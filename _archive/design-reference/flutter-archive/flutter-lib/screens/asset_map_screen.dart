import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/asset_service.dart';
import '../game/systems/audio_system.dart';

/// Tactical Map Screen - Real-Time Asset Tracking
/// ==============================================
/// OpenStreetMap-based real-time tactical map showing:
/// - Asset GPS markers (color-coded by type)
/// - Live WebSocket updates
/// - Geofence zones
/// - Asset trails (movement history)
/// - Click markers for details
/// - Filter by asset type

class AssetMapScreen extends ConsumerStatefulWidget {
  const AssetMapScreen({super.key});

  @override
  ConsumerState<AssetMapScreen> createState() => _AssetMapScreenState();
}

class _AssetMapScreenState extends ConsumerState<AssetMapScreen> {
  final AssetService _assetService = AssetService();
  final AudioSystem _audioSystem = AudioSystem();
  final MapController _mapController = MapController();

  List<Asset> _assets = [];
  final Map<String, List<LatLng>> _assetTrails = {}; // Movement history
  StreamSubscription<AssetTelemetry>? _telemetrySub;
  StreamSubscription<AssetAlert>? _alertSub;

  // Filters
  bool _showMachines = true;
  bool _showHumans = true;
  bool _showDevices = true;
  bool _showLocations = true;
  bool _showTrails = false;
  bool _showGeofences = true;
  bool _darkMode = true;

  // Selected asset
  Asset? _selectedAsset;

