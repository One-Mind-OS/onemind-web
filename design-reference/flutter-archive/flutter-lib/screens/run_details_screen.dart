import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/run_details_model.dart';

/// Detailed view of agent run execution for monitoring and debugging
class RunDetailsScreen extends ConsumerWidget {
  final String agentId;
  final String runId;

  const RunDetailsScreen({
    super.key,
    required this.agentId,
    required this.runId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement actual API call via provider
    // For now, show mock data structure
    final mockDetails = _getMockRunDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RUN DETAILS',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: TacticalColors.surface,
        foregroundColor: TacticalColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              // ref.invalidate(runDetailsProvider(runId));
            },
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () => _copyRunId(context),
          ),
        ],
      ),
      backgroundColor: TacticalColors.background,
      body: _buildContent(context, mockDetails),
    );
  }

  Widget _buildContent(BuildContext context, RunDetails details) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview card
        _buildOverviewCard(details),
        const SizedBox(height: 16),

        // Token usage card
        _buildTokenUsageCard(details),
        const SizedBox(height: 16),

        // Execution timeline header
        Row(
          children: [
            Icon(Icons.timeline, size: 18, color: TacticalColors.primary),
            const SizedBox(width: 8),
            Text(
              'EXECUTION TIMELINE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 14,
                color: TacticalColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Execution steps
        ...details.steps.map((step) => _buildStepCard(context, step)),

        const SizedBox(height: 32),
      ],
    );
  }

  /// Overview card with run metadata
  Widget _buildOverviewCard(RunDetails details) {
    return Card(
      color: TacticalColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: TacticalColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: TacticalColors.primary),
                const SizedBox(width: 8),
                Text(
                  'OVERVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Agent', details.agentName),
            _buildInfoRow('Status', details.status.toUpperCase()),
            _buildInfoRow(
              'Duration',
              '${details.duration.inSeconds}.${details.duration.inMilliseconds % 1000}s',
            ),
            if (details.cost != null)
              _buildInfoRow('Cost', '\$${details.cost!.toStringAsFixed(4)}'),
            if (details.error != null)
              _buildInfoRow('Error', details.error!, isError: true),
          ],
        ),
      ),
    );
  }

  /// Token usage breakdown card
  Widget _buildTokenUsageCard(RunDetails details) {
    return Card(
      color: TacticalColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: TacticalColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 18, color: TacticalColors.cyan),
                const SizedBox(width: 8),
                Text(
                  'TOKEN USAGE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TacticalColors.cyan,
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTokenColumn(
                    'Input',
                    details.totalInputTokens,
                    TacticalColors.cyan,
                  ),
                ),
                Expanded(
                  child: _buildTokenColumn(
                    'Output',
                    details.totalOutputTokens,
                    TacticalColors.success,
                  ),
                ),
                Expanded(
                  child: _buildTokenColumn(
                    'Total',
                    details.totalTokens,
                    TacticalColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Token usage column
  Widget _buildTokenColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: 0.7),
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Execution step card with expandable details
  Widget _buildStepCard(BuildContext context, RunStep step) {
    final hasDetails = step.input != null || step.output != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: TacticalColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: TacticalColors.textMuted.withValues(alpha: 0.3),
        ),
      ),
      child: hasDetails
          ? ExpansionTile(
              leading: Text(
                step.icon,
                style: const TextStyle(fontSize: 18),
              ),
              title: Text(
                _getStepTitle(step),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: TacticalColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '${step.totalTokens} tokens • ${step.duration.inMilliseconds}ms',
                style: TextStyle(
                  fontSize: 11,
                  color: TacticalColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (step.input != null) ...[
                        _buildJsonSection('Input', step.input!),
                        const SizedBox(height: 12),
                      ],
                      if (step.output != null) ...[
                        _buildJsonSection('Output', step.output!),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : ListTile(
              leading: Text(
                step.icon,
                style: const TextStyle(fontSize: 18),
              ),
              title: Text(
                _getStepTitle(step),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: TacticalColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '${step.totalTokens} tokens • ${step.duration.inMilliseconds}ms',
                style: TextStyle(
                  fontSize: 11,
                  color: TacticalColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
    );
  }

  /// JSON section with copy button
  Widget _buildJsonSection(String label, Map<String, dynamic> data) {
    final jsonString = JsonEncoder.withIndent('  ').convert(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TacticalColors.primary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: Icon(Icons.copy, size: 14, color: TacticalColors.cyan),
              label: Text(
                'COPY',
                style: TextStyle(
                  fontSize: 10,
                  color: TacticalColors.cyan,
                  fontFamily: 'monospace',
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TacticalColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: TacticalColors.cyan.withValues(alpha: 0.3),
            ),
          ),
          child: SelectableText(
            jsonString,
            style: TextStyle(
              fontSize: 11,
              color: TacticalColors.textPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  /// Info row builder
  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: TacticalColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isError ? TacticalColors.error : TacticalColors.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get step title based on type
  String _getStepTitle(RunStep step) {
    switch (step.type.toLowerCase()) {
      case 'tool_call':
        return 'Tool: ${step.toolName ?? 'Unknown'}';
      case 'reasoning':
        return 'Reasoning Step ${step.stepNumber}';
      case 'response':
        return 'Generated Response';
      case 'system':
        return 'System Event';
      default:
        return 'Step ${step.stepNumber}';
    }
  }

  /// Copy run ID to clipboard
  void _copyRunId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: runId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Run ID copied to clipboard',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: TacticalColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mock data for development
  RunDetails _getMockRunDetails() {
    return RunDetails(
      runId: runId,
      agentId: agentId,
      agentName: 'Researcher',
      status: 'complete',
      startedAt: DateTime.now().subtract(const Duration(seconds: 45)),
      completedAt: DateTime.now(),
      totalInputTokens: 1250,
      totalOutputTokens: 3500,
      cost: 0.0142,
      steps: [
        RunStep(
          stepNumber: 1,
          type: 'tool_call',
          toolName: 'duckduckgo',
          inputTokens: 120,
          outputTokens: 850,
          timestamp: DateTime.now().subtract(const Duration(seconds: 40)),
          duration: const Duration(milliseconds: 2400),
          input: {'query': 'quantum computing applications'},
          output: {'results': '10 results found'},
        ),
        RunStep(
          stepNumber: 2,
          type: 'tool_call',
          toolName: 'wikipedia',
          inputTokens: 95,
          outputTokens: 1200,
          timestamp: DateTime.now().subtract(const Duration(seconds: 35)),
          duration: const Duration(milliseconds: 1800),
          input: {'query': 'quantum computing'},
          output: {'article': 'Wikipedia article extracted'},
        ),
        RunStep(
          stepNumber: 3,
          type: 'reasoning',
          inputTokens: 485,
          outputTokens: 650,
          timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
          duration: const Duration(milliseconds: 3500),
        ),
        RunStep(
          stepNumber: 4,
          type: 'response',
          inputTokens: 550,
          outputTokens: 800,
          timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
          duration: const Duration(milliseconds: 5200),
        ),
      ],
    );
  }
}
