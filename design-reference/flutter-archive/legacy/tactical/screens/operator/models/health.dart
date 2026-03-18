// Health models for Operator Intel
// Supports biometrics from Oura, Apple Health, etc.

import 'package:flutter/material.dart';
import '../../../../shared/theme/tactical.dart';

/// Health score category
enum HealthCategory {
  sleep,
  activity,
  readiness,
  hrv,
  stress,
  recovery,
}

/// Health score model
class HealthScore {
  final HealthCategory category;
  final double score; // 0-100
  final double? change; // Change from previous period
  final String? insight;
  final DateTime timestamp;

  const HealthScore({
    required this.category,
    required this.score,
    this.change,
    this.insight,
    required this.timestamp,
  });

  /// Score color
  Color get scoreColor {
    if (score >= 80) return TacticalColors.operational;
    if (score >= 60) return TacticalColors.complete;
    if (score >= 40) return TacticalColors.inProgress;
    return TacticalColors.critical;
  }

  /// Score label
  String get scoreLabel {
    if (score >= 80) return 'OPTIMAL';
    if (score >= 60) return 'GOOD';
    if (score >= 40) return 'FAIR';
    return 'LOW';
  }

  /// Category icon
  IconData get icon {
    switch (category) {
      case HealthCategory.sleep:
        return Icons.bedtime;
      case HealthCategory.activity:
        return Icons.directions_run;
      case HealthCategory.readiness:
        return Icons.battery_full;
      case HealthCategory.hrv:
        return Icons.favorite;
      case HealthCategory.stress:
        return Icons.psychology;
      case HealthCategory.recovery:
        return Icons.healing;
    }
  }

  /// Category label
  String get categoryLabel {
    switch (category) {
      case HealthCategory.sleep:
        return 'SLEEP';
      case HealthCategory.activity:
        return 'ACTIVITY';
      case HealthCategory.readiness:
        return 'READINESS';
      case HealthCategory.hrv:
        return 'HRV';
      case HealthCategory.stress:
        return 'STRESS';
      case HealthCategory.recovery:
        return 'RECOVERY';
    }
  }

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      category: HealthCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HealthCategory.readiness,
      ),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      change: (json['change'] as num?)?.toDouble(),
      insight: json['insight'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

/// Health metric model
class HealthMetric {
  final String name;
  final String value;
  final String? unit;
  final String? trend; // up, down, stable
  final IconData icon;

  const HealthMetric({
    required this.name,
    required this.value,
    this.unit,
    this.trend,
    required this.icon,
  });

  /// Trend icon
  IconData get trendIcon {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  /// Trend color
  Color get trendColor {
    switch (trend) {
      case 'up':
        return TacticalColors.operational;
      case 'down':
        return TacticalColors.critical;
      default:
        return TacticalColors.textMuted;
    }
  }
}

/// Health alert model
class HealthAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  const HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    this.severity = AlertSeverity.info,
    required this.timestamp,
    this.isRead = false,
  });

  /// Severity color
  Color get severityColor {
    switch (severity) {
      case AlertSeverity.critical:
        return TacticalColors.critical;
      case AlertSeverity.warning:
        return TacticalColors.inProgress;
      case AlertSeverity.info:
        return TacticalColors.complete;
      case AlertSeverity.success:
        return TacticalColors.operational;
    }
  }

  /// Severity icon
  IconData get severityIcon {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.info:
        return Icons.info;
      case AlertSeverity.success:
        return Icons.check_circle;
    }
  }

  /// Relative time
  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      severity: AlertSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

/// Alert severity
enum AlertSeverity {
  critical,
  warning,
  info,
  success,
}

/// Mood entry for health logging
class MoodEntry {
  final String id;
  final int mood; // 1-5
  final int energy; // 1-5
  final int stress; // 1-5
  final String? note;
  final DateTime timestamp;
  final List<String> tags;

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.energy,
    required this.stress,
    this.note,
    required this.timestamp,
    this.tags = const [],
  });

  /// Mood emoji
  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  /// Energy level text
  String get energyText {
    switch (energy) {
      case 1:
        return 'Exhausted';
      case 2:
        return 'Low';
      case 3:
        return 'Normal';
      case 4:
        return 'Good';
      case 5:
        return 'High';
      default:
        return 'Normal';
    }
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String? ?? '',
      mood: json['mood'] as int? ?? 3,
      energy: json['energy'] as int? ?? 3,
      stress: json['stress'] as int? ?? 3,
      note: json['note'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Health correlation model
class HealthCorrelation {
  final String factor1;
  final String factor2;
  final double correlation; // -1 to 1
  final String insight;

  const HealthCorrelation({
    required this.factor1,
    required this.factor2,
    required this.correlation,
    required this.insight,
  });

  /// Correlation strength
  String get strength {
    final abs = correlation.abs();
    if (abs >= 0.7) return 'Strong';
    if (abs >= 0.4) return 'Moderate';
    return 'Weak';
  }

  /// Correlation direction
  String get direction => correlation >= 0 ? 'Positive' : 'Negative';

  /// Correlation color
  Color get color {
    if (correlation >= 0.4) return TacticalColors.operational;
    if (correlation >= 0) return TacticalColors.complete;
    if (correlation >= -0.4) return TacticalColors.inProgress;
    return TacticalColors.critical;
  }
}
