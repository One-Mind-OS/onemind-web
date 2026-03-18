import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';

/// Activity Feed Screen — Unified Activity Stream
/// ================================================
/// Real-time feed of all system activities (agent actions, user events,
/// system events, deployments, etc.)

class ActivityFeedScreen extends ConsumerStatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  ConsumerState<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends ConsumerState<ActivityFeedScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _activities = [];
  String _filterActor = 'all';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadActivities());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await ApiService.listActivityFeed(limit: 100);
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        title: Row(
          children: [
            Icon(Icons.timeline, color: TacticalColors.cyan, size: 22),
            const SizedBox(width: 10),
            Text('ACTIVITY', style: TacticalText.screenTitle.copyWith(fontSize: 18)),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !_isLoading
                  ? Container(
                      key: ValueKey(_activities.length),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: TacticalDecoration.statusBadge(TacticalColors.success),
                      child: Text('${_activities.length} events',
                          style: TextStyle(fontSize: 11, color: TacticalColors.success)),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        actions: [
          // Actor filter
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: TacticalColors.input,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TacticalColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterActor,
                dropdownColor: TacticalColors.elevated,
                style: TextStyle(color: TacticalColors.textSecondary, fontSize: 12),
                items: ['all', 'system', 'agent', 'user'].map((a) =>
                    DropdownMenuItem(value: a, child: Text(a.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => _filterActor = v!),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.textSecondary),
            onPressed: _loadActivities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: TacticalColors.textMuted)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadActivities, child: const Text('Retry')),
                  ],
                ))
              : _buildFeed(),
    );
  }

  Widget _buildFeed() {
    final filtered = _filterActor == 'all'
        ? _activities
        : _activities.where((a) => (a['actor_type'] ?? a['actor'] ?? '') == _filterActor).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: TacticalColors.textDim),
            const SizedBox(height: 16),
            Text('No activity yet', style: TextStyle(color: TacticalColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Actions from agents, users, and the system appear here',
                style: TextStyle(color: TacticalColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildActivityItem(filtered[i], i == 0),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isFirst) {
    final actor = activity['actor'] ?? activity['actor_id'] ?? 'system';
    final action = activity['action'] ?? 'unknown';
    final entity = activity['entity_type'] ?? '';
    final entityId = activity['entity_id'] ?? '';
    final timestamp = activity['timestamp'] ?? activity['created_at'] ?? '';
    final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

    final iconData = _actionIcon(action);
    final color = _actionColor(action);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(iconData, size: 14, color: color),
                ),
                if (!isFirst || true)
                  Container(
                    width: 2, height: 40,
                    color: TacticalColors.border,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: TacticalDecoration.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(actor, style: TextStyle(
                        color: TacticalColors.cyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
                      const SizedBox(width: 6),
                      Text(action, style: TextStyle(
                        color: TacticalColors.textSecondary,
                        fontSize: 13,
                      )),
                      if (entity.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: TacticalDecoration.statusBadge(color),
                          child: Text(entity.toUpperCase(),
                              style: TextStyle(fontSize: 9, color: color)),
                        ),
                      ],
                    ],
                  ),
                  if (entityId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(entityId, style: TextStyle(
                      color: TacticalColors.textDim,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    )),
                  ],
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: metadata.entries.take(3).map((e) =>
                          Text('${e.key}: ${e.value}',
                              style: TextStyle(fontSize: 10, color: TacticalColors.textMuted))
                      ).toList(),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(_formatTimestamp(timestamp),
                      style: TextStyle(fontSize: 10, color: TacticalColors.textDim)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _actionIcon(String action) {
    if (action.contains('create')) return Icons.add_circle_outline;
    if (action.contains('update') || action.contains('edit')) return Icons.edit_outlined;
    if (action.contains('delete') || action.contains('remove')) return Icons.delete_outline;
    if (action.contains('deploy')) return Icons.rocket_launch;
    if (action.contains('run') || action.contains('execute')) return Icons.play_arrow;
    if (action.contains('complete') || action.contains('done')) return Icons.check_circle_outline;
    if (action.contains('error') || action.contains('fail')) return Icons.error_outline;
    return Icons.radio_button_unchecked;
  }

  Color _actionColor(String action) {
    if (action.contains('create') || action.contains('add')) return TacticalColors.success;
    if (action.contains('update') || action.contains('edit')) return TacticalColors.info;
    if (action.contains('delete') || action.contains('remove')) return TacticalColors.error;
    if (action.contains('deploy') || action.contains('run')) return TacticalColors.cyan;
    if (action.contains('complete')) return TacticalColors.success;
    if (action.contains('error') || action.contains('fail')) return TacticalColors.error;
    return TacticalColors.inactive;
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts);
      final now = DateTime.now().toUtc();
      final diff = now.difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM d, HH:mm').format(dt);
    } catch (_) {
      return ts;
    }
  }
}
