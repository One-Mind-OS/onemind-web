// OMOS-194: Agent Metrics Dashboard Provider
// OMOS-238: Extended with time-series chart data
// Provides real-time metrics data from backend API

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/api/agno_client.dart';
import '../../../platform/providers/app_providers.dart';
import '../widgets/charts.dart';

/// Dashboard summary state
class MetricsSummary {
  final String systemStatus;
  final int activeAgents;
  final int totalAgents;
  final int totalRequestsToday;
  final int totalRequestsHour;
  final double avgRequestsPerMinute;
  final double avgLatencyMs;
  final double p95LatencyMs;
  final int totalTokensToday;
  final double estimatedCostToday;
  final double errorRate;
  final int recentErrors;
  final String? fastestAgent;
  final String? mostActiveAgent;
  final String updatedAt;

  MetricsSummary({
    this.systemStatus = 'healthy',
    this.activeAgents = 0,
    this.totalAgents = 0,
    this.totalRequestsToday = 0,
    this.totalRequestsHour = 0,
    this.avgRequestsPerMinute = 0.0,
    this.avgLatencyMs = 0.0,
    this.p95LatencyMs = 0.0,
    this.totalTokensToday = 0,
    this.estimatedCostToday = 0.0,
    this.errorRate = 0.0,
    this.recentErrors = 0,
    this.fastestAgent,
    this.mostActiveAgent,
    this.updatedAt = '',
  });

