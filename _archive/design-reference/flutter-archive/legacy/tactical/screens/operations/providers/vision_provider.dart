// Vision provider for Edge AI and Vision Pipeline
// Manages edge connections and inference pipelines

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vision.dart';

/// Vision state
class VisionState {
  final List<EdgeConnection> connections;
  final List<VisionPipeline> pipelines;
  final List<InferenceResult> recentResults;
  final EdgeConnection? selectedConnection;
  final VisionPipeline? selectedPipeline;
  final bool isLoading;
  final String? error;

  const VisionState({
    this.connections = const [],
    this.pipelines = const [],
    this.recentResults = const [],
    this.selectedConnection,
    this.selectedPipeline,
    this.isLoading = false,
    this.error,
  });

  VisionState copyWith({
    List<EdgeConnection>? connections,
    List<VisionPipeline>? pipelines,
    List<InferenceResult>? recentResults,
    EdgeConnection? selectedConnection,
    VisionPipeline? selectedPipeline,
    bool? isLoading,
    String? error,
  }) {
    return VisionState(
      connections: connections ?? this.connections,
      pipelines: pipelines ?? this.pipelines,
      recentResults: recentResults ?? this.recentResults,
      selectedConnection: selectedConnection ?? this.selectedConnection,
      selectedPipeline: selectedPipeline ?? this.selectedPipeline,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get onlineCount =>
      connections.where((c) => c.status == ConnectionStatus.online).length;

  int get activePipelineCount => pipelines.where((p) => p.isActive).length;
}

/// Vision notifier
class VisionNotifier extends StateNotifier<VisionState> {
  VisionNotifier() : super(const VisionState()) {
    _init();
  }

  void _init() {
    state = const VisionState(
      connections: [],
      pipelines: [],
      recentResults: [],
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Connect to Edge AI backend
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isLoading: false);
  }

  void selectConnection(EdgeConnection connection) {
    state = state.copyWith(selectedConnection: connection);
  }

  void selectPipeline(VisionPipeline pipeline) {
    state = state.copyWith(selectedPipeline: pipeline);
  }

  Future<void> addConnection({
    required String name,
    required String host,
    int port = 8000,
  }) async {
    // TODO: Add connection to backend
  }

  Future<void> removeConnection(String id) async {
    final connections = state.connections.where((c) => c.id != id).toList();
    state = state.copyWith(connections: connections);
  }

  Future<void> togglePipeline(String id, bool active) async {
    // TODO: Toggle pipeline on backend
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider
final visionProvider =
    StateNotifierProvider<VisionNotifier, VisionState>((ref) {
  return VisionNotifier();
});

/// Provider for online connections
final onlineConnectionsProvider = Provider<List<EdgeConnection>>((ref) {
  return ref
      .watch(visionProvider)
      .connections
      .where((c) => c.status == ConnectionStatus.online)
      .toList();
});

/// Provider for active pipelines
final activePipelinesProvider = Provider<List<VisionPipeline>>((ref) {
  return ref.watch(visionProvider).pipelines.where((p) => p.isActive).toList();
});

/// Provider for recent results
final recentInferenceResultsProvider = Provider<List<InferenceResult>>((ref) {
  return ref.watch(visionProvider).recentResults;
});
