import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import 'system_topology_screen.dart';
import 'system_pulse_screen.dart';
import 'system_logs_screen.dart';
import 'settings_screen.dart';

class SystemsScreen extends ConsumerStatefulWidget {
  const SystemsScreen({super.key});

  @override
  ConsumerState<SystemsScreen> createState() => _SystemsScreenState();
}

class _SystemsScreenState extends ConsumerState<SystemsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: AppBar(
          backgroundColor: TacticalColors.surface,
          elevation: 0,
          title: Text(
            'SYSTEM CONTROLS',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: TacticalColors.primary,
            labelColor: TacticalColors.primary,
            unselectedLabelColor: TacticalColors.primary.withValues(alpha: 0.4),
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'PULSE'),
              Tab(text: 'TOPOLOGY'),
              Tab(text: 'LOGS'),
              Tab(text: 'SETTINGS'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SystemPulseScreen(embedded: true),
            SystemTopologyScreen(embedded: true),
            SystemLogsScreen(embedded: true),
            SettingsScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
