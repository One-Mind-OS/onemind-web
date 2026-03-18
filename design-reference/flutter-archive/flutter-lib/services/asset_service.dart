import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/environment.dart';

/// Asset Service - Fetch and subscribe to real assets
/// ===================================================
/// Connects to backend /api/assets and WebSocket telemetry streams.

class AssetService {
  static final AssetService _instance = AssetService._internal();
  factory AssetService() => _instance;
  AssetService._internal();

  final String _baseUrl = Environment.apiBaseUrl;
  WebSocketChannel? _telemetryChannel;
  final _telemetryController = StreamController<AssetTelemetry>.broadcast();
  final _alertController = StreamController<AssetAlert>.broadcast();

  bool _connected = false;

  Stream<AssetTelemetry> get telemetryStream => _telemetryController.stream;
  Stream<AssetAlert> get alertStream => _alertController.stream;
  bool get isConnected => _connected;

  /// Fetch all assets from backend
  Future<List<Asset>> fetchAssets({
    String? assetType,
    String? subType,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (assetType != null) params['asset_type'] = assetType;
      if (subType != null) params['sub_type'] = subType;
      if (status != null) params['status'] = status;

      final uri = Uri.parse('$_baseUrl/api/assets/').replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> assetList = data['assets'] ?? [];
        return assetList.map((a) => Asset.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching assets: $e');
      return [];
    }
  }

  /// Fetch single asset by ID
  Future<Asset?> fetchAsset(String assetId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/assets/$assetId'));
      if (response.statusCode == 200) {
        return Asset.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching asset: $e');
      return null;
    }
  }

  /// Fetch asset stats
  Future<AssetStats?> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/assets/stats/overview'));
      if (response.statusCode == 200) {
        return AssetStats.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      return null;
    }
  }

