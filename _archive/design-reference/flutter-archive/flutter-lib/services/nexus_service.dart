import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/environment.dart';

/// Nexus API Service — Frontend client for the meta-orchestration layer
///
/// Connects to:
///   POST /nexus/command      — Send commands (voice/chat)
///   POST /nexus/fan-out      — Multi-target dispatch
///   POST /nexus/assign       — Assign tasks
///   GET  /nexus/overview     — System overview
///   GET  /nexus/entities     — Entity listing
///   GET  /nexus/awareness    — Agent NATS awareness status
///   GET  /nexus/events       — Event log
///   GET  /nexus/history      — Dispatch history
///   GET  /nexus/legacy/awareness — Legacy's full awareness state
///   WS   /nexus/stream       — Real-time event stream

// =============================================================================
// DATA MODELS
// =============================================================================

class NexusEntity {
  final String id;
  final String name;
  final String entityType;
  final String framework;
  final String status;
  final String? description;
  final List<String> capabilities;
  final List<String> tools;
  final List<String> members;
  final String? natsSubject;
  final Map<String, dynamic> metadata;
  final List<String> inputModalities;
  final List<String> outputModalities;

  NexusEntity({
    required this.id,
    required this.name,
    required this.entityType,
    required this.framework,
    required this.status,
    this.description,
    this.capabilities = const [],
    this.tools = const [],
    this.members = const [],
    this.natsSubject,
    this.metadata = const {},
    this.inputModalities = const ['text'],
    this.outputModalities = const ['text'],
  });

  factory NexusEntity.fromJson(Map<String, dynamic> json) {
    return NexusEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      entityType: json['entity_type'] ?? 'agent',
      framework: json['framework'] ?? 'agno',
      status: json['status'] ?? 'idle',
      description: json['description'],
      capabilities: List<String>.from(json['capabilities'] ?? []),
      tools: List<String>.from(json['tools'] ?? []),
      members: List<String>.from(json['members'] ?? []),
      natsSubject: json['nats_subject'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      inputModalities: List<String>.from(json['input_modalities'] ?? ['text']),
      outputModalities: List<String>.from(json['output_modalities'] ?? ['text']),
    );
  }

  bool get isAgent => entityType == 'agent';
  bool get isTeam => entityType == 'team';
  bool get isRobot => entityType == 'robot';
  bool get isSensor => entityType == 'sensor';
  bool get isService => entityType == 'service';
  bool get isIdle => status == 'idle';
  bool get isBusy => status == 'busy';
  bool get isOffline => status == 'offline';
  bool get supportsVoice => inputModalities.contains('audio');
  bool get supportsVision => inputModalities.contains('image');
  bool get supportsSensor => inputModalities.contains('sensor');
}

class DispatchResult {
  final String commandId;
  final String target;
  final String status;
  final String? result;
  final String? error;
  final double elapsedMs;
  final String timestamp;

  DispatchResult({
    required this.commandId,
    required this.target,
    required this.status,
    this.result,
    this.error,
    required this.elapsedMs,
    required this.timestamp,
  });

