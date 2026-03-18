// Camera provider for Eagle Eye surveillance
// Connects to Frigate NVR backend

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera.dart';

/// Camera state
class CameraState {
  final List<Camera> cameras;
  final List<DetectionEvent> events;
  final Camera? selectedCamera;
  final bool isLoading;
  final bool isLoadingEvents;
  final String? error;
  final FrigateStats? stats;

  const CameraState({
    this.cameras = const [],
    this.events = const [],
    this.selectedCamera,
    this.isLoading = false,
    this.isLoadingEvents = false,
    this.error,
    this.stats,
  });

  CameraState copyWith({
    List<Camera>? cameras,
    List<DetectionEvent>? events,
    Camera? selectedCamera,
    bool? isLoading,
    bool? isLoadingEvents,
    String? error,
    FrigateStats? stats,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      events: events ?? this.events,
      selectedCamera: selectedCamera ?? this.selectedCamera,
      isLoading: isLoading ?? this.isLoading,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      error: error,
      stats: stats ?? this.stats,
    );
  }

  /// Online cameras count
  int get onlineCount => cameras.where((c) => c.isOnline).length;

  /// Offline cameras count
  int get offlineCount => cameras.where((c) => !c.isOnline).length;

  /// Events for selected camera
  List<DetectionEvent> get selectedCameraEvents {
    if (selectedCamera == null) return events;
    return events.where((e) => e.camera == selectedCamera!.id).toList();
  }

  /// Recent events (last 10)
  List<DetectionEvent> get recentEvents => events.take(10).toList();

  /// Events by label
  Map<String, int> get eventsByLabel {
    final map = <String, int>{};
    for (final event in events) {
      map[event.label] = (map[event.label] ?? 0) + 1;
    }
    return map;
  }
}

/// Camera notifier - placeholder for API integration
class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(const CameraState()) {
    _init();
  }

  void _init() {
    // Initialize with empty state - ready for Frigate API connection
    state = const CameraState(
      cameras: [],
      events: [],
      isLoading: false,
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    // TODO: Connect to Frigate API
    // For now, show empty state indicating no cameras connected
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      isLoading: false,
      error: null,
    );
  }

  /// Select a camera
  void selectCamera(Camera camera) {
    state = state.copyWith(selectedCamera: camera);
  }

  /// Filter events by label
  Future<void> filterEventsByLabel(String? label) async {
    state = state.copyWith(isLoadingEvents: true);

    // TODO: Filter from API
    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(isLoadingEvents: false);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for camera state
final cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});

/// Provider for selected camera
final selectedCameraProvider = Provider<Camera?>((ref) {
  return ref.watch(cameraProvider).selectedCamera;
});

/// Provider for online cameras
final onlineCamerasProvider = Provider<List<Camera>>((ref) {
  return ref.watch(cameraProvider).cameras.where((c) => c.isOnline).toList();
});

/// Provider for recent events
final recentEventsProvider = Provider<List<DetectionEvent>>((ref) {
  return ref.watch(cameraProvider).recentEvents;
});

/// Provider for events by label stats
final eventsByLabelProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(cameraProvider).eventsByLabel;
});

/// Provider for Frigate stats
final frigateStatsProvider = Provider<FrigateStats?>((ref) {
  return ref.watch(cameraProvider).stats;
});
