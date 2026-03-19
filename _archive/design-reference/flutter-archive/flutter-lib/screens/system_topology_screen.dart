import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../config/tactical_theme.dart';

/// System Topology Screen — Visual Tech Stack Dashboard
/// =====================================================
/// Interactive visualization of every technology, protocol,
/// framework, and service in OneMind OS organized by layer.
///
/// Shows: real-time status, connections, health %, layer grouping,
/// searchable/filterable, with color-coded status indicators.

class SystemTopologyScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SystemTopologyScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SystemTopologyScreen> createState() =>
      _SystemTopologyScreenState();
}

class _SystemTopologyScreenState extends ConsumerState<SystemTopologyScreen>
    with TickerProviderStateMixin {
  final String baseUrl = Environment.apiBaseUrl;

  // State
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _topology;
  String _searchQuery = '';
  String? _selectedLayer;
  String? _selectedNodeId;

  // Auto-refresh
  Timer? _refreshTimer;
  late AnimationController _pulseController;

  // Layer colors (matching backend LAYER_COLORS)
  static const Map<String, Color> _layerColors = {
    'frontend': Color(0xFF1a237e),
    'api': Color(0xFF1b5e20),
    'realtime': Color(0xFFb71c1c),
    'ai': Color(0xFF4a148c),
    'media': Color(0xFFe65100),
    'connectivity': Color(0xFF006064),
    'data': Color(0xFF263238),
    'physical': Color(0xFF3e2723),
    'services': Color(0xFF0d47a1),
  };

  static const Map<String, IconData> _layerIcons = {
    'frontend': Icons.monitor,
    'api': Icons.electrical_services,
    'realtime': Icons.flash_on,
    'ai': Icons.psychology,
    'media': Icons.videocam,
    'connectivity': Icons.wifi,
    'data': Icons.storage,
    'physical': Icons.precision_manufacturing,
    'services': Icons.layers,
  };

  static const Map<String, String> _layerLabels = {
    'frontend': 'Frontend',
    'api': 'API',
    'realtime': 'Real-Time',
    'ai': 'AI',
    'media': 'Media / Stream',
    'connectivity': 'Connectivity',
    'data': 'Data',
    'physical': 'Physical',
    'services': 'Services',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _loadTopology();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _loadTopology());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTopology() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/topology/'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _topology = json.decode(response.body);
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server returned ${response.statusCode}';
            _isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: widget.embedded ? null : _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildTopologyView(),
    );
  }

  // ─── App Bar ────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    final total = _topology?['total_technologies'] ?? 0;
    final online = _topology?['total_online'] ?? 0;

    return AppBar(
      backgroundColor: TacticalColors.surface,
      title: Row(
        children: [
          Icon(Icons.hub, color: TacticalColors.cyan, size: 22),
          const SizedBox(width: 10),
          const Text('System Topology',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          if (!_isLoading && _topology != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TacticalColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$online / $total online',
                style: TextStyle(
                  fontSize: 12,
                  color: TacticalColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      actions: [
        // Search
        SizedBox(
          width: 200,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search tech...',
              hintStyle: TextStyle(
                  color: TacticalColors.textMuted, fontSize: 13),
              prefixIcon: Icon(Icons.search,
                  color: TacticalColors.textMuted, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(
                color: TacticalColors.textPrimary, fontSize: 13),
          ),
        ),
        // Refresh button
        IconButton(
          icon: Icon(Icons.refresh, color: TacticalColors.textSecondary),
          onPressed: _loadTopology,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Error View ─────────────────────────────────────────

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
          const SizedBox(height: 16),
          Text('Failed to load topology',
              style: TextStyle(
                  color: TacticalColors.textPrimary, fontSize: 18)),
          const SizedBox(height: 8),
          Text(_error ?? '',
              style: TextStyle(
                  color: TacticalColors.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTopology,
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─── Main Topology View ─────────────────────────────────

  Widget _buildTopologyView() {
    final nodes = _topology?['nodes'] as List<dynamic>? ?? [];
    final layers = _topology?['layers'] as Map<String, dynamic>? ?? {};

    // Filter nodes
    List<dynamic> filteredNodes = nodes;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredNodes = nodes.where((n) {
        final name = (n['name'] ?? '').toString().toLowerCase();
        final desc = (n['description'] ?? '').toString().toLowerCase();
        final tags = (n['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();
        final proto = (n['protocol'] ?? '').toString().toLowerCase();
        return name.contains(q) || desc.contains(q) || tags.contains(q) || proto.contains(q);
      }).toList();
    }
    if (_selectedLayer != null) {
      filteredNodes =
          filteredNodes.where((n) => n['layer'] == _selectedLayer).toList();
    }

    return Column(
      children: [
        // Layer filter chips
        _buildLayerChips(layers),
        // Summary bar
        _buildSummaryBar(),
        // Main content
        Expanded(
          child: _selectedNodeId != null
              ? _buildNodeDetail(_selectedNodeId!)
              : _buildLayeredGrid(filteredNodes, layers),
        ),
      ],
    );
  }

  // ─── Layer Filter Chips ─────────────────────────────────

  Widget _buildLayerChips(Map<String, dynamic> layers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(
            bottom: BorderSide(color: TacticalColors.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // "All" chip
            _filterChip('All', null, Icons.grid_view),
            const SizedBox(width: 8),
            ...layers.entries.map((entry) {
              final layerKey = entry.key;
              final layerData = entry.value as Map<String, dynamic>;
              final count = layerData['count'] ?? 0;
              final online = layerData['online'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _filterChip(
                  '${_layerLabels[layerKey] ?? layerKey} ($online/$count)',
                  layerKey,
                  _layerIcons[layerKey] ?? Icons.circle,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? layerKey, IconData icon) {
    final isSelected = _selectedLayer == layerKey;
    final chipColor = layerKey != null
        ? _layerColors[layerKey] ?? TacticalColors.primary
        : TacticalColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isSelected ? Colors.white : TacticalColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? Colors.white : TacticalColors.textSecondary,
              )),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedLayer = isSelected ? null : layerKey;
          _selectedNodeId = null;
        });
      },
      backgroundColor: TacticalColors.card,
      selectedColor: chipColor.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? chipColor
              : TacticalColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  // ─── Summary Bar ────────────────────────────────────────

  Widget _buildSummaryBar() {
    final nodes = _topology?['nodes'] as List<dynamic>? ?? [];
    final onlineCount =
        nodes.where((n) => n['status'] == 'online').length;
    final degradedCount =
        nodes.where((n) => n['status'] == 'degraded').length;
    final offlineCount =
        nodes.where((n) => n['status'] == 'offline').length;
    final notConfigured =
        nodes.where((n) => n['status'] == 'not_configured').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: TacticalColors.surface.withValues(alpha: 0.5),
      child: Row(
        children: [
          _statusBadge('Online', onlineCount, TacticalColors.success),
          const SizedBox(width: 16),
          _statusBadge('Degraded', degradedCount, TacticalColors.warning),
          const SizedBox(width: 16),
          _statusBadge('Offline', offlineCount, TacticalColors.error),
          const SizedBox(width: 16),
          _statusBadge('Not Configured', notConfigured, TacticalColors.inactive),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + 0.5 * _pulseController.value,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: TacticalColors.success),
                    const SizedBox(width: 6),
                    Text('LIVE',
                        style: TextStyle(
                          fontSize: 11,
                          color: TacticalColors.success,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text('$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            )),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 12,
            )),
      ],
    );
  }

  // ─── Layered Grid ───────────────────────────────────────

  Widget _buildLayeredGrid(
      List<dynamic> nodes, Map<String, dynamic> layers) {
    // Group nodes by layer
    final Map<String, List<dynamic>> grouped = {};
    for (final node in nodes) {
      final layer = node['layer'] as String? ?? 'unknown';
      grouped.putIfAbsent(layer, () => []).add(node);
    }

    // Display order
    const layerOrder = [
      'frontend',
      'api',
      'realtime',
      'ai',
      'media',
      'connectivity',
      'data',
      'physical',
      'services',
    ];

    final orderedLayers = layerOrder.where((l) => grouped.containsKey(l)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderedLayers.length,
      itemBuilder: (context, index) {
        final layerKey = orderedLayers[index];
        final layerNodes = grouped[layerKey] ?? [];
        return _buildLayerSection(layerKey, layerNodes);
      },
    );
  }

  Widget _buildLayerSection(String layerKey, List<dynamic> nodes) {
    final color = _layerColors[layerKey] ?? TacticalColors.primary;
    final icon = _layerIcons[layerKey] ?? Icons.circle;
    final label = _layerLabels[layerKey] ?? layerKey;
    final onlineCount =
        nodes.where((n) => n['status'] == 'online').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layer header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                      color: TacticalColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$onlineCount / ${nodes.length}',
                    style: TextStyle(
                        color: color, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Technology cards grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: nodes.map((node) => _buildTechCard(node, color)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tech Card ──────────────────────────────────────────

  Widget _buildTechCard(Map<String, dynamic> node, Color layerColor) {
    final name = node['name'] ?? '';
    final status = node['status'] ?? 'not_configured';
    final protocol = node['protocol'] ?? '';
    final port = node['port'] ?? 0;
    final tags = (node['tags'] as List<dynamic>? ?? []);
    final nodeId = node['id'] ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'online':
        statusColor = TacticalColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'degraded':
        statusColor = TacticalColors.warning;
        statusIcon = Icons.warning_rounded;
        break;
      case 'offline':
        statusColor = TacticalColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = TacticalColors.inactive;
        statusIcon = Icons.help_outline;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedNodeId = nodeId),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TacticalColors.elevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + status dot
            Row(
              children: [
                Expanded(
                  child: Text(name,
                      style: TextStyle(
                        color: TacticalColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
                Icon(statusIcon, size: 14, color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            // Protocol + port line
            if (protocol.isNotEmpty || port > 0)
              Row(
                children: [
                  if (protocol.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: layerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(protocol.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            color: layerColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                    ),
                  if (port > 0) ...[
                    const SizedBox(width: 6),
                    Text(':$port',
                        style: TextStyle(
                          fontSize: 10,
                          color: TacticalColors.textDim,
                          fontFamily: 'monospace',
                        )),
                  ],
                ],
              ),
            const SizedBox(height: 6),
            // Tags
            if (tags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: tags.take(3).map((tag) {
                  return Text('#$tag',
                      style: TextStyle(
                        fontSize: 9,
                        color: TacticalColors.textDim,
                      ));
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Node Detail Panel ──────────────────────────────────

  Widget _buildNodeDetail(String nodeId) {
    final nodes = _topology?['nodes'] as List<dynamic>? ?? [];
    final node = nodes.firstWhere((n) => n['id'] == nodeId,
        orElse: () => <String, dynamic>{});
    if (node.isEmpty) {
      return const Center(child: Text('Node not found'));
    }

    final name = node['name'] ?? '';
    final desc = node['description'] ?? '';
    final status = node['status'] ?? 'unknown';
    final layer = node['layer'] ?? '';
    final protocol = node['protocol'] ?? '';
    final port = node['port'] ?? 0;
    final host = node['host'] ?? '';
    final url = node['url'] ?? '';
    final connectsTo = (node['connects_to'] as List<dynamic>?)?.cast<String>() ?? [];
    final dependsOn = (node['depends_on'] as List<dynamic>?)?.cast<String>() ?? [];
    final metrics = node['metrics'] as Map<String, dynamic>? ?? {};
    final tags = (node['tags'] as List<dynamic>? ?? []).cast<String>();
    final docsUrl = node['docs_url'] ?? '';
    final lastCheck = node['last_check'] ?? '';
    final lastError = node['last_error'] ?? '';

    Color statusColor;
    switch (status) {
      case 'online':
        statusColor = TacticalColors.success;
        break;
      case 'degraded':
        statusColor = TacticalColors.warning;
        break;
      case 'offline':
        statusColor = TacticalColors.error;
        break;
      default:
        statusColor = TacticalColors.inactive;
    }

    final layerColor = _layerColors[layer] ?? TacticalColors.primary;

    return Column(
      children: [
        // Back button bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: TacticalColors.surface,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: TacticalColors.textSecondary),
                onPressed: () => setState(() => _selectedNodeId = null),
              ),
              const SizedBox(width: 8),
              Text(name,
                  style: TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    )),
              ),
            ],
          ),
        ),
        // Detail content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TacticalColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: layerColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(desc,
                          style: TextStyle(
                            color: TacticalColors.textSecondary,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: layerColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('#$t',
                              style: TextStyle(
                                  fontSize: 11, color: layerColor)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Connection info
                _detailSection('Connection Info', [
                  if (protocol.isNotEmpty) _detailRow('Protocol', protocol.toUpperCase()),
                  if (host.isNotEmpty) _detailRow('Host', host),
                  if (port > 0) _detailRow('Port', port.toString()),
                  if (url.isNotEmpty) _detailRow('URL', url),
                  _detailRow('Layer', _layerLabels[layer] ?? layer),
                  if (lastCheck.isNotEmpty) _detailRow('Last Check', _formatTime(lastCheck)),
                  if (lastError.isNotEmpty) _detailRow('Last Error', lastError),
                ]),

                const SizedBox(height: 16),

                // Metrics
                if (metrics.isNotEmpty)
                  _detailSection('Live Metrics',
                      metrics.entries.map((e) => _detailRow(e.key, e.value.toString())).toList()),

                if (metrics.isNotEmpty) const SizedBox(height: 16),

                // Connections
                if (connectsTo.isNotEmpty)
                  _detailSection(
                    'Connects To (→)',
                    connectsTo
                        .map((id) => _connectionChip(id, TacticalColors.cyan))
                        .toList(),
                    isWrap: true,
                  ),

                if (connectsTo.isNotEmpty) const SizedBox(height: 16),

                // Dependencies
                if (dependsOn.isNotEmpty)
                  _detailSection(
                    'Depends On (←)',
                    dependsOn
                        .map((id) => _connectionChip(id, TacticalColors.warning))
                        .toList(),
                    isWrap: true,
                  ),

                if (docsUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Documentation: $docsUrl',
                      style: TextStyle(
                        color: TacticalColors.cyan,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      )),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailSection(String title, List<Widget> children,
      {bool isWrap = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                color: TacticalColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
          const SizedBox(height: 10),
          if (isWrap)
            Wrap(spacing: 8, runSpacing: 8, children: children)
          else
            ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                )),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                )),
          ),
        ],
      ),
    );
  }

  Widget _connectionChip(String nodeId, Color color) {
    // Find node name from topology
    final nodes = _topology?['nodes'] as List<dynamic>? ?? [];
    final node = nodes.firstWhere((n) => n['id'] == nodeId,
        orElse: () => <String, dynamic>{});
    final name = node.isNotEmpty ? (node['name'] ?? nodeId) : nodeId;
    final status = node.isNotEmpty ? (node['status'] ?? '') : '';

    Color dotColor;
    switch (status) {
      case 'online':
        dotColor = TacticalColors.success;
        break;
      case 'degraded':
        dotColor = TacticalColors.warning;
        break;
      case 'offline':
        dotColor = TacticalColors.error;
        break;
      default:
        dotColor = TacticalColors.inactive;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedNodeId = nodeId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(name,
                style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (e) {
      return iso;
    }
  }
}
