import 'package:flutter/material.dart';
import '../config/tactical_theme.dart';

/// Shows real-time agent activity status
class AgentStatusIndicator extends StatelessWidget {
  final String status;
  final String? toolName;
  final String? agentName;

  const AgentStatusIndicator({
    super.key,
    required this.status,
    this.toolName,
    this.agentName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9FF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated indicator dot
          _PulsingDot(),
          const SizedBox(width: 8),
          // Status text
          Text(
            _buildStatusText(),
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _buildStatusText() {
    if (toolName != null) {
      return '🔧 Using tool: $toolName';
    } else if (agentName != null) {
      return '🤖 $agentName: $status';
    }
    return status;
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TacticalAnimations.breathingPulse(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Only animate in solarpunk theme
    if (TacticalAnimations.shouldAnimate()) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Static dot for tactical themes
    if (!TacticalAnimations.shouldAnimate()) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00D9FF),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    // Animated dot for solarpunk theme
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = (_controller.value < 0.5)
            ? (_controller.value * 2)
            : (2 - _controller.value * 2);

        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00D9FF).withValues(alpha: 0.3 + opacity * 0.7),
          ),
        );
      },
    );
  }
}
