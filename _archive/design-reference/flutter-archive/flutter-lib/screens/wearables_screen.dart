import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_service.dart';

/// Wearables Screen - Smart Glasses, Watches, Biometrics
/// Solar Punk Tactical Theme
///
/// Supports:
/// - Open source glasses (Brilliant Frame, Meshtastic, etc.)
/// - Bluetooth watches (PineTime, Bangle.js, Gadgetbridge-compatible)
/// - Biometric data collection
/// - Connection to Human assets
class WearablesScreen extends ConsumerStatefulWidget {
  const WearablesScreen({super.key});

  @override
  ConsumerState<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends ConsumerState<WearablesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_WearableDevice> _devices = [];
  bool _isScanning = false;
  bool _isLoading = true;
  String? _error;

  final AssetService _assetService = AssetService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch wearable assets from backend
      final assets = await _assetService.fetchAssets(subType: 'wearable');

      setState(() {
        _devices.clear();

        // Convert Asset objects to _WearableDevice objects
        for (final asset in assets) {
          // Determine wearable type from metadata or default to watch
          WearableType wearableType = WearableType.watch;
          if (asset.metadata['wearableType'] != null) {
            final typeStr = asset.metadata['wearableType'] as String;
            if (typeStr == 'glasses') {
              wearableType = WearableType.glasses;
            } else if (typeStr == 'ring') {
              wearableType = WearableType.ring;
            }
          }

          // Map status
          DeviceStatus deviceStatus = DeviceStatus.available;
          if (asset.status == 'active') {
            deviceStatus = DeviceStatus.connected;
          } else if (asset.status == 'offline') {
            deviceStatus = DeviceStatus.offline;
          }

          // Extract features from metadata
          final features = asset.metadata['features'] as List<dynamic>?;

          // Extract biometrics from asset.biometrics
          final biometrics = <String, dynamic>{};
          if (asset.biometrics != null) {
            if (asset.biometrics!.heartRate != null) {
              biometrics['heartRate'] = asset.biometrics!.heartRate;
            }
            if (asset.biometrics!.bloodOxygen != null) {
              biometrics['spo2'] = asset.biometrics!.bloodOxygen;
            }
            if (asset.biometrics!.steps != null) {
              biometrics['steps'] = asset.biometrics!.steps;
            }
            if (asset.biometrics!.calories != null) {
              biometrics['calories'] = asset.biometrics!.calories;
            }
            if (asset.biometrics!.stressLevel != null) {
              biometrics['stress'] = asset.biometrics!.stressLevel;
            }
          }

          // Extract battery from telemetry
          double? batteryLevel;
          if (asset.telemetry?.batteryLevel != null) {
            batteryLevel = asset.telemetry!.batteryLevel;
          }

          // Extract assigned user from metadata
          final assignedTo = asset.metadata['assignedTo'] as String?;

          // Extract last sync from metadata or use asset updatedAt
          DateTime? lastSync = asset.updatedAt;

          _devices.add(_WearableDevice(
            id: asset.id,
            name: asset.name,
            type: wearableType,
            status: deviceStatus,
            battery: batteryLevel?.toInt(),
            assignedTo: assignedTo,
            features: features?.map((f) => f.toString()).toList() ?? [],
            lastSync: lastSync,
            biometrics: biometrics,
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



  void _startScan() {
    setState(() => _isScanning = true);
    // Simulate BLE scan
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isScanning = false);
    });
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

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.watch_outlined, color: accentOrange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wearables', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('Glasses • Watches • Biometrics', style: TextStyle(color: mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                // Refresh button
                IconButton(
                  icon: Icon(Icons.refresh, color: accentGreen, size: 20),
                  onPressed: _loadDevices,
                  tooltip: 'Refresh wearables',
                ),
                const SizedBox(width: 8),
                // Scan button
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: _isScanning
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.bluetooth_searching, size: 16),
                  label: Text(_isScanning ? 'Scanning...' : 'Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: accentGreen,
              unselectedLabelColor: mutedColor,
              indicatorColor: accentGreen,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Glasses'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.watch_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Watches'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_outline, size: 16),
                      const SizedBox(width: 6),
                      Text('Biometrics'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: accentGreen),
                        const SizedBox(height: 16),
                        Text('Loading wearables...', style: TextStyle(color: mutedColor)),
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
                            Text('Error loading wearables', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(_error!, style: TextStyle(color: mutedColor, fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadDevices,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDeviceList(WearableType.glasses, cardColor, borderColor, textColor, mutedColor, accentGreen, accentOrange),
                          _buildDeviceList(WearableType.watch, cardColor, borderColor, textColor, mutedColor, accentGreen, accentOrange),
                          _buildBiometricsView(cardColor, borderColor, textColor, mutedColor, accentGreen),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(WearableType type, Color cardColor, Color borderColor, Color textColor, Color mutedColor, Color accentGreen, Color accentOrange) {
    final devices = _devices.where((d) => d.type == type || (type == WearableType.watch && d.type == WearableType.ring)).toList();

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, size: 48, color: mutedColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No ${type.label} found', style: TextStyle(color: mutedColor, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tap "Scan" to discover nearby devices', style: TextStyle(color: mutedColor.withValues(alpha: 0.7), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device, cardColor, borderColor, textColor, mutedColor, accentGreen, accentOrange);
      },
    );
  }

  Widget _buildDeviceCard(_WearableDevice device, Color cardColor, Color borderColor, Color textColor, Color mutedColor, Color accentGreen, Color accentOrange) {
    final statusColor = device.status == DeviceStatus.connected ? accentGreen : mutedColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: device.status == DeviceStatus.connected ? accentGreen.withValues(alpha: 0.3) : borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: device.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(device.type.icon, color: device.type.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(device.status.label, style: TextStyle(color: statusColor, fontSize: 12)),
                        if (device.assignedTo != null) ...[
                          Text(' • ', style: TextStyle(color: mutedColor)),
                          Icon(Icons.person_outline, size: 12, color: mutedColor),
                          const SizedBox(width: 2),
                          Text(device.assignedTo!, style: TextStyle(color: mutedColor, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (device.battery != null)
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          device.battery! > 50 ? Icons.battery_full : Icons.battery_3_bar,
                          size: 16,
                          color: device.battery! > 20 ? accentGreen : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text('${device.battery}%', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
            ],
          ),

          if (device.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: device.features.map((f) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(f, style: TextStyle(color: mutedColor, fontSize: 10, fontWeight: FontWeight.w500)),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (device.status == DeviceStatus.connected) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.sync, size: 14),
                    label: Text('Sync'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentGreen,
                      side: BorderSide(color: accentGreen.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.link_off, size: 14),
                    label: Text('Disconnect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.bluetooth, size: 14),
                    label: Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAssignDialog(device),
                icon: Icon(Icons.person_add_outlined, size: 14),
                label: Text('Assign'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsView(Color cardColor, Color borderColor, Color textColor, Color mutedColor, Color accentGreen) {
    final connectedDevices = _devices.where((d) => d.status == DeviceStatus.connected && d.biometrics.isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time vitals
          Text('REAL-TIME VITALS', style: TextStyle(color: mutedColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildVitalCard('Heart Rate', '72', 'bpm', Icons.favorite, Colors.red, cardColor, borderColor, textColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildVitalCard('SpO2', '98', '%', Icons.air, const Color(0xFF3B82F6), cardColor, borderColor, textColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildVitalCard('Steps', '4,823', 'today', Icons.directions_walk, accentGreen, cardColor, borderColor, textColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildVitalCard('Calories', '312', 'kcal', Icons.local_fire_department, const Color(0xFFF97316), cardColor, borderColor, textColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildVitalCard('Body Temp', '36.6', '°C', Icons.thermostat, const Color(0xFFA855F7), cardColor, borderColor, textColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildVitalCard('HRV', '45', 'ms', Icons.timeline, const Color(0xFF06B6D4), cardColor, borderColor, textColor)),
            ],
          ),

          const SizedBox(height: 24),
          Text('CONNECTED SOURCES', style: TextStyle(color: mutedColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...connectedDevices.map((device) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(device.type.icon, size: 20, color: device.type.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                      Text(device.biometrics.keys.join(', '), style: TextStyle(color: mutedColor, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentGreen,
                    boxShadow: [BoxShadow(color: accentGreen.withValues(alpha: 0.5), blurRadius: 4)],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, String unit, IconData icon, Color color, Color cardColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  void _showAssignDialog(_WearableDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign ${device.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a human to assign this wearable to:'),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(child: Text('Z')),
              title: Text('Zeus'),
              subtitle: Text('Owner'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Data models
enum WearableType {
  glasses(Icons.visibility_outlined, 'Glasses', Color(0xFF3B82F6)),
  watch(Icons.watch_outlined, 'Watch', Color(0xFFF97316)),
  ring(Icons.circle_outlined, 'Ring', Color(0xFFA855F7));

  final IconData icon;
  final String label;
  final Color color;
  const WearableType(this.icon, this.label, this.color);
}

enum DeviceStatus {
  connected('Connected'),
  available('Available'),
  disconnected('Disconnected'),
  offline('Offline');

  final String label;
  const DeviceStatus(this.label);
}

class _WearableDevice {
  final String id;
  final String name;
  final WearableType type;
  final DeviceStatus status;
  final int? battery;
  final String? assignedTo;
  final List<String> features;
  final DateTime? lastSync;
  final Map<String, dynamic> biometrics;

  _WearableDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.battery,
    this.assignedTo,
    this.features = const [],
    this.lastSync,
    this.biometrics = const {},
  });
}
