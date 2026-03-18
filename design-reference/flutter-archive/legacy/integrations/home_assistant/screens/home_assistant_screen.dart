// Home Assistant integration screen
// DESIGN: Tactical design system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/home_assistant.dart';
import '../providers/home_assistant_provider.dart';
import '../../../shared/theme/tactical.dart';

/// Home Assistant integration screen
class HomeAssistantScreen extends ConsumerStatefulWidget {
  const HomeAssistantScreen({super.key});

  @override
  ConsumerState<HomeAssistantScreen> createState() =>
      _HomeAssistantScreenState();
}

class _HomeAssistantScreenState extends ConsumerState<HomeAssistantScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeAssistantProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeAssistantProvider);
    final notifier = ref.read(homeAssistantProvider.notifier);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TacticalColors.textMuted),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('HOME ASSISTANT', style: TacticalText.cardTitle),
        actions: [
          // Sync button
          IconButton(
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TacticalColors.primary,
                    ),
                  )
                : const Icon(Icons.sync, color: TacticalColors.textMuted),
            onPressed: state.isLoading ? null : () => notifier.syncRegistries(),
            tooltip: 'Sync with Home Assistant',
          ),
          // Open HA Companion
          IconButton(
            icon: const Icon(Icons.open_in_new, color: TacticalColors.textMuted),
            onPressed: () => _openHACompanion(),
            tooltip: 'Open HA Companion',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadAll(),
        color: TacticalColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status
              _ConnectionStatusCard(status: state.status),
              const SizedBox(height: 16),

              // Home summary card
              if (state.summary != null) ...[
                _HomeSummaryCard(summary: state.summary!),
                const SizedBox(height: 16),
              ],

              // Quick actions
              _QuickActionsCard(notifier: notifier),
              const SizedBox(height: 16),

              // Scenes
              if (state.scenes.isNotEmpty) ...[
                _ScenesCard(scenes: state.scenes, notifier: notifier),
                const SizedBox(height: 16),
              ],

              // Filters
              _FiltersCard(
                areas: state.areas,
                domains: state.availableDomains,
                selectedAreaId: state.selectedAreaId,
                selectedDomain: state.selectedDomain,
                onAreaChanged: notifier.setAreaFilter,
                onDomainChanged: notifier.setDomainFilter,
                onClear: notifier.clearFilters,
              ),
              const SizedBox(height: 16),

              // Entities by area
              _EntitiesSection(
                entities: state.filteredEntities,
                areas: state.areas,
                notifier: notifier,
                isLoading: state.isLoading,
              ),

              // Error display
              if (state.error != null) ...[
                const SizedBox(height: 16),
                _ErrorCard(error: state.error!, onDismiss: notifier.clearError),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openHACompanion() async {
    // Try HA Companion app first
    final haUrl = Uri.parse('homeassistant://');
    if (await canLaunchUrl(haUrl)) {
      await launchUrl(haUrl);
    } else {
      // Fall back to web UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('HA Companion app not installed'),
            backgroundColor: TacticalColors.inProgress,
          ),
        );
      }
    }
  }
}

/// Connection status card
class _ConnectionStatusCard extends StatelessWidget {
  final HAConnectionStatus status;

