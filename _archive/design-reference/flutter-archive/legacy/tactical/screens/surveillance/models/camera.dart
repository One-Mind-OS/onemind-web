// Camera models for Eagle Eye / Frigate integration
// Surveillance camera and detection event models

import 'package:flutter/material.dart';
import '../../../../shared/theme/tactical.dart';

/// Camera model from Frigate
class Camera {
  final String id;
  final String name;
  final String? url;
  final String? snapshotUrl;
  final String? streamUrl;
  final String status; // online, offline, unknown
  final String? location;
  final bool enabled;
  final bool detectEnabled;
  final bool recordEnabled;
  final bool snapshotsEnabled;
  final bool audioEnabled;

  const Camera({
    required this.id,
    required this.name,
    this.url,
    this.snapshotUrl,
    this.streamUrl,
    this.status = 'unknown',
    this.location,
    this.enabled = true,
    this.detectEnabled = true,
    this.recordEnabled = true,
    this.snapshotsEnabled = true,
    this.audioEnabled = false,
  });

  /// Status color (tactical themed)
  Color get statusColor {
    switch (status) {
      case 'online':
        return TacticalColors.operational;
      case 'offline':
        return TacticalColors.critical;
      default:
        return TacticalColors.inProgress;
    }
  }

  /// Status icon
  IconData get statusIcon {
    switch (status) {
      case 'online':
        return Icons.videocam;
      case 'offline':
        return Icons.videocam_off;
      default:
        return Icons.help_outline;
    }
  }

  /// Is camera online
  bool get isOnline => status == 'online';

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String?,
      snapshotUrl: json['snapshot_url'] as String?,
      streamUrl: json['stream_url'] as String?,
      status: json['status'] as String? ?? 'unknown',
      location: json['location'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      detectEnabled: json['detect_enabled'] as bool? ?? true,
      recordEnabled: json['record_enabled'] as bool? ?? true,
      snapshotsEnabled: json['snapshots_enabled'] as bool? ?? true,
      audioEnabled: json['audio_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'snapshot_url': snapshotUrl,
      'stream_url': streamUrl,
      'status': status,
      'location': location,
      'enabled': enabled,
      'detect_enabled': detectEnabled,
      'record_enabled': recordEnabled,
      'snapshots_enabled': snapshotsEnabled,
      'audio_enabled': audioEnabled,
    };
  }
}

/// Detection event from Frigate
class DetectionEvent {
  final String id;
  final String camera;
  final String label; // person, car, dog, cat, etc.
  final double score;
  final DateTime startTime;
  final DateTime? endTime;
  final bool hasSnapshot;
  final bool hasClip;
  final String? snapshotUrl;
  final String? clipUrl;
  final String? thumbnailUrl;
  final List<String> zones;
  final int? area;
  final double topScore;

  const DetectionEvent({
    required this.id,
    required this.camera,
    required this.label,
    this.score = 0.0,
    required this.startTime,
    this.endTime,
    this.hasSnapshot = false,
    this.hasClip = false,
    this.snapshotUrl,
    this.clipUrl,
    this.thumbnailUrl,
    this.zones = const [],
    this.area,
    this.topScore = 0.0,
  });

  /// Get label color (tactical themed)
  Color get labelColor {
    switch (label.toLowerCase()) {
      case 'person':
        return TacticalColors.critical;
      case 'car':
      case 'vehicle':
        return TacticalColors.complete;
      case 'dog':
      case 'cat':
        return TacticalColors.operational;
      case 'package':
        return TacticalColors.inProgress;
      default:
        return TacticalColors.textMuted;
    }
  }

  /// Get label icon
  IconData get labelIcon {
    switch (label.toLowerCase()) {
      case 'person':
        return Icons.person;
      case 'car':
      case 'vehicle':
        return Icons.directions_car;
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'package':
        return Icons.inventory_2;
      default:
        return Icons.help_outline;
    }
  }

  /// Duration since event started
  String get relativeDuration {
    final now = DateTime.now();
    final diff = now.difference(startTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Confidence as percentage
  String get confidencePercent => '${(score * 100).toStringAsFixed(0)}%';

  factory DetectionEvent.fromJson(Map<String, dynamic> json) {
    return DetectionEvent(
      id: json['id'] as String? ?? '',
      camera: json['camera'] as String? ?? '',
      label: json['label'] as String? ?? 'unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      hasSnapshot: json['has_snapshot'] as bool? ?? false,
      hasClip: json['has_clip'] as bool? ?? false,
      snapshotUrl: json['snapshot_url'] as String?,
      clipUrl: json['clip_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      zones: (json['zones'] as List?)?.map((e) => e.toString()).toList() ?? [],
      area: json['area'] as int?,
      topScore: (json['top_score'] as num?)?.toDouble() ?? (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'camera': camera,
      'label': label,
      'score': score,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'has_snapshot': hasSnapshot,
      'has_clip': hasClip,
      'snapshot_url': snapshotUrl,
      'clip_url': clipUrl,
      'thumbnail_url': thumbnailUrl,
      'zones': zones,
      'area': area,
      'top_score': topScore,
    };
  }
}

/// Frigate system statistics
class FrigateStats {
  final int uptime;
  final String version;
  final Map<String, dynamic> cameras;
  final Map<String, dynamic> detectors;

  const FrigateStats({
    this.uptime = 0,
    this.version = 'unknown',
    this.cameras = const {},
    this.detectors = const {},
  });

  /// Uptime as formatted string
  String get formattedUptime {
    final days = uptime ~/ 86400;
    final hours = (uptime % 86400) ~/ 3600;
    final minutes = (uptime % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  factory FrigateStats.fromJson(Map<String, dynamic> json) {
    return FrigateStats(
      uptime: json['uptime'] as int? ?? 0,
      version: json['version'] as String? ?? 'unknown',
      cameras: json['cameras'] as Map<String, dynamic>? ?? {},
      detectors: json['detectors'] as Map<String, dynamic>? ?? {},
    );
  }
}
