/// Complete agent model matching AgentOS Agent class
class AgentModel {
  // Identity
  final String? id;
  final String name;

  /// Alias for id (for compatibility)
  String? get agentId => id;
  final String? description;
  final String? role;

  // Model
  final String modelId;
  final String modelName;

  // Instructions & Behavior
  final List<String> instructions;
  final bool markdown;

  // Tools
  final List<String> tools; // List of tool names

  // Knowledge & RAG
  final List<String> knowledgeBases; // List of KB IDs
  final bool addKnowledgeToContext;

  // Memory & Learning
  final bool updateMemoryOnRun;
  final bool enableAgenticMemory;
  final bool addMemoriesToContext;

  // History & Context
  final bool addHistoryToContext;
  final int? numHistoryRuns;
  final int? numHistoryMessages;
  final bool addDatetimeToContext;

  // Session Management
  final bool enableSessionSummaries;
  final bool addSessionSummaryToContext;
  final bool enableAgenticState;

  // Advanced
  final int? toolCallLimit;
  final int? reasoningSteps;

  const AgentModel({
    this.id,
    required this.name,
    this.description,
    this.role,
    required this.modelId,
    required this.modelName,
    this.instructions = const [],
    this.markdown = true,
    this.tools = const [],
    this.knowledgeBases = const [],
    this.addKnowledgeToContext = false,
    this.updateMemoryOnRun = false,
    this.enableAgenticMemory = false,
    this.addMemoriesToContext = false,
    this.addHistoryToContext = true,
    this.numHistoryRuns = 5,
    this.numHistoryMessages,
    this.addDatetimeToContext = true,
    this.enableSessionSummaries = false,
    this.addSessionSummaryToContext = false,
    this.enableAgenticState = false,
    this.toolCallLimit,
    this.reasoningSteps,
  });

  AgentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? role,
    String? modelId,
    String? modelName,
    List<String>? instructions,
    bool? markdown,
    List<String>? tools,
    List<String>? knowledgeBases,
    bool? addKnowledgeToContext,
    bool? updateMemoryOnRun,
    bool? enableAgenticMemory,
    bool? addMemoriesToContext,
    bool? addHistoryToContext,
    int? numHistoryRuns,
    int? numHistoryMessages,
    bool? addDatetimeToContext,
    bool? enableSessionSummaries,
    bool? addSessionSummaryToContext,
    bool? enableAgenticState,
    int? toolCallLimit,
    int? reasoningSteps,
  }) {
    return AgentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      role: role ?? this.role,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      instructions: instructions ?? this.instructions,
      markdown: markdown ?? this.markdown,
      tools: tools ?? this.tools,
      knowledgeBases: knowledgeBases ?? this.knowledgeBases,
      addKnowledgeToContext: addKnowledgeToContext ?? this.addKnowledgeToContext,
      updateMemoryOnRun: updateMemoryOnRun ?? this.updateMemoryOnRun,
      enableAgenticMemory: enableAgenticMemory ?? this.enableAgenticMemory,
      addMemoriesToContext: addMemoriesToContext ?? this.addMemoriesToContext,
      addHistoryToContext: addHistoryToContext ?? this.addHistoryToContext,
      numHistoryRuns: numHistoryRuns ?? this.numHistoryRuns,
      numHistoryMessages: numHistoryMessages ?? this.numHistoryMessages,
      addDatetimeToContext: addDatetimeToContext ?? this.addDatetimeToContext,
      enableSessionSummaries: enableSessionSummaries ?? this.enableSessionSummaries,
      addSessionSummaryToContext: addSessionSummaryToContext ?? this.addSessionSummaryToContext,
      enableAgenticState: enableAgenticState ?? this.enableAgenticState,
      toolCallLimit: toolCallLimit ?? this.toolCallLimit,
      reasoningSteps: reasoningSteps ?? this.reasoningSteps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'role': role,
      'model_id': modelId,
      'model_name': modelName,
      'instructions': instructions,
      'markdown': markdown,
      'tools': tools,
      'knowledge_bases': knowledgeBases,
      'add_knowledge_to_context': addKnowledgeToContext,
      'update_memory_on_run': updateMemoryOnRun,
      'enable_agentic_memory': enableAgenticMemory,
      'add_memories_to_context': addMemoriesToContext,
      'add_history_to_context': addHistoryToContext,
      'num_history_runs': numHistoryRuns,
      'num_history_messages': numHistoryMessages,
      'add_datetime_to_context': addDatetimeToContext,
      'enable_session_summaries': enableSessionSummaries,
      'add_session_summary_to_context': addSessionSummaryToContext,
      'enable_agentic_state': enableAgenticState,
      'tool_call_limit': toolCallLimit,
      'reasoning_steps': reasoningSteps,
    };
  }

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    // Parse AgentOS native format
    final model = json['model'] as Map<String, dynamic>?;
    final tools = json['tools'] as Map<String, dynamic>?;
    final sessions = json['sessions'] as Map<String, dynamic>?;
    final systemMessage = json['system_message'] as Map<String, dynamic>?;

    // Extract tool names from AgentOS format
    final toolsList = (tools?['tools'] as List<dynamic>?)
        ?.map((t) => (t as Map<String, dynamic>)['name'] as String)
        .toList() ?? [];

    // Extract instructions from system_message
    final instructionsList = (systemMessage?['instructions'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [];

    // Get model display name
    final modelIdStr = model?['model'] as String? ?? 'us.anthropic.claude-sonnet-4-5-20250929-v1:0';
    final modelProvider = model?['provider'] as String? ?? 'AwsBedrock';

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
    } else if (modelProvider == 'AwsBedrock') {
      modelDisplayName = 'Claude Sonnet 4.5';
    }

    return AgentModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      role: json['role'] as String?,
      modelId: modelIdStr,
      modelName: modelDisplayName,
      instructions: instructionsList,
      markdown: systemMessage?['markdown'] as bool? ?? true,
      tools: toolsList,
      knowledgeBases: (json['knowledge_bases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      addKnowledgeToContext: json['add_knowledge_to_context'] as bool? ?? false,
      updateMemoryOnRun: json['update_memory_on_run'] as bool? ?? false,
      enableAgenticMemory: json['enable_agentic_memory'] as bool? ?? false,
      addMemoriesToContext: json['add_memories_to_context'] as bool? ?? false,
      addHistoryToContext: sessions?['add_history_to_context'] as bool? ?? true,
      numHistoryRuns: sessions?['num_history_runs'] as int? ?? 5,
      numHistoryMessages: json['num_history_messages'] as int?,
      addDatetimeToContext: systemMessage?['add_datetime_to_context'] as bool? ?? true,
      enableSessionSummaries: json['enable_session_summaries'] as bool? ?? false,
      addSessionSummaryToContext: json['add_session_summary_to_context'] as bool? ?? false,
      enableAgenticState: json['enable_agentic_state'] as bool? ?? false,
      toolCallLimit: json['tool_call_limit'] as int?,
      reasoningSteps: json['reasoning_steps'] as int?,
    );
  }

  /// Create empty agent for new agent form
  factory AgentModel.empty() {
    return const AgentModel(
      name: '',
      modelId: 'us.anthropic.claude-sonnet-4-5-20250929-v1:0',
      modelName: 'Claude Sonnet 4.5',
    );
  }
}

