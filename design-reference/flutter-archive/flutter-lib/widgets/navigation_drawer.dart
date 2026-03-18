import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/tactical_theme.dart';

/// Compact Navigation Drawer with Collapsible Sections
class OneMindNavigationDrawer extends ConsumerWidget {
  const OneMindNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return Drawer(
      backgroundColor: TacticalColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TacticalColors.surface,
              border: Border(bottom: BorderSide(color: TacticalColors.primary.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TacticalColors.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TacticalColors.primary, width: 2),
                  ),
                  child: Icon(Icons.campaign_outlined, color: TacticalColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ONEMIND OS', style: TextStyle(color: TacticalColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('v2.0', style: TextStyle(color: TacticalColors.textMuted, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation - Collapsible Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(icon: Icons.inbox_outlined, label: 'INBOX', route: '/', current: currentRoute),
                _NavItem(icon: Icons.chat_outlined, label: 'CHAT', route: '/chat', current: currentRoute),
                _NavItem(icon: Icons.check_circle_outline, label: 'TASKS', route: '/tasks', current: currentRoute),
                _NavItem(icon: Icons.calendar_month_outlined, label: 'CALENDAR', route: '/calendar', current: currentRoute),

                _CollapsibleSection(
                  title: 'WORKFORCE',
                  icon: Icons.category_outlined,
                  children: [
                    _NavItem(icon: Icons.smart_toy_outlined, label: 'Agents', route: '/agents', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.groups_outlined, label: 'Teams', route: '/teams', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.precision_manufacturing_outlined, label: 'Machines', route: '/machines', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.view_list_outlined, label: 'All Assets', route: '/assets', current: currentRoute, compact: true),
                  ],
                ),

                _CollapsibleSection(
                  title: 'WORKSPACE',
                  icon: Icons.work_outline,
                  children: [
                    _NavItem(icon: Icons.rocket_launch_outlined, label: 'Projects', route: '/projects', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.description_outlined, label: 'Documents', route: '/documents', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.auto_stories_outlined, label: 'Knowledge', route: '/knowledge', current: currentRoute, compact: true),
                  ],
                ),

                _CollapsibleSection(
                  title: 'AUTOMATION',
                  icon: Icons.bolt_outlined,
                  children: [
                    _NavItem(icon: Icons.account_tree_outlined, label: 'Workflows', route: '/workflows', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.build_outlined, label: 'Tools & MCP', route: '/tools', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.history_outlined, label: 'Sessions', route: '/sessions', current: currentRoute, compact: true),
                  ],
                ),

                _CollapsibleSection(
                  title: 'SYSTEM',
                  icon: Icons.monitor_heart_outlined,
                  children: [
                    _NavItem(icon: Icons.monitor_heart_outlined, label: 'Mission Control', route: '/system', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.bolt_outlined, label: 'Events', route: '/events', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.bar_chart_outlined, label: 'Analytics', route: '/analytics', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.hub_outlined, label: 'Topology', route: '/topology', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.map_outlined, label: 'World Map', route: '/map', current: currentRoute, compact: true),
                  ],
                ),

                _CollapsibleSection(
                  title: 'GAME',
                  icon: Icons.sports_esports_outlined,
                  children: [
                    _NavItem(icon: Icons.person_outline, label: 'Commander', route: '/profile', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.flag_outlined, label: 'Quests', route: '/quests', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.account_tree_outlined, label: 'Skill Tree', route: '/skill-tree', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.fort_outlined, label: 'HQ', route: '/hq', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.shield_outlined, label: 'Tactical Base', route: '/base', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.list_alt_outlined, label: 'Roster', route: '/roster', current: currentRoute, compact: true),
                    _NavItem(icon: Icons.sports_esports_outlined, label: 'Game Hub', route: '/game', current: currentRoute, compact: true),
                  ],
                ),

                const Divider(height: 24),
                _NavItem(icon: Icons.link_outlined, label: 'INTEGRATIONS', route: '/integrations', current: currentRoute),
                _NavItem(icon: Icons.settings_outlined, label: 'SETTINGS', route: '/settings', current: currentRoute),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: TacticalColors.primary, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        iconColor: TacticalColors.primary,
        collapsedIconColor: TacticalColors.textMuted,
        children: children,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  final bool compact;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;

    return ListTile(
      dense: compact,
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 32 : 16,
        vertical: compact ? 0 : 4,
      ),
      leading: Icon(
        icon,
        color: isActive ? TacticalColors.primary : TacticalColors.textMuted,
        size: compact ? 18 : 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? TacticalColors.primary : TacticalColors.textMuted,
          fontSize: compact ? 12 : 13,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: compact ? 0.5 : 1,
        ),
      ),
      selected: isActive,
      selectedTileColor: TacticalColors.primary.withValues(alpha: 0.1),
      onTap: () {
        context.go(route);
        Navigator.pop(context);
      },
    );
  }
}