  const _ConnectionStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColor = status.connected
        ? TacticalColors.operational
        : TacticalColors.critical;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              status.connected ? Icons.check_circle : Icons.error,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.connected ? 'CONNECTED' : 'DISCONNECTED',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                if (status.connected && status.haVersion != null)
                  Text(
                    'HA ${status.haVersion} • ${status.locationName ?? "Home"}',
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                if (!status.connected && status.lastError != null)
                  Text(
                    status.lastError!,
                    style: const TextStyle(
                      color: TacticalColors.critical,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Home summary card (dashboard)
class _HomeSummaryCard extends StatelessWidget {
  final HAHomeSummary summary;

  const _HomeSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: TacticalColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.home, color: TacticalColors.textPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                summary.locationName.toUpperCase(),
                style: const TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatItem(
                icon: Icons.lightbulb,
                label: 'LIGHTS',
                value: '${summary.lightsOn}/${summary.lightsTotal}',
                color: summary.lightsOn > 0
                    ? const Color(0xFFFACC15)
                    : TacticalColors.textMuted,
              ),
              _StatItem(
                icon: Icons.lock,
                label: 'LOCKS',
                value: '${summary.locksLocked}/${summary.locksTotal}',
                color: summary.locksLocked == summary.locksTotal
                    ? TacticalColors.operational
                    : TacticalColors.inProgress,
              ),
              if (summary.temperature != null)
                _StatItem(
                  icon: Icons.thermostat,
                  label: 'TEMP',
                  value:
                      '${summary.temperature!.toStringAsFixed(0)}°${summary.temperatureUnit ?? 'F'}',
                  color: TacticalColors.complete,
                ),
              if (summary.personsHome != null)
                _StatItem(
                  icon: Icons.person,
                  label: 'HOME',
                  value: '${summary.personsHome}',
                  color: const Color(0xFF8B5CF6),
                ),
            ],
          ),
          // Alerts
          if (summary.alerts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: TacticalColors.border),
            const SizedBox(height: 8),
            ...summary.alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: TacticalColors.inProgress,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert,
                        style: TextStyle(
                          color: TacticalColors.inProgress,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick actions card
class _QuickActionsCard extends StatelessWidget {
  final HomeAssistantNotifier notifier;

  const _QuickActionsCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: TacticalColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.lightbulb_outline,
                  label: 'All Lights Off',
                  color: const Color(0xFFFACC15),
                  onPressed: () async {
                    final success = await notifier.allLightsOff();
                    if (success) {
                      HapticFeedback.mediumImpact();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.lock,
                  label: 'Lock All',
                  color: TacticalColors.operational,
                  onPressed: () async {
                    final success = await notifier.lockAll();
                    if (success) {
                      HapticFeedback.mediumImpact();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TacticalColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scenes card
class _ScenesCard extends StatelessWidget {
  final List<HAScene> scenes;
  final HomeAssistantNotifier notifier;

  const _ScenesCard({required this.scenes, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: TacticalColors.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SCENES',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: scenes
                .map(
                  (scene) => _SceneChip(
                    scene: scene,
                    onActivate: () async {
                      final success =
                          await notifier.activateScene(scene.entityId);
                      if (success) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SceneChip extends StatelessWidget {
  final HAScene scene;
  final VoidCallback onActivate;

  const _SceneChip({required this.scene, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActivate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: TacticalColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TacticalColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSceneIcon(scene.name),
              size: 16,
              color: TacticalColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              scene.name,
              style: const TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSceneIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('night') || lower.contains('sleep')) {
      return Icons.nightlight;
    } else if (lower.contains('morning') || lower.contains('wake')) {
      return Icons.wb_sunny;
    } else if (lower.contains('movie') || lower.contains('theater')) {
      return Icons.movie;
    } else if (lower.contains('away') || lower.contains('leave')) {
      return Icons.exit_to_app;
    } else if (lower.contains('home') || lower.contains('arrive')) {
      return Icons.home;
    } else if (lower.contains('party') || lower.contains('guest')) {
      return Icons.celebration;
    }
    return Icons.auto_awesome;
  }
}

/// Filters card
class _FiltersCard extends StatelessWidget {
  final List<HAArea> areas;
  final Set<String> domains;
  final String? selectedAreaId;
  final String? selectedDomain;
  final Function(String?) onAreaChanged;
  final Function(String?) onDomainChanged;
  final VoidCallback onClear;

  const _FiltersCard({
    required this.areas,
    required this.domains,
    required this.selectedAreaId,
    required this.selectedDomain,
    required this.onAreaChanged,
    required this.onDomainChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 12,
                    decoration: BoxDecoration(
                      color: TacticalColors.primary,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FILTER DEVICES',
                    style: TextStyle(
                      color: TacticalColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              if (selectedAreaId != null || selectedDomain != null)
                TextButton(
                  onPressed: onClear,
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: TacticalColors.critical),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Area dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedAreaId,
                  decoration: InputDecoration(
                    labelText: 'Area',
                    labelStyle: const TextStyle(color: TacticalColors.textMuted),
                    filled: true,
                    fillColor: TacticalColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  dropdownColor: TacticalColors.surface,
                  style: const TextStyle(color: TacticalColors.textPrimary),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Areas'),
                    ),
                    ...areas.map(
                      (area) => DropdownMenuItem(
                        value: area.areaId,
                        child: Text(area.name),
                      ),
                    ),
                  ],
                  onChanged: onAreaChanged,
                ),
              ),
              const SizedBox(width: 12),
              // Domain dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedDomain,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: const TextStyle(color: TacticalColors.textMuted),
                    filled: true,
                    fillColor: TacticalColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: TacticalColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  dropdownColor: TacticalColors.surface,
                  style: const TextStyle(color: TacticalColors.textPrimary),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...domains.map(
                      (domain) => DropdownMenuItem(
                        value: domain,
                        child: Text(_formatDomain(domain)),
                      ),
                    ),
                  ],
                  onChanged: onDomainChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDomain(String domain) {
    return domain
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

/// Entities section with cards
class _EntitiesSection extends StatelessWidget {
  final List<HAEntity> entities;
  final List<HAArea> areas;
  final HomeAssistantNotifier notifier;
  final bool isLoading;

  const _EntitiesSection({
    required this.entities,
    required this.areas,
    required this.notifier,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && entities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: TacticalColors.primary),
        ),
      );
    }

    if (entities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: TacticalDecoration.card,
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.devices_other,
                color: TacticalColors.textMuted.withValues(alpha: 0.5),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'NO DEVICES FOUND',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by area
    final grouped = <String?, List<HAEntity>>{};
    for (final entity in entities) {
      grouped.putIfAbsent(entity.areaId, () => []).add(entity);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final areaName = entry.key != null
            ? areas
                .firstWhere((a) => a.areaId == entry.key,
                    orElse: () => HAArea(areaId: '', name: entry.key!))
                .name
            : 'Other';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                areaName.toUpperCase(),
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            ...entry.value.map(
              (entity) => _EntityCard(entity: entity, notifier: notifier),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

/// Individual entity card
class _EntityCard extends StatelessWidget {
  final HAEntity entity;
  final HomeAssistantNotifier notifier;

  const _EntityCard({required this.entity, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showEntityDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TacticalColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: entity.isOn
                ? _getDomainColor(entity.domain).withValues(alpha: 0.5)
                : TacticalColors.border,
            width: entity.isOn ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon - tap for detail
            GestureDetector(
              onTap: () => _showEntityDetail(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entity.isOn
                      ? _getDomainColor(entity.domain).withValues(alpha: 0.2)
                      : TacticalColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDomainIcon(entity.domain, entity.deviceClass),
                  color: entity.isOn
                      ? _getDomainColor(entity.domain)
                      : TacticalColors.textMuted,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info - tap for detail
            Expanded(
              child: GestureDetector(
                onTap: () => _showEntityDetail(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: const TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${entity.state ?? 'Unknown'} • ${entity.domain}',
                      style: const TextStyle(
                        color: TacticalColors.textDim,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Show entity detail modal
  void _showEntityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          _EntityDetailSheet(entity: entity, notifier: notifier),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (entity.domain) {
      case 'light':
      case 'switch':
      case 'fan':
        return Switch(
          value: entity.isOn,
          activeColor: _getDomainColor(entity.domain),
          onChanged: (_) async {
            final success = await notifier.toggle(entity.entityId);
            if (success) HapticFeedback.lightImpact();
          },
        );

      case 'lock':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                entity.state == 'locked' ? Icons.lock : Icons.lock_open,
                color: entity.state == 'locked'
                    ? TacticalColors.operational
                    : TacticalColors.inProgress,
              ),
              onPressed: () async {
                final success = entity.state == 'locked'
                    ? await notifier.unlock(entity.entityId)
                    : await notifier.lock(entity.entityId);
                if (success) HapticFeedback.mediumImpact();
              },
            ),
          ],
        );

      case 'cover':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 20),
              color: TacticalColors.textMuted,
              onPressed: () =>
                  notifier.callEntityService(entity.entityId, 'open'),
            ),
            IconButton(
              icon: const Icon(Icons.stop, size: 20),
              color: TacticalColors.textMuted,
              onPressed: () =>
                  notifier.callEntityService(entity.entityId, 'stop'),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 20),
              color: TacticalColors.textMuted,
              onPressed: () =>
                  notifier.callEntityService(entity.entityId, 'close'),
            ),
          ],
        );

      case 'climate':
        return _ClimateControl(entity: entity, notifier: notifier);

      case 'media_player':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                entity.state == 'playing' ? Icons.pause : Icons.play_arrow,
                size: 20,
              ),
              color: TacticalColors.textMuted,
              onPressed: () async {
                final action =
                    entity.state == 'playing' ? 'media_pause' : 'media_play';
                final success =
                    await notifier.callEntityService(entity.entityId, action);
                if (success && context.mounted) {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${entity.name} ${action == 'media_pause' ? 'paused' : 'playing'}'),
                      backgroundColor: TacticalColors.operational,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );

      case 'vacuum':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                entity.state == 'cleaning' ? Icons.stop : Icons.play_arrow,
                size: 20,
              ),
              color: _getDomainColor(entity.domain),
              onPressed: () async {
                final action = entity.state == 'cleaning' ? 'stop' : 'start';
                final success =
                    await notifier.callEntityService(entity.entityId, action);
                if (success && context.mounted) {
                  HapticFeedback.lightImpact();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, size: 20),
              color: TacticalColors.textMuted,
              onPressed: () =>
                  notifier.callEntityService(entity.entityId, 'return_to_base'),
            ),
          ],
        );

      case 'sensor':
      case 'binary_sensor':
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            entity.state ?? '',
            style: TextStyle(
              color: _getDomainColor(entity.domain),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  IconData _getDomainIcon(String domain, String? deviceClass) {
    switch (domain) {
      case 'light':
        return Icons.lightbulb;
      case 'switch':
        return Icons.power_settings_new;
      case 'lock':
        return Icons.lock;
      case 'cover':
        return Icons.window;
      case 'fan':
        return Icons.air;
      case 'climate':
        return Icons.thermostat;
      case 'sensor':
        if (deviceClass == 'temperature') return Icons.thermostat;
        if (deviceClass == 'humidity') return Icons.water_drop;
        if (deviceClass == 'motion') return Icons.directions_run;
        return Icons.sensors;
      case 'binary_sensor':
        if (deviceClass == 'motion') return Icons.directions_run;
        if (deviceClass == 'door') return Icons.door_front_door;
        if (deviceClass == 'window') return Icons.window;
        return Icons.circle;
      case 'camera':
        return Icons.videocam;
      case 'media_player':
        return Icons.tv;
      case 'person':
        return Icons.person;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'light':
        return const Color(0xFFFACC15);
      case 'switch':
        return TacticalColors.complete;
      case 'lock':
        return TacticalColors.operational;
      case 'cover':
        return const Color(0xFF8B5CF6);
      case 'fan':
        return const Color(0xFF06B6D4);
      case 'climate':
        return TacticalColors.inProgress;
      case 'sensor':
        return const Color(0xFF14B8A6);
      case 'binary_sensor':
        return const Color(0xFFEC4899);
      case 'camera':
        return TacticalColors.critical;
      default:
        return TacticalColors.textMuted;
    }
  }
}

/// Error card
class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorCard({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.critical.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.critical),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: TacticalColors.critical),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: TacticalColors.critical),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: TacticalColors.critical),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// Climate control widget with temperature adjustment
class _ClimateControl extends StatelessWidget {
  final HAEntity entity;
  final HomeAssistantNotifier notifier;

  const _ClimateControl({required this.entity, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final currentTemp = entity.attributes['current_temperature'] as num?;
    final targetTemp = entity.attributes['temperature'] as num?;
    final unit = entity.attributes['unit_of_measurement'] as String? ?? '°F';
    final hvacMode = entity.attributes['hvac_mode'] as String? ?? entity.state;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current/Target temp display
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (currentTemp != null)
              Text(
                '${currentTemp.toStringAsFixed(0)}$unit',
                style: const TextStyle(
                  color: TacticalColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            if (targetTemp != null)
              Text(
                '→ ${targetTemp.toStringAsFixed(0)}$unit',
                style: TextStyle(
                  color: TacticalColors.inProgress,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // Temperature controls
        Container(
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TacticalColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease temp
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: TacticalColors.complete,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final newTemp = (targetTemp ?? 70) - 1;
                  final success = await notifier.setTemperature(
                      entity.entityId, newTemp.toDouble());
                  if (success && context.mounted) {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${entity.name} set to ${newTemp.toStringAsFixed(0)}$unit'),
                        backgroundColor: TacticalColors.complete,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              // Increase temp
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: TacticalColors.inProgress,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final newTemp = (targetTemp ?? 70) + 1;
                  final success = await notifier.setTemperature(
                      entity.entityId, newTemp.toDouble());
                  if (success && context.mounted) {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${entity.name} set to ${newTemp.toStringAsFixed(0)}$unit'),
                        backgroundColor: TacticalColors.inProgress,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        // HVAC mode indicator
        if (hvacMode != null && hvacMode != 'off')
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              _getHvacIcon(hvacMode),
              size: 18,
              color: _getHvacColor(hvacMode),
            ),
          ),
      ],
    );
  }

  IconData _getHvacIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'heat':
        return Icons.whatshot;
      case 'cool':
        return Icons.ac_unit;
      case 'heat_cool':
      case 'auto':
        return Icons.autorenew;
      case 'fan_only':
        return Icons.air;
      case 'dry':
        return Icons.water_drop;
      default:
        return Icons.thermostat;
    }
  }

  Color _getHvacColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'heat':
        return TacticalColors.inProgress;
      case 'cool':
        return TacticalColors.complete;
      case 'heat_cool':
      case 'auto':
        return TacticalColors.operational;
      default:
        return TacticalColors.textMuted;
    }
  }
}

/// Entity detail modal sheet
class _EntityDetailSheet extends StatelessWidget {
  final HAEntity entity;
  final HomeAssistantNotifier notifier;

  const _EntityDetailSheet({required this.entity, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getDomainColor(entity.domain).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDomainIcon(entity.domain, entity.deviceClass),
                  color: _getDomainColor(entity.domain),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: const TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      entity.entityId,
                      style: const TextStyle(
                        color: TacticalColors.textDim,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // State badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: entity.isOn
                      ? TacticalColors.operational.withValues(alpha: 0.2)
                      : TacticalColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: entity.isOn
                        ? TacticalColors.operational
                        : TacticalColors.border,
                  ),
                ),
                child: Text(
                  entity.state?.toUpperCase() ?? 'UNKNOWN',
                  style: TextStyle(
                    color: entity.isOn
                        ? TacticalColors.operational
                        : TacticalColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Domain & Device Class
          _DetailRow(
            label: 'Domain',
            value: entity.domain,
            icon: Icons.category,
          ),
          if (entity.deviceClass != null)
            _DetailRow(
              label: 'Device Class',
              value: entity.deviceClass!,
              icon: Icons.devices,
            ),
          if (entity.areaId != null)
            _DetailRow(
              label: 'Area',
              value: entity.areaId!,
              icon: Icons.room,
            ),

          // Attributes section
          if (entity.attributes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: TacticalColors.border),
            const SizedBox(height: 8),
            const Text(
              'ATTRIBUTES',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            ...entity.attributes.entries
                .where((e) =>
                    !['friendly_name', 'icon', 'entity_id'].contains(e.key))
                .take(8)
                .map((e) => _DetailRow(
                      label: _formatAttributeKey(e.key),
                      value: _formatAttributeValue(e.value),
                      icon: null,
                    )),
          ],

          const SizedBox(height: 24),

          // Action buttons based on domain
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (entity.domain) {
      case 'light':
        return Column(
          children: [
            // Brightness slider for lights
            if (entity.attributes['brightness'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.brightness_6,
                      color: Color(0xFFFACC15), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFACC15),
                        thumbColor: const Color(0xFFFACC15),
                        inactiveTrackColor: TacticalColors.border,
                      ),
                      child: Slider(
                        value:
                            ((entity.attributes['brightness'] as num?) ?? 0)
                                    .toDouble() /
                                255 *
                                100,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label:
                            '${(((entity.attributes['brightness'] as num?) ?? 0).toDouble() / 255 * 100).round()}%',
                        onChangeEnd: (value) async {
                          final success = await notifier.setBrightness(
                              entity.entityId, value.round());
                          if (success && context.mounted) {
                            HapticFeedback.selectionClick();
                          }
                        },
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  Text(
                    '${(((entity.attributes['brightness'] as num?) ?? 0).toDouble() / 255 * 100).round()}%',
                    style: const TextStyle(
                      color: TacticalColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _ActionButtonRow(
              buttons: [
                _ActionButton(
                  label: 'Turn On',
                  icon: Icons.lightbulb,
                  color: const Color(0xFFFACC15),
                  onPressed: () async {
                    final success = await notifier.turnOn(entity.entityId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showActionResult(context, success, 'Light turned on');
                    }
                  },
                ),
                _ActionButton(
                  label: 'Turn Off',
                  icon: Icons.lightbulb_outline,
                  color: TacticalColors.textMuted,
                  onPressed: () async {
                    final success = await notifier.turnOff(entity.entityId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showActionResult(context, success, 'Light turned off');
                    }
                  },
                ),
              ],
            ),
          ],
        );

      case 'lock':
        return _ActionButtonRow(
          buttons: [
            _ActionButton(
              label: 'Lock',
              icon: Icons.lock,
              color: TacticalColors.operational,
              onPressed: () async {
                final success = await notifier.lock(entity.entityId);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showActionResult(context, success, 'Locked');
                }
              },
            ),
            _ActionButton(
              label: 'Unlock',
              icon: Icons.lock_open,
              color: TacticalColors.inProgress,
              onPressed: () async {
                final success = await notifier.unlock(entity.entityId);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showActionResult(context, success, 'Unlocked');
                }
              },
            ),
          ],
        );

      case 'switch':
      case 'fan':
        return _ActionButtonRow(
          buttons: [
            _ActionButton(
              label: 'Toggle',
              icon: Icons.power_settings_new,
              color: _getDomainColor(entity.domain),
              onPressed: () async {
                final success = await notifier.toggle(entity.entityId);
                if (context.mounted) {
                  Navigator.pop(context);
                  _showActionResult(context, success, 'Toggled');
                }
              },
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showActionResult(BuildContext context, bool success, String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: TacticalColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(success ? message : 'Action failed'),
          ],
        ),
        backgroundColor:
            success ? TacticalColors.operational : TacticalColors.critical,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatAttributeKey(String key) {
    return key
        .split('_')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');
  }

  String _formatAttributeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return value.join(', ');
    if (value is Map) return '{...}';
    return value.toString();
  }

  IconData _getDomainIcon(String domain, String? deviceClass) {
    switch (domain) {
      case 'light':
        return Icons.lightbulb;
      case 'switch':
        return Icons.power_settings_new;
      case 'lock':
        return Icons.lock;
      case 'cover':
        return Icons.window;
      case 'fan':
        return Icons.air;
      case 'climate':
        return Icons.thermostat;
      case 'sensor':
        if (deviceClass == 'temperature') return Icons.thermostat;
        if (deviceClass == 'humidity') return Icons.water_drop;
        if (deviceClass == 'motion') return Icons.directions_run;
        return Icons.sensors;
      case 'binary_sensor':
        if (deviceClass == 'motion') return Icons.directions_run;
        if (deviceClass == 'door') return Icons.door_front_door;
        if (deviceClass == 'window') return Icons.window;
        return Icons.circle;
      case 'camera':
        return Icons.videocam;
      case 'media_player':
        return Icons.tv;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'light':
        return const Color(0xFFFACC15);
      case 'switch':
        return TacticalColors.complete;
      case 'lock':
        return TacticalColors.operational;
      case 'cover':
        return const Color(0xFF8B5CF6);
      case 'fan':
        return const Color(0xFF06B6D4);
      case 'climate':
        return TacticalColors.inProgress;
      case 'sensor':
        return const Color(0xFF14B8A6);
      case 'binary_sensor':
        return const Color(0xFFEC4899);
      case 'camera':
        return TacticalColors.critical;
      default:
        return TacticalColors.textMuted;
    }
  }
}

/// Detail row for entity detail sheet
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _DetailRow({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: TacticalColors.textDim, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            '$label: ',
            style: const TextStyle(color: TacticalColors.textDim, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button row for entity detail sheet
class _ActionButtonRow extends StatelessWidget {
  final List<_ActionButton> buttons;

  const _ActionButtonRow({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons
          .map((button) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right:
                        buttons.indexOf(button) < buttons.length - 1 ? 8 : 0,
                  ),
                  child: button,
                ),
              ))
          .toList(),
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
