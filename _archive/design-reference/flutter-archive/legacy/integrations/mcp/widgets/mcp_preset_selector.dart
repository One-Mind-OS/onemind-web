// MCP Preset Selector Widget (Agent 4 - OMOS Sprint)
// Quick preset application for MCP servers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../providers/mcp_provider.dart';

/// Widget for selecting and applying MCP presets
class McpPresetSelector extends ConsumerWidget {
  final void Function(String preset, bool success)? onPresetApplied;

  const McpPresetSelector({
    super.key,
    this.onPresetApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(mcpPresetsProvider);
    final isApplying = ref.watch(mcpApplyingPresetProvider);

    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.flash_on,
                size: 16,
                color: TacticalColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'QUICK PRESETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: TacticalColors.textMuted,
                ),
              ),
              if (isApplying) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TacticalColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Preset chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: presets.map((preset) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PresetChip(
                  preset: preset,
                  isApplying: isApplying,
                  onTap: () => _applyPreset(context, ref, preset.name),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _applyPreset(BuildContext context, WidgetRef ref, String presetName) async {
    final notifier = ref.read(mcpProvider.notifier);
    final success = await notifier.applyPreset(presetName);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                success
                    ? 'Applied "$presetName" preset'
                    : 'Failed to apply preset',
              ),
            ],
          ),
          backgroundColor: TacticalColors.card,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    onPresetApplied?.call(presetName, success);
  }
}

/// Individual preset chip widget
class _PresetChip extends StatelessWidget {
  final McpPreset preset;
  final bool isApplying;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.isApplying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isApplying ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: preset.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: preset.color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                preset.icon,
                size: 16,
                color: preset.color,
              ),
              const SizedBox(width: 6),
              Text(
                preset.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: preset.color,
                ),
              ),
              if (preset.servers.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: preset.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${preset.servers.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: preset.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact preset bar for inline use
class McpPresetBar extends ConsumerWidget {
  final void Function(String preset, bool success)? onPresetApplied;

  const McpPresetBar({
    super.key,
    this.onPresetApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(mcpPresetsProvider);
    final isApplying = ref.watch(mcpApplyingPresetProvider);

    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: TacticalColors.elevated,
        border: Border(
          bottom: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            size: 14,
            color: TacticalColors.textDim,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: presets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _CompactPresetChip(
                      preset: preset,
                      isApplying: isApplying,
                      onTap: () async {
                        final notifier = ref.read(mcpProvider.notifier);
                        final success = await notifier.applyPreset(preset.name);
                        onPresetApplied?.call(preset.name, success);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (isApplying)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TacticalColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact chip for the preset bar
class _CompactPresetChip extends StatelessWidget {
  final McpPreset preset;
  final bool isApplying;
  final VoidCallback onTap;

  const _CompactPresetChip({
    required this.preset,
    required this.isApplying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isApplying ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: preset.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: preset.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          preset.name.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: preset.color,
          ),
        ),
      ),
    );
  }
}
