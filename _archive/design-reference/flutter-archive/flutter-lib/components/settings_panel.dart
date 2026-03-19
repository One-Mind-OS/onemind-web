import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings configuration
class AppSettings {
  final double temperature;
  final bool showTimestamps;
  final bool enableSoundEffects;

  AppSettings({
    this.temperature = 0.7,
    this.showTimestamps = true,
    this.enableSoundEffects = false,
  });

  AppSettings copyWith({
    double? temperature,
    bool? showTimestamps,
    bool? enableSoundEffects,
  }) {
    return AppSettings(
      temperature: temperature ?? this.temperature,
      showTimestamps: showTimestamps ?? this.showTimestamps,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
    );
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void updateTemperature(double value) {
    state = state.copyWith(temperature: value);
  }

  void toggleTimestamps() {
    state = state.copyWith(showTimestamps: !state.showTimestamps);
  }

  void toggleSoundEffects() {
    state = state.copyWith(enableSoundEffects: !state.enableSoundEffects);
  }
}

/// Settings panel widget
class SettingsPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Container(
      width: 400,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
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
                  Icons.settings,
                  color: Color(0xFF00D9FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SETTINGS',
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

          // Settings content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Model Temperature
                _SettingSection(
                  title: 'Model Temperature',
                  subtitle: 'Controls randomness (${settings.temperature.toStringAsFixed(1)})',
                  child: Slider(
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
                ),

                const SizedBox(height: 24),

                // Toggle Settings
                _SettingToggle(
                  title: 'Show Timestamps',
                  subtitle: 'Display relative timestamps on messages',
                  value: settings.showTimestamps,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleTimestamps();
                  },
                ),

                const SizedBox(height: 16),

                _SettingToggle(
                  title: 'Sound Effects',
                  subtitle: 'Enable audio feedback',
                  value: settings.enableSoundEffects,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleSoundEffects();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF00D9FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
