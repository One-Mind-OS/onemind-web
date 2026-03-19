import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/tactical_theme.dart';
import '../services/api_service.dart';

/// System Monitoring Screen
/// Provides detailed views of agent registry and NATS bus status
class SystemMonitoringScreen extends ConsumerStatefulWidget {
  const SystemMonitoringScreen({super.key});

  @override
  ConsumerState<SystemMonitoringScreen> createState() => _SystemMonitoringScreenState();
}

class _SystemMonitoringScreenState extends ConsumerState<SystemMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoadingAgents = true;
  bool _isLoadingBus = true;
  String? _agentsError;
  String? _busError;

  Map<String, dynamic>? _agentRegistry;
  Map<String, dynamic>? _busStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadAgents();
    _loadBus();
  }

  Future<void> _loadAgents() async {
    setState(() {
      _isLoadingAgents = true;
      _agentsError = null;
    });

    try {
      final data = await ApiService.getAgentRegistry();
      if (mounted) {
        setState(() {
          _agentRegistry = data;
          _isLoadingAgents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _agentsError = e.toString();
          _isLoadingAgents = false;
        });
      }
    }
  }

  Future<void> _loadBus() async {
    setState(() {
      _isLoadingBus = true;
      _busError = null;
    });

    try {
      final data = await ApiService.getNatsBusStatus();
      if (mounted) {
        setState(() {
          _busStatus = data;
          _isLoadingBus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busError = e.toString();
          _isLoadingBus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'SYSTEM MONITORING',
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'AGENT REGISTRY'),
            Tab(text: 'NATS BUS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAgentRegistryTab(),
          _buildNatsBusTab(),
        ],
      ),
    );
  }

  Widget _buildAgentRegistryTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    if (_isLoadingAgents) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_agentsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: TacticalColors.critical, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load agent registry',
              style: TextStyle(color: textPrimary),
            ),
            Text(
              _agentsError!,
              style: TextStyle(color: textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAgents,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_agentRegistry == null) {
      return Center(
        child: Text(
          'No agent registry data',
          style: TextStyle(color: textMuted),
        ),
      );
    }

    final presetAgents = _agentRegistry!['preset_agents'] as List? ?? [];
    final soulAgents = _agentRegistry!['soul_agents'] as List? ?? [];
    final total = _agentRegistry!['total'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _buildSummaryCard(
          'Total Agents',
          total.toString(),
          Icons.smart_toy,
          primaryColor,
        ),
        SizedBox(height: 16),

        // Preset agents section
        Text(
          'PRESET AGENTS (${presetAgents.length})',
          style: TextStyle(
            color: primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        ...presetAgents.map((agent) => _buildAgentCard(agent as Map<String, dynamic>)),

        if (soulAgents.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'SOUL AGENTS (${soulAgents.length})',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          ...soulAgents.map((agent) => _buildAgentCard(agent as Map<String, dynamic>)),
        ],
      ],
    );
  }

  Widget _buildNatsBusTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    if (_isLoadingBus) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_busError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: TacticalColors.critical, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load NATS bus status',
              style: TextStyle(color: textPrimary),
            ),
            Text(
              _busError!,
              style: TextStyle(color: textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBus,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_busStatus == null) {
      return Center(
        child: Text(
          'No bus status data',
          style: TextStyle(color: textMuted),
        ),
      );
    }

    final connected = _busStatus!['connected'] ?? false;
    final url = _busStatus!['url'] ?? 'Unknown';
    final stats = _busStatus!['stats'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection status
        _buildSummaryCard(
          'Connection',
          connected ? 'CONNECTED' : 'DISCONNECTED',
          Icons.cable,
          connected ? TacticalColors.success : TacticalColors.critical,
        ),
        SizedBox(height: 16),

        // URL
        _buildInfoCard('NATS URL', url),
        SizedBox(height: 16),

        // Statistics
        Text(
          'MESSAGE STATISTICS',
          style: TextStyle(
            color: primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        _buildStatCard(
          'Published',
          stats['messages_published']?.toString() ?? '0',
          Icons.publish,
        ),
        _buildStatCard(
          'Received',
          stats['messages_received']?.toString() ?? '0',
          Icons.download,
        ),
        _buildStatCard(
          'Reconnects',
          stats['reconnects']?.toString() ?? '0',
          Icons.sync,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.grey[500] : Colors.grey[600];

    final name = agent['name'] ?? 'Unknown';
    final modelId = agent['model_id'] ?? 'Unknown';
    final tools = agent['tools'] as List? ?? [];
    final memory = agent['memory'] as Map<String, dynamic>? ?? {};
    final reasoning = agent['reasoning'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and model
          Row(
            children: [
              Icon(Icons.smart_toy, color: primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Model: $modelId',
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),

          // Features
          if (memory.isNotEmpty || reasoning.isNotEmpty) ...[
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (memory['user_memories'] == true)
                  _buildFeatureBadge('User Memory', Icons.memory),
                if (memory['agentic_memory'] == true)
                  _buildFeatureBadge('Agentic Memory', Icons.psychology),
                if (reasoning['enabled'] == true)
                  _buildFeatureBadge('Reasoning', Icons.lightbulb_outline),
              ],
            ),
          ],

          // Tools
          if (tools.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              'Tools (${tools.length}):',
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tools.map((tool) => Chip(
                label: Text(
                  tool.toString(),
                  style: TextStyle(fontSize: 10),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 4),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? TacticalColors.primary : const Color(0xFF2563EB);
    final primaryMuted = isDark ? TacticalColors.primaryMuted : const Color(0xFFDEEBFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
