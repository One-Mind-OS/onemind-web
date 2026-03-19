import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sidebar.dart';

/// AppShell — Responsive layout with persistent sidebar on desktop,
/// hamburger-triggered drawer on mobile.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const double _breakpoint = 768;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= _breakpoint;

    return isWide ? _desktopLayout(context, ref) : _mobileLayout(context, ref);
  }

  /// Desktop: persistent sidebar + content
  Widget _desktopLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          const OneMindSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Mobile: hamburger menu opens sidebar as drawer
  Widget _mobileLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const Drawer(child: OneMindSidebar(isDrawerMode: true)),
      body: child,
    );
  }
}
