import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../services/api_service.dart';

/// Task Board Screen — Kanban-Style Mission Board
/// ================================================
/// Drag-and-drop task board with columns for each status.
/// Connects to /api/tasks/ backend.

class TaskBoardScreen extends ConsumerStatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  ConsumerState<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends ConsumerState<TaskBoardScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _tasks = [];
  List<dynamic> _agents = []; // To store fetched agents
  String _searchQuery = '';

  static const List<String> _columns = ['backlog', 'todo', 'in_progress', 'review', 'done'];
  static const Map<String, String> _columnLabels = {
    'backlog': 'BACKLOG',
    'todo': 'TO DO',
    'in_progress': 'IN PROGRESS',
    'review': 'REVIEW',
    'done': 'DONE',
  };
  static const Map<String, Color> _columnColors = {
    'backlog': Color(0xFF6B7280),
    'todo': Color(0xFF3B82F6),
    'in_progress': Color(0xFFF59E0B),
    'review': Color(0xFF8B5CF6),
    'done': Color(0xFF22C55E),
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await ApiService.listAgents();
      if (mounted) {
        setState(() {
          _agents = agents.map((a) => a.toJson()).toList();
        });
      }
    } catch (e) {
      debugPrint('Failed to load agents: $e');
    }
  }

  Future<void> _loadTasks() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final tasks = await ApiService.listTasks(limit: 100);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await ApiService.updateTask(taskId, {'status': newStatus});
      // Refresh the task list to show updated status
      await _loadTasks();
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: ${e.toString()}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.cyan : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textDim = isDark ? Colors.grey[600] : Colors.grey[500];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Icon(Icons.view_kanban, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Text('MISSION BOARD', style: TacticalText.screenTitle.copyWith(fontSize: 18, color: textPrimary)),
            const SizedBox(width: 12),
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: TacticalDecoration.statusBadge(TacticalColors.info),
                child: Text('${_tasks.length} tasks',
                    style: TextStyle(fontSize: 11, color: TacticalColors.info)),
              ),
          ],
        ),
        actions: [
          SizedBox(
            width: 180,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: textDim, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
                border: InputBorder.none,
              ),
              style: TextStyle(color: textPrimary, fontSize: 13),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: _showCreateDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textSecondary),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildBoard(),
    );
  }

  Widget _buildBoard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _columns.map((col) {
        final colTasks = _tasks.where((t) {
          final status = t['status'] ?? 'backlog';
          if (status != col) return false;
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return (t['title'] ?? '').toString().toLowerCase().contains(q);
          }
          return true;
        }).toList();

        return Expanded(child: _buildColumn(col, colTasks));
      }).toList(),
    );
  }

  Widget _buildColumn(String status, List<Map<String, dynamic>> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final color = _columnColors[status] ?? TacticalColors.inactive;
    final label = _columnLabels[status] ?? status;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label, style: TacticalText.sectionHeader.copyWith(color: color)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${tasks.length}',
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Tasks
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onAcceptWithDetails: (details) {
                final task = details.data;
                final taskId = task['task_id'] ?? task['id'];
                if (taskId != null) _updateTaskStatus(taskId.toString(), status);
              },
              builder: (ctx, candidateData, rejectedData) {
                return Container(
                  color: candidateData.isNotEmpty
                      ? color.withValues(alpha: 0.05)
                      : Colors.transparent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) => _buildTaskCard(tasks[i], color),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, Color columnColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final elevatedColor = isDark ? TacticalColors.elevated : const Color(0xFFF8F9FA);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textDim = isDark ? Colors.grey[600] : Colors.grey[500];

    final title = task['title'] ?? 'Untitled';
    final priority = task['priority'] ?? 'medium';
    final assignee = task['assignee'] ?? '';

    Color priorityColor;
    switch (priority) {
      case 'critical': priorityColor = TacticalColors.error; break;
      case 'high': priorityColor = TacticalColors.warning; break;
      case 'medium': priorityColor = TacticalColors.info; break;
      default: priorityColor = TacticalColors.inactive;
    }

    return Draggable<Map<String, dynamic>>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: elevatedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: columnColor),
          ),
          child: Text(title, style: TacticalText.cardTitle.copyWith(color: textPrimary)),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _taskCardBody(title, priority, priorityColor, assignee, cardColor, textPrimary, textDim),
      ),
      child: _taskCardBody(title, priority, priorityColor, assignee, cardColor, textPrimary, textDim),
    );
  }

  Widget _taskCardBody(String title, String priority, Color priorityColor, String assignee, Color cardColor, Color? textPrimary, Color? textDim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textDim?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TacticalText.cardTitle.copyWith(fontSize: 13, color: textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: TacticalDecoration.statusBadge(priorityColor),
                child: Text(priority.toUpperCase(),
                    style: TextStyle(fontSize: 9, color: priorityColor, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              if (assignee.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: textDim),
                    const SizedBox(width: 4),
                    Text(assignee,
                        style: TextStyle(fontSize: 10, color: textDim)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
          const SizedBox(height: 16),
          Text(_error ?? '', style: TextStyle(color: textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final elevatedColor = isDark ? TacticalColors.elevated : const Color(0xFFF3F4F6);
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    final titleCtrl = TextEditingController();
    String priority = 'medium';
    String? assigneeId; // Selected assignee ID

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('New Mission', style: TextStyle(color: primaryColor, fontFamily: 'monospace')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: TacticalDecoration.inputField(label: 'Title', hint: 'Mission objective'),
              style: TextStyle(color: textPrimary),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setDialogState) => DropdownButtonFormField<String>(
                initialValue: priority,
                dropdownColor: elevatedColor,
                decoration: TacticalDecoration.inputField(label: 'Priority'),
                items: ['low', 'medium', 'high', 'critical'].map((p) =>
                    DropdownMenuItem(value: p, child: Text(p.toUpperCase(),
                        style: TextStyle(color: textPrimary)))).toList(),
                onChanged: (v) => setDialogState(() => priority = v!),
              ),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setDialogState) => DropdownButtonFormField<String>(
                initialValue: assigneeId,
                dropdownColor: elevatedColor,
                decoration: TacticalDecoration.inputField(label: 'Assignee'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned', style: TextStyle(color: Colors.grey))),
                  DropdownMenuItem(value: 'commander', child: Text('Commander (Me)', style: TextStyle(color: textPrimary))),
                  ..._agents.map((a) => DropdownMenuItem(
                    value: a['agent_id'] ?? a['id'], // Handle both structures
                    child: Text(a['name'] ?? 'Agent', style: TextStyle(color: textPrimary)),
                  )),
                ],
                onChanged: (v) => setDialogState(() => assigneeId = v),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ApiService.createTask({
                  'title': titleCtrl.text,
                  'priority': priority,
                  'status': 'todo',
                  'assignee': _getAssigneeName(assigneeId),
                  'assignee_id': assigneeId,
                });
                await _loadTasks();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task created successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create task: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('CREATE', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
  String _getAssigneeName(String? id) {
    if (id == null) return '';
    if (id == 'commander') return 'Commander';
    final agent = _agents.firstWhere((a) => (a['agent_id'] ?? a['id']) == id, orElse: () => {});
    return agent['name'] ?? 'Unknown';
  }
}
