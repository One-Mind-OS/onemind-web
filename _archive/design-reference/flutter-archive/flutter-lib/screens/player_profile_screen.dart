import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/achievement.dart'; // Added

/// Player Profile Screen — Commander Stats & Badge Collection
/// ===========================================================
/// Shows player level, XP, stats, achievement collection, and activity.

class PlayerProfileScreen extends ConsumerStatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  ConsumerState<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).recordScreenVisit('/profile');
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final categories = ['all', 'agents', 'workflows', 'system', 'exploration', 'mastery'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('COMMANDER PROFILE', style: TextStyle(fontFamily: 'monospace', letterSpacing: 2)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── PLAYER CARD ───
            _buildPlayerCard(game),
            const SizedBox(height: 20),

            // ─── STATS GRID ───
            _buildStatsGrid(game),
            const SizedBox(height: 20),

            // ─── XP PROGRESS ───
            _buildXPProgress(game),
            const SizedBox(height: 24),

            // ─── ACHIEVEMENTS ───
            const Text('BADGE COLLECTION',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 14, fontFamily: 'monospace', letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Category filter
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00D9FF).withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00D9FF) : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF00D9FF) : Colors.white54,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Achievement grid
            _buildAchievementGrid(game),
            const SizedBox(height: 24),

            // ─── RECENT UNLOCKS ───
            _buildRecentUnlocks(game),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(GameState game) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0020),
            const Color(0xFF000A14),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rankColor(game.level).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _rankColor(game.level).withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar / Level ring
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_rankColor(game.level), _rankColor(game.level).withValues(alpha: 0.3)],
              ),
              boxShadow: [
                BoxShadow(color: _rankColor(game.level).withValues(alpha: 0.4), blurRadius: 16),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LV', style: TextStyle(color: _rankColor(game.level), fontSize: 10, fontFamily: 'monospace')),
                    Text('${game.level}',
                        style: TextStyle(
                            color: _rankColor(game.level),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.rank.toUpperCase(),
                  style: TextStyle(
                    color: _rankColor(game.level),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ONEMIND OPERATIVE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat('XP', '${game.totalXP}', const Color(0xFF00D9FF)),
                    const SizedBox(width: 16),
                    _miniStat('🔥', '${game.streak}d', const Color(0xFFFF6B00)),
                    const SizedBox(width: 16),
                    _miniStat('🏆', '${game.unlockedAchievements}', const Color(0xFFFFD700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildStatsGrid(GameState game) {
    final stats = [
      _StatItem('QUESTS DONE', '${game.completedQuests}/${game.quests.length}', Icons.flag, const Color(0xFF00D9FF)),
      _StatItem('SKILLS', '${game.unlockedSkills}/${game.skills.length}', Icons.psychology, const Color(0xFF8B5CF6)),
      _StatItem('SCREENS', '${game.visitedScreens.length}', Icons.map, const Color(0xFF22C55E)),
      _StatItem('DAILIES', '${game.dailyChallenges.where((d) => d.completed).length}/${game.dailyChallenges.length}', Icons.today, const Color(0xFFFF6B00)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      children: stats.map((s) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: s.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: s.color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(s.icon, color: s.color, size: 20),
            const SizedBox(height: 4),
            Text(s.value, style: TextStyle(color: s.color, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            Text(s.label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8, fontFamily: 'monospace')),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildXPProgress(GameState game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D9FF).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LEVEL ${game.level}',
                  style: const TextStyle(color: Color(0xFF00D9FF), fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              Text('LEVEL ${game.level + 1}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: game.levelProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(_rankColor(game.level)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${game.currentLevelXP} / ${game.xpToNextLevel} XP',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(GameState game) {
    final filtered = _selectedCategory == 'all'
        ? game.achievements
        : game.achievements.where((a) => a.category == _selectedCategory).toList();

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: filtered.map((a) => _AchievementBadge(achievement: a)).toList(),
    );
  }

  Widget _buildRecentUnlocks(GameState game) {
    final unlocked = game.achievements.where((a) => a.unlocked).toList();
    if (unlocked.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: Text('No achievements unlocked yet. Start exploring!',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'monospace')),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT UNLOCKS',
            style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace', letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...unlocked.take(5).map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Text(a.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(a.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                    ],
                  ),
                ),
                Text('+${a.xpReward} XP', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontFamily: 'monospace')),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Color _rankColor(int level) {
    if (level >= 25) return const Color(0xFFFFD700);
    if (level >= 15) return const Color(0xFFFF00FF);
    if (level >= 10) return const Color(0xFF00FF87);
    if (level >= 5) return const Color(0xFF00D9FF);
    return const Color(0xFF00D9FF);
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.label, this.value, this.icon, this.color);
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: unlocked
              ? const Color(0xFFFFD700).withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked
                ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unlocked ? achievement.icon : '🔒',
              style: TextStyle(
                fontSize: 26,
                color: unlocked ? null : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.2),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0A0A14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: achievement.unlocked
                ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achievement.unlocked ? achievement.icon : '🔒',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(achievement.title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(height: 12),
              if (achievement.unlocked)
                Text('UNLOCKED', style: TextStyle(color: const Color(0xFF22C55E), fontFamily: 'monospace', letterSpacing: 2))
              else
                Text('LOCKED', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'monospace', letterSpacing: 2)),
              const SizedBox(height: 4),
              Text('+${achievement.xpReward} XP',
                  style: const TextStyle(color: Color(0xFFFFD700), fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text(achievement.category.toUpperCase(),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontFamily: 'monospace', letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
