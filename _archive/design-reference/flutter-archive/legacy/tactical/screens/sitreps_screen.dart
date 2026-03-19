import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';
import '../../shared/widgets/tactical/tactical_widgets.dart';
import '../../platform/providers/app_providers.dart';

/// SITREPS Screen - Situation Reports
/// Unified activity feed showing:
/// - System notifications
/// - Agent updates
/// - Integration events
/// - Approval requests
class SitrepsScreen extends ConsumerWidget {
  const SitrepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text(
          'SITREPS',
          style: TacticalText.screenTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: TacticalColors.primary,
            ),
            onPressed: () {
              // TODO: Filter sheet
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TacticalColors.critical,
        onPressed: () => context.push('/sitreps/new'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: activityAsync.when(
        data: (events) => events.isEmpty
            ? _buildEmptyState()
            : _buildSitrepsList(events),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: TacticalColors.primary,
          ),
        ),
        error: (_, __) => _buildEmptyState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TacticalColors.inProgress.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: TacticalColors.inProgress,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No SITREPs',
            style: TacticalText.cardTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'All quiet on the operational front',
            style: TacticalText.cardSubtitle.copyWith(
              color: TacticalColors.textDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSitrepsList(List<dynamic> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildSitrepCard(event);
      },
    );
  }

  Widget _buildSitrepCard(dynamic event) {
    final priority = _getPriority(event);
    final color = _getPriorityColor(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.cardElevated(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: TacticalDecoration.statusDot(color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title ?? 'Unknown Event',
                  style: TacticalText.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TacticalStatusBadge(
                label: priority,
                status: _getStatusFromPriority(priority),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.source ?? 'System',
            style: TacticalText.cardSubtitle,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(event.timestamp),
            style: TacticalText.sectionHeader.copyWith(
              color: TacticalColors.textDim,
            ),
          ),
        ],
      ),
    );
  }

  String _getPriority(dynamic event) {
    // Placeholder logic
    return 'INFO';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return TacticalColors.nonOperational;
      case 'HIGH':
        return TacticalColors.inProgress;
      case 'MEDIUM':
        return TacticalColors.complete;
      default:
        return TacticalColors.textDim;
    }
  }

  String _getStatusFromPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return 'critical';
      case 'HIGH':
        return 'in_progress';
      case 'MEDIUM':
        return 'complete';
      default:
        return 'inactive';
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '--';
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
