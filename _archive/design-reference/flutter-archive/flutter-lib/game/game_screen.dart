import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/environment.dart';
import '../services/asset_service.dart';
import 'components/node_component.dart';
import 'systems/audio_system.dart';
import 'onemind_game.dart';

/// Live View Screen — Real-time System Visualization
/// ==================================================
/// Shows live assets, telemetry, alerts, and data flow through OneMind OS.
/// Connects to WebSocket for real-time updates.

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late OneMindGame _game;
  late AnimationController _panelController;
  late Animation<double> _panelAnimation;

  // Asset service for telemetry
  final AssetService _assetService = AssetService();
  StreamSubscription<AssetTelemetry>? _telemetrySub;
  StreamSubscription<AssetAlert>? _alertSub;

  // Audio system
  final AudioSystem _audioSystem = AudioSystem();

  // Node detail state
  String? _selectedNodeId;
  String? _selectedNodeLabel;
  NodeType? _selectedNodeType;
  double _selectedNodeHealth = 1.0;
  Asset? _selectedAsset;
  bool _panelOpen = false;

  // Live events
  WebSocketChannel? _wsChannel;
  final List<Map<String, dynamic>> _liveEvents = [];
  int _eventCount = 0;
  bool _wsConnected = false;

  // Stats
  int _totalAssets = 0;
  int _onlineAssets = 0;
  int _alertCount = 0;

  // Audio enabled
  bool _audioEnabled = true;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _panelAnimation = CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic);

    _game = OneMindGame(
      onNodeTapped: () {},
      onNodeTappedWithData: (nodeId, label, nodeType, health) {
        final asset = _game.getAssetForNode(nodeId);
        setState(() {
          _selectedNodeId = nodeId;
          _selectedNodeLabel = label;
          _selectedNodeType = nodeType;
          _selectedNodeHealth = health;
          _selectedAsset = asset;
          _panelOpen = true;
        });
        _panelController.forward();
        _audioSystem.playClick();
      },
    );

    _connectWebSocket();
    _connectTelemetry();
    _loadStats();
  }

  void _loadStats() async {
    final stats = await _assetService.fetchStats();
    if (stats != null && mounted) {
      setState(() {
        _totalAssets = stats.totalAssets;
        _onlineAssets = (stats.byStatus['online'] ?? 0) + (stats.byStatus['active'] ?? 0);
        _alertCount = stats.byStatus['alert'] ?? 0;
      });
    }
  }

  void _connectTelemetry() {
    _assetService.connectTelemetry(clientId: 'live-view');

    _telemetrySub = _assetService.telemetryStream.listen((telemetry) {
      _game.updateFromTelemetry(telemetry);
      setState(() => _eventCount++);
    });

    _alertSub = _assetService.alertStream.listen((alert) {
      _game.handleAlert(alert);
      setState(() {
        _alertCount++;
        _liveEvents.insert(0, {
          'type': 'alert',
          'source': 'asset',
          'title': alert.alerts.isNotEmpty ? alert.alerts.first : 'Alert',
          'asset_name': alert.assetName,
          'severity': alert.severity,
        });
        if (_liveEvents.length > 50) _liveEvents.removeLast();
      });
    });
  }

  void _connectWebSocket() {
    try {
      final wsUrl = Environment.apiBaseUrl.replaceFirst('http', 'ws');
      _wsChannel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws/events?client_id=live-view'));
      _wsChannel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            setState(() {
              _liveEvents.insert(0, data);
              if (_liveEvents.length > 50) _liveEvents.removeLast();
              _eventCount++;
              _wsConnected = true;
            });
          } catch (_) {}
        },
        onError: (_) => setState(() => _wsConnected = false),
        onDone: () {
          setState(() => _wsConnected = false);
          // Auto-reconnect after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted && !_wsConnected) _connectWebSocket();
          });
        },
      );
      setState(() => _wsConnected = true);
      _audioSystem.playConnect();
    } catch (_) {
      setState(() => _wsConnected = false);
    }
  }

  @override
  void dispose() {
    _panelController.dispose();
    _wsChannel?.sink.close();
    _telemetrySub?.cancel();
    _alertSub?.cancel();
    _assetService.disconnectTelemetry();
    super.dispose();
  }

  void _closePanel() {
    _panelController.reverse().then((_) {
      setState(() => _panelOpen = false);
    });
  }

  void _toggleAudio() {
    setState(() {
      _audioEnabled = !_audioEnabled;
      _audioSystem.setEnabled(_audioEnabled);
      _game.audioSystem.setEnabled(_audioEnabled);
    });
  }

  Future<void> _refreshAssets() async {
    await _game.refresh();
    _loadStats();
    _audioSystem.playSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA);
    final cardBg = isDark ? const Color(0xFF0A0F0A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            // Connection indicator
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _wsConnected ? accentGreen : const Color(0xFFEF4444),
                boxShadow: [
                  BoxShadow(
                    color: (_wsConnected ? accentGreen : const Color(0xFFEF4444)).withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('Live View', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          // Stats chips
          _headerStatChip('$_onlineAssets/$_totalAssets', 'Assets', accentGreen),
          const SizedBox(width: 8),
          if (_alertCount > 0)
            _headerStatChip('$_alertCount', 'Alerts', const Color(0xFFEF4444)),
          const SizedBox(width: 8),
          _headerStatChip('$_eventCount', 'Events', accentOrange),
          const SizedBox(width: 16),
          // Audio toggle
          IconButton(
            icon: Icon(
              _audioEnabled ? Icons.volume_up : Icons.volume_off,
              color: _audioEnabled ? accentGreen : Colors.grey,
              size: 20,
            ),
            onPressed: _toggleAudio,
            tooltip: _audioEnabled ? 'Mute sounds' : 'Enable sounds',
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white70 : Colors.black54, size: 20),
            onPressed: _refreshAssets,
            tooltip: 'Refresh assets',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Flame game canvas
          GameWidget(game: _game),

          // Live Events Feed (top-left)
          Positioned(
            top: 16,
            left: 16,
            child: _buildEventsFeed(cardBg, borderColor, theme, isDark),
          ),

          // Asset Legend (top-right)
          Positioned(
            top: 16,
            right: _panelOpen ? 300 : 16,
            child: _buildLegend(cardBg, borderColor, isDark),
          ),

          // Zoom controls (bottom-right)
          Positioned(
            bottom: 80,
            right: _panelOpen ? 300 : 20,
            child: Column(
              children: [
                _controlButton(Icons.add, () => _game.zoomIn(), accentGreen),
                const SizedBox(height: 8),
                _controlButton(Icons.remove, () => _game.zoomOut(), accentGreen),
                const SizedBox(height: 8),
                _controlButton(Icons.center_focus_strong, () => _game.resetView(), accentGreen),
              ],
            ),
          ),

          // Node stats panel (bottom-left)
          Positioned(
            bottom: 80,
            left: 20,
            child: _buildStatsPanel(cardBg, borderColor, accentGreen, theme, isDark),
          ),

          // Node detail panel (slides in from right)
          if (_panelOpen)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _panelAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(300 * (1 - _panelAnimation.value), 0),
                    child: child,
                  );
                },
                child: _buildNodeDetailPanel(cardBg, borderColor, theme, isDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEventsFeed(Color cardBg, Color borderColor, ThemeData theme, bool isDark) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.stream, color: const Color(0xFF4ADE80), size: 18),
                const SizedBox(width: 10),
                Text(
                  'LIVE EVENTS',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _wsConnected ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          if (_liveEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _wsConnected ? 'Waiting for events...' : 'Connecting...',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _liveEvents.length,
                itemBuilder: (ctx, i) => _buildEventItem(_liveEvents[i], theme, isDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event, ThemeData theme, bool isDark) {
    final type = event['type']?.toString() ?? event['event_type']?.toString() ?? 'event';
    final source = event['source']?.toString() ?? 'system';
    final title = event['title']?.toString() ?? type;
    final severity = event['severity']?.toString();

    Color eventColor;
    IconData eventIcon;

    if (severity == 'critical') {
      eventColor = const Color(0xFFEF4444);
      eventIcon = Icons.error;
    } else if (severity == 'warning' || type == 'alert') {
      eventColor = const Color(0xFFF97316);
      eventIcon = Icons.warning;
    } else {
      switch (source.toLowerCase()) {
        case 'asset':
        case 'telemetry':
          eventColor = const Color(0xFF4ADE80);
          eventIcon = Icons.sensors;
          break;
        case 'agent':
          eventColor = const Color(0xFF22C55E);
          eventIcon = Icons.smart_toy;
          break;
        case 'workflow':
          eventColor = const Color(0xFF3B82F6);
          eventIcon = Icons.account_tree;
          break;
        default:
          eventColor = const Color(0xFF6B7280);
          eventIcon = Icons.bolt;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: eventColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(eventIcon, color: eventColor, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$source • $type',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color cardBg, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ASSET TYPES', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 8),
          _legendItem('Machine', const Color(0xFFF97316), '⚙'),
          _legendItem('Human', const Color(0xFF3B82F6), '◎'),
          _legendItem('Device', const Color(0xFF8B5CF6), '⟐'),
          _legendItem('Location', const Color(0xFF06B6D4), '⬢'),
          _legendItem('Agent', const Color(0xFF4ADE80), '◉'),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, String symbol) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(child: Text(symbol, style: TextStyle(color: color, fontSize: 10))),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(Color cardBg, Color borderColor, Color accent, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('TOPOLOGY', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _miniStat('Nodes', '${_game.nodes.length}', accent, theme),
              const SizedBox(width: 20),
              _miniStat('Links', '${_game.connections.length}', const Color(0xFF3B82F6), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10)),
      ],
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildNodeDetailPanel(Color cardBg, Color borderColor, ThemeData theme, bool isDark) {
    final color = _nodeTypeColor(_selectedNodeType);
    final typeLabel = _selectedNodeType?.name.toUpperCase() ?? 'UNKNOWN';
    final healthPercent = (_selectedNodeHealth * 100).toInt();

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(left: BorderSide(color: color.withValues(alpha: 0.5), width: 3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(-5, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Center(child: Text(_nodeTypeSymbol(_selectedNodeType), style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedNodeLabel ?? 'Node',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(typeLabel, style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _closePanel,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                    child: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Health bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('HEALTH', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10, fontFamily: 'monospace', letterSpacing: 1)),
                    Text('$healthPercent%', style: TextStyle(color: _healthColor(_selectedNodeHealth), fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _selectedNodeHealth,
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(_healthColor(_selectedNodeHealth)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Asset Details (if available)
          if (_selectedAsset != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DETAILS', style: TextStyle(color: const Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  _detailRow('Status', _selectedAsset!.status.toUpperCase(), _statusColor(_selectedAsset!.status), theme),
                  _detailRow('Type', _selectedAsset!.assetType, const Color(0xFF3B82F6), theme),
                  if (_selectedAsset!.subType != null)
                    _detailRow('Subtype', _selectedAsset!.subType!, const Color(0xFF8B5CF6), theme),
                  if (_selectedAsset!.telemetry != null) ...[
                    const SizedBox(height: 10),
                    Text('TELEMETRY', style: TextStyle(color: const Color(0xFFF97316), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    if (_selectedAsset!.telemetry!.batteryLevel != null)
                      _detailRow('Battery', '${_selectedAsset!.telemetry!.batteryLevel!.toInt()}%', const Color(0xFF4ADE80), theme),
                    if (_selectedAsset!.telemetry!.operationalStatus.isNotEmpty)
                      _detailRow('Op Status', _selectedAsset!.telemetry!.operationalStatus, const Color(0xFF06B6D4), theme),
                  ],
                  if (_selectedAsset!.biometrics != null) ...[
                    const SizedBox(height: 10),
                    Text('BIOMETRICS', style: TextStyle(color: const Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    if (_selectedAsset!.biometrics!.heartRate != null)
                      _detailRow('Heart Rate', '${_selectedAsset!.biometrics!.heartRate} bpm', const Color(0xFFEF4444), theme),
                    if (_selectedAsset!.biometrics!.bloodOxygen != null)
                      _detailRow('Blood O2', '${_selectedAsset!.biometrics!.bloodOxygen}%', const Color(0xFF3B82F6), theme),
                    if (_selectedAsset!.biometrics!.stressLevel != null)
                      _detailRow('Stress', _selectedAsset!.biometrics!.stressLevel!, const Color(0xFFF97316), theme),
                  ],
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _detailRow('STATUS', 'ONLINE', const Color(0xFF22C55E), theme),
                  _detailRow('UPTIME', '99.7%', const Color(0xFF3B82F6), theme),
                  _detailRow('LATENCY', '12ms', const Color(0xFF8B5CF6), theme),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _actionButton('FOCUS', Icons.center_focus_strong, color, () {
                  if (_selectedNodeId != null) {
                    _game.focusOnNode(_selectedNodeId!);
                  }
                }),
                const SizedBox(height: 10),
                _actionButton('VIEW DETAILS', Icons.open_in_new, const Color(0xFF3B82F6), () {
                  // Navigate to asset detail screen
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11, fontFamily: 'monospace')),
          Text(value, style: TextStyle(color: valueColor, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Color _nodeTypeColor(NodeType? type) {
    switch (type) {
      case NodeType.core: return const Color(0xFF4ADE80);
      case NodeType.agent: return const Color(0xFF22C55E);
      case NodeType.infrastructure: return const Color(0xFF06B6D4);
      case NodeType.tool: return const Color(0xFFF97316);
      case NodeType.integration: return const Color(0xFF8B5CF6);
      case NodeType.sensor: return const Color(0xFF3B82F6);
      default: return const Color(0xFF4ADE80);
    }
  }

  String _nodeTypeSymbol(NodeType? type) {
    switch (type) {
      case NodeType.core: return '⬡';
      case NodeType.agent: return '◉';
      case NodeType.infrastructure: return '⬢';
      case NodeType.tool: return '⚙';
      case NodeType.integration: return '⟐';
      case NodeType.sensor: return '◎';
      default: return '●';
    }
  }

  Color _healthColor(double health) {
    if (health > 0.7) return const Color(0xFF4ADE80);
    if (health > 0.4) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
        return const Color(0xFF4ADE80);
      case 'idle':
        return const Color(0xFF3B82F6);
      case 'alert':
        return const Color(0xFFEF4444);
      case 'offline':
        return const Color(0xFF6B7280);
      case 'maintenance':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
