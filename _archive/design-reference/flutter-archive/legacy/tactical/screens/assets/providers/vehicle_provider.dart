// Vehicle provider for Fleet Management
// Connects to Tesla, Ford, OBD-II APIs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';

/// Vehicle state
class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final bool isLoading;
  final String? error;
  final VehicleType? filterType;

  const VehicleState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.isLoading = false,
    this.error,
    this.filterType,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    bool? isLoading,
    String? error,
    VehicleType? filterType,
    bool clearFilter = false,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
    );
  }

  /// Filtered vehicles
  List<Vehicle> get filteredVehicles {
    if (filterType == null) return vehicles;
    return vehicles.where((v) => v.type == filterType).toList();
  }

  /// Online vehicles count
  int get onlineCount =>
      vehicles.where((v) => v.status != VehicleStatus.offline).length;

  /// Charging vehicles count
  int get chargingCount =>
      vehicles.where((v) => v.status == VehicleStatus.charging).length;

  /// Driving vehicles count
  int get drivingCount =>
      vehicles.where((v) => v.status == VehicleStatus.driving).length;

  /// Vehicles by type
  Map<VehicleType, int> get vehiclesByType {
    final map = <VehicleType, int>{};
    for (final vehicle in vehicles) {
      map[vehicle.type] = (map[vehicle.type] ?? 0) + 1;
    }
    return map;
  }
}

/// Vehicle notifier - placeholder for API integration
class VehicleNotifier extends StateNotifier<VehicleState> {
  VehicleNotifier() : super(const VehicleState()) {
    _init();
  }

  void _init() {
    // Initialize with empty state - ready for vehicle API connections
    state = const VehicleState(
      vehicles: [],
      isLoading: false,
    );
  }

  /// Refresh all vehicles
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    // TODO: Connect to Tesla, Ford, OBD-II APIs
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      isLoading: false,
      error: null,
    );
  }

  /// Select a vehicle
  void selectVehicle(Vehicle vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  /// Filter by type
  void setFilter(VehicleType? type) {
    if (type == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterType: type);
    }
  }

  /// Lock vehicle
  Future<void> lockVehicle(String vehicleId) async {
    // TODO: Call vehicle API to lock
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Unlock vehicle
  Future<void> unlockVehicle(String vehicleId) async {
    // TODO: Call vehicle API to unlock
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Start climate
  Future<void> startClimate(String vehicleId) async {
    // TODO: Call vehicle API to start climate
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Honk horn
  Future<void> honkHorn(String vehicleId) async {
    // TODO: Call vehicle API to honk
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for vehicle state
final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier();
});

/// Provider for selected vehicle
final selectedVehicleProvider = Provider<Vehicle?>((ref) {
  return ref.watch(vehicleProvider).selectedVehicle;
});

/// Provider for online vehicles
final onlineVehiclesProvider = Provider<List<Vehicle>>((ref) {
  return ref
      .watch(vehicleProvider)
      .vehicles
      .where((v) => v.status != VehicleStatus.offline)
      .toList();
});

/// Provider for vehicles by type
final vehiclesByTypeProvider = Provider<Map<VehicleType, int>>((ref) {
  return ref.watch(vehicleProvider).vehiclesByType;
});
