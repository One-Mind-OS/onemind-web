import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import 'models/health.dart';
import 'providers/health_provider.dart';

/// Health Screen - Unified Operator Health Intel
/// Tabs: Dashboard, Alerts, Log, Trends, Correlations
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() => ref.read(healthProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('HEALTH', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(healthProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: TacticalColors.primary,
          labelColor: TacticalColors.primary,
          unselectedLabelColor: TacticalColors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          tabs: const [
            Tab(text: 'DASHBOARD'),
            Tab(text: 'ALERTS'),
            Tab(text: 'LOG'),
            Tab(text: 'TRENDS'),
            Tab(text: 'CORRELATIONS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _AlertsTab(),
          _LogTab(),
          _TrendsTab(),
          _CorrelationsTab(),
        ],
      ),
    );
  }
}

/// Dashboard Tab - Overview with scores
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: TacticalColors.primary),
      );
    }

    if (state.scores.isEmpty) {
      return _buildEmptyState(
        'NO HEALTH DATA',
        'Connect Oura, Apple Health, or other sources',
        Icons.monitor_heart_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall score card
          _buildOverallScoreCard(state),
          const SizedBox(height: 16),

          // Score cards grid
          _buildScoreCardsGrid(state.scores),
          const SizedBox(height: 24),

          // Metrics section
          _buildSectionHeader('VITALS'),
          const SizedBox(height: 12),
          _buildMetricsRow(state.metrics),
          const SizedBox(height: 24),

          // AI Insights
          if (state.scores.any((s) => s.insight != null)) ...[
            _buildSectionHeader('AI INSIGHTS'),
            const SizedBox(height: 12),
            ...state.scores
                .where((s) => s.insight != null)
                .map((s) => _buildInsightCard(s))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(HealthState state) {
    final score = state.overallScore;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          // Score ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: TacticalColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    score >= 70
                        ? TacticalColors.operational
                        : score >= 40
                            ? TacticalColors.inProgress
                            : TacticalColors.critical,
                  ),
                ),
                Text(
                  score.toInt().toString(),
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERALL SCORE',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 70
                      ? 'Optimal performance'
                      : score >= 40
                          ? 'Room for improvement'
                          : 'Needs attention',
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCardsGrid(List<HealthScore> scores) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return _buildScoreCard(score);
      },
    );
  }

  Widget _buildScoreCard(HealthScore score) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: TacticalDecoration.card,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(score.icon, color: score.scoreColor, size: 24),
          const SizedBox(height: 8),
          Text(
            score.score.toInt().toString(),
            style: TextStyle(
              color: score.scoreColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.categoryLabel,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          if (score.change != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  score.change! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: score.change! >= 0
                      ? TacticalColors.operational
                      : TacticalColors.critical,
                  size: 10,
                ),
                Text(
                  '${score.change!.abs().toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: score.change! >= 0
                        ? TacticalColors.operational
                        : TacticalColors.critical,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(List<HealthMetric> metrics) {
    if (metrics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: const Center(
          child: Text(
            'No metrics available',
            style: TextStyle(color: TacticalColors.textMuted),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics.map((m) => _buildMetricCard(m)).toList(),
      ),
    );
  }

  Widget _buildMetricCard(HealthMetric metric) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Icon(metric.icon, color: TacticalColors.primary, size: 20),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                metric.value,
                style: const TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              if (metric.unit != null)
                Text(
                  ' ${metric.unit}',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            metric.name,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(HealthScore score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TacticalColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(score.icon, color: TacticalColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.categoryLabel,
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score.insight!,
                  style: const TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: TacticalColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: TacticalColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alerts Tab
class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(healthAlertsProvider);

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: TacticalColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'NO ALERTS',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Health alerts will appear here',
              style: TextStyle(
                color: TacticalColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert, ref);
      },
    );
  }

  Widget _buildAlertCard(HealthAlert alert, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TacticalDecoration.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(healthProvider.notifier).markAlertRead(alert.id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: alert.severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    alert.severityIcon,
                    color: alert.severityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                color: TacticalColors.textPrimary,
                                fontSize: 14,
                                fontWeight: alert.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: TacticalColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          color: TacticalColors.textMuted,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert.relativeTime,
                        style: const TextStyle(
                          color: TacticalColors.textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Log Tab - Mood logging
class _LogTab extends ConsumerStatefulWidget {
  const _LogTab();

  @override
  ConsumerState<_LogTab> createState() => _LogTabState();
}

class _LogTabState extends ConsumerState<_LogTab> {
  int _mood = 3;
  int _energy = 3;
  int _stress = 3;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodLog = ref.watch(moodLogProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Log entry form
          _buildLogForm(),
          const SizedBox(height: 24),

          // Recent entries
          const Text(
            'RECENT ENTRIES',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          if (moodLog.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: TacticalDecoration.card,
              child: const Center(
                child: Text(
                  'No mood entries yet',
                  style: TextStyle(color: TacticalColors.textMuted),
                ),
              ),
            )
          else
            ...moodLog.take(10).map((entry) => _buildMoodEntry(entry)).toList(),
        ],
      ),
    );
  }

  Widget _buildLogForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOG MOOD',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),

          // Mood slider
          _buildSlider('MOOD', _mood, (v) => setState(() => _mood = v)),
          const SizedBox(height: 16),

          // Energy slider
          _buildSlider('ENERGY', _energy, (v) => setState(() => _energy = v)),
          const SizedBox(height: 16),

          // Stress slider
          _buildSlider('STRESS', _stress, (v) => setState(() => _stress = v)),
          const SizedBox(height: 20),

          // Note field
          TextField(
            controller: _noteController,
            style: const TextStyle(color: TacticalColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add a note (optional)',
              hintStyle: TextStyle(
                color: TacticalColors.textMuted.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: TacticalColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TacticalColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TacticalColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: TacticalColors.primary),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: TacticalButton(
              label: 'LOG ENTRY',
              icon: Icons.add,
              onTap: _submitLog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, int value, ValueChanged<int> onChanged) {
    final emojis = ['😢', '😕', '😐', '🙂', '😄'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Text(
              emojis[value - 1],
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: TacticalColors.primary,
            inactiveTrackColor: TacticalColors.border,
            thumbColor: TacticalColors.primary,
            overlayColor: TacticalColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodEntry(MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Text(entry.moodEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMiniStat('Energy', entry.energy),
                    const SizedBox(width: 16),
                    _buildMiniStat('Stress', entry.stress),
                  ],
                ),
                if (entry.note != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.note!,
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            _formatTime(entry.timestamp),
            style: const TextStyle(
              color: TacticalColors.textDim,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: TacticalColors.textDim,
            fontSize: 11,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: TacticalColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}';
  }

  void _submitLog() {
    ref.read(healthProvider.notifier).logMood(
          mood: _mood,
          energy: _energy,
          stress: _stress,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );
    _noteController.clear();
    setState(() {
      _mood = 3;
      _energy = 3;
      _stress = 3;
    });
  }
}

/// Trends Tab
class _TrendsTab extends ConsumerWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'TRENDS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log more data to see trends',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Correlations Tab
class _CorrelationsTab extends ConsumerWidget {
  const _CorrelationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correlations = ref.watch(healthCorrelationsProvider);

    if (correlations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hub,
              size: 64,
              color: TacticalColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'CORRELATIONS',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-detected patterns will appear here',
              style: TextStyle(
                color: TacticalColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: correlations.length,
      itemBuilder: (context, index) {
        final correlation = correlations[index];
        return _buildCorrelationCard(correlation);
      },
    );
  }

  Widget _buildCorrelationCard(HealthCorrelation correlation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TacticalColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  correlation.factor1,
                  style: const TextStyle(
                    color: TacticalColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                correlation.correlation >= 0
                    ? Icons.arrow_forward
                    : Icons.compare_arrows,
                color: correlation.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TacticalColors.complete.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  correlation.factor2,
                  style: const TextStyle(
                    color: TacticalColors.complete,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${correlation.strength} ${correlation.direction}',
                style: TextStyle(
                  color: correlation.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            correlation.insight,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
