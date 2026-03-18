import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';
import '../providers/theme_provider.dart';
import '../components/status_badge.dart';

/// Settings Screen — System Configuration
/// ========================================
/// API connectivity, NATS config, theme, system info.

class SettingsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _systemInfo = {};
  Map<String, dynamic> _health = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final futures = await Future.wait([
        ApiService.getSystemInfo(),
        ApiService.getHealth(),
      ]);

      if (mounted) {
        setState(() {
          _systemInfo = futures[0];
          _health = futures[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: TacticalColors.surface,
              title: Row(
                children: [
                  Icon(Icons.settings, color: TacticalColors.cyan, size: 22),
                  const SizedBox(width: 10),
                  Text('SETTINGS', style: TacticalText.screenTitle.copyWith(fontSize: 18)),
                ],
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('CONNECTION', _buildConnection()),
                  const SizedBox(height: 24),
                  _buildSection('NATS CONFIGURATION', _buildNatsConfig()),
                  const SizedBox(height: 24),
                  _buildSection('APPEARANCE', _buildAppearance()),
                  const SizedBox(height: 24),
                  _buildSection('SYSTEM INFO', _buildSystemInfo()),
                  const SizedBox(height: 24),
                  _buildSection('DANGER ZONE', _buildDanger()),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TacticalText.sectionHeader),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildConnection() {
    final status = _health['status'] ?? 'unknown';
    final isHealthy = status == 'healthy' || status == 'ok';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(),
      child: Column(
        children: [
          _settingRow(
            'API Base URL',
            ApiService.baseUrl,
            icon: Icons.link,
            trailing: StatusBadge(
              size: 10,
              color: isHealthy ? TacticalColors.success : TacticalColors.error,
              isActive: isHealthy,
              tooltip: isHealthy ? 'Backend Connected' : 'Backend Disconnected',
            ),
          ),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow(
            'Backend Status',
            isHealthy ? 'Connected' : 'Disconnected',
            icon: Icons.cloud_done,
            valueColor: isHealthy ? TacticalColors.success : TacticalColors.error,
          ),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow(
            'WebSocket',
            '${ApiService.baseUrl}/ws',
            icon: Icons.cable,
          ),
        ],
      ),
    );
  }

  Widget _buildNatsConfig() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(),
      child: Column(
        children: [
          _settingRow('Server', 'nats://localhost:4222', icon: Icons.dns),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('MQTT Bridge', 'mqtt://localhost:1883', icon: Icons.router),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('HTTP Monitor', 'http://localhost:8222', icon: Icons.monitor_heart),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('WebSocket Port', '9080', icon: Icons.electrical_services),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('Streams', '5 (agents, tasks, system, iot, calendar)', icon: Icons.stream),
        ],
      ),
    );
  }

  Widget _buildAppearance() {
    final currentTheme = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Theme Mode',
              style: TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          RadioListTile<AppThemeMode>(
            title: Text('Light', style: TacticalText.cardTitle),
            subtitle: Text(
              'Default light theme',
              style: TacticalText.bodySmall,
            ),
            value: AppThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeProvider.notifier).setTheme(value);
              }
            },
            activeColor: TacticalColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          RadioListTile<AppThemeMode>(
            title: Text('Dark', style: TacticalText.cardTitle),
            subtitle: Text(
              'OneMind tactical dark mode',
              style: TacticalText.bodySmall,
            ),
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeProvider.notifier).setTheme(value);
              }
            },
            activeColor: TacticalColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          RadioListTile<AppThemeMode>(
            title: Text('Tactical Solarpunk', style: TacticalText.cardTitle),
            subtitle: Text(
              'Forest guardian command center',
              style: TacticalText.bodySmall,
            ),
            value: AppThemeMode.solarpunk,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeProvider.notifier).setTheme(value);
              }
            },
            activeColor: TacticalColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const Divider(color: Color(0xFF1A1A2E), height: 24),
          Row(
            children: [
              Icon(Icons.color_lens_outlined, color: TacticalColors.textDim, size: 18),
              const SizedBox(width: 12),
              Text('Current Accent Colors', style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13)),
              const Spacer(),
              _colorChip(TacticalColors.cyan, 'Cyan'),
              const SizedBox(width: 6),
              _colorChip(TacticalColors.primary, 'Primary'),
              const SizedBox(width: 6),
              _colorChip(TacticalColors.success, 'Success'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorChip(Color color, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    final version = _systemInfo['version'] ?? '2.0.0';
    final agents = _systemInfo['agent_count'] ?? 0;
    final uptime = _systemInfo['uptime'] ?? 'N/A';
    final database = _systemInfo['database'] ?? 'PostgreSQL + pgvector + TimescaleDB';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(),
      child: Column(
        children: [
          _settingRow('Version', 'OneMind OS v$version', icon: Icons.info_outline),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('Active Agents', '$agents', icon: Icons.smart_toy),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('Uptime', uptime.toString(), icon: Icons.timer),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('Database', database.toString(), icon: Icons.storage),
          const Divider(color: Color(0xFF1A1A2E)),
          _settingRow('Framework', 'Agno AgentOS + FastAPI', icon: Icons.architecture),
        ],
      ),
    );
  }

  Widget _buildDanger() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(
        borderColor: TacticalColors.error.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_sweep, color: TacticalColors.error),
            title: Text('Clear Activity Log', style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13)),
            subtitle: Text('Remove all activity entries', style: TextStyle(color: TacticalColors.textDim, fontSize: 11)),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: TacticalColors.error,
                side: BorderSide(color: TacticalColors.error.withValues(alpha: 0.3)),
              ),
              onPressed: () => _confirmAction('Clear activity log?'),
              child: const Text('CLEAR', style: TextStyle(fontSize: 11)),
            ),
          ),
          const Divider(color: Color(0xFF1A1A2E)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restart_alt, color: TacticalColors.warning),
            title: Text('Reset Capabilities', style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13)),
            subtitle: Text('Re-scan all system capabilities', style: TextStyle(color: TacticalColors.textDim, fontSize: 11)),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: TacticalColors.warning,
                side: BorderSide(color: TacticalColors.warning.withValues(alpha: 0.3)),
              ),
              onPressed: () => _confirmAction('Reset capabilities?'),
              child: const Text('RESET', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String label, String value, {
    IconData? icon,
    Widget? trailing,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: TacticalColors.textDim, size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(label, style: TextStyle(color: TacticalColors.textPrimary, fontSize: 13)),
          ),
          if (trailing != null)
            trailing
          else
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? TacticalColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmAction(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: Text('Confirm', style: TextStyle(color: TacticalColors.textPrimary)),
        content: Text(message, style: TextStyle(color: TacticalColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: TacticalColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CONFIRM', style: TextStyle(color: TacticalColors.error)),
          ),
        ],
      ),
    );
  }
}
