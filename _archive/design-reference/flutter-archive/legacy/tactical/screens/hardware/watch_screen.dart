import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Watch Screen - ESP32 Health Watch
/// Biometric monitoring, vitals tracking, health alerts
class WatchScreen extends ConsumerStatefulWidget {
  const WatchScreen({super.key});

  @override
  ConsumerState<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends ConsumerState<WatchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('WATCH', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.textMuted,
            ),
            onPressed: _toggleConnection,
          ),
          IconButton(
            icon: const Icon(Icons.history, color: TacticalColors.primary),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWatchFace(),
            const SizedBox(height: 16),
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            _buildSectionHeader('VITAL SIGNS'),
            const SizedBox(height: 12),
            _buildVitalsGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('ACTIVITY'),
            const SizedBox(height: 12),
            _buildActivityStats(),
            const SizedBox(height: 24),
            _buildSectionHeader('HEALTH ALERTS'),
            const SizedBox(height: 12),
            _buildAlerts(),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchFace() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TacticalColors.background,
              border: Border.all(
                color: _isConnected
                    ? TacticalColors.operational
                    : TacticalColors.border,
                width: 3,
              ),
              boxShadow: _isConnected
                  ? [
                      BoxShadow(
                        color: TacticalColors.operational.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isConnected ? _pulseAnimation.value : 1.0,
                      child: Icon(
                        Icons.favorite,
                        size: 32,
                        color: _isConnected
                            ? TacticalColors.critical
                            : TacticalColors.textDim,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _isConnected ? '72' : '--',
                  style: TextStyle(
                    color: _isConnected
                        ? TacticalColors.textPrimary
                        : TacticalColors.textDim,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'BPM',
                  style: TextStyle(
                    color: _isConnected
                        ? TacticalColors.textMuted
                        : TacticalColors.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ESP32 HEALTH WATCH',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.battery_full,
                size: 16,
                color: TacticalColors.operational,
              ),
              const SizedBox(width: 4),
              Text(
                _isConnected ? '85%' : '--%',
                style: const TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: TacticalDecoration.statusDot(
              _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.nonOperational,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'MQTT CONNECTED' : 'DISCONNECTED',
                  style: TacticalText.statusLabel(
                    _isConnected
                        ? TacticalColors.operational
                        : TacticalColors.nonOperational,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isConnected
                      ? 'Receiving biometric data'
                      : 'Tap to connect via MQTT',
                  style: TacticalText.cardSubtitle,
                ),
              ],
            ),
          ),
          TacticalOutlineButton(
            label: _isConnected ? 'DISCONNECT' : 'CONNECT',
            color: _isConnected
                ? TacticalColors.nonOperational
                : TacticalColors.primary,
            onTap: _toggleConnection,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return TacticalSectionHeader(title: title);
  }

  Widget _buildVitalsGrid() {
    return Row(
      children: [
        Expanded(child: _buildVitalCard('HEART RATE', '72', 'BPM', Icons.favorite, TacticalColors.critical)),
        const SizedBox(width: 12),
        Expanded(child: _buildVitalCard('SpO2', '98', '%', Icons.air, TacticalColors.operational)),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              TacticalStatusBadge(label: 'NORMAL', status: 'operational'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _isConnected ? value : '--',
                style: TextStyle(
                  color: _isConnected
                      ? TacticalColors.textPrimary
                      : TacticalColors.textDim,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: TacticalText.cardSubtitle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TacticalText.sectionHeader),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return TacticalStatusCard(
      title: 'TODAY',
      items: [
        TacticalStatusItem(label: 'Steps', status: 'operational', count: _isConnected ? 8432 : 0),
        TacticalStatusItem(label: 'Calories', status: 'in_progress', count: _isConnected ? 342 : 0),
        TacticalStatusItem(label: 'Active Minutes', status: 'complete', count: _isConnected ? 45 : 0),
      ],
    );
  }

  Widget _buildAlerts() {
    if (!_isConnected) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: const Center(
          child: Text(
            'Connect watch to view health alerts',
            style: TextStyle(color: TacticalColors.textMuted),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.cardElevated(TacticalColors.operational),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TacticalColors.operational.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 24,
              color: TacticalColors.operational,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALL VITALS NORMAL',
                  style: TextStyle(
                    color: TacticalColors.operational,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No health alerts at this time',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HEALTH HISTORY', style: TacticalText.screenTitle),
            const SizedBox(height: 24),
            const Text(
              'View historical biometric data, trends, and health insights.',
              style: TextStyle(color: TacticalColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TacticalOutlineButton(
              label: 'CLOSE',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
