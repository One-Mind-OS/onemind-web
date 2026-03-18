import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import 'models/vehicle.dart';
import 'providers/vehicle_provider.dart';

/// Vehicles Screen - Fleet Management
/// Manages Tesla, Ford, and OBD-II connected vehicles.
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vehicleProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('VEHICLES', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(vehicleProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: TacticalColors.primary),
            onPressed: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TacticalColors.primary))
          : Column(
              children: [
                // Stats header
                _buildStatsHeader(state),

                // Type filter
                _buildTypeFilter(state),

                // Vehicles grid or empty state
                Expanded(
                  child: state.filteredVehicles.isEmpty
                      ? _buildEmptyState()
                      : _buildVehiclesGrid(state),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader(VehicleState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'TOTAL',
            state.vehicles.length.toString(),
            TacticalColors.primary,
          ),
          _buildStatItem(
            'ONLINE',
            state.onlineCount.toString(),
            TacticalColors.operational,
          ),
          _buildStatItem(
            'CHARGING',
            state.chargingCount.toString(),
            TacticalColors.complete,
          ),
          _buildStatItem(
            'DRIVING',
            state.drivingCount.toString(),
            TacticalColors.inProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: TacticalColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter(VehicleState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            'ALL',
            state.filterType == null,
            () => ref.read(vehicleProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: 8),
          ...VehicleType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  type.name.toUpperCase(),
                  state.filterType == type,
                  () => ref.read(vehicleProvider.notifier).setFilter(type),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? TacticalColors.primary.withValues(alpha: 0.2)
              : TacticalColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? TacticalColors.primary : TacticalColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? TacticalColors.primary : TacticalColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO VEHICLES CONNECTED',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect Tesla, Ford, or OBD-II devices',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TacticalButton(
            label: 'ADD VEHICLE',
            icon: Icons.add,
            onTap: () => _showAddVehicleDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesGrid(VehicleState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: state.filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = state.filteredVehicles[index];
        return _VehicleCard(
          vehicle: vehicle,
          onTap: () => _showVehicleDetails(context, vehicle),
          onLock: () => ref.read(vehicleProvider.notifier).lockVehicle(vehicle.id),
          onUnlock: () => ref.read(vehicleProvider.notifier).unlockVehicle(vehicle.id),
        );
      },
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: const Text(
          'ADD VEHICLE',
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildConnectionOption(
              'TESLA',
              Icons.electric_car,
              'Connect via Tesla API',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _buildConnectionOption(
              'FORD',
              Icons.directions_car,
              'Connect via FordPass',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _buildConnectionOption(
              'OBD-II',
              Icons.car_repair,
              'Connect via OBD device',
              () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: TacticalColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionOption(
    String label,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: TacticalDecoration.card,
        child: Row(
          children: [
            Icon(icon, color: TacticalColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: TacticalColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: TacticalColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleDetails(BuildContext context, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.surface,
      isScrollControlled: true,
      builder: (context) => _VehicleDetailsSheet(vehicle: vehicle),
    );
  }
}

/// Vehicle card widget
class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onLock;
  final VoidCallback onUnlock;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onLock,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: TacticalDecoration.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(vehicle.typeIcon, color: TacticalColors.primary, size: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vehicle.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(vehicle.statusIcon,
                          color: vehicle.statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.status.name.toUpperCase(),
                        style: TextStyle(
                          color: vehicle.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              vehicle.name,
              style: const TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Model/Type
            Text(
              vehicle.model ?? vehicle.typeLabel,
              style: const TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 12,
              ),
            ),

            const Spacer(),

            // Energy level
            if (vehicle.energyLevel != null) ...[
              Row(
                children: [
                  Icon(
                    vehicle.isElectric ? Icons.bolt : Icons.local_gas_station,
                    color: TacticalColors.textMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: vehicle.energyLevel! / 100,
                      backgroundColor: TacticalColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        vehicle.energyLevel! > 20
                            ? TacticalColors.operational
                            : TacticalColors.critical,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${vehicle.energyLevel!.toInt()}%',
                    style: const TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],

            // Range
            if (vehicle.range != null) ...[
              const SizedBox(height: 8),
              Text(
                '${vehicle.range!.toInt()} mi range',
                style: const TextStyle(
                  color: TacticalColors.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vehicle details bottom sheet
class _VehicleDetailsSheet extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleDetailsSheet({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TacticalColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Icon(vehicle.typeIcon, color: TacticalColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TacticalText.cardTitle,
                    ),
                    Text(
                      vehicle.model ?? vehicle.typeLabel,
                      style: TacticalText.cardSubtitle,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: vehicle.statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vehicle.status.name.toUpperCase(),
                  style: TextStyle(
                    color: vehicle.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildDetailStat(
                  'BATTERY',
                  vehicle.batteryLevel != null
                      ? '${vehicle.batteryLevel!.toInt()}%'
                      : '--',
                  Icons.battery_charging_full,
                ),
              ),
              Expanded(
                child: _buildDetailStat(
                  'RANGE',
                  vehicle.range != null ? '${vehicle.range!.toInt()} mi' : '--',
                  Icons.route,
                ),
              ),
              Expanded(
                child: _buildDetailStat(
                  'ODOMETER',
                  vehicle.odometer != null
                      ? '${vehicle.odometer!.toInt()} mi'
                      : '--',
                  Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  vehicle.isLocked ? 'UNLOCK' : 'LOCK',
                  vehicle.isLocked ? Icons.lock_open : Icons.lock,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'CLIMATE',
                  Icons.ac_unit,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'HORN',
                  Icons.volume_up,
                  () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Location
          if (vehicle.location != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: TacticalDecoration.card,
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: TacticalColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LAST LOCATION',
                          style: TextStyle(
                            color: TacticalColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          vehicle.location!,
                          style: const TextStyle(
                            color: TacticalColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    vehicle.lastSeenRelative,
                    style: const TextStyle(
                      color: TacticalColors.textDim,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: TacticalDecoration.card,
      child: Column(
        children: [
          Icon(icon, color: TacticalColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: TacticalDecoration.card,
        child: Column(
          children: [
            Icon(icon, color: TacticalColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
