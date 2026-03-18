/// Analytics Models
/// ==================
/// Data models for analytics dashboard in OneMind OS v2.
library;

/// Overview statistics for dashboard
class AnalyticsOverview {
  final int totalAgents;
  final int totalTeams;
  final int totalSessions;
  final int totalRuns;
  final int totalMessages;
  final int totalMemories;
  final int totalKnowledgeBases;
  final int totalDocuments;
  final double totalCostUsd;
  final int totalInputTokens;
  final int totalOutputTokens;
  final double avgResponseTimeMs;
  final double? sessionsChange;
  final double? messagesChange;
  final int? periodDays;
  final String generatedAt;

  AnalyticsOverview({
    required this.totalAgents,
    required this.totalTeams,
    required this.totalSessions,
    required this.totalRuns,
    required this.totalMessages,
    required this.totalMemories,
    required this.totalKnowledgeBases,
    required this.totalDocuments,
    required this.totalCostUsd,
    required this.totalInputTokens,
    required this.totalOutputTokens,
    required this.avgResponseTimeMs,
    this.sessionsChange,
    this.messagesChange,
    this.periodDays,
    required this.generatedAt,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      totalAgents: json['total_agents'] ?? 0,
      totalTeams: json['total_teams'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      totalRuns: json['total_runs'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      totalMemories: json['total_memories'] ?? 0,
      totalKnowledgeBases: json['total_knowledge_bases'] ?? 0,
      totalDocuments: json['total_documents'] ?? 0,
      totalCostUsd: (json['total_cost_usd'] ?? 0.0).toDouble(),
      totalInputTokens: json['total_input_tokens'] ?? 0,
      totalOutputTokens: json['total_output_tokens'] ?? 0,
      avgResponseTimeMs: (json['avg_response_time_ms'] ?? 0.0).toDouble(),
      sessionsChange: json['sessions_change']?.toDouble(),
      messagesChange: json['messages_change']?.toDouble(),
      periodDays: json['period_days'],
      generatedAt: json['generated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  int get totalTokens => totalInputTokens + totalOutputTokens;
}

/// Per-agent usage statistics
class AgentStats {
  final String agentId;
  final String agentName;
  final String? description;
  final String modelName;
  final int runCount;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final double costUsd;
  final double avgResponseTimeMs;

  AgentStats({
    required this.agentId,
    required this.agentName,
    this.description,
    required this.modelName,
    required this.runCount,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.costUsd,
    required this.avgResponseTimeMs,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      description: json['description'],
      modelName: json['model_name'] ?? '',
      runCount: json['run_count'] ?? 0,
      inputTokens: json['input_tokens'] ?? 0,
      outputTokens: json['output_tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
      costUsd: (json['cost_usd'] ?? 0.0).toDouble(),
      avgResponseTimeMs: (json['avg_response_time_ms'] ?? 0.0).toDouble(),
    );
  }
}

/// Session analytics
class SessionStats {
  final int totalSessions;
  final int totalMessages;
  final double avgSessionLength;
  final List<TopSession> topSessions;

  SessionStats({
    required this.totalSessions,
    required this.totalMessages,
    required this.avgSessionLength,
    required this.topSessions,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      totalSessions: json['total_sessions'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      avgSessionLength: (json['avg_session_length'] ?? 0.0).toDouble(),
      topSessions: (json['top_sessions'] as List<dynamic>?)
              ?.map((e) => TopSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Top session data
class TopSession {
  final String sessionId;
  final int messageCount;
  final String? startedAt;
  final String? lastActive;

  TopSession({
    required this.sessionId,
    required this.messageCount,
    this.startedAt,
    this.lastActive,
  });

  factory TopSession.fromJson(Map<String, dynamic> json) {
    return TopSession(
      sessionId: json['session_id'] ?? '',
      messageCount: json['message_count'] ?? 0,
      startedAt: json['started_at'],
      lastActive: json['last_active'],
    );
  }
}

/// Memory statistics
class MemoryStats {
  final int totalMemories;
  final List<MemoryByAgent> memoriesByAgent;
  final List<MemoryGrowthPoint> memoryGrowth;

  MemoryStats({
    required this.totalMemories,
    required this.memoriesByAgent,
    required this.memoryGrowth,
  });

  factory MemoryStats.fromJson(Map<String, dynamic> json) {
    return MemoryStats(
      totalMemories: json['total_memories'] ?? 0,
      memoriesByAgent: (json['memories_by_agent'] as List<dynamic>?)
              ?.map((e) => MemoryByAgent.fromJson(e))
              .toList() ??
          [],
      memoryGrowth: (json['memory_growth'] as List<dynamic>?)
              ?.map((e) => MemoryGrowthPoint.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Memory count by agent
class MemoryByAgent {
  final String agentName;
  final int memoryCount;

  MemoryByAgent({
    required this.agentName,
    required this.memoryCount,
  });

  factory MemoryByAgent.fromJson(Map<String, dynamic> json) {
    return MemoryByAgent(
      agentName: json['agent_name'] ?? '',
      memoryCount: json['memory_count'] ?? 0,
    );
  }
}

/// Memory growth data point
class MemoryGrowthPoint {
  final String date;
  final int count;

  MemoryGrowthPoint({
    required this.date,
    required this.count,
  });

  factory MemoryGrowthPoint.fromJson(Map<String, dynamic> json) {
    return MemoryGrowthPoint(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

/// Workflow execution statistics
class WorkflowStats {
  final int totalWorkflows;
  final int totalExecutions;
  final double successRate;
  final double avgExecutionTimeMs;
  final List<dynamic> workflows;

  WorkflowStats({
    required this.totalWorkflows,
    required this.totalExecutions,
    required this.successRate,
    required this.avgExecutionTimeMs,
    required this.workflows,
  });

  factory WorkflowStats.fromJson(Map<String, dynamic> json) {
    return WorkflowStats(
      totalWorkflows: json['total_workflows'] ?? 0,
      totalExecutions: json['total_executions'] ?? 0,
      successRate: (json['success_rate'] ?? 0.0).toDouble(),
      avgExecutionTimeMs: (json['avg_execution_time_ms'] ?? 0.0).toDouble(),
      workflows: json['workflows'] ?? [],
    );
  }
}

/// Cost breakdown by model
class CostBreakdown {
  final double totalCostUsd;
  final List<ModelCost> costByModel;

  CostBreakdown({
    required this.totalCostUsd,
    required this.costByModel,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      totalCostUsd: (json['total_cost_usd'] ?? 0.0).toDouble(),
      costByModel: (json['cost_by_model'] as List<dynamic>?)
              ?.map((e) => ModelCost.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Cost for a specific model
class ModelCost {
  final String modelName;
  final int runCount;
  final int inputTokens;
  final int outputTokens;
  final double costUsd;

  ModelCost({
    required this.modelName,
    required this.runCount,
    required this.inputTokens,
    required this.outputTokens,
    required this.costUsd,
  });

  factory ModelCost.fromJson(Map<String, dynamic> json) {
    return ModelCost(
      modelName: json['model_name'] ?? '',
      runCount: json['run_count'] ?? 0,
      inputTokens: json['input_tokens'] ?? 0,
      outputTokens: json['output_tokens'] ?? 0,
      costUsd: (json['cost_usd'] ?? 0.0).toDouble(),
    );
  }

  int get totalTokens => inputTokens + outputTokens;
}

/// Performance metrics with percentiles
class PerformanceMetrics {
  final double p50Ms;
  final double p90Ms;
  final double p99Ms;
  final double avgResponseTimeMs;
  final int totalRuns;

  PerformanceMetrics({
    required this.p50Ms,
    required this.p90Ms,
    required this.p99Ms,
    required this.avgResponseTimeMs,
    required this.totalRuns,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      p50Ms: (json['p50_ms'] ?? 0.0).toDouble(),
      p90Ms: (json['p90_ms'] ?? 0.0).toDouble(),
      p99Ms: (json['p99_ms'] ?? 0.0).toDouble(),
      avgResponseTimeMs: (json['avg_response_time_ms'] ?? 0.0).toDouble(),
      totalRuns: json['total_runs'] ?? 0,
    );
  }
}

/// Time series data point
class TimeSeriesDataPoint {
  final String date;
  final int? value;
  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;

  TimeSeriesDataPoint({
    required this.date,
    this.value,
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
  });

  factory TimeSeriesDataPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesDataPoint(
      date: json['date'] ?? '',
      value: json['value'],
      inputTokens: json['input_tokens'],
      outputTokens: json['output_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}
