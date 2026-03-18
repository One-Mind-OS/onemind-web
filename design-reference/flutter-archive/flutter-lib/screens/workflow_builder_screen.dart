import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workflow_model.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';

/// Workflow Builder Screen — Agno-Native Visual Automation Pipeline
/// =================================================================
/// Mobile-friendly workflow creation using Agno's native step types:
/// - step: Single executor or agent action
/// - steps: Sequential step group
/// - parallel: Concurrent execution
/// - condition: If/else branching
/// - loop: Repeat until condition
/// - router: Select path based on expression
/// - agent: Run an Agno agent

class WorkflowBuilderScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const WorkflowBuilderScreen({super.key, this.embedded = false});

  @override
  ConsumerState<WorkflowBuilderScreen> createState() => _WorkflowBuilderScreenState();
}

class _WorkflowBuilderScreenState extends ConsumerState<WorkflowBuilderScreen> {
  // Workflow state - using Agno-native WorkflowStep model
  List<WorkflowModel> _workflows = [];
  WorkflowModel? _activeWorkflow;
  List<WorkflowStep> _steps = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  int? _selectedStepIndex;
  bool _showPalette = false;

  // Agno-native node type categories
  final Map<String, List<Map<String, dynamic>>> _nodeCategories = {
    'Control Flow': [
      {'type': 'parallel', 'icon': Icons.alt_route, 'label': 'Parallel', 'color': Color(0xFFFF9800), 'desc': 'Execute steps concurrently', 'isControlFlow': true},
      {'type': 'condition', 'icon': Icons.call_split, 'label': 'Condition', 'color': Color(0xFFFF9800), 'desc': 'If/else branching', 'isControlFlow': true},
      {'type': 'loop', 'icon': Icons.repeat, 'label': 'Loop', 'color': Color(0xFFFF9800), 'desc': 'Repeat steps', 'isControlFlow': true},
      {'type': 'router', 'icon': Icons.device_hub, 'label': 'Router', 'color': Color(0xFFFF9800), 'desc': 'Select path dynamically', 'isControlFlow': true},
      {'type': 'steps', 'icon': Icons.list, 'label': 'Step Group', 'color': Color(0xFFFF9800), 'desc': 'Sequential group', 'isControlFlow': true},
    ],
    'AI Agents': [
      {'type': 'agent', 'executor': null, 'icon': Icons.smart_toy, 'label': 'AI Agent', 'color': Color(0xFF4CAF50), 'desc': 'Run an Agno agent'},
      {'type': 'step', 'executor': 'llm_call', 'icon': Icons.psychology, 'label': 'LLM Call', 'color': Color(0xFF4CAF50), 'desc': 'Direct model inference'},
    ],
    'Integrations': [
      {'type': 'step', 'executor': 'email_send', 'icon': Icons.email, 'label': 'Send Email', 'color': Color(0xFF9C27B0), 'desc': 'Email via SMTP/Resend'},
      {'type': 'step', 'executor': 'github_action', 'icon': Icons.code, 'label': 'GitHub', 'color': Color(0xFF9C27B0), 'desc': 'GitHub API action'},
      {'type': 'step', 'executor': 'calendar_event', 'icon': Icons.event, 'label': 'Calendar', 'color': Color(0xFF9C27B0), 'desc': 'Create calendar event'},
      {'type': 'step', 'executor': 'webhook_out', 'icon': Icons.send, 'label': 'Webhook', 'color': Color(0xFF9C27B0), 'desc': 'HTTP request'},
    ],
    'Logic': [
      {'type': 'step', 'executor': 'delay', 'icon': Icons.timer, 'label': 'Delay', 'color': Color(0xFF2196F3), 'desc': 'Wait seconds'},
      {'type': 'step', 'executor': 'transform', 'icon': Icons.transform, 'label': 'Transform', 'color': Color(0xFF2196F3), 'desc': 'Transform data'},
    ],
    'Data': [
      {'type': 'step', 'executor': 'db_query', 'icon': Icons.storage, 'label': 'DB Query', 'color': Color(0xFF00BCD4), 'desc': 'Database query'},
    ],
    'Output': [
      {'type': 'step', 'executor': 'create_task', 'icon': Icons.add_task, 'label': 'Create Task', 'color': Color(0xFFE91E63), 'desc': 'New task'},
      {'type': 'step', 'executor': 'activity_post', 'icon': Icons.feed, 'label': 'Activity Post', 'color': Color(0xFFE91E63), 'desc': 'Post to feed'},
      {'type': 'step', 'executor': 'nats_publish', 'icon': Icons.publish, 'label': 'NATS Publish', 'color': Color(0xFFE91E63), 'desc': 'Publish message'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadWorkflows();
  }

  Future<void> _loadWorkflows() async {
    try {
      final workflows = await ApiService.listWorkflows(limit: 100);
      if (mounted) {
        setState(() {
          _workflows = workflows;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load workflows: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _loadWorkflowDetail(String id) async {
    try {
      final workflow = await ApiService.getWorkflow(id);
      if (mounted) {
        setState(() {
          _activeWorkflow = workflow;
          _steps = List<WorkflowStep>.from(workflow.steps);
          _isEditMode = true;
          _selectedStepIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to load workflow: ${e.toString()}', isError: true);
      }
    }
  }

  Map<String, dynamic>? _findNodeType(WorkflowStep step) {
    for (final category in _nodeCategories.values) {
      for (final node in category) {
        // Match control flow types
        if (node['type'] == step.type && (node['isControlFlow'] == true || step.isControlFlow)) {
          return node;
        }
        // Match executor types
        if (node['type'] == 'step' && node['executor'] == step.executor) {
          return node;
        }
        // Match agent type
        if (node['type'] == 'agent' && step.type == 'agent') {
          return node;
        }
      }
    }
    return null;
  }

  void _addStep(Map<String, dynamic> nodeType) {
    final isControlFlow = nodeType['isControlFlow'] == true;
    final newStep = WorkflowStep(
      name: '${nodeType['label']} ${_steps.length + 1}',
      type: nodeType['type'] as String,
      executor: nodeType['executor'] as String?,
      config: {},
      // Initialize nested steps for control flow nodes
      steps: isControlFlow ? [] : null,
      choices: nodeType['type'] == 'router' ? [] : null,
    );

    setState(() {
      _steps.add(newStep);
      _selectedStepIndex = _steps.length - 1;
      _showPalette = false;
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      _selectedStepIndex = null;
    });
  }

  void _addNestedStep(int parentIndex, Map<String, dynamic> nodeType) {
    final parent = _steps[parentIndex];
    if (!parent.canHaveNestedSteps) return;

    final newStep = WorkflowStep(
      name: '${nodeType['label']} ${(parent.steps?.length ?? 0) + 1}',
      type: nodeType['type'] as String,
      executor: nodeType['executor'] as String?,
      config: {},
    );

    final updatedSteps = List<WorkflowStep>.from(parent.steps ?? [])..add(newStep);

    setState(() {
      _steps[parentIndex] = parent.copyWith(steps: updatedSteps);
    });
  }

  Future<void> _saveWorkflow() async {
    if (_activeWorkflow == null) return;
    try {
      final updatedWorkflow = _activeWorkflow!.copyWith(
        steps: _steps,
        updatedAt: DateTime.now(),
      );

      await ApiService.updateWorkflow(
        _activeWorkflow!.id!,
        updatedWorkflow,
      );

      if (mounted) {
        _showSnackBar('Workflow saved', isError: false);
        _loadWorkflows(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _runWorkflow() async {
    if (_activeWorkflow == null) return;
    try {
      final result = await ApiService.runWorkflow(_activeWorkflow!.id!);
      if (mounted) {
        _showSnackBar('Workflow ${result.status}: Run ID ${result.id}', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to run: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? TacticalColors.error : TacticalColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _isEditMode
            ? _buildEditor(isMobile, isTablet)
            : _buildWorkflowList(isMobile);

    if (widget.embedded) {
      return Column(
        children: [
          _buildToolbar(isMobile),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: isMobile ? null : _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            if (isMobile) _buildToolbar(true),
            Expanded(child: content),
          ],
        ),
      ),
      floatingActionButton: _isEditMode && isMobile
          ? FloatingActionButton(
              backgroundColor: TacticalColors.cyan,
              onPressed: () => setState(() => _showPalette = true),
              child: const Icon(Icons.add),
            )
          : null,
      bottomSheet: _showPalette && isMobile ? _buildMobilePalette() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TacticalColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.account_tree, color: TacticalColors.cyan, size: 22),
          const SizedBox(width: 10),
          Text(
            _isEditMode
                ? 'WORKFLOW: ${_activeWorkflow?.name ?? ''}'.toUpperCase()
                : 'AGNO WORKFLOW BUILDER',
            style: TacticalText.screenTitle.copyWith(fontSize: 18),
          ),
        ],
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(bottom: BorderSide(color: TacticalColors.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree, color: TacticalColors.cyan, size: isMobile ? 18 : 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isEditMode
                  ? (_activeWorkflow?.name ?? 'Untitled').toUpperCase()
                  : 'AGNO WORKFLOWS',
              style: TacticalText.screenTitle.copyWith(fontSize: isMobile ? 14 : 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ..._buildActions(),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_isEditMode) {
      return [
        IconButton(
          icon: Icon(Icons.play_arrow, color: TacticalColors.success, size: 22),
          onPressed: _runWorkflow,
          tooltip: 'Run',
        ),
        IconButton(
          icon: Icon(Icons.save, color: TacticalColors.cyan, size: 20),
          onPressed: _saveWorkflow,
          tooltip: 'Save',
        ),
        IconButton(
          icon: Icon(Icons.close, color: TacticalColors.textDim, size: 20),
          onPressed: () => setState(() {
            _isEditMode = false;
            _activeWorkflow = null;
            _steps = [];
            _selectedStepIndex = null;
          }),
          tooltip: 'Close',
        ),
      ];
    }
    return [
      IconButton(
        icon: Icon(Icons.add, color: TacticalColors.cyan, size: 22),
        onPressed: _showCreateDialog,
        tooltip: 'New',
      ),
    ];
  }

  Widget _buildWorkflowList(bool isMobile) {
    if (_workflows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_tree, size: 64, color: TacticalColors.textDim),
              const SizedBox(height: 16),
              Text('No Agno workflows yet',
                  style: TextStyle(color: TacticalColors.textMuted, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Create an automation pipeline using Agno\'s native workflow system',
                  style: TextStyle(color: TacticalColors.textDim, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('NEW WORKFLOW'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TacticalColors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _showCreateDialog,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: _workflows.length,
      itemBuilder: (ctx, i) => _buildWorkflowCard(_workflows[i], isMobile),
    );
  }

  Widget _buildWorkflowCard(WorkflowModel wf, bool isMobile) {
    final status = wf.status;
    final stepCount = wf.totalStepCount;
    final isActive = status == 'active';

    return GestureDetector(
      onTap: () => _loadWorkflowDetail(wf.id ?? ''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: TacticalDecoration.card(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isActive ? TacticalColors.success : TacticalColors.textDim)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_tree,
                color: isActive ? TacticalColors.success : TacticalColors.textDim,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wf.name,
                    style: TacticalText.cardTitle.copyWith(fontSize: isMobile ? 14 : 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$stepCount steps • ${wf.steps.length} top-level',
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(status, isActive),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: TacticalColors.textDim, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? TacticalColors.success : TacticalColors.textDim)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: isActive ? TacticalColors.success : TacticalColors.textDim,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEditor(bool isMobile, bool isTablet) {
    if (isMobile) {
      return _buildMobileEditor();
    }

    // Desktop/Tablet: 3-column layout
    return Row(
      children: [
        // Left: Node Palette
        if (!isTablet) _buildDesktopPalette(),

        // Center: Canvas
        Expanded(child: _buildCanvas(isMobile)),

        // Right: Step Config
        _buildConfigPanel(isMobile),
      ],
    );
  }

  Widget _buildMobileEditor() {
    return Stack(
      children: [
        // Canvas
        _buildCanvas(true),

        // Selected step config (bottom sheet style)
        if (_selectedStepIndex != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMobileConfigSheet(),
          ),
      ],
    );
  }

  Widget _buildCanvas(bool isMobile) {
    if (_steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 48, color: TacticalColors.textDim),
            const SizedBox(height: 12),
            Text(
              isMobile ? 'Tap + to add steps' : 'Click a step type to add it',
              style: TextStyle(color: TacticalColors.textDim, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Parallel, Loop, Condition for control flow',
              style: TextStyle(color: TacticalColors.textDim.withValues(alpha: 0.6), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedStepIndex = null),
      child: Container(
        color: TacticalColors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            children: List.generate(_steps.length, (i) {
              final step = _steps[i];
              final nodeType = _findNodeType(step);
              final isSelected = _selectedStepIndex == i;

              return Column(
                children: [
                  _buildStepCard(i, step, nodeType, isSelected, isMobile),
                  if (i < _steps.length - 1) _buildConnector(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, WorkflowStep step,
      Map<String, dynamic>? nodeType, bool isSelected, bool isMobile) {
    final color = (nodeType?['color'] as Color?) ?? TacticalColors.textDim;
    final icon = (nodeType?['icon'] as IconData?) ?? Icons.help_outline;
    final hasNested = step.canHaveNestedSteps && (step.steps?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: () => setState(() => _selectedStepIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isMobile ? double.infinity : 360,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TacticalColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : TacticalColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name,
                        style: TacticalText.cardTitle.copyWith(fontSize: 14),
                      ),
                      Text(
                        _getStepDescription(step, nodeType),
                        style: TextStyle(color: TacticalColors.textDim, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Step type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    step.type.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            // Show nested steps for control flow nodes
            if (hasNested) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TacticalColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TacticalColors.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NESTED STEPS (${step.steps!.length})',
                      style: TextStyle(
                        color: TacticalColors.textDim,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...step.steps!.asMap().entries.map((e) {
                      final nested = e.value;
                      final nestedType = _findNodeType(nested);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              nestedType?['icon'] as IconData? ?? Icons.circle,
                              size: 12,
                              color: nestedType?['color'] as Color? ?? TacticalColors.textDim,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nested.name,
                                style: TextStyle(
                                  color: TacticalColors.textPrimary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStepDescription(WorkflowStep step, Map<String, dynamic>? nodeType) {
    if (step.isControlFlow) {
      final count = step.steps?.length ?? 0;
      return '${nodeType?['desc'] ?? step.type} • $count nested';
    }
    if (step.type == 'agent') {
      return 'Agent: ${step.agentId ?? 'Not set'}';
    }
    return nodeType?['desc'] ?? step.executor ?? step.type;
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TacticalColors.cyan, TacticalColors.cyan.withValues(alpha: 0.3)],
        ),
      ),
    );
  }

  Widget _buildDesktopPalette() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(right: BorderSide(color: TacticalColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AGNO STEP PALETTE',
                    style: TacticalText.sectionHeader.copyWith(fontSize: 11)),
                const SizedBox(height: 4),
                Text('Native workflow primitives',
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _nodeCategories.entries.map((entry) {
                return _buildPaletteCategory(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteCategory(String title, List<Map<String, dynamic>> nodes) {
    return ExpansionTile(
      title: Text(title.toUpperCase(),
          style: TacticalText.label.copyWith(fontSize: 10, letterSpacing: 1)),
      initiallyExpanded: title == 'Control Flow',
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: nodes.map((n) => _buildPaletteNode(n)).toList(),
    );
  }

  Widget _buildPaletteNode(Map<String, dynamic> node) {
    final color = node['color'] as Color;
    final isControlFlow = node['isControlFlow'] == true;

    return GestureDetector(
      onTap: () => _addStep(node),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(node['icon'] as IconData, color: color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(node['label'] as String,
                          style: TextStyle(color: TacticalColors.textPrimary, fontSize: 12)),
                      if (isControlFlow) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('FLOW',
                              style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(node['desc'] as String,
                      style: TextStyle(color: TacticalColors.textDim, fontSize: 9)),
                ],
              ),
            ),
            Icon(Icons.add, color: color.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePalette() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TacticalColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ADD AGNO STEP', style: TacticalText.sectionHeader),
                    Text('Native workflow primitives',
                        style: TextStyle(color: TacticalColors.textDim, fontSize: 11)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: TacticalColors.textDim),
                  onPressed: () => setState(() => _showPalette = false),
                ),
              ],
            ),
          ),
          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _nodeCategories.entries.map((entry) {
                return _buildMobilePaletteCategory(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaletteCategory(String title, List<Map<String, dynamic>> nodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title.toUpperCase(),
              style: TacticalText.label.copyWith(fontSize: 11, letterSpacing: 1)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: nodes.map((n) => _buildMobilePaletteChip(n)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobilePaletteChip(Map<String, dynamic> node) {
    final color = node['color'] as Color;
    final isControlFlow = node['isControlFlow'] == true;

    return GestureDetector(
      onTap: () => _addStep(node),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: isControlFlow ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(node['icon'] as IconData, color: color, size: 16),
            const SizedBox(width: 6),
            Text(node['label'] as String,
                style: TextStyle(color: TacticalColors.textPrimary, fontSize: 12)),
            if (isControlFlow) ...[
              const SizedBox(width: 4),
              Icon(Icons.account_tree, color: color, size: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigPanel(bool isMobile) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(left: BorderSide(color: TacticalColors.border)),
      ),
      child: _selectedStepIndex != null
          ? _buildStepConfig(_selectedStepIndex!)
          : _buildWorkflowInfo(),
    );
  }

  Widget _buildWorkflowInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORKFLOW INFO', style: TacticalText.sectionHeader.copyWith(fontSize: 11)),
          const SizedBox(height: 16),
          _infoRow('Name', _activeWorkflow?.name ?? 'Untitled'),
          _infoRow('Steps', '${_steps.length} top-level'),
          _infoRow('Total', '${_activeWorkflow?.totalStepCount ?? _steps.length} steps'),
          _infoRow('Status', _activeWorkflow?.status ?? 'draft'),
          if (_activeWorkflow?.schedule != null)
            _infoRow('Schedule', _activeWorkflow!.schedule!),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('RUN WORKFLOW'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalColors.success,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _runWorkflow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConfig(int index) {
    final step = _steps[index];
    final nodeType = _findNodeType(step);
    final color = (nodeType?['color'] as Color?) ?? TacticalColors.cyan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(nodeType?['icon'] as IconData? ?? Icons.settings, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('STEP CONFIG',
                    style: TacticalText.sectionHeader.copyWith(fontSize: 11)),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: TacticalColors.error, size: 20),
                onPressed: () => _removeStep(index),
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Basic info
          _infoRow('Type', step.type),
          if (step.executor != null) _infoRow('Executor', step.executor!),
          if (step.agentId != null) _infoRow('Agent', step.agentId!),

          const SizedBox(height: 16),

          // Name field
          Text('NAME', style: TacticalText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: step.name),
            style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: TacticalColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: TacticalColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onChanged: (v) => setState(() => _steps[index] = step.copyWith(name: v)),
          ),

          // Expression field for control flow
          if (step.type == 'condition' || step.type == 'loop' || step.type == 'router') ...[
            const SizedBox(height: 16),
            Text('EXPRESSION', style: TacticalText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            TextField(
              controller: TextEditingController(text: step.expression ?? ''),
              style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                hintText: step.type == 'condition'
                    ? 'input["status"] == "approved"'
                    : step.type == 'loop'
                        ? 'last.output["done"] == True'
                        : '0',
                hintStyle: TextStyle(color: TacticalColors.textDim, fontSize: 11),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (v) => setState(() => _steps[index] = step.copyWith(expression: v)),
            ),
          ],

          // Max iterations for loop
          if (step.type == 'loop') ...[
            const SizedBox(height: 16),
            Text('MAX ITERATIONS', style: TacticalText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            TextField(
              controller: TextEditingController(text: (step.maxIterations ?? 3).toString()),
              style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (v) {
                final iterations = int.tryParse(v);
                if (iterations != null) {
                  setState(() => _steps[index] = step.copyWith(maxIterations: iterations));
                }
              },
            ),
          ],

          // Agent ID for agent type
          if (step.type == 'agent') ...[
            const SizedBox(height: 16),
            Text('AGENT ID', style: TacticalText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            TextField(
              controller: TextEditingController(text: step.agentId ?? ''),
              style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                hintText: 'e.g., assistant, researcher',
                hintStyle: TextStyle(color: TacticalColors.textDim, fontSize: 11),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: TacticalColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (v) => setState(() => _steps[index] = step.copyWith(agentId: v)),
            ),
          ],

          // Nested steps for control flow
          if (step.canHaveNestedSteps) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NESTED STEPS', style: TacticalText.label.copyWith(fontSize: 10)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: TacticalColors.cyan, size: 18),
                  onPressed: () => _showNestedStepDialog(index),
                  tooltip: 'Add nested step',
                ),
              ],
            ),
            if (step.steps?.isEmpty ?? true)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TacticalColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TacticalColors.border),
                ),
                child: Center(
                  child: Text(
                    'No nested steps',
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 11),
                  ),
                ),
              )
            else
              ...step.steps!.asMap().entries.map((e) => _buildNestedStepItem(index, e.key, e.value)),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedStepIndex = null),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: TacticalColors.border),
                  ),
                  child: Text('CLOSE', style: TextStyle(color: TacticalColors.textDim)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNestedStepItem(int parentIndex, int nestedIndex, WorkflowStep nested) {
    final nestedType = _findNodeType(nested);
    final color = nestedType?['color'] as Color? ?? TacticalColors.textDim;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Row(
        children: [
          Icon(nestedType?['icon'] as IconData? ?? Icons.circle, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nested.name,
              style: TextStyle(color: TacticalColors.textPrimary, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 14, color: TacticalColors.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              final parent = _steps[parentIndex];
              final updatedSteps = List<WorkflowStep>.from(parent.steps ?? [])
                ..removeAt(nestedIndex);
              setState(() {
                _steps[parentIndex] = parent.copyWith(steps: updatedSteps);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showNestedStepDialog(int parentIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Nested Step', style: TextStyle(color: TacticalColors.textPrimary)),
        content: SizedBox(
          width: 360,
          height: 400,
          child: ListView(
            children: _nodeCategories.entries
                .where((e) => e.key != 'Control Flow') // Don't nest control flow
                .map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key.toUpperCase(),
                        style: TacticalText.label.copyWith(fontSize: 10)),
                  ),
                  ...entry.value.map((node) {
                    final color = node['color'] as Color;
                    return GestureDetector(
                      onTap: () {
                        _addNestedStep(parentIndex, node);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(node['icon'] as IconData, color: color, size: 16),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(node['label'] as String,
                                    style: TextStyle(color: TacticalColors.textPrimary, fontSize: 12)),
                                Text(node['desc'] as String,
                                    style: TextStyle(color: TacticalColors.textDim, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: TacticalColors.textDim)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileConfigSheet() {
    if (_selectedStepIndex == null) return const SizedBox.shrink();

    final step = _steps[_selectedStepIndex!];
    final nodeType = _findNodeType(step);
    final color = (nodeType?['color'] as Color?) ?? TacticalColors.cyan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(nodeType?['icon'] as IconData? ?? Icons.settings,
                      color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.name,
                          style: TacticalText.cardTitle.copyWith(fontSize: 14)),
                      Text(_getStepDescription(step, nodeType),
                          style: TextStyle(color: TacticalColors.textDim, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: TacticalColors.error),
                  onPressed: () => _removeStep(_selectedStepIndex!),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: TacticalColors.textDim),
                  onPressed: () => setState(() => _selectedStepIndex = null),
                ),
              ],
            ),
            if (step.canHaveNestedSteps) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Nested Step'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    foregroundColor: color,
                  ),
                  onPressed: () => _showNestedStepDialog(_selectedStepIndex!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: TacticalColors.textDim, fontSize: 11)),
          Text(value,
              style: TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 11,
                fontFamily: 'monospace',
              )),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New Agno Workflow', style: TextStyle(color: TacticalColors.textPrimary)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: TacticalColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Workflow Name',
                  labelStyle: TextStyle(color: TacticalColors.textDim),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.cyan),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: TacticalColors.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: TacticalColors.textDim),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.cyan),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: TacticalColors.textDim)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.cyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              try {
                final workflow = WorkflowModel(
                  name: nameCtrl.text,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  steps: [],
                );

                final created = await ApiService.createWorkflow(workflow);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  setState(() {
                    _activeWorkflow = created;
                    _steps = [];
                    _isEditMode = true;
                  });
                  _loadWorkflows();
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _showSnackBar('Failed to create workflow: ${e.toString()}', isError: true);
                }
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}
