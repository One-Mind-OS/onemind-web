import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/agent_model.dart';
import '../models/team_model.dart';
import '../models/model_info.dart';
import '../models/memory_model.dart';
import '../models/knowledge_model.dart';
import '../models/session_model.dart';
import '../models/workflow_model.dart';
import '../models/approval_model.dart';
import '../models/run_model.dart';
import '../models/evaluation_model.dart';
import '../config/environment.dart';
import 'cache_service.dart';

/// HTTP Method enum for generic request method
enum _HttpMethod { get, post, put, patch, delete }

class ApiService {
  static String get baseUrl => Environment.apiBaseUrl;

  // Request timeout configuration
  static const Duration _requestTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int _maxRetries = 3;

  // Request deduplication - Cache of in-flight requests
  static final Map<String, Future<dynamic>> _pendingRequests = {};

  /// HTTP caching wrapper for GET requests
  ///
  /// Checks cache first, returns cached data if available and not expired.
  /// Otherwise makes the request and caches the result with appropriate TTL.
  static Future<T> _withCache<T>(String key, Future<T> Function() request) async {
    // Try to get from cache first
    final cached = CacheService.get<T>(key);
    if (cached != null) {
      debugPrint('💾 Cache hit: $key');
      return cached;
    }

    // Cache miss - make the request
    debugPrint('📡 Cache miss: $key');
    final result = await request();

    // Cache the result with appropriate TTL
    final ttl = CacheService.getCacheDuration(key);
    CacheService.set(key, result, ttl);

    return result;
  }

  /// Request deduplication wrapper
  ///
  /// Prevents duplicate simultaneous requests to the same endpoint.
  /// If a request is already in progress, returns the existing Future instead of
  /// making a new request.
  ///
  /// Example: If listAgents() is called 3 times simultaneously, only 1 actual
  /// HTTP request is made, and all 3 callers receive the same response.
  static Future<T> _deduplicate<T>(String key, Future<T> Function() request) async {
    // If request is already in progress, return the existing Future
    if (_pendingRequests.containsKey(key)) {
      debugPrint('🔄 Deduplicating request: $key');
      return _pendingRequests[key] as Future<T>;
    }

    // Start new request and cache it
    final future = request();
    _pendingRequests[key] = future;

    // Clean up after completion (success or failure)
    future.whenComplete(() {
      _pendingRequests.remove(key);
    });

    return future;
  }

