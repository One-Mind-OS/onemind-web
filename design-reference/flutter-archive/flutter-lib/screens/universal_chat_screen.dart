import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/tactical_theme.dart';
import '../models/message.dart';
import '../models/agent_event.dart';
import '../services/universal_chat_service.dart';
import '../components/markdown_message.dart';
import '../components/typing_indicator.dart';
import '../components/message_actions.dart';
import '../widgets/tool_call_indicator.dart';

// =============================================================================
// PROVIDERS
// =============================================================================

final universalChatServiceProvider = Provider((ref) => UniversalChatService());

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<Message>>(
  (ref) => ChatMessagesNotifier(),
);

final chatModeProvider = StateProvider<ChatMode>((ref) => ChatMode.agent);
final selectedModelProvider = StateProvider<String?>((ref) => 'gpt-4o');
final selectedAgentIdProvider = StateProvider<String?>((ref) => null);
final selectedTeamIdProvider = StateProvider<String?>((ref) => null);
final enabledToolsProvider = StateProvider<List<String>>((ref) => []);
final webSearchEnabledProvider = StateProvider<bool>((ref) => false);

final availableModelsProvider = FutureProvider<List<ModelInfo>>((ref) async {
  final service = ref.read(universalChatServiceProvider);
  return await service.getModels();
});

final availableToolsProvider = FutureProvider<List<ToolInfo>>((ref) async {
  final service = ref.read(universalChatServiceProvider);
  return await service.getTools();
});

final availableAgentsProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final service = ref.read(universalChatServiceProvider);
  return await service.getAgents();
});

final availableTeamsProvider =
    FutureProvider<List<Map<String, String>>>((ref) async {
  final service = ref.read(universalChatServiceProvider);
  return await service.getTeams();
});

class ChatMessagesNotifier extends StateNotifier<List<Message>> {
  ChatMessagesNotifier() : super([]);

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

  void deleteMessage(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Message>.from(state);
    updated.removeAt(index);
    state = updated;
  }

  void clear() {
    state = [];
  }
}

// =============================================================================
// CHAT SCREEN — Claude-inspired, OneMind-powered
// =============================================================================

class UniversalChatScreen extends ConsumerStatefulWidget {
  const UniversalChatScreen({super.key});

  @override
  ConsumerState<UniversalChatScreen> createState() =>
      _UniversalChatScreenState();
}

