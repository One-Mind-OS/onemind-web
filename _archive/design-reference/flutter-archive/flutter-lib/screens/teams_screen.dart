import 'package:flutter/material.dart';
import '../config/tactical_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_model.dart';
import '../providers/api_providers.dart';
import 'team_form_screen.dart';

/// Teams management screen - List, create, edit, delete teams
class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key});

  @override
  ConsumerState<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends ConsumerState<TeamsScreen> {
  String _searchQuery = '';
  bool _isReloading = false;

  List<TeamModel> _filterTeams(List<TeamModel> teams) {
    if (_searchQuery.isEmpty) return teams;
    return teams.where((team) {
      return team.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (team.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _reloadConfigs() async {
    setState(() => _isReloading = true);

    try {
      await ref.read(teamMutationsProvider).reloadTeamConfigs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Team configs reloaded successfully!'),
            backgroundColor: TacticalColors.primary,
          ),
        );
        // Refresh the team list
        ref.invalidate(teamsProvider);
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

  Future<void> _deleteTeam(String teamId, String teamName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Delete Team',
          style: TextStyle(color: TacticalColors.primary, fontFamily: 'monospace'),
        ),
        content: Text(
          'Are you sure you want to delete "$teamName"?\n\nConfigs will be reloaded automatically.',
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
        await ref.read(teamMutationsProvider).deleteTeam(teamId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team "$teamName" deleted. Reloading configs...'),
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
              content: Text('Failed to delete team: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Text(
          'TEAM MANAGEMENT',
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
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
                        hintText: 'Search teams...',
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TeamFormScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 18),
                  label: Text(
                    'CREATE TEAM',
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

          // Teams grid
          Expanded(
            child: teamsAsync.when(
              data: (teams) {
                final filteredTeams = _filterTeams(teams);
                if (filteredTeams.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'No teams configured' : 'No teams found',
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
                  itemCount: filteredTeams.length,
                  itemBuilder: (context, index) {
                    return _TeamCard(
                      team: filteredTeams[index],
                      onDelete: _deleteTeam,
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
                      'Failed to load teams',
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
                      onPressed: () => ref.invalidate(teamsProvider),
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
      ),
    );
  }
}

/// Team card component
class _TeamCard extends ConsumerStatefulWidget {
  final TeamModel team;
  final Function(String, String) onDelete;

  const _TeamCard({required this.team, required this.onDelete});

  @override
  ConsumerState<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends ConsumerState<_TeamCard> {
  bool _isHovered = false;

  Future<void> _runTeam() async {
    // Show quick run dialog
    final messageController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text(
          'Run ${widget.team.name}',
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
        // Execute team
        await ref.read(teamRunMutationsProvider).runTeam(
              widget.team.id!,
              result,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team "${widget.team.name}" started successfully'),
              backgroundColor: TacticalColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to run team: $e'),
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
                  // Name and coordination mode
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        color: TacticalColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.team.name,
                              style: TextStyle(
                                color: TacticalColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.team.coordinationDescription,
                              style: TextStyle(
                                color: TacticalColors.primary.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Description
                  if (widget.team.description != null)
                    Text(
                      widget.team.description!,
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

                  // Model and member info
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
                          widget.team.modelName,
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
                        Icons.people,
                        color: TacticalColors.primary.withValues(alpha: 0.5),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${widget.team.memberIds.length} members',
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
                      tooltip: 'Run Team',
                      onTap: _runTeam,
                      isSuccess: true,
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TeamFormScreen(team: widget.team),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    _IconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: () {
                        widget.onDelete(widget.team.id!, widget.team.name);
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

/// Small icon button for team card actions
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
