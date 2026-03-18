import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../onemind_game.dart';
import '../../config/tactical_theme.dart';

/// Ambient particle system for visual flair
/// Floating particles, data streams, and energy effects.
/// Theme-aware: cool cyan/blue for tactical, warm amber for solarpunk.

class ParticleSystem extends Component with HasGameReference<OneMindGame> {
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  double _spawnTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer > 0.3 && _particles.length < 50) {
      _spawnTimer = 0;
      _spawnParticle();
    }

    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
      p.alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
    }

    _particles.removeWhere((p) => p.life <= 0);
  }

  void _spawnParticle() {
    final size = game.size;
    final isSolarpunk = TacticalColors.currentTheme == AppThemeMode.solarpunk;

    // Solarpunk: slower, more organic movement (floating upward gently)
    // Tactical: faster, more digital movement (streams of data)
    final vxMultiplier = isSolarpunk ? 15.0 : 20.0;
    final vyBase = isSolarpunk ? 10.0 : 15.0;
    final vyOffset = isSolarpunk ? 3.0 : 5.0;

    _particles.add(_Particle(
      x: _rng.nextDouble() * size.x,
      y: _rng.nextDouble() * size.y,
      vx: (_rng.nextDouble() - 0.5) * vxMultiplier,
      vy: -_rng.nextDouble() * vyBase - vyOffset,
      radius: _rng.nextDouble() * 2 + 0.5,
      color: _randomColor(),
      maxLife: _rng.nextDouble() * 4 + 2,
    ));
  }

  Color _randomColor() {
    // Theme-aware color palettes
    final isSolarpunk = TacticalColors.currentTheme == AppThemeMode.solarpunk;

    if (isSolarpunk) {
      // Warm amber/golden palette for solarpunk
      final colors = [
        TacticalColorsSolarpunk.primary,      // Amber #FFB703
        TacticalColorsSolarpunk.primaryGlow,  // Golden #FFC933
        const Color(0xFFFFC300),              // Rich golden
        const Color(0xFFFFAA00),              // Deep amber
        const Color(0xFFFFD166),              // Soft golden yellow
      ];
      return colors[_rng.nextInt(colors.length)];
    } else {
      // Cool cyan/blue palette for tactical themes (dark/light)
      final colors = [
        const Color(0xFF00D9FF), // Cyan
        const Color(0xFF4ECDC4), // Teal
        const Color(0xFF00A8CC), // Deep cyan
        const Color(0xFF33E0FF), // Bright cyan
      ];
      return colors[_rng.nextInt(colors.length)];
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha * 0.4);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);

      // Soft glow
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: p.alpha * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(p.x, p.y), p.radius * 3, glowPaint);
    }
  }

  /// Burst effect at a point (for achievement unlocks, etc.)
  void burst(double x, double y, {int count = 20, Color? color}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = _rng.nextDouble() * 80 + 20;
      _particles.add(_Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        radius: _rng.nextDouble() * 3 + 1,
        color: color ?? const Color(0xFFFFD700),
        maxLife: _rng.nextDouble() * 1.5 + 0.5,
      ));
    }
  }
}

class _Particle {
  double x, y, vx, vy;
  double radius;
  Color color;
  double life;
  double maxLife;
  double alpha = 1.0;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    required this.maxLife,
  }) : life = maxLife;
}
