/// Status Badge Component with Breathing Animation
///
/// A reusable status badge/indicator that shows breathing animation
/// in solarpunk theme for active/online states.
///
/// Usage:
/// ```dart
/// // Simple status dot
/// StatusBadge(
///   size: 12,
///   color: TacticalColors.success,
///   isActive: true,  // Will breathe in solarpunk theme
/// )
///
/// // Status badge with label
/// StatusBadge(
///   size: 10,
///   color: TacticalColors.success,
///   isActive: true,
///   label: 'ONLINE',
/// )
///
/// // Status badge with container padding
/// StatusBadge(
///   size: 12,
///   color: TacticalColors.success,
///   isActive: connected,
///   showContainer: true,  // Adds padding container
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../config/tactical_theme.dart';

/// Status badge with conditional breathing animation for solarpunk theme
class StatusBadge extends StatefulWidget {
  /// Size of the status dot/badge
  final double size;

  /// Color of the status indicator
  final Color color;

  /// Whether the status is active/online (controls animation)
  final bool isActive;

  /// Optional label text
  final String? label;

  /// Show container with padding around dot
  final bool showContainer;

  /// Optional tooltip message
  final String? tooltip;

  const StatusBadge({
    super.key,
    this.size = 10.0,
    required this.color,
    this.isActive = false,
    this.label,
    this.showContainer = false,
    this.tooltip,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TacticalAnimations.breathingPulse(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TacticalAnimations.breathingScale(_controller);
    _opacityAnimation = TacticalAnimations.breathingOpacity(_controller);

    // Start animation if active and in solarpunk theme
    if (widget.isActive && TacticalAnimations.shouldAnimate()) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation based on state and theme
    final shouldRun = widget.isActive && TacticalAnimations.shouldAnimate();

    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget badge = _buildBadgeContent();

    if (widget.label != null) {
      badge = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.color,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    if (widget.showContainer) {
      badge = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: badge,
      );
    }

    if (widget.tooltip != null) {
      badge = Tooltip(
        message: widget.tooltip!,
        child: badge,
      );
    }

    return badge;
  }

  Widget _buildBadgeContent() {
    // Static badge for non-active states or non-solarpunk themes
    if (!widget.isActive || !TacticalAnimations.shouldAnimate()) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: widget.size * 0.8,
                    spreadRadius: widget.size * 0.2,
                  ),
                ]
              : null,
        ),
      );
    }

    // Animated badge for active states in solarpunk theme
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _opacityAnimation.value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color
                      .withValues(alpha: _opacityAnimation.value * 0.6),
                  blurRadius: widget.size * _scaleAnimation.value,
                  spreadRadius: widget.size * 0.3 * _scaleAnimation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Status Badge Container
/// Wraps a child with a status badge indicator
class StatusBadgeContainer extends StatelessWidget {
  final Widget child;
  final Color statusColor;
  final bool isActive;
  final double badgeSize;
  final Alignment badgeAlignment;

  const StatusBadgeContainer({
    super.key,
    required this.child,
    required this.statusColor,
    this.isActive = false,
    this.badgeSize = 8.0,
    this.badgeAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: badgeAlignment,
            child: Transform.translate(
              offset: const Offset(2, -2),
              child: StatusBadge(
                size: badgeSize,
                color: statusColor,
                isActive: isActive,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
