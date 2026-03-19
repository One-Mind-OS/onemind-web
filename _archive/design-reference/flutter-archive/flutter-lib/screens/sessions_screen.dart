import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/session_model.dart';
import '../providers/api_providers.dart';
import 'run_details_screen.dart';
import 'approvals_screen.dart';

/// Sessions management screen - List, filter, and delete sessions
class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  String _searchQuery = '';
  String _sortBy = 'date'; // date

  List<SessionModel> _filterAndSortSessions(List<SessionModel> sessions) {
    var filtered = sessions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((session) {
        return session.sessionName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            session.sessionId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      if (_sortBy == 'date') {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate); // Descending
      }
      return 0;
    });

    return filtered;
  }

  Future<void> _deleteSession(String sessionId, String sessionName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Session',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete session "$sessionName"?',
          style: TextStyle(
            color: TacticalColors.primary.withValues(alpha: 0.7),
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(sessionMutationsProvider).deleteSession(sessionId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session deleted successfully'),
              backgroundColor: TacticalColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'SESSIONS & APPROVALS',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: TacticalColors.primary,
            labelColor: TacticalColors.primary,
            unselectedLabelColor: TacticalColors.primary.withValues(alpha: 0.4),
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'SESSIONS'),
              Tab(text: 'APPROVALS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSessionsTab(sessionsAsync),
            const ApprovalsScreen(embedded: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab(AsyncValue<List<SessionModel>> sessionsAsync) {
    return Column(
      children: [
        // Filter and search bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            border: Border(
              bottom: BorderSide(
                color: TacticalColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: TacticalColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: TacticalColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: TacticalColors.primary,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search sessions...',
                          hintStyle: TextStyle(
                            color: TacticalColors.primary.withValues(alpha: 0.4),
                            fontFamily: 'monospace',
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            color: TacticalColors.primary.withValues(alpha: 0.5),
                            size: 18,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Sort dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: TacticalColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TacticalColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        dropdownColor: TacticalColors.surface,
                        icon: Icon(
                          Icons.sort,
                          color: TacticalColors.primary.withValues(alpha: 0.7),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'date',
                            child: Text(
                              'Sort by Date',
                              style: TextStyle(
                                color: TacticalColors.primary,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'message_count',
                            child: Text(
                              'Sort by Messages',
                              style: TextStyle(
                                color: TacticalColors.primary,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Sessions list
        Expanded(
          child: sessionsAsync.when(
            data: (sessions) {
              final filteredSessions = _filterAndSortSessions(sessions);
              if (filteredSessions.isEmpty) {
                return Center(
                  child: Text(
                    sessions.isEmpty
                        ? 'No sessions recorded'
                        : 'No sessions found matching filters',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.5),
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSessions.length,
                itemBuilder: (context, index) {
                  return _SessionCard(
                    session: filteredSessions[index],
                    onDelete: _deleteSession,
                  );
                },
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.withValues(alpha: 0.7),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load sessions',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(sessionsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.primary,
                      foregroundColor: TacticalColors.background,
                    ),
                    child: Text('RETRY'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Session card component
class _SessionCard extends StatefulWidget {
  final SessionModel session;
  final Function(String, String) onDelete;

  const _SessionCard({required this.session, required this.onDelete});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TacticalColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? TacticalColors.primary.withValues(alpha: 0.5)
                : TacticalColors.primary.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: TacticalColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Content
            InkWell(
              onTap: () {
                setState(() => _isExpanded = !_isExpanded);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Session name
                              Text(
                                widget.session.sessionName,
                                style: TextStyle(
                                  color: TacticalColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              SizedBox(height: 4),
                              // Session ID (truncated)
                              Text(
                                'ID: ${widget.session.sessionId.length > 16 ? '${widget.session.sessionId.substring(0, 16)}...' : widget.session.sessionId}',
                                style: TextStyle(
                                  color: TacticalColors.primary.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Stats
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: TacticalColors.primary.withValues(alpha: 0.5),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  widget.session.timeAgo,
                                  style: TextStyle(
                                    color: TacticalColors.primary.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.session.durationString,
                              style: TextStyle(
                                color: TacticalColors.primary.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Session state info (if available)
                    if (widget.session.sessionState != null && widget.session.sessionState!.isNotEmpty)
                      Text(
                        'State: ${widget.session.sessionState!.keys.length} properties',
                      style: TextStyle(
                        color: TacticalColors.primary.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),

                    if (_isExpanded) ...[
                      SizedBox(height: 12),
                      Divider(
                        color: TacticalColors.primary.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: 8),
                      // Additional details when expanded
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: TacticalColors.primary.withValues(alpha: 0.5),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Duration: ${widget.session.durationString}',
                            style: TextStyle(
                              color: TacticalColors.primary.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons (visible on hover)
            if (_isHovered)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _IconButton(
                      icon: Icons.info_outline,
                      tooltip: 'View Details',
                      onTap: () {
                        // Navigate to run details screen
                        // For now, using a mock agent ID - in production, get from session
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RunDetailsScreen(
                              agentId: 'assistant', // TODO: Get from session
                              runId: widget.session.sessionId,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: () {
                        widget.onDelete(widget.session.sessionId, widget.session.sessionName);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small icon button for session card actions
class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? TacticalColors.error : TacticalColors.primary;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
