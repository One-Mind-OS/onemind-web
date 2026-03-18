import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/memory_model.dart';
import '../providers/api_providers.dart';

/// Memories management screen - Simplified for AgentOS
class MemoriesScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const MemoriesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  String _searchQuery = '';

  List<MemoryModel> _filterMemories(List<MemoryModel> memories) {
    if (_searchQuery.isEmpty) return memories;

    return memories.where((m) {
      return m.memory.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.topicsDisplay.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showCreateMemoryDialog() async {
    final memoryController = TextEditingController();
    final userIdController = TextEditingController(text: 'default-user');
    final agentIdController = TextEditingController();
    final topicsController = TextEditingController();

    // Fetch agents for selection
    final agentsAsync = ref.read(agentsProvider);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Create Memory',
          style: TextStyle(
            color: TacticalColors.primary,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User ID
              Text(
                'User ID',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: userIdController,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter user ID...',
                  hintStyle: TextStyle(
                    color: TacticalColors.primary.withValues(alpha: 0.4),
                    fontFamily: 'monospace',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Agent ID (REQUIRED by AgentOS)
              Text(
                'Agent ID (required)',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              agentsAsync.when(
                data: (agents) => DropdownButtonFormField<String>(
                  dropdownColor: TacticalColors.surface,
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Select an agent...',
                    hintStyle: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.4),
                      fontFamily: 'monospace',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: TacticalColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: TacticalColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TacticalColors.primary),
                    ),
                  ),
                  items: agents.map((agent) {
                    return DropdownMenuItem<String>(
                      value: agent.id,
                      child: Text(agent.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      agentIdController.text = value;
                    }
                  },
                ),
                loading: () => CircularProgressIndicator(color: TacticalColors.primary),
                error: (error, stack) => TextField(
                  controller: agentIdController,
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter agent ID manually...',
                    hintStyle: TextStyle(
                      color: TacticalColors.primary.withValues(alpha: 0.4),
                      fontFamily: 'monospace',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: TacticalColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: TacticalColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: TacticalColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Memory content
              Text(
                'Memory Content',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: memoryController,
                maxLines: 4,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter memory content...',
                  hintStyle: TextStyle(
                    color: TacticalColors.primary.withValues(alpha: 0.4),
                    fontFamily: 'monospace',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: TacticalColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Topics (optional)
              Text(
                'Topics (optional, comma-separated)',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: topicsController,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., work, personal, important',
                  hintStyle: TextStyle(
                    color: TacticalColors.primary.withValues(alpha: 0.4),
                    fontFamily: 'monospace',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('CREATE'),
          ),
        ],
      ),
    );

    if (result == true &&
        memoryController.text.isNotEmpty &&
        userIdController.text.isNotEmpty &&
        agentIdController.text.isNotEmpty) {
      try {
        // Parse topics
        final topicsText = topicsController.text.trim();
        final topics = topicsText.isNotEmpty
            ? topicsText.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : null;

        final memory = MemoryModel(
          memoryId: '', // Will be generated by backend
          memory: memoryController.text,
          userId: userIdController.text,
          agentId: agentIdController.text, // REQUIRED by AgentOS
          topics: topics,
        );

        await ref.read(memoryMutationsProvider).createMemory(memory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Memory created successfully'),
              backgroundColor: TacticalColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create memory: $e'),
              backgroundColor: TacticalColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteMemory(String memoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Memory',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete this memory?',
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
        await ref.read(memoryMutationsProvider).deleteMemory(memoryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Memory deleted successfully'),
              backgroundColor: TacticalColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete memory: $e'),
              backgroundColor: TacticalColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesProvider);

    final body = Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(TacticalSpacing.md),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            border: Border(
              bottom: BorderSide(
                color: TacticalColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TacticalText.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search memories...',
                    hintStyle: TextStyle(
                      color: TacticalColors.textMuted,
                      fontFamily: 'monospace',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: TacticalColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TacticalRadius.md),
                      borderSide: BorderSide(color: TacticalColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TacticalRadius.md),
                      borderSide: BorderSide(color: TacticalColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TacticalRadius.md),
                      borderSide: BorderSide(color: TacticalColors.primary),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showCreateMemoryDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'CREATE',
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

        // Memory list
        Expanded(
          child: memoriesAsync.when(
            data: (memories) {
              final filteredMemories = _filterMemories(memories);

              if (filteredMemories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.memory_outlined,
                        size: 64,
                        color: TacticalColors.textMuted.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: TacticalSpacing.lg),
                      Text(
                        'NO MEMORIES',
                        style: TacticalText.screenTitle.copyWith(
                          fontSize: 18,
                          color: TacticalColors.textMuted,
                        ),
                      ),
                      SizedBox(height: TacticalSpacing.sm),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No memories match your search.'
                            : 'No memories have been created yet.',
                        style: TacticalText.bodySmall.copyWith(
                          color: TacticalColors.textDim,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(TacticalSpacing.md),
                itemCount: filteredMemories.length,
                itemBuilder: (context, index) {
                  final memory = filteredMemories[index];
                  return _buildMemoryCard(memory);
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
                    size: 64,
                    color: TacticalColors.error,
                  ),
                  SizedBox(height: TacticalSpacing.lg),
                  Text(
                    'Failed to load memories',
                    style: TacticalText.cardTitle.copyWith(
                      color: TacticalColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: TacticalSpacing.sm),
                  Text(
                    error.toString(),
                    style: TacticalText.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: TacticalSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(memoriesProvider),
                    icon: Icon(Icons.refresh),
                    label: Text('RETRY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.primary,
                      foregroundColor: TacticalColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // When embedded in a TabBarView, skip Scaffold/AppBar
    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Text(
          'MEMORIES',
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: () => ref.invalidate(memoriesProvider),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }

  Widget _buildMemoryCard(MemoryModel memory) {
    return Container(
      margin: const EdgeInsets.only(bottom: TacticalSpacing.md),
      decoration: TacticalDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            decoration: BoxDecoration(
              color: TacticalColors.primaryMuted,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TacticalRadius.lg),
                topRight: Radius.circular(TacticalRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.memory,
                  color: TacticalColors.primary,
                  size: 20,
                ),
                SizedBox(width: TacticalSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User: ${memory.userId}',
                        style: TacticalText.cardTitle.copyWith(
                          color: TacticalColors.primary,
                        ),
                      ),
                      Text(
                        memory.timeAgo,
                        style: TacticalText.label.copyWith(
                          color: TacticalColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  color: TacticalColors.error,
                  onPressed: () => _deleteMemory(memory.memoryId),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),

          // Memory content
          Padding(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.memory,
                  style: TacticalText.bodyMedium,
                ),
                if (memory.topics != null && memory.topics!.isNotEmpty) ...[
                  SizedBox(height: TacticalSpacing.md),
                  Wrap(
                    spacing: TacticalSpacing.xs,
                    runSpacing: TacticalSpacing.xs,
                    children: memory.topics!.map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TacticalSpacing.sm,
                          vertical: TacticalSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: TacticalColors.primaryMuted,
                          borderRadius: BorderRadius.circular(TacticalRadius.sm),
                          border: Border.all(color: TacticalColors.primary),
                        ),
                        child: Text(
                          topic,
                          style: TacticalText.label.copyWith(
                            color: TacticalColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (memory.agentId != null) ...[
                  SizedBox(height: TacticalSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        color: TacticalColors.textMuted,
                        size: 16,
                      ),
                      SizedBox(width: TacticalSpacing.xs),
                      Text(
                        'Agent: ${memory.agentId}',
                        style: TacticalText.label.copyWith(
                          fontFamily: 'monospace',
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
}
