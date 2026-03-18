// Databases provider for database connection management

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/services/api_client.dart';

/// Database type
enum DatabaseType {
  postgres('PostgreSQL', Icons.storage, Color(0xFF336791)),
  redis('Redis', Icons.memory, Color(0xFFDC382D)),
  timescale('TimescaleDB', Icons.schedule, Color(0xFFFDB515)),
  lancedb('LanceDB', Icons.search, Color(0xFF9333EA));

  final String label;
  final IconData icon;
  final Color color;

  const DatabaseType(this.label, this.icon, this.color);
}

/// Database status
enum DatabaseStatus {
  connected('Connected', Colors.green),
  connecting('Connecting', Colors.orange),
  disconnected('Disconnected', Colors.grey),
  error('Error', Colors.red);

  final String label;
  final Color color;

  const DatabaseStatus(this.label, this.color);
}

/// Database model
class Database {
  final String id;
  final String name;
  final DatabaseType type;
  final DatabaseStatus status;
  final String host;
  final int port;
  final String? database;
  final String? user;
  final int? connectionCount;
  final int? maxConnections;
  final DateTime? lastPingAt;
  final Duration? latency;
  final Map<String, dynamic>? stats;

  const Database({
    required this.id,
    required this.name,
    required this.type,
    this.status = DatabaseStatus.disconnected,
    required this.host,
    required this.port,
    this.database,
    this.user,
    this.connectionCount,
    this.maxConnections,
    this.lastPingAt,
    this.latency,
    this.stats,
  });

  String get connectionString {
    switch (type) {
      case DatabaseType.postgres:
      case DatabaseType.timescale:
        return 'postgresql://$user@$host:$port/${database ?? ''}';
      case DatabaseType.redis:
        return 'redis://$host:$port';
      case DatabaseType.lancedb:
        return 'lancedb://$host:$port';
    }
  }

  double get connectionUsage {
    if (connectionCount == null || maxConnections == null || maxConnections == 0) {
      return 0;
    }
    return connectionCount! / maxConnections!;
  }

  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DatabaseType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DatabaseType.postgres,
      ),
      status: DatabaseStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DatabaseStatus.disconnected,
      ),
      host: json['host'] as String,
      port: json['port'] as int,
      database: json['database'] as String?,
      user: json['user'] as String?,
      connectionCount: json['connection_count'] as int?,
      maxConnections: json['max_connections'] as int?,
      lastPingAt: json['last_ping_at'] != null
          ? DateTime.parse(json['last_ping_at'] as String)
          : null,
      latency: json['latency_ms'] != null
          ? Duration(milliseconds: json['latency_ms'] as int)
          : null,
      stats: json['stats'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'host': host,
      'port': port,
      'database': database,
      'user': user,
      'connection_count': connectionCount,
      'max_connections': maxConnections,
      'last_ping_at': lastPingAt?.toIso8601String(),
      'latency_ms': latency?.inMilliseconds,
      'stats': stats,
    };
  }
}

/// Databases state
class DatabasesState {
  final List<Database> databases;
  final bool isLoading;
  final String? error;
  final Database? selectedDatabase;

  const DatabasesState({
    this.databases = const [],
    this.isLoading = false,
    this.error,
    this.selectedDatabase,
  });

  DatabasesState copyWith({
    List<Database>? databases,
    bool? isLoading,
    String? error,
    Database? selectedDatabase,
  }) {
    return DatabasesState(
      databases: databases ?? this.databases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDatabase: selectedDatabase ?? this.selectedDatabase,
    );
  }

  List<Database> get connectedDatabases =>
      databases.where((d) => d.status == DatabaseStatus.connected).toList();

  bool get allHealthy => databases.every(
      (d) => d.status == DatabaseStatus.connected || d.status == DatabaseStatus.disconnected);
}

/// Databases notifier with backend integration
class DatabasesNotifier extends StateNotifier<DatabasesState> {
  final ApiClient _apiClient;

  DatabasesNotifier(this._apiClient) : super(const DatabasesState()) {
    loadDatabases();
  }

  Future<void> loadDatabases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get('/databases');
      final List<dynamic> data = response['databases'] ?? [];
      final databases = data.map((d) => Database.fromJson(d)).toList();

      state = state.copyWith(
        databases: databases,
        isLoading: false,
      );
    } catch (e) {
      // No mock fallback - show error state
      state = state.copyWith(
        databases: [],
        isLoading: false,
        error: 'Failed to load databases: $e',
      );
    }
  }

  void selectDatabase(Database? database) {
    state = state.copyWith(selectedDatabase: database);
  }

  Future<void> testConnection(String id) async {
    try {
      await _apiClient.post('/databases/$id/test', {});
      await loadDatabases();
    } catch (e) {
      state = state.copyWith(error: 'Connection test failed: $e');
    }
  }

  Future<void> refreshStats(String id) async {
    await loadDatabases();
  }
}

/// Provider for databases state
final databasesProvider =
    StateNotifierProvider<DatabasesNotifier, DatabasesState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DatabasesNotifier(apiClient);
});

/// Provider for connected databases
final connectedDatabasesProvider = Provider<List<Database>>((ref) {
  return ref.watch(databasesProvider).connectedDatabases;
});

/// Provider for database health
final databasesHealthyProvider = Provider<bool>((ref) {
  return ref.watch(databasesProvider).allHealthy;
});
