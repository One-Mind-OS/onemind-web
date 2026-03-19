import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/node_component.dart';
import 'components/connection_component.dart';
import 'systems/particle_system.dart';
import 'systems/audio_system.dart';
import '../services/asset_service.dart';

/// OneMind Game — Interactive Tech Visualization Engine
/// =====================================================
/// Flame-based game engine rendering the system as a living,
/// interactive organism. Nodes represent real assets from the
/// Asset Tracker - machines, humans, locations, devices.

class OneMindGame extends FlameGame with TapCallbacks, PanDetector {
  final VoidCallback? onNodeTapped;
  final void Function(String nodeId, String label, NodeType nodeType, double health)? onNodeTappedWithData;
  final void Function(Asset asset)? onAssetTapped;
  final Map<String, dynamic> Function()? getSystemData;

  OneMindGame({
    this.onNodeTapped,
    this.onNodeTappedWithData,
    this.onAssetTapped,
    this.getSystemData,
  });

  late ParticleSystem particleSystem;
  final AudioSystem audioSystem = AudioSystem();

  final List<NodeComponent> nodes = [];
  final List<ConnectionComponent> connections = [];
  final Map<String, NodeComponent> _nodeMap = {};
  final Map<String, Asset> _assetMap = {};

  // Camera controls
  double _zoom = 1.0;
  Vector2 _pan = Vector2.zero();

  // Core node (always exists)
  NodeComponent? _coreNode;

  // Layout configuration
  static const double _orbitRadiusInner = 200;
  static const double _orbitRadiusOuter = 350;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    particleSystem = ParticleSystem();

    // Add background grid
    add(GridBackground());

    // Create core hub node
    _createCoreNode();

    // Add particle system for ambient effects
    add(particleSystem);

