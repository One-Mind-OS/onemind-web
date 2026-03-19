import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/knowledge_model.dart';
import '../providers/api_providers.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'memories_screen.dart';

/// Knowledge Base management screen - List, create, edit, delete knowledge bases
class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  String _searchQuery = '';

  List<KnowledgeBaseModel> _filterKnowledgeBases(List<KnowledgeBaseModel> kbs) {
    if (_searchQuery.isEmpty) return kbs;
    return kbs.where((kb) {
      return kb.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (kb.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          kb.embeddingModel.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _deleteKnowledgeBase(String kbId, String kbName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Knowledge Base',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete "$kbName"?\n\nThis will permanently delete all documents in this knowledge base.',
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
        await ref.read(knowledgeMutationsProvider).deleteKnowledgeBase(kbId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Knowledge base "$kbName" deleted successfully.'),
              backgroundColor: TacticalColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete knowledge base: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadDocument(String kbId, String kbName) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md', 'doc', 'docx', 'csv', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      final file = result.files.first;
      if (file.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to read file contents'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: TacticalColors.surface,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: TacticalColors.primary),
                SizedBox(height: 16),
                Text(
                  'Uploading ${file.name}...',
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Upload document
      await ApiService.uploadDocument(
        kbId: kbId,
        fileBytes: file.bytes!,
        fileName: file.name,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${file.name}" uploaded to "$kbName" successfully.'),
            backgroundColor: TacticalColors.success,
          ),
        );
        ref.invalidate(knowledgeBasesProvider); // Refresh to update document count
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: $e'),
            backgroundColor: TacticalColors.error,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedEmbedding = 'text-embedding-3-small';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Create Knowledge Base',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              Text(
                'Name',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Product Documentation',
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description field
              Text(
                'Description (optional)',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe what this knowledge base contains...',
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Embedding model dropdown
              Text(
                'Embedding Model',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedEmbedding,
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  dropdownColor: TacticalColors.surface,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TacticalColors.background,
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
                      borderSide: BorderSide(
                        color: TacticalColors.primary,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'text-embedding-3-small',
                      child: Text('text-embedding-3-small'),
                    ),
                    DropdownMenuItem(
                      value: 'text-embedding-3-large',
                      child: Text('text-embedding-3-large'),
                    ),
                    DropdownMenuItem(
                      value: 'text-embedding-ada-002',
                      child: Text('text-embedding-ada-002'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedEmbedding = value);
                    }
                  },
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final kb = KnowledgeBaseModel(
                  name: name,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  embeddingModel: selectedEmbedding,
                );

                await ref.read(knowledgeMutationsProvider).createKnowledgeBase(kb);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Knowledge base "$name" created successfully.'),
                      backgroundColor: TacticalColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create knowledge base: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
              foregroundColor: TacticalColors.background,
            ),
            child: Text('CREATE'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(KnowledgeBaseModel kb) {
    final nameController = TextEditingController(text: kb.name);
    final descriptionController = TextEditingController(text: kb.description ?? '');
    String selectedEmbedding = kb.embeddingModel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Edit Knowledge Base',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              Text(
                'Name',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Product Documentation',
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description field
              Text(
                'Description (optional)',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe what this knowledge base contains...',
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: TacticalColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Embedding model dropdown
              Text(
                'Embedding Model',
                style: TextStyle(
                  color: TacticalColors.primary.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedEmbedding,
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  dropdownColor: TacticalColors.surface,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: TacticalColors.background,
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
                      borderSide: BorderSide(
                        color: TacticalColors.primary,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'text-embedding-3-small',
                      child: Text('text-embedding-3-small'),
                    ),
                    DropdownMenuItem(
                      value: 'text-embedding-3-large',
                      child: Text('text-embedding-3-large'),
                    ),
                    DropdownMenuItem(
                      value: 'text-embedding-ada-002',
                      child: Text('text-embedding-ada-002'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedEmbedding = value);
                    }
                  },
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
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final updatedKb = kb.copyWith(
                  name: name,
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  embeddingModel: selectedEmbedding,
                );

                await ref.read(knowledgeMutationsProvider).updateKnowledgeBase(kb.id!, updatedKb);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Knowledge base "$name" updated successfully.'),
                      backgroundColor: TacticalColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update knowledge base: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
              foregroundColor: TacticalColors.background,
            ),
            child: Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'KNOWLEDGE & MEMORY',
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
              Tab(text: 'KNOWLEDGE BASES'),
              Tab(text: 'MEMORIES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildKnowledgeTab(),
            const MemoriesScreen(embedded: true),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeTab() {
    final kbsAsync = ref.watch(knowledgeBasesProvider);

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
                      hintText: 'Search knowledge bases...',
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
                onPressed: _showCreateDialog,
                icon: Icon(Icons.add, size: 18),
                label: Text(
                  'CREATE KB',
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

        // Knowledge bases grid
        Expanded(
          child: kbsAsync.when(
            data: (kbs) {
              final filteredKbs = _filterKnowledgeBases(kbs);
              if (filteredKbs.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No knowledge bases configured' : 'No knowledge bases found',
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
                itemCount: filteredKbs.length,
                itemBuilder: (context, index) {
                  return _KnowledgeBaseCard(
                    kb: filteredKbs[index],
                    onDelete: _deleteKnowledgeBase,
                    onUpload: _uploadDocument,
                    onEdit: _showEditDialog,
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
                    'Failed to load knowledge bases',
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
                    onPressed: () => ref.invalidate(knowledgeBasesProvider),
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

/// Knowledge Base card component
class _KnowledgeBaseCard extends StatefulWidget {
  final KnowledgeBaseModel kb;
  final Function(String, String) onDelete;
  final Function(String, String) onUpload;
  final Function(KnowledgeBaseModel) onEdit;

  const _KnowledgeBaseCard({
    required this.kb,
    required this.onDelete,
    required this.onUpload,
    required this.onEdit,
  });

  @override
  State<_KnowledgeBaseCard> createState() => _KnowledgeBaseCardState();
}

class _KnowledgeBaseCardState extends State<_KnowledgeBaseCard> {
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
                  Text(
                    widget.kb.name,
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),

                  SizedBox(height: 12),

                  // Description
                  if (widget.kb.description != null)
                    Text(
                      widget.kb.description!,
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

                  // Document count
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${widget.kb.documentCount} documents',
                        style: TextStyle(
                          color: TacticalColors.primary.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // Embedding model
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.kb.embeddingModel,
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
                      icon: Icons.upload_file,
                      tooltip: 'Upload Document',
                      onTap: () {
                        widget.onUpload(widget.kb.id!, widget.kb.name);
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onTap: () {
                        widget.onEdit(widget.kb);
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: () {
                        widget.onDelete(widget.kb.id!, widget.kb.name);
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

/// Small icon button for knowledge base card actions
class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;

  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? TacticalColors.error : TacticalColors.primary;

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
