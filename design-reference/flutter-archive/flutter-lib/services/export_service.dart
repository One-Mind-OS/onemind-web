// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
// Web-only import - safe for Flutter web builds
import 'dart:html' as html show Blob, Url, AnchorElement;
import '../models/message.dart';

/// Service for exporting chat conversations
class ExportService {
  /// Export conversation as Markdown
  static void exportAsMarkdown(List<Message> messages, {String? title}) {
    final buffer = StringBuffer();

    // Add title
    buffer.writeln('# ${title ?? 'OneMind OS Conversation'}');
    buffer.writeln();
    buffer.writeln('*Exported from OneMind OS v2*');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // Add messages
    for (final message in messages) {
      final role = message.isUser ? '👤 **User**' : '🤖 **Agent**';
      final timestamp = _formatTimestamp(message.timestamp);

      buffer.writeln('## $role');
      buffer.writeln('*$timestamp*');
      buffer.writeln();
      buffer.writeln(message.content);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    // Download file
    _downloadFile(
      buffer.toString(),
      'onemind-conversation-${DateTime.now().millisecondsSinceEpoch}.md',
      'text/markdown',
    );
  }

  /// Export conversation as JSON
  static void exportAsJson(List<Message> messages, {String? title}) {
    final data = {
      'title': title ?? 'OneMind OS Conversation',
      'exported_at': DateTime.now().toIso8601String(),
      'version': '2.0.0',
      'messages': messages.map((m) => {
        'role': m.isUser ? 'user' : 'agent',
        'content': m.content,
        'timestamp': m.timestamp.toIso8601String(),
      }).toList(),
    };

    _downloadFile(
      jsonEncode(data),
      'onemind-conversation-${DateTime.now().millisecondsSinceEpoch}.json',
      'application/json',
    );
  }

  /// Export conversation as plain text
  static void exportAsText(List<Message> messages, {String? title}) {
    final buffer = StringBuffer();

    buffer.writeln(title ?? 'OneMind OS Conversation');
    buffer.writeln('Exported from OneMind OS v2');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final message in messages) {
      final role = message.isUser ? 'USER' : 'AGENT';
      final timestamp = _formatTimestamp(message.timestamp);

      buffer.writeln('[$role] $timestamp');
      buffer.writeln(message.content);
      buffer.writeln();
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    _downloadFile(
      buffer.toString(),
      'onemind-conversation-${DateTime.now().millisecondsSinceEpoch}.txt',
      'text/plain',
    );
  }

  /// Copy entire conversation to clipboard
  static String copyToClipboard(List<Message> messages) {
    final buffer = StringBuffer();

    for (final message in messages) {
      final role = message.isUser ? 'USER' : 'AGENT';
      buffer.writeln('[$role]');
      buffer.writeln(message.content);
      buffer.writeln();
    }

    return buffer.toString();
  }

  static void _downloadFile(String content, String filename, String mimeType) {
    final blob = html.Blob([content], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
           '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
