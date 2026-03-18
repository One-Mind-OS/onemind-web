import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/message.dart';

class AgentService {
  // Default to localhost, can be configured
  final String baseUrl;

  AgentService({String? baseUrl}) : baseUrl = baseUrl ?? Environment.apiBaseUrl;

  /// Send a message to an agent with optional vision support
  /// Uses AgentOS native endpoint: POST /agents/{agent_name}/runs
  Stream<String> sendMessage({
    required String agentName,
    required String message,
    String? modelId, // Kept for compatibility but not used (single model setup)
    List<ImageAttachment>? images, // Vision support: attach images for GPT-4o
  }) async* {
    // Use AgentOS native endpoint: POST /agents/{agent_name}/runs
    final url = Uri.parse('$baseUrl/agents/${agentName.toLowerCase()}/runs');

    // Build request body with optional vision support
    http.BaseRequest request;

    if (images != null && images.isNotEmpty) {
      // For vision: use JSON body with images (GPT-4o multimodal format)
      final body = {
        'message': message,
        'stream': true,
        'images': images.map((img) => img.toJson()).toList(),
      };

      final jsonRequest = http.Request('POST', url);
      jsonRequest.headers['Content-Type'] = 'application/json';
      jsonRequest.body = jsonEncode(body);
      request = jsonRequest;
    } else {
      // Standard message: use multipart/form-data
      final multipartRequest = http.MultipartRequest('POST', url);
      multipartRequest.fields['message'] = message;
      multipartRequest.fields['stream'] = 'true';
      request = multipartRequest;
    }

    try {
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      // Parse AgentOS SSE stream with deduplication
      String buffer = '';
      String lastContent = ''; // Track last full content for deduplication
      String? currentEvent;

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          if (line.isEmpty) {
            currentEvent = null;
            continue;
          }

          // Track event type
          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
            continue;
          }

          // Process data lines
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.isEmpty) continue;

            // Only process RunContent events
            if (currentEvent != 'RunContent' && currentEvent != 'TeamRunContent') {
              continue;
            }

            try {
              final json = jsonDecode(data);
              // AgentOS sends events with 'content' field
              if (json is Map && json['content'] != null) {
                final fullContent = json['content'].toString();

                // Deduplication: only yield new content (like agent-ui does)
                if (fullContent.isNotEmpty && fullContent != lastContent) {
                  // Remove overlap with previous content
                  final uniqueContent = fullContent.replaceFirst(lastContent, '');
                  if (uniqueContent.isNotEmpty) {
                    yield uniqueContent;
                  }
                  lastContent = fullContent; // Update tracker
                }
              }
            } catch (e) {
              // If not JSON, skip
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error streaming response: $e');
    }
  }

  /// Get list of available agents
  Future<List<String>> getAgents() async {
    final url = Uri.parse('$baseUrl/agents');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> agents = jsonDecode(response.body);
        return agents.map((agent) => agent['name'] as String).toList();
      } else {
        throw Exception('Failed to load agents');
      }
    } catch (e) {
      throw Exception('Error fetching agents: $e');
    }
  }

  /// Get list of available models from AgentOS /config endpoint
  /// Following AgentOS native available_models pattern
  Future<List<String>> getAvailableModels() async {
    final url = Uri.parse('$baseUrl/config');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> config = jsonDecode(response.body);
        final List<dynamic>? models = config['available_models'];
        if (models != null) {
          return models.map((model) => model as String).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load config');
      }
    } catch (e) {
      throw Exception('Error fetching available models: $e');
    }
  }
}