    // Load real assets from backend
    await loadAssetsFromBackend();
  }

  void _createCoreNode() {
    _coreNode = NodeComponent(
      nodeId: 'core',
      label: 'OneMind Core',
      nodeType: NodeType.core,
      position: Vector2(size.x / 2, size.y / 2),
      color: const Color(0xFF4ADE80), // Solarpunk green
    );
    nodes.add(_coreNode!);
    _nodeMap['core'] = _coreNode!;
    add(_coreNode!);
  }

  /// Load real assets from the Asset Tracker backend
  Future<void> loadAssetsFromBackend() async {
    try {
      final assetService = AssetService();
      final assets = await assetService.fetchAssets();

      if (assets.isEmpty) {
        // No assets, create demo topology
        _createDemoTopology();
        return;
      }

      // Group assets by type for layout
      final machines = assets.where((a) => a.assetType == 'machine').toList();
      final humans = assets.where((a) => a.assetType == 'human').toList();
      final devices = assets.where((a) => a.assetType == 'device').toList();
      final locations = assets.where((a) => a.assetType == 'location').toList();

      // Layout machines in inner orbit
      _layoutAssetsInOrbit(machines, _orbitRadiusInner, NodeType.tool, const Color(0xFFF97316));

      // Layout humans in outer orbit (top half)
      _layoutAssetsInArc(humans, _orbitRadiusOuter, -pi * 0.75, -pi * 0.25, NodeType.sensor, const Color(0xFF3B82F6));

      // Layout devices in outer orbit (bottom half)
      _layoutAssetsInArc(devices, _orbitRadiusOuter, pi * 0.25, pi * 0.75, NodeType.integration, const Color(0xFF8B5CF6));

      // Layout locations as infrastructure around the edge
      _layoutAssetsInArc(locations, _orbitRadiusOuter + 100, 0, pi * 2, NodeType.infrastructure, const Color(0xFF06B6D4));

      // Play connect sound
      audioSystem.playConnect();

    } catch (e) {
      debugPrint('Error loading assets: $e');
      _createDemoTopology();
    }
  }

  void _layoutAssetsInOrbit(List<Asset> assets, double radius, NodeType nodeType, Color color) {
    if (assets.isEmpty) return;
    final center = Vector2(size.x / 2, size.y / 2);
    final angleStep = 2 * pi / assets.length;

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final angle = angleStep * i - pi / 2;
      final position = center + Vector2(cos(angle) * radius, sin(angle) * radius);

      _addAssetNode(asset, position, nodeType, color);
    }
  }

  void _layoutAssetsInArc(List<Asset> assets, double radius, double startAngle, double endAngle, NodeType nodeType, Color color) {
    if (assets.isEmpty) return;
    final center = Vector2(size.x / 2, size.y / 2);
    final angleRange = endAngle - startAngle;
    final angleStep = assets.length > 1 ? angleRange / (assets.length - 1) : 0;

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final angle = startAngle + (angleStep * i);
      final position = center + Vector2(cos(angle) * radius, sin(angle) * radius);

      _addAssetNode(asset, position, nodeType, color);
    }
  }

  void _addAssetNode(Asset asset, Vector2 position, NodeType nodeType, Color baseColor) {
    // Determine color based on status
    Color color = baseColor;
    if (asset.status == 'alert') {
      color = const Color(0xFFEF4444); // Red
    } else if (asset.status == 'offline') {
      color = const Color(0xFF6B7280); // Gray
    } else if (asset.status == 'active') {
      color = const Color(0xFF22C55E); // Green
    }

    final node = NodeComponent(
      nodeId: asset.id,
      label: asset.name,
      nodeType: nodeType,
      position: position,
      color: color,
    );

    // Set health from asset
    node.setHealth(asset.health);
    node.setActive(asset.status != 'offline');

    nodes.add(node);
    _nodeMap[asset.id] = node;
    _assetMap[asset.id] = asset;
    add(node);

    // Connect to core
    if (_coreNode != null) {
      final conn = ConnectionComponent(
        from: _coreNode!,
        to: node,
        flowColor: color.withValues(alpha: 0.4),
      );
      conn.setActive(asset.status != 'offline');
      connections.add(conn);
      add(conn);
    }
  }

  /// Create demo topology when no real assets exist
  void _createDemoTopology() {
    final center = Vector2(size.x / 2, size.y / 2);

    // Demo infrastructure nodes
    final infraData = [
      {'id': 'nats', 'label': 'NATS Bus', 'offset': Vector2(0, -_orbitRadiusInner)},
      {'id': 'postgres', 'label': 'PostgreSQL', 'offset': Vector2(-_orbitRadiusInner, 0)},
      {'id': 'api', 'label': 'FastAPI', 'offset': Vector2(_orbitRadiusInner, 0)},
      {'id': 'redis', 'label': 'Redis Cache', 'offset': Vector2(0, _orbitRadiusInner)},
    ];

    for (final infra in infraData) {
      final node = NodeComponent(
        nodeId: infra['id'] as String,
        label: infra['label'] as String,
        nodeType: NodeType.infrastructure,
        position: center + (infra['offset'] as Vector2),
        color: const Color(0xFF06B6D4),
      );
      nodes.add(node);
      _nodeMap[infra['id'] as String] = node;
      add(node);

      final conn = ConnectionComponent(
        from: _coreNode!,
        to: node,
        flowColor: const Color(0xFF06B6D4).withValues(alpha: 0.3),
      );
      connections.add(conn);
      add(conn);
    }

    // Demo agent nodes
    final agentPositions = [
      Vector2(-_orbitRadiusOuter * 0.7, -_orbitRadiusOuter * 0.7),
      Vector2(_orbitRadiusOuter * 0.7, -_orbitRadiusOuter * 0.7),
      Vector2(-_orbitRadiusOuter * 0.7, _orbitRadiusOuter * 0.7),
      Vector2(_orbitRadiusOuter * 0.7, _orbitRadiusOuter * 0.7),
    ];
    final agentNames = ['Orchestrator', 'Researcher', 'Coder', 'Analyst'];

    for (int i = 0; i < agentNames.length; i++) {
      final node = NodeComponent(
        nodeId: 'agent_$i',
        label: agentNames[i],
        nodeType: NodeType.agent,
        position: center + agentPositions[i],
        color: const Color(0xFF4ADE80),
      );
      nodes.add(node);
      _nodeMap['agent_$i'] = node;
      add(node);

      final conn = ConnectionComponent(
        from: _coreNode!,
        to: node,
        flowColor: const Color(0xFF4ADE80).withValues(alpha: 0.4),
      );
      connections.add(conn);
      add(conn);
    }
  }

  /// Update node from real-time telemetry
  void updateFromTelemetry(AssetTelemetry telemetry) {
    final node = _nodeMap[telemetry.assetId];
    if (node == null) return;

    final oldHealth = node.health;
    final newHealth = telemetry.health;

    node.setHealth(newHealth);

    // Play sound for significant health changes
    audioSystem.playForHealthChange(oldHealth, newHealth);

    // Trigger particle burst for critical alerts
    if (newHealth < 0.3 && oldHealth >= 0.3) {
      particleSystem.burst(
        node.position.x,
        node.position.y,
        count: 15,
        color: const Color(0xFFEF4444),
      );
      audioSystem.playAlert();
    }
  }

  /// Handle asset alert
  void handleAlert(AssetAlert alert) {
    final node = _nodeMap[alert.assetId];
    if (node == null) return;

    // Flash the node red
    node.setHealth(0.3);

    // Particle burst
    particleSystem.burst(
      node.position.x,
      node.position.y,
      count: 20,
      color: alert.severity == 'critical'
          ? const Color(0xFFEF4444)
          : const Color(0xFFF97316),
    );

    // Play alert sound
    if (alert.severity == 'critical') {
      audioSystem.playAlert();
    } else {
      audioSystem.playWarning();
    }
  }

  /// Add a new asset node dynamically
  void addAsset(Asset asset) {
    if (_nodeMap.containsKey(asset.id)) return;

    // Find a free position
    final center = Vector2(size.x / 2, size.y / 2);
    final angle = Random().nextDouble() * 2 * pi;
    final radius = _orbitRadiusInner + Random().nextDouble() * (_orbitRadiusOuter - _orbitRadiusInner);
    final position = center + Vector2(cos(angle) * radius, sin(angle) * radius);

    final nodeType = _nodeTypeFromAssetType(asset.assetType);
    final color = _colorFromAssetType(asset.assetType);

    _addAssetNode(asset, position, nodeType, color);

    // Play connect sound
    audioSystem.playConnect();

    // Particle burst for new asset
    particleSystem.burst(position.x, position.y, count: 10, color: color);
  }

  /// Remove an asset node
  void removeAsset(String assetId) {
    final node = _nodeMap.remove(assetId);
    if (node == null) return;

    _assetMap.remove(assetId);
    nodes.remove(node);

    // Remove connections to this node
    connections.removeWhere((conn) {
      if (conn.to == node || conn.from == node) {
        remove(conn);
        return true;
      }
      return false;
    });

    remove(node);
    audioSystem.playDisconnect();
  }

  /// Get asset for a node
  Asset? getAssetForNode(String nodeId) {
    return _assetMap[nodeId];
  }

  NodeType _nodeTypeFromAssetType(String assetType) {
    switch (assetType) {
      case 'machine':
        return NodeType.tool;
      case 'human':
        return NodeType.sensor;
      case 'device':
        return NodeType.integration;
      case 'location':
        return NodeType.infrastructure;
      default:
        return NodeType.agent;
    }
  }

  Color _colorFromAssetType(String assetType) {
    switch (assetType) {
      case 'machine':
        return const Color(0xFFF97316); // Orange
      case 'human':
        return const Color(0xFF3B82F6); // Blue
      case 'device':
        return const Color(0xFF8B5CF6); // Purple
      case 'location':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFF4ADE80); // Green
    }
  }

  /// Refresh all assets from backend
  Future<void> refresh() async {
    // Clear existing nodes (except core)
    for (final node in nodes.toList()) {
      if (node.nodeId != 'core') {
        remove(node);
        nodes.remove(node);
      }
    }
    for (final conn in connections.toList()) {
      remove(conn);
    }
    connections.clear();
    _nodeMap.clear();
    _nodeMap['core'] = _coreNode!;
    _assetMap.clear();

    await loadAssetsFromBackend();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _pan += info.delta.global;
    camera.viewfinder.position = -_pan;
  }

  void zoomIn() {
    _zoom = (_zoom * 1.2).clamp(0.3, 3.0);
    camera.viewfinder.zoom = _zoom;
    audioSystem.playClick();
  }

  void zoomOut() {
    _zoom = (_zoom / 1.2).clamp(0.3, 3.0);
    camera.viewfinder.zoom = _zoom;
    audioSystem.playClick();
  }

  void resetView() {
    _zoom = 1.0;
    _pan = Vector2.zero();
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.position = Vector2.zero();
    audioSystem.playClick();
  }

  /// Focus camera on a specific node
  void focusOnNode(String nodeId) {
    final node = _nodeMap[nodeId];
    if (node == null) return;

    _pan = -node.position + Vector2(size.x / 2, size.y / 2);
    camera.viewfinder.position = -_pan;
    _zoom = 1.5;
    camera.viewfinder.zoom = _zoom;
  }
}

/// Background grid rendering
class GridBackground extends Component with HasGameReference<OneMindGame> {
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF0A1A0A) // Dark solarpunk green
      ..strokeWidth = 0.5;

    final size = game.size;
    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.x; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.y; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paint);
    }
  }
}
