import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../platform/api/agno_client.dart';
import '../../../platform/providers/app_providers.dart';
import '../models/home_assistant.dart';

/// State for Home Assistant feature
class HomeAssistantState {
  final HAConnectionStatus status;
  final HAHomeSummary? summary;
  final List<HAEntity> entities;
  final List<HAArea> areas;
  final List<HAScene> scenes;
  final List<HAAlert> alerts;
  final bool isLoading;
  final String? error;
  final String? selectedAreaId;
  final String? selectedDomain;

  const HomeAssistantState({
    this.status = const HAConnectionStatus(),
    this.summary,
    this.entities = const [],
    this.areas = const [],
    this.scenes = const [],
    this.alerts = const [],
    this.isLoading = false,
    this.error,
    this.selectedAreaId,
    this.selectedDomain,
  });

  HomeAssistantState copyWith({
    HAConnectionStatus? status,
    HAHomeSummary? summary,
    List<HAEntity>? entities,
    List<HAArea>? areas,
    List<HAScene>? scenes,
    List<HAAlert>? alerts,
    bool? isLoading,
    String? error,
    String? selectedAreaId,
    String? selectedDomain,
  }) {
    return HomeAssistantState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      entities: entities ?? this.entities,
      areas: areas ?? this.areas,
      scenes: scenes ?? this.scenes,
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedDomain: selectedDomain ?? this.selectedDomain,
    );
  }

  /// Get entities filtered by area and domain
  List<HAEntity> get filteredEntities {
    return entities.where((e) {
      if (selectedAreaId != null && e.areaId != selectedAreaId) return false;
      if (selectedDomain != null && e.domain != selectedDomain) return false;
      return true;
    }).toList();
  }

  /// Get entities grouped by area
  Map<String?, List<HAEntity>> get entitiesByArea {
    final grouped = <String?, List<HAEntity>>{};
    for (final entity in filteredEntities) {
      grouped.putIfAbsent(entity.areaId, () => []).add(entity);
    }
    return grouped;
  }

  /// Get unique domains from entities
  Set<String> get availableDomains {
    return entities.map((e) => e.domain).toSet();
  }
}

/// Provider for Home Assistant state
final homeAssistantProvider =
    StateNotifierProvider<HomeAssistantNotifier, HomeAssistantState>((ref) {
  final apiClient = ref.watch(agnoClientProvider);
  return HomeAssistantNotifier(apiClient);
});

/// Notifier for Home Assistant state management
class HomeAssistantNotifier extends StateNotifier<HomeAssistantState> {
  final AgnoClient _apiClient;

  HomeAssistantNotifier(this._apiClient) : super(const HomeAssistantState());

