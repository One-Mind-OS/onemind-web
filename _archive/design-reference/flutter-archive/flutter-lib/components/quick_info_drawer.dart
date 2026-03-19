import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/settings_panel.dart';
import '../providers/agent_config_provider.dart';
import '../models/tool_config.dart';

/// Quick Info Drawer - Read-only agent/team information display
/// This is NOT an editing interface - just shows what the selected agent has
class QuickInfoDrawer extends ConsumerWidget {
  final VoidCallback onClose;

  const QuickInfoDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentConfig = ref.watch(agentConfigProvider);
    final settings = ref.watch(settingsProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: isMobile ? double.infinity : 400,
      height: isMobile ? height * 0.65 : double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          left: isMobile
              ? BorderSide.none
              : BorderSide(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                  width: 1,
                ),
          top: isMobile
              ? BorderSide(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                  width: 1,
                )
              : BorderSide.none,
        ),
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00D9FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AGENT INFO',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF00D9FF)),
                  onPressed: onClose,
                  iconSize: 20,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Agent/Team Summary
                _AgentSummarySection(agentConfig: agentConfig),

                const SizedBox(height: 24),

                // Model (Read-only)
                _ModelInfoSection(agentConfig: agentConfig),

                const SizedBox(height: 24),

                // Tools (Read-only list)
                if (agentConfig.tools.isNotEmpty) ...[
                  _ToolsInfoSection(tools: agentConfig.tools),
                  const SizedBox(height: 24),
                ],

                // Knowledge Bases (Read-only list)
                if (agentConfig.knowledgeBases.isNotEmpty) ...[
                  _KnowledgeInfoSection(knowledgeBases: agentConfig.knowledgeBases),
                  const SizedBox(height: 24),
                ],

                // Team Members (if team)
                if (agentConfig.isTeam && agentConfig.teamMembers != null) ...[
                  _TeamMembersSection(members: agentConfig.teamMembers!),
                  const SizedBox(height: 24),
                ],

                // Temperature (ONLY editable runtime parameter)
                _TemperatureSection(settings: settings, ref: ref),

                const SizedBox(height: 24),

                // Edit Agent Button
                _EditAgentButton(agentConfig: agentConfig),

                const SizedBox(height: 12),

                // Memories Button
                const _MemoriesButton(),

                const SizedBox(height: 12),

                // Analytics Button
                const _AnalyticsButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Agent/Team summary with role and model
class _AgentSummarySection extends StatelessWidget {
  final AgentConfig agentConfig;

  const _AgentSummarySection({required this.agentConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withValues(alpha: 0.05),
            const Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  agentConfig.isTeam ? 'TEAM' : 'AGENT',
                  style: TextStyle(
                    color: const Color(0xFF00D9FF),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            agentConfig.name ?? 'No selection',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (agentConfig.instructions != null) ...[
            const SizedBox(height: 8),
            Text(
              agentConfig.instructions!,
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Model information (read-only)
class _ModelInfoSection extends StatelessWidget {
  final AgentConfig agentConfig;

  const _ModelInfoSection({required this.agentConfig});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.smart_toy,
              color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'MODEL',
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          agentConfig.modelName ?? 'Unknown',
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          'Pre-configured for this agent',
          style: TextStyle(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// Tools list (read-only)
class _ToolsInfoSection extends StatelessWidget {
  final List<ToolConfig> tools;

  const _ToolsInfoSection({required this.tools});

  @override
  Widget build(BuildContext context) {
    // Only show enabled tools
    final enabledTools = tools.where((t) => t.isEnabled).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.build,
              color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'TOOLS (${enabledTools.length})',
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...enabledTools.map((tool) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                _getIconForTool(tool.iconName),
                color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tool.name,
                  style: TextStyle(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.8),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 4),
        Text(
          'Configured in agent definition',
          style: TextStyle(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
            fontSize: 9,
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  IconData _getIconForTool(String? iconName) {
    switch (iconName) {
      case 'search':
        return Icons.search;
      case 'folder':
        return Icons.folder;
      case 'calculate':
        return Icons.calculate;
      case 'school':
        return Icons.school;
      case 'book':
        return Icons.book;
      case 'code':
        return Icons.code;
      default:
        return Icons.extension;
    }
  }
}

/// Knowledge bases list (read-only)
class _KnowledgeInfoSection extends StatelessWidget {
  final List<String> knowledgeBases;

  const _KnowledgeInfoSection({required this.knowledgeBases});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.library_books,
              color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'KNOWLEDGE (${knowledgeBases.length})',
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...knowledgeBases.map((kb) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D9FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                kb,
                style: TextStyle(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

/// Team members section
class _TeamMembersSection extends StatelessWidget {
  final List<String> members;

  const _TeamMembersSection({required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'TEAM MEMBERS (${members.length})',
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...members.map((member) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                member,
                style: TextStyle(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        Text(
          'Each member has their own model & tools',
          style: TextStyle(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
            fontSize: 9,
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Temperature slider (ONLY editable runtime parameter)
class _TemperatureSection extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _TemperatureSection({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TEMPERATURE',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                settings.temperature.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: settings.temperature,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: const Color(0xFF00D9FF),
            inactiveColor: const Color(0xFF00D9FF).withValues(alpha: 0.2),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateTemperature(value);
            },
          ),
          Text(
            'Runtime parameter (adjustable per conversation)',
            style: TextStyle(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit Agent button (navigates to management page)
class _EditAgentButton extends StatelessWidget {
  final AgentConfig agentConfig;

  const _EditAgentButton({required this.agentConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withValues(alpha: 0.8),
            const Color(0xFF00D9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/agents');
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  agentConfig.isTeam ? 'EDIT TEAM' : 'EDIT AGENT',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Memories button (navigates to memories page)
class _MemoriesButton extends StatelessWidget {
  const _MemoriesButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/memories');
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.memory,
                  color: Color(0xFF00D9FF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'VIEW MEMORIES',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Analytics button (navigates to analytics dashboard)
class _AnalyticsButton extends StatelessWidget {
  const _AnalyticsButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/analytics');
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics,
                  color: Color(0xFF00D9FF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'VIEW ANALYTICS',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
