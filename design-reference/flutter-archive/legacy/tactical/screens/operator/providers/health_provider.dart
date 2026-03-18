// Health provider for Operator Intel
// Connects to Oura, Apple Health, etc.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health.dart';

/// Health state
class HealthState {
  final List<HealthScore> scores;
  final List<HealthMetric> metrics;
  final List<HealthAlert> alerts;
  final List<MoodEntry> moodLog;
  final List<HealthCorrelation> correlations;
  final bool isLoading;
  final String? error;

  const HealthState({
    this.scores = const [],
    this.metrics = const [],
    this.alerts = const [],
    this.moodLog = const [],
    this.correlations = const [],
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({
    List<HealthScore>? scores,
    List<HealthMetric>? metrics,
    List<HealthAlert>? alerts,
    List<MoodEntry>? moodLog,
    List<HealthCorrelation>? correlations,
    bool? isLoading,
    String? error,
  }) {
    return HealthState(
      scores: scores ?? this.scores,
      metrics: metrics ?? this.metrics,
      alerts: alerts ?? this.alerts,
      moodLog: moodLog ?? this.moodLog,
      correlations: correlations ?? this.correlations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Overall score (average)
  double get overallScore {
    if (scores.isEmpty) return 0;
    return scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
  }

  /// Unread alerts count
  int get unreadAlertsCount => alerts.where((a) => !a.isRead).length;

  /// Critical alerts count
  int get criticalAlertsCount =>
      alerts.where((a) => a.severity == AlertSeverity.critical).length;

  /// Recent mood entries (last 7 days)
  List<MoodEntry> get recentMoodLog {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return moodLog.where((m) => m.timestamp.isAfter(weekAgo)).toList();
  }

  /// Average mood (recent)
  double get averageMood {
    if (recentMoodLog.isEmpty) return 0;
    return recentMoodLog.map((m) => m.mood).reduce((a, b) => a + b) /
        recentMoodLog.length;
  }
}

/// Health notifier - placeholder for API integration
class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier() : super(const HealthState()) {
    _init();
  }

  void _init() {
    // Initialize with empty state - ready for health API connections
    state = const HealthState(
      scores: [],
      metrics: [],
      alerts: [],
      moodLog: [],
      correlations: [],
      isLoading: false,
    );
  }

  /// Refresh all health data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    // TODO: Connect to Oura, Apple Health APIs
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      isLoading: false,
      error: null,
    );
  }

  /// Log mood entry
  Future<void> logMood({
    required int mood,
    required int energy,
    required int stress,
    String? note,
    List<String> tags = const [],
  }) async {
    // TODO: Save to backend
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: mood,
      energy: energy,
      stress: stress,
      note: note,
      timestamp: DateTime.now(),
      tags: tags,
    );

    state = state.copyWith(
      moodLog: [entry, ...state.moodLog],
    );
  }

  /// Mark alert as read
  void markAlertRead(String alertId) {
    final alerts = state.alerts.map((a) {
      if (a.id == alertId) {
        return HealthAlert(
          id: a.id,
          title: a.title,
          message: a.message,
          severity: a.severity,
          timestamp: a.timestamp,
          isRead: true,
        );
      }
      return a;
    }).toList();

    state = state.copyWith(alerts: alerts);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for health state
final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier();
});

/// Provider for health scores
final healthScoresProvider = Provider<List<HealthScore>>((ref) {
  return ref.watch(healthProvider).scores;
});

/// Provider for health alerts
final healthAlertsProvider = Provider<List<HealthAlert>>((ref) {
  return ref.watch(healthProvider).alerts;
});

/// Provider for mood log
final moodLogProvider = Provider<List<MoodEntry>>((ref) {
  return ref.watch(healthProvider).moodLog;
});

/// Provider for correlations
final healthCorrelationsProvider = Provider<List<HealthCorrelation>>((ref) {
  return ref.watch(healthProvider).correlations;
});

/// Provider for overall score
final overallHealthScoreProvider = Provider<double>((ref) {
  return ref.watch(healthProvider).overallScore;
});