  /// Fetch connection status
  Future<void> fetchStatus() async {
    try {
      final response = await _apiClient.get('/api/ha/status');
      if (response != null) {
        state = state.copyWith(
          status: HAConnectionStatus.fromJson(response),
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch status: $e');
    }
  }

  /// Fetch home summary for dashboard
  Future<void> fetchSummary() async {
    try {
      final response = await _apiClient.get('/api/ha/summary');
      if (response != null) {
        state = state.copyWith(
          summary: HAHomeSummary.fromJson(response),
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch summary: $e');
    }
  }

  /// Fetch all entities
  Future<void> fetchEntities({String? domain, String? areaId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final queryParams = <String, String>{};
      if (domain != null) queryParams['domain'] = domain;
      if (areaId != null) queryParams['area_id'] = areaId;

      final query = queryParams.isNotEmpty
          ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
          : '';

      final response = await _apiClient.get('/api/ha/entities$query');
      if (response != null) {
        final entities = (response['entities'] as List?)
                ?.map((e) => HAEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        state = state.copyWith(
          entities: entities,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch entities: $e',
      );
    }
  }

  /// Fetch all areas
  Future<void> fetchAreas() async {
    try {
      final response = await _apiClient.get('/api/ha/areas');
      if (response != null) {
        final areas = (response['areas'] as List?)
                ?.map((e) => HAArea.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        state = state.copyWith(areas: areas);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch areas: $e');
    }
  }

  /// Fetch all scenes
  Future<void> fetchScenes() async {
    try {
      final response = await _apiClient.get('/api/ha/scenes');
      if (response != null) {
        final scenes = (response['scenes'] as List?)
                ?.map((e) => HAScene.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        state = state.copyWith(scenes: scenes);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch scenes: $e');
    }
  }

  /// Load all data
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.wait([
      fetchStatus(),
      fetchSummary(),
      fetchEntities(),
      fetchAreas(),
      fetchScenes(),
    ]);
    state = state.copyWith(isLoading: false);
  }

  /// Call service on entity
  Future<bool> callEntityService(
    String entityId,
    String action, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/ha/entities/$entityId/call',
        data: {
          'action': action,
          if (data != null) 'data': data,
        },
      );
      if (response != null && response['success'] == true) {
        // Refresh entities to get updated state
        await fetchEntities();
        await fetchSummary();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to call service: $e');
      return false;
    }
  }

  /// Turn on entity
  Future<bool> turnOn(String entityId) => callEntityService(entityId, 'turn_on');

  /// Turn off entity
  Future<bool> turnOff(String entityId) =>
      callEntityService(entityId, 'turn_off');

  /// Toggle entity
  Future<bool> toggle(String entityId) => callEntityService(entityId, 'toggle');

  /// Lock
  Future<bool> lock(String entityId) => callEntityService(entityId, 'lock');

  /// Unlock
  Future<bool> unlock(String entityId) => callEntityService(entityId, 'unlock');

  /// Activate scene
  Future<bool> activateScene(String sceneId) async {
    try {
      final id = sceneId.startsWith('scene.') ? sceneId.substring(6) : sceneId;
      final response = await _apiClient.post('/api/ha/scenes/$id/activate');
      if (response != null && response['success'] == true) {
        await fetchSummary();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to activate scene: $e');
      return false;
    }
  }

  /// Quick action: Turn off all lights
  Future<bool> allLightsOff() async {
    try {
      final response = await _apiClient.post('/api/ha/quick/lights-off');
      if (response != null && response['success'] == true) {
        await fetchSummary();
        await fetchEntities();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to turn off lights: $e');
      return false;
    }
  }

  /// Quick action: Lock all
  Future<bool> lockAll() async {
    try {
      final response = await _apiClient.post('/api/ha/quick/lock-all');
      if (response != null && response['success'] == true) {
        await fetchSummary();
        await fetchEntities();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Failed to lock all: $e');
      return false;
    }
  }

  /// Set brightness
  Future<bool> setBrightness(String entityId, int brightness) {
    return callEntityService(
      entityId,
      'turn_on',
      data: {'brightness_pct': brightness},
    );
  }

  /// Set temperature for climate entities
  Future<bool> setTemperature(String entityId, double temperature) {
    return callEntityService(
      entityId,
      'set_temperature',
      data: {'temperature': temperature},
    );
  }

  /// Set HVAC mode for climate entities
  Future<bool> setHvacMode(String entityId, String mode) {
    return callEntityService(
      entityId,
      'set_hvac_mode',
      data: {'hvac_mode': mode},
    );
  }

  /// Set area filter
  void setAreaFilter(String? areaId) {
    state = state.copyWith(selectedAreaId: areaId);
  }

  /// Set domain filter
  void setDomainFilter(String? domain) {
    state = state.copyWith(selectedDomain: domain);
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(selectedAreaId: null, selectedDomain: null);
  }

  /// Force sync registries
  Future<void> syncRegistries() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.post('/api/ha/sync');
      await loadAll();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sync: $e',
      );
    }
  }

  /// Add alert (from WebSocket/NATS)
  void addAlert(HAAlert alert) {
    state = state.copyWith(
      alerts: [alert, ...state.alerts].take(50).toList(),
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
