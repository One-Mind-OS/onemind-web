/// Session model matching AgentOS SessionSchema
class SessionModel {
  final String sessionId;
  final String sessionName;
  final Map<String, dynamic>? sessionState;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? agentId;
  final String? lastMessage;

  /// Agent name (alias for agentId for display purposes)
  String? get agentName => agentId;

  const SessionModel({
    required this.sessionId,
    required this.sessionName,
    this.sessionState,
    this.createdAt,
    this.updatedAt,
    this.agentId,
    this.lastMessage,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['session_id'] as String,
      sessionName: json['session_name'] as String,
      sessionState: json['session_state'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      agentId: json['agent_id'] as String?,
      lastMessage: json['summary'] as String?, // Map summary to lastMessage for preview
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_name': sessionName,
      'session_state': sessionState,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get session duration as a formatted string
  String get durationString {
    if (createdAt == null || updatedAt == null) return 'Active';
    final duration = updatedAt!.difference(createdAt!);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get session created date as a formatted string
  String get createdDateString {
    if (createdAt == null) return 'Unknown';
    return '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')} ${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    if (updatedAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays > 7) {
      return createdDateString;
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
