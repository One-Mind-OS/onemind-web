// OMOS-238: Cost Breakdown Pie Chart
// Shows estimated cost distribution by agent
// Estimates cost from token usage using typical Claude pricing

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/tactical.dart';
import 'charts.dart';

/// Pie chart showing cost breakdown by agent
/// Estimates cost from token usage with typical pricing
class CostBreakdownChart extends StatefulWidget {
  final List<AgentTokenData> data;
  final String title;
  final double? totalCost; // Optional: use actual cost if available

  const CostBreakdownChart({
    super.key,
    required this.data,
    this.title = 'Cost Breakdown by Agent',
    this.totalCost,
  });

  @override
  State<CostBreakdownChart> createState() => _CostBreakdownChartState();
}

class _CostBreakdownChartState extends State<CostBreakdownChart> {
  int? _touchedIndex;

  // Estimated cost per 1M tokens (Claude 3.5 Sonnet typical pricing)
  static const double _inputCostPer1M = 3.0; // $3 per 1M input tokens
  static const double _outputCostPer1M = 15.0; // $15 per 1M output tokens

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    final costData = _calculateCostData();
    final totalEstCost = costData.fold<double>(0, (sum, d) => sum + d.estimatedCost);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.pie_chart, size: 16, color: TacticalColors.primary),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'Est: \$${totalEstCost.toStringAsFixed(4)}',
                style: TextStyle(color: TacticalColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart and Legend
          Row(
            children: [
              // Pie Chart
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: _buildSections(costData, totalEstCost),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: costData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final isSelected = _touchedIndex == index;
                    final percent = totalEstCost > 0
                        ? (data.estimatedCost / totalEstCost * 100).toStringAsFixed(1)
                        : '0.0';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getColor(index),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data.agentName,
                              style: TextStyle(
                                color: isSelected ? TacticalColors.textPrimary : TacticalColors.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${data.estimatedCost.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: isSelected ? TacticalColors.primary : TacticalColors.textMuted,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($percent%)',
                            style: TextStyle(color: TacticalColors.textMuted, fontSize: 9),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Note
          Text(
            'Estimated from token usage at typical Claude pricing',
            style: TextStyle(color: TacticalColors.textMuted, fontSize: 9, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  List<_AgentCostData> _calculateCostData() {
    return widget.data.map((agent) {
      final inputCost = agent.inputTokens * _inputCostPer1M / 1000000;
      final outputCost = agent.outputTokens * _outputCostPer1M / 1000000;
      return _AgentCostData(
        agentId: agent.agentId,
        agentName: agent.agentName,
        estimatedCost: inputCost + outputCost,
        inputTokens: agent.inputTokens,
        outputTokens: agent.outputTokens,
      );
    }).toList()
      ..sort((a, b) => b.estimatedCost.compareTo(a.estimatedCost));
  }

  List<PieChartSectionData> _buildSections(List<_AgentCostData> costData, double total) {
    return costData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isSelected = _touchedIndex == index;
      final percent = total > 0 ? data.estimatedCost / total * 100 : 0.0;

      return PieChartSectionData(
        color: _getColor(index),
        value: data.estimatedCost,
        title: isSelected ? '${percent.toStringAsFixed(1)}%' : '',
        radius: isSelected ? 35 : 30,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: TacticalColors.textPrimary,
        ),
      );
    }).toList();
  }

  Color _getColor(int index) {
    final colors = [
      TacticalColors.primary,          // Primary red
      TacticalColors.primaryDim,       // Dimmed red
      TacticalColors.info,             // Blue
      TacticalColors.success,          // Green
      TacticalColors.warning,          // Yellow
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, color: TacticalColors.glassBorderLight, size: 32),
            const SizedBox(height: 8),
            Text(
              'No cost data available',
              style: TextStyle(color: TacticalColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal model for agent cost calculation
class _AgentCostData {
  final String agentId;
  final String agentName;
  final double estimatedCost;
  final int inputTokens;
  final int outputTokens;

  _AgentCostData({
    required this.agentId,
    required this.agentName,
    required this.estimatedCost,
    required this.inputTokens,
    required this.outputTokens,
  });
}
