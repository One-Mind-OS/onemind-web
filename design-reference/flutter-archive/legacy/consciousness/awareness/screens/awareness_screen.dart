// Awareness Screen - Tactical Design
// System awareness mode control and status
// 4 modes: Dormant, Aware, Present, Omnipresent

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../platform/providers/app_providers.dart';
import '../../../shared/models/awareness.dart';
import '../../../shared/models/context.dart';

class AwarenessScreen extends ConsumerStatefulWidget {
  const AwarenessScreen({super.key});

  @override
  ConsumerState<AwarenessScreen> createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends ConsumerState<AwarenessScreen>
    with SingleTickerProviderStateMixin {
  bool _isConnected = true;
  bool _isSyncing = false;
  Timer? _heartbeatTimer;
  DateTime? _lastHeartbeat;

  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  @override
  void initState() {
    super.initState();
    _startHeartbeat();

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _heartbeatAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: Curves.easeInOut,
      ),
    );

    _heartbeatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _heartbeatController.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnection();
    });
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final client = ref.read(agnoClientProvider);
      await client.healthCheck();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _lastHeartbeat = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final awarenessBarAsync = ref.watch(awarenessBarProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('AWARENESS', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () {
              ref.invalidate(awarenessBarProvider);
              ref.invalidate(awarenessProvider);
            },
          ),
        ],
      ),
      body: awarenessBarAsync.when(
        data: (barData) => barData != null
            ? _buildContent(context, barData)
            : _buildFallbackContent(context),
        loading: () => const Center(
          child: CircularProgressIndicator(color: TacticalColors.primary),
        ),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: TacticalColors.critical.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'CONNECTION ERROR',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              ref.invalidate(awarenessBarProvider);
              ref.invalidate(awarenessProvider);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: TacticalColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: TacticalColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackContent(BuildContext context) {
    final awarenessAsync = ref.watch(awarenessProvider);
    return awarenessAsync.when(
      data: (state) => _buildLegacyContent(context, state),
      loading: () => const Center(
        child: CircularProgressIndicator(color: TacticalColors.primary),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildContent(BuildContext context, AwarenessBarData barData) {
    final mode = _modeFromString(barData.mode);
    final sliderValue = _sliderValueForLevel(barData.level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Status Card
          _buildConnectionCard(),
          const SizedBox(height: 16),

          // Main Awareness Card with Slider
          _buildMainAwarenessCard(context, barData, mode, sliderValue),
          const SizedBox(height: 16),

          // Permissions Card
          _buildPermissionsCard(barData),
          const SizedBox(height: 24),

          // Mode Selection List
          _buildSectionHeader('QUICK MODE SELECTION', Icons.speed),
          const SizedBox(height: 16),

          ...AwarenessMode.values.map((modeOption) {
            final isSelected = mode == modeOption;
            return _buildModeCard(modeOption, isSelected);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: TacticalColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard() {
    final statusColor = _isConnected
        ? TacticalColors.operational
        : TacticalColors.critical;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildHeartbeatIndicator(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                if (_lastHeartbeat != null)
                  Text(
                    'Last heartbeat: ${_formatTime(_lastHeartbeat!)}',
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (_isSyncing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TacticalColors.inProgress,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeartbeatIndicator() {
    return AnimatedBuilder(
      animation: _heartbeatAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isConnected ? _heartbeatAnimation.value : 1.0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.critical,
              boxShadow: _isConnected
                  ? [
                      BoxShadow(
                        color: TacticalColors.operational.withValues(alpha: 0.5),
                        blurRadius: 8 * _heartbeatAnimation.value,
                        spreadRadius: 2 * _heartbeatAnimation.value,
                      )
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainAwarenessCard(BuildContext context, AwarenessBarData barData,
      AwarenessMode mode, double sliderValue) {
    final modeColor = _getColorForMode(mode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          // Mode Icon and Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _getIconForMode(mode),
                    size: 32,
                    color: modeColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barData.modeDisplay.toUpperCase(),
                    style: TextStyle(
                      color: modeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    barData.status,
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Level Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AWARENESS LEVEL',
                    style: TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      barData.levelPercent,
                      style: TextStyle(
                        color: modeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: barData.level / 100,
                  backgroundColor: TacticalColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Slider for mode selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ADJUST MODE',
                style: TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: modeColor,
                  inactiveTrackColor: TacticalColors.border,
                  thumbColor: modeColor,
                  overlayColor: modeColor.withValues(alpha: 0.2),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: sliderValue,
                  min: 0,
                  max: 100,
                  divisions: 3,
                  onChanged: (value) {
                    final newMode = _modeFromSlider(value);
                    if (newMode != mode) {
                      _setAwarenessMode(context, newMode);
                    }
                  },
                ),
              ),
              // Mode labels under slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: AwarenessMode.values.map((m) {
                    final isActive = m == mode;
                    return GestureDetector(
                      onTap: () => _setAwarenessMode(context, m),
                      child: Text(
                        m.name.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? _getColorForMode(m) : TacticalColors.textMuted,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(AwarenessBarData barData) {
    final mode = _modeFromString(barData.mode);
    final canExecute =
        mode == AwarenessMode.present || mode == AwarenessMode.omnipresent;
    final canMonitor = mode != AwarenessMode.dormant;
    final requiresApproval =
        mode == AwarenessMode.dormant || mode == AwarenessMode.aware;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVE PERMISSIONS',
                style: TextStyle(
                  color: TacticalColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              if (barData.status.contains('|'))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TacticalColors.complete.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: TacticalColors.complete,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        barData.status.split('|').last.trim(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: TacticalColors.complete,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPermissionBadge(
                'Interrupt',
                barData.canInterrupt,
                Icons.notifications_active,
              ),
              _buildPermissionBadge(
                'Execute',
                canExecute,
                Icons.play_arrow,
                isHighlight: true,
              ),
              _buildPermissionBadge(
                'Voice',
                barData.voiceActive,
                Icons.mic,
              ),
              _buildPermissionBadge(
                'Monitor',
                canMonitor,
                Icons.visibility,
              ),
              _buildPermissionBadge(
                'Sources',
                barData.sourcesActive > 0,
                Icons.sensors,
                subtitle: '${barData.sourcesActive}/${barData.sourcesTotal}',
              ),
              if (requiresApproval)
                _buildPermissionBadge(
                  'Approval',
                  true,
                  Icons.approval,
                  isWarning: true,
                ),
              if (!requiresApproval)
                _buildPermissionBadge(
                  'Auto',
                  true,
                  Icons.auto_mode,
                  isHighlight: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBadge(
    String label,
    bool enabled,
    IconData icon, {
    String? subtitle,
    bool isHighlight = false,
    bool isWarning = false,
  }) {
    Color activeColor;
    if (isHighlight) {
      activeColor = TacticalColors.primary;
    } else if (isWarning) {
      activeColor = TacticalColors.inProgress;
    } else {
      activeColor = TacticalColors.operational;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled
            ? activeColor.withValues(alpha: 0.1)
            : TacticalColors.card,
        border: Border.all(
          color: enabled
              ? activeColor.withValues(alpha: 0.3)
              : TacticalColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: enabled ? activeColor : TacticalColors.textDim,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled ? TacticalColors.textPrimary : TacticalColors.textMuted,
                  fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: enabled ? activeColor : TacticalColors.textDim,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(AwarenessMode modeOption, bool isSelected) {
    final modeColor = _getColorForMode(modeOption);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? modeColor.withValues(alpha: 0.1)
            : TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? modeColor.withValues(alpha: 0.5)
              : TacticalColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _setAwarenessMode(context, modeOption),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForMode(modeOption),
                    color: modeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modeOption.name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? modeColor : TacticalColors.textPrimary,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDescriptionForMode(modeOption),
                        style: const TextStyle(
                          color: TacticalColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: modeColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyContent(BuildContext context, AwarenessState state) {
    final modeColor = _getColorForMode(state.mode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: TacticalDecoration.card,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForMode(state.mode),
                    size: 64,
                    color: modeColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.mode.name.toUpperCase(),
                  style: TextStyle(
                    color: modeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getDescriptionForMode(state.mode),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('CHANGE MODE', Icons.tune),
          const SizedBox(height: 16),
          ...AwarenessMode.values.map((mode) {
            final isSelected = state.mode == mode;
            return _buildModeCard(mode, isSelected);
          }),
        ],
      ),
    );
  }

  AwarenessMode _modeFromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'dormant':
        return AwarenessMode.dormant;
      case 'aware':
        return AwarenessMode.aware;
      case 'present':
        return AwarenessMode.present;
      case 'omnipresent':
        return AwarenessMode.omnipresent;
      default:
        return AwarenessMode.aware;
    }
  }

  double _sliderValueForLevel(int level) {
    if (level >= 90) return 100;
    if (level >= 65) return 75;
    if (level >= 35) return 50;
    if (level >= 10) return 25;
    return 0;
  }

  AwarenessMode _modeFromSlider(double value) {
    if (value >= 75) return AwarenessMode.omnipresent;
    if (value >= 50) return AwarenessMode.present;
    if (value >= 25) return AwarenessMode.aware;
    return AwarenessMode.dormant;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 5) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  IconData _getIconForMode(AwarenessMode mode) {
    switch (mode) {
      case AwarenessMode.dormant:
        return Icons.bedtime;
      case AwarenessMode.aware:
        return Icons.visibility;
      case AwarenessMode.present:
        return Icons.flash_on;
      case AwarenessMode.omnipresent:
        return Icons.radio_button_checked;
    }
  }

  Color _getColorForMode(AwarenessMode mode) {
    switch (mode) {
      case AwarenessMode.dormant:
        return TacticalColors.textMuted;
      case AwarenessMode.aware:
        return TacticalColors.complete;
      case AwarenessMode.present:
        return TacticalColors.inProgress;
      case AwarenessMode.omnipresent:
        return TacticalColors.primary;
    }
  }

  String _getDescriptionForMode(AwarenessMode mode) {
    switch (mode) {
      case AwarenessMode.dormant:
        return 'Sleeping - Emergencies only';
      case AwarenessMode.aware:
        return 'Watching passively';
      case AwarenessMode.present:
        return 'Engaged, ready to act';
      case AwarenessMode.omnipresent:
        return 'Full presence everywhere';
    }
  }

  Future<void> _setAwarenessMode(
    BuildContext context,
    AwarenessMode mode,
  ) async {
    setState(() => _isSyncing = true);
    try {
      final client = ref.read(agnoClientProvider);
      await client.setAwarenessMode(mode);

      ref.invalidate(awarenessBarProvider);
      ref.invalidate(awarenessProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Awareness mode set to ${mode.name}'),
            backgroundColor: TacticalColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: TacticalColors.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