  // Default center (San Francisco - will auto-center on first asset)
  LatLng _center = LatLng(37.7749, -122.4194);
  final double _zoom = 13.0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _subscribeLiveUpdates();
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _alertSub?.cancel();
    _assetService.disconnectTelemetry();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    final assets = await _assetService.fetchAssets();
    if (mounted) {
      setState(() {
        _assets = assets;
        // Auto-center on first asset with location
        final firstWithLocation = assets.where((a) => a.location != null).isNotEmpty
            ? assets.firstWhere((a) => a.location != null)
            : null;

        if (firstWithLocation != null && firstWithLocation.location != null) {
          _center = LatLng(
            firstWithLocation.location!.latitude,
            firstWithLocation.location!.longitude,
          );
          _mapController.move(_center, _zoom);
        }
      });
    }
  }

  void _subscribeLiveUpdates() {
    _assetService.connectTelemetry(clientId: 'tactical-map');

    // Real-time telemetry updates
    _telemetrySub = _assetService.telemetryStream.listen((telemetry) {
      final index = _assets.indexWhere((a) => a.id == telemetry.assetId);
      if (index != -1 && mounted) {
        final asset = _assets[index];

        // Update trail if location changed
        if (telemetry.latitude != null && telemetry.longitude != null) {
          final newPos = LatLng(telemetry.latitude!, telemetry.longitude!);

          if (!_assetTrails.containsKey(asset.id)) {
            _assetTrails[asset.id] = [];
          }
          _assetTrails[asset.id]!.add(newPos);

          // Keep last 50 positions
          if (_assetTrails[asset.id]!.length > 50) {
            _assetTrails[asset.id]!.removeAt(0);
          }

          // Update asset location
          setState(() {
            _assets[index] = Asset(
              id: asset.id,
              name: asset.name,
              assetType: asset.assetType,
              subType: asset.subType,
              status: asset.status,
              location: GeoLocation(
                latitude: telemetry.latitude!,
                longitude: telemetry.longitude!,
              ),
              telemetry: asset.telemetry,
              biometrics: asset.biometrics,
              ownerId: asset.ownerId,
              teamId: asset.teamId,
              assignedAgentId: asset.assignedAgentId,
              tags: asset.tags,
              metadata: asset.metadata,
              natsSwitch: asset.natsSwitch,
              createdAt: asset.createdAt,
              updatedAt: asset.updatedAt,
            );
          });
        }
      }
    });

    // Alert notifications with audio
    _alertSub = _assetService.alertStream.listen((alert) {
      if (alert.severity == 'critical') {
        _audioSystem.playAlert();
      } else {
        _audioSystem.playWarning();
      }

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${alert.assetName}: ${alert.alerts.join(', ')}'),
            backgroundColor: alert.severity == 'critical' ? const Color(0xFFEF4444) : const Color(0xFFF97316),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  List<Asset> get _filteredAssets {
    return _assets.where((asset) {
      if (asset.location == null) return false;

      switch (asset.assetType) {
        case 'machine':
          return _showMachines;
        case 'human':
          return _showHumans;
        case 'device':
          return _showDevices;
        case 'location':
          return _showLocations;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.map, color: accentGreen, size: 20),
            const SizedBox(width: 8),
            const Text('TACTICAL MAP'),
          ],
        ),
        actions: [
          // Dark/Light mode toggle
          IconButton(
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: () => setState(() => _darkMode = !_darkMode),
            tooltip: 'Toggle map style',
          ),
          // Trails toggle
          IconButton(
            icon: Icon(Icons.route, color: _showTrails ? accentGreen : Colors.grey, size: 20),
            onPressed: () => setState(() => _showTrails = !_showTrails),
            tooltip: 'Toggle trails',
          ),
          // Geofence toggle
          IconButton(
            icon: Icon(Icons.radio_button_unchecked, color: _showGeofences ? accentGreen : Colors.grey, size: 20),
            onPressed: () => setState(() => _showGeofences = !_showGeofences),
            tooltip: 'Toggle geofences',
          ),
          // Refresh
          IconButton(
            icon: Icon(Icons.refresh, color: accentGreen, size: 20),
            onPressed: _loadAssets,
            tooltip: 'Refresh assets',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _assets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No assets with GPS location', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadAssets,
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _zoom,
                    minZoom: 3,
                    maxZoom: 18,
                    onTap: (_, _) => setState(() => _selectedAsset = null),
                  ),
                  children: [
                    // Base map layer
                    TileLayer(
                      urlTemplate: _darkMode
                          ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
                          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: _darkMode ? const [] : const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.onemind.os',
                    ),

                    // Asset trails (movement history)
                    if (_showTrails)
                      PolylineLayer(
                        polylines: _assetTrails.entries.where((entry) {
                          return _assets.any((a) => a.id == entry.key);
                        }).map((entry) {
                          final asset = _assets.firstWhere((a) => a.id == entry.key);
                          return Polyline(
                            points: entry.value,
                            strokeWidth: 2,
                            color: _getAssetColor(asset.assetType).withValues(alpha: 0.5),
                            // Note: isDotted removed in flutter_map 7.0+
                          );
                        }).toList().cast<Polyline>(),
                      ),

                    // Geofence zones (circles)
                    if (_showGeofences)
                      CircleLayer(
                        circles: _assets
                            .where((a) => a.assetType == 'location' && a.location != null)
                            .map((location) => CircleMarker(
                                  point: LatLng(location.location!.latitude, location.location!.longitude),
                                  radius: 100, // meters
                                  color: accentBlue.withValues(alpha: 0.1),
                                  borderColor: accentBlue,
                                  borderStrokeWidth: 2,
                                  useRadiusInMeter: true,
                                ))
                            .toList(),
                      ),

                    // Asset markers
                    MarkerLayer(
                      markers: _filteredAssets.map((asset) {
                        final color = _getAssetColor(asset.assetType);
                        final isSelected = _selectedAsset?.id == asset.id;

                        return Marker(
                          point: LatLng(asset.location!.latitude, asset.location!.longitude),
                          width: isSelected ? 50 : 40,
                          height: isSelected ? 50 : 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedAsset = asset);
                              _audioSystem.playClick();
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse animation for selected
                                if (isSelected)
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color.withValues(alpha: 0.3),
                                    ),
                                  ),
                                // Marker
                                Container(
                                  width: isSelected ? 40 : 30,
                                  height: isSelected ? 40 : 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getAssetIcon(asset.assetType),
                                    color: Colors.white,
                                    size: isSelected ? 20 : 16,
                                  ),
                                ),
                                // Alert indicator
                                if (asset.status == 'alert')
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFEF4444),
                                        border: Border.all(color: Colors.white, width: 1),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Filter panel (top-left)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildFilterPanel(accentGreen, accentOrange, accentBlue),
                ),

                // Asset count (top-right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildAssetCount(),
                ),

                // Asset detail panel (bottom)
                if (_selectedAsset != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildAssetDetailPanel(),
                  ),
              ],
            ),
      floatingActionButton: _assets.isNotEmpty
          ? FloatingActionButton.small(
              heroTag: 'center',
              onPressed: () {
                if (_filteredAssets.isNotEmpty) {
                  final bounds = _calculateBounds(_filteredAssets);
                  _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
                }
              },
              backgroundColor: accentGreen,
              child: const Icon(Icons.center_focus_strong, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildFilterPanel(Color green, Color orange, Color blue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FILTERS', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          _filterChip('Machines', _showMachines, orange, (val) => setState(() => _showMachines = val)),
          _filterChip('Humans', _showHumans, blue, (val) => setState(() => _showHumans = val)),
          _filterChip('Devices', _showDevices, const Color(0xFF8B5CF6), (val) => setState(() => _showDevices = val)),
          _filterChip('Locations', _showLocations, const Color(0xFF06B6D4), (val) => setState(() => _showLocations = val)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool value, Color color, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? color : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: value ? Colors.white : Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.3)),
      ),
      child: Text(
        '${_filteredAssets.length} ASSETS',
        style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildAssetDetailPanel() {
    final asset = _selectedAsset!;
    final color = _getAssetColor(asset.assetType);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color),
                ),
                child: Icon(_getAssetIcon(asset.assetType), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(asset.assetType.toUpperCase(), style: TextStyle(color: color, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => setState(() => _selectedAsset = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow('Status', asset.status.toUpperCase(), _getStatusColor(asset.status)),
          if (asset.location != null)
            _detailRow('Location', '${asset.location!.latitude.toStringAsFixed(4)}, ${asset.location!.longitude.toStringAsFixed(4)}', const Color(0xFF3B82F6)),
          if (asset.telemetry?.batteryLevel != null)
            _detailRow('Battery', '${asset.telemetry!.batteryLevel!.toInt()}%', _getBatteryColor(asset.telemetry!.batteryLevel!.toInt())),
          if (asset.biometrics?.heartRate != null)
            _detailRow('Heart Rate', '${asset.biometrics!.heartRate} bpm', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Color _getAssetColor(String type) {
    switch (type) {
      case 'machine':
        return const Color(0xFFF97316); // Orange
      case 'human':
        return const Color(0xFF3B82F6); // Blue
      case 'device':
        return const Color(0xFF8B5CF6); // Purple
      case 'location':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFF4ADE80); // Green
    }
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'machine':
        return Icons.precision_manufacturing;
      case 'human':
        return Icons.person;
      case 'device':
        return Icons.sensors;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
        return const Color(0xFF4ADE80);
      case 'alert':
        return const Color(0xFFEF4444);
      case 'offline':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getBatteryColor(int battery) {
    if (battery > 60) return const Color(0xFF4ADE80);
    if (battery > 20) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  LatLngBounds _calculateBounds(List<Asset> assets) {
    if (assets.isEmpty) {
      return LatLngBounds(LatLng(37.7, -122.5), LatLng(37.8, -122.3));
    }

    double minLat = assets.first.location!.latitude;
    double maxLat = assets.first.location!.latitude;
    double minLng = assets.first.location!.longitude;
    double maxLng = assets.first.location!.longitude;

    for (final asset in assets) {
      if (asset.location == null) continue;
      if (asset.location!.latitude < minLat) minLat = asset.location!.latitude;
      if (asset.location!.latitude > maxLat) maxLat = asset.location!.latitude;
      if (asset.location!.longitude < minLng) minLng = asset.location!.longitude;
      if (asset.location!.longitude > maxLng) maxLng = asset.location!.longitude;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }
}
