import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/settings_panel.dart';
import '../providers/agent_config_provider.dart';
import '../models/tool_config.dart';

/// Quick settings drawer with context-aware configuration
class QuickSettingsDrawer extends ConsumerWidget {
  final VoidCallback onClose;

  const QuickSettingsDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentConfig = ref.watch(agentConfigProvider);
    final settings = ref.watch(settingsProvider);
    final knowledgeBases = ref.watch(knowledgeBasesProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: isMobile ? double.infinity : 400,
      height: isMobile ? height * 0.6 : double.infinity,
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
                  Icons.tune,
                  color: Color(0xFF00D9FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'QUICK SETTINGS',
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
                // Current Agent/Team Info
                _AgentInfoSection(agentConfig: agentConfig),

                const SizedBox(height: 24),

                // Temperature Setting
                _TemperatureSection(settings: settings, ref: ref),

                const SizedBox(height: 24),

                // Quick Tools Toggle
                if (agentConfig.tools.isNotEmpty) ...[
                  _QuickToolsSection(agentConfig: agentConfig, ref: ref),
                  const SizedBox(height: 24),
                ],

                // Knowledge Bases
                if (knowledgeBases.isNotEmpty) ...[
                  _KnowledgeBasesSection(
                    knowledgeBases: knowledgeBases,
                    selectedKBs: agentConfig.knowledgeBases,
                    ref: ref,
                  ),
                  const SizedBox(height: 24),
                ],

                // Team Members (if team selected)
                if (agentConfig.isTeam && agentConfig.teamMembers != null) ...[
                  _TeamMembersSection(members: agentConfig.teamMembers!),
                  const SizedBox(height: 24),
                ],

                // Management Links
                _ManagementLinksSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Agent/Team information display
class _AgentInfoSection extends StatelessWidget {
  final AgentConfig agentConfig;

  const _AgentInfoSection({required this.agentConfig});

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
            children: [
              Icon(
                agentConfig.isTeam ? Icons.groups : Icons.person,
                color: const Color(0xFF00D9FF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                agentConfig.isTeam ? 'TEAM' : 'AGENT',
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
            agentConfig.name ?? 'No selection',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (agentConfig.instructions != null) ...[
            const SizedBox(height: 6),
            Text(
              agentConfig.instructions!,
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Temperature slider section
class _TemperatureSection extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _TemperatureSection({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Temperature',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
            Text(
              settings.temperature.toStringAsFixed(1),
              style: TextStyle(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                fontSize: 12,
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
          'Controls response randomness',
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

/// Quick tools toggle section
class _QuickToolsSection extends StatelessWidget {
  final AgentConfig agentConfig;
  final WidgetRef ref;

  const _QuickToolsSection({required this.agentConfig, required this.ref});

  @override
  Widget build(BuildContext context) {
    // Show top 5 tools
    final topTools = agentConfig.tools.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.build,
              color: Color(0xFF00D9FF),
              size: 14,
            ),
            const SizedBox(width: 6),
            const Text(
              'Quick Tools',
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
        const SizedBox(height: 12),
        ...topTools.map((tool) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ToolToggleItem(tool: tool, ref: ref),
        )),
        if (agentConfig.tools.length > 5) ...[
          const SizedBox(height: 4),
          Text(
            '+${agentConfig.tools.length - 5} more tools',
            style: TextStyle(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }
}

/// Individual tool toggle item
class _ToolToggleItem extends StatelessWidget {
  final ToolConfig tool;
  final WidgetRef ref;

  const _ToolToggleItem({required this.tool, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: tool.isEnabled
              ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
              : const Color(0xFF00D9FF).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForTool(tool.iconName),
            color: tool.isEnabled
                ? const Color(0xFF00D9FF)
                : const Color(0xFF00D9FF).withValues(alpha: 0.4),
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name,
                  style: TextStyle(
                    color: tool.isEnabled
                        ? const Color(0xFF00D9FF)
                        : const Color(0xFF00D9FF).withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  tool.description,
                  style: TextStyle(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: tool.isEnabled,
            activeThumbColor: const Color(0xFF00D9FF),
            onChanged: (value) {
              ref.read(agentConfigProvider.notifier).toggleTool(tool.name);
            },
          ),
        ],
      ),
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

/// Knowledge bases section
class _KnowledgeBasesSection extends StatelessWidget {
  final List<KnowledgeBaseConfig> knowledgeBases;
  final List<String> selectedKBs;
  final WidgetRef ref;

  const _KnowledgeBasesSection({
    required this.knowledgeBases,
    required this.selectedKBs,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.library_books,
              color: Color(0xFF00D9FF),
              size: 14,
            ),
            const SizedBox(width: 6),
            const Text(
              'Knowledge Bases',
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
        const SizedBox(height: 12),
        ...knowledgeBases.map((kb) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _KnowledgeBaseItem(
            kb: kb,
            isSelected: selectedKBs.contains(kb.id),
            ref: ref,
          ),
        )),
      ],
    );
  }
}

/// Individual knowledge base item
class _KnowledgeBaseItem extends StatelessWidget {
  final KnowledgeBaseConfig kb;
  final bool isSelected;
  final WidgetRef ref;

  const _KnowledgeBaseItem({
    required this.kb,
    required this.isSelected,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isSelected) {
          ref.read(agentConfigProvider.notifier).removeKnowledgeBase(kb.id);
        } else {
          ref.read(agentConfigProvider.notifier).addKnowledgeBase(kb.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
                : const Color(0xFF00D9FF).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected
                  ? const Color(0xFF00D9FF)
                  : const Color(0xFF00D9FF).withValues(alpha: 0.4),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kb.name,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00D9FF)
                          : const Color(0xFF00D9FF).withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    '${kb.documentCount} documents',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                      fontSize: 9,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            const Icon(
              Icons.people,
              color: Color(0xFF00D9FF),
              size: 14,
            ),
            const SizedBox(width: 6),
            const Text(
              'Team Members',
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
        const SizedBox(height: 12),
        ...members.map((member) => Padding(
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
      ],
    );
  }
}

/// Management links section
class _ManagementLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          color: Color(0xFF00D9FF),
          thickness: 0.5,
        ),
        const SizedBox(height: 8),
        Text(
          'ADVANCED',
          style: TextStyle(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _ManagementLink(
          icon: Icons.person,
          label: 'Manage Agents',
          onTap: () {
            // TODO: Navigate to /agents
            debugPrint('Navigate to /agents');
          },
        ),
        _ManagementLink(
          icon: Icons.groups,
          label: 'Manage Teams',
          onTap: () {
            // TODO: Navigate to /teams
            debugPrint('Navigate to /teams');
          },
        ),
        _ManagementLink(
          icon: Icons.build,
          label: 'Tool Marketplace',
          onTap: () {
            // TODO: Navigate to /tools
            debugPrint('Navigate to /tools');
          },
        ),
        _ManagementLink(
          icon: Icons.library_books,
          label: 'Knowledge Bases',
          onTap: () {
            // TODO: Navigate to /knowledge
            debugPrint('Navigate to /knowledge');
          },
        ),
        _ManagementLink(
          icon: Icons.account_tree,
          label: 'Workflows',
          onTap: () {
            // TODO: Navigate to /workflows
            debugPrint('Navigate to /workflows');
          },
        ),
      ],
    );
  }
}

/// Management link item
class _ManagementLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ManagementLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ManagementLink> createState() => _ManagementLinkState();
}

class _ManagementLinkState extends State<_ManagementLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF00D9FF).withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF00D9FF).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.7),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
