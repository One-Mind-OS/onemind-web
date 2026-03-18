import 'package:flutter/material.dart';
import '../../../shared/theme/tactical.dart';
import '../../shared/animations/micro_interactions.dart';

/// Mobile-optimized approval card
class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onViewDetails;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(item.priority).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getTypeColor(item.type).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(item.type),
                    size: 22,
                    color: _getTypeColor(item.type),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _PriorityBadge(priority: item.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: TacticalColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 14,
                            color: TacticalColors.textDim,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.agentName ?? 'System',
                            style: TextStyle(
                              color: TacticalColors.textDim,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: TacticalColors.textDim,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(item.createdAt),
                            style: TextStyle(
                              color: TacticalColors.textDim,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Context/Details (if any)
          if (item.context != null) ...[
            const Divider(height: 1, color: TacticalColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.context!,
                style: TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Actions
          const Divider(height: 1, color: TacticalColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // View details
                if (onViewDetails != null)
                  BounceTap(
                    onTap: onViewDetails,
                    hapticType: TacticalHaptic.light,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: TacticalColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TacticalColors.border),
                      ),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          color: TacticalColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                const Spacer(),

                // Reject button
                BounceTap(
                  onTap: onReject,
                  hapticType: TacticalHaptic.medium,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TacticalColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TacticalColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 16,
                          color: TacticalColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reject',
                          style: TextStyle(
                            color: TacticalColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Approve button
                BounceTap(
                  onTap: onApprove,
                  hapticType: TacticalHaptic.success,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TacticalColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TacticalColors.success.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: TacticalColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Approve',
                          style: TextStyle(
                            color: TacticalColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    return switch (type.toLowerCase()) {
      'agent' || 'agent_action' => Colors.purple,
      'workflow' => Colors.blue,
      'transaction' || 'financial' => Colors.green,
      'system' || 'config' => TacticalColors.warning,
      'destructive' || 'delete' => TacticalColors.primary,
      _ => TacticalColors.textSecondary,
    };
  }

  IconData _getTypeIcon(String type) {
    return switch (type.toLowerCase()) {
      'agent' || 'agent_action' => Icons.smart_toy,
      'workflow' => Icons.account_tree,
      'transaction' || 'financial' => Icons.attach_money,
      'system' || 'config' => Icons.settings,
      'destructive' || 'delete' => Icons.delete_outline,
      _ => Icons.approval,
    };
  }

  Color _getPriorityColor(String priority) {
    return switch (priority.toLowerCase()) {
      'critical' || 'urgent' => TacticalColors.primary,
      'high' => TacticalColors.orange,
      'medium' => TacticalColors.warning,
      _ => TacticalColors.textDim,
    };
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.month}/${time.day}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority.toLowerCase()) {
      'critical' || 'urgent' => TacticalColors.primary,
      'high' => TacticalColors.orange,
      'medium' => TacticalColors.warning,
      _ => TacticalColors.textDim,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Approval item model
class ApprovalItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;
  final String? agentName;
  final String? context;
  final DateTime? createdAt;

  const ApprovalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.priority = 'medium',
    this.agentName,
    this.context,
    this.createdAt,
  });

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Approval Required',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'agent',
      priority: json['priority'] as String? ?? 'medium',
      agentName: json['agent_name'] as String?,
      context: json['context'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

/// Swipeable approval card
class SwipeableApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onViewDetails;

  const SwipeableApprovalCard({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: _buildSwipeBackground(
        color: TacticalColors.success,
        icon: Icons.check,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: TacticalColors.primary,
        icon: Icons.close,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onApprove();
        } else {
          onReject();
        }
        return false; // Don't actually dismiss, let parent handle removal
      },
      child: ApprovalCard(
        item: item,
        onApprove: onApprove,
        onReject: onReject,
        onViewDetails: onViewDetails,
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
      ),
    );
  }
}