/// Available models for selection
class ModelOption {
  final String id;
  final String name;
  final String provider;

  const ModelOption({
    required this.id,
    required this.name,
    required this.provider,
  });
}

/// Predefined model options
const List<ModelOption> availableModels = [
  ModelOption(
    id: 'us.anthropic.claude-sonnet-4-5-20250929-v1:0',
    name: 'Claude Sonnet 4.5',
    provider: 'Anthropic',
  ),
  ModelOption(
    id: 'claude-opus-4-6',
    name: 'Claude Opus 4.6',
    provider: 'Anthropic',
  ),
  ModelOption(
    id: 'gpt-4o',
    name: 'GPT-4o',
    provider: 'OpenAI',
  ),
  ModelOption(
    id: 'gpt-4-turbo',
    name: 'GPT-4 Turbo',
    provider: 'OpenAI',
  ),
];

/// Tool information model
class ToolInfo {
  final String name;
  final String category;
  final String description;
  final String? iconName;

  const ToolInfo({
    required this.name,
    required this.category,
    required this.description,
    this.iconName,
  });
}

/// Available tools organized by category (subset for now, will expand)
const Map<String, List<ToolInfo>> availableTools = {
  'Web & Search': [
    ToolInfo(
      name: 'DuckDuckGoTools',
      category: 'Web & Search',
      description: 'Web search using DuckDuckGo',
      iconName: 'search',
    ),
    ToolInfo(
      name: 'BraveTools',
      category: 'Web & Search',
      description: 'Web search using Brave',
      iconName: 'search',
    ),
    ToolInfo(
      name: 'WikipediaTools',
      category: 'Web & Search',
      description: 'Search Wikipedia articles',
      iconName: 'book',
    ),
  ],
  'Development': [
    ToolInfo(
      name: 'GitHubTools',
      category: 'Development',
      description: 'GitHub repository operations',
      iconName: 'code',
    ),
    ToolInfo(
      name: 'DockerTools',
      category: 'Development',
      description: 'Docker container management',
      iconName: 'code',
    ),
  ],
  'Data & Analytics': [
    ToolInfo(
      name: 'ArxivTools',
      category: 'Data & Analytics',
      description: 'Search academic papers on Arxiv',
      iconName: 'school',
    ),
    ToolInfo(
      name: 'CalculatorTools',
      category: 'Data & Analytics',
      description: 'Mathematical calculations',
      iconName: 'calculate',
    ),
  ],
  'File Operations': [
    ToolInfo(
      name: 'FileTools',
      category: 'File Operations',
      description: 'File read/write operations',
      iconName: 'folder',
    ),
    ToolInfo(
      name: 'CSVTools',
      category: 'File Operations',
      description: 'CSV file processing',
      iconName: 'folder',
    ),
  ],
};