  /// Retry wrapper with exponential backoff
  ///
  /// Retries failed requests up to [_maxRetries] times with exponential backoff:
  /// - Attempt 1: immediate
  /// - Attempt 2: 1 second delay
  /// - Attempt 3: 2 seconds delay
  /// - Attempt 4: 4 seconds delay
  static Future<T> _withRetry<T>(
    Future<T> Function() request, {
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          // Max retries exceeded, rethrow the exception
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: math.pow(2, attempts - 1).toInt());
        debugPrint('⚠️ Request failed (attempt $attempts/$maxRetries): $e');
        debugPrint('⏳ Retrying after ${delay.inSeconds}s delay...');

        await Future.delayed(delay);
      }
    }
    // This should never be reached due to rethrow, but required by analyzer
    throw Exception('Max retries exceeded');
  }

  /// Generic timeout wrapper for all HTTP methods
  ///
  /// Replaces 5 duplicate timeout wrappers with a single implementation.
  /// Handles GET, POST, PUT, PATCH, DELETE with proper timeout handling.
  static Future<http.Response> _requestWithTimeout(
    _HttpMethod method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    Future<http.Response> request;

    switch (method) {
      case _HttpMethod.get:
        request = http.get(uri, headers: headers);
        break;
      case _HttpMethod.post:
        request = http.post(uri, headers: headers, body: body);
        break;
      case _HttpMethod.put:
        request = http.put(uri, headers: headers, body: body);
        break;
      case _HttpMethod.patch:
        request = http.patch(uri, headers: headers, body: body);
        break;
      case _HttpMethod.delete:
        request = http.delete(uri, headers: headers, body: body);
        break;
    }

    return request.timeout(
      _requestTimeout,
      onTimeout: () => throw TimeoutException(
        'Request timed out after ${_requestTimeout.inSeconds} seconds',
        _requestTimeout,
      ),
    );
  }

  // Backward compatibility wrappers (to be removed gradually)
  static Future<http.Response> _getWithTimeout(Uri uri, {Map<String, String>? headers}) =>
      _requestWithTimeout(_HttpMethod.get, uri, headers: headers);

  static Future<http.Response> _postWithTimeout(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _requestWithTimeout(_HttpMethod.post, uri, headers: headers, body: body);

  static Future<http.Response> _putWithTimeout(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _requestWithTimeout(_HttpMethod.put, uri, headers: headers, body: body);

  static Future<http.Response> _patchWithTimeout(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _requestWithTimeout(_HttpMethod.patch, uri, headers: headers, body: body);

  static Future<http.Response> _deleteWithTimeout(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _requestWithTimeout(_HttpMethod.delete, uri, headers: headers, body: body);

  /// Generic API request method - replaces 65+ repetitive methods
  ///
  /// Combines all request patterns: cache, deduplication, retry, timeout
  /// into a single reusable method. Use this for all new API methods.
  ///
  /// Example usage:
  /// ```dart
  /// static Future<List<AgentModel>> listAgents() => _makeRequest(
  ///   method: _HttpMethod.get,
  ///   endpoint: '/agents',
  ///   parser: (data) => (data as List).map((e) => AgentModel.fromJson(e)).toList(),
  ///   useCache: true,
  ///   useDedupe: true,
  /// );
  /// ```
  static Future<T> _makeRequest<T>({
    required _HttpMethod method,
    required String endpoint,
    required T Function(dynamic) parser,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool useCache = false,
    bool useDedupe = true,
    bool useRetry = true,
    int maxRetries = _maxRetries,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final cacheKey = '${method.name.toUpperCase()}:$endpoint';

    // Build the base request
    Future<T> makeHttpRequest() async {
      final requestBody = body != null ? json.encode(body) : null;
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await _requestWithTimeout(
        method,
        uri,
        headers: requestHeaders,
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return parser(responseData);
      } else {
        throw Exception('Request failed (${response.statusCode}): ${response.body}');
      }
    }

    // Apply wrappers in order: retry -> dedupe -> cache
    Future<T> request = makeHttpRequest();

    if (useRetry) {
      request = _withRetry(() => makeHttpRequest(), maxRetries: maxRetries);
    }

    if (useDedupe) {
      request = _deduplicate(cacheKey, () => request);
    }

    if (useCache && method == _HttpMethod.get) {
      request = _withCache(cacheKey, () => request);
    }

    return request;
  }

  // =============================================================================
  // Agent APIs (Using AgentOS Native Endpoints)
  // =============================================================================

  /// List all agents (AgentOS native endpoint)
  static Future<List<AgentModel>> listAgents() async {
    return _withCache('GET:/agents', () {
      return _deduplicate('GET:/agents', () {
        return _withRetry(() async {
          final response = await _getWithTimeout(Uri.parse('$baseUrl/agents'));

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            return data.map((json) => AgentModel.fromJson(json)).toList();
          } else {
            throw Exception('Failed to load agents: ${response.body}');
          }
        });
      });
    });
  }

  /// Get specific agent (AgentOS native endpoint)
  static Future<AgentModel> getAgent(String agentId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId'),
      );

      if (response.statusCode == 200) {
        return AgentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load agent: ${response.body}');
      }
    });
  }

  /// Create new agent (AgentOS native endpoint)
  static Future<AgentModel> createAgent(AgentModel agent) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/agents'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agent.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AgentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create agent: ${response.body}');
      }
    });
  }

  /// Update existing agent (AgentOS native endpoint)
  static Future<AgentModel> updateAgent(String agentId, AgentModel agent) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agent.toJson()),
      );

      if (response.statusCode == 200) {
        return AgentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update agent: ${response.body}');
      }
    });
  }

  /// Delete agent (AgentOS native endpoint)
  static Future<void> deleteAgent(String agentId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete agent: ${response.body}');
      }
    });
  }

  /// Reload agent configurations (not applicable to AgentOS native)
  static Future<Map<String, dynamic>> reloadAgentConfigs() async {
    // AgentOS manages agent lifecycle automatically
    return {'status': 'ok', 'message': 'AgentOS handles agent reloading automatically'};
  }

  // =============================================================================
  // Agent Execution APIs (AgentOS native endpoints)
  // =============================================================================

  /// Execute an agent with a message
  static Future<AgentRunModel> runAgent(
    String agentId, {
    required String message,
    String? sessionId,
    bool stream = false,
  }) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId/runs'),
        body: json.encode({
          'message': message,
          'session_id': ?sessionId,
          'stream': stream,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AgentRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to run agent: ${response.body}');
      }
    });
  }

  /// Execute an agent with a message and file attachments
  static Future<AgentRunModel> runAgentWithFiles(
    String agentId, {
    required String message,
    List<Map<String, dynamic>>? files,
    String? sessionId,
  }) async {
    return _withRetry(() async {
      final uri = Uri.parse('$baseUrl/agents/$agentId/runs');
      final request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['message'] = message;
      if (sessionId != null) {
        request.fields['session_id'] = sessionId;
      }

      // Add files
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          final bytes = file['bytes'] as List<int>;
          final fileName = file['name'] as String;
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              bytes,
              filename: fileName,
            ),
          );
        }
      }

      try {
        final streamedResponse = await request.send().timeout(_requestTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return AgentRunModel.fromJson(json.decode(response.body));
        } else {
          throw Exception('Failed to run agent with files: ${response.body}');
        }
      } catch (e) {
        throw Exception('Failed to run agent with files: $e');
      }
    });
  }

  /// Cancel a running agent execution
  static Future<void> cancelAgentRun(String agentId, String runId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId/runs/$runId/cancel'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel agent run: ${response.body}');
      }
    });
  }

  /// Continue a paused agent run (HITL - Human-in-the-Loop)
  static Future<void> continueAgentRun(
    String agentId,
    String runId, {
    bool approved = true,
    Map<String, dynamic>? input,
  }) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/agents/$agentId/runs/$runId/continue'),
        body: json.encode({
          'approved': approved,
          'input': ?input,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to continue agent run: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Team Configuration APIs
  // =============================================================================

  /// List all team configurations
  static Future<List<TeamModel>> listTeams() async {
    return _withCache('GET:/teams', () {
      return _deduplicate('GET:/teams', () {
        return _withRetry(() async {
          final response = await _getWithTimeout(Uri.parse('$baseUrl/teams'));

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            return data.map((json) => TeamModel.fromJson(json)).toList();
          } else {
            throw Exception('Failed to load teams: ${response.body}');
          }
        });
      });
    });
  }

  /// Get specific team configuration
  static Future<TeamModel> getTeam(String teamId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/teams/$teamId'),
      );

      if (response.statusCode == 200) {
        return TeamModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load team: ${response.body}');
      }
    });
  }

  /// Create new team configuration
  static Future<TeamModel> createTeam(TeamModel team) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/teams'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(team.toJson()),
      );

      if (response.statusCode == 201) {
        return TeamModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create team: ${response.body}');
      }
    });
  }

  /// Update existing team configuration
  static Future<TeamModel> updateTeam(String teamId, TeamModel team) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(team.toJson()),
      );

      if (response.statusCode == 200) {
        return TeamModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update team: ${response.body}');
      }
    });
  }

  /// Delete team configuration
  static Future<void> deleteTeam(String teamId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/teams/$teamId'),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete team: ${response.body}');
      }
    });
  }

  /// Reload team configurations (hot-reload)
  static Future<Map<String, dynamic>> reloadTeamConfigs() async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/teams/reload'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to reload team configs: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Team Execution APIs (AgentOS native endpoints)
  // =============================================================================

  /// Execute a team with a message
  static Future<TeamRunModel> runTeam(
    String teamId, {
    required String message,
    String? sessionId,
    bool stream = false,
  }) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/teams/$teamId/runs'),
        body: json.encode({
          'message': message,
          'session_id': ?sessionId,
          'stream': stream,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TeamRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to run team: ${response.body}');
      }
    });
  }

  /// Cancel a running team execution
  static Future<void> cancelTeamRun(String teamId, String runId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/teams/$teamId/runs/$runId/cancel'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel team run: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Tool Registry APIs
  // =============================================================================

  // =============================================================================
  // Tools APIs - REMOVED
  // =============================================================================
  // AgentOS does not expose /tools endpoint publicly.
  // Tools are pre-configured per agent and not exposed via REST API.
  // Tool information is available only through agent definitions.

  // =============================================================================
  // Model Registry APIs (AgentOS Native Endpoints)
  // =============================================================================

  /// List all available models (AgentOS native endpoint)
  static Future<List<ModelInfo>> listModels({String? provider}) async {
    final key = provider != null ? 'GET:/models?provider=$provider' : 'GET:/models';
    return _withCache(key, () {
      return _deduplicate(key, () {
        return _withRetry(() async {
          final uri = provider != null
              ? Uri.parse('$baseUrl/models?provider=$provider')
              : Uri.parse('$baseUrl/models');

          final response = await _getWithTimeout(uri);

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            return data.map((json) => ModelInfo.fromJson(json)).toList();
          } else {
            throw Exception('Failed to load models: ${response.body}');
          }
        });
      });
    });
  }

  /// List model providers (derived from models list)
  static Future<List<Map<String, dynamic>>> listProviders() async {
    // Agent OS doesn't have /models/providers, derive from models list
    final models = await listModels();
    final Set<String> providers = {};

    for (var model in models) {
      providers.add(model.provider);
        }

    return providers.map((p) => {'name': p}).toList();
  }

  /// Get specific model details (AgentOS native endpoint)
  static Future<ModelInfo> getModel(String modelId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/models/$modelId'),
      );

      if (response.statusCode == 200) {
        return ModelInfo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load model: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Memory Management APIs
  // =============================================================================

  /// List all memories or filter by agent_id
  static Future<List<MemoryModel>> listMemories({String? agentId}) async {
    return _withRetry(() async {
      final uri = agentId != null
          ? Uri.parse('$baseUrl/memories?agent_id=$agentId')
          : Uri.parse('$baseUrl/memories');

      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'] as List<dynamic>;
        return data.map((json) => MemoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load memories: ${response.body}');
      }
    });
  }

  /// Get specific memory
  static Future<MemoryModel> getMemory(String memoryId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/memories/$memoryId'),
      );

      if (response.statusCode == 200) {
        return MemoryModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load memory: ${response.body}');
      }
    });
  }

  /// Create new memory
  static Future<MemoryModel> createMemory(MemoryModel memory) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/memories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(memory.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MemoryModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create memory: ${response.body}');
      }
    });
  }

  /// Delete memory
  static Future<void> deleteMemory(String memoryId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/memories/$memoryId'),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete memory: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Knowledge Base APIs
  // =============================================================================

  /// List all knowledge bases
  static Future<List<KnowledgeBaseModel>> listKnowledgeBases({String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/knowledge/content?db_id=$dbId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => KnowledgeBaseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load knowledge bases: ${response.body}');
      }
    });
  }

  /// Get specific knowledge base
  static Future<KnowledgeBaseModel> getKnowledgeBase(String kbId, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$kbId?db_id=$dbId'),
      );

      if (response.statusCode == 200) {
        return KnowledgeBaseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load knowledge base: ${response.body}');
      }
    });
  }

  /// Create new knowledge base
  static Future<KnowledgeBaseModel> createKnowledgeBase(KnowledgeBaseModel kb, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/knowledge/content?db_id=$dbId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(kb.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return KnowledgeBaseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create knowledge base: ${response.body}');
      }
    });
  }

  /// Update existing knowledge base
  static Future<KnowledgeBaseModel> updateKnowledgeBase(String kbId, KnowledgeBaseModel kb, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$kbId?db_id=$dbId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(kb.toJson()),
      );

      if (response.statusCode == 200) {
        return KnowledgeBaseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update knowledge base: ${response.body}');
      }
    });
  }

  /// Delete knowledge base
  static Future<void> deleteKnowledgeBase(String kbId, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$kbId?db_id=$dbId'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete knowledge base: ${response.body}');
      }
    });
  }

  // Note: AgentOS knowledge endpoints don't have document sub-resources
  // Documents are managed as part of the knowledge content object

  // =============================================================================
  // Session Management APIs
  // =============================================================================

  /// List all session summaries, optionally filtered by agent_id
  static Future<List<SessionModel>> listSessions({String? agentId}) async {
    return _withRetry(() async {
      final uri = agentId != null
          ? Uri.parse('$baseUrl/sessions?agent_id=$agentId')
          : Uri.parse('$baseUrl/sessions');

      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'] as List<dynamic>;
        return data.map((json) => SessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sessions: ${response.body}');
      }
    });
  }

  /// Get specific session summary by session_id
  static Future<SessionModel> getSession(String sessionId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/sessions/$sessionId'),
      );

      if (response.statusCode == 200) {
        return SessionModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load session: ${response.body}');
      }
    });
  }

  /// Delete session summary
  static Future<void> deleteSession(String sessionId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/sessions/$sessionId'),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete session: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Workflow APIs (Agno-Native)
  // =============================================================================

  /// Base URL for Agno workflow API
  static const String _workflowApiBase = '/api/agno-workflows';

  /// List all workflows
  static Future<List<WorkflowModel>> listWorkflows({int limit = 100, int offset = 0}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkflowModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workflows: ${response.body}');
      }
    });
  }

  /// Get specific workflow by ID (includes full definition)
  static Future<WorkflowModel> getWorkflow(String workflowId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/$workflowId'),
      );

      if (response.statusCode == 200) {
        return WorkflowModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load workflow: ${response.body}');
      }
    });
  }

  /// Create new workflow
  static Future<WorkflowModel> createWorkflow(WorkflowModel workflow) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(workflow.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WorkflowModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create workflow: ${response.body}');
      }
    });
  }

  /// Update existing workflow
  static Future<WorkflowModel> updateWorkflow(String workflowId, WorkflowModel workflow) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/$workflowId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(workflow.toJson()),
      );

      if (response.statusCode == 200) {
        return WorkflowModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update workflow: ${response.body}');
      }
    });
  }

  /// Delete workflow
  static Future<void> deleteWorkflow(String workflowId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/$workflowId'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete workflow: ${response.body}');
      }
    });
  }

  /// Run workflow (non-streaming)
  static Future<WorkflowRunModel> runWorkflow(String workflowId, {dynamic input, String? sessionId}) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/$workflowId/run'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'input': input,
          'session_id': sessionId,
          'stream': false,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WorkflowRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to run workflow: ${response.body}');
      }
    });
  }

  /// Get workflow run history
  static Future<List<WorkflowRunModel>> getWorkflowRuns(String workflowId, {int limit = 50}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/$workflowId/runs?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkflowRunModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workflow runs: ${response.body}');
      }
    });
  }

  /// Get available node types for workflow builder
  static Future<List<NodeTypeInfo>> getWorkflowNodeTypes() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl$_workflowApiBase/node-types'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NodeTypeInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load node types: ${response.body}');
      }
    });
  }

  /// Cancel a running workflow execution (legacy support)
  static Future<void> cancelWorkflowRun(String workflowId, String runId) async {
    // Note: Agno workflows don't have a cancel endpoint yet
    // This is kept for backwards compatibility
    return;
  }

  // =============================================================================
  // Approval APIs (AgentOS Native HITL)
  // =============================================================================

  /// List all approval requests
  static Future<List<ApprovalRequest>> listApprovals() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(Uri.parse('$baseUrl/api/approvals'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ApprovalRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load approval requests: ${response.body}');
      }
    });
  }

  /// Approve an approval request
  static Future<void> approveRequest(String requestId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/approvals/$requestId/approve'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to approve request: ${response.body}');
      }
    });
  }

  /// Reject an approval request
  static Future<void> rejectRequest(String requestId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/approvals/$requestId/reject'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to reject request: ${response.body}');
      }
    });
  }

  /// List all paused runs
  static Future<List<PausedRun>> listPausedRuns() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(Uri.parse('$baseUrl/api/approvals/paused-runs'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PausedRun.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load paused runs: ${response.body}');
      }
    });
  }

  /// Continue a paused run
  static Future<void> continueRun(String runId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/approvals/paused-runs/$runId/continue'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to continue run: ${response.body}');
      }
    });
  }

  /// Cancel a paused run
  static Future<void> cancelRun(String runId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/approvals/paused-runs/$runId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel run: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Evaluation APIs (AgentOS Native)
  // =============================================================================

  /// List all evaluation runs
  static Future<List<EvaluationRunModel>> listEvaluations() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(Uri.parse('$baseUrl/eval-runs'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data is List ? data : data['data'] ?? data;
        return items.map((json) => EvaluationRunModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load evaluations: ${response.body}');
      }
    });
  }

  /// Get specific evaluation run
  static Future<EvaluationRunModel> getEvaluation(String evalId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/eval-runs/$evalId'),
      );

      if (response.statusCode == 200) {
        return EvaluationRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load evaluation: ${response.body}');
      }
    });
  }

  /// Create new evaluation run
  static Future<EvaluationRunModel> createEvaluation(
      EvaluationRunModel eval) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/eval-runs'),
        body: json.encode(eval.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EvaluationRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create evaluation: ${response.body}');
      }
    });
  }

  /// Update evaluation run
  static Future<EvaluationRunModel> updateEvaluation(
    String evalId,
    EvaluationRunModel eval,
  ) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/eval-runs/$evalId'),
        body: json.encode(eval.toJson()),
      );

      if (response.statusCode == 200) {
        return EvaluationRunModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update evaluation: ${response.body}');
      }
    });
  }

  /// Batch delete evaluations
  static Future<void> deleteEvaluations(List<String> evalIds) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/eval-runs'),
        body: json.encode({'ids': evalIds}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete evaluations: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Session Advanced APIs (AgentOS Native)
  // =============================================================================

  /// Get session run history
  static Future<List<AgentRunModel>> getSessionRuns(String sessionId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/sessions/$sessionId/runs'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data is List ? data : data['data'] ?? data;
        return items.map((json) => AgentRunModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load session runs: ${response.body}');
      }
    });
  }

  /// Rename session
  static Future<void> renameSession(String sessionId, String newName) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/sessions/$sessionId/rename'),
        body: json.encode({'name': newName}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rename session: ${response.body}');
      }
    });
  }

  /// Batch delete sessions
  static Future<void> batchDeleteSessions(List<String> sessionIds) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/sessions'),
        body: json.encode({'ids': sessionIds}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to batch delete sessions: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Memory Advanced APIs (AgentOS Native)
  // =============================================================================

  /// Get memory topics
  static Future<List<String>> getMemoryTopics() async {
    return _withRetry(() async {
      final response =
          await _getWithTimeout(Uri.parse('$baseUrl/memory_topics'));

      if (response.statusCode == 200) {
        final List<dynamic> topics = json.decode(response.body);
        return topics.map((t) => t.toString()).toList();
      } else {
        throw Exception('Failed to load memory topics: ${response.body}');
      }
    });
  }

  /// Get user memory statistics
  static Future<Map<String, dynamic>> getUserMemoryStats() async {
    return _withRetry(() async {
      final response =
          await _getWithTimeout(Uri.parse('$baseUrl/user_memory_stats'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load memory stats: ${response.body}');
      }
    });
  }

  /// Update memory
  static Future<void> updateMemory(String memoryId, MemoryModel memory) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/memories/$memoryId'),
        body: json.encode(memory.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update memory: ${response.body}');
      }
    });
  }

  /// Batch delete memories
  static Future<void> batchDeleteMemories(List<String> memoryIds) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/memories'),
        body: json.encode({'ids': memoryIds}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to batch delete memories: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Knowledge Base Document Management APIs (AgentOS Native)
  // =============================================================================

  /// Upload document to knowledge base
  static Future<DocumentModel> uploadDocument({
    required String kbId,
    required List<int> fileBytes,
    required String fileName,
    String dbId = 'default',
  }) async {
    final uri = Uri.parse('$baseUrl/knowledge/content?db_id=$dbId');
    final request = http.MultipartRequest('POST', uri);

    // Add file
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    // Add KB ID as form field
    request.fields['kb_id'] = kbId;

    try {
      final streamedResponse = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DocumentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to upload document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Get document indexing status
  static Future<Map<String, dynamic>> getDocumentStatus(String contentId, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$contentId/status?db_id=$dbId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get document status: ${response.body}');
      }
    });
  }

  /// Update document metadata
  static Future<void> updateKnowledgeDocument(
    String contentId,
    Map<String, dynamic> updates, {
    String dbId = 'default',
  }) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$contentId?db_id=$dbId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update document: ${response.body}');
      }
    });
  }

  /// Delete document from knowledge base
  static Future<void> deleteKnowledgeDocument(String contentId, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/knowledge/content/$contentId?db_id=$dbId'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete document: ${response.body}');
      }
    });
  }

  /// Batch delete documents
  static Future<void> batchDeleteDocuments(List<String> contentIds, {String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/knowledge/content?db_id=$dbId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': contentIds}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to batch delete documents: ${response.body}');
      }
    });
  }

  /// Get knowledge base configuration
  static Future<Map<String, dynamic>> getKnowledgeConfig({String dbId = 'default'}) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/knowledge/config?db_id=$dbId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get knowledge config: ${response.body}');
      }
    });
  }

  // =============================================================================
  // System Configuration APIs (AgentOS Native)
  // =============================================================================

  /// Get system configuration
  static Future<Map<String, dynamic>> getSystemConfig() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(Uri.parse('$baseUrl/config'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get config: ${response.body}');
      }
    });
  }

  /// Get system metrics
  static Future<Map<String, dynamic>> getSystemMetrics() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(Uri.parse('$baseUrl/metrics'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get metrics: ${response.body}');
      }
    });
  }

  /// Refresh metrics
  static Future<void> refreshMetrics() async {
    return _withRetry(() async {
      final response =
          await _postWithTimeout(Uri.parse('$baseUrl/metrics/refresh'));

      if (response.statusCode != 200) {
        throw Exception('Failed to refresh metrics: ${response.body}');
      }
    });
  }

  /// Get agent registry (system monitoring)
  static Future<Map<String, dynamic>> getAgentRegistry() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/system/agents'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get agent registry: ${response.body}');
      }
    });
  }

  /// Get agent learning metrics (for Digital Cortex)
  static Future<Map<String, dynamic>> getAgentLearningMetrics() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/agents/learning'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get agent learning metrics: ${response.body}');
      }
    });
  }

  /// Get NATS bus status (system monitoring)
  static Future<Map<String, dynamic>> getNatsBusStatus() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/system/bus'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get NATS bus status: ${response.body}');
      }
    });
  }

  // =============================================================================
  // MCP (Model Context Protocol) APIs
  // =============================================================================

  /// List all MCP servers
  static Future<Map<String, dynamic>> listMcpServers() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/mcp/servers'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to list MCP servers: ${response.body}');
      }
    });
  }

  /// Connect to an MCP server
  static Future<Map<String, dynamic>> connectMcpServer(String serverId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/mcp/servers/$serverId/connect'),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to connect MCP server: ${response.body}');
      }
    });
  }

  /// Disconnect from an MCP server
  static Future<Map<String, dynamic>> disconnectMcpServer(String serverId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/mcp/servers/$serverId/disconnect'),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to disconnect MCP server: ${response.body}');
      }
    });
  }

  /// Test MCP server connection
  static Future<Map<String, dynamic>> testMcpServer(String serverId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/mcp/servers/$serverId/test'),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to test MCP server: ${response.body}');
      }
    });
  }

  /// Get MCP presets
  static Future<Map<String, dynamic>> getMcpPresets() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/mcp/presets'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get MCP presets: ${response.body}');
      }
    });
  }

  /// Apply an MCP preset
  static Future<Map<String, dynamic>> applyMcpPreset(String preset) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/mcp/presets/$preset/apply'),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to apply MCP preset: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Event APIs
  // =============================================================================

  /// List system events with optional filtering
  static Future<List<Map<String, dynamic>>> listEvents({
    String? source,
    int? priority,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (source != null) queryParams['source'] = source;
      if (priority != null) queryParams['priority'] = priority.toString();
      
      final uri = Uri.parse('$baseUrl/api/events').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle both old format (list) and new format ({events: [...]})
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['events'] != null) {
          return (data['events'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    });
  }

  /// Get event statistics
  static Future<Map<String, dynamic>> getEventStats() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/events/stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load event stats: ${response.body}');
      }
    });
  }

  /// Mark events as processed (bulk operation)
  static Future<void> markEventsProcessed(List<String> eventIds) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/events/mark-processed'),
        body: {'event_ids': eventIds},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark events as processed: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Task APIs
  // =============================================================================

  /// List all tasks
  static Future<List<Map<String, dynamic>>> listTasks({
    String? status,
    String? priority,
    String? assigneeId,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (assigneeId != null) queryParams['assignee_id'] = assigneeId;

      final uri = Uri.parse('$baseUrl/api/tasks').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['tasks'] != null) {
          return (data['tasks'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load tasks: ${response.body}');
      }
    });
  }

  /// Get specific task
  static Future<Map<String, dynamic>> getTask(String taskId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load task: ${response.body}');
      }
    });
  }

  /// Create new task
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    });
  }

  /// Update task
  static Future<Map<String, dynamic>> updateTask(String taskId, Map<String, dynamic> updates) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update task: ${response.body}');
      }
    });
  }

  /// Delete task
  static Future<void> deleteTask(String taskId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/tasks/$taskId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Projects APIs
  // =============================================================================

  /// List all projects
  static Future<List<Map<String, dynamic>>> listProjects({
    String? status,
    String? ownerId,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (ownerId != null) queryParams['owner_id'] = ownerId;

      final uri = Uri.parse('$baseUrl/api/projects').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['projects'] != null) {
          return (data['projects'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load projects: ${response.body}');
      }
    });
  }

  /// Get specific project
  static Future<Map<String, dynamic>> getProject(String projectId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/projects/$projectId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load project: ${response.body}');
      }
    });
  }

  /// Create new project
  static Future<Map<String, dynamic>> createProject(Map<String, dynamic> project) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/projects'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(project),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create project: ${response.body}');
      }
    });
  }

  /// Update project
  static Future<Map<String, dynamic>> updateProject(String projectId, Map<String, dynamic> updates) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/api/projects/$projectId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update project: ${response.body}');
      }
    });
  }

  /// Delete project
  static Future<void> deleteProject(String projectId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/projects/$projectId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete project: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Documents APIs
  // =============================================================================

  /// List all documents
  static Future<List<Map<String, dynamic>>> listDocuments({
    String? projectId,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (projectId != null) queryParams['project_id'] = projectId;

      final uri = Uri.parse('$baseUrl/api/documents').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['documents'] != null) {
          return (data['documents'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load documents: ${response.body}');
      }
    });
  }

  /// Get specific document
  static Future<Map<String, dynamic>> getDocument(String documentId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/documents/$documentId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load document: ${response.body}');
      }
    });
  }

  /// Create new document
  static Future<Map<String, dynamic>> createDocument(Map<String, dynamic> document) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/documents'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(document),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create document: ${response.body}');
      }
    });
  }

  /// Update document
  static Future<Map<String, dynamic>> updateDocument(String documentId, Map<String, dynamic> updates) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/api/documents/$documentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update document: ${response.body}');
      }
    });
  }

  /// Delete document
  static Future<void> deleteDocument(String documentId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/documents/$documentId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete document: ${response.body}');
      }
    });
  }

  /// Extract action items from document (AI)
  static Future<Map<String, dynamic>> extractDocumentActions(String documentId) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/documents/$documentId/ai/extract-actions'),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to extract actions: ${response.body}');
      }
    });
  }

  /// Summarize document (AI)
  static Future<Map<String, dynamic>> summarizeDocument(String documentId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/documents/$documentId/ai/summary'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to summarize document: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Calendar APIs
  // =============================================================================

  /// List all calendar events
  static Future<List<Map<String, dynamic>>> listCalendarEvents({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/api/calendar/events').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['events'] != null) {
          return (data['events'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load calendar events: ${response.body}');
      }
    });
  }

  /// Get specific calendar event
  static Future<Map<String, dynamic>> getCalendarEvent(String eventId) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/calendar/events/$eventId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load calendar event: ${response.body}');
      }
    });
  }

  /// Create new calendar event
  static Future<Map<String, dynamic>> createCalendarEvent(Map<String, dynamic> event) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/calendar/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create calendar event: ${response.body}');
      }
    });
  }

  /// Update calendar event
  static Future<Map<String, dynamic>> updateCalendarEvent(String eventId, Map<String, dynamic> updates) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/api/calendar/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update calendar event: ${response.body}');
      }
    });
  }

  /// Delete calendar event
  static Future<void> deleteCalendarEvent(String eventId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/calendar/events/$eventId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete calendar event: ${response.body}');
      }
    });
  }

  // Sheets APIs — REMOVED (see REFINEMENT_PLAN.md)

  // =============================================================================
  // Activity Feed APIs
  // =============================================================================

  /// Get activity feed
  static Future<List<Map<String, dynamic>>> getActivityFeed({
    String? category,
    String? severity,
    int limit = 50,
  }) async {
    return _withRetry(() async {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (category != null) queryParams['category'] = category;
      if (severity != null) queryParams['severity'] = severity;

      final uri = Uri.parse('$baseUrl/api/activity/feed').replace(queryParameters: queryParams);
      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data['activities'] != null) {
          return (data['activities'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load activity feed: ${response.body}');
      }
    });
  }

  /// Get activity statistics
  static Future<Map<String, dynamic>> getActivityStats() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/activity/stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load activity stats: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Analytics APIs
  // =============================================================================

  /// Get analytics overview
  static Future<Map<String, dynamic>> getAnalyticsOverview() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/metrics'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load analytics: ${response.body}');
      }
    });
  }

  // =============================================================================
  // NATS Control APIs
  // =============================================================================

  /// Get NATS switches
  static Future<Map<String, dynamic>> getNatsSwitches() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/nats-switch'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load NATS switches: ${response.body}');
      }
    });
  }

  /// Toggle NATS switch
  static Future<Map<String, dynamic>> toggleNatsSwitch(String switchId, bool enabled) async {
    return _withRetry(() async {
      final response = await _patchWithTimeout(
        Uri.parse('$baseUrl/api/nats-switch/$switchId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'enabled': enabled}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to toggle NATS switch: ${response.body}');
      }
    });
  }

  // =============================================================================
  // System & Settings APIs
  // =============================================================================

  /// Get system status
  static Future<Map<String, dynamic>> getSystemStatus() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/system/status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load system status: ${response.body}');
      }
    });
  }

  /// Get tools list (for tools screen)
  static Future<Map<String, dynamic>> getToolsList() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/tools'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load tools: ${response.body}');
      }
    });
  }

  // ============================================================================
  // Capabilities API
  // ============================================================================

  /// Get all capabilities with optional filtering
  static Future<Map<String, dynamic>> getCapabilities({
    String? domain,
    String? category,
    String? handlerType,
  }) async {
    return _withRetry(() async {
      final params = <String, String>{};
      if (domain != null) params['domain'] = domain;
      if (category != null) params['category'] = category;
      if (handlerType != null) params['handler_type'] = handlerType;

      final uri = Uri.parse('$baseUrl/api/capabilities').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );

      final response = await _getWithTimeout(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load capabilities: ${response.body}');
      }
    });
  }

  /// Get capabilities summary statistics
  static Future<Map<String, dynamic>> getCapabilitiesSummary() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/capabilities/summary'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load capabilities summary: ${response.body}');
      }
    });
  }

  /// Get single capability by name
  static Future<Map<String, dynamic>> getCapability(String name) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/capabilities/$name'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Capability not found: $name');
      } else {
        throw Exception('Failed to load capability: ${response.body}');
      }
    });
  }

  // =============================================================================
  // Integrations APIs
  // =============================================================================

  /// Get integration health status
  static Future<Map<String, dynamic>> getIntegrationsStatus() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/integrations/status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load integrations status: ${response.body}');
      }
    });
  }

  /// Refresh integration health status
  static Future<Map<String, dynamic>> refreshIntegrationsStatus() async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/integrations/refresh'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to refresh integrations: ${response.body}');
      }
    });
  }

  /// Get specific integration status
  static Future<Map<String, dynamic>> getIntegrationStatus(String integrationName) async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/integrations/$integrationName/status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Integration not found: $integrationName');
      } else {
        throw Exception('Failed to load integration status: ${response.body}');
      }
    });
  }

  // =============================================================================
  // API Keys Management (SECURITY-SENSITIVE)
  // =============================================================================

  /// List all API keys (returns masked keys only)
  static Future<List<Map<String, dynamic>>> listApiKeys() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/settings/keys'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load API keys: ${response.body}');
      }
    });
  }

  /// Create new API key (encrypts before storage)
  static Future<Map<String, dynamic>> createApiKey({
    required String name,
    required String key,
    String? description,
    String? icon,
    String? color,
  }) async {
    return _withRetry(() async {
      final response = await _postWithTimeout(
        Uri.parse('$baseUrl/api/settings/keys'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'key': key,
          'description': ?description,
          'icon': ?icon,
          'color': ?color,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create API key: ${response.body}');
      }
    });
  }

  /// Update API key metadata (not the key itself)
  static Future<Map<String, dynamic>> updateApiKey(
    String keyId,
    Map<String, dynamic> updates,
  ) async {
    return _withRetry(() async {
      final response = await _putWithTimeout(
        Uri.parse('$baseUrl/api/settings/keys/$keyId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update API key: ${response.body}');
      }
    });
  }

  /// Delete API key
  static Future<void> deleteApiKey(String keyId) async {
    return _withRetry(() async {
      final response = await _deleteWithTimeout(
        Uri.parse('$baseUrl/api/settings/keys/$keyId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete API key: ${response.body}');
      }
    });
  }

  /// Get API key statistics
  static Future<Map<String, dynamic>> getApiKeyStats() async {
    return _withRetry(() async {
      final response = await _getWithTimeout(
        Uri.parse('$baseUrl/api/settings/keys/stats/summary'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load API key stats: ${response.body}');
      }
    });
  }
  // =============================================================================
  // Analytics & Dashboard APIs
  // =============================================================================

  /// List activity feed events
  static Future<List<Map<String, dynamic>>> listActivityFeed({int limit = 20}) async {
    return _withCache('GET:/activity?limit=$limit', () {
      return _deduplicate('GET:/activity?limit=$limit', () {
        return _makeRequest(
          method: _HttpMethod.get,
          endpoint: '/activity?limit=$limit',
          parser: (data) => List<Map<String, dynamic>>.from(data),
          useCache: true,
        );
      });
    });
  }

  /// Alias for listActivityFeed (backward compatibility)
  static Future<List<Map<String, dynamic>>> getActivity({int limit = 20}) => listActivityFeed(limit: limit);

  /// Get system metrics
  static Future<Map<String, dynamic>> getMetrics() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/metrics',
      parser: (data) => data as Map<String, dynamic>,
      useCache: false, // Real-time data
    );
  }

  /// Get session list
  static Future<List<SessionModel>> getSessions({int limit = 20, int offset = 0}) async {
    return _withCache('GET:/sessions?limit=$limit&offset=$offset', () {
      return _makeRequest(
        method: _HttpMethod.get,
        endpoint: '/sessions?limit=$limit&offset=$offset',
        parser: (data) => (data as List).map((e) => SessionModel.fromJson(e)).toList(),
      );
    });
  }

  /// Alias for listMemories
  static Future<List<MemoryModel>> getMemories({String? agentId}) => listMemories(agentId: agentId);

  /// Alias for listKnowledgeBases
  static Future<List<KnowledgeBaseModel>> getKnowledgeContent({String dbId = 'default'}) => listKnowledgeBases(dbId: dbId);

  /// List digital assets
  static Future<List<Map<String, dynamic>>> listAssets({String? assetType, int? limit}) async {
    String endpoint = '/assets';
    final queryParams = <String>[];
    if (assetType != null) queryParams.add('type=$assetType');
    if (limit != null) queryParams.add('limit=$limit');
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: endpoint,
      parser: (data) => (data as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  /// Get system configuration/info
  static Future<Map<String, dynamic>> getSystemInfo() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/system/info',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get backend health status
  static Future<Map<String, dynamic>> getHealth() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/health',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get NATS/Switch configuration status
  static Future<Map<String, dynamic>> getNatsStatus() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/system/nats/status',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get detailed system bus metrics
  static Future<Map<String, dynamic>> getSystemBusStatus() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/system/bus/metrics',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Set global NATS publish state
  static Future<Map<String, dynamic>> setNatsGlobal(bool enabled) async {
    return _makeRequest(
      method: _HttpMethod.post,
      endpoint: '/system/nats/global',
      body: {'enabled': enabled},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// List all registered tools
  static Future<List<Map<String, dynamic>>> listTools() async {
    return _makeRequest(
      method: _HttpMethod.get,
      endpoint: '/tools',
      parser: (data) => (data as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }
}
