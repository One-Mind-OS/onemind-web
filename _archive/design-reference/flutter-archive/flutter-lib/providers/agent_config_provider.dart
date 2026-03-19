import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tool_config.dart';

// Note: selectedAgentProvider is defined in universal_chat_screen.dart
// We'll reference it there when integrating

/// Agent configuration notifier
class AgentConfigNotifier extends StateNotifier<AgentConfig> {
  AgentConfigNotifier() : super(const AgentConfig());

  /// Update configuration based on selected agent/team
  void updateFromSelection(String? agentOrTeamName) {
    if (agentOrTeamName == null) {
      state = const AgentConfig();
      return;
    }

    // Check if it's a team (starts with ⚡)
    final isTeam = agentOrTeamName.startsWith('⚡ ');
    final cleanName = isTeam ? agentOrTeamName.substring(2) : agentOrTeamName;

    if (isTeam) {
      _loadTeamConfig(cleanName);
    } else {
      _loadAgentConfig(cleanName);
    }
  }

  /// Load agent configuration
  void _loadAgentConfig(String agentName) {
    // Default tools for each agent (will be replaced by API call)
    final tools = _getDefaultToolsForAgent(agentName);
    final model = _getModelForAgent(agentName);

    state = AgentConfig(
      agentId: agentName.toLowerCase().replaceAll(' ', '_'),
      name: agentName,
      modelId: model['id'],
      modelName: model['name'],
      tools: tools,
      knowledgeBases: [],
      instructions: _getDefaultInstructionsForAgent(agentName),
      isTeam: false,
    );
  }

  /// Load team configuration
  void _loadTeamConfig(String teamName) {
    final members = _getTeamMembers(teamName);
    final tools = _getDefaultToolsForTeam(teamName);
    final model = _getModelForTeam(teamName);

    state = AgentConfig(
      agentId: teamName.toLowerCase().replaceAll(' ', '_'),
      name: teamName,
      modelId: model['id'],
      modelName: model['name'],
      tools: tools,
      knowledgeBases: [],
      instructions: 'Team coordination instructions',
      isTeam: true,
      teamMembers: members,
    );
  }

  /// Toggle tool enabled state
  void toggleTool(String toolName) {
    final updatedTools = state.tools.map((tool) {
      if (tool.name == toolName) {
        return tool.copyWith(isEnabled: !tool.isEnabled);
      }
      return tool;
    }).toList();

    state = state.copyWith(tools: updatedTools);
  }

  /// Add knowledge base
  void addKnowledgeBase(String kbId) {
    if (!state.knowledgeBases.contains(kbId)) {
      state = state.copyWith(
        knowledgeBases: [...state.knowledgeBases, kbId],
      );
    }
  }

  /// Remove knowledge base
  void removeKnowledgeBase(String kbId) {
    state = state.copyWith(
      knowledgeBases: state.knowledgeBases.where((id) => id != kbId).toList(),
    );
  }

  // Helper methods for default configurations

