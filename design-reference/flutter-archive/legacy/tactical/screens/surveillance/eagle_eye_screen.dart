import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/tactical.dart';
import '../../../shared/widgets/tactical/tactical_widgets.dart';
import 'providers/camera_provider.dart';
import 'models/camera.dart';

/// Eagle Eye - Tactical Surveillance Operations
/// Central command view showing all camera feeds, detection events, and status
/// Integrates with Frigate NVR backend
class EagleEyeScreen extends ConsumerStatefulWidget {
  const EagleEyeScreen({super.key});

  @override
  ConsumerState<EagleEyeScreen> createState() => _EagleEyeScreenState();
}

class _EagleEyeScreenState extends ConsumerState<EagleEyeScreen> {
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text('EAGLE EYE', style: TacticalText.screenTitle),
        actions: [
          IconButton(
            icon: cameraState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(TacticalColors.primary),
                    ),
                  )
                : const Icon(Icons.refresh, color: TacticalColors.primary),
            onPressed: cameraState.isLoading
                ? null
                : () => ref.read(cameraProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, color: TacticalColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: TacticalColors.primary),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          _buildStatusBar(cameraState),

          // Main content
          Expanded(
            child: cameraState.cameras.isEmpty
                ? _buildEmptyState()
                : isMobile
                    ? _buildMobileLayout(cameraState)
                    : _buildDesktopLayout(cameraState),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(CameraState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        border: Border(
          bottom: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildStatusChip('ONLINE', state.onlineCount, TacticalColors.operational),
          const SizedBox(width: 8),
          _buildStatusChip('OFFLINE', state.offlineCount, TacticalColors.inProgress),
          const SizedBox(width: 8),
          _buildStatusChip('EVENTS', state.events.length, TacticalColors.primary),
          const Spacer(),
          // Recording indicator
          _buildRecordingIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: TacticalDecoration.statusBadge(color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: TacticalDecoration.statusBadge(TacticalColors.critical),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: TacticalDecoration.statusDot(TacticalColors.critical),
          ),
          const SizedBox(width: 6),
          Text('REC', style: TacticalText.statusLabel(TacticalColors.critical)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: TacticalColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.videocam_off,
                size: 64,
                color: TacticalColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO CAMERAS CONNECTED',
              style: TacticalText.screenTitle,
            ),
            const SizedBox(height: 12),
            const Text(
              'Connect to Frigate NVR to view camera feeds\nand detection events in real-time',
              style: TextStyle(
                color: TacticalColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TacticalOutlineButton(
              label: 'CONFIGURE FRIGATE',
              icon: Icons.settings,
              onTap: () => _showSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(CameraState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary view
          _buildPrimaryView(state, compact: true),
          const SizedBox(height: 16),

          // Camera grid
          const TacticalSectionHeader(title: 'ALL CAMERAS'),
          const SizedBox(height: 12),
          _buildCameraGrid(state, crossAxisCount: 2),

          const SizedBox(height: 24),

          // Recent events
          const TacticalSectionHeader(title: 'DETECTION EVENTS'),
          const SizedBox(height: 12),
          _buildEventsList(state),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(CameraState state) {
    return Row(
      children: [
        // Feed selector sidebar
        _buildFeedSelector(state),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Primary view
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildPrimaryView(state),
                ),
              ),

              // Secondary feeds
              SizedBox(
                height: 140,
                child: _buildSecondaryFeeds(state),
              ),
            ],
          ),
        ),

        // Activity panel
        _buildActivityPanel(state),
      ],
    );
  }

  Widget _buildFeedSelector(CameraState state) {
    final cameras = state.cameras;
    final selectedCamera = state.selectedCamera;

    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(
          right: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: ListView(
        children: [
          // All cameras option
          _buildFeedSelectorItem(
            icon: Icons.grid_view,
            label: 'ALL',
            isSelected: selectedCamera == null,
            onTap: () {},
          ),
          // Individual cameras
          ...cameras.map((camera) => _buildFeedSelectorItem(
                icon: camera.isOnline ? Icons.videocam : Icons.videocam_off,
                label: camera.name.substring(0, camera.name.length > 8 ? 8 : camera.name.length).toUpperCase(),
                isSelected: camera.id == selectedCamera?.id,
                isOnline: camera.isOnline,
                onTap: () => ref.read(cameraProvider.notifier).selectCamera(camera),
              )),
        ],
      ),
    );
  }

  Widget _buildFeedSelectorItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    bool isOnline = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? TacticalColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? TacticalColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? TacticalColors.primary
                  : isOnline
                      ? TacticalColors.textMuted
                      : TacticalColors.inProgress,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? TacticalColors.primary : TacticalColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryView(CameraState state, {bool compact = false}) {
    final selectedCamera = state.selectedCamera;

    return Container(
      decoration: TacticalDecoration.card,
      child: Stack(
        children: [
          // Placeholder when no feed
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(compact ? 16 : 24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TacticalColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.videocam_off,
                    size: compact ? 36 : 48,
                    color: TacticalColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: compact ? 12 : 16),
                Text(
                  selectedCamera?.name ?? 'NO FEED SELECTED',
                  style: TacticalText.cardTitle,
                ),
                SizedBox(height: compact ? 4 : 8),
                Text(
                  compact ? 'Tap camera to select feed' : 'Select a feed from the sidebar to view',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Overlay controls
          Positioned(
            top: compact ? 8 : 12,
            left: compact ? 8 : 12,
            child: _buildFeedLabel(selectedCamera?.name ?? 'NO CAMERA'),
          ),

          Positioned(
            top: compact ? 8 : 12,
            right: compact ? 8 : 12,
            child: Row(
              children: [
                _buildControlButton(Icons.mic, 'Audio'),
                SizedBox(width: compact ? 4 : 8),
                _buildControlButton(Icons.zoom_in, 'Zoom'),
                if (!compact) ...[
                  const SizedBox(width: 8),
                  _buildControlButton(Icons.screenshot, 'Screenshot'),
                ],
              ],
            ),
          ),

          // Status badge
          if (selectedCamera != null)
            Positioned(
              bottom: compact ? 8 : 12,
              left: compact ? 8 : 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: TacticalDecoration.statusBadge(
                  selectedCamera.isOnline
                      ? TacticalColors.operational
                      : TacticalColors.inProgress,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selectedCamera.isOnline
                            ? TacticalColors.operational
                            : TacticalColors.inProgress,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedCamera.status.toUpperCase(),
                      style: TextStyle(
                        color: selectedCamera.isOnline
                            ? TacticalColors.operational
                            : TacticalColors.inProgress,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: TacticalColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: TacticalDecoration.statusDot(TacticalColors.operational),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TacticalText.statusLabel(TacticalColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TacticalColors.border),
        ),
        child: Icon(icon, size: 16, color: TacticalColors.textSecondary),
      ),
    );
  }

  Widget _buildSecondaryFeeds(CameraState state) {
    if (state.cameras.isEmpty) {
      return Center(
        child: Text(
          'No cameras available',
          style: TacticalText.cardSubtitle,
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: state.cameras.length,
      itemBuilder: (context, index) {
        final camera = state.cameras[index];
        final isSelected = camera.id == state.selectedCamera?.id;

        return _buildCameraThumbnail(camera, isSelected);
      },
    );
  }

  Widget _buildCameraThumbnail(Camera camera, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(cameraProvider.notifier).selectCamera(camera),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: TacticalColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TacticalColors.primary.withValues(alpha: 0.5)
                : camera.isOnline
                    ? TacticalColors.border
                    : TacticalColors.inProgress.withValues(alpha: 0.3),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                camera.isOnline ? Icons.videocam : Icons.videocam_off,
                size: 32,
                color: camera.isOnline ? TacticalColors.textDim : TacticalColors.inProgress,
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _buildFeedLabel(camera.name),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: camera.isOnline ? TacticalColors.operational : TacticalColors.inProgress,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: camera.isOnline
                          ? TacticalColors.operational.withValues(alpha: 0.5)
                          : TacticalColors.inProgress.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraGrid(CameraState state, {int crossAxisCount = 3}) {
    if (state.cameras.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: const Center(
          child: Text(
            'No cameras connected',
            style: TextStyle(color: TacticalColors.textMuted),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: state.cameras.length,
      itemBuilder: (context, index) {
        final camera = state.cameras[index];
        final isSelected = camera.id == state.selectedCamera?.id;

        return _buildCameraThumbnail(camera, isSelected);
      },
    );
  }

  Widget _buildActivityPanel(CameraState state) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: TacticalColors.surface,
        border: Border(
          left: BorderSide(color: TacticalColors.border),
        ),
      ),
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TacticalColors.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: TacticalColors.primary,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text('DETECTION EVENTS', style: TacticalText.sectionHeader),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: state.events.isEmpty
                ? _buildEmptyEventsState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(state.events[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: TacticalColors.textDim,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent events',
            style: TacticalText.cardSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(CameraState state) {
    if (state.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: TacticalDecoration.card,
        child: Column(
          children: [
            Icon(
              Icons.notifications_none,
              size: 48,
              color: TacticalColors.textDim,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Detection Events',
              style: TacticalText.cardTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Events will appear here when detected',
              style: TextStyle(color: TacticalColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: state.events.take(5).map((e) => _buildEventCard(e)).toList(),
    );
  }

  Widget _buildEventCard(DetectionEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TacticalColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.labelColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event.labelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(event.labelIcon, size: 16, color: event.labelColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.label.toUpperCase(),
                      style: const TextStyle(
                        color: TacticalColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: event.labelColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.confidencePercent,
                        style: TextStyle(
                          color: event.labelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.camera} ${event.zones.isNotEmpty ? '• ${event.zones.first}' : ''}',
                  style: const TextStyle(
                    color: TacticalColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            event.relativeDuration,
            style: const TextStyle(
              color: TacticalColors.textDim,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TacticalColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EAGLE EYE SETTINGS', style: TacticalText.screenTitle),
            const SizedBox(height: 24),
            const Text(
              'Configure Frigate NVR connection to enable camera feeds and detection events.',
              style: TextStyle(color: TacticalColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: TacticalDecoration.card,
              child: Row(
                children: [
                  const Icon(Icons.dns, color: TacticalColors.textMuted),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Frigate NVR', style: TacticalText.cardTitle),
                        Text('Not configured', style: TextStyle(color: TacticalColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: TacticalDecoration.statusDot(TacticalColors.nonOperational),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TacticalOutlineButton(
              label: 'CLOSE',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
