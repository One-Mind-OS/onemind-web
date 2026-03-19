import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';
import '../../shared/widgets/tactical/tactical_widgets.dart';
import '../../platform/providers/app_providers.dart';

/// MISSIONS Screen - Active Operations
/// Shows all active and recent agent runs, workflow executions,
/// and team operations.
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text(
          'MISSIONS',
          style: TacticalText.screenTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history,
              color: TacticalColors.primary,
            ),
            onPressed: () => context.push('/sessions'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TacticalColors.primary,
        onPressed: () => context.push('/terminal'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: sessionsAsync.when(
        data: (sessions) => sessions.isEmpty
            ? _buildEmptyState(context)
            : _buildMissionsList(context, sessions),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: TacticalColors.primary,
          ),
        ),
        error: (_, __) => _buildEmptyState(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TacticalColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: TacticalColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Missions',
            style: TacticalText.cardTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new operation from Terminal',
            style: TacticalText.cardSubtitle.copyWith(
              color: TacticalColors.textDim,
            ),
          ),
          const SizedBox(height: 24),
          TacticalOutlineButton(
            label: 'OPEN TERMINAL',
            icon: Icons.terminal,
            onTap: () => context.push('/terminal'),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(BuildContext context, List<dynamic> sessions) {
    // Group by status
    final active = sessions.where((s) => _isActive(s)).toList();
    final completed = sessions.where((s) => !_isActive(s)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          const TacticalSectionHeader(title: 'ACTIVE OPERATIONS'),
          ...active.map((s) => _buildMissionCard(context, s, isActive: true)),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          TacticalSectionHeader(
            title: 'COMPLETED',
            actionLabel: 'VIEW ALL',
            onAction: () => context.push('/sessions'),
          ),
          ...completed
              .take(5)
              .map((s) => _buildMissionCard(context, s, isActive: false)),
        ],
        if (active.isEmpty && completed.isEmpty) _buildEmptyState(context),
      ],
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    dynamic session, {
    required bool isActive,
  }) {
    final color =
        isActive ? TacticalColors.inProgress : TacticalColors.operational;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to session/run details
            // context.push('/sessions/${session.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: TacticalDecoration.cardElevated(color),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isActive ? Icons.radar : Icons.check_circle_outline,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.agentId ?? 'Unknown Agent',
                            style: TacticalText.cardTitle,
                          ),
                          Text(
                            _formatSessionId(session.id),
                            style: TacticalText.sectionHeader.copyWith(
                              color: TacticalColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TacticalStatusBadge(
                      label: isActive ? 'ACTIVE' : 'COMPLETE',
                      status: isActive ? 'in_progress' : 'complete',
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          backgroundColor:
                              TacticalColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'In Progress...',
                        style: TacticalText.cardSubtitle.copyWith(
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isActive(dynamic session) {
    // Placeholder logic - check session status
    return false;
  }

  String _formatSessionId(String? id) {
    if (id == null) return 'session-unknown';
    if (id.length > 12) return 'session-${id.substring(0, 8)}...';
    return 'session-$id';
  }
}