  List<ToolConfig> _getDefaultToolsForAgent(String agentName) {
    switch (agentName) {
      case 'Assistant':
        return [
          const ToolConfig(
            name: 'Web Search',
            category: 'Web & Search',
            description: 'Search the web for current information',
            isEnabled: true,
            iconName: 'search',
          ),
          const ToolConfig(
            name: 'File Operations',
            category: 'File Operations',
            description: 'Read and write files',
            isEnabled: true,
            iconName: 'folder',
          ),
          const ToolConfig(
            name: 'Calculator',
            category: 'Data & Analytics',
            description: 'Perform mathematical calculations',
            isEnabled: false,
            iconName: 'calculate',
          ),
        ];
      case 'Researcher':
        return [
          const ToolConfig(
            name: 'Web Search',
            category: 'Web & Search',
            description: 'Search the web for information',
            isEnabled: true,
            iconName: 'search',
          ),
          const ToolConfig(
            name: 'Arxiv Search',
            category: 'Data & Analytics',
            description: 'Search academic papers',
            isEnabled: true,
            iconName: 'school',
          ),
          const ToolConfig(
            name: 'Wikipedia',
            category: 'Data & Analytics',
            description: 'Search Wikipedia',
            isEnabled: true,
            iconName: 'book',
          ),
        ];
      case 'Analyst':
        return [
          const ToolConfig(
            name: 'Calculator',
            category: 'Data & Analytics',
            description: 'Mathematical operations',
            isEnabled: true,
            iconName: 'calculate',
          ),
          const ToolConfig(
            name: 'File Operations',
            category: 'File Operations',
            description: 'Read and analyze files',
            isEnabled: true,
            iconName: 'folder',
          ),
        ];
      case 'Coder':
        return [
          const ToolConfig(
            name: 'GitHub Tools',
            category: 'Development',
            description: 'Access GitHub repositories',
            isEnabled: true,
            iconName: 'code',
          ),
          const ToolConfig(
            name: 'File Operations',
            category: 'File Operations',
            description: 'Read and write code files',
            isEnabled: true,
            iconName: 'folder',
          ),
        ];
      default:
        return [];
    }
  }

  List<ToolConfig> _getDefaultToolsForTeam(String teamName) {
    // Teams typically have combined tools from members
    return [
      const ToolConfig(
        name: 'Web Search',
        category: 'Web & Search',
        description: 'Shared web search capability',
        isEnabled: true,
        iconName: 'search',
      ),
      const ToolConfig(
        name: 'File Operations',
        category: 'File Operations',
        description: 'Shared file access',
        isEnabled: true,
        iconName: 'folder',
      ),
    ];
  }

  List<String> _getTeamMembers(String teamName) {
    switch (teamName) {
      case 'Research Team':
        return ['Researcher', 'Analyst'];
      case 'Dev Team':
        return ['Coder', 'Assistant'];
      case 'Full Team':
        return ['Assistant', 'Researcher', 'Analyst', 'Coder'];
      default:
        return [];
    }
  }

  String _getDefaultInstructionsForAgent(String agentName) {
    switch (agentName) {
      case 'Assistant':
        return 'General purpose AI assistant with web search and file operations';
      case 'Researcher':
        return 'Research specialist with access to academic sources';
      case 'Analyst':
        return 'Data analysis expert with calculation and file processing';
      case 'Coder':
        return 'Coding specialist with GitHub integration';
      default:
        return 'AI agent';
    }
  }

  Map<String, String> _getModelForAgent(String agentName) {
    // All agents in backend use Claude Sonnet 4.5
    return {
      'id': 'us.anthropic.claude-sonnet-4-5-20250929-v1:0',
      'name': 'Claude Sonnet 4.5',
    };
  }

  Map<String, String> _getModelForTeam(String teamName) {
    // Team coordinator model
    return {
      'id': 'us.anthropic.claude-sonnet-4-5-20250929-v1:0',
      'name': 'Claude Sonnet 4.5',
    };
  }
}

/// Agent configuration provider
/// Note: This will be connected to the selectedAgentProvider from universal_chat_screen.dart
final agentConfigProvider = StateNotifierProvider<AgentConfigNotifier, AgentConfig>(
  (ref) => AgentConfigNotifier(),
);

/// Knowledge base list provider (will be replaced with API call)
final knowledgeBasesProvider = Provider<List<KnowledgeBaseConfig>>((ref) {
  return [
    const KnowledgeBaseConfig(
      id: 'kb_1',
      name: 'Documentation',
      description: 'Project documentation and guides',
      documentCount: 15,
      isEnabled: false,
    ),
    const KnowledgeBaseConfig(
      id: 'kb_2',
      name: 'Research Papers',
      description: 'Academic research collection',
      documentCount: 42,
      isEnabled: false,
    ),
    const KnowledgeBaseConfig(
      id: 'kb_3',
      name: 'Code Examples',
      description: 'Programming examples and patterns',
      documentCount: 28,
      isEnabled: false,
    ),
  ];
});
