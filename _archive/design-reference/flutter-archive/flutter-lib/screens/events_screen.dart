import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/tactical_theme.dart';
import '../services/api_service.dart';

/// Events Dashboard Screen
/// Displays all incoming events from webhooks and sensors
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _stats;

  // Filters
  String? _selectedSource;
  int? _selectedPriority;

  // Bulk selection
  final Set<String> _selectedEventIds = {};
  bool _isMarkingProcessed = false;

  final List<String> _sources = [
    'all',
    'github',
    'clickup',
    'home_assistant',
    'sensor',
    'webhook',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await ApiService.listEvents(
        source: _selectedSource == 'all' ? null : _selectedSource,
        priority: _selectedPriority,
        limit: 100,
      );

      // Try to get stats
      Map<String, dynamic>? stats;
      try {
        stats = await ApiService.getEventStats();
      } catch (_) {
        // Stats endpoint may not be available
      }

      if (mounted) {
        setState(() {
          _events = events;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markSelectedProcessed() async {
    if (_selectedEventIds.isEmpty) return;

    setState(() {
      _isMarkingProcessed = true;
    });

    try {
      await ApiService.markEventsProcessed(_selectedEventIds.toList());

      if (mounted) {
        setState(() {
          _selectedEventIds.clear();
          _isMarkingProcessed = false;
        });

        // Reload events
        _loadEvents();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Events marked as processed'),
            backgroundColor: TacticalColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarkingProcessed = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark events as processed: $e'),
            backgroundColor: TacticalColors.critical,
          ),
        );
      }
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return TacticalColors.critical;
      case 4:
        return TacticalColors.warning;
      case 3:
        return TacticalColors.primary;
      case 2:
        return TacticalColors.info;
      default:
        return TacticalColors.textMuted;
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'github':
        return Icons.code;
      case 'clickup':
        return Icons.check_circle_outline;
      case 'home_assistant':
        return Icons.home;
      case 'sensor':
        return Icons.sensors;
      default:
        return Icons.webhook;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'EVENT STREAM',
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
        actions: [
          // Priority filter
          PopupMenuButton<int?>(
            icon: Icon(Icons.filter_alt, color: primaryColor),
            tooltip: 'Filter by priority',
            onSelected: (priority) {
              setState(() {
                _selectedPriority = priority;
              });
              _loadEvents();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text('All priorities')),
              PopupMenuItem(value: 5, child: Text('P1 - Critical')),
              PopupMenuItem(value: 4, child: Text('P2 - High')),
              PopupMenuItem(value: 3, child: Text('P3 - Normal')),
              PopupMenuItem(value: 2, child: Text('P4 - Low')),
              PopupMenuItem(value: 1, child: Text('P5 - Lowest')),
            ],
          ),
          // Mark as processed button (shown when events are selected)
          if (_selectedEventIds.isNotEmpty)
            IconButton(
              icon: _isMarkingProcessed
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : Icon(Icons.check_circle, color: TacticalColors.success),
              onPressed: _isMarkingProcessed ? null : _markSelectedProcessed,
              tooltip: 'Mark as Processed (${_selectedEventIds.length})',
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadEvents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          if (_stats != null) _buildStatsBar(),

          // Source filter chips
          _buildSourceFilters(),

          // Events list
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      color: surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('Total', _stats!['total']?.toString() ?? '0'),
          if (_stats!['by_priority'] != null) ...[
            _buildStatChip('P1', _stats!['by_priority']['5']?.toString() ?? '0', color: TacticalColors.critical),
            _buildStatChip('P2', _stats!['by_priority']['4']?.toString() ?? '0', color: TacticalColors.warning),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textMuted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final primaryMuted = isDark ? TacticalColors.primaryMuted : const Color(0xFFDEEBFF);
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];
    final borderColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _sources.map((source) {
          final isSelected = source == (_selectedSource ?? 'all');
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(source.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSource = selected ? source : null;
                });
                _loadEvents();
              },
              backgroundColor: surfaceColor,
              selectedColor: primaryMuted,
              labelStyle: TextStyle(
                color: isSelected ? primaryColor : textMuted,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              side: BorderSide(
                color: isSelected ? primaryColor : borderColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: TacticalColors.critical, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: TextStyle(color: textPrimary),
            ),
            Text(
              _error!,
              style: TextStyle(color: textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEvents,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: textMuted, size: 64),
            SizedBox(height: 16),
            Text(
              'No events yet',
              style: TextStyle(color: textPrimary, fontSize: 18),
            ),
            Text(
              'Events will appear here when received from webhooks',
              style: TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final primaryMuted = isDark ? TacticalColors.primaryMuted : const Color(0xFFDEEBFF);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    final priority = event['priority'] as int? ?? 3;
    final source = event['source'] as String? ?? 'unknown';
    final type = event['type'] as String? ?? 'event';
    final title = event['title'] as String? ?? type;
    final timestamp = event['timestamp'] as String?;

    DateTime? time;
    if (timestamp != null) {
      try {
        time = DateTime.parse(timestamp);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: _getPriorityColor(priority),
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryMuted,
          child: Icon(
            _getSourceIcon(source),
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            if (time != null)
              Text(
                DateFormat('MMM d, HH:mm').format(time),
                style: TextStyle(
                  color: textMuted,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox for bulk selection
            Checkbox(
              value: _selectedEventIds.contains(event['id']),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedEventIds.add(event['id'] as String);
                  } else {
                    _selectedEventIds.remove(event['id']);
                  }
                });
              },
              activeColor: primaryColor,
            ),
            SizedBox(width: 8),
            // Priority badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'P$priority',
                style: TextStyle(
                  color: _getPriorityColor(priority),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // Show event details in bottom sheet
          _showEventDetails(event);
        },
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];
    final borderColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                // Header
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  event['title'] ?? event['type'] ?? 'Event',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Source: ${event['source']} | Type: ${event['type']}',
                  style: TextStyle(
                    color: textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: 16),
                Divider(color: borderColor),
                SizedBox(height: 16),
                // Raw payload
                Text(
                  'RAW PAYLOAD',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    event.toString(),
                    style: TextStyle(
                      color: textMuted,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
