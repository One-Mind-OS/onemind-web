import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../services/api_service.dart';
import '../models/agent_model.dart';
import '../models/unified_entity.dart';

/// Unified Entity Roster — All humans, agents, machines, sensors
/// Shows both backend agents/teams AND game entities for a unified view.
class EntityRosterScreen extends ConsumerStatefulWidget {
  const EntityRosterScreen({super.key});

  @override
  ConsumerState<EntityRosterScreen> createState() => _EntityRosterScreenState();
}

class _EntityRosterScreenState extends ConsumerState<EntityRosterScreen> {
  EntityType? _filterType;
  String _sortBy = 'name';
  String? _selectedId;

  // Real data from backend
  List<AgentModel> _realAgents = [];

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    try {
      final agents = await ApiService.listAgents();
      if (mounted) {
        setState(() {
          _realAgents = agents;
        });
      }
    } catch (_) {
      // Error handled silently or via another mechanism
    }
  }

  // Convert real agents to UnifiedEntity format
  List<UnifiedEntity> _buildAllEntities(GameState game) {
    final List<UnifiedEntity> all = [];

    // Add real backend agents
    for (final agent in _realAgents) {
      all.add(UnifiedEntity(
        id: 'real_${agent.agentId}',
        name: agent.name,
        type: EntityType.agent,
        status: EntityStatus.active,
        health: 100,
        level: 1,
        xp: 0,
        role: agent.description ?? 'AI Agent',
        skills: [],
        activeTools: agent.tools,
        protocols: ['API', 'SSE'],
        tasksCompleted: 0,
        tasksFailed: 0,
        uptime: 99.9,
        stats: {'str': 5, 'int': 9, 'end': 8, 'spd': 9},
      ));
    }

    // Add game entities (mock data for visualization)
    all.addAll(game.entities);

    return all;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    var entities = _buildAllEntities(game);

    // Filter
    if (_filterType != null) {
      entities = entities.where((e) => e.type == _filterType).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'health':
        entities.sort((a, b) => b.health.compareTo(a.health));
        break;
      case 'tasks':
        entities.sort((a, b) => b.tasksCompleted.compareTo(a.tasksCompleted));
        break;
      case 'level':
        entities.sort((a, b) => b.level.compareTo(a.level));
        break;
      default:
        entities.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Entity Roster', style: TextStyle(fontWeight: FontWeight.w700)),
            if (_realAgents.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_realAgents.length} live',
                  style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.grey : Colors.grey[600], size: 20),
            onPressed: _loadRealData,
          ),
          _sortButton(isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          _buildSummaryBar(game),
          // Filter chips
          _buildFilterRow(game),
          // Entity list/grid
          Expanded(
            child: _selectedId != null
                ? _buildSplitView(entities, game)
                : _buildEntityGrid(entities),
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY BAR ───

  Widget _buildSummaryBar(GameState game) {
    final humans = game.entities.where((e) => e.type == EntityType.human).length;
    final agents = game.entities.where((e) => e.type == EntityType.agent).length;
    final machines = game.entities.where((e) => e.type == EntityType.machine).length;
    final sensors = game.entities.where((e) => e.type == EntityType.sensor).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF050505),
      child: Row(
        children: [
          _summaryDot('👤 $humans', const Color(0xFF00D9FF)),
          const SizedBox(width: 12),
          _summaryDot('🤖 $agents', const Color(0xFF22C55E)),
          const SizedBox(width: 12),
          _summaryDot('⚙️ $machines', const Color(0xFFFF6B00)),
          const SizedBox(width: 12),
          _summaryDot('💓 $sensors', const Color(0xFF8B5CF6)),
          const Spacer(),
          Text('${game.activeEntities.length} ACTIVE', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _summaryDot(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  // ─── FILTER ROW ───

  Widget _buildFilterRow(GameState game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('ALL', null),
            _filterChip('HUMAN', EntityType.human, const Color(0xFF00D9FF)),
            _filterChip('AGENT', EntityType.agent, const Color(0xFF22C55E)),
            _filterChip('MACHINE', EntityType.machine, const Color(0xFFFF6B00)),
            _filterChip('SENSOR', EntityType.sensor, const Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, EntityType? type, [Color? color]) {
    final selected = _filterType == type;
    final c = color ?? const Color(0xFF00D9FF);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(
          color: selected ? Colors.black : c,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1,
        )),
        selected: selected,
        onSelected: (_) => setState(() => _filterType = selected ? null : type),
        backgroundColor: Colors.transparent,
        selectedColor: c,
        side: BorderSide(color: c.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _sortButton(bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: isDark ? Colors.grey : Colors.grey[600]),
      color: isDark ? const Color(0xFF111111) : Colors.white,
      onSelected: (val) => setState(() => _sortBy = val),
      itemBuilder: (_) => [
        _sortItem('name', 'Name', isDark),
        _sortItem('health', 'Health', isDark),
        _sortItem('tasks', 'Tasks Completed', isDark),
        _sortItem('level', 'Level', isDark),
      ],
    );
  }

  PopupMenuItem<String> _sortItem(String value, String label, bool isDark) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            const Icon(Icons.check, size: 14, color: Color(0xFF00D9FF))
          else
            const SizedBox(width: 14),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 12)),
        ],
      ),
    );
  }

  // ─── ENTITY GRID ───

  Widget _buildEntityGrid(List<UnifiedEntity> entities) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: entities.length,
          itemBuilder: (context, index) => _buildEntityCard(entities[index]),
        );
      },
    );
  }

  // ─── SPLIT VIEW (selection) ───

  Widget _buildSplitView(List<UnifiedEntity> entities, GameState game) {
    final entity = entities.firstWhere((e) => e.id == _selectedId, orElse: () => entities.first);
    return Row(
      children: [
        // List
        SizedBox(
          width: 280,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: entities.length,
            itemBuilder: (context, index) => _buildEntityListTile(entities[index]),
          ),
        ),
        Container(width: 1, color: Colors.grey[900]),
        // Detail
        Expanded(child: _buildEntityDetail(entity)),
      ],
    );
  }

  Widget _buildEntityListTile(UnifiedEntity e) {
    final selected = e.id == _selectedId;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected ? e.typeColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: selected ? Border.all(color: e.typeColor.withValues(alpha: 0.3)) : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Text(e.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(e.name, style: TextStyle(color: selected ? Colors.white : Colors.grey[400], fontWeight: FontWeight.w700, fontSize: 12)),
        subtitle: Row(
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: e.statusColor),
            ),
            const SizedBox(width: 4),
            Text(e.typeLabel, style: TextStyle(color: e.typeColor, fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
        trailing: _miniHealthBar(e),
        onTap: () => setState(() => _selectedId = e.id),
      ),
    );
  }

  // ─── ENTITY CARD ───

  Widget _buildEntityCard(UnifiedEntity e) {
    return GestureDetector(
      onTap: () => setState(() => _selectedId = e.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: e.typeColor.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(e.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: e.typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(e.typeLabel, style: TextStyle(color: e.typeColor, fontSize: 8, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: e.statusColor),
                          ),
                          const SizedBox(width: 3),
                          Text(e.status.name.toUpperCase(), style: TextStyle(color: e.statusColor, fontSize: 8, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Level badge
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: e.typeColor, width: 2),
                  ),
                  child: Center(
                    child: Text('${e.level}', style: TextStyle(color: e.typeColor, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Health bar
            Row(
              children: [
                const Text('HP', style: TextStyle(color: Color(0xFFE63946), fontSize: 8, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE63946).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3))),
                      FractionallySizedBox(
                        widthFactor: (e.health / 100).clamp(0, 1),
                        child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE63946), borderRadius: BorderRadius.circular(3))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text('${e.health.toInt()}%', style: const TextStyle(color: Color(0xFFE63946), fontSize: 9, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            // Stats row
            Row(
              children: [
                _microStat('⚡ ${e.skills.length}', 'skills'),
                _microStat('🔧 ${e.activeTools.length}', 'tools'),
                _microStat('✅ ${e.tasksCompleted}', 'tasks'),
                Text('${e.uptime.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[600], fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _microStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _miniHealthBar(UnifiedEntity e) {
    return SizedBox(
      width: 40, height: 6,
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(color: const Color(0xFFE63946).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3))),
          FractionallySizedBox(
            widthFactor: (e.health / 100).clamp(0, 1),
            child: Container(decoration: BoxDecoration(color: const Color(0xFFE63946), borderRadius: BorderRadius.circular(3))),
          ),
        ],
      ),
    );
  }

  // ─── ENTITY DETAIL ───

  Widget _buildEntityDetail(UnifiedEntity e) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => setState(() => _selectedId = null),
              ),
            ],
          ),
          // Identity
          Center(
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.typeColor.withValues(alpha: 0.15),
                    border: Border.all(color: e.typeColor, width: 3),
                  ),
                  child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: 8),
                Text(e.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: e.typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(e.typeLabel, style: TextStyle(color: e.typeColor, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: e.statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: e.statusColor)),
                          const SizedBox(width: 4),
                          Text(e.status.name.toUpperCase(), style: TextStyle(color: e.statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(e.role, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          _sectionTitle('ATTRIBUTES'),
          const SizedBox(height: 8),
          _buildStatsBars(e),
          const SizedBox(height: 16),

          // Health + Uptime
          _sectionTitle('VITALS'),
          const SizedBox(height: 8),
          _vitalBar('HEALTH', e.health, 100, const Color(0xFFE63946)),
          const SizedBox(height: 6),
          _vitalBar('UPTIME', e.uptime, 100, const Color(0xFF22C55E)),
          const SizedBox(height: 16),

          // Operational stats
          _sectionTitle('OPERATIONS'),
          const SizedBox(height: 8),
          Row(
            children: [
              _statCard('Tasks Done', '${e.tasksCompleted}', const Color(0xFF22C55E)),
              const SizedBox(width: 8),
              _statCard('Tasks Failed', '${e.tasksFailed}', const Color(0xFFE63946)),
              const SizedBox(width: 8),
              _statCard('Level', '${e.level}', const Color(0xFF00D9FF)),
              const SizedBox(width: 8),
              _statCard('XP', '${e.xp}', const Color(0xFFFFB800)),
            ],
          ),
          const SizedBox(height: 16),

          // Skills
          _sectionTitle('SKILLS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: e.skills.map((s) => _tagChip(s, e.typeColor)).toList(),
          ),
          const SizedBox(height: 16),

          // Tools
          _sectionTitle('ACTIVE TOOLS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: e.activeTools.map((t) => _tagChip(t, const Color(0xFFFFB800))).toList(),
          ),
          const SizedBox(height: 16),

          // Protocols
          _sectionTitle('PROTOCOLS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: e.protocols.map((p) => _tagChip(p, const Color(0xFF8B5CF6))).toList(),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.healing, size: 16),
                  label: const Text('HEAL', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF22C55E),
                    side: const BorderSide(color: Color(0xFF22C55E)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D9FF),
                    side: const BorderSide(color: Color(0xFF00D9FF)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.assignment, size: 16),
                  label: const Text('ASSIGN', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFB800),
                    side: const BorderSide(color: Color(0xFFFFB800)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBars(UnifiedEntity e) {
    final stats = [
      ('STR', e.stats['str'] ?? 0, const Color(0xFFE63946)),
      ('INT', e.stats['int'] ?? 0, const Color(0xFF00D9FF)),
      ('END', e.stats['end'] ?? 0, const Color(0xFF22C55E)),
      ('SPD', e.stats['spd'] ?? 0, const Color(0xFFFFB800)),
    ];

    return Column(
      children: stats.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(width: 32, child: Text(s.$1, style: TextStyle(color: s.$3, fontSize: 10, fontWeight: FontWeight.w800))),
              Expanded(
                child: Stack(
                  children: [
                    Container(height: 12, decoration: BoxDecoration(color: s.$3.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6))),
                    FractionallySizedBox(
                      widthFactor: (s.$2 / 10).clamp(0, 1),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [s.$3.withValues(alpha: 0.5), s.$3]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${s.$2.toInt()}/10', style: TextStyle(color: s.$3, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _vitalBar(String label, double val, double max, Color color) {
    final pct = (val / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 55, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800))),
        Expanded(
          child: Stack(
            children: [
              Container(height: 10, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5))),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('${val.toStringAsFixed(1)}%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2));
  }
}
