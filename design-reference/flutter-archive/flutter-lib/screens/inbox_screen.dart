import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_model.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import 'approvals_screen.dart';
import 'universal_chat_screen.dart';

// Consistent color palette
class CommandCenterColors {
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFFF6B00);
  static const error = Color(0xFFE63946);
  static const info = Color(0xFF00D9FF);
}

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  bool _isSystemHealthy = true;

  List<Map<String, dynamic>> _events = [];
  List<PausedRun> _approvals = [];
  List<SessionModel> _sessions = [];
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventsFuture = ApiService.listEvents(limit: 20);
      final approvalsFuture = ApiService.listPausedRuns();
      final sessionsFuture = ApiService.listSessions(agentId: null);
      final tasksFuture = ApiService.listTasks(assigneeId: 'commander', status: 'todo'); // Filter for commander's todo tasks

      final results = await Future.wait([
        eventsFuture,
        approvalsFuture,
        sessionsFuture,
        tasksFuture,
      ]);

      if (mounted) {
        setState(() {
          _events = results[0] as List<Map<String, dynamic>>;
          _approvals = results[1] as List<PausedRun>;
          _sessions = results[2] as List<SessionModel>;
          _tasks = results[3] as List<Map<String, dynamic>>;
          _isLoading = false;
          _isSystemHealthy = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isSystemHealthy = false;
        });
      }
    }
  }

  int get _unreadEventsCount {
    // Count events from the last hour as "unread"
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _events.where((event) {
      try {
        final timestamp = DateTime.parse(event['timestamp'] ?? '');
        return timestamp.isAfter(oneHourAgo);
      } catch (e) {
        return false;
      }
    }).length;
  }

  int get _activeSessionsCount {
    return _sessions.length;
  }

  int get _myTasksCount {
    return _tasks.length;
  }

  IconData _getEventIcon(Map<String, dynamic> event) {
    final source = event['source']?.toString().toLowerCase() ?? '';
    final type = event['type']?.toString().toLowerCase() ?? '';

    if (source.contains('github')) {
      if (type.contains('pr')) return Icons.merge_type;
      if (type.contains('issue')) return Icons.report_problem_outlined;
      if (type.contains('commit')) return Icons.commit;
      return Icons.code;
    } else if (source.contains('clickup')) {
      if (type.contains('task')) return Icons.task_alt;
      return Icons.check_box_outlined;
    } else if (source.contains('calendar')) {
      return Icons.event;
    } else if (source.contains('gmail')) {
      return Icons.email_outlined;
    } else if (source.contains('homeassistant') || source.contains('home')) {
      return Icons.home_outlined;
    } else if (source.contains('system')) {
      return Icons.settings_suggest;
    }

    return Icons.notifications_outlined;
  }

  Color _getEventColor(Map<String, dynamic> event, BuildContext context) {
    final priority = event['priority']?.toString() ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (priority.contains('5') || priority.contains('critical')) {
      return CommandCenterColors.error;
    } else if (priority.contains('4') || priority.contains('urgent')) {
      return CommandCenterColors.warning;
    } else if (priority.contains('3') || priority.contains('high')) {
      return CommandCenterColors.info;
    }

    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  String _getAgentInitials(String? agentName) {
    if (agentName == null || agentName.isEmpty) return '?';
    final words = agentName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return agentName.substring(0, 1).toUpperCase();
  }

  Color _getAgentColor(String? agentName) {
    final colors = [
      CommandCenterColors.info,
      CommandCenterColors.success,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];
    final hash = agentName?.hashCode ?? 0;
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180, // Height for the stats area
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                            theme.colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 60), // Bottom padding for TabBar
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary, size: 32),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Command Center',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (_isSystemHealthy ? CommandCenterColors.success : CommandCenterColors.error).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: (_isSystemHealthy ? CommandCenterColors.success : CommandCenterColors.error).withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8, height: 8,
                                            decoration: BoxDecoration(
                                              color: _isSystemHealthy ? CommandCenterColors.success : CommandCenterColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isSystemHealthy ? 'Online' : 'Offline',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                                      onPressed: _isLoading ? null : _loadData,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (!_isLoading)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(context, 'Pending', _approvals.length.toString(), Icons.pending_actions, CommandCenterColors.warning),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(context, 'Unread', _unreadEventsCount.toString(), Icons.notifications_active, CommandCenterColors.info),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(context, 'My Tasks', _myTasksCount.toString(), Icons.check_box_outlined, const Color(0xFF3B82F6)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(context, 'Active', _activeSessionsCount.toString(), Icons.chat_bubble, CommandCenterColors.success),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: theme.colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timeline, size: 18),
                            const SizedBox(width: 8),
                            const Text('Activity'),
                            if (_unreadEventsCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CommandCenterColors.info,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_unreadEventsCount.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.approval, size: 18),
                            const SizedBox(width: 8),
                            const Text('Approvals'),
                            if (_approvals.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CommandCenterColors.warning,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_approvals.length.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.forum, size: 18), SizedBox(width: 8), Text('Chats')])),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            const Text('Tasks'),
                            if (_myTasksCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_myTasksCount.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: CommandCenterColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connection Error',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _error!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildActivityTab(),
                            _buildApprovalsTab(),
                            _buildChatsTab(),
                            _buildTasksTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UniversalChatScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('New Chat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_events.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.timeline,
        'No Recent Activity',
        'Events will appear here as they occur',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final icon = _getEventIcon(event);
    final color = _getEventColor(event, context);

    final title = event['title']?.toString() ?? event['type']?.toString() ?? 'Event';
    final source = event['source']?.toString() ?? 'Unknown';
    final timestamp = event['timestamp']?.toString() ?? '';

    String timeAgo = 'Unknown time';
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        timeAgo = 'Just now';
      } else if (diff.inHours < 1) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    } catch (e) {
      // Keep default
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Event Details',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('Title', title),
                    _buildDetailRow('Source', source),
                    _buildDetailRow('Type', event['type']?.toString() ?? 'N/A'),
                    _buildDetailRow('Time', timestamp),
                    if (event['description'] != null)
                      _buildDetailRow('Description', event['description'].toString()),
                    if (event['actor'] != null)
                      _buildDetailRow('Actor', event['actor'].toString()),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            source.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsTab() {
    if (_approvals.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.check_circle_outline,
        'No Pending Approvals',
        'Agent approval requests will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _approvals.length,
      itemBuilder: (context, index) {
        final run = _approvals[index];
        return _buildApprovalCard(context, run);
      },
    );
  }

  Widget _buildApprovalCard(BuildContext context, PausedRun run) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: CommandCenterColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CommandCenterColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: CommandCenterColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        run.agentName ?? 'Agent',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Waiting for approval',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                run.message ?? 'No message provided',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // TODO: Handle rejection
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rejection functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CommandCenterColors.error,
                      side: BorderSide(color: CommandCenterColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApprovalsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CommandCenterColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsTab() {
    if (_sessions.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.chat_bubble_outline,
        'No Active Chats',
        'Start a new chat to begin a conversation',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildChatCard(context, session);
      },
    );
  }

  Widget _buildChatCard(BuildContext context, SessionModel session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final agentInitials = _getAgentInitials(session.agentName);
    final agentColor = _getAgentColor(session.agentName);

    final sessionName = session.sessionName.isNotEmpty
      ? session.sessionName
      : 'Session ${session.sessionId.substring(0, 8)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UniversalChatScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      agentColor,
                      agentColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: agentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    agentInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sessionName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          session.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (session.agentName != null) ...[
                      Text(
                        session.agentName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: agentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      session.lastMessage ?? 'No messages yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    if (_tasks.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.check_circle_outline,
        'No Pending Tasks',
        'Tasks assigned to you will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return _buildTaskCard(context, task);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final priority = task['priority']?.toString().toLowerCase() ?? 'medium';
    Color priorityColor;
    if (priority == 'critical') {
      priorityColor = CommandCenterColors.error;
    } else if (priority == 'high') {
      priorityColor = CommandCenterColors.warning;
    } else {
      priorityColor = CommandCenterColors.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: priorityColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['title'] ?? 'Untitled Task',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Assigned to Me',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                // Checkbox simulation
                Container(
                  width: 24, 
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

