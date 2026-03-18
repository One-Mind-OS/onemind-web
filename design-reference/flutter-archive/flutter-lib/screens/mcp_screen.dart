import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// MCP Screen - Model Context Protocol Servers
/// Manage connected MCP servers and their tools
/// Solar Punk Tactical Theme
class McpScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const McpScreen({super.key, this.embedded = false});

  @override
  ConsumerState<McpScreen> createState() => _McpScreenState();
}

class _McpScreenState extends ConsumerState<McpScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _servers = [];
  List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadServers();
    await _loadPresets();
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.listMcpServers();
      final servers = response['servers'] as List<dynamic>;

      if (mounted) {
        setState(() {
          _servers = servers.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPresets() async {
    try {
      final response = await ApiService.getMcpPresets();
      final presets = response['presets'] as List<dynamic>;

      if (mounted) {
        setState(() {
          _presets = presets.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      // Presets are optional, don't show error
    }
  }

  Future<void> _connectServer(String serverId) async {
    try {
      await ApiService.connectMcpServer(serverId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server connected successfully'),
            backgroundColor: Color(0xFF4ADE80),
          ),
        );
      }

      // Reload servers to get updated status
      _loadServers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnectServer(String serverId) async {
    try {
      await ApiService.disconnectMcpServer(serverId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server disconnected'),
            backgroundColor: Color(0xFFF97316),
          ),
        );
      }

      // Reload servers to get updated status
      _loadServers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testServer(String serverId) async {
    try {
      final result = await ApiService.testMcpServer(serverId);

      if (mounted) {
        final success = result['success'] ?? false;
        final toolCount = result['tool_count'] ?? 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Connection successful! Found $toolCount tools.'
                  : 'Connection failed: ${result['error']}',
            ),
            backgroundColor: success ? const Color(0xFF4ADE80) : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _applyPreset(String presetName) async {
    try {
      await ApiService.applyMcpPreset(presetName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied preset: $presetName'),
            backgroundColor: const Color(0xFF4ADE80),
          ),
        );
      }

      // Reload servers to get updated status
      _loadServers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply preset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddServerDialog() {
    // TODO: Implement add server dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add server dialog - coming soon'),
      ),
    );
  }

  void _showPresetsDialog() {
    if (_presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No presets available'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply MCP Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _presets.map((preset) {
            final name = preset['name'] ?? 'Unknown';
            final description = preset['description'] ?? '';
            final servers = preset['servers'] as List? ?? [];

            return ListTile(
              title: Text(name.toUpperCase()),
              subtitle: Text('$description\nServers: ${servers.join(', ')}'),
              onTap: () {
                Navigator.pop(ctx);
                _applyPreset(name);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF5F7F5);
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    if (_isLoading) {
      final loadingWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentGreen),
            const SizedBox(height: 16),
            Text('Loading MCP servers...', style: TextStyle(color: mutedText)),
          ],
        ),
      );
      if (widget.embedded) return loadingWidget;
      return Scaffold(backgroundColor: bg, body: loadingWidget);
    }

    if (_error != null) {
      final errorWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: accentOrange),
            const SizedBox(height: 16),
            Text('Error loading MCP servers', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: mutedText, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen),
            ),
          ],
        ),
      );
      if (widget.embedded) return errorWidget;
      return Scaffold(backgroundColor: bg, body: errorWidget);
    }

    final connectedCount = _servers.where((s) => s['status'] == 'connected').length;
    final totalTools = _servers.fold<int>(0, (sum, s) {
      final tools = s['tools'] as List?;
      return sum + (tools?.length ?? 0);
    });

    final body = Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentBlue, const Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: accentBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.hub, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MCP Servers', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Model Context Protocol integrations', style: TextStyle(color: mutedText, fontSize: 12)),
                  ],
                ),
              ),
              _statChip('$connectedCount', 'Connected', accentGreen),
              const SizedBox(width: 8),
              _statChip('$totalTools', 'Tools', accentOrange),
              const SizedBox(width: 12),
              if (_presets.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.bookmark_outline, color: accentBlue, size: 20),
                  onPressed: _showPresetsDialog,
                  tooltip: 'Apply Preset',
                ),
              IconButton(
                icon: Icon(Icons.refresh, color: accentGreen, size: 20),
                onPressed: _loadServers,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        // Servers List
        Expanded(
          child: _servers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hub_outlined, size: 64, color: mutedText.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No MCP servers configured',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a server to get started',
                        style: TextStyle(color: mutedText, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final server = _servers[index];
                    return _serverCard(server, cardBg, borderColor, accentGreen, accentOrange, textColor, mutedText);
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: bg,
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServerDialog,
        backgroundColor: accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Server', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _serverCard(Map<String, dynamic> server, Color cardBg, Color borderColor, Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    final serverId = server['id'] ?? '';
    final name = server['name'] ?? 'Unknown';
    final status = server['status'] ?? 'disconnected';
    final tools = server['tools'] as List? ?? [];
    final transport = server['transport'] ?? 'stdio';

    final statusColor = status == 'connected'
        ? accentGreen
        : status == 'connecting'
            ? accentOrange
            : status == 'error'
                ? Colors.red
                : mutedText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Icon(_getServerIcon(transport), color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(transport.toUpperCase(), style: TextStyle(color: mutedText, fontSize: 10, letterSpacing: 1)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
            ],
          ),

          // Tools list
          if (tools.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Tools (${tools.length}):', style: TextStyle(color: mutedText, fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tools.map((tool) {
                final toolName = tool is Map ? tool['name'] ?? 'Unknown' : tool.toString();
                return Chip(
                  label: Text(toolName, style: const TextStyle(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],

          // Action buttons
          const SizedBox(height: 12),
          Row(
            children: [
              if (status == 'disconnected')
                ElevatedButton.icon(
                  onPressed: () => _connectServer(serverId),
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Connect', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 32),
                  ),
                ),
              if (status == 'connected')
                ElevatedButton.icon(
                  onPressed: () => _disconnectServer(serverId),
                  icon: const Icon(Icons.link_off, size: 16),
                  label: const Text('Disconnect', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 32),
                  ),
                ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _testServer(serverId),
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('Test', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getServerIcon(String transport) {
    switch (transport.toLowerCase()) {
      case 'stdio':
        return Icons.terminal;
      case 'sse':
        return Icons.stream;
      case 'streamable-http':
        return Icons.http;
      default:
        return Icons.hub;
    }
  }
}
