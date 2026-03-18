import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_event.dart';
import '../models/message.dart';
import '../config/environment.dart';

/// Chat mode for universal chat
enum ChatMode {
  direct,  // Use model directly (default)
  agent,   // Route to specific agent
  team,    // Route to team
}

/// Model info from backend
class ModelInfo {
  final String id;
  final String name;
  final String provider;
  final String description;
  final List<String> capabilities;

  ModelInfo({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.capabilities,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      provider: json['provider'] ?? '',
      description: json['description'] ?? '',
      capabilities: List<String>.from(json['capabilities'] ?? []),
    );
  }

  bool get hasVision => capabilities.contains('vision');
  bool get hasTools => capabilities.contains('tools');
  bool get hasReasoning => capabilities.contains('reasoning');
  bool get hasAudio => capabilities.contains('audio');
}

/// Tool info from backend
class ToolInfo {
  final String id;
  final String name;
  final String category;
  final bool available;

  ToolInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.available,
  });

  factory ToolInfo.fromJson(Map<String, dynamic> json) {
    return ToolInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'custom',
      available: json['available'] ?? true,
    );
  }
}

/// Universal chat service for OneMind OS
///
/// Supports three modes:
/// 1. Direct: Use model directly with optional tools (default)
/// 2. Agent: Route to specific agent
/// 3. Team: Route to team
class UniversalChatService {
  final String baseUrl;

  UniversalChatService({String? baseUrl}) : baseUrl = baseUrl ?? Environment.apiBaseUrl;

  /// Send message using universal chat endpoint
  ///
  /// [mode] - Chat mode (direct, agent, team)
  /// [message] - User message
  /// [targetId] - Agent or team ID (required for agent/team mode)
  /// [modelId] - Model to use (for direct mode)
  /// [tools] - Tool names to enable (for direct mode)
  /// [sessionId] - Session ID for context
  /// [images] - Image attachments for vision
  Stream<AgentEvent> sendMessage({
    required String message,
    ChatMode mode = ChatMode.direct,
    String? targetId,
    String? modelId,
    List<String>? tools,
    String? sessionId,
    List<ImageAttachment>? images,
  }) async* {
    final url = Uri.parse('$baseUrl/api/chat/universal');

    try {
      // Build request body
      final body = {
        'message': message,
        'mode': mode.name,
        'stream': true,
      };

      if (targetId != null) body['target_id'] = targetId;
      if (modelId != null) body['model_id'] = modelId;
      if (tools != null && tools.isNotEmpty) body['tools'] = tools;
      if (sessionId != null) body['session_id'] = sessionId;

      // Make streaming request
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);

      final response = await request.send();

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw Exception('Failed to send message: ${response.statusCode} - $errorBody');
      }

      String buffer = '';

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.isEmpty) continue;

          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.isEmpty) continue;

            try {
              final json = jsonDecode(data);
              if (json is! Map) continue;

              // Handle events from universal chat endpoint
              final event = json['event'] as String?;

              if (event == 'start') {
                yield AgentEvent(
                  type: AgentEventType.agentStart,
                  agentName: json['model_id'] ?? 'OneMind',
                );
              } else if (event == 'tool_start') {
                yield AgentEvent(
                  type: AgentEventType.toolCall,
                  toolName: json['tool'] ?? 'unknown',
                );
              } else if (event == 'tool_complete') {
                yield AgentEvent(
                  type: AgentEventType.toolResult,
                  toolName: json['tool'] ?? 'unknown',
                );
              } else if (event == 'member_start') {
                // Team member started
                yield AgentEvent(
                  type: AgentEventType.teamCoordination,
                  agentName: json['member'],
                );
              } else if (event == 'complete') {
                yield AgentEvent(
                  type: AgentEventType.agentComplete,
                );
              } else if (json.containsKey('content')) {
                // Content chunk
                final content = json['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  yield AgentEvent(
                    type: AgentEventType.content,
                    content: content,
                  );
                }
              } else if (json.containsKey('error')) {
                throw Exception(json['error']);
              }
            } catch (e) {
              if (e is Exception && e.toString().contains('error')) {
                rethrow;
              }
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error streaming response: $e');
    }
  }

  /// Get available models from backend
  Future<List<ModelInfo>> getModels() async {
    final url = Uri.parse('$baseUrl/api/chat/models');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((m) => ModelInfo.fromJson(m)).toList();
      }
      throw Exception('Failed to load models: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching models: $e');
    }
  }

  /// Get available tools from backend
  Future<List<ToolInfo>> getTools() async {
    final url = Uri.parse('$baseUrl/api/chat/tools');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => ToolInfo.fromJson(t)).toList();
      }
      throw Exception('Failed to load tools: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching tools: $e');
    }
  }

  /// Get available agents from backend
  Future<List<Map<String, String>>> getAgents() async {
    final url = Uri.parse('$baseUrl/api/chat/agents');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((a) => {
          'id': a['id'] as String,
          'name': a['name'] as String,
        }).toList();
      }
      throw Exception('Failed to load agents: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching agents: $e');
    }
  }

  /// Get available teams from backend
  Future<List<Map<String, String>>> getTeams() async {
    final url = Uri.parse('$baseUrl/api/chat/teams');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((t) => {
          'id': t['id'] as String,
          'name': t['name'] as String,
        }).toList();
      }
      throw Exception('Failed to load teams: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }
}
