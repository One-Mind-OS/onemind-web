import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/workflow_model.dart';
import '../providers/api_providers.dart';
import 'workflow_builder_screen.dart';

/// Workflows management screen - List, create, edit, delete, and run workflows
class WorkflowsScreen extends ConsumerStatefulWidget {
  const WorkflowsScreen({super.key});

  @override
  ConsumerState<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

class _WorkflowsScreenState extends ConsumerState<WorkflowsScreen> {
  String _searchQuery = '';

  List<WorkflowModel> _filterWorkflows(List<WorkflowModel> workflows) {
    if (_searchQuery.isEmpty) return workflows;
    return workflows.where((workflow) {
      return workflow.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (workflow.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _deleteWorkflow(String workflowId, String workflowName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Workflow',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete "$workflowName"?\n\nThis action cannot be undone.',
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(workflowMutationsProvider).deleteWorkflow(workflowId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Workflow "$workflowName" deleted successfully.'),
              backgroundColor: TacticalColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete workflow: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _createWorkflow() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Create Workflow',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Workflow Name',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Workflow name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: TacticalColors.primary),
            child: Text('CREATE'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final workflow = WorkflowModel(
          id: '', // Will be set by backend
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref.read(workflowMutationsProvider).createWorkflow(workflow);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Workflow "${workflow.name}" created successfully'),
              backgroundColor: TacticalColors.primary,
            ),
          );
          ref.invalidate(workflowsProvider); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create workflow: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _runWorkflow(String workflowId, String workflowName) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Running workflow "$workflowName"...'),
            backgroundColor: TacticalColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final result = await ref.read(workflowMutationsProvider).runWorkflow(workflowId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workflow "$workflowName" ${result.status}: ${result.output ?? "No output"}'),
            backgroundColor: result.status == 'completed' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to run workflow: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _editWorkflow(WorkflowModel workflow) async {
    final nameController = TextEditingController(text: workflow.name);
    final descriptionController = TextEditingController(text: workflow.description ?? '');

    // Create a list of steps that we can modify
    final steps = List<WorkflowStep>.from(workflow.steps);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _WorkflowEditDialog(
        nameController: nameController,
        descriptionController: descriptionController,
        initialSteps: steps,
      ),
    );

    if (result == true && mounted) {
      try {
        final updatedWorkflow = workflow.copyWith(
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          steps: steps,
          updatedAt: DateTime.now(),
        );

        await ref.read(workflowMutationsProvider).updateWorkflow(workflow.id!, updatedWorkflow);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Workflow "${updatedWorkflow.name}" updated successfully'),
              backgroundColor: TacticalColors.primary,
            ),
          );
          ref.invalidate(workflowsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update workflow: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflowsAsync = ref.watch(workflowsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'AUTOMATION',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: TacticalColors.primary,
            labelColor: TacticalColors.primary,
            unselectedLabelColor: TacticalColors.primary.withValues(alpha: 0.4),
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'WORKFLOWS'),
              Tab(text: 'BUILDER'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkflowsTab(workflowsAsync),
            const WorkflowBuilderScreen(embedded: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowsTab(AsyncValue<List<WorkflowModel>> workflowsAsync) {
    return Column(
      children: [
        // Search and create bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            border: Border(
              bottom: BorderSide(
                color: TacticalColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: TacticalColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search workflows...',
                      hintStyle: TextStyle(
                        color: TacticalColors.primary.withValues(alpha: 0.4),
                        fontFamily: 'monospace',
                      ),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Create button
              ElevatedButton.icon(
                onPressed: _createWorkflow,
                icon: Icon(Icons.add, size: 18),
                label: Text(
                  'CREATE WORKFLOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TacticalColors.primary,
                  foregroundColor: TacticalColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Workflows grid
        Expanded(
          child: workflowsAsync.when(
            data: (workflows) {
              final filteredWorkflows = _filterWorkflows(workflows);
              if (filteredWorkflows.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No workflows configured' : 'No workflows found',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.5),
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: filteredWorkflows.length,
                itemBuilder: (context, index) {
                  return _WorkflowCard(
                    workflow: filteredWorkflows[index],
                    onDelete: _deleteWorkflow,
                    onRun: _runWorkflow,
                    onEdit: _editWorkflow,
                  );
                },
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.withValues(alpha: 0.7),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load workflows',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.7),
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(workflowsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.primary,
                      foregroundColor: TacticalColors.background,
                    ),
                    child: Text('RETRY'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Workflow card component
class _WorkflowCard extends StatefulWidget {
  final WorkflowModel workflow;
  final Function(String, String) onDelete;
  final Function(String, String) onRun;
  final Function(WorkflowModel) onEdit;

  const _WorkflowCard({
    required this.workflow,
    required this.onDelete,
    required this.onRun,
    required this.onEdit,
  });

  @override
  State<_WorkflowCard> createState() => _WorkflowCardState();
}

class _WorkflowCardState extends State<_WorkflowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: TacticalColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? TacticalColors.primary.withValues(alpha: 0.5)
                : TacticalColors.primary.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: TacticalColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.workflow.name,
                          style: TextStyle(
                            color: TacticalColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Description
                  if (widget.workflow.description != null)
                    Text(
                      widget.workflow.description!,
                      style: TextStyle(
                        color: TacticalColors.primary.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const Spacer(),

                  // Steps count
                  Row(
                    children: [
                      Icon(
                        Icons.view_timeline,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${widget.workflow.steps.length} steps',
                        style: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _formatDate(widget.workflow.updatedAt),
                        style: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons (visible on hover)
            if (_isHovered)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _IconButton(
                      icon: Icons.play_arrow,
                      tooltip: 'Run',
                      onTap: () {
                        widget.onRun(widget.workflow.id!, widget.workflow.name);
                      },
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onTap: () {
                        widget.onEdit(widget.workflow);
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: () {
                        widget.onDelete(widget.workflow.id!, widget.workflow.name);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Small icon button for workflow card actions
class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? color;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isDestructive ? TacticalColors.error : TacticalColors.primary);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: buttonColor.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: buttonColor,
          ),
        ),
      ),
    );
  }
}

/// Workflow edit dialog
class _WorkflowEditDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<WorkflowStep> initialSteps;

  const _WorkflowEditDialog({
    required this.nameController,
    required this.descriptionController,
    required this.initialSteps,
  });

  @override
  State<_WorkflowEditDialog> createState() => _WorkflowEditDialogState();
}

class _WorkflowEditDialogState extends State<_WorkflowEditDialog> {
  late List<WorkflowStep> steps;

  @override
  void initState() {
    super.initState();
    steps = List.from(widget.initialSteps);
  }

  void _addStep() {
    setState(() {
      steps.add(WorkflowStep(
        name: 'New Step',
        type: 'step',
        executor: 'transform',
        config: {},
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  void _editStep(int index) async {
    final step = steps[index];
    final nameController = TextEditingController(text: step.name);
    final descriptionController = TextEditingController(text: step.description ?? '');
    String selectedType = step.type;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Edit Step',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Step Name',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'Step Type',
                      labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TacticalColors.primary),
                      ),
                    ),
                    dropdownColor: TacticalColors.surface,
                    items: const [
                      // Agno-native step types
                      DropdownMenuItem(value: 'step', child: Text('Step (Executor)')),
                      DropdownMenuItem(value: 'agent', child: Text('Agent')),
                      DropdownMenuItem(value: 'parallel', child: Text('Parallel')),
                      DropdownMenuItem(value: 'condition', child: Text('Condition')),
                      DropdownMenuItem(value: 'loop', child: Text('Loop')),
                      DropdownMenuItem(value: 'router', child: Text('Router')),
                      DropdownMenuItem(value: 'steps', child: Text('Step Group')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Step name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: TacticalColors.primary),
            child: Text('SAVE'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        steps[index] = step.copyWith(
          name: nameController.text.trim(),
          type: selectedType,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        );
      });
    }
  }

  void _moveStepUp(int index) {
    if (index == 0) return;
    setState(() {
      final step = steps.removeAt(index);
      steps.insert(index - 1, step);
    });
  }

  void _moveStepDown(int index) {
    if (index == steps.length - 1) return;
    setState(() {
      final step = steps.removeAt(index);
      steps.insert(index + 1, step);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TacticalColors.surface,
      title: Text(
        'Edit Workflow',
        style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextField(
                controller: widget.nameController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Workflow Name',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description field
              TextField(
                controller: widget.descriptionController,
                style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: TacticalColors.primary.withValues(alpha: 0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Steps section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workflow Steps',
                    style: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.9),
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addStep,
                    icon: Icon(Icons.add, size: 16),
                    label: Text('ADD STEP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.primary,
                      foregroundColor: TacticalColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Steps list
              if (steps.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TacticalColors.background,
                    border: Border.all(
                      color: TacticalColors.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No steps added yet',
                      style: TextStyle(
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: TacticalColors.background,
                    border: Border.all(
                      color: TacticalColors.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: steps.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: TacticalColors.primary.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: TacticalColors.primary.withValues(alpha: 0.2),
                          radius: 16,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: TacticalColors.primary,
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          step.name,
                          style: TextStyle(
                            color: TacticalColors.primary,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          'Type: ${step.type}${step.description != null ? ' - ${step.description}' : ''}',
                          style: TextStyle(
                            color: TacticalColors.primary.withValues(alpha: 0.6),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: index == 0
                                    ? TacticalColors.primary.withValues(alpha: 0.3)
                                    : TacticalColors.primary,
                              ),
                              onPressed: index == 0 ? null : () => _moveStepUp(index),
                              tooltip: 'Move Up',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: index == steps.length - 1
                                    ? TacticalColors.primary.withValues(alpha: 0.3)
                                    : TacticalColors.primary,
                              ),
                              onPressed: index == steps.length - 1 ? null : () => _moveStepDown(index),
                              tooltip: 'Move Down',
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 16, color: TacticalColors.primary),
                              onPressed: () => _editStep(index),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              onPressed: () => _removeStep(index),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (widget.nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Workflow name is required'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            // Update the steps list with the modified steps
            widget.initialSteps.clear();
            widget.initialSteps.addAll(steps);
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(foregroundColor: TacticalColors.primary),
          child: Text('SAVE'),
        ),
      ],
    );
  }
}
