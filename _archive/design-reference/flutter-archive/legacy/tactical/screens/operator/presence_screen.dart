import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Presence Screen - Operator Physical Location & Status
/// Tracks home/away status, location, device presence, and cameras
class PresenceScreen extends ConsumerStatefulWidget {
  const PresenceScreen({super.key});

  @override
  ConsumerState<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends ConsumerState<PresenceScreen> {
  bool _isHome = true;
  String _currentLocation = 'main-house';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('PRESENCE', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPresenceCard(),
            const SizedBox(height: 16),
            _buildHomeAwayActions(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'LOCATION MAP'),
            const SizedBox(height: 12),
            _buildLocationMap(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'CONNECTED DEVICES'),
            const SizedBox(height: 12),
            _buildDevicesList(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'LOCATIONS'),
            const SizedBox(height: 12),
            _buildLocationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresenceCard() {
    final color = _isHome ? TacticalColors.operational : TacticalColors.inProgress;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.cardElevated(color),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              _isHome ? Icons.home : Icons.directions_walk,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isHome ? 'HOME' : 'AWAY',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.place, size: 16, color: TacticalColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatLocationName(_currentLocation),
                style: const TextStyle(color: TacticalColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricChip(Icons.gps_fixed, 'GPS'),
              const SizedBox(width: 8),
              _buildMetricChip(Icons.analytics, '95%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalColors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TacticalColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeAwayActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.home,
            label: 'SET HOME',
            color: TacticalColors.operational,
            isActive: _isHome,
            onPressed: () => setState(() => _isHome = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.directions_walk,
            label: 'SET AWAY',
            color: TacticalColors.inProgress,
            isActive: !_isHome,
            onPressed: () => setState(() => _isHome = false),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isActive ? color.withValues(alpha: 0.15) : TacticalColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color.withValues(alpha: 0.5) : TacticalColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? color : TacticalColors.textMuted, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? color : TacticalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      height: 200,
      decoration: TacticalDecoration.card,
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            size: const Size.fromHeight(200),
            painter: _GridPatternPainter(),
          ),
          // Location pins
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: TacticalColors.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Location Map',
                  style: TacticalText.cardTitle,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: TacticalColors.operational),
                    const SizedBox(width: 4),
                    Text(
                      '41.0186°N, 73.6416°W',
                      style: TacticalText.cardSubtitle.copyWith(fontFamily: 'monospace'),
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

  Widget _buildDevicesList() {
    final devices = [
      {'name': 'iPhone 15 Pro', 'type': 'iphone', 'connected': true, 'primary': true},
      {'name': 'MacBook Pro', 'type': 'mac', 'connected': true, 'primary': false},
      {'name': 'iPad Pro', 'type': 'ipad', 'connected': false, 'primary': false},
    ];

    return Column(
      children: devices.map((device) => _buildDeviceCard(device)).toList(),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isConnected = device['connected'] as bool;
    final isPrimary = device['primary'] as bool;
    final color = _getDeviceColor(device['type'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? Border.all(color: TacticalColors.primary.withValues(alpha: 0.3))
            : Border.all(color: TacticalColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device['type'] as String),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device['name'] as String,
                        style: TacticalText.cardTitle,
                      ),
                    ),
                    if (isPrimary)
                      const TacticalRoleBadge(role: 'PRIMARY'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected
                            ? TacticalColors.operational
                            : TacticalColors.textDim,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Connected' : 'Offline',
                      style: TacticalText.cardSubtitle.copyWith(
                        color: isConnected
                            ? TacticalColors.operational
                            : TacticalColors.textDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: isConnected ? TacticalColors.operational : TacticalColors.textDim,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList() {
    final locations = [
      {'id': 'main-house', 'name': 'Main House', 'cameras': 3},
      {'id': 'outdoor', 'name': 'Outdoor', 'cameras': 2},
      {'id': 'garage', 'name': 'Garage', 'cameras': 1},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final isActive = location['id'] == _currentLocation;

        return _buildLocationTile(location, isActive);
      },
    );
  }

  Widget _buildLocationTile(Map<String, dynamic> location, bool isActive) {
    return Material(
      color: isActive
          ? TacticalColors.primary.withValues(alpha: 0.15)
          : TacticalColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _currentLocation = location['id'] as String),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? TacticalColors.primary.withValues(alpha: 0.5)
                  : TacticalColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getLocationIcon(location['id'] as String),
                    color: isActive ? TacticalColors.primary : TacticalColors.textMuted,
                    size: 24,
                  ),
                  const Spacer(),
                  if (isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: TacticalDecoration.statusDot(TacticalColors.primary),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location['name'] as String,
                    style: TextStyle(
                      color: isActive ? TacticalColors.textPrimary : TacticalColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${location['cameras']} cameras',
                    style: TacticalText.cardSubtitle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLocationName(String id) {
    return id.replaceAll('-', ' ').split(' ').map((w) =>
      w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : ''
    ).join(' ');
  }

  IconData _getLocationIcon(String id) {
    switch (id) {
      case 'main-house': return Icons.home;
      case 'outdoor': return Icons.park;
      case 'garage': return Icons.garage;
      default: return Icons.place;
    }
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'iphone': return Icons.phone_iphone;
      case 'mac': return Icons.laptop_mac;
      case 'ipad': return Icons.tablet_mac;
      default: return Icons.devices_other;
    }
  }

  Color _getDeviceColor(String type) {
    switch (type) {
      case 'iphone':
      case 'mac':
      case 'ipad':
        return TacticalColors.complete; // Apple blue
      default:
        return TacticalColors.textMuted;
    }
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TacticalColors.textPrimary.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
