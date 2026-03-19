// OMOS-238: Metrics Time-Series Charts
// Uses fl_chart for visualizations
// Follows black/white/red color scheme

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/theme/tactical.dart';

// =============================================================================
// DATA MODELS
// =============================================================================

/// Data point for time-series charts
class ChartDataPoint {
  final DateTime timestamp;
  final double value;

  const ChartDataPoint({
    required this.timestamp,
    required this.value,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : json['timestamp'] as DateTime,
      value: (json['value'] ?? json['count'] ?? 0).toDouble(),
    );
  }
}

/// Token data per agent for bar charts
class AgentTokenData {
  final String agentId;
  final String agentName;
  final int inputTokens;
  final int outputTokens;

  const AgentTokenData({
    required this.agentId,
    required this.agentName,
    required this.inputTokens,
    required this.outputTokens,
  });

  int get totalTokens => inputTokens + outputTokens;

  factory AgentTokenData.fromJson(Map<String, dynamic> json) {
    return AgentTokenData(
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? json['agent_id'] ?? 'Unknown',
      inputTokens: json['input_tokens'] ?? json['tokens_input'] ?? 0,
      outputTokens: json['output_tokens'] ?? json['tokens_output'] ?? 0,
    );
  }
}

// =============================================================================
// REQUESTS OVER TIME CHART (Line Chart)
// =============================================================================

/// Line chart showing requests over time
class RequestsOverTimeChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String title;

  const RequestsOverTimeChart({
    super.key,
    required this.data,
    this.title = 'Requests Over Time',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 16, color: TacticalColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: TacticalColors.glassBorderLight,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value),
                          style: TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: (data.length / 5).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        final date = data[index].timestamp;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('M/d').format(date),
                            style: TextStyle(
                              color: TacticalColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY,
                maxY: maxY * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: TacticalColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: TacticalColors.primary,
                          strokeWidth: 1,
                          strokeColor: TacticalColors.textPrimary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TacticalColors.primary.withValues(alpha: 0.3),
                          TacticalColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: TacticalColors.card,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= data.length) return null;
                        final point = data[index];
                        return LineTooltipItem(
                          '${DateFormat('MMM d').format(point.timestamp)}\n${point.value.toInt()} requests',
                          TextStyle(
                            color: TacticalColors.textPrimary,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 32, color: TacticalColors.glassBorderLight),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(color: TacticalColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }
}

// =============================================================================
// TOKENS BY AGENT CHART (Bar Chart)
// =============================================================================

/// Horizontal bar chart showing token usage by agent
class TokensByAgentChart extends StatelessWidget {
  final List<AgentTokenData> data;
  final String title;

  const TokensByAgentChart({
    super.key,
    required this.data,
    this.title = 'Tokens by Agent',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final maxTokens = data.map((d) => d.totalTokens).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 16, color: TacticalColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxTokens * 1.1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: TacticalColors.card,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final agent = data[group.x.toInt()];
                      return BarTooltipItem(
                        '${agent.agentName}\n${_formatTokens(agent.totalTokens)} tokens',
                        TextStyle(color: TacticalColors.textPrimary, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatTokens(value.toInt()),
                          style: TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _truncateName(data[index].agentName, 10),
                            style: TextStyle(
                              color: TacticalColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxTokens > 0 ? maxTokens / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: TacticalColors.glassBorderLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final agent = entry.value;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: agent.inputTokens.toDouble(),
                        color: TacticalColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: agent.outputTokens.toDouble(),
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: TacticalColors.primary, label: 'Input'),
              const SizedBox(width: 16),
              _LegendItem(color: TacticalColors.primary.withValues(alpha: 0.5), label: 'Output'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 32, color: TacticalColors.glassBorderLight),
            const SizedBox(height: 8),
            Text(
              'No agent data available',
              style: TextStyle(color: TacticalColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTokens(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength - 2)}..';
  }
}

// =============================================================================
// LATENCY CHART (Bar Chart)
// =============================================================================

/// Bar chart showing latency percentiles
class LatencyPercentilesChart extends StatelessWidget {
  final double p50;
  final double p95;
  final double p99;
  final String title;

  const LatencyPercentilesChart({
    super.key,
    required this.p50,
    required this.p95,
    required this.p99,
    this.title = 'Latency Percentiles',
  });

  @override
  Widget build(BuildContext context) {
    final maxLatency = [p50, p95, p99].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 16, color: TacticalColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _LatencyBar(
                  label: 'P50',
                  value: p50,
                  maxValue: maxLatency,
                  color: TacticalColors.success,
                ),
                _LatencyBar(
                  label: 'P95',
                  value: p95,
                  maxValue: maxLatency,
                  color: TacticalColors.warning,
                ),
                _LatencyBar(
                  label: 'P99',
                  value: p99,
                  maxValue: maxLatency,
                  color: TacticalColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LatencyBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const _LatencyBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = maxValue > 0 ? (value / maxValue) : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _formatLatency(value),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 80 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: TacticalColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatLatency(double ms) {
    if (ms >= 1000) return '${(ms / 1000).toStringAsFixed(1)}s';
    return '${ms.toInt()}ms';
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: TacticalColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
