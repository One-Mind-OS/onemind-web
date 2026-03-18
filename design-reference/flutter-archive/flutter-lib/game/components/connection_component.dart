import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../onemind_game.dart';
import 'node_component.dart';
import '../../config/tactical_theme.dart';

/// Connection between two nodes — renders animated data flow line
class ConnectionComponent extends Component with HasGameReference<OneMindGame> {
  final NodeComponent from;
  final NodeComponent to;
  final Color flowColor;

  double _flowPhase = 0;
  double _flowSpeed = 1.0;
  bool isActive = true;

  ConnectionComponent({
    required this.from,
    required this.to,
    required this.flowColor,
    double flowSpeed = 1.0,
  }) : _flowSpeed = flowSpeed;

  @override
  void update(double dt) {
    super.update(dt);
    _flowPhase += dt * _flowSpeed * 3;
    if (_flowPhase > 1.0) _flowPhase -= 1.0;
  }

  @override
  void render(Canvas canvas) {
    final fromPos = Offset(from.position.x, from.position.y);
    final toPos = Offset(to.position.x, to.position.y);
    final isSolarpunk = TacticalAnimations.shouldAnimate();

    if (isSolarpunk) {
      _renderBezierConnection(canvas, fromPos, toPos);
    } else {
      _renderStraightConnection(canvas, fromPos, toPos);
    }
  }

  /// Render straight line connections for tactical themes
  void _renderStraightConnection(Canvas canvas, Offset fromPos, Offset toPos) {
    // Base line
    final linePaint = Paint()
      ..color = flowColor.withValues(alpha: isActive ? 0.2 : 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(fromPos, toPos, linePaint);

    // Animated flow dots (data packets moving along the line)
    if (isActive) {
      final dx = toPos.dx - fromPos.dx;
      final dy = toPos.dy - fromPos.dy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 1) return;

      const dotCount = 3;
      for (int i = 0; i < dotCount; i++) {
        final phase = (_flowPhase + i / dotCount) % 1.0;
        final x = fromPos.dx + dx * phase;
        final y = fromPos.dy + dy * phase;

        // Dot glow
        final glowPaint = Paint()
          ..color = flowColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), 4, glowPaint);

        // Dot
        final dotPaint = Paint()
          ..color = flowColor.withValues(alpha: 0.9);
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }
  }

  /// Render organic bezier curve connections for solarpunk theme
  void _renderBezierConnection(Canvas canvas, Offset fromPos, Offset toPos) {
    // Use moss green for solarpunk connections
    final mossColor = TacticalColorsSolarpunk.moss;

    // Calculate bezier control point (perpendicular offset)
    final dx = toPos.dx - fromPos.dx;
    final dy = toPos.dy - fromPos.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < 1) return;

    // Create perpendicular offset for organic curve
    // Offset is 30% of distance, perpendicular to the line
    final perpX = -dy / dist * dist * 0.3;
    final perpY = dx / dist * dist * 0.3;
    final controlPoint = Offset(
      (fromPos.dx + toPos.dx) / 2 + perpX,
      (fromPos.dy + toPos.dy) / 2 + perpY,
    );

    // Create bezier curve path
    final path = Path()
      ..moveTo(fromPos.dx, fromPos.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        toPos.dx,
        toPos.dy,
      );

    // Base curve
    final curvePaint = Paint()
      ..color = mossColor.withValues(alpha: isActive ? 0.25 : 0.08)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, curvePaint);

    // Animated energy pulse along the curve
    if (isActive) {
      const dotCount = 3;
      for (int i = 0; i < dotCount; i++) {
        final phase = (_flowPhase + i / dotCount) % 1.0;

        // Calculate position along bezier curve using quadratic formula
        final t = phase;
        final x = pow(1 - t, 2) * fromPos.dx +
            2 * (1 - t) * t * controlPoint.dx +
            pow(t, 2) * toPos.dx;
        final y = pow(1 - t, 2) * fromPos.dy +
            2 * (1 - t) * t * controlPoint.dy +
            pow(t, 2) * toPos.dy;

        // Energy pulse glow (organic, larger)
        final glowPaint = Paint()
          ..color = mossColor.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(x, y), 5, glowPaint);

        // Energy pulse core
        final dotPaint = Paint()
          ..color = mossColor.withValues(alpha: 0.95);
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }
  }

  void setActive(bool active) {
    isActive = active;
  }

  void setFlowSpeed(double speed) {
    _flowSpeed = speed;
  }
}
