import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Activity item type
enum ActivityType {
  message,
  notification,
  event,
  approval,
  task,
  alert,
  reminder,
  suggestion,
}

/// Activity priority
enum ActivityPriority {
  low,
  normal,
  high,
  urgent,
}

/// Activity item model
class ActivityItem {
  final String id;
  final ActivityType type;
  final ActivityPriority priority;
  final String title;
  final String? body;
  final String source;
  final DateTime timestamp;
  final bool isRead;
  final bool isStarred;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;

  const ActivityItem({
    required this.id,
    required this.type,
    this.priority = ActivityPriority.normal,
    required this.title,
    this.body,
    required this.source,
    required this.timestamp,
    this.isRead = false,
    this.isStarred = false,
    this.actionRoute,
    this.metadata,
  });

  Color get typeColor {
    switch (type) {
      case ActivityType.message:
        return TacticalColors.complete;
      case ActivityType.notification:
        return TacticalColors.textMuted;
      case ActivityType.event:
        return TacticalColors.inProgress;
      case ActivityType.approval:
        return TacticalColors.primary;
      case ActivityType.task:
        return TacticalColors.operational;
      case ActivityType.alert:
        return TacticalColors.critical;
      case ActivityType.reminder:
        return TacticalColors.complete;
      case ActivityType.suggestion:
        return TacticalColors.primary;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ActivityType.message:
        return Icons.chat_bubble_outline;
      case ActivityType.notification:
        return Icons.notifications_none;
      case ActivityType.event:
        return Icons.event;
      case ActivityType.approval:
        return Icons.verified_user;
      case ActivityType.task:
        return Icons.task_alt;
      case ActivityType.alert:
        return Icons.warning_amber;
      case ActivityType.reminder:
        return Icons.alarm;
      case ActivityType.suggestion:
        return Icons.lightbulb_outline;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case ActivityPriority.urgent:
        return TacticalColors.critical;
      case ActivityPriority.high:
        return TacticalColors.inProgress;
      case ActivityPriority.normal:
        return TacticalColors.textMuted;
      case ActivityPriority.low:
        return TacticalColors.textDim;
    }
  }

  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

/// Activity state
class ActivityState {
  final List<ActivityItem> items;
  final bool isLoading;
  final String? error;
  final ActivityType? filter;

  const ActivityState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.filter,
  });

  ActivityState copyWith({
    List<ActivityItem>? items,
    bool? isLoading,
    String? error,
    ActivityType? filter,
    bool clearFilter = false,
  }) {
    return ActivityState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }

  List<ActivityItem> get filteredItems {
    if (filter == null) return items;
    return items.where((i) => i.type == filter).toList();
  }

  int get unreadCount => items.where((i) => !i.isRead).length;
  int get starredCount => items.where((i) => i.isStarred).length;

  Map<ActivityType, int> get itemsByType {
    final map = <ActivityType, int>{};
    for (final item in items) {
      map[item.type] = (map[item.type] ?? 0) + 1;
    }
    return map;
  }
}

/// Activity notifier
class ActivityNotifier extends StateNotifier<ActivityState> {
  ActivityNotifier() : super(const ActivityState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Connect to backend activity API
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  void setFilter(ActivityType? type) {
    if (type == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filter: type);
    }
  }

  void markAsRead(String id) {
    final items = state.items.map((i) {
      if (i.id == id) {
        return ActivityItem(
          id: i.id,
          type: i.type,
          priority: i.priority,
          title: i.title,
          body: i.body,
          source: i.source,
          timestamp: i.timestamp,
          isRead: true,
          isStarred: i.isStarred,
          actionRoute: i.actionRoute,
          metadata: i.metadata,
        );
      }
      return i;
    }).toList();
    state = state.copyWith(items: items);
  }

  void toggleStar(String id) {
    final items = state.items.map((i) {
      if (i.id == id) {
        return ActivityItem(
          id: i.id,
          type: i.type,
          priority: i.priority,
          title: i.title,
          body: i.body,
          source: i.source,
          timestamp: i.timestamp,
          isRead: i.isRead,
          isStarred: !i.isStarred,
          actionRoute: i.actionRoute,
          metadata: i.metadata,
        );
      }
      return i;
    }).toList();
    state = state.copyWith(items: items);
  }

  void delete(String id) {
    final items = state.items.where((i) => i.id != id).toList();
    state = state.copyWith(items: items);
  }
}

/// Provider
final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier();
});

/// Activity Screen - Unified Inbox
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activityProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: Row(
          children: [
            const Text('ACTIVITY', style: TacticalText.cardTitle),
            if (state.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TacticalColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.unreadCount.toString(),
                  style: const TextStyle(
                    color: TacticalColors.background,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(activityProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          _buildStatsRow(state),

          // Type filter
          _buildTypeFilter(state),

          // Activity list
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: TacticalColors.primary))
                : state.filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildActivityCard(state.filteredItems[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ActivityState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('TOTAL', state.items.length, TacticalColors.textMuted),
          _buildStat('UNREAD', state.unreadCount, TacticalColors.primary),
          _buildStat('STARRED', state.starredCount, TacticalColors.inProgress),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

  Widget _buildTypeFilter(ActivityState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('ALL', state.filter == null,
              () => ref.read(activityProvider.notifier).setFilter(null)),
          const SizedBox(width: 8),
          ...ActivityType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  type.name.toUpperCase(),
                  state.filter == type,
                  () => ref.read(activityProvider.notifier).setFilter(type),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? TacticalColors.primary.withValues(alpha: 0.2)
              : TacticalColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? TacticalColors.primary : TacticalColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? TacticalColors.primary : TacticalColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO ACTIVITY',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activity from agents, events, and approvals will appear here',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(activityProvider.notifier).delete(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: TacticalColors.critical.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: TacticalColors.critical),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TacticalColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: item.isRead ? TacticalColors.border : item.typeColor,
              width: 3,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(activityProvider.notifier).markAsRead(item.id);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: item.typeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(item.typeIcon, color: item.typeColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: TacticalColors.textPrimary,
                                fontSize: 14,
                                fontWeight: item.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.source,
                              style: const TextStyle(
                                color: TacticalColors.textDim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.relativeTime,
                            style: const TextStyle(
                              color: TacticalColors.textDim,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => ref
                                .read(activityProvider.notifier)
                                .toggleStar(item.id),
                            child: Icon(
                              item.isStarred ? Icons.star : Icons.star_border,
                              color: item.isStarred
                                  ? TacticalColors.inProgress
                                  : TacticalColors.textDim,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Body
                  if (item.body != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.body!,
                      style: const TextStyle(
                        color: TacticalColors.textMuted,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Priority indicator
                  if (item.priority != ActivityPriority.normal) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.priority.name.toUpperCase(),
                        style: TextStyle(
                          color: item.priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
