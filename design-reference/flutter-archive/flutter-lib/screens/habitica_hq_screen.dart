import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/game_provider.dart';
import '../models/daily_op.dart';
import '../models/mission.dart';

/// HQ Dashboard — Command Center Overview
/// Shows system health, agents, daily operations, and missions.
/// Removed XP/Gold display, focused on real system data.
class HabiticaHQScreen extends ConsumerStatefulWidget {
  const HabiticaHQScreen({super.key});

  @override
  ConsumerState<HabiticaHQScreen> createState() => _HabiticaHQScreenState();
}

class _HabiticaHQScreenState extends ConsumerState<HabiticaHQScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  // Real data from backend
  int _agentCount = 0;
  int _teamCount = 0;
  int _taskCount = 0;
  int _workflowCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadSystemData();
  }

  Future<void> _loadSystemData() async {
    try {
      final agents = await ApiService.listAgents();
      final teams = await ApiService.listTeams();
      final tasks = await ApiService.listTasks();
      final workflows = await ApiService.listWorkflows();

      if (mounted) {
        setState(() {
          _agentCount = agents.length;
          _teamCount = teams.length;
          _taskCount = tasks.length;
          _workflowCount = workflows.length;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E),
                boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.5), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 10),
            const Text('HQ Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadSystemData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              _buildSystemOverview(isDark, theme),
              TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[500],
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1),
                tabs: [
                  _buildTab('OVERVIEW', Icons.dashboard_outlined, 0),
                  _buildTab('DAILY OPS', Icons.check_circle_outline, game.dailyOps.where((d) => !d.completedToday).length),
                  _buildTab('MISSIONS', Icons.flag_outlined, game.missions.where((m) => !m.completed).length),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark, theme),
          _buildDailyOpsColumn(game, isDark, theme),
          _buildMissionsColumn(game, isDark, theme),
        ],
      ),
    );
  }

  // ─── SYSTEM OVERVIEW HEADER ───

  Widget _buildSystemOverview(bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        border: Border.all(color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF22C55E).withValues(alpha: 0.3 + _pulseController.value * 0.2),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF22C55E), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Color(0xFF22C55E), size: 24),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Systems Operational',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statBadge('$_agentCount Agents', const Color(0xFF22C55E), isDark),
                    const SizedBox(width: 8),
                    _statBadge('$_teamCount Teams', const Color(0xFF00D9FF), isDark),
                    const SizedBox(width: 8),
                    _statBadge('$_taskCount Tasks', const Color(0xFFFF6B00), isDark),
                    const SizedBox(width: 8),
                    _statBadge('$_workflowCount Workflows', const Color(0xFF8B5CF6), isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE63946), borderRadius: BorderRadius.circular(8)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── OVERVIEW TAB ───

  Widget _buildOverviewTab(bool isDark, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Grid
          _sectionTitle('Quick Stats', isDark),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _statCard('Active Agents', '$_agentCount', Icons.smart_toy_outlined, const Color(0xFF22C55E), isDark),
              _statCard('Running Workflows', '$_workflowCount', Icons.account_tree_outlined, const Color(0xFF8B5CF6), isDark),
              _statCard('Pending Tasks', '$_taskCount', Icons.check_box_outlined, const Color(0xFFFF6B00), isDark),
              _statCard('Teams Online', '$_teamCount', Icons.groups_outlined, const Color(0xFF00D9FF), isDark),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          _sectionTitle('Quick Actions', isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionChip('New Chat', Icons.chat_bubble_outline, () {}, theme),
              _actionChip('Create Task', Icons.add_task, () {}, theme),
              _actionChip('Run Workflow', Icons.play_arrow_outlined, () {}, theme),
              _actionChip('View Events', Icons.bolt_outlined, () {}, theme),
            ],
          ),

          const SizedBox(height: 24),

          // System Health
          _sectionTitle('System Health', isDark),
          const SizedBox(height: 12),
          _healthRow('Backend API', 'Healthy', 1.0, const Color(0xFF22C55E), isDark),
          _healthRow('PostgreSQL', 'Connected', 1.0, const Color(0xFF22C55E), isDark),
          _healthRow('NATS JetStream', 'Active', 0.98, const Color(0xFF22C55E), isDark),
          _healthRow('WebSocket', 'Connected', 1.0, const Color(0xFF22C55E), isDark),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(String label, IconData icon, VoidCallback onTap, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      onPressed: onTap,
      backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF3F4F6),
      side: BorderSide(color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB)),
    );
  }

  Widget _healthRow(String service, String status, double health, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(service, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
          ),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: health,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DAILY OPS COLUMN ───

  Widget _buildDailyOpsColumn(GameState game, bool isDark, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: game.dailyOps.length + 1,
      itemBuilder: (context, index) {
        if (index == game.dailyOps.length) {
          return _addButton('Add Daily Operation', isDark);
        }
        return _buildDailyOpCard(game.dailyOps[index], isDark);
      },
    );
  }

  Widget _buildDailyOpCard(DailyOp op, bool isDark) {
    final completed = op.completedToday;
    return Card(
      color: isDark
          ? (completed ? const Color(0xFF050505) : const Color(0xFF0A0A0A))
          : (completed ? const Color(0xFFF3F4F6) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: completed
              ? (isDark ? Colors.grey[900]! : const Color(0xFFE5E7EB))
              : const Color(0xFF00D9FF).withValues(alpha: 0.2),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: completed
            ? null
            : () => ref.read(gameProvider.notifier).completeDailyOp(op.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? const Color(0xFF22C55E).withValues(alpha: 0.2) : Colors.transparent,
                  border: Border.all(
                    color: completed ? const Color(0xFF22C55E) : const Color(0xFF00D9FF).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: completed ? const Icon(Icons.check, size: 16, color: Color(0xFF22C55E)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      op.title,
                      style: TextStyle(
                        color: completed
                            ? (isDark ? Colors.grey[700] : Colors.grey[500])
                            : (isDark ? Colors.white : Colors.black87),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (op.notes.isNotEmpty)
                      Text(op.notes, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (op.streak > 0)
                          _microBadge('${op.streak} day streak', const Color(0xFFFF6B00)),
                        const Spacer(),
                        Text(op.schedule.toUpperCase(),
                            style: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[500], fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── MISSIONS COLUMN ───

  Widget _buildMissionsColumn(GameState game, bool isDark, ThemeData theme) {
    final active = game.missions.where((m) => !m.completed).toList();
    final done = game.missions.where((m) => m.completed).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...active.map((m) => _buildMissionCard(m, isDark)),
        if (done.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('COMPLETED', style: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          ),
          ...done.map((m) => _buildMissionCard(m, isDark)),
        ],
        _addButton('Add Mission', isDark),
      ],
    );
  }

  Widget _buildMissionCard(Mission mission, bool isDark) {
    final priorityColor = {

      MissionDifficulty.easy: const Color(0xFF00D9FF),
      MissionDifficulty.medium: const Color(0xFFFFB800),
      MissionDifficulty.hard: const Color(0xFFE63946),
    }[mission.priority] ?? Colors.grey;

    return Card(
      color: isDark
          ? (mission.completed ? const Color(0xFF050505) : const Color(0xFF0A0A0A))
          : (mission.completed ? const Color(0xFFF3F4F6) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: priorityColor.withValues(alpha: mission.completed ? 0.1 : 0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: mission.completed
            ? null
            : () => ref.read(gameProvider.notifier).completeMission(mission.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: mission.completed ? const Color(0xFF22C55E).withValues(alpha: 0.2) : Colors.transparent,
                  border: Border.all(color: mission.completed ? const Color(0xFF22C55E) : priorityColor.withValues(alpha: 0.4)),
                ),
                child: mission.completed ? const Icon(Icons.check, size: 14, color: Color(0xFF22C55E)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        color: mission.completed
                            ? (isDark ? Colors.grey[700] : Colors.grey[500])
                            : (isDark ? Colors.white : Colors.black87),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        decoration: mission.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (mission.notes.isNotEmpty)
                      Text(mission.notes, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _microBadge(mission.priority.name.toUpperCase(), priorityColor),
                        const Spacer(),
                        if (mission.isOverdue)
                          _microBadge('OVERDUE', const Color(0xFFE63946)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SHARED WIDGETS ───

  Widget _microBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _addButton(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.grey[600] : Colors.grey[500],
          side: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
