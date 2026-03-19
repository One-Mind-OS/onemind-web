import 'package:flutter/material.dart';

enum OpStatus {
  pending,
  inProgress,
  completed,
  failed
}

class DailyOp {
  final String id;
  final String title;
  final String description;
  final OpStatus status;
  final int xpReward;
  final int creditsReward;
  final DateTime? deadline;
  final String schedule; // Added for HQ screen
  final double progress; // 0.0 to 1.0
  final bool completedToday; // Added for HQ screen
  final String notes; // Added for HQ screen
  final int streak; // Added for HQ screen

  const DailyOp({
    required this.id,
    required this.title,
    required this.description,
    this.status = OpStatus.pending,
    this.xpReward = 100,
    this.creditsReward = 50,
    this.deadline,
    this.schedule = 'Daily',
    this.progress = 0.0,
    this.completedToday = false,
    this.notes = '',
    this.streak = 0,
  });

  Color get color {
    switch (status) {
      case OpStatus.pending:
        return Colors.orange;
      case OpStatus.inProgress:
        return Colors.blue;
      case OpStatus.completed:
        return Colors.green;
      case OpStatus.failed:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (status) {
      case OpStatus.pending:
        return Icons.hourglass_empty;
      case OpStatus.inProgress:
        return Icons.play_arrow;
      case OpStatus.completed:
        return Icons.check_circle;
      case OpStatus.failed:
        return Icons.cancel;
    }
  }

  bool get completed => completedToday || status == OpStatus.completed; // Added compatibility getter
}
