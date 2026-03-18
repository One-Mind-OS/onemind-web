/// Evaluation Models for Agent/Team Testing
///
/// Represents evaluation runs for testing agent/team performance.
/// These models map to AgentOS native evaluation schemas.
library;

class EvaluationRunModel {
  final String? id;
  final String? agentId;
  final String? teamId;
  final String status; // 'running', 'completed', 'failed', 'pending'
  final Map<String, dynamic>? criteria;
  final double? score;
  final String? feedback;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? results;

  EvaluationRunModel({
    this.id,
    this.agentId,
    this.teamId,
    required this.status,
    this.criteria,
    this.score,
    this.feedback,
    required this.createdAt,
    this.completedAt,
    this.results,
  });

  factory EvaluationRunModel.fromJson(Map<String, dynamic> json) {
    return EvaluationRunModel(
      id: json['id'] as String?,
      agentId: json['agent_id'] as String?,
      teamId: json['team_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      criteria: json['criteria'] as Map<String, dynamic>?,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      results: json['results'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (agentId != null) 'agent_id': agentId,
      if (teamId != null) 'team_id': teamId,
      'status': status,
      if (criteria != null) 'criteria': criteria,
      if (score != null) 'score': score,
      if (feedback != null) 'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (results != null) 'results': results,
    };
  }

  EvaluationRunModel copyWith({
    String? id,
    String? agentId,
    String? teamId,
    String? status,
    Map<String, dynamic>? criteria,
    double? score,
    String? feedback,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? results,
  }) {
    return EvaluationRunModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      teamId: teamId ?? this.teamId,
      status: status ?? this.status,
      criteria: criteria ?? this.criteria,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      results: results ?? this.results,
    );
  }

  // Helper: Get duration of the evaluation
  String get durationString {
    if (completedAt == null) {
      final now = DateTime.now();
      final duration = now.difference(createdAt);
      return '${duration.inSeconds}s (ongoing)';
    }
    final duration = completedAt!.difference(createdAt);
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
    return '${duration.inSeconds}s';
  }

  // Helper: Get score as percentage
  String get scorePercentage {
    if (score == null) return 'N/A';
    return '${(score! * 100).toStringAsFixed(1)}%';
  }

  // Helper: Check if evaluation is complete
  bool get isCompleted => status == 'completed' || status == 'failed';

  // Helper: Check if evaluation is active
  bool get isActive => status == 'running' || status == 'pending';

  // Helper: Get target name (agent or team)
  String get targetName {
    if (agentId != null) return 'Agent: $agentId';
    if (teamId != null) return 'Team: $teamId';
    return 'Unknown';
  }
}

class EvaluationResult {
  final String runId;
  final double accuracy;
  final double relevance;
  final double completeness;
  final String feedback;
  final Map<String, dynamic>? metadata;

  EvaluationResult({
    required this.runId,
    required this.accuracy,
    required this.relevance,
    required this.completeness,
    required this.feedback,
    this.metadata,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      runId: json['run_id'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      relevance: (json['relevance'] as num).toDouble(),
      completeness: (json['completeness'] as num).toDouble(),
      feedback: json['feedback'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'run_id': runId,
      'accuracy': accuracy,
      'relevance': relevance,
      'completeness': completeness,
      'feedback': feedback,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Helper: Get overall score
  double get overallScore => (accuracy + relevance + completeness) / 3;

  // Helper: Get overall score as percentage
  String get overallScorePercentage =>
      '${(overallScore * 100).toStringAsFixed(1)}%';
}
