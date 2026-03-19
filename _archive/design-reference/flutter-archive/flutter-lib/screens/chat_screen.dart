import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../config/tactical_theme.dart';
import '../models/message.dart';
import '../models/agent_event.dart';
import '../services/agent_service.dart';
import '../services/enhanced_agent_service.dart';
import '../services/export_service.dart';
import '../components/markdown_message.dart';
import '../components/typing_indicator.dart';
import '../components/agent_status_indicator.dart';
import '../components/message_actions.dart';
import '../components/quick_info_drawer.dart';
import '../providers/agent_config_provider.dart' as agent_config;
import '../widgets/tool_call_indicator.dart';

// Provider for AgentService (original)
final agentServiceProvider = Provider((ref) => AgentService());

// Provider for EnhancedAgentService (with status updates)
final enhancedAgentServiceProvider = Provider((ref) => EnhancedAgentService());

// Provider for messages
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>(
  (ref) => MessagesNotifier(),
);

// Provider for selected agent
final selectedAgentProvider = StateProvider<String>((ref) => 'Assistant');

// Note: Model selector removed - agents have pre-configured models
// Each agent in backend has its own model defined

class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void updateLastMessage(String content) {
    if (state.isEmpty) return;
    final updated = List<Message>.from(state);
    final last = updated.last;
    updated[updated.length - 1] = Message(
      content: last.content + content,
      isUser: last.isUser,
      timestamp: last.timestamp,
    );
    state = updated;
  }

  void removeLastMessage() {
    if (state.isEmpty) return;
    state = state.sublist(0, state.length - 1);
  }

  void deleteMessage(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Message>.from(state);
    updated.removeAt(index);
    state = updated;
  }

  void editMessage(int index, String newContent) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Message>.from(state);
    updated[index] = Message(
      content: newContent,
      isUser: updated[index].isUser,
      timestamp: updated[index].timestamp,
    );
    state = updated;
  }

  void clear() {
    state = [];
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentStatus;
  String? _currentTool;
  bool _showSettings = false;

  // File upload state
  final List<PlatformFile> _selectedFiles = [];
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'txt', 'md', 'doc', 'docx'];

  // Advanced AgentOS features
  final List<ToolCall> _currentToolCalls = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      // Validate file sizes
      final invalidFiles = <String>[];
      final validFiles = <PlatformFile>[];

      for (final file in result.files) {
        if (file.size > _maxFileSizeBytes) {
          invalidFiles.add('${file.name} (${(file.size / (1024 * 1024)).toStringAsFixed(1)}MB)');
        } else {
          validFiles.add(file);
        }
      }

      if (invalidFiles.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Files exceeding 10MB limit:\n${invalidFiles.join('\n')}',
              style: TextStyle(fontFamily: 'monospace'),
            ),
            backgroundColor: TacticalColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (validFiles.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(validFiles);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick files: $e',
              style: TextStyle(fontFamily: 'monospace'),
            ),
            backgroundColor: TacticalColors.error,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'pdf':
        return '📄';
      case 'txt':
      case 'md':
        return '📝';
      case 'doc':
      case 'docx':
        return '📋';
      default:
        return '📎';
    }
  }

  /// Check if a file is an image
  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension.toLowerCase());
  }

  /// Convert PlatformFile to ImageAttachment for vision support
  ImageAttachment? _fileToImageAttachment(PlatformFile file) {
    if (!_isImageFile(file.extension ?? '')) return null;
    if (file.bytes == null) return null;

    return ImageAttachment(
      base64Data: base64Encode(file.bytes!),
      mimeType: _getImageMimeType(file.extension!),
      fileName: file.name,
    );
  }

  /// Get MIME type from extension
  String _getImageMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // fallback
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty && _selectedFiles.isEmpty) return;

    final selectedAgent = ref.read(selectedAgentProvider);
    // Model is pre-configured per agent in backend

    // Clear any previous error and status
    setState(() {
      _errorMessage = null;
      _currentStatus = null;
      _currentTool = null;
    });

    // Extract image attachments for the user message
    List<ImageAttachment>? messageImages;
    if (_selectedFiles.isNotEmpty) {
      final images = _selectedFiles
          .map((file) => _fileToImageAttachment(file))
          .where((img) => img != null)
          .cast<ImageAttachment>()
          .toList();

      if (images.isNotEmpty) {
        messageImages = images;
      }
    }

    // Build message with file information
    String fullMessage = message;
    if (_selectedFiles.isNotEmpty) {
      final fileList = _selectedFiles.map((f) => f.name).join(', ');
      fullMessage = '$message\n\n[Attached: $fileList]';
    }

    // Add user message with image attachments
    ref.read(messagesProvider.notifier).addMessage(
          Message(
            content: fullMessage,
            isUser: true,
            images: messageImages, // Include images in message
          ),
        );

    _controller.clear();
    final filesToSend = List<PlatformFile>.from(_selectedFiles);
    setState(() {
      _isLoading = true;
      _selectedFiles.clear(); // Clear files after sending
    });
    _scrollToBottom();

    try {
      // Extract images for vision support (GPT-4o multimodal)
      List<ImageAttachment>? imageAttachments;

      if (filesToSend.isNotEmpty) {
        // Convert image files to ImageAttachment objects for vision
        final images = filesToSend
            .map((file) => _fileToImageAttachment(file))
            .where((img) => img != null)
            .cast<ImageAttachment>()
            .toList();

        if (images.isNotEmpty) {
          imageAttachments = images;
          setState(() {
            _currentStatus = 'Processing ${images.length} image(s) with GPT-4o vision...';
          });
        } else {
          // Non-image files - show informational message
          setState(() {
            _currentStatus = 'Note: Only images supported for vision. Other files shown for context.';
          });
        }

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final enhancedService = ref.read(enhancedAgentServiceProvider);
      final stream = enhancedService.sendMessageWithEvents(
        agentName: selectedAgent,
        message: message.isEmpty ? 'Please analyze the attached files.' : message,
        modelId: null, // Agent uses its pre-configured model
        images: imageAttachments, // Vision support - pass images if present
      );

      bool hasContent = false;

      await for (final event in stream) {
        switch (event.type) {
          case AgentEventType.agentStart:
            setState(() {
              _currentStatus = 'Starting...';
              _currentTool = null;
            });
            break;

          case AgentEventType.toolCall:
            setState(() {
              _currentStatus = 'Using tool';
              _currentTool = event.toolName;

              // Track tool call for transparency
              if (event.toolName != null) {
                _currentToolCalls.add(ToolCall(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  toolName: event.toolName!,
                  status: 'running',
                  timestamp: DateTime.now(),
                ));
              }
            });
            break;

          case AgentEventType.toolResult:
            setState(() {
              _currentStatus = 'Tool complete';
              _currentTool = event.toolName;

              // Update tool call status
              if (event.toolName != null && _currentToolCalls.isNotEmpty) {
                final toolCall = _currentToolCalls.lastWhere(
                  (t) => t.toolName == event.toolName && t.status == 'running',
                  orElse: () => _currentToolCalls.last,
                );
                final index = _currentToolCalls.indexOf(toolCall);
                if (index != -1) {
                  _currentToolCalls[index] = toolCall.copyWith(
                    status: 'complete',
                    result: 'Success',
                  );
                }
              }
            });
            break;

          case AgentEventType.content:
            if (!hasContent) {
              ref.read(messagesProvider.notifier).addMessage(
                    Message(content: '', isUser: false),
                  );
              hasContent = true;
              setState(() {
                _currentStatus = null;
                _currentTool = null;
              });
            }
            if (event.content != null) {
              ref.read(messagesProvider.notifier).updateLastMessage(event.content!);
            }
            break;

          case AgentEventType.agentComplete:
            setState(() {
              _currentStatus = null;
              _currentTool = null;
              _currentToolCalls.clear();
            });
            break;

          case AgentEventType.teamCoordination:
            setState(() {
              _currentStatus = 'Team coordinating';
              _currentTool = null;
            });
            break;
        }
        _scrollToBottom();
      }

      if (!hasContent) {
        setState(() => _errorMessage = 'No response received from agent');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
        _currentStatus = null;
        _currentTool = null;
      });
      _scrollToBottom();
    }
  }

  Widget _buildAgentChip(String agent, IconData icon) {
    final selectedAgent = ref.watch(selectedAgentProvider);
    final isSelected = selectedAgent == agent;

    return InkWell(
      onTap: _isLoading ? null : () {
        ref.read(selectedAgentProvider.notifier).state = agent;
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.primary.withValues(alpha: 0.15)
              : TacticalColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TacticalColors.primary.withValues(alpha: 0.5)
                : TacticalColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: TacticalColors.primary,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              agent,
              style: TextStyle(
                color: TacticalColors.primary,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final selectedAgent = ref.watch(selectedAgentProvider);

    // Listen to agent selection changes and update agent config
    ref.listen<String>(selectedAgentProvider, (previous, next) {
      ref.read(agent_config.agentConfigProvider.notifier).updateFromSelection(next);
    });

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TacticalColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TacticalColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.terminal,
                color: TacticalColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'ONEMIND OS',
              style: TextStyle(
                color: TacticalColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TacticalColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'v2',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Export button
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: TacticalColors.primary),
            tooltip: 'Export Conversation',
            color: TacticalColors.surface,
            onSelected: (value) {
              final messages = ref.read(messagesProvider);
              switch (value) {
                case 'markdown':
                  ExportService.exportAsMarkdown(messages);
                  break;
                case 'json':
                  ExportService.exportAsJson(messages);
                  break;
                case 'text':
                  ExportService.exportAsText(messages);
                  break;
                case 'copy':
                  ExportService.copyToClipboard(messages);
                  // Copy to clipboard here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Copied to clipboard',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: TacticalColors.primary,
                        ),
                      ),
                      backgroundColor: TacticalColors.surface,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'markdown',
                child: Row(
                  children: [
                    Icon(Icons.description, color: TacticalColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Export as Markdown',
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    Icon(Icons.code, color: TacticalColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Export as JSON',
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'text',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet, color: TacticalColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Export as Text',
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: TacticalColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Copy to Clipboard',
                      style: TextStyle(
                        color: TacticalColors.primary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Agent Info button
          IconButton(
            icon: Icon(Icons.info_outline, color: TacticalColors.primary),
            onPressed: () {
              setState(() => _showSettings = !_showSettings);
            },
            tooltip: 'Agent Info',
          ),
          // Clear button
          IconButton(
            icon: Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: () {
              ref.read(messagesProvider.notifier).clear();
            },
            tooltip: 'Clear Terminal',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: TacticalColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: TacticalColors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.terminal,
                            size: 48,
                            color: TacticalColors.primary,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          '> SYSTEM READY',
                          style: TextStyle(
                            fontSize: 16,
                            color: TacticalColors.primary.withValues(alpha: 0.7),
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Initialize command sequence...',
                          style: TextStyle(
                            fontSize: 12,
                            color: TacticalColors.primary.withValues(alpha: 0.5),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length +
                              (_currentStatus != null || _isLoading ? 1 : 0) +
                              (_errorMessage != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show error message at the end
                      if (_errorMessage != null &&
                          index == messages.length + (_currentStatus != null || _isLoading ? 1 : 0)) {
                        return ErrorMessage(
                          error: _errorMessage!,
                          onRetry: () {
                            setState(() => _errorMessage = null);
                            _sendMessage();
                          },
                        );
                      }

                      // Show status indicator if present (takes precedence over typing)
                      if (_currentStatus != null && index == messages.length) {
                        return AgentStatusIndicator(
                          status: _currentStatus!,
                          toolName: _currentTool,
                          agentName: ref.read(selectedAgentProvider),
                        );
                      }

                      // Show tool call indicators (AgentOS tool transparency)
                      if (_currentToolCalls.isNotEmpty && index == messages.length) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._currentToolCalls.map((call) => ToolCallIndicator(
                              toolName: call.toolName,
                              status: call.status,
                              result: call.result,
                              timestamp: call.timestamp,
                            )),
                            const SizedBox(height: 8),
                          ],
                        );
                      }

                      // Show typing indicator while loading (only if no status)
                      if (_isLoading && _currentStatus == null && index == messages.length) {
                        return const TypingIndicator();
                      }

                      // Show message with actions
                      final message = messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarkdownMessage(message: message),
                          MessageActions(
                            messageContent: message.content,
                            isUser: message.isUser,
                            onRegenerate: () async {
                              // Find the user message before this agent message
                              if (index > 0) {
                                final userMessage = messages[index - 1];
                                if (userMessage.isUser) {
                                  // Remove agent message and regenerate
                                  ref.read(messagesProvider.notifier).deleteMessage(index);
                                  _controller.text = userMessage.content;
                                  await _sendMessage();
                                }
                              }
                            },
                            onEdit: () {
                              // TODO: Implement inline editing
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(text: message.content);
                                  return AlertDialog(
                                    backgroundColor: TacticalColors.surface,
                                    title: Text(
                                      'Edit Message',
                                      style: TextStyle(
                                        color: TacticalColors.primary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    content: TextField(
                                      controller: controller,
                                      maxLines: 5,
                                      style: TextStyle(
                                        color: TacticalColors.textPrimary,
                                        fontFamily: 'monospace',
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: TacticalColors.primary.withValues(alpha: 0.3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: TacticalColors.primary.withValues(alpha: 0.7),
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref.read(messagesProvider.notifier).editMessage(
                                                index,
                                                controller.text,
                                              );
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(
                                            color: TacticalColors.primary,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: TacticalColors.surface,
                                  title: Text(
                                    'Delete Message',
                                    style: TextStyle(
                                      color: TacticalColors.error,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete this message?',
                                    style: TextStyle(
                                      color: TacticalColors.textPrimary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: TacticalColors.primary.withValues(alpha: 0.7),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(messagesProvider.notifier).deleteMessage(index);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: TacticalColors.error,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Modern large input area (Claude-style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: TacticalColors.background,
              border: Border(
                top: BorderSide(
                  color: TacticalColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // Large input container
                    Container(
                      decoration: BoxDecoration(
                        color: TacticalColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: TacticalColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Selected files display
                          if (_selectedFiles.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TacticalColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: TacticalColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedFiles.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final file = entry.value;
                                  final extension = file.extension ?? '';
                                  final sizeKB = (file.size / 1024).toStringAsFixed(1);

                                  // Show image preview for image files
                                  if (_isImageFile(extension) && file.bytes != null) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: TacticalColors.primary.withValues(alpha: 0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.memory(
                                              file.bytes!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () => _removeFile(index),
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: TacticalColors.background.withValues(alpha: 0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: TacticalColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  // Standard file chip for non-images
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: TacticalColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: TacticalColors.primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _getFileIcon(extension),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(width: 6),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: Text(
                                            file.name,
                                            style: TextStyle(
                                              color: TacticalColors.primary,
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '($sizeKB KB)',
                                          style: TextStyle(
                                            color: TacticalColors.primary.withValues(alpha: 0.5),
                                            fontFamily: 'monospace',
                                            fontSize: 9,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => _removeFile(index),
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: TacticalColors.primary.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          // Input field
                          TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: TacticalColors.textPrimary,
                              fontFamily: 'monospace',
                              fontSize: 15,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'How can I help you today?',
                              hintStyle: TextStyle(
                                color: TacticalColors.primary.withValues(alpha: 0.4),
                                fontFamily: 'monospace',
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: 12),
                          // Bottom row with controls
                          Row(
                            children: [
                              // File attachment button with badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: TacticalColors.primary.withValues(alpha: 0.7),
                                      size: 22,
                                    ),
                                    onPressed: _isLoading ? null : _pickFiles,
                                    tooltip: 'Attach files (jpg, png, pdf, txt, md, doc)',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  if (_selectedFiles.isNotEmpty)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: TacticalColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${_selectedFiles.length}',
                                          style: TextStyle(
                                            color: TacticalColors.background,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              // Agent selector
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: TacticalColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: TacticalColors.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedAgent,
                                  underline: SizedBox(),
                                  dropdownColor: TacticalColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  isDense: true,
                                  icon: Icon(
                                    Icons.expand_more,
                                    color: TacticalColors.primary.withValues(alpha: 0.7),
                                    size: 18,
                                  ),
                                  style: TextStyle(
                                    color: TacticalColors.primary,
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                  items: [
                                    // Individual Agents
                                    const DropdownMenuItem<String>(
                                      value: 'Assistant',
                                      child: Text('Assistant'),
                                    ),
                                    const DropdownMenuItem<String>(
                                      value: 'Researcher',
                                      child: Text('Researcher'),
                                    ),
                                    const DropdownMenuItem<String>(
                                      value: 'Analyst',
                                      child: Text('Analyst'),
                                    ),
                                    const DropdownMenuItem<String>(
                                      value: 'Coder',
                                      child: Text('Coder'),
                                    ),
                                    // Teams (with visual prefix)
                                    DropdownMenuItem<String>(
                                      value: 'Research Team',
                                      child: Row(
                                        children: [
                                          Text(
                                            '⚡ ',
                                            style: TextStyle(
                                              color: TacticalColors.primary.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text('Research Team'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Dev Team',
                                      child: Row(
                                        children: [
                                          Text(
                                            '⚡ ',
                                            style: TextStyle(
                                              color: TacticalColors.primary.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text('Dev Team'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'Full Team',
                                      child: Row(
                                        children: [
                                          Text(
                                            '⚡ ',
                                            style: TextStyle(
                                              color: TacticalColors.primary.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text('Full Team'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: _isLoading ? null : (value) {
                                    if (value != null) {
                                      ref.read(selectedAgentProvider.notifier).state = value;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              // Model selector removed - agents have pre-configured models
                              // Send button
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      TacticalColors.primary.withValues(alpha: 0.8),
                                      TacticalColors.primary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TacticalColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _sendMessage,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  TacticalColors.background,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.arrow_upward,
                                              color: TacticalColors.background,
                                              size: 18,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // File upload helper text
                    if (_selectedFiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Tip: Click + to attach files (max 10MB each)',
                          style: TextStyle(
                            color: TacticalColors.primary.withValues(alpha: 0.4),
                            fontFamily: 'monospace',
                            fontSize: 9,
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    // Agent & Team suggestion chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildAgentChip('Assistant', Icons.psychology),
                        _buildAgentChip('Researcher', Icons.search),
                        _buildAgentChip('Analyst', Icons.analytics),
                        _buildAgentChip('Coder', Icons.code),
                        _buildAgentChip('Research Team', Icons.groups),
                        _buildAgentChip('Dev Team', Icons.engineering),
                        _buildAgentChip('Full Team', Icons.group_work),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
          ),
          // Quick Info Drawer overlay (read-only agent info)
          if (_showSettings)
            Positioned(
              right: MediaQuery.of(context).size.width < 600 ? 0 : 0,
              bottom: MediaQuery.of(context).size.width < 600 ? 0 : 0,
              left: MediaQuery.of(context).size.width < 600 ? 0 : null,
              top: MediaQuery.of(context).size.width < 600 ? null : 0,
              child: QuickInfoDrawer(
                onClose: () {
                  setState(() => _showSettings = false);
                },
              ),
            ),
        ],
      ),
    );
  }
}

