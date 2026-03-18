import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../onemind_game.dart';
import '../../config/tactical_theme.dart';

/// Node types in the OneMind universe
enum NodeType { core, agent, infrastructure, tool, integration, sensor }

/// Interactive node component — represents an entity in the system
class NodeComponent extends CircleComponent
    with TapCallbacks, HasGameReference<OneMindGame> {
  final String nodeId;
  final String label;
  final NodeType nodeType;
  final Color color;

  // Animation
  double _pulsePhase = 0;
  double _glowIntensity = 0.5;
  bool _isHovered = false;
  bool _isActive = true;

  // Breathing animation for solarpunk theme
  double _breathingPhase = 0;
  double _breathingScale = 1.0;
  double _breathingOpacity = 1.0;

  // Health (0..1)
  double health = 1.0;

  NodeComponent({
    required this.nodeId,
    required this.label,
    required this.nodeType,
    required Vector2 position,
    required this.color,
  }) : super(
          position: position,
          radius: _radiusForType(nodeType),
          anchor: Anchor.center,
        ) {
    _pulsePhase = Random().nextDouble() * pi * 2;
  }

  static double _radiusForType(NodeType type) {
    switch (type) {
      case NodeType.core:
        return 32;
      case NodeType.agent:
        return 22;
      case NodeType.infrastructure:
        return 26;
      case NodeType.tool:
        return 16;
      case NodeType.integration:
        return 18;
      case NodeType.sensor:
        return 14;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulsePhase += dt * 2.0;
    _glowIntensity = 0.4 + sin(_pulsePhase) * 0.2;

    // Breathing animation for solarpunk theme
    if (TacticalAnimations.shouldAnimate()) {
      _breathingPhase += dt * 1.5; // Slower than pulse for organic feel

      // Subtle scale animation: 1.0 → 1.08
      _breathingScale = 1.0 + (sin(_breathingPhase) * 0.04);

      // Subtle opacity animation: 0.85 → 1.0
      _breathingOpacity = 0.925 + (sin(_breathingPhase) * 0.075);
    } else {
      // Reset to default for non-solarpunk themes
      _breathingScale = 1.0;
      _breathingOpacity = 1.0;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(radius, radius);

    // Apply breathing animation transformations for solarpunk theme
    canvas.save();

    // Apply scale transformation from center
    canvas.translate(center.dx, center.dy);
    canvas.scale(_breathingScale);
    canvas.translate(-center.dx, -center.dy);

    // Calculate opacity multiplier for breathing effect
    final opacityMultiplier = _breathingOpacity;

    // Outer glow
    if (_isActive) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: _glowIntensity * 0.3 * opacityMultiplier)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius + 8, glowPaint);
    }

    // Health ring
    final healthPaint = Paint()
      ..color = _healthColor().withValues(alpha: 0.6 * opacityMultiplier)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 3),
      -pi / 2,
      2 * pi * health,
      false,
      healthPaint,
    );

    // Main body
    final bodyPaint = Paint()
      ..color = color.withValues(alpha: (_isHovered ? 0.9 : 0.7) * opacityMultiplier);
    canvas.drawCircle(center, radius, bodyPaint);

    // Inner highlight
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * opacityMultiplier);
    canvas.drawCircle(center, radius * 0.5, innerPaint);

    // Center dot
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.8 * opacityMultiplier);
    canvas.drawCircle(center, 3, dotPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9 * opacityMultiplier),
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + radius + 8),
    );

    // Type icon (small indicator)
    final typePainter = TextPainter(
      text: TextSpan(
        text: _typeSymbol(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6 * opacityMultiplier),
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    typePainter.layout();
    typePainter.paint(
      canvas,
      Offset(center.dx - typePainter.width / 2, center.dy - 5),
    );

    canvas.restore();
  }

  String _typeSymbol() {
    switch (nodeType) {
      case NodeType.core:
        return '⬡';
      case NodeType.agent:
        return '◉';
      case NodeType.infrastructure:
        return '⬢';
      case NodeType.tool:
        return '⚙';
      case NodeType.integration:
        return '⟐';
      case NodeType.sensor:
        return '◎';
    }
  }

  Color _healthColor() {
    if (health > 0.8) return const Color(0xFF00FF88);
    if (health > 0.5) return const Color(0xFFFFAA00);
    return const Color(0xFFFF4444);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isHovered = true;
    game.onNodeTappedWithData?.call(nodeId, label, nodeType, health);
    game.onNodeTapped?.call();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isHovered = false;
  }

  void setHealth(double h) {
    health = h.clamp(0.0, 1.0);
  }

  void setActive(bool active) {
    _isActive = active;
  }
}
