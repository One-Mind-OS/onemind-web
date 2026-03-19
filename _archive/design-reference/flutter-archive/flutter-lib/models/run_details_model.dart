/// Detailed agent run information for monitoring and debugging
class RunDetails {
  final String runId;
  final String agentId;
  final String agentName;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<RunStep> steps;
  final int totalInputTokens;
  final int totalOutputTokens;
  final double? cost;
  final String? error;

  RunDetails({
    required this.runId,
    required this.agentId,
    required this.agentName,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.steps,
    required this.totalInputTokens,
    required this.totalOutputTokens,
    this.cost,
    this.error,
  });

  /// Calculate total tokens
  int get totalTokens => totalInputTokens + totalOutputTokens;

  /// Calculate duration
  Duration get duration {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Check if run is complete
  bool get isComplete => completedAt != null;

  /// Check if run had errors
  bool get hasError => error != null || status.toLowerCase() == 'error';

  /// Factory from JSON
  factory RunDetails.fromJson(Map<String, dynamic> json) {
    return RunDetails(
      runId: json['run_id'] ?? json['id'] ?? '',
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? 'Unknown',
      status: json['status'] ?? 'unknown',
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => RunStep.fromJson(s))
              .toList() ??
          [],
      totalInputTokens: json['total_input_tokens'] ?? 0,
      totalOutputTokens: json['total_output_tokens'] ?? 0,
      cost: json['cost']?.toDouble(),
      error: json['error'],
    );
  }
}

/// Individual step in agent execution
class RunStep {
  final int stepNumber;
  final String type; // 'tool_call', 'reasoning', 'response', 'system'
  final String? toolName;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final int inputTokens;
  final int outputTokens;
  final DateTime timestamp;
  final Duration duration;
  final String? status;

  RunStep({
    required this.stepNumber,
    required this.type,
    this.toolName,
    this.input,
    this.output,
    required this.inputTokens,
    required this.outputTokens,
    required this.timestamp,
    required this.duration,
    this.status,
  });

  /// Get total tokens for this step
  int get totalTokens => inputTokens + outputTokens;

  /// Get display icon for step type
  String get icon {
    switch (type.toLowerCase()) {
      case 'tool_call':
        return '🔧';
      case 'reasoning':
        return '🧠';
      case 'response':
        return '💬';
      case 'system':
        return '⚙️';
      default:
        return '📌';
    }
  }

  /// Factory from JSON
  factory RunStep.fromJson(Map<String, dynamic> json) {
    return RunStep(
      stepNumber: json['step_number'] ?? 0,
      type: json['type'] ?? 'unknown',
      toolName: json['tool_name'],
      input: json['input'] as Map<String, dynamic>?,
      output: json['output'] as Map<String, dynamic>?,
      inputTokens: json['input_tokens'] ?? 0,
      outputTokens: json['output_tokens'] ?? 0,
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      duration: Duration(milliseconds: json['duration_ms'] ?? 0),
      status: json['status'],
    );
  }
}

/// Token usage statistics
class TokenUsageStats {
  final int inputTokens;
  final int outputTokens;
  final String category; // 'reasoning', 'tools', 'response'

  TokenUsageStats({
    required this.inputTokens,
    required this.outputTokens,
    required this.category,
  });

  int get totalTokens => inputTokens + outputTokens;
}
