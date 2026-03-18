import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Biometrics Screen - Operator Health Telemetry
/// Tracks vital signs, health metrics, and physiological data
class BiometricsScreen extends ConsumerWidget {
  const BiometricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('BIOMETRICS', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: TacticalColors.primary),
            onPressed: () {},
          ),
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
            // Operator Status
            _buildOperatorStatus(),
            const SizedBox(height: 24),

            // Vital Signs
            const TacticalSectionHeader(title: 'VITAL SIGNS'),
            const SizedBox(height: 12),
            _buildVitalSigns(),

            const SizedBox(height: 24),

            // Body Metrics
            const TacticalSectionHeader(title: 'BODY METRICS'),
            const SizedBox(height: 12),
            _buildBodyMetrics(),

            const SizedBox(height: 24),

            // Activity Stats
            const TacticalSectionHeader(title: 'ACTIVITY'),
            const SizedBox(height: 12),
            _buildActivityStats(),

            const SizedBox(height: 24),

            // Recovery & Sleep
            const TacticalSectionHeader(title: 'RECOVERY'),
            const SizedBox(height: 12),
            _buildRecoverySection(),

            const SizedBox(height: 24),

            // Data Sources
            const TacticalSectionHeader(title: 'DATA SOURCES'),
            const SizedBox(height: 12),
            _buildDataSources(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.cardElevated(TacticalColors.operational),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TacticalColors.operational.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: TacticalColors.operational, width: 2),
            ),
            child: const Icon(
              Icons.favorite,
              size: 36,
              color: TacticalColors.operational,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERATOR STATUS',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'OPTIMAL',
                  style: TextStyle(
                    color: TacticalColors.operational,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'All vitals within normal range',
                  style: TextStyle(
                    color: TacticalColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSigns() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                icon: Icons.favorite,
                label: 'HEART RATE',
                value: '--',
                unit: 'BPM',
                color: TacticalColors.critical,
                status: 'normal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVitalCard(
                icon: Icons.bloodtype,
                label: 'BLOOD OXYGEN',
                value: '--',
                unit: '%',
                color: TacticalColors.complete,
                status: 'normal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                icon: Icons.thermostat,
                label: 'BODY TEMP',
                value: '--',
                unit: '°F',
                color: TacticalColors.inProgress,
                status: 'normal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVitalCard(
                icon: Icons.monitor_heart,
                label: 'HRV',
                value: '--',
                unit: 'MS',
                color: TacticalColors.primary,
                status: 'normal',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: TacticalDecoration.statusDot(
                  status == 'normal' ? TacticalColors.operational : TacticalColors.critical,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetrics() {
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          _buildMetricRow(Icons.monitor_weight, 'Weight', '--', 'lbs'),
          const Divider(color: TacticalColors.border, height: 1),
          _buildMetricRow(Icons.water_drop, 'Hydration', '--', '%'),
          const Divider(color: TacticalColors.border, height: 1),
          _buildMetricRow(Icons.local_fire_department, 'Body Fat', '--', '%'),
          const Divider(color: TacticalColors.border, height: 1),
          _buildMetricRow(Icons.fitness_center, 'Muscle Mass', '--', 'lbs'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(IconData icon, String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TacticalColors.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return Row(
      children: [
        Expanded(child: _buildActivityCard(Icons.directions_walk, 'STEPS', '--', TacticalColors.operational)),
        const SizedBox(width: 12),
        Expanded(child: _buildActivityCard(Icons.local_fire_department, 'CALORIES', '--', TacticalColors.critical)),
        const SizedBox(width: 12),
        Expanded(child: _buildActivityCard(Icons.timer, 'ACTIVE', '--m', TacticalColors.inProgress)),
      ],
    );
  }

  Widget _buildActivityCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoverySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Row(
            children: [
              _buildRecoveryMetric(Icons.bedtime, 'SLEEP', '--h', TacticalColors.complete),
              const SizedBox(width: 16),
              _buildRecoveryMetric(Icons.battery_charging_full, 'RECOVERY', '--%', TacticalColors.operational),
              const SizedBox(width: 16),
              _buildRecoveryMetric(Icons.psychology, 'STRESS', '--', TacticalColors.inProgress),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: TacticalColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.insights, size: 16, color: TacticalColors.textMuted),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Connect a device to see recovery insights',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryMetric(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSources() {
    final sources = [
      {'name': 'Oura Ring', 'icon': Icons.circle_outlined, 'connected': false},
      {'name': 'Apple Health', 'icon': Icons.favorite, 'connected': false},
      {'name': 'ESP32 Watch', 'icon': Icons.watch, 'connected': false},
      {'name': 'Whoop', 'icon': Icons.sports_score, 'connected': false},
    ];

    return Column(
      children: sources.map((source) => _buildSourceCard(source)).toList(),
    );
  }

  Widget _buildSourceCard(Map<String, dynamic> source) {
    final isConnected = source['connected'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isConnected
                  ? TacticalColors.operational.withValues(alpha: 0.1)
                  : TacticalColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              source['icon'] as IconData,
              size: 20,
              color: isConnected ? TacticalColors.operational : TacticalColors.textDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source['name'] as String,
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isConnected ? 'Connected' : 'Not connected',
                  style: TextStyle(
                    color: isConnected ? TacticalColors.operational : TacticalColors.textDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TacticalOutlineButton(
            label: isConnected ? 'DISCONNECT' : 'CONNECT',
            color: isConnected ? TacticalColors.nonOperational : TacticalColors.primary,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
