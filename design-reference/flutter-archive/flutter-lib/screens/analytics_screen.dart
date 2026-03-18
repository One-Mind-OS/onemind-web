import '../config/tactical_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../models/analytics_model.dart';

/// Analytics Dashboard Screen
/// ===========================
/// Comprehensive analytics dashboard with metrics, charts, and insights.

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  // State
  bool _isLoading = true;
  String? _error;
  int _selectedDays = 30; // Default to 30 days

  // Analytics data
  AnalyticsOverview? _overview;
  List<AgentStats> _agentStats = [];
  CostBreakdown? _costBreakdown;
  PerformanceMetrics? _performanceMetrics;
  List<TimeSeriesDataPoint> _sessionTimeSeries = [];
  List<TimeSeriesDataPoint> _tokenTimeSeries = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load data from multiple endpoints to build analytics
      final futures = await Future.wait([
        ApiService.getMetrics(),
        ApiService.listAgents(),
        ApiService.getSessions(),
        ApiService.getMemories(),
        ApiService.getKnowledgeContent(),
        ApiService.listTeams(),
      ]);

      final metricsData = futures[0] as Map<String, dynamic>;
      final agentsData = futures[1] as List<dynamic>;
      final sessionsData = futures[2] as Map<String, dynamic>;
      final memoriesData = futures[3] as Map<String, dynamic>;
      final knowledgeData = futures[4] as List<dynamic>;
      final teamsData = futures[5] as List<dynamic>;

      // Parse metrics (if available)
      final metricsList = metricsData['metrics'] as List<dynamic>? ?? [];

      // Aggregate metrics data
      int totalRuns = 0;
      int totalMessages = 0;
      int totalInputTokens = 0;
      int totalOutputTokens = 0;
      double totalCost = 0.0;
      double totalResponseTime = 0.0;
      Map<String, Map<String, dynamic>> agentMetrics = {};
      Map<String, Map<String, dynamic>> modelMetrics = {};
      List<TimeSeriesDataPoint> sessionsTimeSeries = [];
      List<TimeSeriesDataPoint> tokensTimeSeries = [];

      // Process each metric
      for (var metric in metricsList) {
        final agentId = metric['agent_id'] as String?;
        final modelName = metric['model'] as String?;
        final inputTokens = metric['input_tokens'] as int? ?? 0;
        final outputTokens = metric['output_tokens'] as int? ?? 0;
        final cost = (metric['cost'] as num?)?.toDouble() ?? 0.0;
        final responseTime = (metric['response_time_ms'] as num?)?.toDouble() ?? 0.0;

        totalRuns++;
        totalMessages++; // Each run is a message
        totalInputTokens += inputTokens;
        totalOutputTokens += outputTokens;
        totalCost += cost;
        totalResponseTime += responseTime;

        // Aggregate by agent
        if (agentId != null) {
          agentMetrics.putIfAbsent(agentId, () => {
            'runs': 0,
            'input_tokens': 0,
            'output_tokens': 0,
            'cost': 0.0,
            'response_time': 0.0,
          });
          agentMetrics[agentId]!['runs'] = (agentMetrics[agentId]!['runs'] as int) + 1;
          agentMetrics[agentId]!['input_tokens'] = (agentMetrics[agentId]!['input_tokens'] as int) + inputTokens;
          agentMetrics[agentId]!['output_tokens'] = (agentMetrics[agentId]!['output_tokens'] as int) + outputTokens;
          agentMetrics[agentId]!['cost'] = (agentMetrics[agentId]!['cost'] as double) + cost;
          agentMetrics[agentId]!['response_time'] = (agentMetrics[agentId]!['response_time'] as double) + responseTime;
        }

        // Aggregate by model
        if (modelName != null) {
          modelMetrics.putIfAbsent(modelName, () => {
            'runs': 0,
            'input_tokens': 0,
            'output_tokens': 0,
            'cost': 0.0,
          });
          modelMetrics[modelName]!['runs'] = (modelMetrics[modelName]!['runs'] as int) + 1;
          modelMetrics[modelName]!['input_tokens'] = (modelMetrics[modelName]!['input_tokens'] as int) + inputTokens;
          modelMetrics[modelName]!['output_tokens'] = (modelMetrics[modelName]!['output_tokens'] as int) + outputTokens;
          modelMetrics[modelName]!['cost'] = (modelMetrics[modelName]!['cost'] as double) + cost;
        }
      }

      // Calculate averages
      final avgResponseTime = totalRuns > 0 ? totalResponseTime / totalRuns : 0.0;

      // Get session count from sessions data
      final totalSessions = sessionsData['meta']?['total_count'] ?? 0;
      final totalMemories = memoriesData['meta']?['total_count'] ?? 0;

      // Build overview
      _overview = AnalyticsOverview(
        totalAgents: agentsData.length,
        totalTeams: teamsData.length,
        totalSessions: totalSessions,
        totalRuns: totalRuns,
        totalMessages: totalMessages,
        totalMemories: totalMemories,
        totalKnowledgeBases: knowledgeData.length,
        totalDocuments: 0, // TODO: Parse from knowledge base documents
        totalCostUsd: totalCost,
        totalInputTokens: totalInputTokens,
        totalOutputTokens: totalOutputTokens,
        avgResponseTimeMs: avgResponseTime,
        sessionsChange: null, // TODO: Calculate from historical data
        messagesChange: null,
        periodDays: _selectedDays,
        generatedAt: DateTime.now().toIso8601String(),
      );

      // Build agent stats
      _agentStats = agentMetrics.entries.map((entry) {
        final agentId = entry.key;
        final metrics = entry.value;

        // Find agent name from agents list
        final agent = agentsData.firstWhere(
          (a) => a['id'] == agentId,
          orElse: () => {'name': agentId, 'model': {'model': 'Unknown'}},
        );

        final runs = metrics['runs'] as int;
        final responseTimeSum = metrics['response_time'] as double;

        return AgentStats(
          agentId: agentId,
          agentName: agent['name'] ?? agentId,
          description: agent['description'],
          modelName: agent['model']?['model'] ?? 'Unknown',
          runCount: runs,
          inputTokens: metrics['input_tokens'] as int,
          outputTokens: metrics['output_tokens'] as int,
          totalTokens: (metrics['input_tokens'] as int) + (metrics['output_tokens'] as int),
          costUsd: metrics['cost'] as double,
          avgResponseTimeMs: runs > 0 ? responseTimeSum / runs : 0.0,
        );
      }).toList();

      // Sort by run count
      _agentStats.sort((a, b) => b.runCount.compareTo(a.runCount));

      // Build cost breakdown by model
      final costByModelList = modelMetrics.entries.map((entry) {
        return ModelCost(
          modelName: entry.key,
          runCount: entry.value['runs'] as int,
          inputTokens: entry.value['input_tokens'] as int,
          outputTokens: entry.value['output_tokens'] as int,
          costUsd: entry.value['cost'] as double,
        );
      }).toList();

      if (costByModelList.isNotEmpty) {
        _costBreakdown = CostBreakdown(
          totalCostUsd: totalCost,
          costByModel: costByModelList,
        );
      }

      // Build performance metrics (calculate percentiles from metrics)
      if (totalRuns > 0) {
        final responseTimes = metricsList
            .map((m) => (m['response_time_ms'] as num?)?.toDouble() ?? 0.0)
            .where((t) => t > 0)
            .toList()
          ..sort();

        if (responseTimes.isNotEmpty) {
          final p50Index = (responseTimes.length * 0.5).floor();
          final p90Index = (responseTimes.length * 0.9).floor();
          final p99Index = (responseTimes.length * 0.99).floor();

          _performanceMetrics = PerformanceMetrics(
            p50Ms: responseTimes[p50Index],
            p90Ms: responseTimes[p90Index],
            p99Ms: responseTimes[p99Index],
            avgResponseTimeMs: avgResponseTime,
            totalRuns: totalRuns,
          );
        }
      }

      // Session stats built but not currently used in UI
      // Generate time series data (placeholder for now - would need historical data)
      // For demo purposes, create some sample data if we have runs
      if (totalRuns > 0) {
        final now = DateTime.now();
        for (var i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          sessionsTimeSeries.add(TimeSeriesDataPoint(
            date: date.toIso8601String().substring(0, 10),
            value: (totalSessions / 7 * (0.8 + (i % 3) * 0.1)).round(),
          ));
          tokensTimeSeries.add(TimeSeriesDataPoint(
            date: date.toIso8601String().substring(0, 10),
            inputTokens: (totalInputTokens / 7 * (0.8 + (i % 3) * 0.1)).round(),
            outputTokens: (totalOutputTokens / 7 * (0.8 + (i % 3) * 0.1)).round(),
          ));
        }
        _sessionTimeSeries = sessionsTimeSeries;
        _tokenTimeSeries = tokensTimeSeries;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        title: Row(
          children: [
            Icon(Icons.analytics, color: TacticalColors.primary),
            SizedBox(width: 8),
            Text('Analytics Dashboard',
                style: TextStyle(color: TacticalColors.textPrimary, fontSize: 20)),
          ],
        ),
        actions: [
          // Date range selector
          _buildDateRangeSelector(),
          SizedBox(width: 16),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildDateRangeSelector() {
    return DropdownButton<int>(
      value: _selectedDays,
      dropdownColor: Colors.grey[900],
      style: TextStyle(color: TacticalColors.primary),
      underline: Container(height: 1, color: TacticalColors.primary),
      items: const [
        DropdownMenuItem(value: 7, child: Text('Last 7 days')),
        DropdownMenuItem(value: 30, child: Text('Last 30 days')),
        DropdownMenuItem(value: 90, child: Text('Last 90 days')),
        DropdownMenuItem(value: 0, child: Text('All time')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedDays = value;
          });
          _loadAnalytics();
        }
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TacticalColors.primary),
            SizedBox(height: 16),
            Text('Loading analytics...',
                style: TextStyle(color: TacticalColors.textSecondary)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('Error loading analytics',
                style: TextStyle(color: TacticalColors.textPrimary, fontSize: 18)),
            SizedBox(height: 8),
            Text(_error!,
                style: TextStyle(color: TacticalColors.textSecondary),
                textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalytics,
              style: ElevatedButton.styleFrom(backgroundColor: TacticalColors.primary),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key metrics cards
          _buildMetricsCards(),
          SizedBox(height: 32),

          // Charts section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Time series charts
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildSessionsChart(),
                    SizedBox(height: 24),
                    _buildTokensChart(),
                  ],
                ),
              ),
              SizedBox(width: 24),

              // Right column - Breakdown charts
              Expanded(
                child: Column(
                  children: [
                    _buildCostPieChart(),
                    SizedBox(height: 24),
                    _buildAgentUsageBarChart(),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 32),

          // Performance and details section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPerformanceMetrics(),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildTopAgents(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // KEY METRICS CARDS
  // ==========================================================================

  Widget _buildMetricsCards() {
    if (_overview == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Sessions',
          _overview!.totalSessions.toString(),
          Icons.chat_bubble_outline,
          _overview!.sessionsChange,
        ),
        _buildMetricCard(
          'Total Messages',
          _overview!.totalMessages.toString(),
          Icons.message_outlined,
          _overview!.messagesChange,
        ),
        _buildMetricCard(
          'Total Cost',
          '\$${_overview!.totalCostUsd.toStringAsFixed(2)}',
          Icons.attach_money,
          null,
        ),
        _buildMetricCard(
          'Avg Response Time',
          '${_overview!.avgResponseTimeMs.toStringAsFixed(0)} ms',
          Icons.speed,
          null,
        ),
        _buildMetricCard(
          'Active Agents',
          _overview!.totalAgents.toString(),
          Icons.smart_toy,
          null,
        ),
        _buildMetricCard(
          'Total Memories',
          _overview!.totalMemories.toString(),
          Icons.memory,
          null,
        ),
        _buildMetricCard(
          'Documents',
          _overview!.totalDocuments.toString(),
          Icons.description,
          null,
        ),
        _buildMetricCard(
          'Total Tokens',
          _formatNumber(_overview!.totalTokens),
          Icons.token,
          null,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, double? change) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: TacticalColors.primary, size: 20),
              if (change != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: change >= 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: TacticalColors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CHARTS
  // ==========================================================================

  Widget _buildSessionsChart() {
    if (_sessionTimeSeries.isEmpty) {
      return _buildEmptyChart('Sessions Over Time');
    }

    return _buildChartCard(
      title: 'Sessions Over Time',
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: TacticalColors.primary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: TacticalColors.textSecondary, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (_sessionTimeSeries.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _sessionTimeSeries.length) {
                    final date = _sessionTimeSeries[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        date.substring(5), // Show MM-DD
                        style: TextStyle(
                            color: TacticalColors.textSecondary, fontSize: 10),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _sessionTimeSeries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                      e.key.toDouble(), (e.value.value ?? 0).toDouble()))
                  .toList(),
              isCurved: true,
              color: TacticalColors.primary,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: TacticalColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensChart() {
    if (_tokenTimeSeries.isEmpty) {
      return _buildEmptyChart('Token Usage Over Time');
    }

    return _buildChartCard(
      title: 'Token Usage Over Time',
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: TacticalColors.primary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatNumber(value.toInt()),
                    style: TextStyle(color: TacticalColors.textSecondary, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (_tokenTimeSeries.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _tokenTimeSeries.length) {
                    final date = _tokenTimeSeries[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        date.substring(5),
                        style: TextStyle(
                            color: TacticalColors.textSecondary, fontSize: 10),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _tokenTimeSeries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(),
                      (e.value.inputTokens ?? 0).toDouble()))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: _tokenTimeSeries
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(),
                      (e.value.outputTokens ?? 0).toDouble()))
                  .toList(),
              isCurved: true,
              color: Colors.purple,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostPieChart() {
    if (_costBreakdown == null || _costBreakdown!.costByModel.isEmpty) {
      return _buildEmptyChart('Cost by Model');
    }

    final sections = _costBreakdown!.costByModel.map((model) {
      final percentage =
          (model.costUsd / _costBreakdown!.totalCostUsd) * 100;
      return PieChartSectionData(
        value: model.costUsd,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getColorForModel(model.modelName),
        radius: 100,
        titleStyle: TextStyle(
          color: TacticalColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return _buildChartCard(
      title: 'Cost by Model',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 16),
          ..._costBreakdown!.costByModel.map((model) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForModel(model.modelName),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        model.modelName,
                        style: TextStyle(
                            color: TacticalColors.textSecondary, fontSize: 12),
                      ),
                    ),
                    Text(
                      '\$${model.costUsd.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAgentUsageBarChart() {
    if (_agentStats.isEmpty) {
      return _buildEmptyChart('Agent Usage');
    }

    // Take top 5 agents
    final topAgents = _agentStats.take(5).toList();

    return _buildChartCard(
      title: 'Top Agents by Usage',
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (topAgents.first.runCount * 1.2).toDouble(),
          barGroups: topAgents.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.runCount.toDouble(),
                  color: TacticalColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: TacticalColors.textSecondary, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < topAgents.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        topAgents[value.toInt()].agentName,
                        style: TextStyle(
                            color: TacticalColors.textSecondary, fontSize: 10),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: TacticalColors.primary.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ==========================================================================
  // DETAILS SECTIONS
  // ==========================================================================

  Widget _buildPerformanceMetrics() {
    if (_performanceMetrics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: TacticalColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPerformanceRow('p50 (median)', _performanceMetrics!.p50Ms),
          _buildPerformanceRow('p90', _performanceMetrics!.p90Ms),
          _buildPerformanceRow('p99', _performanceMetrics!.p99Ms),
          _buildPerformanceRow('Average', _performanceMetrics!.avgResponseTimeMs),
          Divider(color: TacticalColors.border, height: 24),
          Text(
            'Based on ${_performanceMetrics!.totalRuns} runs',
            style: TextStyle(color: TacticalColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: TacticalColors.textSecondary)),
          Text(
            '${value.toStringAsFixed(0)} ms',
            style: TextStyle(
              color: TacticalColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAgents() {
    if (_agentStats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: TacticalColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Agent Leaderboard',
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._agentStats.take(5).map((agent) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.agentName,
                            style: TextStyle(
                              color: TacticalColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${agent.runCount} runs • \$${agent.costUsd.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: TacticalColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatNumber(agent.totalTokens),
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(height: 250, child: child),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: TacticalColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Color _getColorForModel(String modelName) {
    final colors = [
      TacticalColors.primary,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
    ];

    // Simple hash to get consistent color for model
    final hash = modelName.hashCode.abs();
    return colors[hash % colors.length];
  }
}