  /// Connect to WebSocket for real-time telemetry
  void connectTelemetry({String? clientId}) {
    if (_connected) return;

    try {
      final wsUrl = _baseUrl.replaceFirst('http', 'ws');
      final id = clientId ?? 'game-view-${DateTime.now().millisecondsSinceEpoch}';

      _telemetryChannel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws/assets?client_id=$id'),
      );

      _telemetryChannel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            final type = data['type'] ?? data['event_type'] ?? '';

            if (type.contains('telemetry') || data.containsKey('battery') || data.containsKey('heart_rate')) {
              _telemetryController.add(AssetTelemetry.fromJson(data));
            } else if (type.contains('alert') || data.containsKey('alerts')) {
              _alertController.add(AssetAlert.fromJson(data));
            }
          } catch (e) {
            // Ignore parse errors
          }
        },
        onError: (error) {
          debugPrint('Telemetry WebSocket error: $error');
          _connected = false;
        },
        onDone: () {
          debugPrint('Telemetry WebSocket closed');
          _connected = false;
          // Auto-reconnect after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (!_connected) connectTelemetry(clientId: clientId);
          });
        },
      );

      _connected = true;
    } catch (e) {
      debugPrint('Failed to connect telemetry WebSocket: $e');
      _connected = false;
    }
  }

  /// Disconnect telemetry stream
  void disconnectTelemetry() {
    _telemetryChannel?.sink.close();
    _connected = false;
  }

  void dispose() {
    disconnectTelemetry();
    _telemetryController.close();
    _alertController.close();
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

class Asset {
  final String id;
  final String name;
  final String assetType;
  final String? subType;
  final String status;
  final GeoLocation? location;
  final MachineTelemetry? telemetry;
  final Biometrics? biometrics;
  final String? ownerId;
  final String? teamId;
  final String? assignedAgentId;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final bool natsSwitch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asset({
    required this.id,
    required this.name,
    required this.assetType,
    this.subType,
    required this.status,
    this.location,
    this.telemetry,
    this.biometrics,
    this.ownerId,
    this.teamId,
    this.assignedAgentId,
    this.tags = const [],
    this.metadata = const {},
    this.natsSwitch = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      assetType: json['asset_type'] ?? 'device',
      subType: json['sub_type'],
      status: json['status'] ?? 'offline',
      location: json['location'] != null ? GeoLocation.fromJson(json['location']) : null,
      telemetry: json['telemetry'] != null ? MachineTelemetry.fromJson(json['telemetry']) : null,
      biometrics: json['biometrics'] != null ? Biometrics.fromJson(json['biometrics']) : null,
      ownerId: json['owner_id'],
      teamId: json['team_id'],
      assignedAgentId: json['assigned_agent_id'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      natsSwitch: json['nats_switch'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  /// Calculate health based on status and telemetry
  double get health {
    if (status == 'offline') return 0.0;
    if (status == 'alert') return 0.3;
    if (status == 'maintenance') return 0.5;

    // Machine telemetry health
    if (telemetry != null) {
      if (telemetry!.batteryLevel != null) {
        return (telemetry!.batteryLevel! / 100).clamp(0.0, 1.0);
      }
      if (telemetry!.operationalStatus == 'error') return 0.2;
    }

    // Human biometrics health
    if (biometrics != null) {
      double h = 1.0;
      if (biometrics!.heartRate != null) {
        if (biometrics!.heartRate! > 120 || biometrics!.heartRate! < 50) h -= 0.3;
      }
      if (biometrics!.bloodOxygen != null && biometrics!.bloodOxygen! < 95) h -= 0.3;
      if (biometrics!.stressLevel == 'high') h -= 0.2;
      return h.clamp(0.0, 1.0);
    }

    return status == 'online' || status == 'active' ? 1.0 : 0.7;
  }
}

class GeoLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? heading;
  final double? speed;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.heading,
    this.speed,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      heading: json['heading']?.toDouble(),
      speed: json['speed']?.toDouble(),
    );
  }
}

class MachineTelemetry {
  final double? batteryLevel;
  final double? cpuUsage;
  final double? memoryUsage;
  final double? speed;
  final double? heading;
  final String operationalStatus;
  final String? missionId;

  MachineTelemetry({
    this.batteryLevel,
    this.cpuUsage,
    this.memoryUsage,
    this.speed,
    this.heading,
    this.operationalStatus = 'ready',
    this.missionId,
  });

  factory MachineTelemetry.fromJson(Map<String, dynamic> json) {
    return MachineTelemetry(
      batteryLevel: json['battery_level']?.toDouble(),
      cpuUsage: json['cpu_usage']?.toDouble(),
      memoryUsage: json['memory_usage']?.toDouble(),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
      operationalStatus: json['operational_status'] ?? 'ready',
      missionId: json['mission_id'],
    );
  }
}

class Biometrics {
  final int? heartRate;
  final double? bloodOxygen;
  final double? bodyTemp;
  final int? stepsToday;
  final int? steps;
  final int? calories;
  final String? stressLevel;

  Biometrics({
    this.heartRate,
    this.bloodOxygen,
    this.bodyTemp,
    this.stepsToday,
    this.steps,
    this.calories,
    this.stressLevel,
  });

  factory Biometrics.fromJson(Map<String, dynamic> json) {
    return Biometrics(
      heartRate: json['heart_rate'],
      bloodOxygen: json['blood_oxygen']?.toDouble(),
      bodyTemp: json['body_temp']?.toDouble(),
      stepsToday: json['steps_today'],
      steps: json['steps'] ?? json['steps_today'],
      calories: json['calories'],
      stressLevel: json['stress_level'],
    );
  }
}

class AssetStats {
  final int totalAssets;
  final Map<String, int> byType;
  final Map<String, int> byStatus;
  final int geofenceZones;

  AssetStats({
    required this.totalAssets,
    required this.byType,
    required this.byStatus,
    required this.geofenceZones,
  });

  factory AssetStats.fromJson(Map<String, dynamic> json) {
    return AssetStats(
      totalAssets: json['total_assets'] ?? 0,
      byType: Map<String, int>.from(json['by_type'] ?? {}),
      byStatus: Map<String, int>.from(json['by_status'] ?? {}),
      geofenceZones: json['geofence_zones'] ?? 0,
    );
  }
}

class AssetTelemetry {
  final String assetId;
  final String assetType;
  final String? subType;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? battery;
  final String? operationalStatus;
  final int? heartRate;
  final double? bloodOxygen;
  final String? stressLevel;

  AssetTelemetry({
    required this.assetId,
    required this.assetType,
    this.subType,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.battery,
    this.operationalStatus,
    this.heartRate,
    this.bloodOxygen,
    this.stressLevel,
  });

  factory AssetTelemetry.fromJson(Map<String, dynamic> json) {
    return AssetTelemetry(
      assetId: json['asset_id'] ?? '',
      assetType: json['asset_type'] ?? 'device',
      subType: json['sub_type'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      battery: json['battery']?.toDouble(),
      operationalStatus: json['operational_status'],
      heartRate: json['heart_rate'],
      bloodOxygen: json['blood_oxygen']?.toDouble(),
      stressLevel: json['stress_level'],
    );
  }

  /// Calculate health from telemetry data
  double get health {
    if (battery != null) return (battery! / 100).clamp(0.0, 1.0);
    if (operationalStatus == 'error') return 0.2;
    if (heartRate != null && (heartRate! > 120 || heartRate! < 50)) return 0.5;
    if (bloodOxygen != null && bloodOxygen! < 95) return 0.6;
    return 1.0;
  }
}

class AssetAlert {
  final String assetId;
  final String assetName;
  final String assetType;
  final List<String> alerts;
  final String severity;
  final DateTime timestamp;

  AssetAlert({
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.alerts,
    required this.severity,
    required this.timestamp,
  });

  factory AssetAlert.fromJson(Map<String, dynamic> json) {
    return AssetAlert(
      assetId: json['asset_id'] ?? '',
      assetName: json['asset_name'] ?? 'Unknown',
      assetType: json['asset_type'] ?? 'device',
      alerts: List<String>.from(json['alerts'] ?? []),
      severity: json['severity'] ?? 'warning',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
