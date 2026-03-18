import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Notification type
enum NotificationType {
  system,
  agent,
  approval,
  alert,
  info,
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.info,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.metadata,
  });

  Color get typeColor {
    switch (type) {
      case NotificationType.system:
        return TacticalColors.complete;
      case NotificationType.agent:
        return TacticalColors.primary;
      case NotificationType.approval:
        return TacticalColors.inProgress;
      case NotificationType.alert:
        return TacticalColors.critical;
      case NotificationType.info:
        return TacticalColors.textMuted;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.agent:
        return Icons.smart_toy;
      case NotificationType.approval:
        return Icons.verified_user;
      case NotificationType.alert:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Notifications state
class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

/// Notifications notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  void markAsRead(String id) {
    final notifications = state.notifications.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          timestamp: n.timestamp,
          isRead: true,
          actionRoute: n.actionRoute,
          metadata: n.metadata,
        );
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: notifications);
  }

  void markAllAsRead() {
    final notifications = state.notifications.map((n) {
      return AppNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        timestamp: n.timestamp,
        isRead: true,
        actionRoute: n.actionRoute,
        metadata: n.metadata,
      );
    }).toList();
    state = state.copyWith(notifications: notifications);
  }

  void delete(String id) {
    final notifications = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: notifications);
  }

  void clearAll() {
    state = state.copyWith(notifications: []);
  }
}

/// Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

/// Notifications Screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationType? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final filteredNotifications = _filter == null
        ? state.notifications
        : state.notifications.where((n) => n.type == _filter).toList();

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: Row(
          children: [
            const Text('NOTIFICATIONS', style: TacticalText.cardTitle),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: TacticalColors.textMuted),
            color: TacticalColors.surface,
            onSelected: (value) {
              if (value == 'read_all') {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              } else if (value == 'clear_all') {
                ref.read(notificationsProvider.notifier).clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Text('Mark all as read',
                    style: TextStyle(color: TacticalColors.textPrimary)),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all',
                    style: TextStyle(color: TacticalColors.critical)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Notifications list
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: TacticalColors.primary))
                : filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(filteredNotifications[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('ALL', _filter == null, () => setState(() => _filter = null)),
          const SizedBox(width: 8),
          ...NotificationType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  type.name.toUpperCase(),
                  _filter == type,
                  () => setState(() => _filter = type),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? TacticalColors.primary.withValues(alpha: 0.2)
              : TacticalColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? TacticalColors.primary : TacticalColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? TacticalColors.primary : TacticalColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
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
            Icons.notifications_none,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO NOTIFICATIONS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationsProvider.notifier).delete(notification.id);
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
              color: notification.isRead
                  ? TacticalColors.border
                  : notification.typeColor,
              width: 3,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(notificationsProvider.notifier).markAsRead(notification.id);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notification.typeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notification.typeIcon,
                      color: notification.typeColor,
                      size: 20,
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
                                notification.title,
                                style: TextStyle(
                                  color: TacticalColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              notification.relativeTime,
                              style: const TextStyle(
                                color: TacticalColors.textDim,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
