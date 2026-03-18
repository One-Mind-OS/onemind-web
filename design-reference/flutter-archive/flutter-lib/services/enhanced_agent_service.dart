import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent_event.dart';
import '../models/message.dart';
import '../config/environment.dart';

/// Enhanced agent service that provides detailed status updates
class EnhancedAgentService {
  final String baseUrl;

  EnhancedAgentService({String? baseUrl}) : baseUrl = baseUrl ?? Environment.apiBaseUrl;

  /// Send message and get detailed event stream including status updates
  /// Supports vision via optional images parameter
  /// Uses enhanced endpoint for reasoning and tool call visibility
  Stream<AgentEvent> sendMessageWithEvents({
    required String agentName,
    required String message,
    String? modelId,
    List<ImageAttachment>? images, // Vision support
  }) async* {
    // Use native AgentOS endpoint (plural 'runs')
    final url = Uri.parse('$baseUrl/agents/${agentName.toLowerCase()}/runs');

    // Always use multipart form-data (AgentOS native format)
    final multipartRequest = http.MultipartRequest('POST', url);
    multipartRequest.fields['message'] = message;
    multipartRequest.fields['stream'] = 'true';

    // TODO: Vision support - add image files when implemented
    // if (images != null && images.isNotEmpty) {
    //   for (var img in images) {
    //     multipartRequest.files.add(http.MultipartFile.fromBytes(
    //       'files',
    //       img.bytes,
    //       filename: img.filename,
    //     ));
    //   }
    // }

    final request = multipartRequest;

    try {
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      String buffer = '';
      String? currentEvent;

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.isEmpty) {
            currentEvent = null;
            continue;
          }

          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
            continue;
          }

          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.isEmpty) continue;

            try {
              // AgentOS native endpoint returns proper JSON
              // Example: data: {"event":"RunContent","content":"2",...}
              final json = jsonDecode(data);
              if (json is! Map) continue;

              // Handle different event types based on the 'event' field in JSON
              final eventType = json['event'] as String?;

              if (eventType == 'RunStarted' || currentEvent == 'RunStarted') {
                yield AgentEvent(
                  type: AgentEventType.agentStart,
                  agentName: json['agent_name'] ?? agentName,
                );
              } else if (eventType == 'RunContent' || currentEvent == 'RunContent') {
                // Content events - stream incrementally
                final content = json['content']?.toString();
                if (content != null && content.isNotEmpty) {
                  yield AgentEvent(
                    type: AgentEventType.content,
                    content: content,
                  );
                }
              } else if (eventType == 'RunComplete' || currentEvent == 'RunComplete') {
                yield AgentEvent(
                  type: AgentEventType.agentComplete,
                  agentName: json['agent_name'] ?? agentName,
                );
              } else if (eventType == 'ToolCallStarted' || currentEvent == 'ToolCallStarted') {
                // Tool usage started
                final toolName = json['tool_name'] ?? json['name'] ?? 'unknown';
                yield AgentEvent(
                  type: AgentEventType.toolCall,
                  toolName: toolName,
                );
              } else if (eventType == 'ToolCallComplete' || currentEvent == 'ToolCallComplete') {
                // Tool usage completed
                final toolName = json['tool_name'] ?? json['name'] ?? 'unknown';
                yield AgentEvent(
                  type: AgentEventType.toolResult,
                  toolName: toolName,
                  content: json['result']?.toString(),
                );
              } else if (currentEvent == 'TeamRunContent') {
                // Team content events
                final content = json['content']?.toString();
                if (content != null && content.isNotEmpty) {
                  yield AgentEvent(
                    type: AgentEventType.content,
                    content: content,
                  );
                }
              } else if (currentEvent == 'ToolCallStarted') {
                // Tool usage started
                final toolName = json['tool_name'] ?? 'unknown';
                yield AgentEvent(
                  type: AgentEventType.toolCall,
                  toolName: toolName,
                );
              } else if (currentEvent == 'ToolCallCompleted') {
                // Tool completed
                final toolName = json['tool_name'] ?? 'unknown';
                yield AgentEvent(
                  type: AgentEventType.toolResult,
                  toolName: toolName,
                );
              } else if (currentEvent == 'RunCompleted') {
                yield AgentEvent(
                  type: AgentEventType.agentComplete,
                  agentName: agentName,
                );
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error streaming response: $e');
    }
  }

  /// Get available agents
  Future<List<String>> getAgents() async {
    final url = Uri.parse('$baseUrl/agents');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> agents = jsonDecode(response.body);
        return agents.map((agent) => agent['name'] as String).toList();
      }
      throw Exception('Failed to load agents');
    } catch (e) {
      throw Exception('Error fetching agents: $e');
    }
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    final url = Uri.parse('$baseUrl/config');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> config = jsonDecode(response.body);
        final List<dynamic>? models = config['available_models'];
        return models?.map((model) => model as String).toList() ?? [];
      }
      throw Exception('Failed to load config');
    } catch (e) {
      throw Exception('Error fetching available models: $e');
    }
  }
}
