import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/tactical.dart';
import '../../shared/widgets/tactical/tactical_widgets.dart';
import '../widgets/tactical_drawer.dart';

/// Current tactical nav index provider
final tacticalNavIndexProvider = StateProvider<int>((ref) => 0);

/// Tactical Shell - Main navigation wrapper
/// Provides bottom navigation (5 items) + drawer for full menu:
/// - COMMAND (Dashboard)
/// - MAP (Geographic view)
/// - SITREPS (Situation reports)
/// - MISSIONS (Active runs)
/// - TERMINAL (Chat interface)
/// + Drawer for all other screens
class TacticalShell extends ConsumerStatefulWidget {
  final Widget child;

  const TacticalShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<TacticalShell> createState() => _TacticalShellState();
}

class _TacticalShellState extends ConsumerState<TacticalShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _navItems = [
    TacticalNavItem(
      icon: Icons.dashboard_outlined,
      label: 'COMMAND',
      route: '/command',
    ),
    TacticalNavItem(
      icon: Icons.map_outlined,
      label: 'MAP',
      route: '/map',
    ),
    TacticalNavItem(
      icon: Icons.warning_amber_rounded,
      label: 'SITREP',
      route: '/sitreps',
    ),
    TacticalNavItem(
      icon: Icons.assignment_outlined,
      label: 'MISSIONS',
      route: '/missions',
    ),
    TacticalNavItem(
      icon: Icons.terminal,
      label: 'TERMINAL',
      route: '/chat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tacticalNavIndexProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TacticalColors.background,
      drawer: const TacticalDrawer(),
      body: Stack(
        children: [
          // Main content
          widget.child,
          // Floating menu button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _buildMenuButton(),
          ),
        ],
      ),
      bottomNavigationBar: TacticalBottomNav(
        currentIndex: currentIndex,
        items: _navItems,
        onTap: (index) {
          ref.read(tacticalNavIndexProvider.notifier).state = index;
          context.go(_navItems[index].route);
        },
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: TacticalColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TacticalColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu,
                color: TacticalColors.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'MENU',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Get nav index from route
int getNavIndexFromRoute(String route) {
  if (route.startsWith('/command') || route == '/') return 0;
  if (route.startsWith('/map')) return 1;
  if (route.startsWith('/sitreps')) return 2;
  if (route.startsWith('/missions')) return 3;
  if (route.startsWith('/chat') || route.startsWith('/terminal')) return 4;
  // All drawer routes don't highlight any nav item (return -1 or keep at current)
  return -1;
}
