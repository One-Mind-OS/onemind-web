// Metrics Screen - Tactical Design
// System metrics, agent performance, and cost tracking
// Backend: GET /api/metrics/summary, GET /api/metrics/agents, GET /api/metrics/usage

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../providers/metrics_provider.dart';
import '../widgets/charts.dart';
import '../widgets/cost_breakdown.dart';

class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _formatLatency(double ms) {
    if (ms >= 1000) return '${(ms / 1000).toStringAsFixed(1)}s';
    return '${ms.toStringAsFixed(0)}ms';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsState = ref.watch(metricsProvider);
    final summary = metricsState.summary;

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('METRICS', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(metricsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: metricsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            )
          : metricsState.error != null
              ? _buildErrorState(ref, metricsState.error!)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryGrid(summary),
                      const SizedBox(height: 16),

                      // System Status
                      _buildSystemStatus(summary),
                      const SizedBox(height: 24),

                      // Agent Performance
                      _buildSectionHeader('AGENT PERFORMANCE', Icons.smart_toy),
                      const SizedBox(height: 12),
                      _buildAgentMetrics(metricsState),
                      const SizedBox(height: 24),

                      // Trends
                      if (metricsState.requestsOverTime.isNotEmpty ||
                          metricsState.tokensByAgent.isNotEmpty) ...[
                        _buildSectionHeader('TRENDS', Icons.trending_up),
                        const SizedBox(height: 12),
                        _buildTrendsSection(metricsState, summary),
                        const SizedBox(height: 24),
                      ],

                      // Top Performers
                      if (summary?.fastestAgent != null ||
                          summary?.mostActiveAgent != null) ...[
                        _buildSectionHeader('TOP PERFORMERS', Icons.star),
                        const SizedBox(height: 12),
                        _buildTopPerformers(summary),
                        const SizedBox(height: 24),
                      ],

                      // Error Rate
                      _buildErrorRateCard(summary),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: TacticalColors.critical.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'FAILED TO LOAD METRICS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ref.read(metricsProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: TacticalColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: TacticalColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(MetricsSummary? summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'REQUESTS/HR',
                value: summary?.totalRequestsHour.toString() ?? '0',
                subtitle: '${summary?.avgRequestsPerMinute.toStringAsFixed(1) ?? 0}/min',
                icon: Icons.play_circle,
                color: TacticalColors.primary,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                title: 'TOKENS TODAY',
                value: _formatNumber(summary?.totalTokensToday ?? 0),
                subtitle: 'all agents',
                icon: Icons.token,
                color: TacticalColors.complete,
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'EST. COST',
                value: '\$${summary?.estimatedCostToday.toStringAsFixed(2) ?? '0.00'}',
                subtitle: 'today',
                icon: Icons.attach_money,
                color: TacticalColors.inProgress,
                isPositive: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                title: 'AVG LATENCY',
                value: _formatLatency(summary?.avgLatencyMs ?? 0),
                subtitle: 'P95: ${_formatLatency(summary?.p95LatencyMs ?? 0)}',
                icon: Icons.speed,
                color: (summary?.avgLatencyMs ?? 0) < 2000
                    ? TacticalColors.operational
                    : TacticalColors.critical,
                isPositive: (summary?.avgLatencyMs ?? 0) < 2000,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemStatus(MetricsSummary? summary) {
    final isHealthy = summary?.systemStatus == 'healthy';
    final statusColor = isHealthy ? TacticalColors.operational : TacticalColors.inProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM: ${(summary?.systemStatus ?? 'unknown').toUpperCase()}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${summary?.activeAgents ?? 0}/${summary?.totalAgents ?? 0} agents active',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            color: statusColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAgentMetrics(MetricsState metricsState) {
    if (metricsState.agents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: TacticalDecoration.card,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.smart_toy,
                size: 48,
                color: TacticalColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'NO AGENT METRICS',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Metrics will appear after agents run',
                style: TextStyle(
                  color: TacticalColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: metricsState.agents.map((agent) => _AgentMetricsCard(
            name: agent.agentName,
            requests: agent.totalRequests,
            tokens: agent.totalTokens,
            latencyMs: agent.avgLatencyMs,
            errorRate: agent.errorRate,
            toolCalls: agent.toolCallsTotal,
          )).toList(),
    );
  }

  Widget _buildTrendsSection(MetricsState metricsState, MetricsSummary? summary) {
    return Column(
      children: [
        // Requests over time chart
        if (metricsState.requestsOverTime.isNotEmpty)
          SizedBox(
            height: 220,
            child: RequestsOverTimeChart(
              data: metricsState.requestsOverTime,
              title: 'Requests (Last 7 Days)',
            ),
          ),

        if (metricsState.requestsOverTime.isNotEmpty &&
            metricsState.tokensByAgent.isNotEmpty)
          const SizedBox(height: 16),

        // Tokens by agent chart
        if (metricsState.tokensByAgent.isNotEmpty)
          SizedBox(
            height: 200,
            child: TokensByAgentChart(
              data: metricsState.tokensByAgent,
              title: 'Token Usage by Agent',
            ),
          ),

        // Latency percentiles chart
        if (summary != null && summary.avgLatencyMs > 0) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LatencyPercentilesChart(
              p50: summary.avgLatencyMs,
              p95: summary.p95LatencyMs,
              p99: metricsState.p99LatencyMs ?? summary.p95LatencyMs * 1.2,
              title: 'Latency Distribution',
            ),
          ),
        ],

        // Cost breakdown pie chart
        if (metricsState.tokensByAgent.isNotEmpty) ...[
          const SizedBox(height: 16),
          CostBreakdownChart(
            data: metricsState.tokensByAgent,
            title: 'Cost Breakdown by Agent',
            totalCost: summary?.estimatedCostToday,
          ),
        ],
      ],
    );
  }