class _UniversalChatScreenState extends ConsumerState<UniversalChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentStatus;
  final List<PlatformFile> _selectedFiles = [];
  final List<ToolCall> _currentToolCalls = [];

  // Voice input
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  static const int _maxFileSizeBytes = 10 * 1024 * 1024;
  static const List<String> _allowedExtensions = [
    'jpg', 'jpeg', 'png', 'pdf', 'txt', 'md', 'py', 'dart', 'js', 'ts',
    'json', 'yaml', 'yml', 'csv', 'html', 'css',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Update send button appearance when text changes
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final validFiles =
          result.files.where((f) => f.size <= _maxFileSizeBytes).toList();
      if (validFiles.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(validFiles);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick files: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty && _selectedFiles.isEmpty) return;

    final chatMode = ref.read(chatModeProvider);
    final selectedModel = ref.read(selectedModelProvider);
    final selectedAgentId = ref.read(selectedAgentIdProvider);
    final selectedTeamId = ref.read(selectedTeamIdProvider);
    final enabledTools = ref.read(enabledToolsProvider);

    setState(() {
      _errorMessage = null;
      _currentStatus = null;
    });

    String fullMessage = message;
    if (_selectedFiles.isNotEmpty) {
      final fileList = _selectedFiles.map((f) => f.name).join(', ');
      fullMessage = '$message\n\n[Attached: $fileList]';
    }

    ref.read(chatMessagesProvider.notifier).addMessage(
          Message(content: fullMessage, isUser: true),
        );

    _controller.clear();
    setState(() {
      _isLoading = true;
      _selectedFiles.clear();
    });
    _scrollToBottom();

    try {
      final service = ref.read(universalChatServiceProvider);

      String? targetId;
      if (chatMode == ChatMode.agent) targetId = selectedAgentId;
      if (chatMode == ChatMode.team) targetId = selectedTeamId;

      final stream = service.sendMessage(
        message:
            message.isEmpty ? 'Please analyze the attached files.' : message,
        mode: chatMode,
        targetId: targetId,
        modelId: chatMode == ChatMode.direct ? selectedModel : null,
        tools: chatMode == ChatMode.direct ? enabledTools : null,
      );

      bool hasContent = false;

      await for (final event in stream) {
        switch (event.type) {
          case AgentEventType.agentStart:
            setState(() {
              _currentStatus = 'Thinking...';
            });
            break;
          case AgentEventType.toolCall:
            setState(() {
              _currentStatus = 'Using ${event.toolName ?? "tool"}...';
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
              _currentStatus = null;
            });
            break;
          case AgentEventType.content:
            if (!hasContent) {
              ref.read(chatMessagesProvider.notifier).addMessage(
                    Message(content: '', isUser: false),
                  );
              hasContent = true;
              setState(() {
                _currentStatus = null;
              });
            }
            if (event.content != null) {
              ref
                  .read(chatMessagesProvider.notifier)
                  .updateLastMessage(event.content!);
            }
            break;
          case AgentEventType.agentComplete:
            setState(() {
              _currentStatus = null;
              _currentToolCalls.clear();
            });
            break;
          case AgentEventType.teamCoordination:
            setState(() {
              _currentStatus = '${event.agentName} is working...';
            });
            break;
        }
        _scrollToBottom();
      }

      if (!hasContent) {
        setState(() => _errorMessage = 'No response received');
      }
    } catch (e) {
      setState(() =>
          _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
        _currentStatus = null;
      });
      _scrollToBottom();
    }
  }

  void _insertQuickPrompt(String prompt) {
    _controller.text = prompt;
    _inputFocusNode.requestFocus();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final chatMode = ref.watch(chatModeProvider);
    final isDark = TacticalColors.currentTheme == AppThemeMode.dark;

    // Warm background colors inspired by Claude
    final bgColor = isDark
        ? const Color(0xFF1A1816) // warm dark
        : const Color(0xFFFAF6F1); // warm cream
    final inputBgColor = isDark
        ? const Color(0xFF2A2622)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF3D3832)
        : const Color(0xFFE8E0D8);
    final textColor = isDark
        ? const Color(0xFFF5F0EB)
        : const Color(0xFF2D2A26);
    final textMutedColor = isDark
        ? const Color(0xFF9A9488)
        : const Color(0xFF8A8278);
    final accentColor = const Color(0xFFD2775A); // warm coral/terracotta

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar: mode tabs ───
            _buildTopBar(chatMode, bgColor, textColor, textMutedColor, accentColor, borderColor),

            // ─── Main content ───
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState(bgColor, textColor, textMutedColor, accentColor, inputBgColor, borderColor)
                  : _buildConversation(messages, bgColor, textColor, textMutedColor, accentColor, inputBgColor, borderColor),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP BAR — Mode tabs centered, like Claude's Chat|Cowork|Code
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTopBar(
    ChatMode chatMode,
    Color bgColor,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabPill('Chat', ChatMode.direct, chatMode, textColor, textMutedColor, accentColor, bgColor),
                _buildTabPill('Agent', ChatMode.agent, chatMode, textColor, textMutedColor, accentColor, bgColor),
                _buildTabPill('Team', ChatMode.team, chatMode, textColor, textMutedColor, accentColor, bgColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(
    String label,
    ChatMode mode,
    ChatMode currentMode,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
    Color bgColor,
  ) {
    final isSelected = mode == currentMode;
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => ref.read(chatModeProvider.notifier).state = mode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? textColor : textMutedColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE — Greeting + centered input
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
    Color bgColor,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
    Color inputBgColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // ─── Greeting ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // OneMind sparkle icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_getGreeting()}, Commander',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: textColor,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // ─── Input box (Claude-style) ───
              _buildInputBox(inputBgColor, borderColor, textColor, textMutedColor, accentColor),

              const SizedBox(height: 20),

              // ─── Quick action chips ───
              _buildQuickActions(borderColor, textMutedColor, accentColor),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSATION VIEW — Messages + input at bottom
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildConversation(
    List<Message> messages,
    Color bgColor,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
    Color inputBgColor,
    Color borderColor,
  ) {
    return Column(
      children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: messages.length +
                (_currentStatus != null || _isLoading ? 1 : 0) +
                (_errorMessage != null ? 1 : 0),
            itemBuilder: (context, index) {
              // Error
              if (_errorMessage != null &&
                  index ==
                      messages.length +
                          (_currentStatus != null || _isLoading ? 1 : 0)) {
                return _buildErrorBanner(bgColor, textColor);
              }

              // Status
              if (_currentStatus != null && index == messages.length) {
                return _buildStatusIndicator(textMutedColor, accentColor);
              }

              // Typing
              if (_isLoading &&
                  _currentStatus == null &&
                  index == messages.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: const TypingIndicator(),
                    ),
                  ),
                );
              }

              // Message
              if (index < messages.length) {
                return _buildMessageBubble(
                    messages[index], index, textColor, textMutedColor, accentColor, bgColor);
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _buildInputBox(
                  inputBgColor, borderColor, textColor, textMutedColor, accentColor),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE BUBBLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMessageBubble(
    Message message,
    int index,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
    Color bgColor,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role label
              Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 16),
                child: Row(
                  children: [
                    if (message.isUser) ...[
                      Icon(Icons.person_outline, size: 16, color: textMutedColor),
                      const SizedBox(width: 6),
                      Text(
                        'You',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OneMind',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Message content
              MarkdownMessage(message: message),

              // Actions
              MessageActions(
                messageContent: message.content,
                isUser: message.isUser,
                onRegenerate: () {},
                onEdit: () {},
                onDelete: () {
                  ref.read(chatMessagesProvider.notifier).deleteMessage(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT BOX — Claude-style rounded container
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInputBox(
    Color inputBgColor,
    Color borderColor,
    Color textColor,
    Color textMutedColor,
    Color accentColor,
  ) {
    final chatMode = ref.watch(chatModeProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final modelsAsync = ref.watch(availableModelsProvider);
    final agentsAsync = ref.watch(availableAgentsProvider);
    final teamsAsync = ref.watch(availableTeamsProvider);

    return Container(
      decoration: BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selected files chips
          if (_selectedFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedFiles.asMap().entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          e.value.name,
                          style: TextStyle(fontSize: 12, color: textColor),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeFile(e.key),
                          child: Icon(Icons.close, size: 14, color: textMutedColor),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Text field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'How can I help you today?',
                hintStyle: TextStyle(
                  color: textMutedColor.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),

          // Bottom toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                // ─── Plus button (popover menu) ───
                _buildPlusButton(textMutedColor, accentColor, textColor),

                // ─── Voice button ───
                GestureDetector(
                  onTap: _isLoading ? null : _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? accentColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? accentColor : textMutedColor,
                      size: 20,
                    ),
                  ),
                ),

                const Spacer(),

                // ─── Model/Agent/Team selector ───
                _buildTargetSelector(chatMode, selectedModel, modelsAsync,
                    agentsAsync, teamsAsync, textColor, textMutedColor),

                const SizedBox(width: 8),

                // ─── Send button ───
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (_controller.text.trim().isNotEmpty || _selectedFiles.isNotEmpty)
                          ? accentColor
                          : accentColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PLUS BUTTON — Claude-style popover with OneMind features
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPlusButton(Color textMutedColor, Color accentColor, Color textColor) {
    final isDark = TacticalColors.currentTheme == AppThemeMode.dark;
    final menuBg = isDark ? const Color(0xFF2A2622) : Colors.white;
    final webSearchEnabled = ref.watch(webSearchEnabledProvider);
    final toolsAsync = ref.watch(availableToolsProvider);
    final enabledTools = ref.watch(enabledToolsProvider);

    return PopupMenuButton<String>(
      icon: Icon(Icons.add, color: textMutedColor, size: 22),
      tooltip: 'Attach & configure',
      color: menuBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, -16),
      position: PopupMenuPosition.over,
      onSelected: (value) {
        switch (value) {
          case 'files':
            _pickFiles();
            break;
          case 'web_search':
            ref.read(webSearchEnabledProvider.notifier).state = !webSearchEnabled;
            break;
          case 'machine_control':
            _toggleTool('machine_control', enabledTools);
            break;
        }
      },
      itemBuilder: (context) => [
        // ─── Files ───
        PopupMenuItem(
          value: 'files',
          child: _menuRow(Icons.attach_file_outlined, 'Add files or photos', textColor),
        ),

        // ─── Divider ───
        const PopupMenuDivider(),

        // ─── Web search ───
        PopupMenuItem(
          value: 'web_search',
          child: Row(
            children: [
              Icon(Icons.language, size: 18, color: webSearchEnabled ? accentColor : textMutedColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Web search',
                  style: TextStyle(
                    fontSize: 14,
                    color: webSearchEnabled ? accentColor : textColor,
                  ),
                ),
              ),
              if (webSearchEnabled)
                Icon(Icons.check, size: 16, color: accentColor),
            ],
          ),
        ),

        // ─── Machine control ───
        PopupMenuItem(
          value: 'machine_control',
          child: Row(
            children: [
              Icon(Icons.terminal, size: 18,
                  color: enabledTools.contains('machine_control') ? accentColor : textMutedColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Machine control',
                  style: TextStyle(
                    fontSize: 14,
                    color: enabledTools.contains('machine_control') ? accentColor : textColor,
                  ),
                ),
              ),
              if (enabledTools.contains('machine_control'))
                Icon(Icons.check, size: 16, color: accentColor),
            ],
          ),
        ),

        // ─── Divider ───
        const PopupMenuDivider(),

        // ─── Tools submenu header ───
        PopupMenuItem(
          enabled: false,
          height: 28,
          child: Text(
            'TOOLS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textMutedColor,
              letterSpacing: 1,
            ),
          ),
        ),

        // ─── Dynamic tools from backend ───
        ...toolsAsync.when(
          data: (tools) => tools
              .take(6)
              .map((tool) {
                final isEnabled = enabledTools.contains(tool.id);
                return PopupMenuItem<String>(
                  value: 'tool_${tool.id}',
                  onTap: () => _toggleTool(tool.id, enabledTools),
                  child: Row(
                    children: [
                      Icon(
                        _getToolIcon(tool.category),
                        size: 18,
                        color: isEnabled ? accentColor : textMutedColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tool.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: isEnabled ? accentColor : textColor,
                          ),
                        ),
                      ),
                      if (isEnabled)
                        Icon(Icons.check, size: 16, color: accentColor),
                    ],
                  ),
                );
              })
              .toList(),
          loading: () => [
            PopupMenuItem(
              enabled: false,
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: textMutedColor),
              ),
            ),
          ],
          error: (_, _) => [],
        ),
      ],
    );
  }

  void _toggleTool(String toolId, List<String> currentTools) {
    final updated = List<String>.from(currentTools);
    if (updated.contains(toolId)) {
      updated.remove(toolId);
    } else {
      updated.add(toolId);
    }
    ref.read(enabledToolsProvider.notifier).state = updated;
  }

  IconData _getToolIcon(String category) {
    switch (category.toLowerCase()) {
      case 'search': return Icons.search;
      case 'code': return Icons.code;
      case 'file': return Icons.folder_outlined;
      case 'shell': return Icons.terminal;
      case 'docker': return Icons.view_in_ar;
      case 'python': return Icons.data_object;
      case 'web': return Icons.language;
      case 'api': return Icons.api;
      default: return Icons.build_outlined;
    }
  }

  Widget _menuRow(IconData icon, String label, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textColor.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: textColor)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TARGET SELECTOR — model/agent/team dropdown
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTargetSelector(
    ChatMode chatMode,
    String? selectedModel,
    AsyncValue<List<ModelInfo>> modelsAsync,
    AsyncValue<List<Map<String, String>>> agentsAsync,
    AsyncValue<List<Map<String, String>>> teamsAsync,
    Color textColor,
    Color textMutedColor,
  ) {
    String displayLabel = '';
    List<PopupMenuEntry<String>> items = [];

    switch (chatMode) {
      case ChatMode.direct:
        displayLabel = modelsAsync.when(
          data: (models) {
            final m = models.firstWhere(
              (m) => m.id == selectedModel,
              orElse: () => models.isNotEmpty ? models.first : ModelInfo(id: 'gpt-4o', name: 'GPT-4o', provider: 'openai', description: '', capabilities: []),
            );
            return m.name;
          },
          loading: () => 'Loading...',
          error: (_, _) => 'Error',
        );
        items = modelsAsync.when(
          data: (models) => models
              .map((m) => PopupMenuItem<String>(
                    value: m.id,
                    child: Text(m.name, style: TextStyle(fontSize: 13, color: textColor)),
                  ))
              .toList(),
          loading: () => [],
          error: (_, _) => [],
        );
        break;

      case ChatMode.agent:
        final agentId = ref.watch(selectedAgentIdProvider);
        displayLabel = agentsAsync.when(
          data: (agents) {
            if (agents.isEmpty) return 'No agents';
            final a = agents.firstWhere(
              (a) => a['id'] == agentId,
              orElse: () => agents.first,
            );
            return a['name'] ?? 'Agent';
          },
          loading: () => 'Loading...',
          error: (_, _) => 'Error',
        );
        items = agentsAsync.when(
          data: (agents) => agents
              .map((a) => PopupMenuItem<String>(
                    value: a['id'],
                    child: Text(a['name'] ?? '', style: TextStyle(fontSize: 13, color: textColor)),
                  ))
              .toList(),
          loading: () => [],
          error: (_, _) => [],
        );
        break;

      case ChatMode.team:
        final teamId = ref.watch(selectedTeamIdProvider);
        displayLabel = teamsAsync.when(
          data: (teams) {
            if (teams.isEmpty) return 'No teams';
            final t = teams.firstWhere(
              (t) => t['id'] == teamId,
              orElse: () => teams.first,
            );
            return t['name'] ?? 'Team';
          },
          loading: () => 'Loading...',
          error: (_, _) => 'Error',
        );
        items = teamsAsync.when(
          data: (teams) => teams
              .map((t) => PopupMenuItem<String>(
                    value: t['id'],
                    child: Text(t['name'] ?? '', style: TextStyle(fontSize: 13, color: textColor)),
                  ))
              .toList(),
          loading: () => [],
          error: (_, _) => [],
        );
        break;
    }

    final isDark = TacticalColors.currentTheme == AppThemeMode.dark;
    final menuBg = isDark ? const Color(0xFF2A2622) : Colors.white;

    return PopupMenuButton<String>(
      color: menuBg,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (chatMode) {
          case ChatMode.direct:
            ref.read(selectedModelProvider.notifier).state = value;
            break;
          case ChatMode.agent:
            ref.read(selectedAgentIdProvider.notifier).state = value;
            break;
          case ChatMode.team:
            ref.read(selectedTeamIdProvider.notifier).state = value;
            break;
        }
      },
      itemBuilder: (_) => items,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textMutedColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 16, color: textMutedColor),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // QUICK ACTION CHIPS — like Claude's "Learn, Strategize, Write"
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActions(
    Color borderColor,
    Color textMutedColor,
    Color accentColor,
  ) {
    final chips = [
      _QuickAction(Icons.build_outlined, 'Build', 'Help me build a new feature'),
      _QuickAction(Icons.search, 'Research', 'Research this topic in depth'),
      _QuickAction(Icons.smart_toy_outlined, 'Automate', 'Help me automate a workflow'),
      _QuickAction(Icons.rocket_launch_outlined, 'Deploy', 'Help me deploy to production'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: chips.map((chip) {
        return GestureDetector(
          onTap: () => _insertQuickPrompt(chip.prompt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chip.icon, size: 16, color: textMutedColor),
                const SizedBox(width: 8),
                Text(
                  chip.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: textMutedColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS & ERROR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusIndicator(Color textMutedColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 11),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(accentColor),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _currentStatus ?? 'Thinking...',
                style: TextStyle(
                  fontSize: 13,
                  color: textMutedColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _errorMessage = null),
                child: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper models
// =============================================================================

class _QuickAction {
  final IconData icon;
  final String label;
  final String prompt;
  const _QuickAction(this.icon, this.label, this.prompt);
}
