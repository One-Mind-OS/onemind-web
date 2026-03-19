import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import 'package:go_router/go_router.dart';

import '../models/agent_model.dart';
import '../providers/api_providers.dart';
import '../widgets/reasoning_indicator.dart';
import 'skill_tree_screen.dart';

/// Agents management screen - List, create, edit, delete agents
class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  String _searchQuery = '';
  bool _isReloading = false;

  List<AgentModel> _filterAgents(List<AgentModel> agents) {
    if (_searchQuery.isEmpty) return agents;
    return agents.where((agent) {
      return agent.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (agent.role?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (agent.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _reloadConfigs() async {
    setState(() => _isReloading = true);

    try {
      await ref.read(agentMutationsProvider).reloadAgentConfigs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agent configs reloaded successfully!'),
            backgroundColor: TacticalColors.primary,
          ),
        );
        // Refresh the agent list
        ref.invalidate(agentsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reload configs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReloading = false);
      }
    }
  }

  Future<void> _deleteAgent(String agentId, String agentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Agent',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete "$agentName"?\n\nConfigs will be reloaded automatically.',
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
        await ref.read(agentMutationsProvider).deleteAgent(agentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Agent "$agentName" deleted. Reloading configs...'),
              backgroundColor: TacticalColors.primary,
            ),
          );
          // Auto-reload configs after delete
          await _reloadConfigs();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete agent: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'AGENTS HUB',
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
              Tab(text: 'AGENTS'),
              Tab(text: 'SKILLS'),
              Tab(text: 'PRESETS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAgentsTab(),
            const SkillTreeScreen(embedded: true),
            _buildPresetsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentsTab() {
    final agentsAsync = ref.watch(agentsProvider);

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
                      hintText: 'Search agents...',
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
              // Reload button
              ElevatedButton.icon(
                onPressed: _isReloading ? null : _reloadConfigs,
                icon: _isReloading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TacticalColors.background,
                        ),
                      )
                    : Icon(Icons.refresh, size: 18),
                label: Text(
                  _isReloading ? 'RELOADING...' : 'RELOAD CONFIGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TacticalColors.success,
                  foregroundColor: TacticalColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Create button
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/agents/create');
                },
                icon: Icon(Icons.add, size: 18),
                label: Text(
                  'CREATE AGENT',
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

        // Agents grid
        Expanded(
          child: agentsAsync.when(
            data: (agents) {
              final filteredAgents = _filterAgents(agents);
              if (filteredAgents.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No agents configured' : 'No agents found',
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
                itemCount: filteredAgents.length,
                itemBuilder: (context, index) {
                  return _AgentCard(
                    agent: filteredAgents[index],
                    onDelete: _deleteAgent,
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
                    'Failed to load agents',
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
                    onPressed: () => ref.invalidate(agentsProvider),
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

  Widget _buildPresetsTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 64, color: TacticalColors.primary.withValues(alpha: 0.3)),
          SizedBox(height: 16),
          Text(
            'Agent Presets Coming Soon',
            style: TextStyle(
              color: TacticalColors.primary.withValues(alpha: 0.7),
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pre-configured agent templates for specialized tasks',
            style: TextStyle(
              color: TacticalColors.primary.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Agent card component
class _AgentCard extends ConsumerStatefulWidget {
  final AgentModel agent;
  final Function(String, String) onDelete;

  const _AgentCard({required this.agent, required this.onDelete});

  @override
  ConsumerState<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends ConsumerState<_AgentCard> {
  bool _isHovered = false;

  /// Check if agent has extended reasoning enabled
  bool _hasExtendedReasoning(String agentName) {
    final reasoningAgents = ['researcher', 'analyst', 'coder'];
    return reasoningAgents.contains(agentName.toLowerCase());
  }

  Future<void> _runAgent() async {
    // Show quick run dialog
    final messageController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Run ${widget.agent.name}',
          style: TextStyle(
            color: TacticalColors.primary,
            fontFamily: 'monospace',
          ),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your message:',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 3,
                autofocus: true,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
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
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.of(context).pop(message);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
              foregroundColor: TacticalColors.background,
            ),
            child: Text('RUN'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      try {
        // Execute agent
        await ref.read(agentRunMutationsProvider).runAgent(
              widget.agent.id!,
              result,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Agent "${widget.agent.name}" started successfully'),
              backgroundColor: TacticalColors.success,
              action: SnackBarAction(
                label: 'VIEW CHAT',
                textColor: TacticalColors.background,
                onPressed: () {
                  context.go('/chat', extra: widget.agent);
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to run agent: $e'),
              backgroundColor: TacticalColors.error,
            ),
          );
        }
      }
    }
  }

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
                  // Name and role
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.agent.name,
                              style: TextStyle(
                                color: TacticalColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (widget.agent.role != null) ...[
                              SizedBox(height: 4),
                              Text(
                                widget.agent.role!,
                                style: TextStyle(
                                  color: TacticalColors.primary.withValues(alpha: 0.6),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Description
                  if (widget.agent.description != null)
                    Text(
                      widget.agent.description!,
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

                  // Model and tools info
                  Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.agent.modelName,
                          style: TextStyle(
                            color: TacticalColors.primary.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.build,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${widget.agent.tools.length} tools',
                        style: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  // Reasoning badge for agents with extended reasoning
                  if (_hasExtendedReasoning(widget.agent.name)) ...[
                    SizedBox(height: 8),
                    ReasoningBadge(),
                  ],
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
                      tooltip: 'Run Agent',
                      onTap: _runAgent,
                      isSuccess: true,
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onTap: () {
                        context.go('/agents/edit/${widget.agent.id}', extra: widget.agent);
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: () {
                        widget.onDelete(widget.agent.id!, widget.agent.name);
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
}

/// Small icon button for agent card actions
class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isSuccess;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? TacticalColors.error
        : isSuccess
            ? TacticalColors.success
            : TacticalColors.primary;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
