import 'dart:convert';

/// Approval request model for HITL (Human-in-the-Loop)
class ApprovalRequest {
  final String id;
  final String agentId;
  final String? agentName;
  final String? sessionId;
  final String toolName;
  final Map<String, dynamic> toolArgs;
  final DateTime requestedAt;
  final String status; // 'pending', 'approved', 'rejected'

  const ApprovalRequest({
    required this.id,
    required this.agentId,
    this.agentName,
    this.sessionId,
    required this.toolName,
    required this.toolArgs,
    required this.requestedAt,
    required this.status,
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] as String,
      agentId: json['agent_id'] as String,
      agentName: json['agent_name'] as String?,
      sessionId: json['session_id'] as String?,
      toolName: json['tool_name'] as String,
      toolArgs: json['tool_args'] as Map<String, dynamic>? ?? {},
      requestedAt: DateTime.parse(json['requested_at'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'agent_name': agentName,
      'session_id': sessionId,
      'tool_name': toolName,
      'tool_args': toolArgs,
      'requested_at': requestedAt.toIso8601String(),
      'status': status,
    };
  }

  /// Format the requested timestamp
  String get requestedAtString {
    return '${requestedAt.year}-${requestedAt.month.toString().padLeft(2, '0')}-${requestedAt.day.toString().padLeft(2, '0')} ${requestedAt.hour.toString().padLeft(2, '0')}:${requestedAt.minute.toString().padLeft(2, '0')}:${requestedAt.second.toString().padLeft(2, '0')}';
  }

  /// Format tool args as a readable string
  String get toolArgsString {
    if (toolArgs.isEmpty) return 'No arguments';
    return const JsonEncoder.withIndent('  ').convert(toolArgs);
  }

  /// Get a brief summary of tool args (first 100 chars)
  String get toolArgsBrief {
    final jsonStr = jsonEncode(toolArgs);
    if (jsonStr.length <= 100) return jsonStr;
    return '${jsonStr.substring(0, 100)}...';
  }
}

/// Paused run model for agent runs awaiting approval
class PausedRun {
  final String id;
  final String runId;
  final String agentId;
  final String? agentName;
  final String? sessionId;
  final String? message;
  final String status; // 'paused', 'waiting_approval'
  final DateTime pausedAt;

  const PausedRun({
    required this.id,
    required this.runId,
    required this.agentId,
    this.agentName,
    this.sessionId,
    this.message,
    required this.status,
    required this.pausedAt,
  });

  factory PausedRun.fromJson(Map<String, dynamic> json) {
    return PausedRun(
      id: json['id'] as String,
      runId: json['run_id'] as String,
      agentId: json['agent_id'] as String,
      agentName: json['agent_name'] as String?,
      sessionId: json['session_id'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'paused',
      pausedAt: DateTime.parse(json['paused_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'run_id': runId,
      'agent_id': agentId,
      'agent_name': agentName,
      'session_id': sessionId,
      'message': message,
      'status': status,
      'paused_at': pausedAt.toIso8601String(),
    };
  }

  /// Format the paused timestamp
  String get pausedAtString {
    return '${pausedAt.year}-${pausedAt.month.toString().padLeft(2, '0')}-${pausedAt.day.toString().padLeft(2, '0')} ${pausedAt.hour.toString().padLeft(2, '0')}:${pausedAt.minute.toString().padLeft(2, '0')}:${pausedAt.second.toString().padLeft(2, '0')}';
  }

  /// Get duration paused in human-readable format
  String get pausedDuration {
    final now = DateTime.now();
    final duration = now.difference(pausedAt);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inSeconds}s ago';
    }
  }
}
