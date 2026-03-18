import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/tactical_theme.dart';

/// Visual indicator for tool calls during agent execution
/// Shows real-time tool usage with status and results
class ToolCallIndicator extends StatelessWidget {
  final String toolName;
  final String status; // 'running', 'complete', 'error'
  final String? result;
  final DateTime timestamp;

  const ToolCallIndicator({
    super.key,
    required this.toolName,
    required this.status,
    this.result,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          _getStatusIcon(),
          const SizedBox(width: 12),
          // Tool info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tool name
                Text(
                  _getToolDisplayName(toolName),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: TacticalColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (result != null && result!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    result!,
                    style: TextStyle(
                      fontSize: 11,
                      color: TacticalColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Timestamp
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 10,
              color: TacticalColors.textMuted,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Get status-based color
  Color _getStatusColor() {
    switch (status) {
      case 'running':
        return TacticalColors.primary;
      case 'complete':
        return TacticalColors.success;
      case 'error':
        return TacticalColors.error;
      default:
        return TacticalColors.textSecondary;
    }
  }

  /// Get status icon widget
  Widget _getStatusIcon() {
    switch (status) {
      case 'running':
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
        );
      case 'complete':
        return Icon(
          Icons.check_circle,
          size: 16,
          color: _getStatusColor(),
        );
      case 'error':
        return Icon(
          Icons.error,
          size: 16,
          color: _getStatusColor(),
        );
      default:
        return Icon(
          Icons.circle,
          size: 16,
          color: _getStatusColor(),
        );
    }
  }

  /// Get human-readable tool display name with emoji
  String _getToolDisplayName(String tool) {
    final map = {
      'duckduckgo': '🔍 Searching DuckDuckGo',
      'wikipedia': '📚 Reading Wikipedia',
      'file_read': '📄 Reading file',
      'file_write': '✍️ Writing file',
      'python': '🐍 Running Python',
      'shell': '💻 Executing shell command',
      'search': '🔎 Searching',
      'web_fetch': '🌐 Fetching web content',
      'calculator': '🧮 Calculating',
    };
    return map[tool.toLowerCase()] ?? '🔧 Using $tool';
  }

  /// Format timestamp to relative time
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 1) {
      return 'now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return DateFormat('HH:mm:ss').format(timestamp);
    }
  }
}

/// Model for tracking tool call state
class ToolCall {
  final String id;
  final String toolName;
  final String status;
  final String? result;
  final DateTime timestamp;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;

  ToolCall({
    required this.id,
    required this.toolName,
    required this.status,
    this.result,
    required this.timestamp,
    this.input,
    this.output,
  });

  /// Create copy with updated fields
  ToolCall copyWith({
    String? status,
    String? result,
    Map<String, dynamic>? output,
  }) {
    return ToolCall(
      id: id,
      toolName: toolName,
      status: status ?? this.status,
      result: result ?? this.result,
      timestamp: timestamp,
      input: input,
      output: output ?? this.output,
    );
  }
}

/// Compact tool call summary widget
class ToolCallSummary extends StatelessWidget {
  final List<ToolCall> toolCalls;

  const ToolCallSummary({super.key, required this.toolCalls});

  @override
  Widget build(BuildContext context) {
    if (toolCalls.isEmpty) return const SizedBox.shrink();

    final completedCount = toolCalls.where((t) => t.status == 'complete').length;
    final runningCount = toolCalls.where((t) => t.status == 'running').length;
    final errorCount = toolCalls.where((t) => t.status == 'error').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TacticalColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.build_circle,
            size: 14,
            color: TacticalColors.primary,
          ),
          const SizedBox(width: 6),
          if (runningCount > 0) ...[
            Text(
              '$runningCount running',
              style: TextStyle(
                fontSize: 11,
                color: TacticalColors.primary,
                fontFamily: 'monospace',
              ),
            ),
            if (completedCount > 0 || errorCount > 0) const Text(' • '),
          ],
          if (completedCount > 0) ...[
            Text(
              '$completedCount complete',
              style: TextStyle(
                fontSize: 11,
                color: TacticalColors.success,
                fontFamily: 'monospace',
              ),
            ),
            if (errorCount > 0) const Text(' • '),
          ],
          if (errorCount > 0)
            Text(
              '$errorCount error',
              style: TextStyle(
                fontSize: 11,
                color: TacticalColors.error,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}
