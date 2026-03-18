import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import 'package:go_router/go_router.dart';

import '../models/agent_model.dart';
import '../providers/api_providers.dart';

/// Agent creation/editing form with tabbed interface
class AgentFormScreen extends ConsumerStatefulWidget {
  final AgentModel? agent; // null for create, populated for edit

  const AgentFormScreen({super.key, this.agent});

  @override
  ConsumerState<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends ConsumerState<AgentFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AgentModel _formData;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roleController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedModelId = 'us.anthropic.claude-sonnet-4-5-20250929-v1:0';
  Set<String> _selectedTools = {};
  Set<String> _selectedKnowledgeBases = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize with existing agent data or empty
    _formData = widget.agent ?? AgentModel.empty();

    // Populate form fields
    _nameController.text = _formData.name;
    _descriptionController.text = _formData.description ?? '';
    _roleController.text = _formData.role ?? '';
    _instructionsController.text = _formData.instructions.join('\n');
    _selectedModelId = _formData.modelId;
    _selectedTools = Set.from(_formData.tools);
    _selectedKnowledgeBases = Set.from(_formData.knowledgeBases);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _roleController.dispose();
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

  Future<void> _saveAgent() async {
    if (_formKey.currentState!.validate()) {
      // Build updated agent model
      final updatedAgent = _formData.copyWith(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        role: _roleController.text.isEmpty ? null : _roleController.text,
        instructions: _instructionsController.text.split('\n').where((s) => s.isNotEmpty).toList(),
        modelId: _selectedModelId,
        modelName: _getModelName(_selectedModelId),
        tools: _selectedTools.toList(),
        knowledgeBases: _selectedKnowledgeBases.toList(),
      );

      try {
        // Call API (no loading dialog to avoid Navigator issues with GoRouter)
        final mutations = ref.read(agentMutationsProvider);
        if (widget.agent == null) {
          // Create new agent
          await mutations.createAgent(updatedAgent);
        } else {
          // Update existing agent
          await mutations.updateAgent(widget.agent!.id!, updatedAgent);
        }

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.agent == null
                  ? 'Agent created successfully!'
                  : 'Agent updated successfully!',
            ),
            backgroundColor: const Color(0xFFE63946),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to agents list using GoRouter
        if (mounted) {
          context.go('/agents');
        }
      } catch (e) {
        if (!mounted) return;

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save agent: $e'),
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
          widget.agent == null ? 'CREATE AGENT' : 'EDIT AGENT',
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
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _saveAgent,
              icon: Icon(Icons.save, size: 18),
              label: Text(
                'SAVE',
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFE63946),
          labelColor: const Color(0xFFE63946),
          unselectedLabelColor: const Color(0xFFE63946).withValues(alpha: 0.5),
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
          tabs: const [
            Tab(text: 'BASIC INFO'),
            Tab(text: 'MODEL & TOOLS'),
            Tab(text: 'KNOWLEDGE & MEMORY'),
            Tab(text: 'HISTORY & CONTEXT'),
            Tab(text: 'ADVANCED'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildModelToolsTab(),
            _buildKnowledgeMemoryTab(),
            _buildHistoryContextTab(),
            _buildAdvancedTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: Basic Info
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Agent Identity'),
          SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Agent Name *',
            hint: 'e.g., Research Assistant',
            validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _roleController,
            label: 'Role',
            hint: 'e.g., Research Specialist',
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Brief description of agent capabilities',
            maxLines: 3,
          ),
          SizedBox(height: 24),
          _buildSectionTitle('Instructions'),
          SizedBox(height: 16),
          _buildTextField(
            controller: _instructionsController,
            label: 'System Instructions',
            hint: 'Enter instructions (one per line)',
            maxLines: 8,
          ),
          SizedBox(height: 16),
          _buildSwitch(
            label: 'Enable Markdown',
            value: _formData.markdown,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(markdown: value);
              });
            },
          ),
        ],
      ),
    );
  }

  // Tab 2: Model & Tools
  Widget _buildModelToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Language Model'),
          SizedBox(height: 16),
          _buildModelSelector(),
          SizedBox(height: 32),
          _buildSectionTitle('Tools'),
          SizedBox(height: 8),
          Text(
            'Select tools this agent can use',
            style: TextStyle(
              color: const Color(0xFFE63946).withValues(alpha: 0.6),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 16),
          _buildToolSelector(),
        ],
      ),
    );
  }

  // Tab 3: Knowledge & Memory
  Widget _buildKnowledgeMemoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Knowledge Bases (RAG)'),
          SizedBox(height: 16),
          _buildKnowledgeBaseSelector(),
          SizedBox(height: 16),
          _buildSwitch(
            label: 'Add Knowledge to Context',
            value: _formData.addKnowledgeToContext,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(addKnowledgeToContext: value);
              });
            },
          ),
          SizedBox(height: 32),
          _buildSectionTitle('Memory Management'),
          SizedBox(height: 16),
          _buildSwitch(
            label: 'Update Memory on Run',
            value: _formData.updateMemoryOnRun,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(updateMemoryOnRun: value);
              });
            },
          ),
          SizedBox(height: 12),
          _buildSwitch(
            label: 'Enable Agentic Memory',
            subtitle: 'AI-managed memory with automatic updates',
            value: _formData.enableAgenticMemory,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(enableAgenticMemory: value);
              });
            },
          ),
          SizedBox(height: 12),
          _buildSwitch(
            label: 'Add Memories to Context',
            value: _formData.addMemoriesToContext,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(addMemoriesToContext: value);
              });
            },
          ),
        ],
      ),
    );
  }

  // Tab 4: History & Context
  Widget _buildHistoryContextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Conversation History'),
          SizedBox(height: 16),
          _buildSwitch(
            label: 'Add History to Context',
            value: _formData.addHistoryToContext,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(addHistoryToContext: value);
              });
            },
          ),
          if (_formData.addHistoryToContext) ...[
            SizedBox(height: 16),
            _buildNumberField(
              label: 'Number of History Runs',
              value: _formData.numHistoryRuns,
              onChanged: (value) {
                setState(() {
                  _formData = _formData.copyWith(numHistoryRuns: value);
                });
              },
            ),
            SizedBox(height: 16),
            _buildNumberField(
              label: 'Number of History Messages',
              value: _formData.numHistoryMessages,
              onChanged: (value) {
                setState(() {
                  _formData = _formData.copyWith(numHistoryMessages: value);
                });
              },
            ),
          ],
          SizedBox(height: 24),
          _buildSwitch(
            label: 'Add Datetime to Context',
            value: _formData.addDatetimeToContext,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(addDatetimeToContext: value);
              });
            },
          ),
          SizedBox(height: 32),
          _buildSectionTitle('Session Management'),
          SizedBox(height: 16),
          _buildSwitch(
            label: 'Enable Session Summaries',
            value: _formData.enableSessionSummaries,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(enableSessionSummaries: value);
              });
            },
          ),
          SizedBox(height: 12),
          _buildSwitch(
            label: 'Add Session Summary to Context',
            value: _formData.addSessionSummaryToContext,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(addSessionSummaryToContext: value);
              });
            },
          ),
          SizedBox(height: 12),
          _buildSwitch(
            label: 'Enable Agentic State',
            subtitle: 'Persistent state across sessions',
            value: _formData.enableAgenticState,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(enableAgenticState: value);
              });
            },
          ),
        ],
      ),
    );
  }

  // Tab 5: Advanced
  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Advanced Settings'),
          SizedBox(height: 16),
          _buildNumberField(
            label: 'Tool Call Limit',
            value: _formData.toolCallLimit,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(toolCallLimit: value);
              });
            },
          ),
          SizedBox(height: 16),
          _buildNumberField(
            label: 'Reasoning Steps',
            value: _formData.reasoningSteps,
            onChanged: (value) {
              setState(() {
                _formData = _formData.copyWith(reasoningSteps: value);
              });
            },
          ),
        ],
      ),
    );
  }

  // UI Components

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Color(0xFFE63946),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: Color(0xFFE63946),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFE63946).withValues(alpha: 0.4),
              fontFamily: 'monospace',
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
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE63946).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFFE63946),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFFE63946).withValues(alpha: 0.6),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFE63946),
            activeTrackColor: const Color(0xFFE63946).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Color(0xFFE63946),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          onChanged: (text) {
            onChanged(int.tryParse(text));
          },
          decoration: InputDecoration(
            hintText: 'Optional',
            hintStyle: TextStyle(
              color: const Color(0xFFE63946).withValues(alpha: 0.4),
              fontFamily: 'monospace',
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
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE63946).withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ref.watch(modelsProvider).when(
            data: (models) {
              // Ensure the selected model exists in the list
              final modelIds = models.map((m) => m.modelId).toSet();
              return modelIds.contains(_selectedModelId) ? _selectedModelId : (models.isNotEmpty ? models.first.modelId : null);
            },
            loading: () => 'loading',
            error: (_, _) => 'error',
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF0A0A0A),
          style: TextStyle(
            color: Color(0xFFE63946),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          items: ref.watch(modelsProvider).when(
            data: (models) {
              // Ensure unique model IDs
              final uniqueModels = <String, dynamic>{};
              for (var model in models) {
                uniqueModels[model.modelId] = model;
              }
              return uniqueModels.values.map((model) {
                return DropdownMenuItem<String>(
                  value: model.modelId,
                  child: Text('${model.modelName} (${model.provider})'),
                );
              }).toList();
            },
            loading: () => [
              const DropdownMenuItem<String>(
                value: 'loading',
                enabled: false,
                child: Text('Loading models...'),
              ),
            ],
            error: (_, _) => [
              const DropdownMenuItem<String>(
                value: 'error',
                enabled: false,
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
    );
  }

  Widget _buildToolSelector() {
    // AgentOS doesn't expose /tools endpoint - tools are pre-configured per agent
    // Provide a simple text field for manually specifying tool names

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'TOOLS (COMMA-SEPARATED)',
            style: TextStyle(
              color: const Color(0xFFE63946).withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ),
        TextField(
          onChanged: (value) {
            setState(() {
              _selectedTools = value
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toSet();
            });
          },
          decoration: InputDecoration(
            hintText: 'e.g., web_search, calculator, file_system',
            hintStyle: TextStyle(
              color: const Color(0xFFE63946).withValues(alpha: 0.4),
              fontFamily: 'monospace',
              fontSize: 11,
            ),
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFE63946).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFE63946).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color(0xFFE63946),
                width: 2,
              ),
            ),
          ),
          style: TextStyle(
            color: Color(0xFFE63946),
            fontFamily: 'monospace',
            fontSize: 12,
          ),
          maxLines: 2,
        ),
        SizedBox(height: 8),
        Text(
          'Tools are pre-configured in backend/tools/ - specify tool names to enable',
          style: TextStyle(
            color: const Color(0xFFE63946).withValues(alpha: 0.5),
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeBaseSelector() {
    // Mock knowledge bases (will be replaced with API call)
    final knowledgeBases = [
      {'id': 'kb_1', 'name': 'Documentation', 'count': 15},
      {'id': 'kb_2', 'name': 'Research Papers', 'count': 42},
      {'id': 'kb_3', 'name': 'Code Examples', 'count': 28},
    ];

    return Column(
      children: knowledgeBases.map((kb) {
        final isSelected = _selectedKnowledgeBases.contains(kb['id']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedKnowledgeBases.remove(kb['id']);
                } else {
                  _selectedKnowledgeBases.add(kb['id'] as String);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE63946)
                      : const Color(0xFFE63946).withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: const Color(0xFFE63946),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kb['name'] as String,
                          style: TextStyle(
                            color: Color(0xFFE63946),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${kb['count']} documents',
                          style: TextStyle(
                            color: const Color(0xFFE63946).withValues(alpha: 0.6),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
