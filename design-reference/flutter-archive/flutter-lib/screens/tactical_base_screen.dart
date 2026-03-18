import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/unified_entity.dart';


/// Tactical Grid Base Map — pixel art–inspired infrastructure view.
/// Buildings represent real systems, entities move on the grid.
/// Tap buildings/entities for detail panels.
class TacticalBaseScreen extends ConsumerStatefulWidget {
  const TacticalBaseScreen({super.key});

  @override
  ConsumerState<TacticalBaseScreen> createState() => _TacticalBaseScreenState();
}

class _TacticalBaseScreenState extends ConsumerState<TacticalBaseScreen>
    with TickerProviderStateMixin {
  // Grid config
  static const int gridCols = 14;
  static const int gridRows = 10;
  static const double tileSize = 48;

  late AnimationController _entityPulse;
  late AnimationController _beamAnim;
  String? _selectedBuildingId;
  String? _selectedEntityId;

  // Buildings placed on the grid
  final List<_Building> _buildings = [
    _Building(id: 'cmd_center', name: 'Command Center', icon: '🏛️', col: 6, row: 4, w: 2, h: 2, color: Color(0xFF00D9FF), type: 'core', desc: 'Central coordination hub — FastAPI Gateway'),
    _Building(id: 'data_vault', name: 'Data Vault', icon: '🗄️', col: 1, row: 1, w: 2, h: 2, color: Color(0xFF8B5CF6), type: 'storage', desc: 'PostgreSQL + pgvector + TimescaleDB'),
    _Building(id: 'relay_tower', name: 'Relay Tower', icon: '📡', col: 11, row: 1, w: 2, h: 2, color: Color(0xFFFF6B00), type: 'network', desc: 'NATS JetStream event bus'),
    _Building(id: 'agent_barracks', name: 'Agent Barracks', icon: '🤖', col: 2, row: 6, w: 2, h: 2, color: Color(0xFF22C55E), type: 'agents', desc: 'AI Agent deployment & training facility'),
    _Building(id: 'workshop', name: 'Workshop', icon: '⚒️', col: 10, row: 6, w: 2, h: 2, color: Color(0xFFFFB800), type: 'tools', desc: 'Tool registry & workflow builder'),
    _Building(id: 'watchtower', name: 'Watchtower', icon: '🗼', col: 0, row: 4, w: 1, h: 2, color: Color(0xFFE63946), type: 'monitor', desc: 'Health monitoring & alerting'),
    _Building(id: 'lab', name: 'Research Lab', icon: '🧪', col: 13, row: 4, w: 1, h: 2, color: Color(0xFF06B6D4), type: 'research', desc: 'Model training & experimentation'),
    _Building(id: 'armory', name: 'Protocol Armory', icon: '🛡️', col: 5, row: 8, w: 2, h: 1, color: Color(0xFF64748B), type: 'protocols', desc: 'Workflow protocols & security rules'),
    _Building(id: 'garden', name: 'Knowledge Garden', icon: '🌿', col: 8, row: 8, w: 2, h: 1, color: Color(0xFF10B981), type: 'knowledge', desc: 'Memory store & knowledge base'),
  ];

  @override
  void initState() {
    super.initState();
    _entityPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _beamAnim = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _entityPulse.dispose();
    _beamAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TACTICAL BASE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        actions: [
          _goldBadge(game.gold),
          const SizedBox(width: 8),
          _entityCounter(game),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Mini status bar
          _buildStatusBar(game),
          // Grid map
          Expanded(
            child: Stack(
              children: [
                // Grid + buildings
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(200),
                  child: Center(
                    child: SizedBox(
                      width: gridCols * tileSize,
                      height: gridRows * tileSize,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_entityPulse, _beamAnim]),
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _BasePainter(
                              buildings: _buildings,
                              entities: game.entities,
                              selectedBuildingId: _selectedBuildingId,
                              selectedEntityId: _selectedEntityId,
                              pulseValue: _entityPulse.value,
                              beamValue: _beamAnim.value,
                              tileSize: tileSize,
                              cols: gridCols,
                              rows: gridRows,
                            ),
                            child: GestureDetector(
                              onTapDown: (details) => _handleTap(details, game.entities),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Detail panel
                if (_selectedBuildingId != null || _selectedEntityId != null)
                  Positioned(
                    right: 0, top: 0, bottom: 0, width: screenW > 600 ? 280 : screenW * 0.7,
                    child: _buildDetailPanel(game),
                  ),
              ],
            ),
          ),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  void _handleTap(TapDownDetails details, List<UnifiedEntity> entities) {
    final pos = details.localPosition;
    final col = (pos.dx / tileSize).floor();
    final row = (pos.dy / tileSize).floor();

    // Check buildings
    for (final b in _buildings) {
      if (col >= b.col && col < b.col + b.w && row >= b.row && row < b.row + b.h) {
        setState(() { _selectedBuildingId = b.id; _selectedEntityId = null; });
        return;
      }
    }

    // Check entities (positioned deterministically)
    for (int i = 0; i < entities.length; i++) {
      final eCol = _entityCol(i, entities.length);
      final eRow = _entityRow(i, entities.length);
      if (col == eCol && row == eRow) {
        setState(() { _selectedEntityId = entities[i].id; _selectedBuildingId = null; });
        return;
      }
    }

    setState(() { _selectedBuildingId = null; _selectedEntityId = null; });
  }

  int _entityCol(int index, int total) {
    // Spread entities around the map in sensible positions
    final positions = [
      [7, 3], [3, 3], [4, 5], [11, 4], [12, 5],
      [2, 3], [11, 3], [7, 6], [1, 5],
    ];
    if (index < positions.length) return positions[index][0];
    return 5 + (index % 5);
  }

  int _entityRow(int index, int total) {
    final positions = [
      [7, 3], [3, 3], [4, 5], [11, 4], [12, 5],
      [2, 3], [11, 3], [7, 6], [1, 5],
    ];
    if (index < positions.length) return positions[index][1];
    return 3 + (index % 4);
  }

  // ─── DETAIL PANEL ───

  Widget _buildDetailPanel(GameState game) {
    if (_selectedBuildingId != null) {
      final b = _buildings.firstWhere((b) => b.id == _selectedBuildingId);
      return _detailContainer(
        icon: b.icon,
        name: b.name,
        typeLabel: b.type.toUpperCase(),
        typeColor: b.color,
        children: [
          Text(b.desc, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 12),
          _detailRow('TYPE', b.type.toUpperCase()),
          _detailRow('STATUS', 'OPERATIONAL'),
          _detailRow('GRID POS', '(${b.col}, ${b.row})'),
          _detailRow('SIZE', '${b.w}x${b.h}'),
          const SizedBox(height: 16),
          _actionButton('INSPECT', Icons.search, const Color(0xFF00D9FF)),
          const SizedBox(height: 8),
          _actionButton('UPGRADE', Icons.arrow_upward, const Color(0xFF22C55E)),
        ],
      );
    }
    if (_selectedEntityId != null) {
      final e = game.entities.firstWhere((e) => e.id == _selectedEntityId);
      return _detailContainer(
        icon: e.emoji,
        name: e.name,
        typeLabel: e.typeLabel,
        typeColor: e.typeColor,
        children: [
          Text(e.role, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 8),
          // HP bar
          _miniBar('HEALTH', e.health, 100, const Color(0xFFE63946)),
          const SizedBox(height: 4),
          _miniBar('UPTIME', e.uptime, 100, const Color(0xFF22C55E)),
          const SizedBox(height: 12),
          _detailRow('LEVEL', '${e.level}'),
          _detailRow('STATUS', e.status.name.toUpperCase()),
          _detailRow('TASKS', '${e.tasksCompleted}'),
          const SizedBox(height: 8),
          Text('SKILLS', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: e.skills.map((s) => _chip(s, e.typeColor)).toList(),
          ),
          const SizedBox(height: 8),
          Text('TOOLS', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: e.activeTools.map((t) => _chip(t, const Color(0xFFFFB800))).toList(),
          ),
          const SizedBox(height: 8),
          Text('PROTOCOLS', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4, runSpacing: 4,
            children: e.protocols.map((p) => _chip(p, const Color(0xFF8B5CF6))).toList(),
          ),
          const SizedBox(height: 12),
          // Stats
          _buildStatsGrid(e),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _detailContainer({
    required String icon,
    required String name,
    required String typeLabel,
    required Color typeColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(left: BorderSide(color: typeColor.withValues(alpha: 0.5), width: 2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[900]!)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => setState(() { _selectedBuildingId = null; _selectedEntityId = null; }),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UnifiedEntity e) {
    final stats = {'STR': e.stats['str'] ?? 0, 'INT': e.stats['int'] ?? 0, 'END': e.stats['end'] ?? 0, 'SPD': e.stats['spd'] ?? 0};
    return Row(
      children: stats.entries.map((entry) {
        final pct = entry.value / 10;
        return Expanded(
          child: Column(
            children: [
              Text(entry.key, style: TextStyle(color: Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              SizedBox(
                width: 32, height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 3,
                      color: const Color(0xFF00D9FF),
                      backgroundColor: Colors.grey[900],
                    ),
                    Text('${entry.value.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _miniBar(String label, double val, double max, Color color) {
    final pct = (val / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9, fontWeight: FontWeight.w800))),
        Expanded(
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text('${val.toStringAsFixed(1)}%', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w700))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  // ─── STATUS BAR ───

  Widget _buildStatusBar(GameState game) {
    final completeOps = game.dailyOps.where((d) => d.completedToday).length;
    final activeMissions = game.missions.where((m) => !m.completed).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFF050505),
      child: Row(
        children: [
          _statusChip('⚡ ${game.entities.length} ENTITIES', const Color(0xFF00D9FF)),
          const SizedBox(width: 8),
          _statusChip('📋 $completeOps/${game.dailyOps.length} OPS', const Color(0xFF22C55E)),
          const SizedBox(width: 8),
          _statusChip('🎯 $activeMissions MISSIONS', const Color(0xFFFFB800)),
          const Spacer(),
          Text('GRID ${gridCols}x$gridRows', style: TextStyle(color: Colors.grey[700], fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _goldBadge(int gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text('$gold', style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _entityCounter(GameState game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('${game.activeEntities.length} ACTIVE', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  // ─── LEGEND ───

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF050505),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendDot('Human', const Color(0xFF00D9FF)),
          _legendDot('Agent', const Color(0xFF22C55E)),
          _legendDot('Machine', const Color(0xFFFF6B00)),
          _legendDot('Sensor', const Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          Text('■ Building', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── BUILDINGS MODEL ───

class _Building {
  final String id, name, icon, type, desc;
  final int col, row, w, h;
  final Color color;
  const _Building({
    required this.id, required this.name, required this.icon,
    required this.col, required this.row, required this.w, required this.h,
    required this.color, required this.type, required this.desc,
  });
}

// ─── CUSTOM PAINTER ───

class _BasePainter extends CustomPainter {
  final List<_Building> buildings;
  final List<UnifiedEntity> entities;
  final String? selectedBuildingId;
  final String? selectedEntityId;
  final double pulseValue;
  final double beamValue;
  final double tileSize;
  final int cols, rows;

  _BasePainter({
    required this.buildings,
    required this.entities,
    required this.selectedBuildingId,
    required this.selectedEntityId,
    required this.pulseValue,
    required this.beamValue,
    required this.tileSize,
    required this.cols,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawConnectionBeams(canvas);
    _drawBuildings(canvas);
    _drawEntities(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 0.5;

    for (int c = 0; c <= cols; c++) {
      canvas.drawLine(Offset(c * tileSize, 0), Offset(c * tileSize, rows * tileSize), paint);
    }
    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(Offset(0, r * tileSize), Offset(cols * tileSize, r * tileSize), paint);
    }

    // Subtle terrain — grass patches
    final grassPaint = Paint()..color = const Color(0xFF0A1A0A);
    final rng = Random(42);
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        if (rng.nextDouble() < 0.15) {
          canvas.drawRect(
            Rect.fromLTWH(c * tileSize + 2, r * tileSize + 2, tileSize - 4, tileSize - 4),
            grassPaint,
          );
        }
      }
    }
  }

  void _drawConnectionBeams(Canvas canvas) {
    // Draw animated data flow beams between buildings
    final center = buildings.firstWhere((b) => b.id == 'cmd_center');
    final cx = (center.col + center.w / 2) * tileSize;
    final cy = (center.row + center.h / 2) * tileSize;

    for (final b in buildings) {
      if (b.id == 'cmd_center') continue;
      final bx = (b.col + b.w / 2) * tileSize;
      final by = (b.row + b.h / 2) * tileSize;

      // Base line
      final linePaint = Paint()
        ..color = b.color.withValues(alpha: 0.08)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, cy), Offset(bx, by), linePaint);

      // Animated pulse dot
      final t = (beamValue + buildings.indexOf(b) * 0.15) % 1.0;
      final px = cx + (bx - cx) * t;
      final py = cy + (by - cy) * t;
      canvas.drawCircle(
        Offset(px, py),
        3,
        Paint()..color = b.color.withValues(alpha: 0.4 + pulseValue * 0.3),
      );
    }
  }

  void _drawBuildings(Canvas canvas) {
    for (final b in buildings) {
      final rect = Rect.fromLTWH(
        b.col * tileSize + 2, b.row * tileSize + 2,
        b.w * tileSize - 4, b.h * tileSize - 4,
      );

      final isSelected = b.id == selectedBuildingId;

      // Fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = b.color.withValues(alpha: isSelected ? 0.25 : 0.1),
      );

      // Border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = b.color.withValues(alpha: isSelected ? 0.8 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2 : 1,
      );

      // Glow for selected
      if (isSelected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(8)),
          Paint()
            ..color = b.color.withValues(alpha: 0.15 + pulseValue * 0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: '${b.icon}\n${b.name}',
          style: TextStyle(color: b.color, fontSize: 9, fontWeight: FontWeight.w700, height: 1.4),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 4);
      tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
    }
  }

  void _drawEntities(Canvas canvas) {
    final positions = [
      [7, 3], [3, 3], [4, 5], [11, 4], [12, 5],
      [2, 3], [11, 3], [7, 6], [1, 5],
    ];

    for (int i = 0; i < entities.length; i++) {
      final e = entities[i];
      final col = i < positions.length ? positions[i][0] : 5 + (i % 5);
      final row = i < positions.length ? positions[i][1] : 3 + (i % 4);
      final cx = col * tileSize + tileSize / 2;
      final cy = row * tileSize + tileSize / 2;
      final isSelected = e.id == selectedEntityId;
      final radius = isSelected ? 14.0 : 10.0;

      // Glow
      canvas.drawCircle(
        Offset(cx, cy),
        radius + 4 + pulseValue * 3,
        Paint()..color = e.typeColor.withValues(alpha: 0.08 + pulseValue * 0.05),
      );

      // Body
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()..color = e.typeColor.withValues(alpha: isSelected ? 0.5 : 0.25),
      );

      // Ring
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = e.statusColor.withValues(alpha: isSelected ? 1.0 : 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.5,
      );

      // Health pip (tiny ring on top-right)
      if (e.health < 100) {
        final hpAngle = (e.health / 100) * 2 * pi;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius + 2),
          -pi / 2,
          hpAngle,
          false,
          Paint()
            ..color = const Color(0xFFE63946)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: e.emoji,
          style: const TextStyle(fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

      // Name below
      final nameTp = TextPainter(
        text: TextSpan(
          text: e.name.split(' ').last,
          style: TextStyle(color: e.typeColor, fontSize: 7, fontWeight: FontWeight.w700),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      nameTp.paint(canvas, Offset(cx - nameTp.width / 2, cy + radius + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BasePainter old) => true;
}