  factory DispatchResult.fromJson(Map<String, dynamic> json) {
    return DispatchResult(
      commandId: json['command_id'] ?? '',
      target: json['target'] ?? '',
      status: json['status'] ?? 'unknown',
      result: json['result']?.toString(),
      error: json['error'],
      elapsedMs: (json['elapsed_ms'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed' || status == 'timeout';
}

class NexusCommandResult {
  final String mode;
  final String? plan;
  final int dispatched;
  final List<DispatchResult> results;
  final String? source;

  NexusCommandResult({
    required this.mode,
    this.plan,
    required this.dispatched,
    required this.results,
    this.source,
  });

  factory NexusCommandResult.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List? ?? [];
    return NexusCommandResult(
      mode: json['mode'] ?? 'unknown',
      plan: json['plan'],
      dispatched: json['dispatched'] ?? rawResults.length,
      results: rawResults.map((r) {
        if (r is Map<String, dynamic>) {
          // Could be DispatchResult or direct response
          if (r.containsKey('command_id')) {
            return DispatchResult.fromJson(r);
          }
          return DispatchResult(
            commandId: '',
            target: r['entity_id'] ?? 'direct',
            status: r['status'] ?? 'completed',
            result: r['result']?.toString(),
            error: r['error'],
            elapsedMs: 0,
            timestamp: r['timestamp'] ?? '',
          );
        }
        return DispatchResult(
          commandId: '',
          target: 'direct',
          status: 'completed',
          result: r.toString(),
          error: null,
          elapsedMs: 0,
          timestamp: '',
        );
      }).toList(),
      source: json['source'],
    );
  }
}

class NexusSystemEvent {
  final String subject;
  final dynamic data;
  final String timestamp;
  final String? framework;
  final String? entityId;
  final String? eventType;

  NexusSystemEvent({
    required this.subject,
    required this.data,
    required this.timestamp,
    this.framework,
    this.entityId,
    this.eventType,
  });

  factory NexusSystemEvent.fromJson(Map<String, dynamic> json) {
    return NexusSystemEvent(
      subject: json['subject'] ?? '',
      data: json['data'],
      timestamp: json['timestamp'] ?? '',
      framework: json['framework'],
      entityId: json['entity_id'],
      eventType: json['event_type'],
    );
  }
}

class NexusOverview {
  final bool nexusStarted;
  final List<String> frameworks;
  final int totalEntities;
  final Map<String, int> byFramework;
  final Map<String, int> byType;
  final List<NexusEntity> entities;
  final int totalEvents;
  final int activeDispatches;

  NexusOverview({
    required this.nexusStarted,
    required this.frameworks,
    required this.totalEntities,
    required this.byFramework,
    required this.byType,
    required this.entities,
    required this.totalEvents,
    required this.activeDispatches,
  });

  factory NexusOverview.fromJson(Map<String, dynamic> json) {
    final nexus = json['nexus'] as Map<String, dynamic>? ?? {};
    final system = json['system'] as Map<String, dynamic>? ?? {};
    final legacy = json['legacy'] as Map<String, dynamic>? ?? {};
    final dispatcher = json['dispatcher'] as Map<String, dynamic>? ?? {};
    final eventLog = legacy['event_log'] as Map<String, dynamic>? ?? {};

    final rawEntities = system['entities'] as List? ?? [];

    return NexusOverview(
      nexusStarted: nexus['started'] ?? false,
      frameworks: List<String>.from(nexus['frameworks'] ?? []),
      totalEntities: system['total_entities'] ?? 0,
      byFramework: Map<String, int>.from(system['by_framework'] ?? {}),
      byType: Map<String, int>.from(system['by_type'] ?? {}),
      entities: rawEntities.map((e) => NexusEntity.fromJson(e as Map<String, dynamic>)).toList(),
      totalEvents: eventLog['total_events'] ?? 0,
      activeDispatches: dispatcher['active_commands'] ?? 0,
    );
  }
}

// =============================================================================
// NEXUS SERVICE
// =============================================================================

class NexusService {
  final String baseUrl;

  NexusService({String? baseUrl}) : baseUrl = baseUrl ?? Environment.apiBaseUrl;

  static const Duration _timeout = Duration(seconds: 60);

  // ─── COMMAND ───

  /// Send a unified command to Legacy (supports multimodal)
  Future<NexusCommandResult> command({
    required String message,
    String mode = 'auto',
    List<String>? targets,
    String priority = 'normal',
    String source = 'chat',
    String modality = 'text',
    List<Map<String, dynamic>>? images,
    List<Map<String, dynamic>>? audio,
    List<Map<String, dynamic>>? files,
    Map<String, dynamic>? data,
    String? sessionId,
    String? correlationId,
  }) async {
    final url = Uri.parse('$baseUrl/nexus/command');
    final body = <String, dynamic>{
      'message': message,
      'mode': mode,
      'priority': priority,
      'source': source,
      'modality': modality,
    };
    if (targets != null) body['targets'] = targets;
    if (images != null) body['images'] = images;
    if (audio != null) body['audio'] = audio;
    if (files != null) body['files'] = files;
    if (data != null) body['data'] = data;
    if (sessionId != null) body['session_id'] = sessionId;
    if (correlationId != null) body['correlation_id'] = correlationId;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return NexusCommandResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Nexus command failed: ${response.statusCode} ${response.body}');
  }

  // ─── FAN-OUT ───

  /// Multi-target dispatch
  Future<List<DispatchResult>> fanOut({
    required List<Map<String, String>> commands,
    String source = 'ui',
  }) async {
    final url = Uri.parse('$baseUrl/nexus/fan-out');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'commands': commands,
        'source': source,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];
      return results.map((r) => DispatchResult.fromJson(r)).toList();
    }
    throw Exception('Fan-out failed: ${response.statusCode}');
  }

  // ─── ASSIGN TASK ───

  /// Assign a task to an entity
  Future<Map<String, dynamic>> assignTask({
    required String title,
    required String assignee,
    String priority = 'normal',
    Map<String, dynamic>? context,
  }) async {
    final url = Uri.parse('$baseUrl/nexus/assign');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'assignee': assignee,
        'priority': priority,
        'context': context,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Assign task failed: ${response.statusCode}');
  }

  // ─── OVERVIEW ───

  /// Get full system overview
  Future<NexusOverview> getOverview() async {
    final url = Uri.parse('$baseUrl/nexus/overview');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return NexusOverview.fromJson(jsonDecode(response.body));
    }
    throw Exception('Overview failed: ${response.statusCode}');
  }

