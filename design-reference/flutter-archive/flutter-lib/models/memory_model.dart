/// Memory model matching AgentOS UserMemorySchema
class MemoryModel {
  final String memoryId;
  final String memory;
  final List<String>? topics;
  final String? agentId;
  final String? teamId;
  final String userId;
  final DateTime? updatedAt;

  const MemoryModel({
    required this.memoryId,
    required this.memory,
    this.topics,
    this.agentId,
    this.teamId,
    required this.userId,
    this.updatedAt,
  });

  MemoryModel copyWith({
    String? memoryId,
    String? memory,
    List<String>? topics,
    String? agentId,
    String? teamId,
    String? userId,
    DateTime? updatedAt,
  }) {
    return MemoryModel(
      memoryId: memoryId ?? this.memoryId,
      memory: memory ?? this.memory,
      topics: topics ?? this.topics,
      agentId: agentId ?? this.agentId,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memory_id': memoryId,
      'memory': memory,
      if (topics != null) 'topics': topics,
      if (agentId != null) 'agent_id': agentId,
      if (teamId != null) 'team_id': teamId,
      'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      memoryId: json['memory_id'] as String,
      memory: json['memory'] as String,
      topics: json['topics'] != null
          ? List<String>.from(json['topics'] as List)
          : null,
      agentId: json['agent_id'] as String?,
      teamId: json['team_id'] as String?,
      userId: json['user_id'] as String,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Create empty memory for new memory form
  factory MemoryModel.empty(String userId) {
    return MemoryModel(
      memoryId: '',
      memory: '',
      userId: userId,
    );
  }

  /// Format the updated timestamp
  String get updatedAtString {
    if (updatedAt == null) return 'Unknown';
    return '${updatedAt!.year}-${updatedAt!.month.toString().padLeft(2, '0')}-${updatedAt!.day.toString().padLeft(2, '0')} ${updatedAt!.hour.toString().padLeft(2, '0')}:${updatedAt!.minute.toString().padLeft(2, '0')}';
  }

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    if (updatedAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays > 7) {
      return updatedAtString;
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

  /// Get topics as display string
  String get topicsDisplay {
    if (topics == null || topics!.isEmpty) return 'No topics';
    return topics!.join(', ');
  }
}
