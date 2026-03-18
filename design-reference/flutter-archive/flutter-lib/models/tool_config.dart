/// Tool configuration model for agent/team tool assignments
class ToolConfig {
  final String name;
  final String category;
  final String description;
  final bool isEnabled;
  final String? iconName;

  const ToolConfig({
    required this.name,
    required this.category,
    required this.description,
    this.isEnabled = false,
    this.iconName,
  });

  ToolConfig copyWith({
    String? name,
    String? category,
    String? description,
    bool? isEnabled,
    String? iconName,
  }) {
    return ToolConfig(
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'isEnabled': isEnabled,
      'iconName': iconName,
    };
  }

  factory ToolConfig.fromJson(Map<String, dynamic> json) {
    return ToolConfig(
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      isEnabled: json['isEnabled'] as bool? ?? false,
      iconName: json['iconName'] as String?,
    );
  }
}

/// Tool categories for organization
enum ToolCategory {
  webSearch('Web & Search', '🔍'),
  development('Development', '💻'),
  communication('Communication', '💬'),
  dataAnalytics('Data & Analytics', '📊'),
  cloudServices('Cloud Services', '☁️'),
  aiServices('AI Services', '🤖'),
  fileOperations('File Operations', '📁'),
  custom('Custom Tools', '🔧');

  final String label;
  final String icon;

  const ToolCategory(this.label, this.icon);
}

/// Agent configuration for dynamic settings
class AgentConfig {
  final String? agentId;
  final String? name;
  final String? modelId;
  final String? modelName;
  final List<ToolConfig> tools;
  final List<String> knowledgeBases;
  final String? instructions;
  final bool isTeam;
  final List<String>? teamMembers;

  const AgentConfig({
    this.agentId,
    this.name,
    this.modelId,
    this.modelName,
    this.tools = const [],
    this.knowledgeBases = const [],
    this.instructions,
    this.isTeam = false,
    this.teamMembers,
  });

  AgentConfig copyWith({
    String? agentId,
    String? name,
    String? modelId,
    String? modelName,
    List<ToolConfig>? tools,
    List<String>? knowledgeBases,
    String? instructions,
    bool? isTeam,
    List<String>? teamMembers,
  }) {
    return AgentConfig(
      agentId: agentId ?? this.agentId,
      name: name ?? this.name,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      tools: tools ?? this.tools,
      knowledgeBases: knowledgeBases ?? this.knowledgeBases,
      instructions: instructions ?? this.instructions,
      isTeam: isTeam ?? this.isTeam,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }

  /// Get only enabled tools
  List<ToolConfig> get enabledTools => tools.where((t) => t.isEnabled).toList();

  /// Get tools by category
  List<ToolConfig> getToolsByCategory(ToolCategory category) {
    return tools.where((t) => t.category == category.label).toList();
  }
}

/// Knowledge base configuration
class KnowledgeBaseConfig {
  final String id;
  final String name;
  final String description;
  final int documentCount;
  final bool isEnabled;

  const KnowledgeBaseConfig({
    required this.id,
    required this.name,
    required this.description,
    this.documentCount = 0,
    this.isEnabled = false,
  });

  KnowledgeBaseConfig copyWith({
    String? id,
    String? name,
    String? description,
    int? documentCount,
    bool? isEnabled,
  }) {
    return KnowledgeBaseConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      documentCount: documentCount ?? this.documentCount,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'documentCount': documentCount,
      'isEnabled': isEnabled,
    };
  }

  factory KnowledgeBaseConfig.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      documentCount: json['documentCount'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }
}
