import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';

/// Calendar Screen — Event Calendar with AI Time-Blocking
/// =======================================================
/// Monthly/weekly/daily calendar view with events, time blocks,
/// conflict detection, and open slot finding.

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _events = [];
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'month'; // month | week | day

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

      final events = await ApiService.listCalendarEvents(
        startDate: start,
        endDate: end,
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.cyan : const Color(0xFF2563EB);
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Icon(Icons.calendar_month, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Text('CALENDAR', style: TacticalText.screenTitle.copyWith(fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        actions: [
          // View mode toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'month', label: Text('M', style: TextStyle(fontSize: 11))),
              ButtonSegment(value: 'week', label: Text('W', style: TextStyle(fontSize: 11))),
              ButtonSegment(value: 'day', label: Text('D', style: TextStyle(fontSize: 11))),
            ],
            selected: {_viewMode},
            onSelectionChanged: (v) => setState(() => _viewMode = v.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor.withValues(alpha: 0.2);
                }
                return Colors.transparent;
              }),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.today, color: textSecondary),
            onPressed: () => setState(() { _selectedDate = DateTime.now(); _loadEvents(); }),
            tooltip: 'Today',
          ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: _showCreateDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildMonthNavigator(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
                          const SizedBox(height: 16),
                          Text(_error!, style: TextStyle(color: textMuted)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadEvents, child: const Text('Retry')),
                        ],
                      ))
                    : _viewMode == 'month' ? _buildMonthView()
                    : _viewMode == 'week' ? _buildWeekView()
                    : _buildDayView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB);
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: textSecondary),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
              });
              _loadEvents();
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: TacticalText.cardTitle.copyWith(fontSize: 16, color: textPrimary),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: textSecondary),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
              });
              _loadEvents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final days = <Widget>[];

    // Day headers
    for (final d in ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']) {
      days.add(Center(
        child: Text(d, style: TacticalText.label.copyWith(fontSize: 10, letterSpacing: 1)),
      ));
    }

    // Empty cells before first day
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final dayEvents = _eventsForDate(date);
      final isToday = _isToday(date);
      final isSelected = date.day == _selectedDate.day;

      days.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? TacticalColors.primary.withValues(alpha: 0.15)
                : isToday
                    ? TacticalColors.cyan.withValues(alpha: 0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: TacticalColors.cyan.withValues(alpha: 0.5))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day',
                  style: TextStyle(
                    color: isToday ? TacticalColors.cyan : TacticalColors.textPrimary,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  )),
              if (dayEvents.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayEvents.take(3).map((e) {
                    return Container(
                      width: 5, height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                      decoration: BoxDecoration(
                        color: _eventColor(e['event_type'] ?? e['type'] ?? ''),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ));
    }

    return Column(
      children: [
        // Calendar grid
        Expanded(
          flex: 3,
          child: GridView.count(
            crossAxisCount: 7,
            padding: const EdgeInsets.all(8),
            children: days,
          ),
        ),
        // Day's events list
        Expanded(
          flex: 2,
          child: _buildDayEventsList(),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final now = _selectedDate;
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (ctx, i) {
        final day = startOfWeek.add(Duration(days: i));
        final dayEvents = _eventsForDate(day);
        final isToday = _isToday(day);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday ? TacticalColors.cyan.withValues(alpha: 0.08) : TacticalColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday ? TacticalColors.cyan.withValues(alpha: 0.3) : TacticalColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, MMM d').format(day),
                  style: TacticalText.cardTitle.copyWith(
                    color: isToday ? TacticalColors.cyan : TacticalColors.textPrimary,
                  )),
              const SizedBox(height: 8),
              if (dayEvents.isEmpty)
                Text('No events', style: TextStyle(color: TacticalColors.textDim, fontSize: 12))
              else
                ...dayEvents.map((e) => _buildEventChip(e)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayView() {
    final dayEvents = _eventsForDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
            style: TacticalText.cardTitle.copyWith(fontSize: 16),
          ),
        ),
        Expanded(
          child: dayEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 48, color: TacticalColors.textDim),
                      const SizedBox(height: 12),
                      Text('No events today', style: TextStyle(color: TacticalColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayEvents.length,
                  itemBuilder: (ctx, i) => _buildEventCard(dayEvents[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildDayEventsList() {
    final dayEvents = _eventsForDate(_selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(top: BorderSide(color: TacticalColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              DateFormat('EEEE, MMM d').format(_selectedDate),
              style: TacticalText.sectionHeader,
            ),
          ),
          Expanded(
            child: dayEvents.isEmpty
                ? Center(child: Text('No events',
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 12)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: dayEvents.map((e) => _buildEventCard(e)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title'] ?? 'Untitled';
    final start = event['start_time'] ?? event['start'] ?? '';
    final end = event['end_time'] ?? event['end'] ?? '';
    final type = event['event_type'] ?? event['type'] ?? 'general';
    final color = _eventColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TacticalText.cardTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                Text(_formatTimeRange(start, end),
                    style: TextStyle(color: TacticalColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: TacticalDecoration.statusBadge(color),
            child: Text(type.toUpperCase(),
                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventChip(Map<String, dynamic> event) {
    final title = event['title'] ?? 'Untitled';
    final type = event['event_type'] ?? event['type'] ?? '';
    final color = _eventColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: Text(title, style: TextStyle(fontSize: 12, color: TacticalColors.textPrimary)),
    );
  }

  List<Map<String, dynamic>> _eventsForDate(DateTime date) {
    return _events.where((e) {
      try {
        final start = DateTime.parse(e['start_time'] ?? e['start'] ?? '');
        return start.year == date.year && start.month == date.month && start.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'meeting': return TacticalColors.info;
      case 'task': case 'time_block': return TacticalColors.warning;
      case 'deadline': return TacticalColors.error;
      case 'reminder': return TacticalColors.cyan;
      default: return TacticalColors.success;
    }
  }

  String _formatTimeRange(String start, String end) {
    try {
      final s = DateTime.parse(start);
      final e = DateTime.parse(end);
      return '${DateFormat('HH:mm').format(s)} - ${DateFormat('HH:mm').format(e)}';
    } catch (_) {
      return '';
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text('New Event', style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace')),
        content: TextField(
          controller: titleCtrl,
          decoration: TacticalDecoration.inputField(label: 'Event Title', hint: 'Team standup'),
          style: TextStyle(color: TacticalColors.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final start = _selectedDate.toIso8601String();
              final end = _selectedDate.add(const Duration(hours: 1)).toIso8601String();
              try {
                await ApiService.createCalendarEvent({
                  'title': titleCtrl.text,
                  'start_time': start,
                  'end_time': end,
                });
                _loadEvents();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create event: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('CREATE', style: TextStyle(color: TacticalColors.primary)),
          ),
        ],
      ),
    );
  }
}
