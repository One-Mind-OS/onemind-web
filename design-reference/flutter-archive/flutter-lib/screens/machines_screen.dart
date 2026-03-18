import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_service.dart';
import 'sensors_screen.dart';
import 'locations_screen.dart';
import 'world_map_screen.dart';

/// Machines Screen - Robots, Drones, Vehicles, 3D Printers, CNC
/// Physical asset registry with telemetry and control
/// Solar Punk Tactical Theme - NOW WITH REAL DATA
class MachinesScreen extends ConsumerStatefulWidget {
  const MachinesScreen({super.key});

  @override
  ConsumerState<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends ConsumerState<MachinesScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final AssetService _assetService = AssetService();
  List<Asset> _machines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() => _loading = true);
    final machines = await _assetService.fetchAssets(assetType: 'machine');
    if (mounted) {
      setState(() {
        _machines = machines;
        _loading = false;
      });
    }
  }

  List<Asset> get _filteredMachines {
    var filtered = _machines;

    if (_selectedCategory != 'all') {
      filtered = filtered.where((m) => m.subType == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) =>
        m.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF0A0F0A) : Colors.white;
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'MACHINES HUB',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: isDark ? Colors.grey : Colors.black54,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'FLEET'),
              Tab(text: 'SENSORS'),
              Tab(text: 'LOCATIONS'),
              Tab(text: 'MAP'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: accentGreen),
              onPressed: _loadMachines,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            _buildFleetTab(theme, isDark, cardBg, accentGreen, accentOrange),
            const SensorsScreen(embedded: true),
            const LocationsScreen(embedded: true),
            const WorldMapScreen(embedded: true),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddMachineDialog,
          backgroundColor: accentGreen,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text('Add Machine', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildFleetTab(ThemeData theme, bool isDark, Color cardBg, Color accentGreen, Color accentOrange) {
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);

    return Column(
      children: [
        // Search & Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Column(
            children: [
              // Search
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search machines...',
                  prefixIcon: Icon(Icons.search, color: accentGreen),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F1A0F) : const Color(0xFFF5F9F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip('all', 'All', Icons.apps, accentGreen, isDark),
                    _categoryChip('robot', 'Robots', Icons.smart_toy, accentOrange, isDark),
                    _categoryChip('drone', 'Drones', Icons.flight, const Color(0xFF3B82F6), isDark),
                    _categoryChip('vehicle', 'Vehicles', Icons.directions_car, const Color(0xFF8B5CF6), isDark),
                    _categoryChip('3d_printer', '3D Printers', Icons.print, const Color(0xFFEC4899), isDark),
                    _categoryChip('cnc', 'CNC', Icons.precision_manufacturing, const Color(0xFF06B6D4), isDark),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Machines Grid
        Expanded(
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: accentGreen),
                      const SizedBox(height: 16),
                      Text('Loading machines...', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                )
              : _filteredMachines.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.precision_manufacturing, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ? 'No machines found' : 'No machines registered',
                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showAddMachineDialog,
                            icon: Icon(Icons.add, color: accentGreen),
                            label: Text('Register Machine', style: TextStyle(color: accentGreen)),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredMachines.length,
                      itemBuilder: (ctx, i) => _buildMachineCard(_filteredMachines[i], cardBg, borderColor, theme, isDark),
                    ),
        ),
      ],
    );
  }

  Widget _categoryChip(String value, String label, IconData icon, Color color, bool isDark) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? const Color(0xFF0F1A0F) : const Color(0xFFF5F9F5)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineCard(Asset machine, Color cardBg, Color borderColor, ThemeData theme, bool isDark) {
    final statusColor = _getStatusColor(machine.status);
    final battery = machine.telemetry?.batteryLevel?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withValues(alpha: 0.1), Colors.transparent],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getMachineIcon(machine.subType), color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine.name, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(machine.subType ?? 'machine', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(machine.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Battery/Health
                if (battery > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Battery', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                      Text('$battery%', style: TextStyle(color: _getBatteryColor(battery), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: battery / 100,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(_getBatteryColor(battery)),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Location
                if (machine.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: const Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Lat: ${machine.location!.latitude.toStringAsFixed(4)}, Lng: ${machine.location!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
        return const Color(0xFF4ADE80);
      case 'idle':
        return const Color(0xFF3B82F6);
      case 'offline':
        return const Color(0xFF6B7280);
      case 'alert':
        return const Color(0xFFEF4444);
      case 'charging':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getBatteryColor(int battery) {
    if (battery > 60) return const Color(0xFF4ADE80);
    if (battery > 20) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  IconData _getMachineIcon(String? subType) {
    switch (subType?.toLowerCase()) {
      case 'robot':
        return Icons.smart_toy;
      case 'drone':
        return Icons.flight;
      case 'vehicle':
        return Icons.directions_car;
      case '3d_printer':
        return Icons.print;
      case 'cnc':
        return Icons.precision_manufacturing;
      default:
        return Icons.precision_manufacturing;
    }
  }

  void _showAddMachineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Machine'),
        content: const Text('Use the Asset Tracker API to register new machines:\n\ncurl -X POST http://localhost:7777/api/assets/ \\\n  -H "Content-Type: application/json" \\\n  -d \'{"name": "Robot Arm 1", "asset_type": "machine", "sub_type": "robot"}\''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
