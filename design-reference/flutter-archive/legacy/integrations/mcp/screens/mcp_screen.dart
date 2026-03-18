// MCP Screen - Tactical Design
// Model Context Protocol server management with tactical UI
// Features: Server list, connection management, tool discovery

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import '../providers/mcp_provider.dart';
import '../widgets/mcp_preset_selector.dart';

class MCPScreen extends ConsumerStatefulWidget {
  const MCPScreen({super.key});

  @override
  ConsumerState<MCPScreen> createState() => _MCPScreenState();
}

class _MCPScreenState extends ConsumerState<MCPScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<McpServer> _filterServers(List<McpServer> servers) {
    if (_searchQuery.isEmpty) return servers;
    return servers
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mcpState = ref.watch(mcpProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('MCP SERVERS', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(mcpProvider.notifier).loadServers(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: TacticalColors.primary),
            onPressed: () => _showAddServerDialog(context),
            tooltip: 'Add Server',
          ),
        ],
      ),
      body: mcpState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TacticalColors.primary),
            )
          : mcpState.error != null && mcpState.servers.isEmpty
              ? _buildErrorState(context, mcpState.error!)
              : _buildContent(context, mcpState),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TacticalColors.critical.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'ERROR LOADING SERVERS',
            style: TextStyle(
              color: TacticalColors.critical,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TacticalColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TacticalButton(
            label: 'RETRY',
            icon: Icons.refresh,
            onTap: () => ref.read(mcpProvider.notifier).loadServers(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, McpState state) {
    final filteredServers = _filterServers(state.servers);

    if (state.servers.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        _SearchBar(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),

        // Preset selector
        const McpPresetSelector(),
        const SizedBox(height: 16),

        // Stats card
        _StatsCard(state: state),
        const SizedBox(height: 24),

        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SERVERS',
              style: TextStyle(
                color: TacticalColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${filteredServers.length} of ${state.servers.length}',
              style: const TextStyle(
                color: TacticalColors.textDim,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Server list
        if (filteredServers.isEmpty && _searchQuery.isNotEmpty)
          _buildNoResultsState()
        else
          ...filteredServers.map(
            (server) => _McpServerCard(
              server: server,
              onConnect: () => ref.read(mcpProvider.notifier).connectServer(server.id),
              onDisconnect: () => ref.read(mcpProvider.notifier).disconnectServer(server.id),
              onDelete: () => _confirmDelete(context, server),
              onViewDetails: () => _showServerDetails(context, server),
              onTest: () => _testConnection(context, server.id),
              isTesting: state.isTesting,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO MCP SERVERS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a server to extend agent capabilities',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TacticalButton(
            label: 'ADD SERVER',
            icon: Icons.add,
            onTap: () => _showAddServerDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No servers matching "$_searchQuery"',
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddServerDialog(
        onAdd: (server) {
          ref.read(mcpProvider.notifier).addServer(server);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added server "${server.name}"'),
              backgroundColor: TacticalColors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, McpServer server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: TacticalColors.border),
        ),
        title: const Text(
          'DELETE SERVER',
          style: TextStyle(
            color: TacticalColors.critical,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${server.name}"?',
          style: TextStyle(
            color: TacticalColors.textMuted.withValues(alpha: 0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: TacticalColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(mcpProvider.notifier).removeServer(server.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${server.name}"'),
                  backgroundColor: TacticalColors.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: TacticalColors.critical),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(BuildContext context, String serverId) async {
    final notifier = ref.read(mcpProvider.notifier);
    final result = await notifier.testConnection(serverId);

    if (context.mounted) {
      final success = result != null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? TacticalColors.operational : TacticalColors.critical,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'Connection successful${result['tools'] != null ? ' - ${(result['tools'] as List).length} tools available' : ''}'
                      : 'Connection failed',
                  style: const TextStyle(color: TacticalColors.textPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: TacticalColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showServerDetails(BuildContext context, McpServer server) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ServerDetailsSheet(
          server: server,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// =============================================================================
// SEARCH BAR
// =============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: TacticalColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search servers...',
        hintStyle: TextStyle(
          color: TacticalColors.textMuted.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.search, color: TacticalColors.textDim),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: TacticalColors.textDim),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: TacticalColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.primary),
        ),
      ),
    );
  }
}

// =============================================================================
// STATS CARD
// =============================================================================

class _StatsCard extends StatelessWidget {
  final McpState state;

  const _StatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('SERVERS', state.servers.length.toString(), TacticalColors.textMuted),
          _buildStatItem('CONNECTED', state.connectedServers.length.toString(), TacticalColors.operational),
          _buildStatItem('TOOLS', state.totalTools.toString(), TacticalColors.primary),
          _buildStatItem('RESOURCES', state.totalResources.toString(), TacticalColors.complete),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MCP SERVER CARD
// =============================================================================

class _McpServerCard extends StatelessWidget {
  final McpServer server;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback? onTest;
  final bool isTesting;

  const _McpServerCard({
    required this.server,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    required this.onViewDetails,
    this.onTest,
    this.isTesting = false,
  });

  IconData get _transportIcon {
    switch (server.transport) {
      case 'sse':
        return Icons.cloud;
      case 'stdio':
      default:
        return Icons.terminal;
    }
  }

  Color get _statusColor {
    switch (server.status) {
      case McpServerStatus.connected:
        return TacticalColors.operational;
      case McpServerStatus.connecting:
        return TacticalColors.inProgress;
      case McpServerStatus.error:
        return TacticalColors.critical;
      case McpServerStatus.disconnected:
      default:
        return TacticalColors.textDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnecting = server.status == McpServerStatus.connecting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TacticalDecoration.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Server icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _transportIcon,
                        color: _statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Server info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  server.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TacticalColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _StatusBadge(status: server.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _TransportBadge(transport: server.transport),
                              const SizedBox(width: 8),
                              _ToolCountBadge(count: server.tools.length),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Connection info
                if (server.command != null || server.url != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TacticalColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: TacticalColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          server.transport == 'sse' ? Icons.link : Icons.code,
                          size: 14,
                          color: TacticalColors.textDim,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            server.transport == 'sse'
                                ? server.url ?? ''
                                : '${server.command} ${server.args?.join(' ') ?? ''}',
                            style: const TextStyle(
                              color: TacticalColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Connect/Disconnect toggle
                    Expanded(
                      child: server.status == McpServerStatus.connected
                          ? _buildActionButton(
                              label: 'DISCONNECT',
                              icon: Icons.link_off,
                              color: TacticalColors.inProgress,
                              onTap: isConnecting ? null : onDisconnect,
                              outlined: true,
                            )
                          : _buildActionButton(
                              label: isConnecting ? 'CONNECTING...' : 'CONNECT',
                              icon: isConnecting ? null : Icons.link,
                              color: TacticalColors.operational,
                              onTap: isConnecting ? null : onConnect,
                              isLoading: isConnecting,
                            ),
                    ),
                    const SizedBox(width: 8),
                    // Test connection button
                    if (onTest != null)
                      Container(
                        decoration: BoxDecoration(
                          color: TacticalColors.complete.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TacticalColors.complete.withValues(alpha: 0.3),
                          ),
                        ),
                        child: IconButton(
                          onPressed: isTesting ? null : onTest,
                          icon: isTesting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TacticalColors.complete,
                                  ),
                                )
                              : const Icon(
                                  Icons.network_check,
                                  color: TacticalColors.complete,
                                  size: 20,
                                ),
                          tooltip: 'Test Connection',
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Delete button
                    Container(
                      decoration: BoxDecoration(
                        color: TacticalColors.critical.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: TacticalColors.critical.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: TacticalColors.critical,
                          size: 20,
                        ),
                        tooltip: 'Remove Server',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    IconData? icon,
    required Color color,
    VoidCallback? onTap,
    bool outlined = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _StatusBadge extends StatelessWidget {
  final McpServerStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case McpServerStatus.connected:
        return TacticalColors.operational;
      case McpServerStatus.connecting:
        return TacticalColors.inProgress;
      case McpServerStatus.error:
        return TacticalColors.critical;
      case McpServerStatus.disconnected:
      default:
        return TacticalColors.textDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRANSPORT BADGE
// =============================================================================

class _TransportBadge extends StatelessWidget {
  final String transport;

  const _TransportBadge({required this.transport});

  @override
  Widget build(BuildContext context) {
    final isSSE = transport.toLowerCase() == 'sse';
    final color = isSSE ? TacticalColors.complete : TacticalColors.inProgress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        transport.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// =============================================================================
// TOOL COUNT BADGE
// =============================================================================

class _ToolCountBadge extends StatelessWidget {
  final int count;

  const _ToolCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: TacticalColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.build, size: 10, color: TacticalColors.primary),
          const SizedBox(width: 4),
          Text(
            '$count tools',
            style: const TextStyle(
              color: TacticalColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SERVER DETAILS SHEET
// =============================================================================

class _ServerDetailsSheet extends StatelessWidget {
  final McpServer server;
  final ScrollController scrollController;

  const _ServerDetailsSheet({
    required this.server,
    required this.scrollController,
  });

  Color get _statusColor {
    switch (server.status) {
      case McpServerStatus.connected:
        return TacticalColors.operational;
      case McpServerStatus.connecting:
        return TacticalColors.inProgress;
      case McpServerStatus.error:
        return TacticalColors.critical;
      case McpServerStatus.disconnected:
      default:
        return TacticalColors.textDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: TacticalColors.border),
          left: BorderSide(color: TacticalColors.border),
          right: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TacticalColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.hub,
                    color: _statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              server.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TacticalColors.textPrimary,
                              ),
                            ),
                          ),
                          _StatusBadge(status: server.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _TransportBadge(transport: server.transport),
                          const SizedBox(width: 8),
                          _ToolCountBadge(count: server.tools.length),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Connection details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TacticalColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONNECTION',
                    style: TextStyle(
                      color: TacticalColors.textDim,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (server.transport == 'sse' && server.url != null)
                    Text(
                      server.url!,
                      style: const TextStyle(
                        color: TacticalColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    )
                  else if (server.command != null)
                    Text(
                      '${server.command} ${server.args?.join(' ') ?? ''}',
                      style: const TextStyle(
                        color: TacticalColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: TacticalColors.border, height: 1),
          // Tools header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'AVAILABLE TOOLS',
                  style: TextStyle(
                    color: TacticalColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${server.tools.length}',
                  style: const TextStyle(
                    color: TacticalColors.textDim,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Tools list
          Expanded(
            child: server.tools.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_outlined,
                          size: 48,
                          color: TacticalColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'NO TOOLS AVAILABLE',
                          style: TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect the server to discover tools',
                          style: TextStyle(
                            color: TacticalColors.textMuted.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: server.tools.length,
                    itemBuilder: (context, index) => _ToolCard(
                      tool: server.tools[index],
                      index: index + 1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TOOL CARD
// =============================================================================

class _ToolCard extends StatelessWidget {
  final McpTool tool;
  final int index;

  const _ToolCard({required this.tool, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TacticalColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: TacticalColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    style: const TextStyle(
                      color: TacticalColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.description,
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: TacticalColors.textDim,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ADD SERVER DIALOG
// =============================================================================

class _AddServerDialog extends StatefulWidget {
  final Function(McpServer) onAdd;

  const _AddServerDialog({required this.onAdd});

  @override
  State<_AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<_AddServerDialog> {
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  final _urlController = TextEditingController();
  final _argsController = TextEditingController();
  String _transport = 'stdio';

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _urlController.dispose();
    _argsController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_nameController.text.isEmpty) return false;
    if (_transport == 'stdio' && _commandController.text.isEmpty) return false;
    if (_transport == 'sse' && _urlController.text.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TacticalColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TacticalColors.border),
      ),
      title: const Text(
        'ADD MCP SERVER',
        style: TextStyle(
          color: TacticalColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            _buildTextField(
              controller: _nameController,
              label: 'Server Name *',
              hint: 'e.g., Filesystem',
            ),
            const SizedBox(height: 16),

            // Transport dropdown
            const Text(
              'TRANSPORT TYPE',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: TacticalColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _transport,
                  dropdownColor: TacticalColors.surface,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  style: const TextStyle(color: TacticalColors.textPrimary),
                  items: [
                    DropdownMenuItem(
                      value: 'stdio',
                      child: Row(
                        children: [
                          Icon(Icons.terminal, size: 18, color: TacticalColors.inProgress),
                          const SizedBox(width: 8),
                          const Text('stdio (Local Process)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'sse',
                      child: Row(
                        children: [
                          Icon(Icons.cloud, size: 18, color: TacticalColors.complete),
                          const SizedBox(width: 8),
                          const Text('sse (Server-Sent Events)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _transport = value!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transport-specific fields
            if (_transport == 'stdio') ...[
              _buildTextField(
                controller: _commandController,
                label: 'Command *',
                hint: 'e.g., npx',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _argsController,
                label: 'Arguments',
                hint: 'e.g., -y @modelcontextprotocol/server-filesystem /tmp',
              ),
            ] else ...[
              _buildTextField(
                controller: _urlController,
                label: 'URL *',
                hint: 'e.g., https://mcp.example.com/sse',
              ),
            ],

            const SizedBox(height: 16),

            // Hint box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TacticalColors.inProgress.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TacticalColors.inProgress.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: TacticalColors.inProgress,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Popular: Filesystem, GitHub, Brave Search, Slack',
                      style: TextStyle(
                        color: TacticalColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: TacticalColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _isValid ? _addServer : null,
          child: Text(
            'ADD',
            style: TextStyle(
              color: _isValid ? TacticalColors.primary : TacticalColors.textDim,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: TacticalColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: TacticalColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TacticalColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _addServer() {
    final server = McpServer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      transport: _transport,
      command: _transport == 'stdio' ? _commandController.text : null,
      args: _transport == 'stdio' && _argsController.text.isNotEmpty
          ? _argsController.text.split(' ')
          : null,
      url: _transport == 'sse' ? _urlController.text : null,
      status: McpServerStatus.disconnected,
    );
    widget.onAdd(server);
    Navigator.pop(context);
  }
}
