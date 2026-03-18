/// Run Models for Agent/Team/Workflow Execution
///
/// Represents the execution state and results of agents, teams, and workflows.
/// These models map to AgentOS native run schemas.
library;

class AgentRunModel {
  final String? runId;
  final String agentId;
  final String status; // 'running', 'completed', 'failed', 'paused', 'cancelled'
  final String? sessionId;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final String? error;
  final int? inputTokens;
  final int? outputTokens;
  final DateTime createdAt;
  final DateTime? completedAt;

  AgentRunModel({
    this.runId,
    required this.agentId,
    required this.status,
    this.sessionId,
    this.input,
    this.output,
    this.error,
    this.inputTokens,
    this.outputTokens,
    required this.createdAt,
    this.completedAt,
  });

  factory AgentRunModel.fromJson(Map<String, dynamic> json) {
    return AgentRunModel(
      runId: json['run_id'] as String?,
      agentId: json['agent_id'] as String,
      status: json['status'] as String? ?? 'unknown',
      sessionId: json['session_id'] as String?,
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (runId != null) 'run_id': runId,
      'agent_id': agentId,
      'status': status,
      if (sessionId != null) 'session_id': sessionId,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (error != null) 'error': error,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  AgentRunModel copyWith({
    String? runId,
    String? agentId,
    String? status,
    String? sessionId,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? error,
    int? inputTokens,
    int? outputTokens,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return AgentRunModel(
      runId: runId ?? this.runId,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      input: input ?? this.input,
      output: output ?? this.output,
      error: error ?? this.error,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper: Get duration of the run
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

  // Helper: Get total tokens used
  int get totalTokens => (inputTokens ?? 0) + (outputTokens ?? 0);

  // Helper: Check if run is complete
  bool get isCompleted =>
      status == 'completed' || status == 'failed' || status == 'cancelled';

  // Helper: Check if run is active
  bool get isActive => status == 'running' || status == 'paused';
}

class TeamRunModel {
  final String? runId;
  final String teamId;
  final String status; // 'running', 'completed', 'failed', 'paused', 'cancelled'
  final String? sessionId;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final String? error;
  final int? inputTokens;
  final int? outputTokens;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<AgentRunModel>? agentRuns; // Individual agent runs within the team

  TeamRunModel({
    this.runId,
    required this.teamId,
    required this.status,
    this.sessionId,
    this.input,
    this.output,
    this.error,
    this.inputTokens,
    this.outputTokens,
    required this.createdAt,
    this.completedAt,
    this.agentRuns,
  });

  factory TeamRunModel.fromJson(Map<String, dynamic> json) {
    return TeamRunModel(
      runId: json['run_id'] as String?,
      teamId: json['team_id'] as String,
      status: json['status'] as String? ?? 'unknown',
      sessionId: json['session_id'] as String?,
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      agentRuns: json['agent_runs'] != null
          ? (json['agent_runs'] as List)
              .map((run) => AgentRunModel.fromJson(run as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (runId != null) 'run_id': runId,
      'team_id': teamId,
      'status': status,
      if (sessionId != null) 'session_id': sessionId,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (error != null) 'error': error,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (agentRuns != null)
        'agent_runs': agentRuns!.map((run) => run.toJson()).toList(),
    };
  }

  TeamRunModel copyWith({
    String? runId,
    String? teamId,
    String? status,
    String? sessionId,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    String? error,
    int? inputTokens,
    int? outputTokens,
    DateTime? createdAt,
    DateTime? completedAt,
    List<AgentRunModel>? agentRuns,
  }) {
    return TeamRunModel(
      runId: runId ?? this.runId,
      teamId: teamId ?? this.teamId,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      input: input ?? this.input,
      output: output ?? this.output,
      error: error ?? this.error,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      agentRuns: agentRuns ?? this.agentRuns,
    );
  }

  // Helper: Get duration of the run
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

  // Helper: Get total tokens used
  int get totalTokens => (inputTokens ?? 0) + (outputTokens ?? 0);

  // Helper: Check if run is complete
  bool get isCompleted =>
      status == 'completed' || status == 'failed' || status == 'cancelled';

  // Helper: Check if run is active
  bool get isActive => status == 'running' || status == 'paused';
}

// Note: WorkflowRunModel is already defined in workflow_model.dart
// Import from there instead of duplicating here
