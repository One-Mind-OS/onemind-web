import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unified_entity.dart';
import '../models/daily_op.dart';
import '../models/mission.dart';
import '../models/achievement.dart';
import '../models/skill_node.dart';


/// Game State Provider — Tracks global game state and gamification elements
class GameState {
  final bool audioEnabled;
  final bool darkMode;
  final DateTime lastLoginDate;
  final List<UnifiedEntity> entities;
  final List<DailyOp> dailyOps;
  final List<Mission> missions;
  final List<Achievement> achievements;
  final List<SkillNode> skills;
  final List<String> visitedScreens;
  final int level;
  final int xp;
  final int streak;
  final int gold;

  GameState({
    this.audioEnabled = true,
    this.darkMode = true,
    DateTime? lastLoginDate,
    this.entities = const [],
    this.dailyOps = const [],
    this.missions = const [],
    this.achievements = const [],
    this.skills = const [],
    this.visitedScreens = const [],
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.gold = 1000,
  }) : lastLoginDate = lastLoginDate ?? DateTime.now();

  // Computed Getters for UI
  List<UnifiedEntity> get activeEntities => entities.where((e) => e.status == EntityStatus.active).toList();
  
  String get rank => level > 20 ? 'Overseer' : level > 10 ? 'Commander' : 'Operative';
  int get totalXP => xp;
  int get unlockedAchievements => achievements.where((a) => a.unlocked).length;
  
  List<Mission> get quests => missions;
  int get completedQuests => missions.where((m) => m.completed).length;
  
  int get unlockedSkills => skills.where((s) => s.unlocked).length;
  
  List<DailyOp> get dailyChallenges => dailyOps;
  
  // Level progression (mock formula)
  int get xpToNextLevel => level * 1000;
  int get currentLevelXP => xp % 1000;
  double get levelProgress => currentLevelXP / xpToNextLevel;