  Widget _buildTopPerformers(MetricsSummary? summary) {
    return Row(
      children: [
        if (summary?.fastestAgent != null)
          Expanded(
            child: _TopPerformerCard(
              title: 'FASTEST',
              value: summary!.fastestAgent!,
              icon: Icons.flash_on,
            ),
          ),
        if (summary?.fastestAgent != null && summary?.mostActiveAgent != null)
          const SizedBox(width: 8),
        if (summary?.mostActiveAgent != null)
          Expanded(
            child: _TopPerformerCard(
              title: 'MOST ACTIVE',
              value: summary!.mostActiveAgent!,
              icon: Icons.trending_up,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorRateCard(MetricsSummary? summary) {
    final errorRate = summary?.errorRate ?? 0;
    final isHighError = errorRate > 0.05;
    final statusColor = isHighError ? TacticalColors.critical : TacticalColors.operational;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ERROR RATE',
              style: TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(errorRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: TacticalColors.textMuted),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isPositive ? TacticalColors.operational : TacticalColors.critical,
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isPositive ? TacticalColors.operational : TacticalColors.critical,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentMetricsCard extends StatelessWidget {
  final String name;
  final int requests;
  final int tokens;
  final double latencyMs;
  final double errorRate;
  final int toolCalls;

  const _AgentMetricsCard({
    required this.name,
    required this.requests,
    required this.tokens,
    required this.latencyMs,
    required this.errorRate,
    required this.toolCalls,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = errorRate < 0.05;
    final statusColor = isHealthy ? TacticalColors.operational : TacticalColors.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TacticalColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: TacticalColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TacticalColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(errorRate * 100).toStringAsFixed(0)}% ERR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricChip(label: '$requests runs', icon: Icons.play_arrow),
              const SizedBox(width: 8),
              _MetricChip(
                label: '${(tokens / 1000).toStringAsFixed(0)}K tok',
                icon: Icons.token,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: '${latencyMs.toStringAsFixed(0)}ms',
                icon: Icons.timer,
              ),
              const SizedBox(width: 8),
              _MetricChip(label: '$toolCalls tools', icon: Icons.build),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MetricChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: TacticalColors.textDim),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _TopPerformerCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TopPerformerCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: TacticalColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
