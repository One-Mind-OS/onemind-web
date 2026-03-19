import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'mcp_screen.dart';
import 'capabilities_screen.dart';

/// Tools Hub Screen - Tabs: Tools | MCP Servers | Capabilities
class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  List<Map<String, dynamic>> _tools = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    setState(() => _loading = true);
    try {
      final tools = await ApiService.listTools();
      if (mounted) {
        setState(() {
          _tools = tools;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tools: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentGreen = const Color(0xFF4ADE80);
    final bgColor = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF0F5F0);
    final surfaceColor = isDark ? const Color(0xFF0F1A0F) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          title: Text(
            'TOOLS & CAPABILITIES',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          bottom: TabBar(
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textColor.withValues(alpha: 0.4),
            labelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1.5,
            ),
            tabs: const [
              Tab(text: 'TOOLS'),
              Tab(text: 'MCP SERVERS'),
              Tab(text: 'CAPABILITIES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildToolsTab(accentGreen),
            const McpScreen(embedded: true),
            const CapabilitiesScreen(embedded: true),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab(Color accentGreen) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: accentGreen));
    }
    if (_tools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_outlined, size: 64, color: accentGreen.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No tools registered',
              style: TextStyle(
                color: accentGreen.withValues(alpha: 0.5),
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        // Refresh bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: accentGreen),
                onPressed: _loadTools,
                tooltip: 'Refresh tools',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tools.length,
            itemBuilder: (ctx, i) {
              final tool = _tools[i];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.build, color: accentGreen),
                  title: Text(tool['name'] ?? 'Unknown Tool'),
                  subtitle: Text(tool['description'] ?? ''),
                  trailing: Switch(
                    value: tool['enabled'] ?? true,
                    onChanged: (val) {},
                    activeThumbColor: accentGreen,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
