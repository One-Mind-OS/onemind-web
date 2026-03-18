import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../config/tactical_theme.dart';

/// System Pulse Screen — The Living OS Dashboard
/// ================================================
/// Shows real-time health of every subsystem: database, NATS bus,
/// agents, heartbeat, events, WebSocket connections, capabilities.
///
/// This is the "mission control" view that makes OneMind feel alive.

class SystemPulseScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SystemPulseScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SystemPulseScreen> createState() => _SystemPulseScreenState();
}

class _SystemPulseScreenState extends ConsumerState<SystemPulseScreen>
    with TickerProviderStateMixin {
  final String baseUrl = Environment.apiBaseUrl;

  // State
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _systemStatus;
  Map<String, dynamic>? _pulse;

  // Auto-refresh
  Timer? _pulseTimer;
  Timer? _statusTimer;
  late AnimationController _pulseAnimController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation (heartbeat effect)
    _pulseAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _loadFullStatus();

    // Auto-refresh pulse every 3 seconds
    _pulseTimer = Timer.periodic(const Duration(seconds: 3), (_) => _loadPulse());

    // Full status refresh every 15 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadFullStatus());
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _statusTimer?.cancel();
    _pulseAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadFullStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/system/status'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _systemStatus = json.decode(response.body);
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Status endpoint returned ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Cannot reach backend: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPulse() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/system/pulse'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _pulse = json.decode(response.body);
        });
      }
    } catch (_) {
      // Silently handle pulse failures
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: widget.embedded ? null : AppBar(
        backgroundColor: TacticalColors.surface,
        title: Row(
          children: [
            // Animated pulse indicator
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final isAlive = _pulse?['alive'] == true;
                return Container(
                  width: 12 * (_pulseAnimation.value),
                  height: 12 * (_pulseAnimation.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAlive
                        ? TacticalColors.success
                        : TacticalColors.error,
                    boxShadow: isAlive
                        ? [
                            BoxShadow(
                              color: TacticalColors.success.withValues(alpha: 0.5),
                              blurRadius: 8 * _pulseAnimation.value,
                              spreadRadius: 2 * _pulseAnimation.value,
                            )
                          ]
                        : [],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'SYSTEM PULSE',
              style: TacticalText.screenTitle,
            ),
            const SizedBox(width: 8),
            if (_systemStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _systemStatus!['status'] == 'alive'
                      ? TacticalColors.success.withValues(alpha: 0.15)
                      : TacticalColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _systemStatus!['status'] == 'alive'
                        ? TacticalColors.success.withValues(alpha: 0.5)
                        : TacticalColors.warning.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _systemStatus!['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                  style: TacticalText.label.copyWith(
                    color: _systemStatus!['status'] == 'alive'
                        ? TacticalColors.success
                        : TacticalColors.warning,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (_systemStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'UP ${_systemStatus!['uptime_human'] ?? ''}',
                  style: TacticalText.label.copyWith(
                    color: TacticalColors.textMuted,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.textSecondary),
            onPressed: _loadFullStatus,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null && _systemStatus == null
              ? _buildErrorState()
              : _buildDashboard(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: TacticalColors.primary),
          const SizedBox(height: 16),
          Text('Connecting to OneMind OS...', style: TacticalText.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_wifi_off, size: 48, color: TacticalColors.error),
          const SizedBox(height: 16),
          Text('SYSTEM OFFLINE', style: TacticalText.screenTitle.copyWith(color: TacticalColors.error)),
          const SizedBox(height: 8),
          Text(_error ?? '', style: TacticalText.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadFullStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('RETRY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final status = _systemStatus!;
    final subsystems = status['subsystems'] as Map<String, dynamic>? ?? {};
    final agents = status['agents'] as List<dynamic>? ?? [];
    final capabilities = status['capabilities'] as Map<String, dynamic>? ?? {};
    final config = status['config'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadFullStatus,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Stats Row ──
            _buildTopStats(status),
            const SizedBox(height: 20),

            // ── Subsystem Health Grid ──
            _buildSectionHeader('SUBSYSTEM HEALTH', Icons.monitor_heart_outlined),
            const SizedBox(height: 12),
            _buildSubsystemGrid(subsystems),
            const SizedBox(height: 24),

            // ── Agent Registry ──
            _buildSectionHeader('AGENT REGISTRY', Icons.precision_manufacturing_outlined),
            const SizedBox(height: 12),
            _buildAgentList(agents),
            const SizedBox(height: 24),

            // ── Capability Map ──
            _buildSectionHeader('CAPABILITY MAP', Icons.hub_outlined),
            const SizedBox(height: 12),
            _buildCapabilityMap(capabilities),
            const SizedBox(height: 24),

            // ── Configuration ──
            _buildSectionHeader('CONFIGURATION', Icons.settings_outlined),
            const SizedBox(height: 12),
            _buildConfigCard(config),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStats(Map<String, dynamic> status) {
    final bus = status['subsystems']?['nats_bus'] as Map<String, dynamic>? ?? {};
    final ws = status['subsystems']?['websocket'] as Map<String, dynamic>? ?? {};
    final heartbeat = status['subsystems']?['heartbeat'] as Map<String, dynamic>? ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'AGENTS',
            '${status['agent_count'] ?? 0}',
            Icons.precision_manufacturing_outlined,
            TacticalColors.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'BUS MSGS',
            '${(bus['published'] ?? 0) + (bus['received'] ?? 0)}',
            Icons.swap_horiz,
            TacticalColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'WS CLIENTS',
            '${ws['total_connections'] ?? 0}',
            Icons.cable,
            TacticalColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'HEARTBEAT',
            heartbeat['status']?.toString().toUpperCase() ?? 'STOPPED',
            Icons.favorite_outlined,
            heartbeat['status'] == 'running'
                ? TacticalColors.success
                : TacticalColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(TacticalRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TacticalText.statValue.copyWith(color: color, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TacticalText.label.copyWith(
              color: TacticalColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TacticalColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TacticalText.sectionHeader.copyWith(
            color: TacticalColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: TacticalColors.primary.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSubsystemGrid(Map<String, dynamic> subsystems) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSubsystemCard(
          'DATABASE',
          Icons.storage_outlined,
          subsystems['database']?['healthy'] == true ? 'ONLINE' : 'OFFLINE',
          subsystems['database']?['healthy'] == true,
        ),
        _buildSubsystemCard(
          'NATS BUS',
          Icons.hub_outlined,
          subsystems['nats_bus']?['connected'] == true ? 'CONNECTED' : 'DISCONNECTED',
          subsystems['nats_bus']?['connected'] == true,
        ),
        _buildSubsystemCard(
          'EVENT GATEWAY',
          Icons.route_outlined,
          (subsystems['event_gateway']?['status'] ?? 'unknown').toString().toUpperCase(),
          subsystems['event_gateway']?['status'] == 'active',
        ),
        _buildSubsystemCard(
          'WEBSOCKET',
          Icons.cable_outlined,
          '${subsystems['websocket']?['total_connections'] ?? 0} CLIENTS',
          true,
        ),
        _buildSubsystemCard(
          'HEARTBEAT',
          Icons.favorite_outlined,
          (subsystems['heartbeat']?['status'] ?? 'stopped').toString().toUpperCase(),
          subsystems['heartbeat']?['status'] == 'running',
        ),
      ],
    );
  }

  Widget _buildSubsystemCard(String name, IconData icon, String status, bool healthy) {
    final color = healthy ? TacticalColors.success : TacticalColors.warning;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(TacticalRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TacticalText.label.copyWith(
              color: TacticalColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TacticalText.label.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentList(List<dynamic> agents) {
    if (agents.isEmpty) {
      return _buildEmptyCard('No agents loaded');
    }

    return Column(
      children: agents.map((agent) {
        final a = agent as Map<String, dynamic>;
        final hasReasoning = a['reasoning'] == true;
        final hasMemory = a['memory'] == true;
        final tools = (a['tools'] as List<dynamic>?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            borderRadius: BorderRadius.circular(TacticalRadius.md),
            border: Border.all(color: TacticalColors.border),
          ),
          child: Row(
            children: [
              // Agent icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TacticalColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TacticalColors.cyan.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(
                    Icons.precision_manufacturing_outlined,
                    color: TacticalColors.cyan,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['name']?.toString() ?? 'Unknown',
                      style: TacticalText.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag(a['model']?.toString() ?? '', TacticalColors.info),
                        if (hasReasoning) ...[
                          const SizedBox(width: 6),
                          _buildTag('REASONING', TacticalColors.warning),
                        ],
                        if (hasMemory) ...[
                          const SizedBox(width: 6),
                          _buildTag('MEMORY', TacticalColors.success),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Tool count
              if (tools.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TacticalColors.primaryMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${tools.length} tools',
                    style: TacticalText.label.copyWith(
                      color: TacticalColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCapabilityMap(Map<String, dynamic> capabilities) {
    final capList = capabilities['capabilities'] as List<dynamic>? ?? [];

    if (capList.isEmpty) {
      return _buildEmptyCard('No capabilities registered');
    }

    // Group by domain
    final Map<String, List<dynamic>> byDomain = {};
    for (var cap in capList) {
      final domain = (cap as Map<String, dynamic>)['domain']?.toString() ?? 'unknown';
      byDomain.putIfAbsent(domain, () => []).add(cap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byDomain.entries.map((entry) {
        final domainColor = _domainColor(entry.key);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                entry.key.toUpperCase(),
                style: TacticalText.label.copyWith(
                  color: domainColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((cap) {
                final c = cap as Map<String, dynamic>;
                return Tooltip(
                  message: '${c['description']}\nHandler: ${c['handler']}\nApproval: ${c['approval']}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: domainColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: domainColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c['approval'] == 'confirm')
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.lock_outline, size: 12, color: TacticalColors.warning),
                          ),
                        Text(
                          c['name']?.toString() ?? '',
                          style: TacticalText.label.copyWith(color: domainColor, fontFamily: 'monospace', fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildConfigCard(Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(TacticalRadius.md),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        children: config.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  entry.key.toUpperCase(),
                  style: TacticalText.label.copyWith(
                    color: TacticalColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  entry.value.toString(),
                  style: TacticalText.label.copyWith(
                    color: TacticalColors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(TacticalRadius.md),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Center(
        child: Text(message, style: TacticalText.bodySmall),
      ),
    );
  }

  Color _domainColor(String domain) {
    switch (domain) {
      case 'digital':
        return TacticalColors.cyan;
      case 'physical':
        return TacticalColors.success;
      case 'hybrid':
        return TacticalColors.warning;
      case 'system':
        return TacticalColors.info;
      default:
        return TacticalColors.textMuted;
    }
  }
}
