import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';
import '../../shared/widgets/tactical/tactical_widgets.dart';
import '../../platform/providers/app_providers.dart';

/// COMMAND Screen - Tactical Dashboard
/// Full operational overview inspired by military command centers.
/// Includes: LEGACY status, LIVE FEED, THREE PILLARS, WORKFORCE, SYSTEM HEALTH
class CommandScreen extends ConsumerStatefulWidget {
  const CommandScreen({super.key});

  @override
  ConsumerState<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends ConsumerState<CommandScreen> {
  Timer? _refreshTimer;
  String _currentMode = 'present';

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshData() {
    ref.invalidate(agentsProvider);
    ref.invalidate(teamsProvider);
    ref.invalidate(sessionsProvider);
    ref.invalidate(toolsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentsProvider);
    final teamsAsync = ref.watch(teamsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final toolsAsync = ref.watch(toolsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: TacticalColors.primary,
          backgroundColor: TacticalColors.card,
          onRefresh: () async => _refreshData(),
          child: CustomScrollView(
            slivers: [
              // ══════════════════════════════════════════════════════════
              // TACTICAL APP BAR
              // ══════════════════════════════════════════════════════════
              SliverAppBar(
                backgroundColor: TacticalColors.background,
                floating: true,
                pinned: false,
                elevation: 0,
                automaticallyImplyLeading: false,
                leadingWidth: 0,
                titleSpacing: 70, // Space for menu button
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COMMAND CENTER',
                      style: TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      _getTimeString(),
                      style: const TextStyle(
                        color: TacticalColors.textDim,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: TacticalColors.textMuted, size: 20),
                    onPressed: _refreshData,
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: TacticalColors.primary, size: 20),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),

              // ══════════════════════════════════════════════════════════
              // CONTENT
              // ══════════════════════════════════════════════════════════
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── LEGACY STATUS CARD ─────────────────────────────
                    _buildLegacyStatusCard(),

                    const SizedBox(height: 20),

                    // ── LIVE FEED ──────────────────────────────────────
                    _buildSectionHeader('LIVE FEED', 'Real-time events', onAction: () => context.push('/activity')),
                    const SizedBox(height: 12),
                    _buildLiveFeed(),

                    const SizedBox(height: 20),

                    // ── THREE PILLARS ──────────────────────────────────
                    _buildSectionHeader('THREE PILLARS', 'Life balance metrics'),
                    const SizedBox(height: 12),
                    _buildThreePillars(),

                    const SizedBox(height: 20),

                    // ── WORKFORCE STATS ────────────────────────────────
                    _buildSectionHeader('WORKFORCE', 'AI assets at your command'),
                    const SizedBox(height: 12),
                    _buildWorkforceGrid(agentsAsync, teamsAsync, sessionsAsync, toolsAsync),

                    const SizedBox(height: 20),

                    // ── SYSTEM HEALTH ──────────────────────────────────
                    _buildSectionHeader('SYSTEM HEALTH', 'Core infrastructure status', onAction: () => context.push('/metrics')),
                    const SizedBox(height: 12),
                    _buildSystemHealth(),

                    const SizedBox(height: 20),

                    // ── QUICK ACTIONS ──────────────────────────────────
                    _buildSectionHeader('QUICK ACTIONS', 'Primary operations'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),

                    const SizedBox(height: 20),

                    // ── INTEGRATIONS ───────────────────────────────────
                    _buildSectionHeader('INTEGRATIONS', 'Connected data sources'),
                    const SizedBox(height: 12),
                    _buildIntegrations(),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeString() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final day = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][now.weekday % 7];
    return '$day $hour:$minute LOCAL';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LEGACY STATUS CARD
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildLegacyStatusCard() {
    final color = _getAwarenessColor(_currentMode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Avatar + Status + Quick actions
          Row(
            children: [
              // Avatar with glow
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.psychology, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LEGACY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Status dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TacticalColors.operational,
                            boxShadow: [
                              BoxShadow(
                                color: TacticalColors.operational.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ONLINE',
                          style: TextStyle(
                            color: TacticalColors.operational,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mode badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _currentMode.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick action buttons
              _buildQuickIconButton(Icons.terminal, TacticalColors.operational, () => context.push('/chat')),
              const SizedBox(width: 8),
              _buildQuickIconButton(Icons.visibility, TacticalColors.complete, () => context.push('/eagle-eye')),
            ],
          ),

          const SizedBox(height: 16),

          // Awareness mode selector
          Row(
            children: ['dormant', 'aware', 'present', 'omnipresent'].map((mode) {
              final isSelected = _currentMode == mode;
              final modeColor = _getAwarenessColor(mode);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: mode != 'omnipresent' ? 8 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _currentMode = mode),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? modeColor.withValues(alpha: 0.2) : TacticalColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? modeColor : TacticalColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getAwarenessIcon(mode),
                            color: isSelected ? modeColor : TacticalColors.textDim,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mode.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? modeColor : TacticalColors.textDim,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LIVE FEED
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildLiveFeed() {
    final events = [
      _FeedItem('Agent @coder completed task', 'AGENT', DateTime.now().subtract(const Duration(minutes: 2)), TacticalColors.operational),
      _FeedItem('New email from client@company.com', 'EMAIL', DateTime.now().subtract(const Duration(minutes: 15)), TacticalColors.complete),
      _FeedItem('GitHub: PR merged to main', 'GITHUB', DateTime.now().subtract(const Duration(minutes: 32)), Colors.white),
      _FeedItem('Calendar: Meeting in 1 hour', 'CALENDAR', DateTime.now().subtract(const Duration(hours: 1)), Colors.blue),
    ];

    return Container(
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(bottom: BorderSide(color: TacticalColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getSourceIcon(event.source), color: event.color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: TacticalColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        event.source,
                        style: TextStyle(
                          color: event.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRelativeTime(event.timestamp),
                  style: const TextStyle(
                    color: TacticalColors.textDim,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source.toUpperCase()) {
      case 'AGENT': return Icons.smart_toy_outlined;
      case 'EMAIL': return Icons.email_outlined;
      case 'GITHUB': return Icons.code;
      case 'CALENDAR': return Icons.event;
      case 'TODOIST': return Icons.check_circle_outline;
      default: return Icons.notifications_outlined;
    }
  }

  String _formatRelativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // THREE PILLARS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildThreePillars() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        children: [
          _buildPillarRow('HP', 'Health Performance', 78, TacticalColors.primary, Icons.favorite),
          const SizedBox(height: 14),
          _buildPillarRow('LE', 'Life Enhancement', 65, TacticalColors.inProgress, Icons.bolt),
          const SizedBox(height: 14),
          _buildPillarRow('GE', 'Growth & Evolution', 82, TacticalColors.operational, Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildPillarRow(String code, String label, int value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 28,
          child: Text(
            code,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: TacticalColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$value%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // WORKFORCE GRID
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildWorkforceGrid(
    AsyncValue<List<dynamic>> agentsAsync,
    AsyncValue<List<dynamic>> teamsAsync,
    AsyncValue<List<dynamic>> sessionsAsync,
    AsyncValue<dynamic> toolsAsync,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: agentsAsync.when(
                data: (agents) => _buildStatCard('AGENTS', '${agents.length}', Icons.smart_toy_outlined, TacticalColors.operational, () => context.push('/agents')),
                loading: () => _buildStatCard('AGENTS', '--', Icons.smart_toy_outlined, TacticalColors.textDim, null),
                error: (_, __) => _buildStatCard('AGENTS', '!', Icons.smart_toy_outlined, TacticalColors.nonOperational, null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: teamsAsync.when(
                data: (teams) => _buildStatCard('TEAMS', '${teams.length}', Icons.groups_outlined, TacticalColors.complete, () => context.push('/teams')),
                loading: () => _buildStatCard('TEAMS', '--', Icons.groups_outlined, TacticalColors.textDim, null),
                error: (_, __) => _buildStatCard('TEAMS', '!', Icons.groups_outlined, TacticalColors.nonOperational, null),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) => _buildStatCard('SESSIONS', '${sessions.length}', Icons.history, TacticalColors.inProgress, () => context.push('/sessions')),
                loading: () => _buildStatCard('SESSIONS', '--', Icons.history, TacticalColors.textDim, null),
                error: (_, __) => _buildStatCard('SESSIONS', '!', Icons.history, TacticalColors.nonOperational, null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: toolsAsync.when(
                data: (tools) {
                  final count = tools is List ? tools.length : 0;
                  return _buildStatCard('TOOLS', '$count', Icons.build_outlined, TacticalColors.primary, () => context.push('/tools'));
                },
                loading: () => _buildStatCard('TOOLS', '--', Icons.build_outlined, TacticalColors.textDim, null),
                error: (_, __) => _buildStatCard('TOOLS', '!', Icons.build_outlined, TacticalColors.nonOperational, null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TacticalColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: TacticalColors.textDim,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: TacticalColors.textDim, size: 16),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SYSTEM HEALTH
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSystemHealth() {
    final services = [
      _ServiceStatus('AgentOS', true, 42),
      _ServiceStatus('Gateway', true, 28),
      _ServiceStatus('NATS', false, null),
      _ServiceStatus('Database', true, 15),
      _ServiceStatus('Redis', true, 8),
    ];

    final onlineCount = services.where((s) => s.isOnline).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        children: [
          // Summary row
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onlineCount == services.length
                      ? TacticalColors.operational
                      : TacticalColors.inProgress,
                  boxShadow: [
                    BoxShadow(
                      color: (onlineCount == services.length
                              ? TacticalColors.operational
                              : TacticalColors.inProgress)
                          .withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$onlineCount of ${services.length} services online',
                style: const TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Service chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: services.map((service) {
              final color = service.isOnline ? TacticalColors.operational : TacticalColors.nonOperational;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.name,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (service.latencyMs != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${service.latencyMs}ms',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: TacticalPrimaryButton(
            label: 'NEW SITREP',
            icon: Icons.add_alert,
            onTap: () => context.push('/sitreps/new'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TacticalOutlineButton(
            label: 'RUN AGENT',
            icon: Icons.play_arrow,
            onTap: () => context.push('/chat'),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // INTEGRATIONS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildIntegrations() {
    final integrations = [
      _Integration('CalDAV', Icons.event, true, '3 calendars'),
      _Integration('IMAP', Icons.email, true, '2 accounts'),
      _Integration('RSS', Icons.rss_feed, true, '12 feeds'),
      _Integration('GitHub', Icons.code, true, 'Connected'),
      _Integration('Todoist', Icons.check_circle, true, 'Synced'),
      _Integration('Linear', Icons.dashboard, false, 'Setup needed'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        children: integrations.asMap().entries.map((entry) {
          final index = entry.key;
          final integration = entry.value;
          final isLast = index == integrations.length - 1;

          return InkWell(
            onTap: () => context.push('/settings'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: TacticalColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (integration.isConnected
                              ? TacticalColors.operational
                              : TacticalColors.inactive)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      integration.icon,
                      color: integration.isConnected
                          ? TacticalColors.operational
                          : TacticalColors.inactive,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          integration.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          integration.status,
                          style: TextStyle(
                            color: integration.isConnected
                                ? TacticalColors.operational
                                : TacticalColors.textDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: integration.isConnected
                          ? TacticalColors.operational
                          : TacticalColors.inactive,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, String subtitle, {VoidCallback? onAction}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: TacticalColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: TacticalColors.textDim,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: TacticalColors.primary, size: 14),
              ],
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════════
  Color _getAwarenessColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'omnipresent':
        return TacticalColors.primary;
      case 'present':
        return TacticalColors.inProgress;
      case 'aware':
        return TacticalColors.complete;
      case 'dormant':
      default:
        return TacticalColors.textDim;
    }
  }

  IconData _getAwarenessIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'omnipresent':
        return Icons.flash_on;
      case 'present':
        return Icons.visibility;
      case 'aware':
        return Icons.remove_red_eye_outlined;
      case 'dormant':
      default:
        return Icons.bedtime;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ════════════════════════════════════════════════════════════════════════════

class _FeedItem {
  final String title;
  final String source;
  final DateTime timestamp;
  final Color color;

  const _FeedItem(this.title, this.source, this.timestamp, this.color);
}

class _ServiceStatus {
  final String name;
  final bool isOnline;
  final int? latencyMs;

  const _ServiceStatus(this.name, this.isOnline, this.latencyMs);
}

class _Integration {
  final String name;
  final IconData icon;
  final bool isConnected;
  final String status;

  const _Integration(this.name, this.icon, this.isConnected, this.status);
}
