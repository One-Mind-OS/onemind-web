import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';

/// Projects Screen — AI Project Lifecycle Management
/// ==================================================
/// Project list with health scoring, stages, Gantt preview,
/// and risk indicators.

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _projects = [];
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final projects = await ApiService.listProjects(limit: 100);
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            Icon(Icons.folder_special, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Text('PROJECTS', style: TacticalText.screenTitle.copyWith(fontSize: 18, color: textPrimary)),
            const SizedBox(width: 12),
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: TacticalDecoration.statusBadge(TacticalColors.info),
                child: Text('${_projects.length}',
                    style: TextStyle(fontSize: 11, color: TacticalColors.info)),
              ),
          ],
        ),
        actions: [
          if (_selectedProjectId != null)
            IconButton(
              icon: Icon(Icons.arrow_back, color: textSecondary),
              onPressed: () => setState(() => _selectedProjectId = null),
            ),
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: _showCreateDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textSecondary),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _selectedProjectId != null
                  ? _buildProjectDetail()
                  : _buildProjectList(),
    );
  }

  Widget _buildProjectList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];
    final textDim = isDark ? Colors.grey[600] : Colors.grey[500];
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_special, size: 64, color: textDim),
            const SizedBox(height: 16),
            Text('No projects yet', style: TextStyle(color: textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Create a project to track goals, stages, and health',
                style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (ctx, i) => _buildProjectCard(_projects[i]),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final name = project['name'] ?? 'Untitled';
    final status = project['status'] ?? 'planning';
    final health = project['health'] ?? 'unknown';
    final desc = project['description'] ?? '';
    final stages = (project['stages'] as List?)?.length ?? 0;
    final id = project['project_id'] ?? project['id'] ?? '';

    final healthColor = _healthColor(health);
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () => setState(() => _selectedProjectId = id.toString()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: TacticalDecoration.card(borderColor: healthColor.withValues(alpha: 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TacticalText.cardTitle.copyWith(fontSize: 15)),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(desc, style: TacticalText.cardSubtitle,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: TacticalDecoration.statusBadge(statusColor),
                      child: Text(status.toUpperCase(),
                          style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: TacticalDecoration.statusBadge(healthColor),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_healthIcon(health), size: 12, color: healthColor),
                          const SizedBox(width: 4),
                          Text(health.toString().toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(fontSize: 9, color: healthColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stages progress bar
            Row(
              children: [
                Icon(Icons.flag, size: 14, color: TacticalColors.textDim),
                const SizedBox(width: 6),
                Text('$stages stages', style: TextStyle(color: TacticalColors.textMuted, fontSize: 12)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: TacticalColors.textDim),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetail() {
    final project = _projects.firstWhere(
        (p) => (p['project_id'] ?? p['id']).toString() == _selectedProjectId,
        orElse: () => <String, dynamic>{});

    if (project.isEmpty) {
      return const Center(child: Text('Project not found'));
    }

    final name = project['name'] ?? '';
    final desc = project['description'] ?? '';
    final status = project['status'] ?? 'planning';
    final health = project['health'] ?? 'unknown';
    final stages = (project['stages'] as List<dynamic>?) ?? [];
    final healthColor = _healthColor(health);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: TacticalDecoration.card(borderColor: healthColor.withValues(alpha: 0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TacticalText.screenTitle.copyWith(fontSize: 22)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(desc, style: TacticalText.bodyMedium),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _detailBadge('Status', status, _statusColor(status)),
                    const SizedBox(width: 12),
                    _detailBadge('Health', health.toString().replaceAll('_', ' '), healthColor),
                    const SizedBox(width: 12),
                    _detailBadge('Stages', '${stages.length}', TacticalColors.info),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stages
          Text('PROJECT STAGES', style: TacticalText.sectionHeader),
          const SizedBox(height: 12),
          if (stages.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: TacticalDecoration.card(),
              child: Center(
                child: Text('No stages defined yet',
                    style: TextStyle(color: TacticalColors.textDim)),
              ),
            )
          else
            ...stages.asMap().entries.map((e) {
              final stage = e.value as Map<String, dynamic>;
              final stageStatus = stage['status'] ?? 'pending';
              final stageColor = stageStatus == 'completed'
                  ? TacticalColors.success
                  : stageStatus == 'in_progress'
                      ? TacticalColors.warning
                      : TacticalColors.inactive;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TacticalColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: stageColor, width: 3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: TextStyle(fontSize: 11, color: stageColor, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(stage['name'] ?? 'Stage ${e.key + 1}',
                          style: TacticalText.cardTitle.copyWith(fontSize: 13)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: TacticalDecoration.statusBadge(stageColor),
                      child: Text(stageStatus.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: stageColor)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _detailBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: TacticalDecoration.statusBadge(color),
      child: Column(
        children: [
          Text(value.toUpperCase(),
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(fontSize: 9, color: TacticalColors.textDim)),
        ],
      ),
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
          ElevatedButton(onPressed: _loadProjects, child: const Text('Retry')),
        ],
      ),
    );
  }

  Color _healthColor(String health) {
    switch (health) {
      case 'on_track': return TacticalColors.success;
      case 'at_risk': return TacticalColors.warning;
      case 'behind': return const Color(0xFFFF8C00);
      case 'critical': return TacticalColors.error;
      default: return TacticalColors.inactive;
    }
  }

  IconData _healthIcon(String health) {
    switch (health) {
      case 'on_track': return Icons.check_circle;
      case 'at_risk': return Icons.warning;
      case 'behind': return Icons.schedule;
      case 'critical': return Icons.error;
      default: return Icons.help_outline;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return TacticalColors.success;
      case 'planning': return TacticalColors.info;
      case 'paused': return TacticalColors.warning;
      case 'completed': return TacticalColors.cyan;
      case 'archived': return TacticalColors.inactive;
      default: return TacticalColors.inactive;
    }
  }

  void _showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('New Project', style: TextStyle(color: primaryColor, fontFamily: 'monospace')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: TacticalDecoration.inputField(label: 'Project Name'),
              style: TextStyle(color: textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: TacticalDecoration.inputField(label: 'Description'),
              style: TextStyle(color: textPrimary),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ApiService.createProject({
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                });
                _loadProjects();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create project: ${e.toString()}')),
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
}
