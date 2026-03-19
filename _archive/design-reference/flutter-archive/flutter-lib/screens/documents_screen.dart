import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';

/// Documents Screen — Versioned Document Browser & Editor
/// =======================================================
/// Browse, create, edit, and version documents. Supports 7 doc types.

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _documents = [];
  String _filterType = 'all';
  String _searchQuery = '';
  String? _selectedDocId;
  bool _isEditing = false;
  final TextEditingController _editController = TextEditingController();

  static const Map<String, IconData> _docIcons = {
    'note': Icons.sticky_note_2_outlined,
    'sop': Icons.rule,
    'report': Icons.assessment_outlined,
    'meeting_notes': Icons.groups_outlined,
    'spec': Icons.description_outlined,
    'wiki': Icons.language,
    'template': Icons.copy_all_outlined,
  };

  static const Map<String, Color> _docColors = {
    'note': Color(0xFF3B82F6),
    'sop': Color(0xFF8B5CF6),
    'report': Color(0xFF22C55E),
    'meeting_notes': Color(0xFFF59E0B),
    'spec': Color(0xFFEC4899),
    'wiki': Color(0xFF06B6D4),
    'template': Color(0xFF6B7280),
  };

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final documents = await ApiService.listDocuments(limit: 100);
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDocs {
    return _documents.where((d) {
      if (_filterType != 'all' && d['doc_type'] != _filterType) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (d['title'] ?? '').toString().toLowerCase();
        final tags = ((d['tags'] as List?) ?? []).join(' ').toLowerCase();
        if (!title.contains(q) && !tags.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.cyan : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Icon(Icons.description, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Text('DOCUMENTS', style: TacticalText.screenTitle.copyWith(fontSize: 18, color: textPrimary)),
          ],
        ),
        actions: [
          if (_selectedDocId != null)
            IconButton(
              icon: Icon(Icons.auto_awesome, color: primaryColor),
              onPressed: () => _showAIMenu(context),
              tooltip: 'AI Actions',
            ),
          if (_selectedDocId != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.visibility : Icons.edit,
                  color: textSecondary),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          if (_selectedDocId != null)
            IconButton(
              icon: Icon(Icons.arrow_back, color: textSecondary),
              onPressed: () => setState(() { _selectedDocId = null; _isEditing = false; }),
            ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: _showCreateDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textSecondary),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _selectedDocId != null
                  ? _buildDocDetail()
                  : _buildDocList(),
    );
  }

  Widget _buildDocList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB);
    final inputColor = isDark ? TacticalColors.input : const Color(0xFFF3F4F6);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];
    final textDim = isDark ? Colors.grey[600] : Colors.grey[500];
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: TextStyle(color: textDim, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: textMuted, size: 18),
                      filled: true,
                      fillColor: inputColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: textPrimary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Type filter chips
              ..._buildTypeChips(),
            ],
          ),
        ),
        // Document list
        Expanded(
          child: _filteredDocs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: textDim),
                      const SizedBox(height: 16),
                      Text('No documents', style: TextStyle(color: textSecondary, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Document'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredDocs.length,
                  itemBuilder: (ctx, i) => _buildDocCard(_filteredDocs[i]),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildTypeChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];
    final textOnSelected = isDark ? Colors.white : Colors.white;

    final types = ['all', 'note', 'sop', 'report', 'wiki'];
    return types.map((t) {
      final isSelected = _filterType == t;
      final color = _docColors[t] ?? TacticalColors.primary;
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: FilterChip(
          label: Text(t == 'all' ? 'ALL' : t.toUpperCase(),
              style: TextStyle(fontSize: 10, color: isSelected ? textOnSelected : textMuted)),
          selected: isSelected,
          onSelected: (_) => setState(() => _filterType = t),
          backgroundColor: cardColor,
          selectedColor: color.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }).toList();
  }

  Widget _buildDocCard(Map<String, dynamic> doc) {
    final title = doc['title'] ?? 'Untitled';
    final type = doc['doc_type'] ?? 'note';
    final version = doc['version'] ?? 1;
    final tags = (doc['tags'] as List?) ?? [];
    final updated = doc['updated_at'] ?? doc['created_at'] ?? '';
    final id = doc['document_id'] ?? doc['id'] ?? '';
    final color = _docColors[type] ?? TacticalColors.info;
    final icon = _docIcons[type] ?? Icons.description;

    return GestureDetector(
      onTap: () => setState(() { _selectedDocId = id.toString(); _isEditing = false; }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TacticalColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TacticalText.cardTitle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('v$version', style: TextStyle(
                        color: TacticalColors.textDim, fontSize: 10, fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      if (tags.isNotEmpty)
                        ...tags.take(3).map((t) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('#$t', style: TextStyle(
                            fontSize: 10, color: color.withValues(alpha: 0.7))),
                        )),
                    ],
                  ),
                ],
              ),
            ),
            Text(_formatTime(updated),
                style: TextStyle(fontSize: 10, color: TacticalColors.textDim)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocDetail() {
    final doc = _documents.firstWhere(
        (d) => (d['document_id'] ?? d['id']).toString() == _selectedDocId,
        orElse: () => <String, dynamic>{});

    if (doc.isEmpty) return const Center(child: Text('Document not found'));

    final title = doc['title'] ?? '';
    final content = doc['content'] ?? '';
    final type = doc['doc_type'] ?? 'note';
    final version = doc['version'] ?? 1;
    final color = _docColors[type] ?? TacticalColors.info;

    if (_isEditing) {
      _editController.text = content;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            border: Border(bottom: BorderSide(color: TacticalColors.border)),
          ),
          child: Row(
            children: [
              Icon(_docIcons[type] ?? Icons.description, color: color, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TacticalText.cardTitle.copyWith(fontSize: 16)),
              const Spacer(),
              Text('v$version', style: TextStyle(
                color: TacticalColors.textDim, fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
        ),
        Expanded(
          child: _isEditing
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _editController,
                          maxLines: null,
                          expands: true,
                          style: TextStyle(
                            color: TacticalColors.textPrimary,
                            fontSize: 14,
                            fontFamily: 'monospace',
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: TacticalColors.input,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: TacticalColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('CANCEL'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await ApiService.updateDocument(
                                  _selectedDocId!,
                                  {'content': _editController.text},
                                );
                                _loadDocuments();
                                setState(() => _isEditing = false);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to save: ${e.toString()}')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TacticalColors.primary,
                            ),
                            child: const Text('SAVE'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: TacticalDecoration.card(),
                    child: SelectableText(
                      content.isEmpty ? 'Empty document' : content,
                      style: TextStyle(
                        color: content.isEmpty ? TacticalColors.textDim : TacticalColors.textPrimary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
          const SizedBox(height: 16),
          Text(_error ?? '', style: TextStyle(color: textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDocuments, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _formatTime(String ts) {
    try {
      final dt = DateTime.parse(ts);
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return '';
    }
  }

  void _showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final elevatedColor = isDark ? TacticalColors.elevated : const Color(0xFFF3F4F6);
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    final titleCtrl = TextEditingController();
    String docType = 'note';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('New Document', style: TextStyle(color: primaryColor, fontFamily: 'monospace')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: TacticalDecoration.inputField(label: 'Title'),
              style: TextStyle(color: textPrimary),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setDialogState) => DropdownButtonFormField<String>(
                initialValue: docType,
                dropdownColor: elevatedColor,
                decoration: TacticalDecoration.inputField(label: 'Type'),
                items: _docIcons.keys.map((t) => DropdownMenuItem(
                  value: t,
                  child: Row(
                    children: [
                      Icon(_docIcons[t], size: 16, color: _docColors[t]),
                      const SizedBox(width: 8),
                      Text(t.toUpperCase(), style: TextStyle(color: textPrimary)),
                    ],
                  ),
                )).toList(),
                onChanged: (v) => setDialogState(() => docType = v!),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ApiService.createDocument({
                  'title': titleCtrl.text,
                  'doc_type': docType,
                });
                _loadDocuments();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create document: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('CREATE', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showAIMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Actions', style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.checklist, color: primaryColor),
              title: const Text('Extract Action Items'),
              subtitle: const Text('Find tasks and action items in document'),
              onTap: () {
                Navigator.pop(ctx);
                _extractActionItems();
              },
            ),
            ListTile(
              leading: Icon(Icons.summarize, color: primaryColor),
              title: const Text('Summarize'),
              subtitle: const Text('Generate document summary with AI'),
              onTap: () {
                Navigator.pop(ctx);
                _summarizeDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _extractActionItems() async {
    if (_selectedDocId == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        content: Row(
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(width: 20),
            const Text('Extracting action items...'),
          ],
        ),
      ),
    );

    try {
      final result = await ApiService.extractDocumentActions(_selectedDocId!);
      final actionItems = (result['action_items'] as List?) ?? [];

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show results dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            title: Text('Action Items', style: TextStyle(color: primaryColor)),
            content: actionItems.isEmpty
                ? const Text('No action items found in document.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Found ${actionItems.length} action items:'),
                      const SizedBox(height: 12),
                      ...actionItems.take(10).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: primaryColor)),
                            Expanded(
                              child: Text(
                                item['description'] ?? item.toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (actionItems.length > 10)
                        Text('...and ${actionItems.length - 10} more'),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract action items: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _summarizeDocument() async {
    if (_selectedDocId == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        content: Row(
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(width: 20),
            const Text('Generating summary...'),
          ],
        ),
      ),
    );

    try {
      final result = await ApiService.summarizeDocument(_selectedDocId!);
      final summary = result['summary'] ?? 'No summary generated.';

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show summary dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            title: Text('Document Summary', style: TextStyle(color: primaryColor)),
            content: SingleChildScrollView(
              child: Text(
                summary,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to summarize document: ${e.toString()}')),
        );
      }
    }
  }
}
