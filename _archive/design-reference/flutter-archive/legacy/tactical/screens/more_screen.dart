import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';

/// MORE Screen - Tactical Command Menu
/// Military-grade overflow menu with categorized sections.
///
/// PRIMARY SECTIONS:
/// - ASSETS: Agents, Teams, Models, Tools, MCP Servers
/// - HARDWARE: Robotics, Drones, Vehicles, Watch, Frame
/// - PROTOCOLS: Skills, Workflows
/// - OPERATIONS: Sessions, Approvals, Metrics, Traces
/// - OPERATOR: Health, Presence, Biometrics
/// - SURVEILLANCE: Eagle Eye
///
/// SECONDARY:
/// - INTEL: Memory, Knowledge
/// - COMMS: Terminal (also in bottom nav)
/// - SYSTEM: Settings
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: CustomScrollView(
        slivers: [
          // Tactical App Bar
          SliverAppBar(
            backgroundColor: TacticalColors.background,
            elevation: 0,
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TacticalColors.border, width: 1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: TacticalColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'COMMAND MENU',
                            style: TextStyle(
                              color: TacticalColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: TacticalColors.primary,
                              borderRadius: BorderRadius.circular(2),
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

          // Menu Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ══════════════════════════════════════════════════════════
                // ASSETS - AI workforce and physical capabilities
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'ASSETS',
                  subtitle: 'AI WORKFORCE & CAPABILITIES',
                  items: [
                    _TacticalItem(Icons.smart_toy_outlined, 'AGENTS', '/agents'),
                    _TacticalItem(Icons.groups_outlined, 'TEAMS', '/teams'),
                    _TacticalItem(Icons.model_training, 'MODELS', '/models'),
                    _TacticalItem(Icons.build_outlined, 'TOOLS', '/tools'),
                    _TacticalItem(Icons.hub_outlined, 'MCP SERVERS', '/mcp'),
                  ],
                ),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // HARDWARE - Physical devices and robotics
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'HARDWARE',
                  subtitle: 'PHYSICAL SYSTEMS & WEARABLES',
                  items: [
                    _TacticalItem(Icons.precision_manufacturing, 'ROBOTICS', '/robotics'),
                    _TacticalItem(Icons.flight, 'DRONES', '/drones'),
                    _TacticalItem(Icons.directions_car, 'VEHICLES', '/vehicles'),
                    _TacticalItem(Icons.watch, 'WATCH', '/watch'),
                    _TacticalItem(Icons.preview, 'FRAME', '/frame'),
                  ],
                ),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // PROTOCOLS - Standard operating procedures
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'PROTOCOLS',
                  subtitle: 'STANDARD OPERATING PROCEDURES',
                  items: [
                    _TacticalItem(Icons.auto_fix_high, 'SKILLS', '/skills'),
                    _TacticalItem(Icons.account_tree_outlined, 'WORKFLOWS', '/workflows'),
                  ],
                ),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // OPERATIONS - Active missions & observability
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'OPERATIONS',
                  subtitle: 'MISSION CONTROL & OBSERVABILITY',
                  items: [
                    _TacticalItem(Icons.history, 'SESSIONS', '/sessions'),
                    _TacticalItem(Icons.verified_user_outlined, 'APPROVALS', '/approvals'),
                    _TacticalItem(Icons.insights, 'METRICS', '/metrics'),
                    _TacticalItem(Icons.timeline, 'TRACES', '/traces'),
                    _TacticalItem(Icons.notifications_outlined, 'NOTIFICATIONS', '/notifications'),
                    _TacticalItem(Icons.inbox_outlined, 'ACTIVITY', '/activity'),
                  ],
                ),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // OPERATOR - Human status & health
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'OPERATOR',
                  subtitle: 'HUMAN STATUS & HEALTH INTEL',
                  items: [
                    _TacticalItem(Icons.monitor_heart_outlined, 'HEALTH', '/health'),
                    _TacticalItem(Icons.person_pin_circle, 'PRESENCE', '/presence'),
                    _TacticalItem(Icons.monitor_heart, 'BIOMETRICS', '/biometrics'),
                  ],
                ),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // SURVEILLANCE - Security & monitoring
                // ══════════════════════════════════════════════════════════
                _TacticalSection(
                  title: 'SURVEILLANCE',
                  subtitle: 'SECURITY & MONITORING',
                  items: [
                    _TacticalItem(Icons.visibility, 'EAGLE EYE', '/eagle-eye'),
                    _TacticalItem(Icons.hub_outlined, 'EDGE AI', '/edge-ai'),
                    _TacticalItem(Icons.account_tree_outlined, 'VISION PIPELINE', '/vision-pipeline'),
                  ],
                ),

                const SizedBox(height: 32),

                // ══════════════════════════════════════════════════════════
                // SECONDARY SECTION DIVIDER
                // ══════════════════════════════════════════════════════════
                _buildSecondaryDivider(),

                const SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // INTEL - Intelligence & context (SECONDARY)
                // ══════════════════════════════════════════════════════════
                _TacticalSectionSecondary(
                  title: 'INTEL',
                  items: [
                    _TacticalItem(Icons.psychology_outlined, 'MEMORY', '/memory'),
                    _TacticalItem(Icons.auto_stories_outlined, 'KNOWLEDGE', '/knowledge'),
                  ],
                ),

                const SizedBox(height: 16),

                // ══════════════════════════════════════════════════════════
                // COMMS - Communication (SECONDARY)
                // ══════════════════════════════════════════════════════════
                _TacticalSectionSecondary(
                  title: 'COMMS',
                  items: [
                    _TacticalItem(Icons.terminal, 'TERMINAL', '/chat'),
                  ],
                ),

                const SizedBox(height: 32),

                // ══════════════════════════════════════════════════════════
                // SYSTEM - Settings (Always at bottom)
                // ══════════════════════════════════════════════════════════
                _buildSystemButton(context),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  TacticalColors.border,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SECONDARY',
            style: TextStyle(
              color: TacticalColors.textDim,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TacticalColors.border,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/settings'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TacticalColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TacticalColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              color: TacticalColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'SYSTEM SETTINGS',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTICAL SECTION - Primary sections with full styling
// ════════════════════════════════════════════════════════════════════════════

class _TacticalSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_TacticalItem> items;

  const _TacticalSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with red accent
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TacticalColors.border),
                left: BorderSide(color: TacticalColors.primary, width: 3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: TacticalColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: TacticalColors.textDim,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // Item count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TacticalColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => _TacticalGridItem(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTICAL SECTION SECONDARY - Simpler styling for secondary sections
// ════════════════════════════════════════════════════════════════════════════

class _TacticalSectionSecondary extends StatelessWidget {
  final String title;
  final List<_TacticalItem> items;

  const _TacticalSectionSecondary({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: TacticalColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ),
        // Items as simple list
        ...items.map((item) => _TacticalSecondaryItem(item: item)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTICAL GRID ITEM - Grid-style item for primary sections
// ════════════════════════════════════════════════════════════════════════════

class _TacticalGridItem extends StatelessWidget {
  final _TacticalItem item;

  const _TacticalGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: TacticalColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: TacticalColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: TacticalColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTICAL SECONDARY ITEM - Simple list item for secondary sections
// ════════════════════════════════════════════════════════════════════════════

class _TacticalSecondaryItem extends StatelessWidget {
  final _TacticalItem item;

  const _TacticalSecondaryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: TacticalColors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: TacticalColors.textDim,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: TacticalColors.textDim,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

class _TacticalItem {
  final IconData icon;
  final String label;
  final String route;

  const _TacticalItem(this.icon, this.label, this.route);
}
