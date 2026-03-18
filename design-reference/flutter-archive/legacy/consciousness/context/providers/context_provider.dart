// Context provider using Riverpod

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/context_state.dart';

/// Context notifier
class ContextNotifier extends StateNotifier<ContextState> {
  Timer? _timeTimer;
  Timer? _refreshTimer;

  ContextNotifier() : super(ContextState.initial()) {
    _startTimers();
    _loadContext();
  }

  void _startTimers() {
    // Cancel existing timers before creating new ones to prevent duplicates
    _cancelTimers();

    // Update time every minute
    _timeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      state = state.copyWith(currentTime: DateTime.now());
      _updateSunState();
    });

    // Refresh weather every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadWeather();
    });
  }

  void _cancelTimers() {
    _timeTimer?.cancel();
    _timeTimer = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _loadContext() async {
    state = state.copyWith(isLoading: true);

    try {
      // Context is loaded from device and external APIs
      // For now, use initial state with current time
      state = state.copyWith(
        isLoading: false,
        currentTime: DateTime.now(),
      );

      // Attempt to load weather and location in background
      _loadWeather();
      _loadLocation();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Context not available: $e',
      );
    }
  }

  Future<void> _loadWeather() async {
    // Weather API not yet configured
    // Will be implemented when weather service is set up
  }

  Future<void> _loadLocation() async {
    // Location services not yet configured
    // Will be implemented when location permissions are set up
  }

  void _updateSunState() {
    final now = state.currentTime;
    final sunrise = state.sunrise;
    final sunset = state.sunset;

    if (sunrise == null || sunset == null) return;

    SunState newState;
    if (now.isBefore(sunrise)) {
      // Before sunrise
      final hoursBefore = sunrise.difference(now).inMinutes / 60;
      if (hoursBefore <= 0.5) {
        newState = SunState.blueHour;
      } else {
        newState = SunState.night;
      }
    } else if (now.isAfter(sunset)) {
      // After sunset
      final hoursAfter = now.difference(sunset).inMinutes / 60;
      if (hoursAfter <= 0.5) {
        newState = SunState.goldenHour;
      } else if (hoursAfter <= 1) {
        newState = SunState.blueHour;
      } else {
        newState = SunState.night;
      }
    } else {
      // Between sunrise and sunset
      final minutesToSunset = sunset.difference(now).inMinutes;
      final minutesFromSunrise = now.difference(sunrise).inMinutes;

      if (minutesFromSunrise <= 30 || minutesToSunset <= 60) {
        newState = SunState.goldenHour;
      } else {
        newState = SunState.day;
      }
    }

    if (state.sunState != newState) {
      state = state.copyWith(sunState: newState);
    }
  }

  Future<void> refresh() async {
    await _loadContext();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}

/// Provider for context state
final contextProvider =
    StateNotifierProvider<ContextNotifier, ContextState>((ref) {
  return ContextNotifier();
});

/// Provider for current time only
final currentTimeProvider = Provider<DateTime>((ref) {
  return ref.watch(contextProvider).currentTime;
});

/// Provider for weather summary
final weatherSummaryProvider = Provider<String>((ref) {
  final state = ref.watch(contextProvider);
  if (state.weatherCondition == null) return '--';
  return '${state.formattedTemperature}, ${state.weatherCondition}';
});
