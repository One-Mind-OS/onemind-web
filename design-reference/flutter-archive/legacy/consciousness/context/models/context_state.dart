// Context state model

import 'package:flutter/material.dart';

/// Sun state based on time relative to sunrise/sunset
enum SunState {
  day,
  night,
  goldenHour,
  blueHour,
}

/// Current context state
class ContextState {
  final DateTime currentTime;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? weatherCondition;
  final double? temperature;
  final String temperatureUnit;
  final int? humidity;
  final DateTime? sunrise;
  final DateTime? sunset;
  final SunState? sunState;
  final bool isLoading;
  final String? error;

  const ContextState({
    required this.currentTime,
    this.locationName,
    this.latitude,
    this.longitude,
    this.weatherCondition,
    this.temperature,
    this.temperatureUnit = 'F',
    this.humidity,
    this.sunrise,
    this.sunset,
    this.sunState,
    this.isLoading = false,
    this.error,
  });

  ContextState copyWith({
    DateTime? currentTime,
    String? locationName,
    double? latitude,
    double? longitude,
    String? weatherCondition,
    double? temperature,
    String? temperatureUnit,
    int? humidity,
    DateTime? sunrise,
    DateTime? sunset,
    SunState? sunState,
    bool? isLoading,
    String? error,
  }) {
    return ContextState(
      currentTime: currentTime ?? this.currentTime,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      humidity: humidity ?? this.humidity,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      sunState: sunState ?? this.sunState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get weather icon based on condition
  IconData get weatherIcon {
    switch (weatherCondition?.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return sunState == SunState.night ? Icons.nightlight : Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'rain':
      case 'rainy':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
      case 'snowy':
        return Icons.ac_unit;
      case 'fog':
      case 'foggy':
      case 'mist':
        return Icons.foggy;
      case 'windy':
        return Icons.air;
      default:
        return Icons.wb_sunny;
    }
  }

  /// Get sun icon
  IconData get sunIcon {
    switch (sunState) {
      case SunState.day:
        return Icons.wb_sunny;
      case SunState.night:
        return Icons.nightlight;
      case SunState.goldenHour:
        return Icons.wb_twilight;
      case SunState.blueHour:
        return Icons.dark_mode;
      default:
        return Icons.wb_sunny;
    }
  }

  /// Get formatted temperature
  String get formattedTemperature {
    if (temperature == null) return '--';
    return '${temperature!.round()}°$temperatureUnit';
  }

  /// Get formatted time
  String get formattedTime {
    final hour = currentTime.hour > 12
        ? currentTime.hour - 12
        : currentTime.hour == 0
            ? 12
            : currentTime.hour;
    final period = currentTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted sunrise time
  String? get formattedSunrise {
    if (sunrise == null) return null;
    final hour = sunrise!.hour > 12
        ? sunrise!.hour - 12
        : sunrise!.hour == 0
            ? 12
            : sunrise!.hour;
    final period = sunrise!.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString()}:${sunrise!.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted sunset time
  String? get formattedSunset {
    if (sunset == null) return null;
    final hour = sunset!.hour > 12
        ? sunset!.hour - 12
        : sunset!.hour == 0
            ? 12
            : sunset!.hour;
    final period = sunset!.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString()}:${sunset!.minute.toString().padLeft(2, '0')} $period';
  }

  /// Get sun state description
  String get sunStateDescription {
    switch (sunState) {
      case SunState.day:
        return sunset != null ? 'Sunset at $formattedSunset' : 'Day';
      case SunState.night:
        return sunrise != null ? 'Sunrise at $formattedSunrise' : 'Night';
      case SunState.goldenHour:
        return 'Golden Hour';
      case SunState.blueHour:
        return 'Blue Hour';
      default:
        return 'Day';
    }
  }

  factory ContextState.initial() {
    return ContextState(
      currentTime: DateTime.now(),
      isLoading: true,
    );
  }

}
