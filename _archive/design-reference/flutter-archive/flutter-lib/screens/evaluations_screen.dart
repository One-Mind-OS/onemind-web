import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/evaluation_model.dart';
import '../services/api_service.dart';
import '../providers/api_providers.dart';

/// Evaluations Screen - Agent/Team Performance Testing
class EvaluationsScreen extends ConsumerStatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  ConsumerState<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends ConsumerState<EvaluationsScreen> {
  late Future<List<EvaluationRunModel>> _evaluationsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  void _loadEvaluations() {
    setState(() {
      _evaluationsFuture = ApiService.listEvaluations();
    });
  }

  Future<void> _createEvaluation() async {
    await _showCreateEvaluationDialog();
  }

  Future<void> _showCreateEvaluationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _CreateEvaluationDialog(),
    );

    if (result != null && mounted) {
      try {
        // Create evaluation model
        final evaluation = EvaluationRunModel(
          agentId: result['agentId'] as String?,
          teamId: result['teamId'] as String?,
          status: 'pending',
          criteria: result['criteria'] as Map<String, dynamic>?,
          createdAt: DateTime.now(),
        );

        await ApiService.createEvaluation(evaluation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Evaluation created successfully'),
              backgroundColor: TacticalColors.success,
            ),
          );
          _loadEvaluations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create evaluation: $e'),
              backgroundColor: TacticalColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteEvaluation(String evalId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Evaluation',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete this evaluation?',
          style: TextStyle(
            color: TacticalColors.primary.withValues(alpha: 0.7),
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: TacticalColors.error),
            child: Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ApiService.deleteEvaluations([evalId]);
        _loadEvaluations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Evaluation deleted successfully'),
              backgroundColor: TacticalColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete evaluation: $e'),
              backgroundColor: TacticalColors.error,
            ),
          );
        }
      }
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
            Icon(Icons.assessment_outlined, color: TacticalColors.primary),
            SizedBox(width: 8),
            Text(
              'EVALUATIONS',
              style: TextStyle(
                color: TacticalColors.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: _loadEvaluations,
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEvaluation,
        backgroundColor: TacticalColors.primary,
        foregroundColor: TacticalColors.background,
        icon: Icon(Icons.add),
        label: Text(
          'CREATE EVALUATION',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
      ),
      body: FutureBuilder<List<EvaluationRunModel>>(
        future: _evaluationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: TacticalColors.error),
                  SizedBox(height: 16),
                  Text(
                    'Error loading evaluations',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final evaluations = snapshot.data ?? [];

          if (evaluations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 64,
                    color: TacticalColors.primary.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'NO EVALUATIONS',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create an evaluation to test agent/team performance',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            itemCount: evaluations.length,
            itemBuilder: (context, index) {
              final eval = evaluations[index];
              return _buildEvaluationCard(eval);
            },
          );
        },
      ),
    );
  }

  Widget _buildEvaluationCard(EvaluationRunModel eval) {
    final statusColor = _getStatusColor(eval.status);

    return Container(
      margin: const EdgeInsets.only(bottom: TacticalSpacing.md),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border.all(
          color: TacticalColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.assessment, color: statusColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.targetName,
                        style: TextStyle(
                          color: TacticalColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${eval.id ?? "N/A"}',
                        style: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    eval.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score
                if (eval.score != null) ...[
                  _buildInfoRow('Score', eval.scorePercentage, Icons.trending_up),
                  SizedBox(height: 8),
                ],

                // Duration
                _buildInfoRow('Duration', eval.durationString, Icons.timer),
                SizedBox(height: 8),

                // Feedback
                if (eval.feedback != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'FEEDBACK',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    eval.feedback!,
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],

                // Actions
                if (eval.isCompleted) ...[
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _deleteEvaluation(eval.id!),
                        icon: Icon(Icons.delete_outline, size: 16),
                        label: Text('DELETE'),
                        style: TextButton.styleFrom(
                          foregroundColor: TacticalColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.primary.withValues(alpha: 0.6), size: 16),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: TacticalColors.primary.withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TacticalColors.success;
      case 'running':
      case 'pending':
        return TacticalColors.warning;
      case 'failed':
        return TacticalColors.error;
      default:
        return TacticalColors.primary;
    }
  }
}

/// Create Evaluation Dialog
class _CreateEvaluationDialog extends ConsumerStatefulWidget {
  const _CreateEvaluationDialog();

  @override
  ConsumerState<_CreateEvaluationDialog> createState() => _CreateEvaluationDialogState();
}

class _CreateEvaluationDialogState extends ConsumerState<_CreateEvaluationDialog> {
  final _formKey = GlobalKey<FormState>();

  // Target selection
  String _targetType = 'agent'; // 'agent' or 'team'
  String? _selectedAgentId;
  String? _selectedTeamId;

  // Test prompts
  final List<TextEditingController> _promptControllers = [TextEditingController()];

  // Evaluation criteria
  final Map<String, bool> _criteria = {
    'accuracy': true,
    'relevance': true,
    'completeness': true,
    'response_time': false,
    'tool_usage': false,
  };

  @override
  void dispose() {
    for (var controller in _promptControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPromptField() {
    setState(() {
      _promptControllers.add(TextEditingController());
    });
  }

  void _removePromptField(int index) {
    if (_promptControllers.length > 1) {
      setState(() {
        _promptControllers[index].dispose();
        _promptControllers.removeAt(index);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Get selected ID based on target type
      final targetId = _targetType == 'agent' ? _selectedAgentId : _selectedTeamId;

      if (targetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a $_targetType'),
            backgroundColor: TacticalColors.error,
          ),
        );
        return;
      }

      // Collect test prompts
      final prompts = _promptControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (prompts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one test prompt'),
            backgroundColor: TacticalColors.error,
          ),
        );
        return;
      }

      // Build criteria map
      final selectedCriteria = _criteria.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Return result
      Navigator.of(context).pop({
        'agentId': _targetType == 'agent' ? targetId : null,
        'teamId': _targetType == 'team' ? targetId : null,
        'criteria': {
          'test_prompts': prompts,
          'metrics': selectedCriteria,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentsProvider);
    final teamsAsync = ref.watch(teamsProvider);

    return AlertDialog(
      backgroundColor: TacticalColors.surface,
      title: Row(
        children: [
          Icon(Icons.assessment, color: TacticalColors.primary),
          SizedBox(width: 8),
          Text(
            'CREATE EVALUATION',
            style: TextStyle(
              color: TacticalColors.primary,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target type selection
                Text(
                  'EVALUATION TARGET',
                  style: TextStyle(
                    color: TacticalColors.primary.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioGroup<String>(
                        groupValue: _targetType,
                        onChanged: (value) {
                          setState(() {
                            _targetType = value!;
                            _selectedAgentId = null;
                            _selectedTeamId = null;
                          });
                        },
                        child: RadioListTile<String>(
                          value: 'agent',
                          title: Text(
                            'Agent',
                            style: TextStyle(
                              color: TacticalColors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          activeColor: TacticalColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RadioGroup<String>(
                        groupValue: _targetType,
                        onChanged: (value) {
                          setState(() {
                            _targetType = value!;
                            _selectedAgentId = null;
                            _selectedTeamId = null;
                          });
                        },
                        child: RadioListTile<String>(
                          value: 'team',
                          title: Text(
                            'Team',
                            style: TextStyle(
                              color: TacticalColors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          activeColor: TacticalColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Agent/Team selection dropdown
                if (_targetType == 'agent')
                  agentsAsync.when(
                    data: (agents) => DropdownButtonFormField<String>(
                      initialValue: _selectedAgentId,
                      decoration: InputDecoration(
                        labelText: 'Select Agent',
                        labelStyle: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.7),
                          fontFamily: 'monospace',
                        ),
                        filled: true,
                        fillColor: TacticalColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: TacticalColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      dropdownColor: TacticalColors.surface,
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                      ),
                      items: agents.map((agent) {
                        return DropdownMenuItem(
                          value: agent.id,
                          child: Text(agent.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAgentId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an agent';
                        }
                        return null;
                      },
                    ),
                    loading: () => CircularProgressIndicator(
                      color: TacticalColors.primary,
                    ),
                    error: (err, stack) => Text(
                      'Error loading agents: $err',
                      style: TextStyle(
                        color: TacticalColors.error,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                if (_targetType == 'team')
                  teamsAsync.when(
                    data: (teams) => DropdownButtonFormField<String>(
                      initialValue: _selectedTeamId,
                      decoration: InputDecoration(
                        labelText: 'Select Team',
                        labelStyle: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.7),
                          fontFamily: 'monospace',
                        ),
                        filled: true,
                        fillColor: TacticalColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: TacticalColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      dropdownColor: TacticalColors.surface,
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                      ),
                      items: teams.map((team) {
                        return DropdownMenuItem(
                          value: team.id,
                          child: Text(team.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTeamId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a team';
                        }
                        return null;
                      },
                    ),
                    loading: () => CircularProgressIndicator(
                      color: TacticalColors.primary,
                    ),
                    error: (err, stack) => Text(
                      'Error loading teams: $err',
                      style: TextStyle(
                        color: TacticalColors.error,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                SizedBox(height: 24),

                // Test prompts section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TEST PROMPTS',
                      style: TextStyle(
                        color: TacticalColors.primary.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 20),
                      color: TacticalColors.primary,
                      onPressed: _addPromptField,
                      tooltip: 'Add prompt',
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ...List.generate(_promptControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _promptControllers[index],
                            maxLines: 2,
                            style: TextStyle(
                              color: TacticalColors.primary,
                              fontFamily: 'monospace',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter test prompt ${index + 1}...',
                              hintStyle: TextStyle(
                                color: TacticalColors.primary.withValues(alpha: 0.4),
                                fontFamily: 'monospace',
                              ),
                              filled: true,
                              fillColor: TacticalColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: TacticalColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (index == 0 && (value == null || value.trim().isEmpty)) {
                                return 'At least one prompt is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_promptControllers.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, size: 20),
                            color: TacticalColors.error,
                            onPressed: () => _removePromptField(index),
                            tooltip: 'Remove prompt',
                          ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 24),

                // Evaluation criteria section
                Text(
                  'EVALUATION METRICS',
                  style: TextStyle(
                    color: TacticalColors.primary.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                ..._criteria.entries.map((entry) {
                  return CheckboxListTile(
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _criteria[entry.key] = value ?? false;
                      });
                    },
                    title: Text(
                      entry.key.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    activeColor: TacticalColors.primary,
                    checkColor: TacticalColors.background,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(fontFamily: 'monospace'),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: TacticalColors.primary,
            foregroundColor: TacticalColors.background,
          ),
          child: Text(
            'CREATE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
