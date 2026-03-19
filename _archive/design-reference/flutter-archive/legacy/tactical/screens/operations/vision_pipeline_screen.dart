import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import 'models/vision.dart';
import 'providers/vision_provider.dart';

/// Vision Pipeline Screen - AI Inference Pipeline Management
/// Manages and monitors vision processing pipelines.
class VisionPipelineScreen extends ConsumerStatefulWidget {
  const VisionPipelineScreen({super.key});

  @override
  ConsumerState<VisionPipelineScreen> createState() => _VisionPipelineScreenState();
}

class _VisionPipelineScreenState extends ConsumerState<VisionPipelineScreen> {
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
        title: const Text('VISION PIPELINE', style: TacticalText.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: TacticalColors.textMuted),
            onPressed: () => ref.read(visionProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: TacticalColors.primary),
            onPressed: () => _showCreatePipelineDialog(context),
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

                // Pipelines list or empty state
                Expanded(
                  child: state.pipelines.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.pipelines.length,
                          itemBuilder: (context, index) {
                            return _buildPipelineCard(state.pipelines[index]);
                          },
                        ),
                ),

                // Recent detections
                if (state.recentResults.isNotEmpty) ...[
                  _buildRecentDetections(state.recentResults),
                ],
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
            'PIPELINES',
            state.pipelines.length.toString(),
            TacticalColors.textMuted,
          ),
          _buildStatItem(
            'ACTIVE',
            state.activePipelineCount.toString(),
            TacticalColors.operational,
          ),
          _buildStatItem(
            'EDGES',
            state.onlineCount.toString(),
            TacticalColors.complete,
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
            Icons.account_tree_outlined,
            size: 64,
            color: TacticalColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO PIPELINES',
            style: TextStyle(
              color: TacticalColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create vision processing pipelines',
            style: TextStyle(
              color: TacticalColors.textMuted.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          TacticalButton(
            label: 'CREATE PIPELINE',
            icon: Icons.add,
            onTap: () => _showCreatePipelineDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(VisionPipeline pipeline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TacticalDecoration.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPipelineDetails(context, pipeline),
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
                        color: (pipeline.isActive
                                ? TacticalColors.operational
                                : TacticalColors.textMuted)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_tree,
                        color: pipeline.isActive
                            ? TacticalColors.operational
                            : TacticalColors.textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pipeline.name,
                            style: const TextStyle(
                              color: TacticalColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (pipeline.description != null)
                            Text(
                              pipeline.description!,
                              style: const TextStyle(
                                color: TacticalColors.textMuted,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: pipeline.isActive,
                      onChanged: (value) {
                        ref
                            .read(visionProvider.notifier)
                            .togglePipeline(pipeline.id, value);
                      },
                      activeColor: TacticalColors.operational,
                      inactiveTrackColor: TacticalColors.border,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pipeline stages visualization
                if (pipeline.stages.isNotEmpty) ...[
                  _buildPipelineStages(pipeline.stages),
                  const SizedBox(height: 16),
                ],

                // Stats row
                if (pipeline.stats != null) ...[
                  Row(
                    children: [
                      _buildPipelineStat(
                        'FPS',
                        pipeline.stats!.fps.toStringAsFixed(1),
                      ),
                      const SizedBox(width: 24),
                      _buildPipelineStat(
                        'LATENCY',
                        '${pipeline.stats!.avgLatencyMs.toInt()}ms',
                      ),
                      const SizedBox(width: 24),
                      _buildPipelineStat(
                        'TODAY',
                        pipeline.stats!.detectionsToday.toString(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStages(List<PipelineStage> stages) {
    return Row(
      children: stages.map((stage) {
        final index = stages.indexOf(stage);
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: stage.typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: stage.isActive
                          ? stage.typeColor
                          : TacticalColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        stage.typeIcon,
                        color: stage.typeColor,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.name,
                        style: TextStyle(
                          color: stage.typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (index < stages.length - 1) ...[
                Icon(
                  Icons.arrow_forward,
                  color: TacticalColors.textDim,
                  size: 16,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPipelineStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          value,
          style: const TextStyle(
            color: TacticalColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDetections(List<InferenceResult> results) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT DETECTIONS',
            style: TextStyle(
              color: TacticalColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: TacticalDecoration.card,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.center_focus_strong,
                        color: TacticalColors.primary,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.label,
                        style: const TextStyle(
                          color: TacticalColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        result.confidencePercent,
                        style: const TextStyle(
                          color: TacticalColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePipelineDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TacticalColors.surface,
        title: const Text(
          'CREATE PIPELINE',
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
            _buildTextField(nameController, 'Name', 'e.g., Person Detection'),
            const SizedBox(height: 12),
            _buildTextField(descController, 'Description', 'Optional'),
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
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // TODO: Create pipeline
              }
            },
            child: const Text(
              'CREATE',
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

  void _showPipelineDetails(BuildContext context, VisionPipeline pipeline) {
    ref.read(visionProvider.notifier).selectPipeline(pipeline);
    // TODO: Navigate to pipeline detail/editor screen
  }
}
