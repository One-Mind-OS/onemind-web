import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import 'models/vision.dart';
import 'providers/vision_provider.dart';

/// Edge AI Screen - Remote Connection Monitoring
/// Monitors edge devices running AI inference.
class EdgeAIScreen extends ConsumerStatefulWidget {
  const EdgeAIScreen({super.key});

  @override
  ConsumerState<EdgeAIScreen> createState() => _EdgeAIScreenState();
}

class _EdgeAIScreenState extends ConsumerState<EdgeAIScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(visionProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visionProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('EDGE AI', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(visionProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: TacticalColors.primary),
            onPressed: () => _showAddConnectionDialog(context),
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

                // Connections list or empty state
                Expanded(
                  child: state.connections.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.connections.length,
                          itemBuilder: (context, index) {
                            return _buildConnectionCard(state.connections[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader(VisionState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: TacticalDecoration.card,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'TOTAL',
            state.connections.length.toString(),
            TacticalColors.textMuted,
          ),
          _buildStatItem(
            'ONLINE',
            state.onlineCount.toString(),
            TacticalColors.operational,
          ),
          _buildStatItem(
            'OFFLINE',
            (state.connections.length - state.onlineCount).toString(),
            TacticalColors.critical,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO EDGE CONNECTIONS',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to edge devices running AI inference',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TacticalButton(
            label: 'ADD CONNECTION',
            icon: Icons.add,
            onTap: () => _showAddConnectionDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(EdgeConnection connection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TacticalDecoration.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showConnectionDetails(context, connection),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: connection.statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        connection.statusIcon,
                        color: connection.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connection.name,
                            style: const TextStyle(
                              color: TacticalColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${connection.host}:${connection.port}',
                            style: const TextStyle(
                              color: TacticalColors.textMuted,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: connection.statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        connection.status.name.toUpperCase(),
                        style: TextStyle(
                          color: connection.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Resources row
                if (connection.resources != null) ...[
                  Row(
                    children: [
                      _buildResourceGauge(
                        'CPU',
                        connection.resources!['cpu'] ?? 0,
                      ),
                      const SizedBox(width: 16),
                      _buildResourceGauge(
                        'MEM',
                        connection.resources!['memory'] ?? 0,
                      ),
                      const SizedBox(width: 16),
                      _buildResourceGauge(
                        'GPU',
                        connection.resources!['gpu'] ?? 0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Heartbeat timeline
                if (connection.heartbeats.isNotEmpty) ...[
                  const Text(
                    'HEARTBEAT',
                    style: TextStyle(
                      color: TacticalColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildHeartbeatTimeline(connection.heartbeats),
                ],

                // Last seen
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last seen: ${connection.relativeLastSeen}',
                      style: const TextStyle(
                        color: TacticalColors.textDim,
                        fontSize: 11,
                      ),
                    ),
                    if (connection.version != null)
                      Text(
                        'v${connection.version}',
                        style: const TextStyle(
                          color: TacticalColors.textDim,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceGauge(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: TacticalColors.textDim,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: TacticalColors.textMuted,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: TacticalColors.border,
            valueColor: AlwaysStoppedAnimation(
              value > 80
                  ? TacticalColors.critical
                  : value > 60
                      ? TacticalColors.inProgress
                      : TacticalColors.operational,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartbeatTimeline(List<HeartbeatEntry> heartbeats) {
    final recent = heartbeats.take(20).toList();
    return Row(
      children: recent.map((hb) {
        return Expanded(
          child: Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: hb.color.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddConnectionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '8000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: const Text(
          'ADD EDGE CONNECTION',
          style: TextStyle(
            color: TacticalColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, 'Name', 'e.g., Jetson-1'),
            const SizedBox(height: 12),
            _buildTextField(hostController, 'Host', 'e.g., 192.168.1.100'),
            const SizedBox(height: 12),
            _buildTextField(portController, 'Port', '8000'),
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
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  hostController.text.isNotEmpty) {
                ref.read(visionProvider.notifier).addConnection(
                      name: nameController.text,
                      host: hostController.text,
                      port: int.tryParse(portController.text) ?? 8000,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'ADD',
              style: TextStyle(color: TacticalColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: TacticalColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: TacticalColors.textMuted),
        hintText: hint,
        hintStyle: TextStyle(
          color: TacticalColors.textMuted.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: TacticalColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: TacticalColors.primary),
        ),
      ),
    );
  }

  void _showConnectionDetails(BuildContext context, EdgeConnection connection) {
    ref.read(visionProvider.notifier).selectConnection(connection);
    // TODO: Navigate to connection detail screen
  }
}
