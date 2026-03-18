// Vehicle models for Fleet Management
// Supports Tesla, Ford, OBD-II connected vehicles

import 'package:flutter/material.dart';
import '../../../../shared/theme/tactical.dart';

/// Vehicle type enum
enum VehicleType {
  tesla,
  ford,
  obd,
  generic,
}

/// Vehicle status
enum VehicleStatus {
  online,
  offline,
  charging,
  driving,
  parked,
  unknown,
}

/// Vehicle model
class Vehicle {
  final String id;
  final String name;
  final VehicleType type;
  final VehicleStatus status;
  final String? model;
  final String? vin;
  final double? batteryLevel;
  final double? fuelLevel;
  final double? range;
  final double? odometer;
  final bool isLocked;
  final bool isCharging;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? lastSeen;

  const Vehicle({
    required this.id,
    required this.name,
    this.type = VehicleType.generic,
    this.status = VehicleStatus.unknown,
    this.model,
    this.vin,
    this.batteryLevel,
    this.fuelLevel,
    this.range,
    this.odometer,
    this.isLocked = true,
    this.isCharging = false,
    this.location,
    this.latitude,
    this.longitude,
    this.lastSeen,
  });

  /// Status color (tactical themed)
  Color get statusColor {
    switch (status) {
      case VehicleStatus.online:
      case VehicleStatus.parked:
        return TacticalColors.operational;
      case VehicleStatus.charging:
        return TacticalColors.complete;
      case VehicleStatus.driving:
        return TacticalColors.inProgress;
      case VehicleStatus.offline:
        return TacticalColors.critical;
      case VehicleStatus.unknown:
        return TacticalColors.textMuted;
    }
  }

  /// Status icon
  IconData get statusIcon {
    switch (status) {
      case VehicleStatus.online:
      case VehicleStatus.parked:
        return Icons.local_parking;
      case VehicleStatus.charging:
        return Icons.bolt;
      case VehicleStatus.driving:
        return Icons.speed;
      case VehicleStatus.offline:
        return Icons.power_off;
      case VehicleStatus.unknown:
        return Icons.help_outline;
    }
  }

  /// Type icon
  IconData get typeIcon {
    switch (type) {
      case VehicleType.tesla:
        return Icons.electric_car;
      case VehicleType.ford:
        return Icons.directions_car;
      case VehicleType.obd:
        return Icons.car_repair;
      case VehicleType.generic:
        return Icons.directions_car_filled;
    }
  }

  /// Type label
  String get typeLabel {
    switch (type) {
      case VehicleType.tesla:
        return 'TESLA';
      case VehicleType.ford:
        return 'FORD';
      case VehicleType.obd:
        return 'OBD-II';
      case VehicleType.generic:
        return 'VEHICLE';
    }
  }

  /// Energy level (battery or fuel)
  double? get energyLevel => batteryLevel ?? fuelLevel;

  /// Is electric vehicle
  bool get isElectric => type == VehicleType.tesla || batteryLevel != null;

  /// Relative time since last seen
  String get lastSeenRelative {
    if (lastSeen == null) return 'Unknown';
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: VehicleType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => VehicleType.generic,
      ),
      status: VehicleStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VehicleStatus.unknown,
      ),
      model: json['model'] as String?,
      vin: json['vin'] as String?,
      batteryLevel: (json['battery_level'] as num?)?.toDouble(),
      fuelLevel: (json['fuel_level'] as num?)?.toDouble(),
      range: (json['range'] as num?)?.toDouble(),
      odometer: (json['odometer'] as num?)?.toDouble(),
      isLocked: json['is_locked'] as bool? ?? true,
      isCharging: json['is_charging'] as bool? ?? false,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'model': model,
      'vin': vin,
      'battery_level': batteryLevel,
      'fuel_level': fuelLevel,
      'range': range,
      'odometer': odometer,
      'is_locked': isLocked,
      'is_charging': isCharging,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}
