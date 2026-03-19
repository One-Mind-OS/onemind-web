import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../config/tactical_theme.dart';

/// Tactical markdown message renderer with Matrix theme
class MarkdownMessage extends StatelessWidget {
  final Message message;

  const MarkdownMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: message.isUser
                  ? TacticalColors.error.withValues(alpha: 0.2)
                  : TacticalColors.cyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: message.isUser
                    ? TacticalColors.error.withValues(alpha: 0.5)
                    : TacticalColors.cyan.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              message.isUser ? Icons.person : Icons.psychology,
              color: message.isUser ? TacticalColors.error : TacticalColors.cyan,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with role and timestamp
                Row(
                  children: [
                    Text(
                      message.isUser ? 'USER' : 'AGENT',
                      style: TextStyle(
                        fontSize: 10,
                        color: (message.isUser ? TacticalColors.error : TacticalColors.cyan)
                            .withValues(alpha: 0.7),
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        fontSize: 9,
                        color: TacticalColors.cyan.withValues(alpha: 0.4),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Image attachments (if present)
                if (message.images != null && message.images!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.images!.map((img) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (message.isUser ? TacticalColors.error : TacticalColors.cyan)
                                  .withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              base64Decode(img.base64Data),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Message content with markdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TacticalColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (message.isUser ? TacticalColors.error : TacticalColors.cyan)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: message.content.isEmpty
                      ? Text(
                          '▊',
                          style: TextStyle(
                            color: TacticalColors.textPrimary,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: _buildMarkdownStyle(),
                          builders: {
                            'code': CodeBlockBuilder(),
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }

  MarkdownStyleSheet _buildMarkdownStyle() {
    return MarkdownStyleSheet(
      p: TextStyle(
        color: TacticalColors.textPrimary,
        fontSize: 13,
        fontFamily: 'monospace',
        height: 1.5,
      ),
      h1: TextStyle(
        color: TacticalColors.cyan,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
      h2: TextStyle(
        color: TacticalColors.cyan,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
      h3: TextStyle(
        color: TacticalColors.cyan,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
      code: TextStyle(
        color: TacticalColors.cyan,
        backgroundColor: TacticalColors.background,
        fontFamily: 'monospace',
        fontSize: 12,
      ),
      codeblockDecoration: BoxDecoration(
        color: TacticalColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: TacticalColors.cyan.withValues(alpha: 0.3),
        ),
      ),
      blockquote: TextStyle(
        color: TacticalColors.textPrimary,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: TacticalColors.background,
        border: Border(
          left: BorderSide(
            color: TacticalColors.cyan.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      listBullet: TextStyle(
        color: TacticalColors.cyan,
        fontSize: 13,
      ),
      a: TextStyle(
        color: TacticalColors.textPrimary,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

/// Custom code block builder with syntax highlighting and copy button
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(element, preferredStyle) {
    final String code = element.textContent.trim();
    final String? language = element.attributes['class']?.replaceFirst('language-', '');

    return _CodeBlock(
      code: code,
      language: language ?? 'text',
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;
  final String language;

  const _CodeBlock({required this.code, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: TacticalColors.cyan.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TacticalColors.cyan.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: TacticalColors.cyan.withValues(alpha: 0.7),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _CopyButton(code: code),
              ],
            ),
          ),
          // Code with syntax highlighting
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              code,
              language: _normalizeLanguage(language),
              theme: monokaiSublimeTheme,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeLanguage(String lang) {
    // Normalize common language aliases
    final Map<String, String> aliases = {
      'js': 'javascript',
      'ts': 'typescript',
      'py': 'python',
      'sh': 'bash',
      'yml': 'yaml',
    };
    return aliases[lang.toLowerCase()] ?? lang.toLowerCase();
  }
}

class _CopyButton extends StatefulWidget {
  final String code;

  const _CopyButton({required this.code});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copyToClipboard,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check : Icons.copy,
              size: 12,
              color: TacticalColors.cyan.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'COPIED' : 'COPY',
              style: TextStyle(
                fontSize: 9,
                color: TacticalColors.cyan.withValues(alpha: 0.7),
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
