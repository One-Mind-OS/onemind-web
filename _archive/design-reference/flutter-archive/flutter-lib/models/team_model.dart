class TeamModel {
  final String? id;
  final String name;
  final String? description;
  final String modelId;
  final String modelName;
  final List<String> memberIds; // UUIDs of agent_configs

  // AgentOS Team coordination flags (actual API parameters)
  final bool respondDirectly;
  final bool determineInputForMembers;
  final bool delegateToAllMembers;

  final List<String> instructions;
  final bool markdown;
  final bool addHistoryToContext;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeamModel({
    this.id,
    required this.name,
    this.description,
    required this.modelId,
    required this.modelName,
    required this.memberIds,
    this.respondDirectly = false,
    this.determineInputForMembers = true,
    this.delegateToAllMembers = false,
    this.instructions = const [],
    this.markdown = true,
    this.addHistoryToContext = true,
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    // Parse AgentOS native format
    final model = json['model'] as Map<String, dynamic>?;
    final systemMessage = json['system_message'] as Map<String, dynamic>?;
    final sessions = json['sessions'] as Map<String, dynamic>?;
    final members = json['members'] as List<dynamic>?;

    // Extract member IDs from AgentOS format
    final memberIdsList = members?.map((m) => (m as Map<String, dynamic>)['id'] as String).toList() ?? [];

    // Extract instructions from system_message
    final instructionsList = (systemMessage?['instructions'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [];

    // Get model display name
    final modelIdStr = model?['model'] as String? ?? 'us.anthropic.claude-sonnet-4-5-20250929-v1:0';

    // Create friendly model name
    String modelDisplayName = 'Claude Sonnet 4.5';
    if (modelIdStr.contains('opus')) {
      modelDisplayName = 'Claude Opus';
    } else if (modelIdStr.contains('sonnet-4-5')) {
      modelDisplayName = 'Claude Sonnet 4.5';
    } else if (modelIdStr.contains('sonnet')) {
      modelDisplayName = 'Claude Sonnet';
    } else if (modelIdStr.contains('haiku')) {
      modelDisplayName = 'Claude Haiku';
    }

    return TeamModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      modelId: modelIdStr,
      modelName: modelDisplayName,
      memberIds: memberIdsList,
      respondDirectly: json['respond_directly'] ?? false,
      determineInputForMembers: json['determine_input_for_members'] ?? true,
      delegateToAllMembers: json['delegate_to_all_members'] ?? false,
      instructions: instructionsList,
      markdown: systemMessage?['markdown'] as bool? ?? true,
      addHistoryToContext: sessions?['add_history_to_context'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'model_id': modelId,
      'model_name': modelName,
      'member_ids': memberIds,
      'respond_directly': respondDirectly,
      'determine_input_for_members': determineInputForMembers,
      'delegate_to_all_members': delegateToAllMembers,
      'instructions': instructions,
      'markdown': markdown,
      'add_history_to_context': addHistoryToContext,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? description,
    String? modelId,
    String? modelName,
    List<String>? memberIds,
    bool? respondDirectly,
    bool? determineInputForMembers,
    bool? delegateToAllMembers,
    List<String>? instructions,
    bool? markdown,
    bool? addHistoryToContext,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      memberIds: memberIds ?? this.memberIds,
      respondDirectly: respondDirectly ?? this.respondDirectly,
      determineInputForMembers: determineInputForMembers ?? this.determineInputForMembers,
      delegateToAllMembers: delegateToAllMembers ?? this.delegateToAllMembers,
      instructions: instructions ?? this.instructions,
      markdown: markdown ?? this.markdown,
      addHistoryToContext: addHistoryToContext ?? this.addHistoryToContext,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get coordination description based on flags
  String get coordinationDescription {
    if (respondDirectly) {
      return 'Team lead responds directly';
    } else if (delegateToAllMembers) {
      return 'Delegates to all members';
    } else if (determineInputForMembers) {
      return 'Smart delegation';
    } else {
      return 'Custom coordination';
    }
  }
}
