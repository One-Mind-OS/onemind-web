// MCP (Model Context Protocol) provider for MCP server management
// Updated: Agent 4 - OMOS Sprint - Added presets, CRUD, connection testing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/services/api_client.dart';
import '../../../platform/api/agno_client.dart';
import '../../../platform/providers/app_providers.dart';

/// MCP preset for quick server configuration
class McpPreset {
  final String name;
  final List<String> servers;
  final String description;

  const McpPreset({
    required this.name,
    required this.servers,
    this.description = '',
  });

  factory McpPreset.fromJson(Map<String, dynamic> json) {
    return McpPreset(
      name: json['name'] as String,
      servers: List<String>.from(json['servers'] ?? []),
      description: json['description'] as String? ?? '',
    );
  }

  IconData get icon {
    switch (name) {
      case 'basic':
        return Icons.folder_outlined;
      case 'web':
        return Icons.language;
      case 'dev':
        return Icons.code;
      case 'research':
        return Icons.search;
      case 'full':
        return Icons.all_inclusive;
      default:
        return Icons.extension;
    }
  }

  Color get color {
    switch (name) {
      case 'basic':
        return Colors.blue;
      case 'web':
        return Colors.purple;
      case 'dev':
        return Colors.green;
      case 'research':
        return Colors.orange;
      case 'full':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// MCP server status
enum McpServerStatus {
  connected('Connected', Colors.green),
  connecting('Connecting', Colors.orange),
  disconnected('Disconnected', Colors.grey),
  error('Error', Colors.red);

  final String label;
  final Color color;

  const McpServerStatus(this.label, this.color);
}

/// MCP tool
class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic>? inputSchema;

  const McpTool({
    required this.name,
    required this.description,
    this.inputSchema,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      inputSchema: json['input_schema'] as Map<String, dynamic>?,
    );
  }
}

/// MCP resource
class McpResource {
  final String uri;
  final String name;
  final String? description;
  final String? mimeType;

  const McpResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  factory McpResource.fromJson(Map<String, dynamic> json) {
    return McpResource(
      uri: json['uri'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mimeType: json['mime_type'] as String?,
    );
  }
}

/// MCP server model
class McpServer {
  final String id;
  final String name;
  final String transport; // stdio, sse
  final String? command;
  final List<String>? args;
  final String? url;
  final McpServerStatus status;
  final List<McpTool> tools;
  final List<McpResource> resources;
  final bool isEnabled;
  final DateTime? connectedAt;

  const McpServer({
    required this.id,
    required this.name,
    required this.transport,
    this.command,
    this.args,
    this.url,
    this.status = McpServerStatus.disconnected,
    this.tools = const [],
    this.resources = const [],
    this.isEnabled = true,
    this.connectedAt,
  });

  McpServer copyWith({
    String? id,
    String? name,
    String? transport,
    String? command,
    List<String>? args,
    String? url,
    McpServerStatus? status,
    List<McpTool>? tools,
    List<McpResource>? resources,
    bool? isEnabled,
    DateTime? connectedAt,
  }) {
    return McpServer(
      id: id ?? this.id,
      name: name ?? this.name,
      transport: transport ?? this.transport,
      command: command ?? this.command,
      args: args ?? this.args,
      url: url ?? this.url,
      status: status ?? this.status,
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      isEnabled: isEnabled ?? this.isEnabled,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  factory McpServer.fromJson(Map<String, dynamic> json) {
    return McpServer(
      id: json['id'] as String,
      name: json['name'] as String,
      transport: json['transport'] as String? ?? 'stdio',
      command: json['command'] as String?,
      args: (json['args'] as List<dynamic>?)?.cast<String>(),
      url: json['url'] as String?,
      status: McpServerStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => McpServerStatus.disconnected,
      ),
      tools: (json['tools'] as List<dynamic>?)
              ?.map((t) => McpTool.fromJson(t))
              .toList() ??
          [],
      resources: (json['resources'] as List<dynamic>?)
              ?.map((r) => McpResource.fromJson(r))
              .toList() ??
          [],
      isEnabled: json['is_enabled'] as bool? ?? true,
      connectedAt: json['connected_at'] != null
          ? DateTime.parse(json['connected_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transport': transport,
      'command': command,
      'args': args,
      'url': url,
      'status': status.name,
      'is_enabled': isEnabled,
      'connected_at': connectedAt?.toIso8601String(),
    };
  }
}

/// MCP state
class McpState {
  final List<McpServer> servers;
  final List<McpPreset> presets;
  final bool isLoading;
  final bool isApplyingPreset;
  final bool isTesting;
  final String? error;
  final McpServer? selectedServer;
  final String? testResult;

  const McpState({
    this.servers = const [],
    this.presets = const [],
    this.isLoading = false,
    this.isApplyingPreset = false,
    this.isTesting = false,
    this.error,
    this.selectedServer,
    this.testResult,
  });

  McpState copyWith({
    List<McpServer>? servers,
    List<McpPreset>? presets,
    bool? isLoading,
    bool? isApplyingPreset,
    bool? isTesting,
    String? error,
    McpServer? selectedServer,
    String? testResult,
    bool clearError = false,
    bool clearTestResult = false,
  }) {
    return McpState(
      servers: servers ?? this.servers,
      presets: presets ?? this.presets,
      isLoading: isLoading ?? this.isLoading,
      isApplyingPreset: isApplyingPreset ?? this.isApplyingPreset,
      isTesting: isTesting ?? this.isTesting,
      error: clearError ? null : (error ?? this.error),
      selectedServer: selectedServer ?? this.selectedServer,
      testResult: clearTestResult ? null : (testResult ?? this.testResult),
    );
  }

  List<McpServer> get connectedServers =>
      servers.where((s) => s.status == McpServerStatus.connected).toList();

  List<McpServer> get enabledServers =>
      servers.where((s) => s.isEnabled).toList();

  int get totalTools => servers.fold(0, (sum, s) => sum + s.tools.length);

  int get totalResources =>
      servers.fold(0, (sum, s) => sum + s.resources.length);
}

/// MCP notifier with backend integration
class McpNotifier extends StateNotifier<McpState> {
  final ApiClient _apiClient;
  final AgnoClient _agnoClient;

  McpNotifier(this._apiClient, this._agnoClient) : super(const McpState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadServers();
    await loadPresets();
  }

  Future<void> loadServers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiClient.get('/mcp/servers');
      final List<dynamic> data = response['servers'] ?? [];
      final servers = data.map((s) => McpServer.fromJson(s)).toList();

      state = state.copyWith(
        servers: servers,
        isLoading: false,
      );
    } catch (e) {
      // No mock fallback - show error state
      state = state.copyWith(
        servers: [],
        isLoading: false,
        error: 'Failed to load MCP servers: $e',
      );
    }
  }

  /// Load available MCP presets
  Future<void> loadPresets() async {
    try {
      final presetsData = await _agnoClient.getMCPPresets();
      final presets = presetsData.map((p) => McpPreset.fromJson(p)).toList();
      state = state.copyWith(presets: presets);
    } catch (e) {
      // Silently fail - presets are optional
    }
  }

  /// Apply an MCP preset to enable servers
  Future<bool> applyPreset(String presetName) async {
    state = state.copyWith(isApplyingPreset: true, clearError: true);

    try {
      final result = await _agnoClient.applyMCPPreset(presetName);
      if (result) {
        await loadServers(); // Reload to get updated status
        state = state.copyWith(isApplyingPreset: false);
        return true;
      }
      state = state.copyWith(
        isApplyingPreset: false,
        error: 'Failed to apply preset',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isApplyingPreset: false,
        error: 'Failed to apply preset: $e',
      );
      return false;
    }
  }

  void selectServer(McpServer? server) {
    state = state.copyWith(selectedServer: server);
  }

  Future<void> connectServer(String id) async {
    final updatedServers = state.servers.map((s) {
      if (s.id == id) {
        return s.copyWith(status: McpServerStatus.connecting);
      }
      return s;
    }).toList();

    state = state.copyWith(servers: updatedServers);

    try {
      await _apiClient.post('/mcp/servers/$id/connect', {});
      await loadServers(); // Reload to get updated status
    } catch (e) {
      // Revert to disconnected on error
      final revertedServers = state.servers.map((s) {
        if (s.id == id) {
          return s.copyWith(status: McpServerStatus.disconnected);
        }
        return s;
      }).toList();
      state = state.copyWith(
        servers: revertedServers,
        error: 'Failed to connect server: $e',
      );
    }
  }

  Future<void> disconnectServer(String id) async {
    try {
      await _apiClient.post('/mcp/servers/$id/disconnect', {});
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect server: $e');
      return;
    }

    final updatedServers = state.servers.map((s) {
      if (s.id == id) {
        return s.copyWith(
          status: McpServerStatus.disconnected,
          connectedAt: null,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(servers: updatedServers);
  }

  Future<void> toggleServer(String id) async {
    final updatedServers = state.servers.map((s) {
      if (s.id == id) {
        return s.copyWith(isEnabled: !s.isEnabled);
      }
      return s;
    }).toList();

    state = state.copyWith(servers: updatedServers);
  }

  /// Create a new MCP server via API
  Future<bool> createServer(McpServer server) async {
    try {
      final result = await _agnoClient.createMCPServer(server.toJson());
      if (result != null) {
        await loadServers(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create server: $e');
      return false;
    }
  }

  /// Update an existing MCP server via API
  Future<bool> updateServer(String id, McpServer server) async {
    try {
      final result = await _agnoClient.updateMCPServer(id, server.toJson());
      if (result) {
        await loadServers(); // Reload to get updated status
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update server: $e');
      return false;
    }
  }

  /// Delete an MCP server via API
  Future<bool> deleteServer(String id) async {
    try {
      final success = await _agnoClient.deleteMCPServer(id);
      if (success) {
        final updatedServers = state.servers.where((s) => s.id != id).toList();
        state = state.copyWith(servers: updatedServers);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete server: $e');
      return false;
    }
  }

  /// Test connection to an MCP server
  Future<Map<String, dynamic>?> testConnection(String serverId) async {
    state = state.copyWith(isTesting: true, clearTestResult: true, clearError: true);

    try {
      final result = await _agnoClient.testMCPConnection(serverId);
      state = state.copyWith(
        isTesting: false,
        testResult: result != null ? 'Connection successful' : 'Connection failed',
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        isTesting: false,
        error: 'Connection test failed: $e',
      );
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Legacy method - now calls createServer
  Future<void> addServer(McpServer server) async {
    await createServer(server);
  }

  /// Legacy method - now calls deleteServer
  Future<void> removeServer(String id) async {
    await deleteServer(id);
  }
}

/// Provider for MCP state
final mcpProvider = StateNotifierProvider<McpNotifier, McpState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final agnoClient = ref.watch(agnoClientProvider);
  return McpNotifier(apiClient, agnoClient);
});

/// Provider for connected servers
final connectedMcpServersProvider = Provider<List<McpServer>>((ref) {
  return ref.watch(mcpProvider).connectedServers;
});

/// Provider for total tools count
final mcpToolsCountProvider = Provider<int>((ref) {
  return ref.watch(mcpProvider).totalTools;
});

/// Provider for MCP presets
final mcpPresetsProvider = Provider<List<McpPreset>>((ref) {
  return ref.watch(mcpProvider).presets;
});

/// Provider for preset applying state
final mcpApplyingPresetProvider = Provider<bool>((ref) {
  return ref.watch(mcpProvider).isApplyingPreset;
});

/// Provider for connection testing state
final mcpTestingProvider = Provider<bool>((ref) {
  return ref.watch(mcpProvider).isTesting;
});
