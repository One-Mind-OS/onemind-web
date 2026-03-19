import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import 'package:go_router/go_router.dart';

import '../models/team_model.dart';
import '../providers/api_providers.dart';

/// Team form screen - Create or edit team configuration
class TeamFormScreen extends ConsumerStatefulWidget {
  final TeamModel? team; // null for create, populated for edit

  const TeamFormScreen({super.key, this.team});

  @override
  ConsumerState<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends ConsumerState<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructionsController;

  late String _selectedModelId;
  late Set<String> _selectedMemberIds;
  late bool _respondDirectly;
  late bool _determineInputForMembers;
  late bool _delegateToAllMembers;
  late bool _markdown;
  late bool _addHistoryToContext;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.team?.name ?? '');
    _descriptionController = TextEditingController(text: widget.team?.description ?? '');
    _instructionsController = TextEditingController(
      text: widget.team?.instructions.join('\n') ?? '',
    );

    // Initialize selections
    _selectedModelId = widget.team?.modelId ?? 'us.anthropic.claude-sonnet-4-5-20250929-v1:0';
    _selectedMemberIds = Set<String>.from(widget.team?.memberIds ?? []);
    _respondDirectly = widget.team?.respondDirectly ?? false;
    _determineInputForMembers = widget.team?.determineInputForMembers ?? true;
    _delegateToAllMembers = widget.team?.delegateToAllMembers ?? false;
    _markdown = widget.team?.markdown ?? true;
    _addHistoryToContext = widget.team?.addHistoryToContext ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _getModelName(String modelId) {
    final modelsAsync = ref.read(modelsProvider);
    return modelsAsync.when(
      data: (models) {
        try {
          return models.firstWhere((m) => m.modelId == modelId).modelName;
        } catch (e) {
          return 'Unknown Model';
        }
      },
      loading: () => 'Loading...',
      error: (_, _) => 'Unknown Model',
    );
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      // Validate member selection
      if (_selectedMemberIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one team member'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Build team model
      final team = TeamModel(
        id: widget.team?.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        modelId: _selectedModelId,
        modelName: _getModelName(_selectedModelId),
        memberIds: _selectedMemberIds.toList(),
        respondDirectly: _respondDirectly,
        determineInputForMembers: _determineInputForMembers,
        delegateToAllMembers: _delegateToAllMembers,
        instructions: _instructionsController.text
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        markdown: _markdown,
        addHistoryToContext: _addHistoryToContext,
      );

      try {
        // Call API (no loading dialog to avoid Navigator issues with GoRouter)
        final mutations = ref.read(teamMutationsProvider);
        if (widget.team == null) {
          // Create new team
          await mutations.createTeam(team);
        } else {
          // Update existing team
          await mutations.updateTeam(widget.team!.id!, team);
        }

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.team == null
                  ? 'Team created successfully!'
                  : 'Team updated successfully!',
            ),
            backgroundColor: const Color(0xFFE63946),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to teams list using GoRouter
        if (mounted) {
          context.go('/teams');
        }
      } catch (e) {
        if (!mounted) return;

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save team: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Text(
          widget.team == null ? 'CREATE TEAM' : 'EDIT TEAM',
          style: TextStyle(
            color: Color(0xFFE63946),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
        actions: [
          // Save button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _saveTeam,
              icon: Icon(Icons.save, size: 18),
              label: Text(
                'SAVE TEAM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE63946),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              SizedBox(height: 24),
              _buildMemberSelector(),
              SizedBox(height: 24),
              _buildCoordinationFlags(),
              SizedBox(height: 24),
              _buildModelSelector(),
              SizedBox(height: 24),
              _buildInstructions(),
              SizedBox(height: 24),
              _buildOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BASIC INFORMATION'),
        SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          label: 'Team Name',
          hint: 'e.g., Research Team, Dev Team',
          validator: (value) => value?.isEmpty == true ? 'Name required' : null,
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description (Optional)',
          hint: 'What does this team do?',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildMemberSelector() {
    final agentsAsync = ref.watch(agentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TEAM MEMBERS'),
        SizedBox(height: 8),
        Text(
          'Select agents to include in this team',
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12),
        agentsAsync.when(
          data: (agents) {
            if (agents.isEmpty) {
              return Text(
                'No agents available. Create agents first.',
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: agents.map((agent) {
                final isSelected = _selectedMemberIds.contains(agent.id);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMemberIds.remove(agent.id);
                      } else {
                        _selectedMemberIds.add(agent.id!);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE63946).withValues(alpha: 0.1)
                          : const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE63946)
                            : const Color(0xFFE63946).withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xFFE63946),
                              size: 16,
                            ),
                          ),
                        Text(
                          agent.name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFE63946)
                                : const Color(0xFFE63946).withValues(alpha: 0.7),
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: Color(0xFFE63946)),
          ),
          error: (error, stack) => Text(
            'Error loading agents: $error',
            style: TextStyle(color: Colors.red, fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinationFlags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TEAM COORDINATION (AgentOS Flags)'),
        SizedBox(height: 8),
        Text(
          'Configure how the team coordinates member agents',
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12),
        _buildCheckbox(
          'Respond Directly',
          _respondDirectly,
          (value) => setState(() => _respondDirectly = value),
          subtitle: 'Team lead responds directly without delegating',
        ),
        _buildCheckbox(
          'Determine Input For Members',
          _determineInputForMembers,
          (value) => setState(() => _determineInputForMembers = value),
          subtitle: 'Team lead determines what input to give each member',
        ),
        _buildCheckbox(
          'Delegate To All Members',
          _delegateToAllMembers,
          (value) => setState(() => _delegateToAllMembers = value),
          subtitle: 'Delegate task to all team members simultaneously',
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    final modelsAsync = ref.watch(modelsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('COORDINATOR MODEL'),
        SizedBox(height: 8),
        Text(
          'Model used by the team coordinator',
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE63946).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedModelId,
              isExpanded: true,
              dropdownColor: const Color(0xFF0A0A0A),
              style: TextStyle(
                color: Color(0xFFE63946),
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              items: modelsAsync.when(
                data: (models) => models.map((model) {
                  return DropdownMenuItem<String>(
                    value: model.modelId,
                    child: Text('${model.modelName} (${model.provider})'),
                  );
                }).toList(),
                loading: () => [
                  const DropdownMenuItem<String>(
                    value: 'loading',
                    enabled: false,
                    child: Text('Loading models...'),
                  ),
                ],
                error: (_, _) => [
                  DropdownMenuItem<String>(
                    value: _selectedModelId,
                    child: Text('Error loading models'),
                  ),
                ],
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedModelId = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('INSTRUCTIONS'),
        SizedBox(height: 8),
        Text(
          'Team coordination instructions (one per line)',
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.6),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: _instructionsController,
          label: 'Instructions',
          hint: 'Coordinate team members effectively\nDelegate tasks based on expertise',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('OPTIONS'),
        SizedBox(height: 12),
        _buildCheckbox(
          'Enable Markdown',
          _markdown,
          (value) => setState(() => _markdown = value),
        ),
        _buildCheckbox(
          'Add History to Context',
          _addHistoryToContext,
          (value) => setState(() => _addHistoryToContext = value),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xFFE63946),
        fontSize: 13,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: Color(0xFFE63946),
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: const Color(0xFFE63946).withValues(alpha: 0.7),
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: const Color(0xFFE63946).withValues(alpha: 0.4),
          fontFamily: 'monospace',
          fontSize: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: const Color(0xFFE63946).withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: const Color(0xFFE63946).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(0xFFE63946),
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged, {String? subtitle}) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (val) => onChanged(val ?? false),
              activeColor: const Color(0xFFE63946),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFFE63946),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFFE63946).withValues(alpha: 0.6),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
