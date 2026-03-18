import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Action buttons for messages (copy, regenerate, edit, delete)
/// Only visible on hover for a clean, discreet UI
class MessageActions extends StatefulWidget {
  final String messageContent;
  final bool isUser;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MessageActions({
    super.key,
    required this.messageContent,
    required this.isUser,
    required this.onRegenerate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<MessageActions> createState() => _MessageActionsState();
}

class _MessageActionsState extends State<MessageActions> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(top: 6, left: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.copy,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.messageContent));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Copied to clipboard',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: const Color(0xFF00D9FF),
                        ),
                      ),
                      backgroundColor: const Color(0xFF0A0A0A),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (!widget.isUser) ...[
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.refresh,
                  onTap: widget.onRegenerate,
                ),
              ],
              const SizedBox(width: 4),
              _ActionButton(
                icon: Icons.edit,
                onTap: widget.onEdit,
              ),
              const SizedBox(width: 4),
              _ActionButton(
                icon: Icons.delete_outline,
                onTap: widget.onDelete,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? const Color(0xFFFF0000) : const Color(0xFF00D9FF);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isHovered ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: color.withValues(alpha: _isHovered ? 0.9 : 0.6),
          ),
        ),
      ),
    );
  }
}
