import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Audio System for OneMind OS
/// ============================
/// Provides audio feedback for system events, alerts, and interactions.
/// Uses web-compatible tone generation and optional sound files.

class AudioSystem {
  static final AudioSystem _instance = AudioSystem._internal();
  factory AudioSystem() => _instance;
  AudioSystem._internal();

  final AudioPlayer _alertPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _uiPlayer = AudioPlayer();

  bool _enabled = true;
  double _volume = 0.5;

  // Sound URLs (using web-compatible sources)
  static const String _alertSound = 'https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3';
  static const String _warningSound = 'https://assets.mixkit.co/active_storage/sfx/2867/2867-preview.mp3';
  static const String _successSound = 'https://assets.mixkit.co/active_storage/sfx/2866/2866-preview.mp3';
  static const String _clickSound = 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3';
  static const String _connectSound = 'https://assets.mixkit.co/active_storage/sfx/2570/2570-preview.mp3';
  static const String _disconnectSound = 'https://assets.mixkit.co/active_storage/sfx/2572/2572-preview.mp3';

  bool get enabled => _enabled;
  double get volume => _volume;

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      stopAll();
    }
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _alertPlayer.setVolume(_volume);
    _ambientPlayer.setVolume(_volume * 0.3); // Ambient is quieter
    _uiPlayer.setVolume(_volume * 0.7);
  }

  /// Play alert sound for critical events
  Future<void> playAlert() async {
    if (!_enabled) return;
    try {
      await _alertPlayer.setVolume(_volume);
      await _alertPlayer.play(UrlSource(_alertSound));
    } catch (e) {
      // Audio not available, fail silently
    }
  }

  /// Play warning sound for non-critical alerts
  Future<void> playWarning() async {
    if (!_enabled) return;
    try {
      await _alertPlayer.setVolume(_volume);
      await _alertPlayer.play(UrlSource(_warningSound));
    } catch (e) {
      // Audio not available
    }
  }

  /// Play success sound for positive events
  Future<void> playSuccess() async {
    if (!_enabled) return;
    try {
      await _uiPlayer.setVolume(_volume);
      await _uiPlayer.play(UrlSource(_successSound));
    } catch (e) {
      // Audio not available
    }
  }

  /// Play click sound for UI interactions
  Future<void> playClick() async {
    if (!_enabled) return;
    try {
      await _uiPlayer.setVolume(_volume * 0.5);
      await _uiPlayer.play(UrlSource(_clickSound));
    } catch (e) {
      // Audio not available
    }
  }

  /// Play connection established sound
  Future<void> playConnect() async {
    if (!_enabled) return;
    try {
      await _uiPlayer.setVolume(_volume);
      await _uiPlayer.play(UrlSource(_connectSound));
    } catch (e) {
      // Audio not available
    }
  }

  /// Play disconnection sound
  Future<void> playDisconnect() async {
    if (!_enabled) return;
    try {
      await _uiPlayer.setVolume(_volume);
      await _uiPlayer.play(UrlSource(_disconnectSound));
    } catch (e) {
      // Audio not available
    }
  }

  /// Play sound based on event type
  Future<void> playForEvent(String eventType) async {
    if (!_enabled) return;

    switch (eventType.toLowerCase()) {
      case 'alert':
      case 'critical':
      case 'error':
        await playAlert();
        break;
      case 'warning':
      case 'caution':
        await playWarning();
        break;
      case 'success':
      case 'complete':
      case 'done':
        await playSuccess();
        break;
      case 'connect':
      case 'online':
      case 'joined':
        await playConnect();
        break;
      case 'disconnect':
      case 'offline':
      case 'left':
        await playDisconnect();
        break;
      default:
        await playClick();
    }
  }

  /// Play sound based on asset health change
  Future<void> playForHealthChange(double oldHealth, double newHealth) async {
    if (!_enabled) return;

    // Health dropped significantly
    if (newHealth < oldHealth - 0.2) {
      if (newHealth < 0.3) {
        await playAlert();
      } else {
        await playWarning();
      }
    }
    // Health recovered significantly
    else if (newHealth > oldHealth + 0.2 && newHealth > 0.8) {
      await playSuccess();
    }
  }

  /// Haptic feedback for mobile devices
  Future<void> hapticLight() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> hapticMedium() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> hapticHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  void stopAll() {
    _alertPlayer.stop();
    _ambientPlayer.stop();
    _uiPlayer.stop();
  }

  void dispose() {
    _alertPlayer.dispose();
    _ambientPlayer.dispose();
    _uiPlayer.dispose();
  }
}

/// Sound event types for easy reference
enum SoundEvent {
  alert,
  warning,
  success,
  click,
  connect,
  disconnect,
  nodeOnline,
  nodeOffline,
  healthCritical,
  healthRecovered,
  dataReceived,
}
