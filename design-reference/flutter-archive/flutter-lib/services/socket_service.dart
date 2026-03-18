import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/environment.dart';

/// OneMind Socket.IO Service — Singleton
///
/// Manages a single multiplexed Socket.IO connection to the backend
/// with namespace-specific event handling.
///
/// Architecture:
///   /system     → heartbeat, pulse, agent status, bus stats
///   /chat       → agent conversations, streaming responses
///   /approvals  → HITL requests, approval/rejection with ack
///   /events     → NATS event relay to frontend
///   /oneintel   → personal intelligence context updates
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Namespace sockets
  io.Socket? _systemSocket;
  io.Socket? _chatSocket;
  io.Socket? _approvalsSocket;
  io.Socket? _eventsSocket;

  // Connection state
  bool _initialized = false;
  final _connectionState = ValueNotifier<SocketConnectionState>(
    SocketConnectionState.disconnected,
  );

  // Event stream controllers
  final _systemEvents = StreamController<Map<String, dynamic>>.broadcast();
  final _chatEvents = StreamController<ChatSocketEvent>.broadcast();
  final _approvalEvents = StreamController<Map<String, dynamic>>.broadcast();
  final _natsEvents = StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get systemEvents => _systemEvents.stream;
  Stream<ChatSocketEvent> get chatEvents => _chatEvents.stream;
  Stream<Map<String, dynamic>> get approvalEvents => _approvalEvents.stream;
  Stream<Map<String, dynamic>> get natsEvents => _natsEvents.stream;
  ValueNotifier<SocketConnectionState> get connectionState => _connectionState;

  /// Initialize all Socket.IO namespace connections.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    final baseUrl = Environment.apiBaseUrl;

    // /system namespace
    _systemSocket = _createSocket(baseUrl, '/system');
    _setupSystemHandlers();

    // /chat namespace
    _chatSocket = _createSocket(baseUrl, '/chat');
    _setupChatHandlers();

    // /approvals namespace
    _approvalsSocket = _createSocket(baseUrl, '/approvals');
    _setupApprovalsHandlers();

    // /events namespace
    _eventsSocket = _createSocket(baseUrl, '/events');
    _setupEventsHandlers();

    debugPrint('[SocketService] Initialized — connecting to $baseUrl');
  }

  /// Create a Socket.IO connection for a specific namespace.
  io.Socket _createSocket(String baseUrl, String namespace) {
    return io.io(
      '$baseUrl$namespace',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .build(),
    );
  }

  // ===========================================================================
  // /system namespace
  // ===========================================================================

  void _setupSystemHandlers() {
    final socket = _systemSocket!;

    socket.onConnect((_) {
      debugPrint('[Socket/system] Connected');
      _connectionState.value = SocketConnectionState.connected;
    });

    socket.onDisconnect((_) {
      debugPrint('[Socket/system] Disconnected');
      _connectionState.value = SocketConnectionState.disconnected;
    });

    socket.on('reconnecting', (_) {
      _connectionState.value = SocketConnectionState.reconnecting;
    });

    socket.onError((err) {
      debugPrint('[Socket/system] Error: $err');
      _connectionState.value = SocketConnectionState.error;
    });

    socket.on('connected', (data) {
      debugPrint('[Socket/system] Server confirmed: $data');
    });

    socket.on('pulse', (data) {
      if (data is Map) {
        _systemEvents.add(Map<String, dynamic>.from(data));
      }
    });

    socket.on('agent_status', (data) {
      if (data is Map) {
        _systemEvents.add({'type': 'agent_status', ...Map<String, dynamic>.from(data)});
      }
    });
  }

  /// Request system pulse data.
  Future<Map<String, dynamic>?> getPulse() async {
    final completer = Completer<Map<String, dynamic>?>();
    _systemSocket?.emitWithAck('get_pulse', {}, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Subscribe to a specific agent's events.
  void subscribeToAgent(String agentId) {
    _systemSocket?.emit('subscribe_agent', {'agent_id': agentId});
  }

  // ===========================================================================
  // /chat namespace
  // ===========================================================================

  void _setupChatHandlers() {
    final socket = _chatSocket!;

    socket.onConnect((_) {
      debugPrint('[Socket/chat] Connected');
    });

    socket.onDisconnect((_) {
      debugPrint('[Socket/chat] Disconnected');
    });

    // Streaming tokens from agent
    socket.on('stream_token', (data) {
      if (data is Map) {
        _chatEvents.add(ChatSocketEvent(
          type: ChatEventType.streamToken,
          data: Map<String, dynamic>.from(data),
        ));
      }
    });

    // Agent started processing
    socket.on('run_started', (data) {
      if (data is Map) {
        _chatEvents.add(ChatSocketEvent(
          type: ChatEventType.runStarted,
          data: Map<String, dynamic>.from(data),
        ));
      }
    });

    // Agent completed
    socket.on('run_complete', (data) {
      if (data is Map) {
        _chatEvents.add(ChatSocketEvent(
          type: ChatEventType.runComplete,
          data: Map<String, dynamic>.from(data),
        ));
      }
    });

    // Tool call events
    socket.on('tool_call', (data) {
      if (data is Map) {
        _chatEvents.add(ChatSocketEvent(
          type: ChatEventType.toolCall,
          data: Map<String, dynamic>.from(data),
        ));
      }
    });

    // Typing indicator from other users
    socket.on('user_typing', (data) {
      if (data is Map) {
        _chatEvents.add(ChatSocketEvent(
          type: ChatEventType.typing,
          data: Map<String, dynamic>.from(data),
        ));
      }
    });

    // Error events
    socket.on('error', (data) {
      _chatEvents.add(ChatSocketEvent(
        type: ChatEventType.error,
        data: data is Map ? Map<String, dynamic>.from(data) : {'error': data.toString()},
      ));
    });
  }

  /// Join a chat session room.
  Future<Map<String, dynamic>?> joinSession(String sessionId) async {
    final completer = Completer<Map<String, dynamic>?>();
    _chatSocket?.emitWithAck('join_session', {'session_id': sessionId}, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Leave a chat session room.
  void leaveSession(String sessionId) {
    _chatSocket?.emit('leave_session', {'session_id': sessionId});
  }

  /// Send a chat message via Socket.IO (returns ack with run_id).
  Future<Map<String, dynamic>?> sendMessage({
    required String message,
    required String agentId,
    String? sessionId,
  }) async {
    final completer = Completer<Map<String, dynamic>?>();
    _chatSocket?.emitWithAck('message', {
      'message': message,
      'agent_id': agentId,
      'session_id': sessionId,
    }, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  }

  /// Send typing indicator.
  void sendTyping(String sessionId, bool isTyping) {
    _chatSocket?.emit('typing', {
      'session_id': sessionId,
      'typing': isTyping,
    });
  }

  // ===========================================================================
  // /approvals namespace
  // ===========================================================================

  void _setupApprovalsHandlers() {
    final socket = _approvalsSocket!;

    socket.onConnect((_) {
      debugPrint('[Socket/approvals] Connected');
    });

    socket.on('new_approval', (data) {
      if (data is Map) {
        _approvalEvents.add(Map<String, dynamic>.from(data));
      }
    });

    socket.on('approval_processed', (data) {
      if (data is Map) {
        _approvalEvents.add(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Get pending approvals.
  Future<Map<String, dynamic>?> getPendingApprovals() async {
    final completer = Completer<Map<String, dynamic>?>();
    _approvalsSocket?.emitWithAck('get_pending', {}, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Approve a HITL request.
  Future<Map<String, dynamic>?> approve(String runId) async {
    final completer = Completer<Map<String, dynamic>?>();
    _approvalsSocket?.emitWithAck('approve', {'run_id': runId}, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Reject a HITL request.
  Future<Map<String, dynamic>?> reject(String runId, {String reason = ''}) async {
    final completer = Completer<Map<String, dynamic>?>();
    _approvalsSocket?.emitWithAck('reject', {
      'run_id': runId,
      'reason': reason,
    }, ack: (data) {
      completer.complete(data is Map ? Map<String, dynamic>.from(data) : null);
    });
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  // ===========================================================================
  // /events namespace
  // ===========================================================================

  void _setupEventsHandlers() {
    final socket = _eventsSocket!;

    socket.onConnect((_) {
      debugPrint('[Socket/events] Connected');
    });

    socket.on('nats_event', (data) {
      if (data is Map) {
        _natsEvents.add(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Subscribe to a NATS subject pattern.
  void subscribeToNats(String subject) {
    _eventsSocket?.emit('subscribe', {'subject': subject});
  }

  /// Unsubscribe from a NATS subject pattern.
  void unsubscribeFromNats(String subject) {
    _eventsSocket?.emit('unsubscribe', {'subject': subject});
  }

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  /// Disconnect all sockets.
  void disconnect() {
    _systemSocket?.disconnect();
    _chatSocket?.disconnect();
    _approvalsSocket?.disconnect();
    _eventsSocket?.disconnect();
    _connectionState.value = SocketConnectionState.disconnected;
    debugPrint('[SocketService] All sockets disconnected');
  }

  /// Reconnect all sockets.
  void reconnect() {
    _systemSocket?.connect();
    _chatSocket?.connect();
    _approvalsSocket?.connect();
    _eventsSocket?.connect();
    debugPrint('[SocketService] Reconnecting all sockets...');
  }

  /// Dispose all resources.
  void dispose() {
    disconnect();
    _systemSocket?.dispose();
    _chatSocket?.dispose();
    _approvalsSocket?.dispose();
    _eventsSocket?.dispose();
    _systemEvents.close();
    _chatEvents.close();
    _approvalEvents.close();
    _natsEvents.close();
    _initialized = false;
  }
}


// =============================================================================
// Models
// =============================================================================

enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum ChatEventType {
  streamToken,
  runStarted,
  runComplete,
  toolCall,
  typing,
  error,
}

class ChatSocketEvent {
  final ChatEventType type;
  final Map<String, dynamic> data;

  ChatSocketEvent({required this.type, required this.data});

  String? get content => data['content'] as String?;
  String? get runId => data['run_id'] as String?;
  String? get agentId => data['agent_id'] as String?;
  String? get toolName => data['tool_name'] as String?;
  String? get error => data['error'] as String?;
}
