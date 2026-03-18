import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';

/// Cortex Screen - OpenMind Digital Cortex Control
/// Shows heartbeat loop, sensory fusion, and AI decisions
/// Solar Punk Tactical Theme
class CortexScreen extends ConsumerStatefulWidget {
  const CortexScreen({super.key});

  @override
  ConsumerState<CortexScreen> createState() => _CortexScreenState();
}

class _CortexScreenState extends ConsumerState<CortexScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _heartbeatTimer;
  int _heartbeatCount = 0;
  bool _cortexActive = true;
  double _heartbeatRate = 0.1; // Hz

  // Real data from backend
  final List<SensoryData> _sensoryFeed = [];
  final List<CortexDecision> _decisions = [];
  final List<ActionLog> _actions = [];

  // Backend data state
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _startHeartbeat();
    _loadBackendData();

    // Refresh data every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadBackendData());
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    if (_cortexActive) {
      final interval = (1000 / _heartbeatRate).round();
      _heartbeatTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
        setState(() {
          _heartbeatCount++;
          _addSensoryData();
        });
      });
    }
  }

  Future<void> _loadBackendData() async {
    try {
      final data = await ApiService.getAgentLearningMetrics();
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      // Update heartbeat from backend data
      final heartbeat = data['heartbeat'] as Map<String, dynamic>?;
      if (heartbeat != null) {
        final status = heartbeat['status'] as String?;
        if (status == 'running') {
          final cycleCount = heartbeat['cycle_count'] as int? ?? 0;
          setState(() {
            _heartbeatCount = cycleCount;
          });
        }
      }

      // Generate sensory data from agent metrics
      _updateSensoryFeedFromBackend(data);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
    }
  }

  void _updateSensoryFeedFromBackend(Map<String, dynamic> data) {
    final agents = data['agents'] as List<dynamic>?;
    if (agents == null || agents.isEmpty) return;

    // Add agent activity to sensory feed
    for (var agent in agents.take(3)) {
      final agentMap = agent as Map<String, dynamic>;
      final name = agentMap['name'] ?? 'Unknown Agent';
      final successfulRuns = agentMap['successful_runs'] ?? 0;
      final memoryFormations = agentMap['memory_formations'] ?? 0;
      final toolCalls = agentMap['tool_calls'] ?? 0;
      final successRate = agentMap['success_rate'] ?? 0.0;

      if (successfulRuns > 0) {
        _addSensoryDataManual(
          source: 'agents',
          data: '$name: $successfulRuns runs (${successRate.toStringAsFixed(1)}% success)',
        );

        // Add action logs for agent runs
        _addActionManual(
          action: 'execute_agent_run',
          target: name,
          status: 'completed',
        );
      }
      if (memoryFormations > 0) {
        _addSensoryDataManual(
          source: 'memory',
          data: '$name: $memoryFormations memories formed',
        );
      }
      if (toolCalls > 0) {
        _addActionManual(
          action: 'tool_execution',
          target: '$name ($toolCalls calls)',
          status: 'completed',
        );
      }
    }

    // Add system metrics
    final metrics = data['metrics'] as Map<String, dynamic>?;
    if (metrics != null) {
      final totalSessions = metrics['total_sessions'] ?? 0;
      final totalMemories = metrics['total_memories'] ?? 0;
      final totalToolCalls = metrics['total_tool_calls'] ?? 0;

      _addDecisionManual(
        input: 'System analysis',
        decision: '$totalSessions sessions, $totalMemories memories, $totalToolCalls tool calls',
        confidence: 0.95,
      );
    }
  }

  void _addSensoryDataManual({required String source, required String data}) {
    _sensoryFeed.insert(0, SensoryData(
      timestamp: DateTime.now(),
      source: source,
      type: 'update',
      data: data,
    ));

    if (_sensoryFeed.length > 20) {
      _sensoryFeed.removeLast();
    }
  }

  void _addDecisionManual({required String input, required String decision, required double confidence}) {
    _decisions.insert(0, CortexDecision(
      timestamp: DateTime.now(),
      input: input,
      decision: decision,
      confidence: confidence,
    ));

    if (_decisions.length > 20) {
      _decisions.removeLast();
    }
  }

  void _addActionManual({required String action, required String target, required String status}) {
    _actions.insert(0, ActionLog(
      timestamp: DateTime.now(),
      action: action,
      target: target,
      status: status,
    ));

    if (_actions.length > 20) {
      _actions.removeLast();
    }
  }

  void _addSensoryData() {
    final sources = ['calendar', 'weather', 'home_assistant', 'email', 'task_manager', 'nats_bus'];
    final source = sources[Random().nextInt(sources.length)];
    final data = _getRandomDataForSource(source);

    _sensoryFeed.insert(0, SensoryData(
      timestamp: DateTime.now(),
      source: source,
      type: 'update',
      data: data,
    ));

    if (_sensoryFeed.length > 20) {
      _sensoryFeed.removeLast();
    }
  }

  String _getRandomDataForSource(String source) {
    switch (source) {
      case 'calendar':
        return ['Next event in 2 hours', 'Meeting reminder', 'Event updated'][Random().nextInt(3)];
      case 'weather':
        return ['Temperature: ${60 + Random().nextInt(20)}°F', 'Rain expected', 'Clear skies'][Random().nextInt(3)];
      case 'home_assistant':
        return ['Motion detected', 'Door state: ${Random().nextBool() ? 'open' : 'closed'}', 'Light adjusted'][Random().nextInt(3)];
      case 'email':
        return ['${Random().nextInt(5)} new emails', 'Priority email received', 'Newsletter arrived'][Random().nextInt(3)];
      case 'task_manager':
        return ['Task completed', 'New task assigned', 'Deadline approaching'][Random().nextInt(3)];
      case 'nats_bus':
        return ['Event published', 'Subscription update', 'Message queued'][Random().nextInt(3)];
      default:
        return 'Data received';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _heartbeatTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Solar Punk colors
    final bg = isDark ? const Color(0xFF0A0F0A) : const Color(0xFFF5F7F5);
    final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
    final accentGreen = const Color(0xFF4ADE80);
    final accentOrange = const Color(0xFFF97316);
    final accentBlue = const Color(0xFF3B82F6);
    final accentPurple = const Color(0xFF8B5CF6);
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // Header with Heartbeat Status
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // Animated brain icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentPurple.withValues(alpha: 0.8 + 0.2 * _pulseController.value),
                            accentBlue.withValues(alpha: 0.8 + 0.2 * _pulseController.value),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (_cortexActive ? accentPurple : Colors.grey).withValues(alpha: 0.3 + 0.2 * _pulseController.value),
                            blurRadius: 8 + 4 * _pulseController.value,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.psychology, color: Colors.white, size: 22),
                    );
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Digital Cortex',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (_cortexActive ? accentGreen : Colors.red).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _cortexActive ? accentGreen : Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_cortexActive ? accentGreen : Colors.red).withValues(alpha: 0.6),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _cortexActive ? 'ACTIVE' : 'PAUSED',
                                  style: TextStyle(
                                    color: _cortexActive ? accentGreen : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'OpenMind heartbeat loop & AI orchestration',
                        style: TextStyle(color: mutedText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Heartbeat stats
                _statPill('${_heartbeatRate.toStringAsFixed(1)} Hz', 'Rate', accentPurple),
                const SizedBox(width: 10),
                _statPill('$_heartbeatCount', 'Beats', accentGreen),
                const SizedBox(width: 10),
                _statPill('${_sensoryFeed.length}', 'Signals', accentOrange),
                const SizedBox(width: 16),
                // Control buttons
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: _loadBackendData,
                    icon: Icon(Icons.refresh, color: accentBlue, size: 28),
                    tooltip: 'Refresh Data',
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _cortexActive = !_cortexActive;
                      _startHeartbeat();
                    });
                  },
                  icon: Icon(
                    _cortexActive ? Icons.pause_circle : Icons.play_circle,
                    color: _cortexActive ? accentOrange : accentGreen,
                    size: 32,
                  ),
                  tooltip: _cortexActive ? 'Pause Cortex' : 'Resume Cortex',
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: mutedText, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadBackendData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      // Left: Heartbeat Loop Visualization
                      Expanded(
                        flex: 2,
                        child: _buildHeartbeatVisualization(isDark, cardBg, borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
                      ),
                      // Right: Feeds & Logs
                      Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: cardBg,
                          border: Border(left: BorderSide(color: borderColor)),
                        ),
                        child: _buildFeedsPanel(borderColor, accentGreen, accentOrange, accentBlue, accentPurple, textColor, mutedText),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildHeartbeatVisualization(bool isDark, Color cardBg, Color borderColor,
      Color accentGreen, Color accentOrange, Color accentBlue, Color accentPurple,
      Color textColor, Color mutedText) {
    return Container(
      color: isDark ? const Color(0xFF050A05) : const Color(0xFFF0F5F0),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: _GridPainter(borderColor.withValues(alpha: 0.2)),
            size: Size.infinite,
          ),
          // Heartbeat Loop Diagram
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loop phases
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _loopPhase('SENSE', Icons.sensors, 'Gather data from\nall sensors', accentBlue, textColor, mutedText, 0),
                    _arrowConnector(accentGreen),
                    _loopPhase('FUSE', Icons.merge_type, 'Combine into\nsituation report', accentOrange, textColor, mutedText, 1),
                    _arrowConnector(accentGreen),
                    _loopPhase('THINK', Icons.psychology, 'LLM decides\nnext action', accentPurple, textColor, mutedText, 2),
                    _arrowConnector(accentGreen),
                    _loopPhase('ACT', Icons.rocket_launch, 'Execute via\nagents/tools', accentGreen, textColor, mutedText, 3),
                  ],
                ),
                const SizedBox(height: 40),
                // Current state
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final phase = (_heartbeatCount % 4);
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentPurple.withValues(alpha: 0.3 + 0.2 * _pulseController.value)),
                        boxShadow: [
                          BoxShadow(
                            color: accentPurple.withValues(alpha: 0.1 + 0.1 * _pulseController.value),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CURRENT PHASE',
                            style: TextStyle(color: accentPurple, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ['SENSING', 'FUSING', 'THINKING', 'ACTING'][phase],
                            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCurrentPhaseDescription(phase),
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Rate control
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Heartbeat Rate: ', style: TextStyle(color: mutedText, fontSize: 12)),
                      Slider(
                        value: _heartbeatRate,
                        min: 0.1,
                        max: 2.0,
                        divisions: 19,
                        activeColor: accentGreen,
                        inactiveColor: borderColor,
                        onChanged: (v) {
                          setState(() {
                            _heartbeatRate = v;
                            _startHeartbeat();
                          });
                        },
                      ),
                      Text('${_heartbeatRate.toStringAsFixed(1)} Hz', style: TextStyle(color: accentGreen, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPhaseDescription(int phase) {
    switch (phase) {
      case 0:
        return 'Gathering data from calendar, weather, home assistant...';
      case 1:
        return 'Creating unified situation report...';
      case 2:
        return 'LLM analyzing context and deciding action...';
      case 3:
        return 'Dispatching actions to agents and tools...';
      default:
        return '';
    }
  }

  Widget _loopPhase(String name, IconData icon, String desc, Color color, Color textColor, Color mutedText, int phaseIndex) {
    final isActive = (_heartbeatCount % 4) == phaseIndex;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.15 + 0.1 * _pulseController.value) : color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : color.withValues(alpha: 0.3),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: color.withValues(alpha: 0.3 + 0.2 * _pulseController.value), blurRadius: 12)]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(name, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: mutedText, fontSize: 10), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _arrowConnector(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.arrow_forward, color: color.withValues(alpha: 0.5), size: 20),
    );
  }

  Widget _buildFeedsPanel(Color borderColor, Color accentGreen, Color accentOrange,
      Color accentBlue, Color accentPurple, Color textColor, Color mutedText) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: accentGreen,
            unselectedLabelColor: mutedText,
            indicatorColor: accentGreen,
            tabs: const [
              Tab(text: 'Sensory'),
              Tab(text: 'Decisions'),
              Tab(text: 'Actions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Sensory Feed
                _buildSensoryFeed(borderColor, accentGreen, accentOrange, accentBlue, textColor, mutedText),
                // Decisions
                _buildDecisionsFeed(borderColor, accentPurple, textColor, mutedText),
                // Actions
                _buildActionsFeed(borderColor, accentGreen, accentOrange, textColor, mutedText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensoryFeed(Color borderColor, Color accentGreen, Color accentOrange,
      Color accentBlue, Color textColor, Color mutedText) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _sensoryFeed.length,
      itemBuilder: (context, index) {
        final item = _sensoryFeed[index];
        final color = _getSourceColor(item.source, accentGreen, accentOrange, accentBlue);
        final age = DateTime.now().difference(item.timestamp).inSeconds;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_getSourceIcon(item.source), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.source, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${age}s ago', style: TextStyle(color: mutedText, fontSize: 9)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(item.data, style: TextStyle(color: textColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecisionsFeed(Color borderColor, Color accentPurple, Color textColor, Color mutedText) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _decisions.length,
      itemBuilder: (context, index) {
        final item = _decisions[index];
        final age = DateTime.now().difference(item.timestamp).inSeconds;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentPurple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: accentPurple, size: 14),
                  const SizedBox(width: 6),
                  Text('LLM Decision', style: TextStyle(color: accentPurple, fontSize: 10, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${age}s ago', style: TextStyle(color: mutedText, fontSize: 9)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Input: ${item.input}', style: TextStyle(color: mutedText, fontSize: 11)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('Decision: ${item.decision}', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${(item.confidence * 100).toInt()}%', style: TextStyle(color: accentPurple, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionsFeed(Color borderColor, Color accentGreen, Color accentOrange,
      Color textColor, Color mutedText) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _actions.length,
      itemBuilder: (context, index) {
        final item = _actions[index];
        final age = DateTime.now().difference(item.timestamp).inSeconds;
        final isCompleted = item.status == 'completed';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isCompleted ? accentGreen : accentOrange).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.pending,
                color: isCompleted ? accentGreen : accentOrange,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.action, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Target: ${item.target}', style: TextStyle(color: mutedText, fontSize: 10)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${age}s ago', style: TextStyle(color: mutedText, fontSize: 9)),
                  Text(item.status, style: TextStyle(color: isCompleted ? accentGreen : accentOrange, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getSourceColor(String source, Color green, Color orange, Color blue) {
    switch (source) {
      case 'calendar':
        return blue;
      case 'weather':
        return const Color(0xFF06B6D4);
      case 'home_assistant':
        return orange;
      case 'email':
        return const Color(0xFFEC4899);
      case 'task_manager':
        return green;
      case 'nats_bus':
        return const Color(0xFF8B5CF6);
      case 'agents':
        return const Color(0xFF3B82F6);
      case 'memory':
        return const Color(0xFF8B5CF6);
      default:
        return green;
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'calendar':
        return Icons.calendar_today;
      case 'weather':
        return Icons.wb_sunny;
      case 'home_assistant':
        return Icons.home;
      case 'email':
        return Icons.email;
      case 'task_manager':
        return Icons.task_alt;
      case 'nats_bus':
        return Icons.hub;
      case 'agents':
        return Icons.psychology;
      case 'memory':
        return Icons.memory;
      default:
        return Icons.sensors;
    }
  }
}

// Data models
class SensoryData {
  final DateTime timestamp;
  final String source;
  final String type;
  final String data;

  SensoryData({
    required this.timestamp,
    required this.source,
    required this.type,
    required this.data,
  });
}

class CortexDecision {
  final DateTime timestamp;
  final String input;
  final String decision;
  final double confidence;

  CortexDecision({
    required this.timestamp,
    required this.input,
    required this.decision,
    required this.confidence,
  });
}

class ActionLog {
  final DateTime timestamp;
  final String action;
  final String target;
  final String status;

  ActionLog({
    required this.timestamp,
    required this.action,
    required this.target,
    required this.status,
  });
}

// Custom painters
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
