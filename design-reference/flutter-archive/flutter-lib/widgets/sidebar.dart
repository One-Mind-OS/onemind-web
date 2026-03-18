import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../config/tactical_theme.dart';
import '../components/status_badge.dart';

/// Collapsible section state - Start with workspace, automation, and settings collapsed
final _collapsedSections = StateProvider<Set<String>>((ref) => {'workspace', 'automation', 'settings'});

/// OneMind Sidebar — Redesigned & Condensed (6 Sections)
/// Solar Punk Tactical Theme - Mobile & Web Friendly
class OneMindSidebar extends ConsumerWidget {
  final bool isDrawerMode;
  const OneMindSidebar({super.key, this.isDrawerMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final collapsed = ref.watch(_collapsedSections);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors using TacticalColors
    final bg = TacticalColors.background;
    final borderColor = TacticalColors.border;
    final sectionColor = TacticalColors.primary; // Amber in solarpunk, red in tactical
    final hoverBg = TacticalColors.primary.withValues(alpha: 0.05);
    final selectedBg = TacticalColors.primary.withValues(alpha: 0.1);
    final selectedFg = TacticalColors.primary;
    final defaultFg = TacticalColors.textMuted;
    final textColor = TacticalColors.textPrimary;
    final accentOrange = const Color(0xFFF97316); // Keep for specific icons
    final accentBlue = const Color(0xFF3B82F6);    // Keep for specific icons
    final accentPurple = const Color(0xFF8B5CF6);  // Keep for specific icons

    void go(String route) {
      context.go(route);
      if (isDrawerMode) Navigator.of(context).pop();
    }

    Widget sectionLabel(String label, String sectionKey, {IconData? icon, Color? iconColor, bool alwaysExpanded = false}) {
      if (alwaysExpanded) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 8, 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: iconColor ?? sectionColor),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: iconColor ?? sectionColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final isCollapsed = collapsed.contains(sectionKey);
      return InkWell(
        onTap: () {
          final s = Set<String>.from(collapsed);
          isCollapsed ? s.remove(sectionKey) : s.add(sectionKey);
          ref.read(_collapsedSections.notifier).state = s;
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 8, 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: iconColor ?? sectionColor),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: iconColor ?? sectionColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Icon(
                isCollapsed ? Icons.chevron_right : Icons.expand_more,
                size: 12,
                color: (iconColor ?? sectionColor).withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      );
    }

    Widget navItem(IconData icon, String label, String route, {String? badge, Color? badgeColor, Color? iconTint}) {
      final selected = currentRoute == route ||
          (route != '/' && currentRoute.startsWith(route) && route.length > 1);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            hoverColor: hoverBg,
            onTap: () => go(route),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: selected ? Border.all(color: selectedFg.withValues(alpha: 0.3), width: 1) : null,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 15, color: selected ? selectedFg : (iconTint ?? defaultFg)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? selectedFg : textColor,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? selectedFg).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badge, style: TextStyle(color: badgeColor ?? selectedFg, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    List<Widget> buildSection(String key, String label, List<Widget> items, {IconData? icon, Color? iconColor, bool alwaysExpanded = false}) {
      final isCollapsed = !alwaysExpanded && collapsed.contains(key);
      return [
        sectionLabel(label, key, icon: icon, iconColor: iconColor, alwaysExpanded: alwaysExpanded),
        if (!isCollapsed) ...items,
      ];
    }

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // ── HEADER ──
          Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF4ADE80), const Color(0xFF166534)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Center(child: Icon(Icons.hub_outlined, size: 18, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OneMind', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                      Text('TACTICAL OS', style: TextStyle(color: sectionColor, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // ── NAV SECTIONS ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                // ═══════════════════════════════════════════════════════════════
                // 🎯 COMMAND CENTER — Unified hub (Always Visible)
                // Combines: Command + System + Game
                // ═══════════════════════════════════════════════════════════════
                ...buildSection('command', 'COMMAND CENTER', [
                  // ── Core Ops ──
                  navItem(Icons.hub_outlined, 'Nexus', '/nexus', iconTint: accentPurple),
                  navItem(Icons.inbox_outlined, 'Inbox', '/'),
                  navItem(Icons.chat_bubble_outline, 'Chat', '/chat'),
                  navItem(Icons.check_circle_outline, 'Tasks', '/tasks'),
                  navItem(Icons.calendar_month_outlined, 'Calendar', '/calendar'),
                  navItem(Icons.timeline_outlined, 'Activity', '/activity'),
                  // ── System ──
                  const SizedBox(height: 4),
                  navItem(Icons.monitor_heart_outlined, 'Mission Control', '/system'),
                  navItem(Icons.bolt_outlined, 'Events', '/events'),
                  navItem(Icons.bar_chart_outlined, 'Analytics', '/analytics'),
                  navItem(Icons.favorite_outlined, 'Heartbeat', '/heartbeat', badge: 'LIVE', badgeColor: const Color(0xFF4ADE80)),
                  // ── Commander ──
                  const SizedBox(height: 4),
                  navItem(Icons.person_outline, 'Commander', '/profile'),
                  navItem(Icons.sports_esports_outlined, 'Game Hub', '/game', iconTint: const Color(0xFFFBBF24)),
                ], icon: Icons.terminal, alwaysExpanded: true),

                // ═══════════════════════════════════════════════════════════════
                // 🏗️ WORKFORCE — Agents, Teams, Machines, Humans
                // ═══════════════════════════════════════════════════════════════
                ...buildSection('workforce', 'WORKFORCE', [
                  navItem(Icons.smart_toy_outlined, 'Agents', '/agents'),
                  navItem(Icons.groups_outlined, 'Teams', '/teams'),
                  navItem(Icons.precision_manufacturing_outlined, 'Machines', '/machines'),
                  navItem(Icons.view_list_outlined, 'All Assets', '/assets', badge: 'NEW', badgeColor: accentOrange),
                ], icon: Icons.category_outlined, iconColor: accentBlue),

                // ═══════════════════════════════════════════════════════════════
                // 💼 WORKSPACE — Knowledge, Projects, Documents
                // ═══════════════════════════════════════════════════════════════
                ...buildSection('workspace', 'WORKSPACE', [
                  navItem(Icons.rocket_launch_outlined, 'Projects', '/projects'),
                  navItem(Icons.description_outlined, 'Documents', '/documents'),
                  navItem(Icons.auto_stories_outlined, 'Knowledge', '/knowledge'),
                  navItem(Icons.psychology_outlined, 'Memories', '/memories'),
                ], icon: Icons.work_outline, iconColor: accentPurple),

                // ═══════════════════════════════════════════════════════════════
                // ⚡ AUTOMATION — Workflows, Tools, MCP, Sessions
                // ═══════════════════════════════════════════════════════════════
                ...buildSection('automation', 'AUTOMATION', [
                  navItem(Icons.account_tree_outlined, 'Workflows', '/workflows'),
                  navItem(Icons.build_outlined, 'Tools & MCP', '/tools'),
                  navItem(Icons.history_outlined, 'Sessions', '/sessions'),
                ], icon: Icons.bolt_outlined, iconColor: accentOrange),

                // ═══════════════════════════════════════════════════════════════
                // ⚙️ SETTINGS — Configuration
                // ═══════════════════════════════════════════════════════════════
                ...buildSection('settings', 'SETTINGS', [
                  navItem(Icons.tune_outlined, 'Settings', '/settings'),
                  navItem(Icons.link_outlined, 'Integrations', '/integrations'),
                ], icon: Icons.settings_outlined, iconColor: Colors.grey),
              ],
            ),
          ),

          // ── FOOTER ──
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF050A05) : const Color(0xFFEAF5EA),
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // Status indicator with breathing animation in solarpunk
                StatusBadge(
                  size: 6,
                  color: TacticalColors.success,
                  isActive: true,
                  tooltip: 'Systems Online',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Systems Online', style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('8 agents • 3 teams', style: TextStyle(color: defaultFg, fontSize: 9)),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 16,
                        color: defaultFg,
                      ),
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
