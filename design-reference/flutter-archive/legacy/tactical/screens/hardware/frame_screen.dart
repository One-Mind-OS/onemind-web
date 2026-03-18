import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';

/// Frame Screen - Brilliant Labs Frame AR Glasses
/// BLE connection, display control, AR features
class FrameScreen extends ConsumerStatefulWidget {
  const FrameScreen({super.key});

  @override
  ConsumerState<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends ConsumerState<FrameScreen> {
  bool _isConnected = false;
  double _brightness = 0.7;
  double _textSize = 0.5;
  int _selectedColor = 0;
  bool _liveTranslation = false;
  bool _navigation = false;
  bool _notifications = true;
  bool _voiceAssistant = true;

  final _colors = [
    TacticalColors.critical,
    TacticalColors.operational,
    TacticalColors.inProgress,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('FRAME', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              color: _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.textMuted,
            ),
            onPressed: _toggleConnection,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: TacticalColors.primary),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDeviceCard(),
            const SizedBox(height: 16),
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'DISPLAY CONTROLS'),
            const SizedBox(height: 12),
            _buildDisplayControls(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'AR FEATURES'),
            const SizedBox(height: 12),
            _buildARFeatures(),
            const SizedBox(height: 24),
            const TacticalSectionHeader(title: 'QUICK ACTIONS'),
            const SizedBox(height: 12),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TacticalDecoration.cardElevated(
        _isConnected ? TacticalColors.operational : TacticalColors.primary,
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TacticalColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isConnected
                    ? TacticalColors.operational
                    : TacticalColors.primary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.preview,
              size: 40,
              color: _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BRILLIANT LABS',
                  style: TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Frame',
                  style: TextStyle(
                    color: TacticalColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(Icons.battery_full, _isConnected ? '92%' : '--'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.memory, _isConnected ? 'v1.2.3' : '--'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TacticalColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: TacticalColors.textMuted),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: TacticalColors.textSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: TacticalDecoration.statusDot(
              _isConnected
                  ? TacticalColors.operational
                  : TacticalColors.nonOperational,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                  style: TacticalText.statusLabel(
                    _isConnected
                        ? TacticalColors.operational
                        : TacticalColors.nonOperational,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isConnected ? 'Frame is ready' : 'Tap to scan for devices',
                  style: TacticalText.cardSubtitle,
                ),
              ],
            ),
          ),
          TacticalOutlineButton(
            label: _isConnected ? 'DISCONNECT' : 'SCAN',
            color: _isConnected
                ? TacticalColors.nonOperational
                : TacticalColors.primary,
            onTap: _toggleConnection,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayControls() {
    return Container(
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          _buildControlRow(
            icon: Icons.brightness_6,
            title: 'Brightness',
            trailing: _buildSlider(_brightness, (v) => setState(() => _brightness = v)),
          ),
          const Divider(color: TacticalColors.border, height: 1),
          _buildControlRow(
            icon: Icons.text_fields,
            title: 'Text Size',
            trailing: _buildSlider(_textSize, (v) => setState(() => _textSize = v)),
          ),
          const Divider(color: TacticalColors.border, height: 1),
          _buildControlRow(
            icon: Icons.palette,
            title: 'Display Color',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_colors.length, (i) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildColorDot(_colors[i], i == _selectedColor, i),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TacticalColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) {
    return SizedBox(
      width: 120,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: _isConnected ? TacticalColors.primary : TacticalColors.textDim,
          inactiveTrackColor: TacticalColors.border,
          thumbColor: _isConnected ? TacticalColors.primary : TacticalColors.textDim,
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: Slider(
          value: value,
          onChanged: _isConnected ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, bool isSelected, int index) {
    return GestureDetector(
      onTap: _isConnected ? () => setState(() => _selectedColor = index) : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _isConnected ? color : color.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
      ),
    );
  }

  Widget _buildARFeatures() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.translate,
          title: 'Live Translation',
          description: 'Real-time text translation overlay',
          isEnabled: _liveTranslation,
          onToggle: () => setState(() => _liveTranslation = !_liveTranslation),
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: Icons.navigation,
          title: 'Navigation',
          description: 'Turn-by-turn AR directions',
          isEnabled: _navigation,
          onToggle: () => setState(() => _navigation = !_navigation),
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: Icons.notifications,
          title: 'Notifications',
          description: 'Display phone notifications',
          isEnabled: _notifications,
          onToggle: () => setState(() => _notifications = !_notifications),
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          icon: Icons.record_voice_over,
          title: 'Voice Assistant',
          description: 'Hands-free Legacy interaction',
          isEnabled: _voiceAssistant,
          onToggle: () => setState(() => _voiceAssistant = !_voiceAssistant),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    final effectiveEnabled = _isConnected && isEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveEnabled
                  ? TacticalColors.primary.withValues(alpha: 0.1)
                  : TacticalColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: effectiveEnabled ? TacticalColors.primary : TacticalColors.textDim,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _isConnected ? TacticalColors.textPrimary : TacticalColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(description, style: TacticalText.cardSubtitle),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: _isConnected ? (_) => onToggle() : null,
            activeColor: TacticalColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton(Icons.camera_alt, 'CAPTURE')),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(Icons.mic, 'VOICE')),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(Icons.center_focus_strong, 'FOCUS')),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: _isConnected ? () {} : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: TacticalDecoration.card,
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: _isConnected ? TacticalColors.primary : TacticalColors.textDim,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: _isConnected ? TacticalColors.textSecondary : TacticalColors.textDim,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FRAME SETTINGS', style: TacticalText.screenTitle),
            const SizedBox(height: 24),
            const Text(
              'Advanced settings for Brilliant Labs Frame. Configure display preferences, gesture controls, and more.',
              style: TextStyle(color: TacticalColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TacticalOutlineButton(
              label: 'CLOSE',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
