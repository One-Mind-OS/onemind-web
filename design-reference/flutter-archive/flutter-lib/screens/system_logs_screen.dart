import 'package:flutter/material.dart';
import '../config/tactical_theme.dart';

class SystemLogsScreen extends StatelessWidget {
  final bool embedded;
  const SystemLogsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    // Mock logs for now
    final logs = List.generate(
      20,
      (index) => '[${DateTime.now().subtract(Duration(minutes: index)).toIso8601String()}] [INFO] System heartbeat check passed.',
    );

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: embedded
          ? null
          : AppBar(
              title: const Text('SYSTEM LOGS', style: TextStyle(fontFamily: 'monospace')),
              backgroundColor: TacticalColors.surface,
            ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              logs[index],
              style: TextStyle(
                color: TacticalColors.primary.withValues(alpha: 0.8),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}
