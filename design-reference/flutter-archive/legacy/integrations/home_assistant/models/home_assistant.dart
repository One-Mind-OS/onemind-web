import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_assistant.freezed.dart';
part 'home_assistant.g.dart';

/// Home Assistant connection status
@freezed
sealed class HAConnectionStatus with _$HAConnectionStatus {
  const factory HAConnectionStatus({
    @Default(false) bool connected,
    String? haVersion,
    String? locationName,
    DateTime? lastSync,
    String? lastError,
  }) = _HAConnectionStatus;

  factory HAConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$HAConnectionStatusFromJson(json);
}

/// Home summary for dashboard card
@freezed
sealed class HAHomeSummary with _$HAHomeSummary {
  const factory HAHomeSummary({
    @Default('Home') String locationName,
    @Default(0) int lightsOn,
    @Default(0) int lightsTotal,
    @Default(0) int locksLocked,
    @Default(0) int locksTotal,
    double? temperature,
    String? temperatureUnit,
    double? humidity,
    @Default([]) List<String> alerts,
    @Default([]) List<String> activeScenes,
    int? personsHome,
  }) = _HAHomeSummary;

  factory HAHomeSummary.fromJson(Map<String, dynamic> json) =>
      _$HAHomeSummaryFromJson(json);
}

/// Entity state
@freezed
sealed class HAEntityState with _$HAEntityState {
  const factory HAEntityState({
    required String entityId,
    required String state,
    @Default({}) Map<String, dynamic> attributes,
    DateTime? lastChanged,
    DateTime? lastUpdated,
  }) = _HAEntityState;

  factory HAEntityState.fromJson(Map<String, dynamic> json) =>
      _$HAEntityStateFromJson(json);
}

/// Entity from registry
@freezed
sealed class HAEntity with _$HAEntity {
  const factory HAEntity({
    required String entityId,
    required String name,
    required String domain,
    String? areaId,
    String? deviceId,
    String? state,
    @Default({}) Map<String, dynamic> attributes,
    @Default(false) bool isOn,
    String? deviceClass,
    String? icon,
  }) = _HAEntity;

  factory HAEntity.fromJson(Map<String, dynamic> json) =>
      _$HAEntityFromJson(json);
}

/// Area/Room
@freezed
sealed class HAArea with _$HAArea {
  const factory HAArea({
    required String areaId,
    required String name,
    String? icon,
    String? floorId,
    @Default([]) List<String> aliases,
  }) = _HAArea;

  factory HAArea.fromJson(Map<String, dynamic> json) =>
      _$HAAreaFromJson(json);
}

/// Scene
@freezed
sealed class HAScene with _$HAScene {
  const factory HAScene({
    required String entityId,
    required String name,
    String? icon,
  }) = _HAScene;

  factory HAScene.fromJson(Map<String, dynamic> json) =>
      _$HASceneFromJson(json);
}

/// Device
@freezed
sealed class HADevice with _$HADevice {
  const factory HADevice({
    required String id,
    required String name,
    String? manufacturer,
    String? model,
    String? swVersion,
    String? areaId,
    @Default(false) bool isDisabled,
  }) = _HADevice;

  factory HADevice.fromJson(Map<String, dynamic> json) =>
      _$HADeviceFromJson(json);
}

/// Alert from event bridge
@freezed
sealed class HAAlert with _$HAAlert {
  const factory HAAlert({
    required String type,
    required String entityId,
    required String message,
    required String priority,
    required DateTime timestamp,
  }) = _HAAlert;

  factory HAAlert.fromJson(Map<String, dynamic> json) =>
      _$HAAlertFromJson(json);
}

/// Entity list response from API
@freezed
sealed class HAEntityListResponse with _$HAEntityListResponse {
  const factory HAEntityListResponse({
    @Default([]) List<HAEntity> entities,
    @Default(0) int count,
    @Default({}) Map<String, int> domainCounts,
  }) = _HAEntityListResponse;

  factory HAEntityListResponse.fromJson(Map<String, dynamic> json) =>
      _$HAEntityListResponseFromJson(json);
}
