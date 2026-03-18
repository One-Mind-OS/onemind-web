import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Drones Screen - Drone Fleet Operations
/// Manage and coordinate drone fleet
class DronesScreen extends ConsumerWidget {
  const DronesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('DRONES', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: TacticalColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: TacticalColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fleet Status
            _buildFleetStatus(),
            const SizedBox(height: 24),

            // Active Missions
            const TacticalSectionHeader(title: 'ACTIVE MISSIONS'),
            const SizedBox(height: 12),
            _buildActiveMissions(),

            const SizedBox(height: 24),

            // Fleet Roster
            const TacticalSectionHeader(title: 'FLEET ROSTER'),
            const SizedBox(height: 12),
            _buildFleetRoster(),

            const SizedBox(height: 24),

            // Quick Commands
            const TacticalSectionHeader(title: 'FLEET COMMANDS'),
            const SizedBox(height: 12),
            _buildQuickCommands(),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.cardElevated(TacticalColors.complete),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TacticalColors.complete.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight,
                  size: 32,
                  color: TacticalColors.complete,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DRONE FLEET',
                      style: TextStyle(
                        color: TacticalColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Zeus Air Operations',
                      style: TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('0', 'AIRBORNE', TacticalColors.operational)),
              Expanded(child: _buildStatItem('0', 'STANDBY', TacticalColors.inProgress)),
              Expanded(child: _buildStatItem('0', 'CHARGING', TacticalColors.complete)),
              Expanded(child: _buildStatItem('0', 'OFFLINE', TacticalColors.textDim)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
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
    );
  }

  Widget _buildActiveMissions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: const Column(
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 48,
            color: TacticalColors.textDim,
          ),
          SizedBox(height: 16),
          Text(
            'No Active Missions',
            style: TacticalText.cardTitle,
          ),
          SizedBox(height: 8),
          Text(
            'All drones are grounded',
            style: TextStyle(color: TacticalColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFleetRoster() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          const Icon(
            Icons.flight,
            size: 48,
            color: TacticalColors.textDim,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Drones Registered',
            style: TacticalText.cardTitle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add drones to your fleet to begin operations',
            style: TextStyle(color: TacticalColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TacticalOutlineButton(
            label: 'REGISTER DRONE',
            icon: Icons.add,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCommands() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCommandCard(
                icon: Icons.flight_takeoff,
                label: 'LAUNCH ALL',
                color: TacticalColors.operational,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCommandCard(
                icon: Icons.flight_land,
                label: 'LAND ALL',
                color: TacticalColors.inProgress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCommandCard(
                icon: Icons.home,
                label: 'RTH',
                subtitle: 'Return to Home',
                color: TacticalColors.complete,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCommandCard(
                icon: Icons.warning,
                label: 'EMERGENCY',
                subtitle: 'Kill All Motors',
                color: TacticalColors.critical,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandCard({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: TacticalDecoration.quickAction(color),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: TacticalColors.textDim,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
