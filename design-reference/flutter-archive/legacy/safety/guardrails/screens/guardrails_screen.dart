// Guardrails Screen - Tactical Design
// Safety and content filter settings
// Manage moderation, input/output validation, and safety constraints

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../providers/guardrails_provider.dart';

/// Guardrails Screen - Safety and content filter settings
class GuardrailsScreen extends ConsumerWidget {
  const GuardrailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guardrailsProvider);
    final notifier = ref.read(guardrailsProvider.notifier);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('GUARDRAILS', style: TacticalText.cardTitle),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TacticalColors.primary,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.history, size: 20, color: TacticalColors.textMuted),
              onPressed: () => _showHistory(context, state.violations),
              tooltip: 'Violation History',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: TacticalColors.textMuted),
              onPressed: () => notifier.refresh(),
              tooltip: 'Refresh',
            ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              color: TacticalColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error banner
                    if (state.error != null) ...[
                      _buildErrorBanner(context, state.error!, notifier),
                      const SizedBox(height: 16),
                    ],

                    // Status Overview
                    _buildStatusOverview(state),
                    const SizedBox(height: 24),

                    // Main Controls Section
                    _buildSectionHeader('CONTENT MODERATION', Icons.shield),
                    const SizedBox(height: 12),
                    _buildModerationCard(state, notifier),
                    const SizedBox(height: 24),

                    // Validation Section
                    _buildSectionHeader('INPUT / OUTPUT VALIDATION', Icons.verified_user),
                    const SizedBox(height: 12),
                    _buildValidationCard(state, notifier),
                    const SizedBox(height: 24),

                    // Filters Section
                    _buildSectionHeader('CONTENT FILTERS', Icons.filter_alt),
                    const SizedBox(height: 12),
                    _buildFiltersCard(state, notifier),
                    const SizedBox(height: 24),

                    // Threshold Settings
                    _buildSectionHeader('THRESHOLD SETTINGS', Icons.tune),
                    const SizedBox(height: 12),
                    _buildThresholdCard(context, state, notifier),
                    const SizedBox(height: 24),

                    // Recent Violations
                    _buildSectionHeader('RECENT VIOLATIONS', Icons.warning),
                    const SizedBox(height: 12),
                    _buildViolationsList(state.violations),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: TacticalColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(
      BuildContext context, String error, GuardrailsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalColors.critical.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.critical.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: TacticalColors.critical, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: TacticalColors.critical, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: TacticalColors.critical),
            onPressed: () => notifier.clearError(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview(GuardrailsState state) {
    final activeProtections = state.config.activeProtections;
    final violationsToday = state.violationsToday;
    final isSecure = activeProtections >= 4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TacticalColors.operational.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TacticalColors.operational.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSecure ? Icons.shield : Icons.shield_outlined,
              size: 32,
              color: TacticalColors.operational,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GUARDRAILS ACTIVE',
                  style: TextStyle(
                    color: TacticalColors.operational,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeProtections of 5 protections enabled',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$violationsToday',
                style: TextStyle(
                  color: violationsToday > 0
                      ? TacticalColors.inProgress
                      : TacticalColors.operational,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const Text(
                'VIOLATIONS TODAY',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModerationCard(GuardrailsState state, GuardrailsNotifier notifier) {
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.remove_red_eye,
            title: 'OpenAI Moderation',
            subtitle: 'Use OpenAI moderation API for content filtering',
            value: state.config.moderationEnabled,
            onChanged: () => notifier.toggleModeration(),
            color: TacticalColors.primary,
          ),
          _buildDivider(),
          _buildInfoRow('MODEL', state.config.model),
          _buildDivider(),
          _buildInfoRow('FALLBACK', 'Pattern-based detection'),
        ],
      ),
    );
  }

  Widget _buildValidationCard(GuardrailsState state, GuardrailsNotifier notifier) {
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.input,
            title: 'Input Validation',
            subtitle: 'Validate and sanitize user inputs before processing',
            value: state.config.inputValidation,
            onChanged: () => notifier.toggleInputValidation(),
            color: TacticalColors.operational,
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.output,
            title: 'Output Validation',
            subtitle: 'Validate agent outputs before delivering to user',
            value: state.config.outputValidation,
            onChanged: () => notifier.toggleOutputValidation(),
            color: TacticalColors.inProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(GuardrailsState state, GuardrailsNotifier notifier) {
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.person_off,
            title: 'PII Filter',
            subtitle: 'Detect and redact personally identifiable information',
            value: state.config.piiFilter,
            onChanged: () => notifier.togglePiiFilter(),
            color: TacticalColors.complete,
          ),
          _buildDivider(),
          _buildToggleRow(
            icon: Icons.block,
            title: 'Profanity Filter',
            subtitle: 'Block or mask profane language',
            value: state.config.profanityFilter,
            onChanged: () => notifier.toggleProfanityFilter(),
            color: TacticalColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdCard(
      BuildContext context, GuardrailsState state, GuardrailsNotifier notifier) {
    final thresholdPercent = (state.config.toxicityThreshold * 100).toInt();
    final isStrict = thresholdPercent < 50;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TacticalColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 20, color: TacticalColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toxicity Threshold',
                      style: TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Block content above this toxicity score',
                      style: TextStyle(
                        color: TacticalColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isStrict ? TacticalColors.operational : TacticalColors.inProgress)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$thresholdPercent%',
                  style: TextStyle(
                    color: isStrict ? TacticalColors.operational : TacticalColors.inProgress,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: TacticalColors.primary,
              inactiveTrackColor: TacticalColors.border,
              thumbColor: TacticalColors.primary,
              overlayColor: TacticalColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: state.config.toxicityThreshold,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (v) => notifier.setToxicityThreshold(v),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LENIENT',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'STRICT',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViolationsList(List<GuardrailsViolation> violations) {
    if (violations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: TacticalDecoration.card,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: TacticalColors.operational.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'NO RECENT VIOLATIONS',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: violations.take(5).map((v) => _buildViolationItem(v)).toList(),
    );
  }

  Widget _buildViolationItem(GuardrailsViolation violation) {
    final color = violation.severity == 'high'
        ? TacticalColors.critical
        : violation.severity == 'medium'
            ? TacticalColors.inProgress
            : TacticalColors.complete;

    final timeAgo = _formatTimeAgo(violation.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              violation.type.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              violation.message,
              style: const TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            timeAgo,
            style: const TextStyle(
              color: TacticalColors.textDim,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onChanged(),
            activeColor: TacticalColors.primary,
            inactiveTrackColor: TacticalColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: TacticalColors.border,
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _showHistory(BuildContext context, List<GuardrailsViolation> violations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TacticalColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'VIOLATION HISTORY',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${violations.length} total',
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: TacticalColors.border),
            Expanded(
              child: violations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: TacticalColors.operational.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No violations recorded',
                            style: TextStyle(
                              color: TacticalColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: violations.length,
                      itemBuilder: (context, index) =>
                          _buildViolationItem(violations[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