  factory MetricsSummary.fromJson(Map<String, dynamic> json) {
    return MetricsSummary(
      systemStatus: json['system_status'] ?? 'healthy',
      activeAgents: json['active_agents'] ?? 0,
      totalAgents: json['total_agents'] ?? 0,
      totalRequestsToday: json['total_requests_today'] ?? 0,
      totalRequestsHour: json['total_requests_hour'] ?? 0,
      avgRequestsPerMinute: (json['avg_requests_per_minute'] ?? 0.0).toDouble(),
      avgLatencyMs: (json['avg_latency_ms'] ?? 0.0).toDouble(),
      p95LatencyMs: (json['p95_latency_ms'] ?? 0.0).toDouble(),
      totalTokensToday: json['total_tokens_today'] ?? 0,
      estimatedCostToday: (json['estimated_cost_today'] ?? 0.0).toDouble(),
      errorRate: (json['error_rate'] ?? 0.0).toDouble(),
      recentErrors: json['recent_errors'] ?? 0,
      fastestAgent: json['fastest_agent'],
      mostActiveAgent: json['most_active_agent'],
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

/// Agent metrics state
class AgentMetrics {
  final String agentId;
  final String agentName;
  final int totalRequests;
  final int requestsToday;
  final double avgLatencyMs;
  final double p95LatencyMs;
  final int totalTokens;
  final double errorRate;
  final int toolCallsTotal;
  final String? lastRequestAt;

  AgentMetrics({
    required this.agentId,
    required this.agentName,
    this.totalRequests = 0,
    this.requestsToday = 0,
    this.avgLatencyMs = 0.0,
    this.p95LatencyMs = 0.0,
    this.totalTokens = 0,
    this.errorRate = 0.0,
    this.toolCallsTotal = 0,
    this.lastRequestAt,
  });

  factory AgentMetrics.fromJson(Map<String, dynamic> json) {
    return AgentMetrics(
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      totalRequests: json['total_requests'] ?? 0,
      requestsToday: json['requests_today'] ?? 0,
      avgLatencyMs: (json['avg_latency_ms'] ?? 0.0).toDouble(),
      p95LatencyMs: (json['p95_latency_ms'] ?? 0.0).toDouble(),
      totalTokens: json['total_tokens'] ?? 0,
      errorRate: (json['error_rate'] ?? 0.0).toDouble(),
      toolCallsTotal: json['tool_calls_total'] ?? 0,
      lastRequestAt: json['last_request_at'],
    );
  }
}

/// Full metrics state
class MetricsState {
  final MetricsSummary? summary;
  final List<AgentMetrics> agents;
  final bool isLoading;
  final String? error;

  // OMOS-238: Chart data
  final List<ChartDataPoint> requestsOverTime;
  final List<AgentTokenData> tokensByAgent;
  final double? p99LatencyMs;

  MetricsState({
    this.summary,
    this.agents = const [],
    this.isLoading = false,
    this.error,
    this.requestsOverTime = const [],
    this.tokensByAgent = const [],
    this.p99LatencyMs,
  });

  MetricsState copyWith({
    MetricsSummary? summary,
    List<AgentMetrics>? agents,
    bool? isLoading,
    String? error,
    List<ChartDataPoint>? requestsOverTime,
    List<AgentTokenData>? tokensByAgent,
    double? p99LatencyMs,
  }) {
    return MetricsState(
      summary: summary ?? this.summary,
      agents: agents ?? this.agents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      requestsOverTime: requestsOverTime ?? this.requestsOverTime,
      tokensByAgent: tokensByAgent ?? this.tokensByAgent,
      p99LatencyMs: p99LatencyMs ?? this.p99LatencyMs,
    );
  }
}

/// Metrics notifier
class MetricsNotifier extends StateNotifier<MetricsState> {
  final AgnoClient _client;

  MetricsNotifier(this._client) : super(MetricsState()) {
    fetchMetrics();
  }

  Future<void> fetchMetrics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch summary
      final summaryData = await _client.getMetricsSummary();
      MetricsSummary? summary;
      if (summaryData != null) {
        summary = MetricsSummary.fromJson(summaryData);
      }

      // Fetch all agent metrics
      final agentsData = await _client.getAllAgentMetrics();
      List<AgentMetrics> agents = [];
      if (agentsData != null && agentsData['agents'] is List) {
        agents = (agentsData['agents'] as List)
            .map((a) => AgentMetrics.fromJson(a))
            .toList();
      }

      // OMOS-238: Fetch usage metrics for charts
      List<ChartDataPoint> requestsOverTime = [];
      List<AgentTokenData> tokensByAgent = [];
      double? p99LatencyMs;

      try {
        final usageData = await _client.getUsageMetrics(days: 7);
        if (usageData != null) {
          // Parse requests over time
          if (usageData['usage_by_day'] is List) {
            requestsOverTime = (usageData['usage_by_day'] as List)
                .map((d) => ChartDataPoint(
                      timestamp: DateTime.parse(d['date'] as String),
                      value: (d['sessions'] ?? d['requests'] ?? 0).toDouble(),
                    ))
                .toList();
          }

          // Parse tokens by agent from agent metrics
          tokensByAgent = agents
              .map((a) => AgentTokenData(
                    agentId: a.agentId,
                    agentName: a.agentName,
                    inputTokens: (a.totalTokens * 0.4).toInt(), // Estimate input
                    outputTokens: (a.totalTokens * 0.6).toInt(), // Estimate output
                  ))
              .toList();

          // Get P99 latency if available
          p99LatencyMs = (usageData['p99_latency_ms'] ?? summary?.p95LatencyMs)?.toDouble();
        }
      } catch (e) {
        // Chart data is optional, don't fail the whole request
        // Just use empty data
      }

      state = MetricsState(
        summary: summary,
        agents: agents,
        isLoading: false,
        requestsOverTime: requestsOverTime,
        tokensByAgent: tokensByAgent,
        p99LatencyMs: p99LatencyMs,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load metrics: $e',
      );
    }
  }

  void refresh() {
    fetchMetrics();
  }
}

/// Provider for metrics state
final metricsProvider = StateNotifierProvider<MetricsNotifier, MetricsState>((ref) {
  final client = ref.watch(agnoClientProvider);
  return MetricsNotifier(client);
});
