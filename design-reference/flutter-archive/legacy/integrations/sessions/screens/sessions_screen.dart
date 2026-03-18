// Sessions Screen - Tactical Design
// Displays chat session history with tactical UI

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/tactical.dart';
import '../../../platform/providers/app_providers.dart';
import '../../../shared/models/session.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('SESSIONS', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.invalidate(sessionsProvider),
            tooltip: 'Refresh sessions',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Stats header
              _buildStatsHeader(sessions),

              // Sessions list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _SessionCard(
                      session: session,
                      onTap: () => _loadSession(context, ref, session),
                      onRename: () => _showRenameDialog(context, ref, session),
                      onDelete: () => _deleteSession(context, ref, session.sessionId),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: TacticalColors.primary),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildStatsHeader(List<Session> sessions) {
    final totalMessages = sessions.fold<int>(
      0, (sum, s) => sum + s.chatHistory.length);
    final today = DateTime.now();
    final todayCount = sessions.where((s) =>
      s.updatedAt != null &&
      s.updatedAt!.day == today.day &&
      s.updatedAt!.month == today.month &&
      s.updatedAt!.year == today.year
    ).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('TOTAL', sessions.length.toString(), TacticalColors.textMuted),
          _buildStatItem('TODAY', todayCount.toString(), TacticalColors.primary),
          _buildStatItem('MESSAGES', totalMessages.toString(), TacticalColors.operational),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO SESSIONS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting to create your first session',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: TacticalColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.primary),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, color: TacticalColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'START CHATTING',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TacticalColors.critical.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'ERROR LOADING SESSIONS',
            style: TextStyle(
              color: TacticalColors.critical,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TacticalColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ref.invalidate(sessionsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: TacticalColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.primary),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: TacticalColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'RETRY',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadSession(BuildContext context, WidgetRef ref, Session session) {
    ref.read(currentSessionIdProvider.notifier).setSessionId(session.sessionId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded: ${session.sessionName ?? 'Session'}'),
        backgroundColor: TacticalColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    context.go('/');
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Session session,
  ) async {
    final controller = TextEditingController(
      text: session.sessionName ?? '',
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: TacticalColors.border),
        ),
        title: const Text(
          'RENAME SESSION',
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: TacticalColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter session name',
            hintStyle: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: TacticalColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.primary),
            ),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: TacticalColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text(
              'RENAME',
              style: TextStyle(color: TacticalColors.primary),
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName != null && newName.isNotEmpty && context.mounted) {
      try {
        final client = ref.read(sessionClientProvider);
        await client.renameSession(session.sessionId, newName);

        ref.invalidate(sessionsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session renamed'),
              backgroundColor: TacticalColors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error renaming session: $e'),
              backgroundColor: TacticalColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: TacticalColors.border),
        ),
        title: const Text(
          'DELETE SESSION',
          style: TextStyle(
            color: TacticalColors.critical,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this session? This action cannot be undone.',
          style: TextStyle(
            color: TacticalColors.textMuted.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: TacticalColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: TacticalColors.critical),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final client = ref.read(sessionClientProvider);
        await client.deleteSession(sessionId);

        final currentSessionId = ref.read(currentSessionIdProvider);
        if (currentSessionId == sessionId) {
          ref.read(currentSessionIdProvider.notifier).clearSession();
        }

        ref.invalidate(sessionsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted'),
              backgroundColor: TacticalColors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting session: $e'),
              backgroundColor: TacticalColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// =============================================================================
// SESSION CARD
// =============================================================================

class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final messageCount = session.chatHistory.length;
    final lastMsg = session.chatHistory.isNotEmpty
        ? session.chatHistory.last['content']?.toString() ?? ''
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TacticalDecoration.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TacticalColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: TacticalColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.sessionName ??
                            'Session ${session.sessionId.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      if (lastMsg != null && lastMsg.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          lastMsg.length > 80
                              ? '${lastMsg.substring(0, 80)}...'
                              : lastMsg,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.message_outlined,
                            label: '$messageCount messages',
                          ),
                          if (session.updatedAt != null) ...[
                            const SizedBox(width: 12),
                            _InfoChip(
                              icon: Icons.access_time,
                              label: _formatDate(session.updatedAt!),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: TacticalColors.textMuted),
                  color: TacticalColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: TacticalColors.border),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        onRename();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: TacticalColors.textMuted, size: 20),
                          SizedBox(width: 12),
                          Text('Rename', style: TextStyle(color: TacticalColors.textPrimary)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: TacticalColors.critical, size: 20),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: TacticalColors.critical)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

// =============================================================================
// INFO CHIP
// =============================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TacticalColors.textDim),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textDim,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
