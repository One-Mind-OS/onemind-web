import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Traces Screen - Agno Agent Run Traces
/// Displays detailed traces from Langfuse/Phoenix for debugging and observability
class TracesScreen extends ConsumerStatefulWidget {
  const TracesScreen({super.key});

  @override
  ConsumerState<TracesScreen> createState() => _TracesScreenState();
}

class _TracesScreenState extends ConsumerState<TracesScreen> {
  String _selectedFilter = 'all';
  String _selectedTimeRange = '1h';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('TRACES', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: TacticalColors.primary),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          _buildStatusBar(),

          // Time range selector
          _buildTimeRangeSelector(),

          // Traces list
          Expanded(
            child: _buildTracesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        border: Border(
          bottom: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildStatusChip('LANGFUSE', false, TacticalColors.inProgress),
          const SizedBox(width: 8),
          _buildStatusChip('PHOENIX', false, TacticalColors.inProgress),
          const Spacer(),
          Text(
            '0 traces',
            style: TacticalText.cardSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool connected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: TacticalDecoration.statusBadge(
        connected ? TacticalColors.operational : color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: connected ? TacticalColors.operational : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: connected ? TacticalColors.operational : color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final ranges = ['15m', '1h', '6h', '24h', '7d'];

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: ranges.map((range) {
          final isSelected = range == _selectedTimeRange;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTimeRange = range),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TacticalColors.primary.withValues(alpha: 0.15)
                      : TacticalColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? TacticalColors.primary
                        : TacticalColors.border,
                  ),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    color: isSelected
                        ? TacticalColors.primary
                        : TacticalColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTracesList() {
    // Placeholder for when no traces are available
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: TacticalColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.timeline,
                size: 64,
                color: TacticalColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO TRACES AVAILABLE',
              style: TacticalText.screenTitle,
            ),
            const SizedBox(height: 12),
            const Text(
              'Connect Langfuse or Phoenix to view\nagent run traces and performance data',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TacticalOutlineButton(
                  label: 'CONFIGURE',
                  icon: Icons.settings,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                TacticalOutlineButton(
                  label: 'DOCS',
                  icon: Icons.description,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FILTER TRACES', style: TacticalText.screenTitle),
            const SizedBox(height: 24),

            // Filter by status
            const Text(
              'STATUS',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Success', 'success'),
                _buildFilterChip('Error', 'error'),
                _buildFilterChip('Running', 'running'),
              ],
            ),

            const SizedBox(height: 20),

            // Filter by agent
            const Text(
              'AGENT',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: TacticalColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'all',
                  isExpanded: true,
                  dropdownColor: TacticalColors.card,
                  style: TextStyle(color: TacticalColors.textPrimary),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Agents')),
                  ],
                  onChanged: null,
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TacticalOutlineButton(
                    label: 'RESET',
                    onTap: () {
                      setState(() => _selectedFilter = 'all');
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TacticalPrimaryButton(
                    label: 'APPLY',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.primary.withValues(alpha: 0.15)
              : TacticalColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? TacticalColors.primary : TacticalColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? TacticalColors.primary : TacticalColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Placeholder for trace item widget
class _TraceItem extends StatelessWidget {
  final String id;
  final String agentName;
  final String status;
  final int durationMs;
  final int tokenCount;
  final DateTime timestamp;

  const _TraceItem({
    required this.id,
    required this.agentName,
    required this.status,
    required this.durationMs,
    required this.tokenCount,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status == 'success'
        ? TacticalColors.operational
        : status == 'error'
            ? TacticalColors.critical
            : TacticalColors.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: TacticalDecoration.statusDot(statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agentName,
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${durationMs}ms',
                style: const TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${tokenCount} tokens',
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: TacticalColors.textDim,
            size: 20,
          ),
        ],
      ),
    );
  }
}
