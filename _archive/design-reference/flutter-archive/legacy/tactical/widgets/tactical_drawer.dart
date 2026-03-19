import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';

/// Tactical Drawer - Military-style side navigation
/// Contains all menu items organized by tactical sections.
class TacticalDrawer extends StatelessWidget {
  const TacticalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: TacticalColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════════════════════════════
            // HEADER
            // ══════════════════════════════════════════════════════════
            _buildHeader(context),

            const Divider(color: TacticalColors.border, height: 1),

            // ══════════════════════════════════════════════════════════
            // MENU CONTENT
            // ══════════════════════════════════════════════════════════
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // OPERATIONS (TOP)
                  _DrawerSection(
                    title: 'OPERATIONS',
                    items: [
                      _DrawerItem(Icons.history, 'Sessions', '/sessions'),
                      _DrawerItem(Icons.verified_user_outlined, 'Approvals', '/approvals'),
                      _DrawerItem(Icons.insights, 'Metrics', '/metrics'),
                      _DrawerItem(Icons.timeline, 'Traces', '/traces'),
                      _DrawerItem(Icons.notifications_outlined, 'Notifications', '/notifications'),
                      _DrawerItem(Icons.inbox_outlined, 'Activity', '/activity'),
                    ],
                  ),

                  // ASSETS
                  _DrawerSection(
                    title: 'ASSETS',
                    items: [
                      _DrawerItem(Icons.smart_toy_outlined, 'Agents', '/agents'),
                      _DrawerItem(Icons.groups_outlined, 'Teams', '/teams'),
                      _DrawerItem(Icons.model_training, 'Models', '/models'),
                      _DrawerItem(Icons.build_outlined, 'Tools', '/tools'),
                      _DrawerItem(Icons.hub_outlined, 'MCP Servers', '/mcp'),
                    ],
                  ),

                  // PROTOCOLS
                  _DrawerSection(
                    title: 'PROTOCOLS',
                    items: [
                      _DrawerItem(Icons.auto_fix_high, 'Skills', '/skills'),
                      _DrawerItem(Icons.account_tree_outlined, 'Workflows', '/workflows'),
                    ],
                  ),

                  // INTEL
                  _DrawerSection(
                    title: 'INTEL',
                    items: [
                      _DrawerItem(Icons.psychology_outlined, 'Memory', '/memory'),
                      _DrawerItem(Icons.auto_stories_outlined, 'Knowledge', '/knowledge'),
                    ],
                  ),

                  // HARDWARE
                  _DrawerSection(
                    title: 'HARDWARE',
                    items: [
                      _DrawerItem(Icons.precision_manufacturing, 'Robotics', '/robotics'),
                      _DrawerItem(Icons.flight, 'Drones', '/drones'),
                      _DrawerItem(Icons.directions_car, 'Vehicles', '/vehicles'),
                      _DrawerItem(Icons.watch, 'Watch', '/watch'),
                      _DrawerItem(Icons.preview, 'Frame', '/frame'),
                    ],
                  ),

                  // OPERATOR
                  _DrawerSection(
                    title: 'OPERATOR',
                    items: [
                      _DrawerItem(Icons.monitor_heart_outlined, 'Health', '/health'),
                      _DrawerItem(Icons.person_pin_circle, 'Presence', '/presence'),
                      _DrawerItem(Icons.monitor_heart, 'Biometrics', '/biometrics'),
                    ],
                  ),

                  // SURVEILLANCE
                  _DrawerSection(
                    title: 'SURVEILLANCE',
                    items: [
                      _DrawerItem(Icons.visibility, 'Eagle Eye', '/eagle-eye'),
                      _DrawerItem(Icons.hub_outlined, 'Edge AI', '/edge-ai'),
                      _DrawerItem(Icons.account_tree_outlined, 'Vision Pipeline', '/vision-pipeline'),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ══════════════════════════════════════════════════════════
            // FOOTER - Settings
            // ══════════════════════════════════════════════════════════
            const Divider(color: TacticalColors.border, height: 1),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TacticalColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: TacticalColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ONEMIND OS',
                  style: TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'COMMAND CENTER',
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: TacticalColors.textMuted),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.push('/settings');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TacticalColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: TacticalColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SYSTEM SETTINGS',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: TacticalColors.textDim, size: 18),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DRAWER SECTION
// ════════════════════════════════════════════════════════════════════════════

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItem> items;

  const _DrawerSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: TacticalColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        // Items
        ...items.map((item) => _DrawerMenuItem(item: item)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DRAWER MENU ITEM
// ════════════════════════════════════════════════════════════════════════════

class _DrawerMenuItem extends StatelessWidget {
  final _DrawerItem item;

  const _DrawerMenuItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isSelected = currentRoute.startsWith(item.route);

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.push(item.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TacticalColors.primary.withValues(alpha: 0.1) : null,
          border: isSelected
              ? Border(
                  left: BorderSide(color: TacticalColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isSelected ? TacticalColors.primary : TacticalColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? TacticalColors.primary : TacticalColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: TacticalColors.textDim,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ════════════════════════════════════════════════════════════════════════════

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem(this.icon, this.label, this.route);
}
