import 'package:flutter/material.dart';
import '../config/tactical_theme.dart';

/// Badge indicating that an agent has extended reasoning capabilities
class ReasoningBadge extends StatelessWidget {
  const ReasoningBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: TacticalColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.psychology,
            size: 12,
            color: TacticalColors.primary,
          ),
          SizedBox(width: 4),
          Text(
            'Extended Reasoning',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: TacticalColors.primary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated indicator showing agent is currently reasoning
class ReasoningIndicator extends StatefulWidget {
  final String? step;

  const ReasoningIndicator({super.key, this.step});

  @override
  State<ReasoningIndicator> createState() => _ReasoningIndicatorState();
}

class _ReasoningIndicatorState extends State<ReasoningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border.all(
          color: TacticalColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.psychology,
              color: TacticalColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent Reasoning...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TacticalColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                if (widget.step != null) ...[
                  SizedBox(height: 4),
                  Text(
                    widget.step!,
                    style: TextStyle(
                      fontSize: 12,
                      color: TacticalColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
