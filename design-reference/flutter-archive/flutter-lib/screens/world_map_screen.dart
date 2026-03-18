import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/asset_service.dart';

/// Universal World Map - GPS, Cloud Resources, Devices, Assets
/// Solar Punk Tactical Theme
///
/// Shows:
/// - Physical device locations (Mac, phones, wearables)
/// - Cloud resources (AWS regions, IP addresses)
/// - Entity locations (humans, robots, vehicles)
/// - Location assets (buildings, zones)
class WorldMapScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const WorldMapScreen({super.key, this.embedded = false});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  String _selectedFilter = 'all';
  final List<_MapMarker> _markers = [];
  bool _isLoading = true;
  String? _error;

  final AssetService _assetService = AssetService();
  StreamSubscription<AssetTelemetry>? _telemetrySub;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _connectTelemetry();
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _assetService.disconnectTelemetry();
    super.dispose();
  }

  Future<void> _loadMarkers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all assets from backend
      final assets = await _assetService.fetchAssets();

      setState(() {
        _markers.clear();

        // Convert Asset objects to _MapMarker objects
        for (final asset in assets) {
          // Only show assets with location data
          if (asset.location == null) continue;

          // Map asset type to marker type
          MarkerType markerType;
          switch (asset.assetType.toLowerCase()) {
            case 'human':
              markerType = MarkerType.human;
              break;
            case 'machine':
            case 'robot':
              markerType = MarkerType.machine;
              break;
            case 'device':
              markerType = MarkerType.device;
              break;
            case 'location':
              markerType = MarkerType.location;
              break;
            case 'cloud':
              markerType = MarkerType.cloud;
              break;
            default:
              markerType = MarkerType.device;
          }

          // Build details map from asset data
          final details = <String, dynamic>{};
          details.addAll(asset.metadata);

          if (asset.telemetry != null) {
            if (asset.telemetry!.batteryLevel != null) {
              details['battery'] = '${asset.telemetry!.batteryLevel!.toStringAsFixed(0)}%';
            }
            if (asset.telemetry!.operationalStatus.isNotEmpty) {
              details['status'] = asset.telemetry!.operationalStatus;
            }
          }

          if (asset.biometrics != null) {
            if (asset.biometrics!.heartRate != null) {
              details['heartRate'] = '${asset.biometrics!.heartRate} bpm';
            }
            if (asset.biometrics!.bloodOxygen != null) {
              details['bloodOxygen'] = '${asset.biometrics!.bloodOxygen}%';
            }
            if (asset.biometrics!.stressLevel != null) {
              details['stressLevel'] = asset.biometrics!.stressLevel!;
            }
          }

          if (asset.subType != null) {
            details['type'] = asset.subType!;
          }

          _markers.add(_MapMarker(
            id: asset.id,
            name: asset.name,
            type: markerType,
            lat: asset.location!.latitude,
            lng: asset.location!.longitude,
            status: asset.status,
            details: details,
          ));
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _connectTelemetry() {
    _assetService.connectTelemetry();

    // Listen for telemetry updates
    _telemetrySub = _assetService.telemetryStream.listen((telemetry) {
      // Update marker with new telemetry data
      final markerIndex = _markers.indexWhere((m) => m.id == telemetry.assetId);
      if (markerIndex != -1) {
        setState(() {
          final marker = _markers[markerIndex];
          final details = Map<String, dynamic>.from(marker.details);

          if (telemetry.battery != null) {
            details['battery'] = '${telemetry.battery!.toStringAsFixed(0)}%';
          }
          if (telemetry.operationalStatus != null) {
            details['status'] = telemetry.operationalStatus!;
          }
          if (telemetry.heartRate != null) {
            details['heartRate'] = '${telemetry.heartRate} bpm';
          }
          if (telemetry.bloodOxygen != null) {
            details['bloodOxygen'] = '${telemetry.bloodOxygen}%';
          }

          // Update location if provided
          double? newLat = telemetry.latitude;
          double? newLng = telemetry.longitude;

          _markers[markerIndex] = _MapMarker(
            id: marker.id,
            name: marker.name,
            type: marker.type,
            lat: newLat ?? marker.lat,
            lng: newLng ?? marker.lng,
            status: marker.status,
            details: details,
          );
        });
      }
    });
  }

  List<_MapMarker> get _filteredMarkers {
    if (_selectedFilter == 'all') return _markers;
    return _markers.where((m) => m.type.name == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF5F7F5);
    final cardColor = isDark ? const Color(0xFF111811) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedColor = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          if (!widget.embedded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, color: accentBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('World Map', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Universal GPS • Cloud • Devices • Assets', style: TextStyle(color: mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Loading indicator
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
                      ),
                    ),
                  // Live indicator
                  if (!_isLoading && _assetService.isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentGreen,
                              boxShadow: [BoxShadow(color: accentGreen.withValues(alpha: 0.5), blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('LIVE', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  // Refresh button
                  IconButton(
                    icon: Icon(Icons.refresh, color: accentBlue, size: 20),
                    onPressed: _loadMarkers,
                    tooltip: 'Refresh assets',
                  ),
                ],
              ),
            ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All', Icons.layers_outlined, textColor, accentGreen),
                  _buildFilterChip('cloud', 'Cloud', Icons.cloud_outlined, textColor, accentBlue),
                  _buildFilterChip('device', 'Devices', Icons.devices_outlined, textColor, accentOrange),
                  _buildFilterChip('human', 'Humans', Icons.person_outline, textColor, Colors.purple),
                  _buildFilterChip('machine', 'Machines', Icons.precision_manufacturing_outlined, textColor, Colors.cyan),
                  _buildFilterChip('location', 'Locations', Icons.location_on_outlined, textColor, Colors.pink),
                ],
              ),
            ),
          ),

          // Map area (placeholder - would use flutter_map or google_maps)
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: accentBlue),
                        const SizedBox(height: 16),
                        Text('Loading assets...', style: TextStyle(color: mutedColor)),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: accentOrange),
                            const SizedBox(height: 16),
                            Text('Error loading assets', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(_error!, style: TextStyle(color: mutedColor, fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadMarkers,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Map background
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0D120D) : const Color(0xFFE8F0E8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  isDark
                                      ? 'https://api.mapbox.com/styles/v1/mapbox/dark-v11/static/-74.006,40.7128,10,0/1200x800?access_token=pk.placeholder'
                                      : 'https://api.mapbox.com/styles/v1/mapbox/light-v11/static/-74.006,40.7128,10,0/1200x800?access_token=pk.placeholder',
                                ),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              ),
                            ),
                            child: _markers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_off, size: 64, color: mutedColor.withValues(alpha: 0.3)),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No assets with location data',
                                          style: TextStyle(color: mutedColor, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Assets will appear here when they have GPS coordinates',
                                          style: TextStyle(color: mutedColor.withValues(alpha: 0.7), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),

                          // Markers list overlay
                          if (!_isLoading && _error == null && _markers.isNotEmpty)
                            Positioned(
                              left: 16,
                              top: 16,
                              bottom: 16,
                              width: 320,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: accentGreen),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Assets (${_filteredMarkers.length})',
                                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: 1, color: borderColor),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _filteredMarkers.length,
                                        itemBuilder: (context, index) {
                                          final marker = _filteredMarkers[index];
                                          return _buildMarkerCard(marker, cardColor, borderColor, textColor, mutedColor);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Stats overlay
                          if (!_isLoading && _markers.isNotEmpty)
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('OVERVIEW', style: TextStyle(color: mutedColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                    const SizedBox(height: 8),
                                    _buildStatRow(Icons.cloud_outlined, 'Cloud Regions', '${_markers.where((m) => m.type == MarkerType.cloud).length}', accentBlue),
                                    _buildStatRow(Icons.devices_outlined, 'Devices', '${_markers.where((m) => m.type == MarkerType.device).length}', accentOrange),
                                    _buildStatRow(Icons.person_outline, 'Humans', '${_markers.where((m) => m.type == MarkerType.human).length}', Colors.purple),
                                    _buildStatRow(Icons.precision_manufacturing_outlined, 'Machines', '${_markers.where((m) => m.type == MarkerType.machine).length}', Colors.cyan),
                                    _buildStatRow(Icons.location_on_outlined, 'Locations', '${_markers.where((m) => m.type == MarkerType.location).length}', Colors.pink),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, Color textColor, Color color) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        selectedColor: color,
        checkmarkColor: Colors.white,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  Widget _buildMarkerCard(_MapMarker marker, Color cardColor, Color borderColor, Color textColor, Color mutedColor) {
    final color = marker.type.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(marker.type.icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marker.name, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(marker.type.label, style: TextStyle(color: mutedColor, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(marker.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  marker.status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(marker.status), fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (marker.details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: marker.details.entries.take(3).map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(color: mutedColor, fontSize: 9, fontFamily: 'monospace'),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
      case 'secure':
      case 'nominal':
        return const Color(0xFF4ADE80);
      case 'idle':
        return const Color(0xFF3B82F6);
      case 'patrolling':
        return const Color(0xFFF97316);
      case 'offline':
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

// Data models
enum MarkerType {
  cloud(Icons.cloud_outlined, 'Cloud Resource', Color(0xFF3B82F6)),
  device(Icons.devices_outlined, 'Device', Color(0xFFF97316)),
  human(Icons.person_outline, 'Human', Color(0xFFA855F7)),
  machine(Icons.precision_manufacturing_outlined, 'Machine', Color(0xFF06B6D4)),
  location(Icons.location_on_outlined, 'Location', Color(0xFFEC4899));

  final IconData icon;
  final String label;
  final Color color;
  const MarkerType(this.icon, this.label, this.color);
}

class _MapMarker {
  final String id;
  final String name;
  final MarkerType type;
  final double lat;
  final double lng;
  final String status;
  final Map<String, dynamic> details;

  _MapMarker({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.status,
    this.details = const {},
  });
}
