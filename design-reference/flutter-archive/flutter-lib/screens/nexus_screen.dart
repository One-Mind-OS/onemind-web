import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/nexus_service.dart';
import '../config/tactical_theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// NEXUS COMMAND CENTER — The God-View of OneMind OS
///
/// Layout:
///   ┌──────────────────────────────────────────────────────┐
///   │  HEADER: Nexus status + framework badges + stats     │
///   ├──────────────────────────────────────────────────────┤
///   │  COMMAND BAR: Text input + mode selector + send      │
///   ├──────────────────────┬────────────────────────────────┤
///   │  LEFT: Entity Grid   │  RIGHT: Live Event Stream     │
///   │  (agents/teams/bots) │  + Dispatch Results            │
///   │                      │                                │
///   └──────────────────────┴────────────────────────────────┘
/// ═══════════════════════════════════════════════════════════════
class NexusScreen extends ConsumerStatefulWidget {
  const NexusScreen({super.key});

  @override
  ConsumerState<NexusScreen> createState() => _NexusScreenState();
}

class _NexusScreenState extends ConsumerState<NexusScreen>
    with SingleTickerProviderStateMixin {
  final NexusService _nexus = NexusService();
  final TextEditingController _commandController = TextEditingController();
  final FocusNode _commandFocus = FocusNode();
  final ScrollController _eventScrollController = ScrollController();

  late AnimationController _pulseController;
  Timer? _refreshTimer;

  // State
  NexusOverview? _overview;
  List<NexusSystemEvent> _events = [];
  final List<_CommandEntry> _commandHistory = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  String _commandMode = 'auto'; // auto | direct | broadcast
  WebSocketChannel? _wsChannel;
  bool _wsConnected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _loadData();
    _connectWebSocket();

    // Refresh overview every 15 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadOverview(),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _nexus.getOverview(),
        _nexus.getEvents(limit: 100),
      ]);
      setState(() {
        _overview = results[0] as NexusOverview;
        _events = results[1] as List<NexusSystemEvent>;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadOverview() async {
    try {
      final overview = await _nexus.getOverview();
      if (mounted) setState(() => _overview = overview);
    } catch (_) {}
  }

  void _connectWebSocket() {
    try {
      _wsChannel = _nexus.connectStream();
      _wsChannel!.stream.listen(
        (message) {
          try {
            final event = NexusSystemEvent.fromJson(jsonDecode(message));
            if (mounted) {
              setState(() {
                _events.insert(0, event);
                if (_events.length > 200) _events.removeLast();
                _wsConnected = true;
              });
            }
          } catch (_) {}
        },
        onError: (_) {
          if (mounted) setState(() => _wsConnected = false);
          // Reconnect after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
        onDone: () {
          if (mounted) setState(() => _wsConnected = false);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
      );
      setState(() => _wsConnected = true);
    } catch (_) {
      setState(() => _wsConnected = false);
    }
  }

  Future<void> _sendCommand() async {
    final message = _commandController.text.trim();
    if (message.isEmpty) return;

    final entry = _CommandEntry(
      message: message,
      mode: _commandMode,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isSending = true;
      _commandHistory.insert(0, entry);
      _commandController.clear();
    });

    try {
      final result = await _nexus.command(
        message: message,
        mode: _commandMode,
        source: 'nexus-ui',
      );

      setState(() {
        entry.result = result;
        entry.status = 'completed';
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        entry.error = e.toString();
        entry.status = 'failed';
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    _commandController.dispose();
    _commandFocus.dispose();
    _eventScrollController.dispose();
    _wsChannel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 900;

    // Colors
    final bg = TacticalColors.background;
    final cardBg = TacticalColors.card;
    final borderColor = TacticalColors.border;
    final textColor = TacticalColors.textPrimary;
    final mutedText = TacticalColors.textMuted;
    final primary = TacticalColors.primary;
    final cyan = isDark ? TacticalColorsDark.cyan : TacticalColorsLight.cyan;
    final success = TacticalColors.success;
    final warning = TacticalColors.warning;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ═══ HEADER ═══
          _buildHeader(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
            success,
          ),

          // ═══ COMMAND BAR ═══
          _buildCommandBar(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
          ),

          // ═══ MAIN CONTENT ═══
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primary),
                        const SizedBox(height: 16),
                        Text(
                          'Connecting to Nexus...',
                          style: TextStyle(color: mutedText),
                        ),
                      ],
                    ),
                  )
                : _error != null
                ? _buildErrorState(primary, textColor, mutedText)
                : isWide
                ? _buildWideLayout(
                    cardBg,
                    borderColor,
                    textColor,
                    mutedText,
                    primary,
                    cyan,
                    success,
                    warning,
                  )
                : _buildNarrowLayout(
                    cardBg,
                    borderColor,
                    textColor,
                    mutedText,
                    primary,
                    cyan,
                    success,
                    warning,
                  ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
    Color success,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Animated Nexus icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(
                      alpha: 0.8 + 0.2 * _pulseController.value,
                    ),
                    cyan.withValues(alpha: 0.8 + 0.2 * _pulseController.value),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(
                      alpha: 0.3 + 0.2 * _pulseController.value,
                    ),
                    blurRadius: 8 + 4 * _pulseController.value,
                  ),
                ],
              ),
              child: const Icon(Icons.hub, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NEXUS',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status pill
                    _statusPill(
                      _overview?.nexusStarted == true ? 'ONLINE' : 'OFFLINE',
                      _overview?.nexusStarted == true ? success : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    _statusPill(
                      _wsConnected ? 'STREAM' : 'NO STREAM',
                      _wsConnected ? cyan : Colors.orange,
                    ),
                  ],
                ),
                Text(
                  'Legacy sees EVERYTHING — Meta-orchestration layer',
                  style: TextStyle(color: mutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          // Framework badges
          if (_overview != null) ...[
            for (final fw in _overview!.frameworks)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _frameworkBadge(fw, cyan),
              ),
            const SizedBox(width: 12),
            // Stats
            _statChip('${_overview!.totalEntities}', 'Entities', cyan),
            const SizedBox(width: 8),
            _statChip('${_overview!.totalEvents}', 'Events', primary),
            const SizedBox(width: 8),
            _statChip('${_overview!.activeDispatches}', 'Active', success),
          ],
          const SizedBox(width: 12),
          IconButton(
            onPressed: _loadData,
            icon: Icon(Icons.refresh, color: cyan, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  // ─── COMMAND BAR ───
  Widget _buildCommandBar(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Mode selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              color: TacticalColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeButton('auto', 'AUTO', Icons.auto_awesome, primary),
                _modeButton('direct', 'DIRECT', Icons.gps_fixed, cyan),
                _modeButton(
                  'broadcast',
                  'ALL',
                  Icons.cell_tower,
                  Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Voice input button
          Tooltip(
            message: 'Voice Input (coming soon)',
            child: IconButton(
              onPressed: () {
                // Placeholder for voice input integration
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Voice input: connect microphone via speech_to_text',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.mic_outlined, color: mutedText, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: TacticalColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: borderColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Image/vision input button
          Tooltip(
            message: 'Attach Image (vision)',
            child: IconButton(
              onPressed: () {
                // Placeholder for image picker integration
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vision input: attach image via file picker'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.image_outlined, color: mutedText, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: TacticalColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: borderColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Command input
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !event.isShiftPressed) {
                  _sendCommand();
                }
              },
              child: TextField(
                controller: _commandController,
                focusNode: _commandFocus,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _commandMode == 'auto'
                      ? 'Tell Legacy what to do... (AI routes automatically)'
                      : _commandMode == 'direct'
                      ? 'Command a specific entity...'
                      : 'Broadcast to all entities...',
                  hintStyle: TextStyle(
                    color: mutedText.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.terminal, color: primary, size: 18),
                  suffixIcon: _isSending
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primary,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _sendCommand,
                          icon: Icon(Icons.send, color: primary, size: 18),
                          tooltip: 'Send Command',
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: TacticalColors.input,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── WIDE LAYOUT (Desktop) ───
  Widget _buildWideLayout(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
    Color success,
    Color warning,
  ) {
    return Row(
      children: [
        // LEFT: Entities + Command History
        Expanded(
          flex: 5,
          child: _buildLeftPanel(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
            success,
            warning,
          ),
        ),
        // RIGHT: Live Events
        Container(width: 1, color: borderColor),
        Expanded(
          flex: 4,
          child: _buildEventStream(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
          ),
        ),
      ],
    );
  }

  // ─── NARROW LAYOUT (Mobile / Tablet) ───
  Widget _buildNarrowLayout(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
    Color success,
    Color warning,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'ENTITIES'),
              Tab(text: 'COMMANDS'),
              Tab(text: 'EVENTS'),
            ],
            indicatorColor: primary,
            labelColor: primary,
            unselectedLabelColor: mutedText,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEntityGrid(
                  cardBg,
                  borderColor,
                  textColor,
                  mutedText,
                  primary,
                  cyan,
                  success,
                  warning,
                ),
                _buildCommandHistory(
                  cardBg,
                  borderColor,
                  textColor,
                  mutedText,
                  primary,
                  cyan,
                ),
                _buildEventStream(
                  cardBg,
                  borderColor,
                  textColor,
                  mutedText,
                  primary,
                  cyan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── LEFT PANEL ───
  Widget _buildLeftPanel(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
    Color success,
    Color warning,
  ) {
    return Column(
      children: [
        // Entity grid
        Expanded(
          flex: 3,
          child: _buildEntityGrid(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
            success,
            warning,
          ),
        ),
        Container(height: 1, color: borderColor),
        // Command history
        Expanded(
          flex: 2,
          child: _buildCommandHistory(
            cardBg,
            borderColor,
            textColor,
            mutedText,
            primary,
            cyan,
          ),
        ),
      ],
    );
  }

  // ─── ENTITY GRID ───
  Widget _buildEntityGrid(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
    Color success,
    Color warning,
  ) {
    final entities = _overview?.entities ?? [];

    if (entities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 48,
              color: mutedText.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text('No entities registered', style: TextStyle(color: mutedText)),
            Text(
              'Start the backend to see agents & teams',
              style: TextStyle(
                color: mutedText.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Group by framework
    final byFramework = <String, List<NexusEntity>>{};
    for (final e in entities) {
      byFramework.putIfAbsent(e.framework, () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 14, color: cyan),
              const SizedBox(width: 6),
              Text(
                'ENTITIES',
                style: TextStyle(
                  color: cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '${entities.length} total',
                style: TextStyle(color: mutedText, fontSize: 11),
              ),
            ],
          ),
        ),
        // By framework
        for (final entry in byFramework.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(
              entry.key.toUpperCase(),
              style: TextStyle(
                color: primary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.value
                .map(
                  (e) => _entityCard(
                    e,
                    cardBg,
                    borderColor,
                    textColor,
                    mutedText,
                    success,
                    warning,
                    cyan,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _entityCard(
    NexusEntity entity,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color success,
    Color warning,
    Color cyan,
  ) {
    final typeIcon = _entityTypeIcon(entity.entityType);
    final statusColor = entity.isIdle
        ? success
        : entity.isBusy
        ? warning
        : Colors.red;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, size: 16, color: cyan),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entity.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entity.entityType.toUpperCase(),
            style: TextStyle(
              color: mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          if (entity.capabilities.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: entity.capabilities
                  .take(3)
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(color: cyan, fontSize: 9),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          // Modality badges
          if (entity.inputModalities.length > 1 ||
              entity.outputModalities.length > 1) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: [
                if (entity.supportsVoice)
                  _modalityBadge(Icons.mic, 'voice', Colors.purple),
                if (entity.supportsVision)
                  _modalityBadge(Icons.visibility, 'vision', Colors.teal),
                if (entity.supportsSensor)
                  _modalityBadge(Icons.sensors, 'sensor', Colors.amber),
              ],
            ),
          ],
          if (entity.tools.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${entity.tools.length} tools',
              style: TextStyle(
                color: mutedText.withValues(alpha: 0.6),
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── MODALITY BADGE ───
  Widget _modalityBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── COMMAND HISTORY ───
  Widget _buildCommandHistory(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.history, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                'DISPATCH LOG',
                style: TextStyle(
                  color: primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (_commandHistory.isNotEmpty)
                Text(
                  '${_commandHistory.length} commands',
                  style: TextStyle(color: mutedText, fontSize: 11),
                ),
            ],
          ),
        ),
        Expanded(
          child: _commandHistory.isEmpty
              ? Center(
                  child: Text(
                    'No commands sent yet',
                    style: TextStyle(
                      color: mutedText.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _commandHistory.length,
                  itemBuilder: (context, index) {
                    final entry = _commandHistory[index];
                    return _commandEntryTile(
                      entry,
                      cardBg,
                      borderColor,
                      textColor,
                      mutedText,
                      primary,
                      cyan,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _commandEntryTile(
    _CommandEntry entry,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
  ) {
    final statusColor = entry.status == 'completed'
        ? TacticalColors.success
        : entry.status == 'failed'
        ? TacticalColors.error
        : TacticalColors.warning;
    final statusIcon = entry.status == 'completed'
        ? Icons.check_circle
        : entry.status == 'failed'
        ? Icons.error
        : Icons.hourglass_top;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.mode.toUpperCase(),
                  style: TextStyle(
                    color: primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(statusIcon, size: 12, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  entry.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(entry.timestamp),
                style: TextStyle(color: mutedText, fontSize: 9),
              ),
            ],
          ),
          if (entry.result != null) ...[
            const SizedBox(height: 6),
            Text(
              '${entry.result!.dispatched} dispatched • ${entry.result!.results.where((r) => r.isCompleted).length} completed',
              style: TextStyle(color: TacticalColors.success, fontSize: 10),
            ),
            if (entry.result!.plan != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  entry.result!.plan!,
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          if (entry.error != null) ...[
            const SizedBox(height: 4),
            Text(
              entry.error!,
              style: TextStyle(color: TacticalColors.error, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ─── EVENT STREAM ───
  Widget _buildEventStream(
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _wsConnected ? TacticalColors.success : Colors.red,
                  boxShadow: _wsConnected
                      ? [
                          BoxShadow(
                            color: TacticalColors.success.withValues(
                              alpha: 0.6,
                            ),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE EVENT STREAM',
                style: TextStyle(
                  color: cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '${_events.length} events',
                style: TextStyle(color: mutedText, fontSize: 11),
              ),
            ],
          ),
        ),
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.stream,
                        size: 36,
                        color: mutedText.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Waiting for events...',
                        style: TextStyle(
                          color: mutedText.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _eventScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _eventTile(
                      event,
                      cardBg,
                      borderColor,
                      textColor,
                      mutedText,
                      primary,
                      cyan,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _eventTile(
    NexusSystemEvent event,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
    Color primary,
    Color cyan,
  ) {
    // Color-code by subject prefix
    Color subjectColor = mutedText;
    IconData subjectIcon = Icons.circle;
    if (event.subject.startsWith('nexus.')) {
      subjectColor = primary;
      subjectIcon = Icons.hub;
    } else if (event.subject.startsWith('digital.')) {
      subjectColor = cyan;
      subjectIcon = Icons.smart_toy;
    } else if (event.subject.startsWith('physical.')) {
      subjectColor = TacticalColors.success;
      subjectIcon = Icons.precision_manufacturing;
    } else if (event.subject.startsWith('system.')) {
      subjectColor = TacticalColors.warning;
      subjectIcon = Icons.monitor_heart;
    } else if (event.subject.startsWith('openmind.')) {
      subjectColor = const Color(0xFF8B5CF6);
      subjectIcon = Icons.psychology;
    } else if (event.subject.startsWith('human.')) {
      subjectColor = const Color(0xFFEC4899);
      subjectIcon = Icons.person;
    }

    final dataStr = event.data is Map
        ? (event.data as Map).entries
              .take(3)
              .map((e) => '${e.key}: ${e.value}')
              .join(' • ')
        : event.data?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: subjectColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: subjectColor, width: 2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(subjectIcon, size: 12, color: subjectColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.subject,
                    style: TextStyle(
                      color: subjectColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (dataStr.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        dataStr,
                        style: TextStyle(color: mutedText, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _formatTime(DateTime.tryParse(event.timestamp) ?? DateTime.now()),
              style: TextStyle(
                color: mutedText.withValues(alpha: 0.5),
                fontSize: 9,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ERROR STATE ───
  Widget _buildErrorState(Color primary, Color textColor, Color mutedText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TacticalColors.error),
          const SizedBox(height: 16),
          Text(
            'Nexus Connection Failed',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: mutedText, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ───

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _frameworkBadge(String framework, Color cyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cyan.withValues(alpha: 0.3)),
      ),
      child: Text(
        framework.toUpperCase(),
        style: TextStyle(
          color: cyan,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _modeButton(
    String mode,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isActive = _commandMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _commandMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? activeColor : TacticalColors.textDim,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : TacticalColors.textDim,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _entityTypeIcon(String type) {
    switch (type) {
      case 'agent':
        return Icons.smart_toy;
      case 'team':
        return Icons.groups;
      case 'robot':
        return Icons.precision_manufacturing;
      case 'drone':
        return Icons.flight;
      case 'sensor':
        return Icons.sensors;
      case 'workflow':
        return Icons.account_tree;
      case 'service':
        return Icons.cloud;
      case 'human':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

// ─── COMMAND ENTRY MODEL ───

class _CommandEntry {
  final String message;
  final String mode;
  final DateTime timestamp;
  String status;
  NexusCommandResult? result;
  String? error;

  _CommandEntry({
    required this.message,
    required this.mode,
    required this.timestamp,
  });
}
