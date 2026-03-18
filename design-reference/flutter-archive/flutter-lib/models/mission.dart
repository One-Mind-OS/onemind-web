import 'package:flutter/material.dart';

enum MissionStatus {
  available,
  active,
  completed,
  failed
}

enum MissionDifficulty {
  easy,
  medium,
  hard,
  expert
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionStatus status;
  final MissionDifficulty difficulty;
  final int xpReward;
  final int creditsReward;
  final List<String> objectives;
  final double progress; // 0.0 to 1.0

  final DateTime? deadline; // Added for isOverdue

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    this.status = MissionStatus.available,
    this.difficulty = MissionDifficulty.medium,
    this.xpReward = 500,
    this.creditsReward = 200,
    this.objectives = const [],
    this.progress = 0.0,
    this.deadline,
  });

  // Getters for HabiticaHQScreen compatibility
  bool get completed => status == MissionStatus.completed || status == MissionStatus.failed;
  MissionDifficulty get priority => difficulty;
  String get notes => description;
  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!);

  Color get difficultyColor {
    switch (difficulty) {
      case MissionDifficulty.easy: return Colors.green;
      case MissionDifficulty.medium: return Colors.blue;
      case MissionDifficulty.hard: return Colors.orange;
      case MissionDifficulty.expert: return Colors.red;
    }
  }

  Color get statusColor {
    switch (status) {
      case MissionStatus.available: return Colors.grey;
      case MissionStatus.active: return Colors.blue;
      case MissionStatus.completed: return Colors.green;
      case MissionStatus.failed: return Colors.red;
    }
  }
}
