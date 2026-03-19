// STATUS: ✅ Complete - Rich database monitoring with connection status, metrics, and tables
// BACKEND: GET /health, GET /databases/status (future endpoint)
// Updated: OMOS-241 - Added query editor for database exploration
// DESIGN: Tactical design system

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../platform/providers/app_providers.dart';
import '../../../shared/models/health.dart';
import '../../../platform/config/environment.dart';
import '../widgets/query_editor.dart';

/// Extract host from API URL
String _getInfrastructureHost() {
  final apiUrl = Environment.apiUrl;
  try {
    final uri = Uri.parse(apiUrl);
    return uri.host;
  } catch (_) {
    return 'localhost'; // Fallback
  }
}

class DatabasesScreen extends ConsumerStatefulWidget {
  const DatabasesScreen({super.key});

  @override
  ConsumerState<DatabasesScreen> createState() => _DatabasesScreenState();
}

class _DatabasesScreenState extends ConsumerState<DatabasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Database configurations
  // Host is derived from Environment.apiUrl, ports are standard service ports
  // Metrics will be loaded from backend /databases/status when available
  late List<_DatabaseInfo> _databases;

  List<_DatabaseInfo> _initDatabases() {
    final host = _getInfrastructureHost();
    return [
      _DatabaseInfo(
        name: 'PostgreSQL',
        type: 'postgres',
        host: host,
        port: 5432,
        status: _ConnectionStatus.checking,
        version: null,
        uptime: null,
        connections: null,
        storage: null,
        tables: [],
        metrics: null,
      ),
      _DatabaseInfo(
        name: 'Redis',
        type: 'redis',
        host: host,
        port: 6379,
        status: _ConnectionStatus.checking,
        version: null,
        uptime: null,
        connections: null,
        storage: null,
        tables: [],
        metrics: null,
      ),
      _DatabaseInfo(
        name: 'TimescaleDB',
        type: 'timescale',
        host: host,
        port: 5433,
        status: _ConnectionStatus.checking,
        version: null,
        uptime: null,
        connections: null,
        storage: null,
        tables: [],
        metrics: null,
      ),
      _DatabaseInfo(
        name: 'NATS JetStream',
        type: 'nats',
        host: host,
        port: 4222,
        status: _ConnectionStatus.checking,
        version: null,
        uptime: null,
        connections: null,
        storage: null,
        tables: [],
        metrics: null,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _databases = _initDatabases();
    _tabController = TabController(length: _databases.length, vsync: this);
    _startAutoRefresh();
    // Load initial status
    Future.microtask(() => _refreshData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _refreshData());
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final api = ref.read(agnoClientProvider);
      // Try to get database status from backend
      final status = await api.getDatabasesStatus();
      if (status != null && status['databases'] is List) {
        final updatedDatabases = <_DatabaseInfo>[];
        for (final db in _databases) {
          final dbStatus = (status['databases'] as List).firstWhere(
            (d) => d['type'] == db.type,
            orElse: () => null,
          );
          if (dbStatus != null) {
            updatedDatabases.add(db.copyWith(
              status: dbStatus['connected'] == true
                  ? _ConnectionStatus.connected
                  : _ConnectionStatus.disconnected,
              version: dbStatus['version'],
              uptime: dbStatus['uptime_seconds'] != null
                  ? Duration(seconds: dbStatus['uptime_seconds'] as int)
                  : null,
              connections: dbStatus['connections'] != null
                  ? _ConnectionStats(
                      active: dbStatus['connections']['active'] ?? 0,
                      idle: dbStatus['connections']['idle'] ?? 0,
                      max: dbStatus['connections']['max'] ?? 100,
                    )
                  : null,
              storage: dbStatus['storage'] != null
                  ? _StorageStats(
                      used: (dbStatus['storage']['used'] ?? 0).toDouble(),
                      total: (dbStatus['storage']['total'] ?? 1).toDouble(),
                      unit: dbStatus['storage']['unit'] ?? 'GB',
                    )
                  : null,
              tables: dbStatus['tables'] != null
                  ? (dbStatus['tables'] as List)
                      .map((t) => _TableInfo(
                            t['name'] ?? '',
                            t['rows'] ?? 0,
                            (t['size_kb'] ?? 0).toDouble(),
                            t['last_updated'] != null
                                ? DateTime.parse(t['last_updated'])
                                : DateTime.now(),
                          ))
                      .toList()
                  : [],
              metrics: dbStatus['metrics'] != null
                  ? _PerformanceMetrics(
                      queriesPerSec:
                          (dbStatus['metrics']['queries_per_sec'] ?? 0)
                              .toDouble(),
                      avgLatency:
                          (dbStatus['metrics']['avg_latency_ms'] ?? 0)
                              .toDouble(),
                      cacheHitRatio:
                          dbStatus['metrics']['cache_hit_ratio']?.toDouble(),
                    )
                  : null,
            ));
          } else {
            // No status info for this database
            updatedDatabases
                .add(db.copyWith(status: _ConnectionStatus.disconnected));
          }
        }
        setState(() => _databases = updatedDatabases);
      } else {
        // Fallback: Use health check to determine basic connection status
        await _updateFromHealthCheck();
      }
    } catch (e) {
      // On error, try basic health check
      await _updateFromHealthCheck();
    }

    setState(() => _isRefreshing = false);
  }

  Future<void> _updateFromHealthCheck() async {
    // Map service names from health check to database types
    final serviceToType = {
      'postgres': 'postgres',
      'redis': 'redis',
      'timescale': 'timescale',
      'nats': 'nats',
    };

    final health = ref.read(healthCheckProvider);
    health.whenData((services) {
      final updatedDatabases = _databases.map((db) {
        final service = services.firstWhere(
          (s) => serviceToType[s.name] == db.type || s.name == db.type,
          orElse: () =>
              ServiceHealth(name: db.type, status: HealthStatus.unhealthy),
        );
        return db.copyWith(
          status: service.status == HealthStatus.healthy
              ? _ConnectionStatus.connected
              : _ConnectionStatus.disconnected,
        );
      }).toList();
      setState(() => _databases = updatedDatabases);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final health = ref.watch(healthCheckProvider);
    final isBackendConnected = health.maybeWhen(
      data: (services) =>
          services.every((s) => s.status == HealthStatus.healthy),
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TacticalColors.textMuted),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('DATABASES', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TacticalColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: TacticalColors.primary,
          indicatorWeight: 3,
          labelColor: TacticalColors.primary,
          unselectedLabelColor: TacticalColors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          tabs: _databases
              .map((db) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: db.status == _ConnectionStatus.connected
                                ? TacticalColors.operational
                                : db.status == _ConnectionStatus.checking
                                    ? TacticalColors.inProgress
                                    : TacticalColors.critical,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(db.name.toUpperCase()),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          _buildGlobalStatusBar(isBackendConnected),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _databases
                  .map((db) =>
                      _DatabaseDetailView(database: db, isMobile: isMobile))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStatusBar(bool isConnected) {
    final connectedCount =
        _databases.where((db) => db.status == _ConnectionStatus.connected).length;
    final checkingCount =
        _databases.where((db) => db.status == _ConnectionStatus.checking).length;
    final totalQueries = _databases.fold<double>(
        0, (sum, db) => sum + (db.metrics?.queriesPerSec ?? 0));
    final hasMetrics = _databases.any((db) => db.metrics != null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(
          bottom: BorderSide(
            color: TacticalColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatusChip(
              icon: Icons.cloud,
              label: 'BACKEND',
              value: isConnected ? 'ONLINE' : 'OFFLINE',
              color:
                  isConnected ? TacticalColors.operational : TacticalColors.critical,
            ),
            const SizedBox(width: 16),
            _StatusChip(
              icon: Icons.storage,
              label: 'DATABASES',
              value: checkingCount > 0
                  ? 'CHECKING...'
                  : '$connectedCount/${_databases.length}',
              color: checkingCount > 0
                  ? TacticalColors.inProgress
                  : connectedCount == _databases.length
                      ? TacticalColors.operational
                      : TacticalColors.critical,
            ),
            const SizedBox(width: 16),
            _StatusChip(
              icon: Icons.speed,
              label: 'QUERIES/SEC',
              value: hasMetrics ? totalQueries.toStringAsFixed(0) : '--',
              color: TacticalColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatabaseDetailView extends StatelessWidget {
  final _DatabaseInfo database;
  final bool isMobile;

  const _DatabaseDetailView({required this.database, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildConnectionCard(),
        const SizedBox(height: 16),
        _buildMetricsGrid(),
        const SizedBox(height: 16),
        if (isMobile) ...[
          _buildStorageCard(),
          const SizedBox(height: 16),
          _buildConnectionsCard()
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStorageCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildConnectionsCard()),
            ],
          ),
        const SizedBox(height: 16),
        _buildTablesCard(),
        // Query Editor (OMOS-241)
        if (database.status == _ConnectionStatus.connected) ...[
          const SizedBox(height: 16),
          QueryEditor(
            databaseType: database.type,
            databaseName: database.name,
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionCard() {
    final isConnected = database.status == _ConnectionStatus.connected;
    final isChecking = database.status == _ConnectionStatus.checking;
    final statusColor = isConnected
        ? TacticalColors.operational
        : isChecking
            ? TacticalColors.inProgress
            : TacticalColors.critical;
    final statusText =
        isConnected ? 'CONNECTED' : isChecking ? 'CHECKING...' : 'OFFLINE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getTypeColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      database.name,
                      style: const TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${database.host}:${database.port}',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  database.version != null
                      ? 'v${database.version}${database.uptime != null ? ' • Uptime: ${_formatUptime(database.uptime!)}' : ''}'
                      : 'Waiting for status...',
                  style: const TextStyle(
                    color: TacticalColors.textDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final m = database.metrics;
    if (m == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PERFORMANCE'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'QUERIES/SEC',
                  value: m.queriesPerSec.toStringAsFixed(1),
                  icon: Icons.speed,
                  color: TacticalColors.primary,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: 'AVG LATENCY',
                  value: '${m.avgLatency.toStringAsFixed(1)}ms',
                  icon: Icons.timer,
                  color: m.avgLatency < 5
                      ? TacticalColors.operational
                      : TacticalColors.inProgress,
                ),
              ),
              if (m.cacheHitRatio != null)
                Expanded(
                  child: _MetricTile(
                    label: 'CACHE HIT',
                    value: '${m.cacheHitRatio!.toStringAsFixed(1)}%',
                    icon: Icons.memory,
                    color: m.cacheHitRatio! > 95
                        ? TacticalColors.operational
                        : TacticalColors.inProgress,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    final s = database.storage;
    if (s == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: TacticalDecoration.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('STORAGE'),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No storage data available',
                style: TextStyle(
                  color: TacticalColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final pct = (s.used / s.total * 100);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('STORAGE'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${s.used.toStringAsFixed(1)} ${s.unit}',
                style: const TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                'of ${s.total.toStringAsFixed(0)} ${s.unit}',
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.used / s.total,
              backgroundColor: TacticalColors.border,
              valueColor: AlwaysStoppedAnimation(
                pct > 90
                    ? TacticalColors.critical
                    : pct > 70
                        ? TacticalColors.inProgress
                        : TacticalColors.operational,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${pct.toStringAsFixed(1)}% used',
            style: const TextStyle(
              color: TacticalColors.textDim,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsCard() {
    final c = database.connections;
    if (c == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: TacticalDecoration.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('CONNECTIONS'),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No connection data available',
                style: TextStyle(
                  color: TacticalColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CONNECTIONS'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ConnStat(
                  label: 'ACTIVE',
                  value: c.active,
                  color: TacticalColors.operational,
                ),
              ),
              Expanded(
                child: _ConnStat(
                  label: 'IDLE',
                  value: c.idle,
                  color: TacticalColors.inProgress,
                ),
              ),
              Expanded(
                child: _ConnStat(
                  label: 'MAX',
                  value: c.max,
                  color: TacticalColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (c.active + c.idle) / c.max,
              backgroundColor: TacticalColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(TacticalColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesCard() {
    final label = database.type == 'redis'
        ? 'KEYS'
        : database.type == 'nats'
            ? 'STREAMS'
            : 'TABLES';
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSectionHeader(label),
                const Spacer(),
                Text(
                  '${database.tables.length} total',
                  style: const TextStyle(
                    color: TacticalColors.textDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: TacticalColors.border, height: 1),
          if (database.tables.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No $label data available',
                  style: TextStyle(
                    color: TacticalColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: TacticalColors.surface,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'NAME',
                      style: TextStyle(
                        color: TacticalColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'ROWS',
                      style: TextStyle(
                        color: TacticalColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'SIZE',
                      style: TextStyle(
                        color: TacticalColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'UPDATED',
                      style: TextStyle(
                        color: TacticalColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...database.tables.map((t) => _TableRow(table: t)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: TacticalColors.primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: TacticalColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon() => switch (database.type) {
        'postgres' => Icons.storage,
        'redis' => Icons.speed,
        'timescale' => Icons.show_chart,
        'nats' => Icons.swap_horiz,
        _ => Icons.storage
      };

  Color _getTypeColor() => switch (database.type) {
        'postgres' => const Color(0xFF336791),
        'redis' => const Color(0xFFDC382D),
        'timescale' => const Color(0xFFFDB515),
        'nats' => const Color(0xFF27AAE1),
        _ => TacticalColors.primary
      };

  String _formatUptime(Duration u) => u.inDays > 0
      ? '${u.inDays}d ${u.inHours % 24}h'
      : '${u.inHours}h ${u.inMinutes % 60}m';
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: TacticalColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      );
}

class _ConnStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ConnStat({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      );
}

class _TableRow extends StatelessWidget {
  final _TableInfo table;
  const _TableRow({required this.table});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: TacticalColors.border.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                table.name,
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                _fmtNum(table.rows),
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: Text(
                _fmtSize(table.sizeKb),
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: Text(
                _fmtTime(table.lastUpdated),
                style: const TextStyle(
                  color: TacticalColors.textDim,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
  String _fmtNum(int n) => n >= 1000000
      ? '${(n / 1000000).toStringAsFixed(1)}M'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(1)}K'
          : '$n';
  String _fmtSize(double kb) => kb >= 1024
      ? '${(kb / 1024).toStringAsFixed(1)} MB'
      : '${kb.toStringAsFixed(1)} KB';
  String _fmtTime(DateTime t) {
    final d = DateTime.now().difference(t);
    return d.inSeconds < 60
        ? '${d.inSeconds}s ago'
        : d.inMinutes < 60
            ? '${d.inMinutes}m ago'
            : d.inHours < 24
                ? '${d.inHours}h ago'
                : '${d.inDays}d ago';
  }
}

enum _ConnectionStatus { connected, disconnected, checking }

class _DatabaseInfo {
  final String name, type, host;
  final String? version;
  final int port;
  final _ConnectionStatus status;
  final Duration? uptime;
  final _ConnectionStats? connections;
  final _StorageStats? storage;
  final List<_TableInfo> tables;
  final _PerformanceMetrics? metrics;
  const _DatabaseInfo({
    required this.name,
    required this.type,
    required this.host,
    required this.port,
    required this.status,
    this.version,
    this.uptime,
    this.connections,
    this.storage,
    required this.tables,
    this.metrics,
  });

  _DatabaseInfo copyWith({
    String? name,
    String? type,
    String? host,
    String? version,
    int? port,
    _ConnectionStatus? status,
    Duration? uptime,
    _ConnectionStats? connections,
    _StorageStats? storage,
    List<_TableInfo>? tables,
    _PerformanceMetrics? metrics,
  }) =>
      _DatabaseInfo(
        name: name ?? this.name,
        type: type ?? this.type,
        host: host ?? this.host,
        version: version ?? this.version,
        port: port ?? this.port,
        status: status ?? this.status,
        uptime: uptime ?? this.uptime,
        connections: connections ?? this.connections,
        storage: storage ?? this.storage,
        tables: tables ?? this.tables,
        metrics: metrics ?? this.metrics,
      );
}

class _ConnectionStats {
  final int active, idle, max;
  const _ConnectionStats({
    required this.active,
    required this.idle,
    required this.max,
  });
}

class _StorageStats {
  final double used, total;
  final String unit;
  const _StorageStats({
    required this.used,
    required this.total,
    required this.unit,
  });
}

class _TableInfo {
  final String name;
  final int rows;
  final double sizeKb;
  final DateTime lastUpdated;
  const _TableInfo(this.name, this.rows, this.sizeKb, this.lastUpdated);
}

class _PerformanceMetrics {
  final double queriesPerSec, avgLatency;
  final double? cacheHitRatio;
  const _PerformanceMetrics({
    required this.queriesPerSec,
    required this.avgLatency,
    this.cacheHitRatio,
  });
}
