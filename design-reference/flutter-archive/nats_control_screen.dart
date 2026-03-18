import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config/tactical_theme.dart';
import '../components/status_badge.dart';

/// NATS Control Screen — Event Bus Command Center
/// ================================================
/// Manage NATS streams, subjects, view metrics, toggle
/// global + per-entity event publishing.

class NatsControlScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const NatsControlScreen({super.key, this.embedded = false});

  @override
  ConsumerState<NatsControlScreen> createState() => _NatsControlScreenState();
}

class _NatsControlScreenState extends ConsumerState<NatsControlScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _switchState = {};
  Map<String, dynamic> _busStatus = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadAll());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final futures = await Future.wait([
        ApiService.getNatsStatus(),
        ApiService.getSystemBusStatus(),
      ]);

      if (mounted) {
        setState(() {
          _switchState = futures[0];
          _busStatus = futures[1];
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleGlobal(bool enabled) async {
    try {
      await ApiService.setNatsGlobal(enabled);
      _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If embedded, return content directly without Scaffold
    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: TacticalColors.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
                ],
              ))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusStatus(),
                    const SizedBox(height: 20),
                    _buildGlobalSwitch(),
                    const SizedBox(height: 20),
                    _buildEntitySwitches(),
                    const SizedBox(height: 20),
                    _buildStreamsInfo(),
                  ],
                ),
              );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: TacticalColors.background,
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: _loadAll,
          backgroundColor: TacticalColors.surface,
          child: Icon(Icons.refresh, color: TacticalColors.textSecondary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        title: Row(
          children: [
            Icon(Icons.electrical_services, color: TacticalColors.cyan, size: 22),
            const SizedBox(width: 10),
            Text('NATS CONTROL', style: TacticalText.screenTitle.copyWith(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.textSecondary),
            onPressed: _loadAll,
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBusStatus() {
    final connected = _busStatus['connected'] ?? false;
    final server = _busStatus['server'] ?? 'N/A';
    final uptime = _busStatus['uptime'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.card(
        borderColor: connected
            ? TacticalColors.success.withValues(alpha: 0.3)
            : TacticalColors.error.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                size: 12,
                color: connected ? TacticalColors.success : TacticalColors.error,
                isActive: connected,
                tooltip: connected ? 'NATS Connected' : 'NATS Disconnected',
              ),
              const SizedBox(width: 10),
              Text('NATS JetStream', style: TacticalText.cardTitle.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: TacticalDecoration.statusBadge(
                    connected ? TacticalColors.success : TacticalColors.error),
                child: Text(connected ? 'CONNECTED' : 'DISCONNECTED',
                    style: TextStyle(
                      fontSize: 10,
                      color: connected ? TacticalColors.success : TacticalColors.error,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('Server', server.toString(), TacticalColors.info),
              const SizedBox(width: 12),
              _statCard('Uptime', uptime.toString(), TacticalColors.success),
              const SizedBox(width: 12),
              _statCard('Protocol', 'NATS + MQTT', TacticalColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TacticalText.label.copyWith(fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSwitch() {
    final globalEnabled = _switchState['global_enabled'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card(),
      child: Row(
        children: [
          Icon(Icons.power_settings_new,
              color: globalEnabled ? TacticalColors.success : TacticalColors.inactive, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Global Event Publishing', style: TacticalText.cardTitle),
                Text('Master switch for all NATS event streams',
                    style: TextStyle(color: TacticalColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: globalEnabled,
            onChanged: _toggleGlobal,
            activeThumbColor: TacticalColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildEntitySwitches() {
    final entities = (_switchState['entities'] as Map<String, dynamic>?) ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ENTITY SWITCHES', style: TacticalText.sectionHeader),
        const SizedBox(height: 12),
        if (entities.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: TacticalDecoration.card(),
            child: Text('No per-entity overrides configured',
                style: TextStyle(color: TacticalColors.textDim)),
          )
        else
          ...entities.entries.map((e) {
            final entityName = e.key;
            final enabled = e.value == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: TacticalDecoration.card(),
              child: Row(
                children: [
                  StatusBadge(
                    size: 8,
                    color: enabled ? TacticalColors.success : TacticalColors.inactive,
                    isActive: enabled,
                    tooltip: enabled ? 'Events Enabled' : 'Events Disabled',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(entityName, style: TacticalText.cardTitle.copyWith(fontSize: 13)),
                  ),
                  Text(enabled ? 'ON' : 'OFF',
                      style: TextStyle(
                        color: enabled ? TacticalColors.success : TacticalColors.inactive,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStreamsInfo() {
    final streams = (_busStatus['streams'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('JETSTREAM STREAMS', style: TacticalText.sectionHeader),
        const SizedBox(height: 12),
        if (streams.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: TacticalDecoration.card(),
            child: Row(
              children: [
                Icon(Icons.stream, color: TacticalColors.textDim, size: 20),
                const SizedBox(width: 12),
                Text('Stream info unavailable — connect to NATS to see streams',
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 12)),
              ],
            ),
          )
        else
          ...streams.map((s) {
            final streamMap = s as Map<String, dynamic>;
            final name = streamMap['name'] ?? '';
            final subjects = (streamMap['subjects'] as List?)?.join(', ') ?? '';
            final messages = streamMap['messages'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: TacticalDecoration.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stream, color: TacticalColors.cyan, size: 16),
                      const SizedBox(width: 8),
                      Text(name.toString(), style: TacticalText.cardTitle.copyWith(fontSize: 13)),
                      const Spacer(),
                      Text('$messages msgs',
                          style: TextStyle(color: TacticalColors.textDim, fontSize: 11, fontFamily: 'monospace')),
                    ],
                  ),
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(subjects, style: TextStyle(
                      color: TacticalColors.textMuted, fontSize: 11, fontFamily: 'monospace')),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}
