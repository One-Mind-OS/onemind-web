import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Robotics Screen - Robotic Workforce Management
/// Control and coordinate robotic units
class RoboticsScreen extends ConsumerWidget {
  const RoboticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('ROBOTICS', style: TacticalText.screenTitle),
        actions: [
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
            // Fleet Overview
            _buildFleetOverview(),
            const SizedBox(height: 24),

            // Active Units
            const TacticalSectionHeader(title: 'ACTIVE UNITS'),
            const SizedBox(height: 12),
            _buildUnitsList(),

            const SizedBox(height: 24),

            // Quick Actions
            const TacticalSectionHeader(title: 'FLEET COMMANDS'),
            const SizedBox(height: 12),
            _buildFleetCommands(),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.cardElevated(TacticalColors.primary),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TacticalColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.precision_manufacturing,
                  size: 32,
                  color: TacticalColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROBOTIC FLEET',
                      style: TextStyle(
                        color: TacticalColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Zeus Operations',
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
              Expanded(child: _buildStatItem('0', 'ACTIVE', TacticalColors.operational)),
              Expanded(child: _buildStatItem('0', 'IDLE', TacticalColors.inProgress)),
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
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Icon(
            Icons.precision_manufacturing,
            size: 48,
            color: TacticalColors.textDim,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Robotic Units',
            style: TacticalText.cardTitle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add robotic units to manage your workforce',
            style: TextStyle(color: TacticalColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TacticalOutlineButton(
            label: 'ADD UNIT',
            icon: Icons.add,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFleetCommands() {
    return Row(
      children: [
        Expanded(
          child: _buildCommandCard(
            icon: Icons.play_arrow,
            label: 'DEPLOY ALL',
            color: TacticalColors.operational,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCommandCard(
            icon: Icons.pause,
            label: 'HALT ALL',
            color: TacticalColors.inProgress,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCommandCard(
            icon: Icons.home,
            label: 'RECALL',
            color: TacticalColors.complete,
          ),
        ),
      ],
    );
  }

  Widget _buildCommandCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: TacticalDecoration.quickAction(color),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