  // ─── ENTITIES ───

  /// List all entities with optional filters
  Future<List<NexusEntity>> getEntities({
    String? entityType,
    String? framework,
    String? capability,
  }) async {
    final params = <String, String>{};
    if (entityType != null) params['entity_type'] = entityType;
    if (framework != null) params['framework'] = framework;
    if (capability != null) params['capability'] = capability;

    final url = Uri.parse('$baseUrl/nexus/entities').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final entities = data['entities'] as List? ?? [];
      return entities.map((e) => NexusEntity.fromJson(e)).toList();
    }
    throw Exception('Entities failed: ${response.statusCode}');
  }

  // ─── AWARENESS ───

  /// Get agent NATS awareness status
  Future<Map<String, dynamic>> getAwareness() async {
    final url = Uri.parse('$baseUrl/nexus/awareness');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Awareness failed: ${response.statusCode}');
  }

  // ─── EVENTS ───

  /// Get recent system events
  Future<List<NexusSystemEvent>> getEvents({int limit = 50, String? subject}) async {
    final params = <String, String>{'limit': limit.toString()};
    if (subject != null) params['subject'] = subject;

    final url = Uri.parse('$baseUrl/nexus/events').replace(queryParameters: params);
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final events = data['events'] as List? ?? [];
      return events.map((e) => NexusSystemEvent.fromJson(e)).toList();
    }
    throw Exception('Events failed: ${response.statusCode}');
  }

  /// Search events
  Future<List<NexusSystemEvent>> searchEvents(String query, {int limit = 50}) async {
    final url = Uri.parse('$baseUrl/nexus/events/search').replace(
      queryParameters: {'q': query, 'limit': limit.toString()},
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];
      return results.map((e) => NexusSystemEvent.fromJson(e)).toList();
    }
    throw Exception('Event search failed: ${response.statusCode}');
  }

  // ─── HISTORY ───

  /// Get dispatch history
  Future<Map<String, dynamic>> getHistory({int limit = 50}) async {
    final url = Uri.parse('$baseUrl/nexus/history').replace(
      queryParameters: {'limit': limit.toString()},
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('History failed: ${response.statusCode}');
  }

  // ─── LEGACY AWARENESS ───

  /// Get Legacy's complete awareness state
  Future<Map<String, dynamic>> getLegacyAwareness() async {
    final url = Uri.parse('$baseUrl/nexus/legacy/awareness');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Legacy awareness failed: ${response.statusCode}');
  }

  // ─── MODALITIES ───

  /// Get system-wide modality inventory
  Future<Map<String, dynamic>> getModalities() async {
    final url = Uri.parse('$baseUrl/nexus/modalities');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Modalities failed: ${response.statusCode}');
  }

  // ─── REALTIME STREAMS ───

  /// Connect to the real-time Nexus event stream via raw WebSocket.
  /// This connects to /nexus/stream which is a dedicated FastAPI WebSocket endpoint.
  ///
  /// For richer realtime events (NATS relay, comms, approvals), use the
  /// SocketService class which connects via Socket.IO to /system, /chat,
  /// /approvals, /events namespaces.
  WebSocketChannel connectStream() {
    final wsUrl = baseUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    return WebSocketChannel.connect(Uri.parse('$wsUrl/nexus/stream'));
  }
}
