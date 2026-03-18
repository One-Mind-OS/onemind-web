import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../models/approval_model.dart';
import '../services/api_service.dart';

/// Approvals Screen - Human-in-the-Loop Tool Authorization
/// ========================================================
///
/// Shows pending tool executions that require human approval.
/// Allows operators to review and approve/reject agent tool calls.
class ApprovalsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ApprovalsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  String _selectedFilter = 'pending'; // 'pending', 'all', 'approved', 'rejected'
  bool _isLoading = true;
  String? _error;
  List<PausedRun> _pausedRuns = [];

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  Future<void> _loadApprovals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch paused runs from API
      final pausedRuns = await ApiService.listPausedRuns();

      if (mounted) {
        setState(() {
          _pausedRuns = pausedRuns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveRun(String agentId, String runId) async {
    try {
      // Call AgentOS native endpoint to continue the paused run
      await ApiService.continueAgentRun(agentId, runId, approved: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tool execution approved and resumed'),
            backgroundColor: TacticalColors.success,
          ),
        );
        _loadApprovals(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: TacticalColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectRun(String agentId, String runId) async {
    try {
      // Call AgentOS native endpoint to cancel the paused run
      await ApiService.cancelAgentRun(agentId, runId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tool execution rejected'),
            backgroundColor: TacticalColors.error,
          ),
        );
        _loadApprovals(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: $e'),
            backgroundColor: TacticalColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        // Filter bar
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
              _buildFilterChip('Pending', 'pending', Icons.pending_actions),
              SizedBox(width: TacticalSpacing.sm),
              _buildFilterChip('All', 'all', Icons.list),
              SizedBox(width: TacticalSpacing.sm),
              _buildFilterChip('Approved', 'approved', Icons.check_circle),
              SizedBox(width: TacticalSpacing.sm),
              _buildFilterChip('Rejected', 'rejected', Icons.cancel),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: TacticalColors.primary),
                onPressed: _loadApprovals,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildBody(),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Text(
          'TOOL APPROVALS',
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
            onPressed: _loadApprovals,
            tooltip: 'Refresh',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _loadApprovals();
      },
      borderRadius: BorderRadius.circular(TacticalRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TacticalSpacing.md,
          vertical: TacticalSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.primaryMuted
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TacticalRadius.md),
          border: Border.all(
            color: isSelected
                ? TacticalColors.primary
                : TacticalColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? TacticalColors.primary
                  : TacticalColors.textMuted,
              size: 16,
            ),
            SizedBox(width: TacticalSpacing.xs),
            Text(
              label.toUpperCase(),
              style: TacticalText.label.copyWith(
                color: isSelected
                    ? TacticalColors.primary
                    : TacticalColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TacticalColors.primary),
            SizedBox(height: TacticalSpacing.md),
            Text(
              'Loading approvals...',
              style: TextStyle(color: TacticalColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: TacticalColors.error,
              size: 48,
            ),
            SizedBox(height: TacticalSpacing.md),
            Text(
              'Failed to load approvals',
              style: TacticalText.cardTitle.copyWith(color: TacticalColors.textPrimary),
            ),
            SizedBox(height: TacticalSpacing.sm),
            Text(
              _error!,
              style: TacticalText.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: TacticalSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadApprovals,
              icon: Icon(Icons.refresh),
              label: Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalColors.primary,
                foregroundColor: TacticalColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (_pausedRuns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: TacticalColors.success.withValues(alpha: 0.5),
              size: 64,
            ),
            SizedBox(height: TacticalSpacing.lg),
            Text(
              'NO PENDING APPROVALS',
              style: TacticalText.screenTitle.copyWith(
                fontSize: 18,
                color: TacticalColors.textMuted,
              ),
            ),
            SizedBox(height: TacticalSpacing.sm),
            Text(
              'All agent tool executions are approved or completed.',
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
      itemCount: _pausedRuns.length,
      itemBuilder: (context, index) {
        return _buildApprovalCard(_pausedRuns[index]);
      },
    );
  }

  Widget _buildApprovalCard(PausedRun run) {
    return Container(
      margin: const EdgeInsets.only(bottom: TacticalSpacing.md),
      decoration: TacticalDecoration.card(
        borderColor: TacticalColors.primary.withValues(alpha: 0.3),
      ),
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
                Container(
                  padding: const EdgeInsets.all(TacticalSpacing.sm),
                  decoration: TacticalDecoration.statusDot(TacticalColors.warning),
                  child: Icon(
                    Icons.pending_actions,
                    color: TacticalColors.warning,
                    size: 20,
                  ),
                ),
                SizedBox(width: TacticalSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        run.agentName ?? 'Agent ${run.agentId}',
                        style: TacticalText.cardTitle.copyWith(
                          color: TacticalColors.primary,
                        ),
                      ),
                      Text(
                        'Paused ${run.pausedDuration}',
                        style: TacticalText.label.copyWith(
                          color: TacticalColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TacticalSpacing.sm,
                    vertical: TacticalSpacing.xs,
                  ),
                  decoration: TacticalDecoration.statusBadge(TacticalColors.warning),
                  child: Text(
                    'AWAITING APPROVAL',
                    style: TacticalText.statusLabel.copyWith(
                      fontSize: 9,
                      color: TacticalColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (run.message != null) ...[
                  Text(
                    run.message!,
                    style: TacticalText.bodyMedium,
                  ),
                  SizedBox(height: TacticalSpacing.md),
                ],

                // Run ID
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      color: TacticalColors.textMuted,
                      size: 16,
                    ),
                    SizedBox(width: TacticalSpacing.xs),
                    Text(
                      'Run ID: ${run.runId}',
                      style: TacticalText.label.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                if (run.sessionId != null) ...[
                  SizedBox(height: TacticalSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.chat,
                        color: TacticalColors.textMuted,
                        size: 16,
                      ),
                      SizedBox(width: TacticalSpacing.xs),
                      Text(
                        'Session: ${run.sessionId}',
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

          // Actions
          Container(
            padding: const EdgeInsets.all(TacticalSpacing.md),
            decoration: BoxDecoration(
              color: TacticalColors.surface,
              border: Border(
                top: BorderSide(
                  color: TacticalColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRun(run.agentId, run.runId),
                    icon: Icon(Icons.cancel, size: 18),
                    label: Text('REJECT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.error,
                      foregroundColor: TacticalColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: TacticalSpacing.md),
                    ),
                  ),
                ),
                SizedBox(width: TacticalSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveRun(run.agentId, run.runId),
                    icon: Icon(Icons.check_circle, size: 18),
                    label: Text('APPROVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TacticalColors.success,
                      foregroundColor: TacticalColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: TacticalSpacing.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
