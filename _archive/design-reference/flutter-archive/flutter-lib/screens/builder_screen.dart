import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builder Screen - Visual Tool & Agent Builder
/// Like Relevance.ai - drag & drop workflow builder
/// Solar Punk Tactical Theme
class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key});

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<BuilderNode> _canvasNodes = [];
  BuilderNode? _selectedNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
    final mutedText = isDark ? const Color(0xFF6B8F6B) : const Color(0xFF4A6B4A);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // Top Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentOrange, const Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: accentOrange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.construction, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Builder',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Build custom tools, agents, workflows & skill trees',
                            style: TextStyle(color: mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // New Project Button
                    FilledButton.icon(
                      onPressed: _showNewProjectDialog,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: accentGreen,
                  unselectedLabelColor: mutedText,
                  indicatorColor: accentGreen,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Tools'),
                    Tab(text: 'Agents'),
                    Tab(text: 'Workflows'),
                    Tab(text: 'Skill Trees'),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildToolsBuilder(isDark, cardBg, borderColor, accentGreen, accentOrange, textColor, mutedText),
                _buildAgentsBuilder(isDark, cardBg, borderColor, accentGreen, accentBlue, textColor, mutedText),
                _buildWorkflowsBuilder(isDark, cardBg, borderColor, accentGreen, accentOrange, textColor, mutedText),
                _buildSkillTreeBuilder(isDark, cardBg, borderColor, accentGreen, accentOrange, textColor, mutedText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOOLS BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildToolsBuilder(bool isDark, Color cardBg, Color borderColor,
      Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    return Row(
      children: [
        // Left Panel - Tool Templates
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'TOOL TEMPLATES',
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _toolTemplate('API Call', Icons.api, 'Make HTTP requests to any API', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('Web Scraper', Icons.language, 'Extract data from websites', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('Database Query', Icons.storage, 'Query SQL or NoSQL databases', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('File Operations', Icons.folder_open, 'Read, write, transform files', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('Code Executor', Icons.code, 'Run Python or JS code', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('AI Transform', Icons.auto_fix_high, 'Transform data with LLM', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('Webhook', Icons.webhook, 'Listen for incoming webhooks', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('Schedule', Icons.schedule, 'Run on cron schedule', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _toolTemplate('MCP Server', Icons.hub, 'Connect to MCP server', accentOrange, cardBg, borderColor, textColor, mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Center - Canvas
        Expanded(
          child: _buildCanvas(isDark, borderColor, accentGreen, textColor, mutedText),
        ),
        // Right Panel - Properties
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(left: BorderSide(color: borderColor)),
          ),
          child: _selectedNode != null
              ? _buildNodeProperties(accentGreen, accentOrange, textColor, mutedText, borderColor)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 48, color: mutedText.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'Select a node to\nedit properties',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _toolTemplate(String name, IconData icon, String desc, Color accent,
      Color cardBg, Color borderColor, Color textColor, Color mutedText) {
    return Draggable<Map<String, dynamic>>(
      data: {'type': 'tool', 'name': name, 'icon': icon.codePoint},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(desc, style: TextStyle(color: mutedText, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.drag_indicator, size: 16, color: mutedText.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AGENTS BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAgentsBuilder(bool isDark, Color cardBg, Color borderColor,
      Color accentGreen, Color accentBlue, Color textColor, Color mutedText) {
    return Row(
      children: [
        // Left - Agent Templates
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'AGENT TEMPLATES',
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _agentTemplate('Assistant', Icons.assistant, 'General purpose helper', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Researcher', Icons.science, 'Deep web research', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Analyst', Icons.analytics, 'Data analysis expert', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Coder', Icons.code, 'Code generation & review', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Writer', Icons.edit_note, 'Content creation', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Planner', Icons.event_note, 'Task & project planning', accentBlue, cardBg, borderColor, textColor, mutedText),
                    _agentTemplate('Custom', Icons.smart_toy, 'Build from scratch', accentGreen, cardBg, borderColor, textColor, mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Center - Agent Config
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Agent Configuration', accentGreen),
                const SizedBox(height: 16),
                _configCard([
                  _textField('Name', 'my-custom-agent', textColor, mutedText, borderColor),
                  const SizedBox(height: 12),
                  _textField('Description', 'A helpful assistant that...', textColor, mutedText, borderColor),
                  const SizedBox(height: 12),
                  _dropdownField('Model', ['gpt-4o', 'claude-sonnet-4-20250514', 'gemini-2.0-flash', 'llama-3.3-70b'], textColor, mutedText, borderColor),
                ], cardBg, borderColor),
                const SizedBox(height: 20),
                _sectionHeader('System Instructions', accentGreen),
                const SizedBox(height: 16),
                _configCard([
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF050A05) : const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'You are a helpful assistant that specializes in...',
                        hintStyle: TextStyle(color: mutedText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ], cardBg, borderColor),
                const SizedBox(height: 20),
                _sectionHeader('Tools & Capabilities', accentGreen),
                const SizedBox(height: 16),
                _configCard([
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _toolChip('Web Search', true, accentGreen),
                      _toolChip('Wikipedia', true, accentGreen),
                      _toolChip('Calculator', false, accentGreen),
                      _toolChip('Code Exec', false, accentGreen),
                      _toolChip('File Read', true, accentGreen),
                      _toolChip('Home Assistant', false, accentGreen),
                      _toolChip('Weather', true, accentGreen),
                    ],
                  ),
                ], cardBg, borderColor),
                const SizedBox(height: 20),
                _sectionHeader('Triggers', accentGreen),
                const SizedBox(height: 16),
                _buildTriggersSection(cardBg, borderColor, accentGreen, const Color(0xFFF97316), textColor, mutedText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _agentTemplate(String name, IconData icon, String desc, Color accent,
      Color cardBg, Color borderColor, Color textColor, Color mutedText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(desc, style: TextStyle(color: mutedText, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WORKFLOWS BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWorkflowsBuilder(bool isDark, Color cardBg, Color borderColor,
      Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    return Row(
      children: [
        // Left - Workflow Blocks
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'WORKFLOW BLOCKS',
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _blockCategory('TRIGGERS', accentGreen),
                    _workflowBlock('Schedule', Icons.schedule, 'Cron-based trigger', accentGreen, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Webhook', Icons.webhook, 'HTTP webhook trigger', accentGreen, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Event', Icons.bolt, 'System event trigger', accentGreen, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Manual', Icons.play_circle, 'Manual execution', accentGreen, cardBg, borderColor, textColor, mutedText),
                    const SizedBox(height: 12),
                    _blockCategory('ACTIONS', accentOrange),
                    _workflowBlock('Run Agent', Icons.smart_toy, 'Execute an agent', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Run Tool', Icons.build, 'Execute a tool', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('API Call', Icons.api, 'HTTP request', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Transform', Icons.auto_fix_high, 'Data transformation', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Notify', Icons.notifications, 'Send notification', accentOrange, cardBg, borderColor, textColor, mutedText),
                    const SizedBox(height: 12),
                    _blockCategory('CONTROL', const Color(0xFF3B82F6)),
                    _workflowBlock('Condition', Icons.call_split, 'If/else branch', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Loop', Icons.loop, 'Iterate over items', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Parallel', Icons.account_tree, 'Run in parallel', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Wait', Icons.hourglass_empty, 'Delay execution', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _workflowBlock('Approval', Icons.check_circle, 'Human approval gate', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Center - Visual Canvas
        Expanded(
          child: _buildCanvas(isDark, borderColor, accentGreen, textColor, mutedText),
        ),
        // Right - Properties
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(left: BorderSide(color: borderColor)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Workflow Properties', accentGreen),
                const SizedBox(height: 16),
                _textField('Name', 'daily-report-workflow', textColor, mutedText, borderColor),
                const SizedBox(height: 12),
                _textField('Description', 'Generates daily summary...', textColor, mutedText, borderColor),
                const SizedBox(height: 20),
                _sectionHeader('Schedule Trigger', accentGreen),
                const SizedBox(height: 16),
                _cronBuilder(textColor, mutedText, borderColor, accentGreen),
                const SizedBox(height: 20),
                _sectionHeader('Event Triggers', accentGreen),
                const SizedBox(height: 16),
                _eventTriggerList(cardBg, borderColor, accentGreen, textColor, mutedText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _blockCategory(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _workflowBlock(String name, IconData icon, String desc, Color accent,
      Color cardBg, Color borderColor, Color textColor, Color mutedText) {
    return Draggable<Map<String, dynamic>>(
      data: {'type': 'workflow', 'name': name, 'icon': icon.codePoint},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(name, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(desc, style: TextStyle(color: mutedText, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SKILL TREE BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSkillTreeBuilder(bool isDark, Color cardBg, Color borderColor,
      Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    return Row(
      children: [
        // Left - Skill Templates
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'SKILL NODES',
                  style: TextStyle(
                    color: accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _blockCategory('CATEGORIES', accentGreen),
                    _skillNode('Digital', Icons.computer, 'Software & tech skills', accentGreen, cardBg, borderColor, textColor, mutedText),
                    _skillNode('Physical', Icons.fitness_center, 'Manual & fitness skills', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _skillNode('Mental', Icons.psychology, 'Cognitive skills', const Color(0xFF8B5CF6), cardBg, borderColor, textColor, mutedText),
                    _skillNode('Social', Icons.groups, 'Communication skills', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _skillNode('Creative', Icons.palette, 'Art & design skills', const Color(0xFFEC4899), cardBg, borderColor, textColor, mutedText),
                    const SizedBox(height: 12),
                    _blockCategory('SKILL TYPES', accentOrange),
                    _skillNode('Core Skill', Icons.star, 'Foundational ability', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _skillNode('Branch Skill', Icons.call_split, 'Specialization path', accentOrange, cardBg, borderColor, textColor, mutedText),
                    _skillNode('Capstone', Icons.emoji_events, 'Mastery achievement', accentOrange, cardBg, borderColor, textColor, mutedText),
                    const SizedBox(height: 12),
                    _blockCategory('LINKED ITEMS', const Color(0xFF3B82F6)),
                    _skillNode('Task Link', Icons.task_alt, 'Link task to skill', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _skillNode('Habit Link', Icons.repeat, 'Daily habit tracker', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                    _skillNode('Project Link', Icons.rocket_launch, 'Project milestone', const Color(0xFF3B82F6), cardBg, borderColor, textColor, mutedText),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Center - Skill Tree Canvas
        Expanded(
          child: _buildSkillTreeCanvas(isDark, borderColor, accentGreen, accentOrange, textColor, mutedText),
        ),
        // Right - Skill Properties
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(left: BorderSide(color: borderColor)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Skill Properties', accentGreen),
                const SizedBox(height: 16),
                _textField('Skill Name', 'Flutter Development', textColor, mutedText, borderColor),
                const SizedBox(height: 12),
                _textField('Description', 'Build cross-platform apps...', textColor, mutedText, borderColor),
                const SizedBox(height: 12),
                _dropdownField('Category', ['Digital', 'Physical', 'Mental', 'Social', 'Creative'], textColor, mutedText, borderColor),
                const SizedBox(height: 20),
                _sectionHeader('XP & Progression', accentGreen),
                const SizedBox(height: 16),
                _xpConfigSection(cardBg, borderColor, accentGreen, accentOrange, textColor, mutedText),
                const SizedBox(height: 20),
                _sectionHeader('Linked Tasks', accentGreen),
                const SizedBox(height: 16),
                _linkedTasksList(cardBg, borderColor, accentGreen, textColor, mutedText),
                const SizedBox(height: 20),
                _sectionHeader('Prerequisites', accentGreen),
                const SizedBox(height: 16),
                _prerequisitesList(cardBg, borderColor, accentGreen, textColor, mutedText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _skillNode(String name, IconData icon, String desc, Color accent,
      Color cardBg, Color borderColor, Color textColor, Color mutedText) {
    return Draggable<Map<String, dynamic>>(
      data: {'type': 'skill', 'name': name, 'icon': icon.codePoint},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(name, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text(desc, style: TextStyle(color: mutedText, fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTreeCanvas(bool isDark, Color borderColor, Color accentGreen,
      Color accentOrange, Color textColor, Color mutedText) {
    return Container(
      color: isDark ? const Color(0xFF050A05) : const Color(0xFFF0F5F0),
      child: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: _GridPainter(borderColor.withValues(alpha: 0.3)),
            size: Size.infinite,
          ),
          // Sample skill tree nodes
          Positioned(
            left: 200,
            top: 50,
            child: _skillTreeNode('Programming', Icons.code, 0.75, accentGreen, textColor, true),
          ),
          Positioned(
            left: 100,
            top: 150,
            child: _skillTreeNode('Frontend', Icons.web, 0.6, const Color(0xFF3B82F6), textColor, false),
          ),
          Positioned(
            left: 300,
            top: 150,
            child: _skillTreeNode('Backend', Icons.dns, 0.4, accentOrange, textColor, false),
          ),
          Positioned(
            left: 50,
            top: 270,
            child: _skillTreeNode('Flutter', Icons.phone_android, 0.3, const Color(0xFF8B5CF6), textColor, false),
          ),
          Positioned(
            left: 150,
            top: 270,
            child: _skillTreeNode('React', Icons.javascript, 0.2, const Color(0xFF06B6D4), textColor, false),
          ),
          // Connection lines
          CustomPaint(
            painter: _SkillTreeLinesPainter(accentGreen.withValues(alpha: 0.4)),
            size: Size.infinite,
          ),
          // Drop target overlay
          DragTarget<Map<String, dynamic>>(
            onAcceptWithDetails: (details) {
              // Add skill node to tree
              setState(() {
                // Handle skill node drop
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                color: candidateData.isNotEmpty
                    ? accentGreen.withValues(alpha: 0.1)
                    : Colors.transparent,
              );
            },
          ),
          // Instructions overlay
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0F0A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SKILL TREE', style: TextStyle(color: accentGreen, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('• Drag skills to add\n• Link tasks for XP\n• Complete tasks to level up', style: TextStyle(color: mutedText, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillTreeNode(String name, IconData icon, double progress, Color color,
      Color textColor, bool isRoot) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: isRoot ? 2 : 1),
        boxShadow: isRoot
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)]
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 2),
          Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCanvas(bool isDark, Color borderColor, Color accentGreen,
      Color textColor, Color mutedText) {
    return Container(
      color: isDark ? const Color(0xFF050A05) : const Color(0xFFF0F5F0),
      child: DragTarget<Map<String, dynamic>>(
        onAcceptWithDetails: (details) {
          final data = details.data;
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.offset);
          setState(() {
            _canvasNodes.add(BuilderNode(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: data['name'] ?? 'Node',
              type: data['type'] ?? 'unknown',
              icon: IconData(data['icon'] ?? Icons.circle.codePoint, fontFamily: 'MaterialIcons'),
              position: localPosition,
            ));
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // Grid
              CustomPaint(
                painter: _GridPainter(borderColor.withValues(alpha: 0.3)),
                size: Size.infinite,
              ),
              // Nodes
              ..._canvasNodes.map((node) => _buildCanvasNode(node, accentGreen, textColor, mutedText)),
              // Drop indicator
              if (candidateData.isNotEmpty)
                Container(color: accentGreen.withValues(alpha: 0.1)),
              // Empty state
              if (_canvasNodes.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_box_outlined, size: 48, color: mutedText.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('Drag components here', style: TextStyle(color: mutedText, fontSize: 14)),
                      Text('to build your workflow', style: TextStyle(color: mutedText.withValues(alpha: 0.6), fontSize: 12)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCanvasNode(BuilderNode node, Color accent, Color textColor, Color mutedText) {
    final isSelected = _selectedNode?.id == node.id;
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onTap: () => setState(() => _selectedNode = node),
        onPanUpdate: (details) {
          setState(() {
            final idx = _canvasNodes.indexWhere((n) => n.id == node.id);
            if (idx >= 0) {
              _canvasNodes[idx] = node.copyWith(
                position: Offset(
                  node.position.dx + details.delta.dx,
                  node.position.dy + details.delta.dy,
                ),
              );
            }
          });
        },
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.2) : const Color(0xFF0F1A0F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? accent : const Color(0xFF1A2F1A), width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(node.icon, color: accent, size: 24),
              const SizedBox(height: 6),
              Text(node.name, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              Text(node.type, style: TextStyle(color: mutedText, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeProperties(Color accent, Color accentOrange, Color textColor, Color mutedText, Color borderColor) {
    if (_selectedNode == null) return const SizedBox();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_selectedNode!.icon, color: accent, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_selectedNode!.name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                onPressed: () {
                  setState(() {
                    _canvasNodes.removeWhere((n) => n.id == _selectedNode!.id);
                    _selectedNode = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionHeader('Configuration', accent),
          const SizedBox(height: 12),
          _textField('Name', _selectedNode!.name, textColor, mutedText, borderColor),
          const SizedBox(height: 12),
          _textField('Type', _selectedNode!.type, textColor, mutedText, borderColor),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _textField(String label, String hint, Color textColor, Color mutedText, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: mutedText, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          style: TextStyle(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: mutedText.withValues(alpha: 0.6)),
            filled: true,
            fillColor: borderColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> options, Color textColor, Color mutedText, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: mutedText, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: options.first,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) {},
          style: TextStyle(color: textColor, fontSize: 13),
          dropdownColor: const Color(0xFF0F1A0F),
          decoration: InputDecoration(
            filled: true,
            fillColor: borderColor.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _configCard(List<Widget> children, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _toolChip(String name, bool enabled, Color accent) {
    return FilterChip(
      label: Text(name, style: TextStyle(color: enabled ? Colors.white : accent, fontSize: 11)),
      selected: enabled,
      selectedColor: accent,
      backgroundColor: Colors.transparent,
      side: BorderSide(color: accent),
      onSelected: (v) {},
    );
  }

  Widget _cronBuilder(Color textColor, Color mutedText, Color borderColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _miniDropdown('Min', ['*', '0', '15', '30', '45'], textColor, borderColor)),
              const SizedBox(width: 8),
              Expanded(child: _miniDropdown('Hour', ['*', '0', '6', '12', '18'], textColor, borderColor)),
              const SizedBox(width: 8),
              Expanded(child: _miniDropdown('Day', ['*', '1', '15'], textColor, borderColor)),
              const SizedBox(width: 8),
              Expanded(child: _miniDropdown('Month', ['*'], textColor, borderColor)),
              const SizedBox(width: 8),
              Expanded(child: _miniDropdown('Week', ['*', 'MON', 'FRI'], textColor, borderColor)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, size: 14, color: accent),
                const SizedBox(width: 6),
                Text('Every day at 6:00 AM', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDropdown(String label, List<String> options, Color textColor, Color borderColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 9)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: options.first,
            isDense: true,
            underline: const SizedBox(),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(color: textColor, fontSize: 11)))).toList(),
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }

  Widget _eventTriggerList(Color cardBg, Color borderColor, Color accent, Color textColor, Color mutedText) {
    final triggers = [
      {'event': 'task.completed', 'enabled': true},
      {'event': 'memory.created', 'enabled': false},
      {'event': 'webhook.received', 'enabled': true},
    ];
    return Column(
      children: [
        ...triggers.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, size: 16, color: t['enabled'] == true ? accent : mutedText),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t['event'] as String, style: TextStyle(color: textColor, fontSize: 12))),
                  Switch(
                    value: t['enabled'] as bool,
                    onChanged: (v) {},
                    activeThumbColor: accent,
                  ),
                ],
              ),
            )),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add, size: 16, color: accent),
          label: Text('Add Event Trigger', style: TextStyle(color: accent, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildTriggersSection(Color cardBg, Color borderColor, Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    return _configCard([
      _sectionHeader('Schedule Triggers', accentGreen),
      const SizedBox(height: 12),
      _triggerItem('Daily at 9:00 AM', Icons.schedule, true, accentGreen, textColor, mutedText, borderColor),
      _triggerItem('Every Monday', Icons.calendar_today, false, accentGreen, textColor, mutedText, borderColor),
      const SizedBox(height: 16),
      _sectionHeader('Event Triggers', accentOrange),
      const SizedBox(height: 12),
      _triggerItem('On task.completed', Icons.bolt, true, accentOrange, textColor, mutedText, borderColor),
      _triggerItem('On webhook.received', Icons.webhook, false, accentOrange, textColor, mutedText, borderColor),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGreen,
          side: BorderSide(color: accentGreen),
        ),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Trigger'),
      ),
    ], cardBg, borderColor);
  }

  Widget _triggerItem(String label, IconData icon, bool enabled, Color accent, Color textColor, Color mutedText, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: enabled ? accent : mutedText),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(color: textColor, fontSize: 12))),
          Switch(value: enabled, onChanged: (v) {}, activeThumbColor: accent),
        ],
      ),
    );
  }

  Widget _xpConfigSection(Color cardBg, Color borderColor, Color accentGreen, Color accentOrange, Color textColor, Color mutedText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('XP to Level Up', style: TextStyle(color: mutedText, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text('500 XP', style: TextStyle(color: accentOrange, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Level', style: TextStyle(color: mutedText, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text('Level 3', style: TextStyle(color: accentGreen, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _xpRewardChip('Task Complete', '+25 XP', accentGreen)),
              const SizedBox(width: 8),
              Expanded(child: _xpRewardChip('Habit Streak', '+10 XP', accentOrange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _xpRewardChip('Project Done', '+100 XP', const Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Expanded(child: _xpRewardChip('Daily Login', '+5 XP', const Color(0xFF8B5CF6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xpRewardChip(String label, String xp, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10)),
          Text(xp, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _linkedTasksList(Color cardBg, Color borderColor, Color accent, Color textColor, Color mutedText) {
    final tasks = [
      {'name': 'Complete Flutter course', 'xp': 50, 'done': true},
      {'name': 'Build sample app', 'xp': 30, 'done': false},
      {'name': 'Write documentation', 'xp': 20, 'done': false},
    ];
    return Column(
      children: [
        ...tasks.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    t['done'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: t['done'] == true ? accent : mutedText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t['name'] as String,
                      style: TextStyle(
                        color: t['done'] == true ? mutedText : textColor,
                        fontSize: 12,
                        decoration: t['done'] == true ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('+${t['xp']} XP', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            )),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add, size: 16, color: accent),
          label: Text('Link Task', style: TextStyle(color: accent, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _prerequisitesList(Color cardBg, Color borderColor, Color accent, Color textColor, Color mutedText) {
    final prereqs = ['Programming Basics', 'Dart Fundamentals'];
    return Column(
      children: [
        ...prereqs.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_open, size: 14, color: accent),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p, style: TextStyle(color: textColor, fontSize: 12))),
                  Icon(Icons.check, size: 14, color: accent),
                ],
              ),
            )),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add, size: 16, color: accent),
          label: Text('Add Prerequisite', style: TextStyle(color: accent, fontSize: 12)),
        ),
      ],
    );
  }

  void _showNewProjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF0F1A0F) : Colors.white;
        final borderColor = isDark ? const Color(0xFF1A2F1A) : const Color(0xFFD5E5D5);
        final textColor = isDark ? const Color(0xFFD1E5D1) : const Color(0xFF1A3A1A);
        final accentGreen = const Color(0xFF4ADE80);

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('New Project', style: TextStyle(color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeOption('Tool', Icons.build, 'Build a custom tool', accentGreen, textColor, borderColor),
              _buildTypeOption('Agent', Icons.smart_toy, 'Create an AI agent', accentGreen, textColor, borderColor),
              _buildTypeOption('Workflow', Icons.account_tree, 'Design automation flow', accentGreen, textColor, borderColor),
              _buildTypeOption('Skill Tree', Icons.psychology, 'Create skill progression', accentGreen, textColor, borderColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeOption(String name, IconData icon, String desc, Color accent, Color textColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _tabController.animateTo(
                name == 'Tool' ? 0 : name == 'Agent' ? 1 : name == 'Workflow' ? 2 : 3,
              );
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                      Text(desc, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class BuilderNode {
  final String id;
  final String name;
  final String type;
  final IconData icon;
  final Offset position;
  final Map<String, dynamic> config;

  BuilderNode({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.position,
    this.config = const {},
  });

  BuilderNode copyWith({
    String? id,
    String? name,
    String? type,
    IconData? icon,
    Offset? position,
    Map<String, dynamic>? config,
  }) {
    return BuilderNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      position: position ?? this.position,
      config: config ?? this.config,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 20.0;
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

class _SkillTreeLinesPainter extends CustomPainter {
  final Color color;
  _SkillTreeLinesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Programming → Frontend
    canvas.drawLine(const Offset(250, 100), const Offset(150, 150), paint);
    // Programming → Backend
    canvas.drawLine(const Offset(250, 100), const Offset(350, 150), paint);
    // Frontend → Flutter
    canvas.drawLine(const Offset(150, 200), const Offset(100, 270), paint);
    // Frontend → React
    canvas.drawLine(const Offset(150, 200), const Offset(200, 270), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
