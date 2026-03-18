import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/skill_node.dart';


/// Skill Tree Screen — Interactive Tech Tree with Visual Branches
/// ================================================================
/// 5 branches: Command, Intel, Engineering, Combat, Exploration.
/// Nodes unlock as player levels up + prerequisites are met.

class SkillTreeScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SkillTreeScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends ConsumerState<SkillTreeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedBranch = 'all';
  late AnimationController _pulseController;

  static const Map<String, _BranchTheme> branchThemes = {
    'command': _BranchTheme('COMMAND', '💬', Color(0xFF00D9FF), 'Communication & voice controls'),
    'intel': _BranchTheme('INTEL', '📖', Color(0xFF8B5CF6), 'Knowledge & analytics'),
    'engineering': _BranchTheme('ENGINEERING', '⚒️', Color(0xFFFF6B00), 'Agent & workflow building'),
    'combat': _BranchTheme('COMBAT', '⚔️', Color(0xFFE63946), 'Operations & task management'),
    'exploration': _BranchTheme('EXPLORATION', '🗺️', Color(0xFF22C55E), 'Monitoring & discovery'),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).recordScreenVisit('/skill-tree');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final allSkills = game.skills;
    final filtered = _selectedBranch == 'all'
        ? allSkills
        : allSkills.where((s) => s.branch == _selectedBranch).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.embedded ? null : AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SKILL TREE', style: TextStyle(fontFamily: 'monospace', letterSpacing: 2)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${game.unlockedSkills}/${allSkills.length}',
                style: const TextStyle(color: Color(0xFF00D9FF), fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Branch filter bar
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildBranchChip('all', 'ALL', '🌐', Colors.white54),
                ...branchThemes.entries.map((e) =>
                    _buildBranchChip(e.key, e.value.name, e.value.icon, e.value.color)),
              ],
            ),
          ),

          // Branch description
          if (_selectedBranch != 'all' && branchThemes.containsKey(_selectedBranch))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                branchThemes[_selectedBranch]!.description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontFamily: 'monospace'),
              ),
            ),

          // Skill tree
          Expanded(
            child: _selectedBranch == 'all'
                ? _buildAllBranchesView(game)
                : _buildBranchView(filtered, game),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchChip(String key, String label, String icon, Color color) {
    final isSelected = key == _selectedBranch;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedBranch = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? color : Colors.white54,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllBranchesView(GameState game) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: branchThemes.entries.map((entry) {
        final branchSkills = game.skills.where((s) => s.branch == entry.key).toList();
        final unlocked = branchSkills.where((s) => s.unlocked).length;
        final theme = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.color.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(theme.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(theme.name,
                            style: TextStyle(color: theme.color, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Text(theme.description,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('$unlocked/${branchSkills.length}',
                      style: TextStyle(color: theme.color, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              // Skill nodes in row
              SizedBox(
                height: 80,
                child: Row(
                  children: branchSkills.asMap().entries.map((e) {
                    final idx = e.key;
                    final skill = e.value;
                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _SkillNodeWidget(skill: skill, branchColor: theme.color, pulseController: _pulseController, playerLevel: game.level)),
                          if (idx < branchSkills.length - 1)
                            SizedBox(
                              width: 20,
                              child: Center(
                                child: Container(
                                  height: 2,
                                  color: skill.unlocked ? theme.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBranchView(List<SkillNode> skills, GameState game) {
    final theme = branchThemes[_selectedBranch]!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Column(
          children: [
            if (index > 0)
              _ConnectionLine(
                isActive: skills[index - 1].unlocked,
                color: theme.color,
              ),
            _SkillDetailCard(
              skill: skill,
              branchColor: theme.color,
              playerLevel: game.level,
              pulseController: _pulseController,
            ),
          ],
        );
      },
    );
  }
}

class _BranchTheme {
  final String name;
  final String icon;
  final Color color;
  final String description;
  const _BranchTheme(this.name, this.icon, this.color, this.description);
}

class _SkillNodeWidget extends StatelessWidget {
  final SkillNode skill;
  final Color branchColor;
  final AnimationController pulseController;
  final int playerLevel;

  const _SkillNodeWidget({
    required this.skill,
    required this.branchColor,
    required this.pulseController,
    required this.playerLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = skill.unlocked;
    final canUnlock = !isUnlocked && skill.levelRequired <= playerLevel;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (context, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? branchColor.withValues(alpha: 0.15)
                      : canUnlock
                          ? branchColor.withValues(alpha: 0.05 + pulseController.value * 0.05)
                          : Colors.white.withValues(alpha: 0.02),
                  border: Border.all(
                    color: isUnlocked
                        ? branchColor.withValues(alpha: 0.7)
                        : canUnlock
                            ? branchColor.withValues(alpha: 0.3 + pulseController.value * 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                    width: isUnlocked ? 2 : 1,
                  ),
                  boxShadow: isUnlocked
                      ? [BoxShadow(color: branchColor.withValues(alpha: 0.3), blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? skill.icon : '🔒',
                    style: TextStyle(fontSize: isUnlocked ? 20 : 14),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                skill.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context) {
    _showSkillDetail(context, skill, branchColor, playerLevel);
  }
}

class _SkillDetailCard extends StatelessWidget {
  final SkillNode skill;
  final Color branchColor;
  final int playerLevel;
  final AnimationController pulseController;

  const _SkillDetailCard({
    required this.skill,
    required this.branchColor,
    required this.playerLevel,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = skill.unlocked;
    final canUnlock = !isUnlocked && skill.levelRequired <= playerLevel;

    return GestureDetector(
      onTap: () => _showSkillDetail(context, skill, branchColor, playerLevel),
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? branchColor.withValues(alpha: 0.05)
                  : canUnlock
                      ? branchColor.withValues(alpha: 0.02 + pulseController.value * 0.02)
                      : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnlocked
                    ? branchColor.withValues(alpha: 0.4)
                    : canUnlock
                        ? branchColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
              ),
              boxShadow: isUnlocked
                  ? [BoxShadow(color: branchColor.withValues(alpha: 0.15), blurRadius: 12)]
                  : null,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked ? branchColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                    border: Border.all(
                      color: isUnlocked ? branchColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isUnlocked ? skill.icon : '🔒',
                      style: TextStyle(fontSize: isUnlocked ? 26 : 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(skill.name,
                                style: TextStyle(
                                    color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('UNLOCKED',
                                  style: TextStyle(color: Color(0xFF22C55E), fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: branchColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('LV ${skill.levelRequired}',
                                  style: TextStyle(color: branchColor, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(skill.description,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                    ],
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

class _ConnectionLine extends StatelessWidget {
  final bool isActive;
  final Color color;
  const _ConnectionLine({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isActive
                ? [color.withValues(alpha: 0.5), color.withValues(alpha: 0.2)]
                : [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
          ),
        ),
      ),
    );
  }
}

void _showSkillDetail(BuildContext context, SkillNode skill, Color branchColor, int playerLevel) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF0A0A14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: skill.unlocked ? branchColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(skill.unlocked ? skill.icon : '🔒', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(skill.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(skill.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 16),
            if (skill.unlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                ),
                child: const Text('✅ SKILL UNLOCKED',
                    style: TextStyle(color: Color(0xFF22C55E), fontFamily: 'monospace', letterSpacing: 1)),
              )
            else ...[
              Text('Required Level: ${skill.levelRequired}',
                  style: TextStyle(
                      color: playerLevel >= skill.levelRequired ? const Color(0xFF22C55E) : const Color(0xFFE63946),
                      fontFamily: 'monospace')),
              if (skill.prerequisites.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Prerequisites: ${skill.prerequisites.join(', ')}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontFamily: 'monospace')),
              ],
              const SizedBox(height: 8),
              Text('Your Level: $playerLevel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontFamily: 'monospace')),
            ],
          ],
        ),
      ),
    ),
  );
}
