import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/mission.dart';
import '../models/daily_op.dart';

/// Quest Board Screen — Mission Control Center
/// =============================================
/// Active quests, daily challenges, and quest log.
/// Full RPG-style mission board.

class QuestBoardScreen extends ConsumerStatefulWidget {
  const QuestBoardScreen({super.key});

  @override
  ConsumerState<QuestBoardScreen> createState() => _QuestBoardScreenState();
}

class _QuestBoardScreenState extends ConsumerState<QuestBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Record screen visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).recordScreenVisit('/quests');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    
    // Categorize missions based on difficulty as a proxy for type
    final mainQuests = game.missions.where((m) => m.difficulty == MissionDifficulty.hard || m.difficulty == MissionDifficulty.expert).toList();
    final sideQuests = game.missions.where((m) => m.difficulty == MissionDifficulty.easy || m.difficulty == MissionDifficulty.medium).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QUEST BOARD', style: TextStyle(fontFamily: 'monospace', letterSpacing: 2)),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D9FF),
          labelColor: const Color(0xFF00D9FF),
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(
              icon: const Icon(Icons.flag, size: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('MAIN', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(width: 4),
                  _completionBadge(mainQuests.where((q) => q.completed).length, mainQuests.length),
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.explore, size: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('SIDE', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(width: 4),
                  _completionBadge(sideQuests.where((q) => q.completed).length, sideQuests.length),
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.today, size: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('DAILY', style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(width: 4),
                  _completionBadge(game.dailyOps.where((d) => d.completedToday).length, game.dailyOps.length),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestList(mainQuests, 'main'),
          _buildQuestList(sideQuests, 'side'),
          _buildDailyChallenges(game.dailyOps),
        ],
      ),
    );
  }

  Widget _completionBadge(int done, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: done == total && total > 0
            ? const Color(0xFF22C55E).withValues(alpha: 0.2)
            : const Color(0xFF00D9FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: done == total && total > 0
              ? const Color(0xFF22C55E).withValues(alpha: 0.5)
              : const Color(0xFF00D9FF).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$done/$total',
        style: TextStyle(
          fontSize: 9,
          fontFamily: 'monospace',
          color: done == total && total > 0
              ? const Color(0xFF22C55E)
              : const Color(0xFF00D9FF),
        ),
      ),
    );
  }

  Widget _buildQuestList(List<Mission> quests, String type) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('No $type quests available',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontFamily: 'monospace')),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _QuestCard(quest: quests[index]),
    );
  }

  Widget _buildDailyChallenges(List<DailyOp> challenges) {
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B00).withValues(alpha: 0.1),
                const Color(0xFFFF0000).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF6B00).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('🌅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DAILY CHALLENGES',
                        style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontFamily: 'monospace', letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    Text('Resets every 24 hours. Complete for bonus XP.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${challenges.where((d) => d.completedToday).length}/${challenges.length}',
                  style: const TextStyle(color: Color(0xFFFF6B00), fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Challenges
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _DailyChallengeCard(challenge: challenges[index]),
          ),
        ),
      ],
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Mission quest;
  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final isComplete = quest.completed;
    final accentColor = isComplete ? const Color(0xFF22C55E) : const Color(0xFF00D9FF);
    final icon = quest.difficulty == MissionDifficulty.hard || quest.difficulty == MissionDifficulty.expert ? '👑' : '🛡️';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFF0A1A0A) : const Color(0xFF0A0A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: isComplete ? 0.3 : 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(quest.title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: isComplete ? TextDecoration.lineThrough : null)),
                        ),
                        if (isComplete)
                          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20)
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quest.difficulty.name.toUpperCase(),
                              style: TextStyle(color: accentColor, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(quest.description,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isComplete ? 1.0 : quest.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(quest.progress * 100).toInt()}%',
                style: TextStyle(color: accentColor, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final DailyOp challenge;
  const _DailyChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isComplete = challenge.completedToday;
    final accentColor = isComplete ? const Color(0xFF22C55E) : const Color(0xFFFF6B00);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFF0A1A0A) : const Color(0xFF140A00),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Completion indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: isComplete ? 0.2 : 0.1),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: isComplete
                  ? const Icon(Icons.check, color: Color(0xFF22C55E), size: 20)
                  : Text(
                      '${(challenge.progress * 100).toInt()}%',
                      style: TextStyle(color: accentColor, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        decoration: isComplete ? TextDecoration.lineThrough : null)),
                Text(challenge.description,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isComplete ? 1.0 : challenge.progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${challenge.xpReward}',
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