  GameState copyWith({
    bool? audioEnabled,
    bool? darkMode,
    DateTime? lastLoginDate,
    List<UnifiedEntity>? entities,
    List<DailyOp>? dailyOps,
    List<Mission>? missions,
    List<Achievement>? achievements,
    List<SkillNode>? skills,
    List<String>? visitedScreens,
    int? level,
    int? xp,
    int? streak,
    int? gold,
  }) {
    return GameState(
      audioEnabled: audioEnabled ?? this.audioEnabled,
      darkMode: darkMode ?? this.darkMode,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      entities: entities ?? this.entities,
      dailyOps: dailyOps ?? this.dailyOps,
      missions: missions ?? this.missions,
      achievements: achievements ?? this.achievements,
      skills: skills ?? this.skills,
      visitedScreens: visitedScreens ?? this.visitedScreens,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      gold: gold ?? this.gold,
    );
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState()) {
    _loadState();
    _loadGameData();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final audioEnabled = prefs.getBool('audio_enabled') ?? true;
      final darkMode = prefs.getBool('dark_mode') ?? true;
      final lastLoginMs = prefs.getInt('last_login') ?? DateTime.now().millisecondsSinceEpoch;
      final savedLevel = prefs.getInt('level') ?? 1;
      final savedXP = prefs.getInt('xp') ?? 0;
      final savedStreak = prefs.getInt('streak') ?? 0;

      state = state.copyWith(
        audioEnabled: audioEnabled,
        darkMode: darkMode,
        lastLoginDate: DateTime.fromMillisecondsSinceEpoch(lastLoginMs),
        level: savedLevel,
        xp: savedXP,
        streak: savedStreak,
      );
    } catch (e) {
      // Ignore load errors
    }
  }

  void _loadGameData() {
    // Mock data for initial state
    state = state.copyWith(
      entities: [
        const UnifiedEntity(id: 'u1', name: 'User Commander', type: EntityType.human, status: EntityStatus.active, level: 5, uptime: 100.0),
        const UnifiedEntity(id: 'a1', name: 'Strategos', type: EntityType.agent, status: EntityStatus.active, level: 3, uptime: 99.5),
        const UnifiedEntity(id: 'r1', name: 'Rover-X', type: EntityType.robot, status: EntityStatus.maintenance, level: 2, uptime: 85.0),
      ],
      dailyOps: [
        DailyOp(id: 'op1', title: 'System Check', description: 'Run diagnostics', status: OpStatus.pending, schedule: 'Daily 09:00'),
        DailyOp(id: 'op2', title: 'Data Backup', description: 'Backup databases', status: OpStatus.completed, schedule: 'Daily 23:00', completedToday: true),
      ],
      missions: [
        Mission(id: 'm1', title: 'Operation Sunrise', description: 'Deploy solar array.', difficulty: MissionDifficulty.medium, status: MissionStatus.active),
        Mission(id: 'm2', title: 'Secure Perimeter', description: 'Verify firewall rules.', difficulty: MissionDifficulty.hard, status: MissionStatus.completed),
      ],
      achievements: [
        const Achievement(id: 'a1', title: 'First Login', description: 'Access the system for the first time.', icon: '🔑', category: 'system', unlocked: true, xpReward: 50),
        const Achievement(id: 'a2', title: 'Task Master', description: 'Complete 10 daily operations.', icon: '✅', category: 'productivity', unlocked: false, xpReward: 200),
        const Achievement(id: 'a3', title: 'Deep Diver', description: 'Visit all system screens.', icon: '🗺️', category: 'exploration', unlocked: false, xpReward: 150),
        const Achievement(id: 'a4', title: 'Commander', description: 'Reach Level 10.', icon: '⭐', category: 'mastery', unlocked: false, xpReward: 1000),
        const Achievement(id: 'a5', title: 'Agent Operator', description: 'Deploy your first agent.', icon: '🤖', category: 'agents', unlocked: true, xpReward: 100),
      ],
      skills: [
        SkillNode(id: 's1', name: 'Voice Command', description: 'Unlock voice-based interactions', icon: '🗣️', branch: 'command', levelRequired: 1, unlocked: true),
        SkillNode(id: 's2', name: 'Entity Search', description: 'Advanced search filters for assets', icon: '🔍', branch: 'intel', levelRequired: 2, unlocked: true),
        SkillNode(id: 's3', name: 'NATS Bridge', description: 'Direct NATS message bus access', icon: '🌉', branch: 'engineering', levelRequired: 5, unlocked: false),
        SkillNode(id: 's4', name: 'Quick Tasks', description: 'Create tasks from chat interface', icon: '⚡', branch: 'combat', levelRequired: 3, unlocked: false),
        SkillNode(id: 's5', name: 'Asset Tracking', description: 'Real-time GPS tracking on world map', icon: '📍', branch: 'exploration', levelRequired: 1, unlocked: true),
      ],
      visitedScreens: ['/home', '/dashboard'],
      gold: 5430,
    );
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audio_enabled', state.audioEnabled);
      await prefs.setBool('dark_mode', state.darkMode);
      await prefs.setInt('last_login', state.lastLoginDate.millisecondsSinceEpoch);
      await prefs.setInt('level', state.level);
      await prefs.setInt('xp', state.xp);
      await prefs.setInt('streak', state.streak);
    } catch (e) {
      // Ignore save errors
    }
  }

  void setAudioEnabled(bool enabled) {
    state = state.copyWith(audioEnabled: enabled);
    _saveState();
  }

  void setDarkMode(bool enabled) {
    state = state.copyWith(darkMode: enabled);
    _saveState();
  }

  void recordLogin() {
    state = state.copyWith(lastLoginDate: DateTime.now());
    _saveState();
  }
  
  void updateEntities(List<UnifiedEntity> newEntities) {
    state = state.copyWith(entities: newEntities);
  }

  void recordScreenVisit(String routeName) {
    if (!state.visitedScreens.contains(routeName)) {
      state = state.copyWith(visitedScreens: [...state.visitedScreens, routeName]);
      _checkAchievements();
    }
  }

  void completeDailyOp(String opId) {
    final updatedOps = state.dailyOps.map((op) {
      if (op.id == opId) {
        return DailyOp(
          id: op.id,
          title: op.title,
          description: op.description,
          status: OpStatus.completed,
          schedule: op.schedule,
          completedToday: true,
          streak: op.streak + 1,
          notes: op.notes,
        );
      }
      return op;
    }).toList();
    
    state = state.copyWith(dailyOps: updatedOps, xp: state.xp + 50);
    _saveState();
    _checkLevelUp();
  }

  void completeMission(String missionId) {
    final updatedMissions = state.missions.map((m) {
      if (m.id == missionId) {
        return Mission(
          id: m.id,
          title: m.title,
          description: m.description,
          difficulty: m.difficulty,
          status: MissionStatus.completed,
          deadline: m.deadline,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(missions: updatedMissions, xp: state.xp + 200);
    _saveState();
    _checkLevelUp();
  }

  void _checkLevelUp() {
    if (state.currentLevelXP >= state.xpToNextLevel) {
      state = state.copyWith(level: state.level + 1);
      // Trigger level up notification logic here if needed
      _saveState();
    }
  }

  void _checkAchievements() {
    // Simple check logic stub
    if (state.visitedScreens.length >= 5) {
      _unlockAchievement('a3');
    }
  }

  void _unlockAchievement(String id) {
    final index = state.achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !state.achievements[index].unlocked) {
      final updatedAchievements = List<Achievement>.from(state.achievements);
      updatedAchievements[index] = updatedAchievements[index].copyWith(unlocked: true, unlockedAt: DateTime.now());
      state = state.copyWith(achievements: updatedAchievements, xp: state.xp + updatedAchievements[index].xpReward);
      _saveState();
      _checkLevelUp();
    }
  }
}

// Provider
final gameProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// Legacy provider name for compatibility
final gameStateProvider = gameProvider;
