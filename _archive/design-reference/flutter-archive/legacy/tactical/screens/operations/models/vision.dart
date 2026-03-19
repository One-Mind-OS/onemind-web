// Vision models for Edge AI and Vision Pipeline
// Supports remote edge connections, inference monitoring

import 'package:flutter/material.dart';
import '../../../../shared/theme/tactical.dart';

/// Connection status
enum ConnectionStatus {
  online,
  offline,
  connecting,
  error,
}

/// Edge connection model
class EdgeConnection {
  final String id;
  final String name;
  final String host;
  final int port;
  final ConnectionStatus status;
  final DateTime? lastSeen;
  final String? version;
  final Map<String, double>? resources; // cpu, memory, gpu
  final List<HeartbeatEntry> heartbeats;

  const EdgeConnection({
    required this.id,
    required this.name,
    required this.host,
    this.port = 8000,
    this.status = ConnectionStatus.offline,
    this.lastSeen,
    this.version,
    this.resources,
    this.heartbeats = const [],
  });

  Color get statusColor {
    switch (status) {
      case ConnectionStatus.online:
        return TacticalColors.operational;
      case ConnectionStatus.offline:
        return TacticalColors.critical;
      case ConnectionStatus.connecting:
        return TacticalColors.inProgress;
      case ConnectionStatus.error:
        return TacticalColors.critical;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ConnectionStatus.online:
        return Icons.check_circle;
      case ConnectionStatus.offline:
        return Icons.cancel;
      case ConnectionStatus.connecting:
        return Icons.sync;
      case ConnectionStatus.error:
        return Icons.error;
    }
  }

  String get relativeLastSeen {
    if (lastSeen == null) return 'Never';
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory EdgeConnection.fromJson(Map<String, dynamic> json) {
    return EdgeConnection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      host: json['host'] as String? ?? '',
      port: json['port'] as int? ?? 8000,
      status: ConnectionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ConnectionStatus.offline,
      ),
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      version: json['version'] as String?,
      resources: json['resources'] != null
          ? Map<String, double>.from(json['resources'] as Map)
          : null,
    );
  }
}

/// Heartbeat entry for connection timeline
class HeartbeatEntry {
  final DateTime timestamp;
  final bool success;
  final int? latencyMs;
  final String? error;

  const HeartbeatEntry({
    required this.timestamp,
    required this.success,
    this.latencyMs,
    this.error,
  });

  Color get color => success ? TacticalColors.operational : TacticalColors.critical;
}

/// Vision pipeline model
class VisionPipeline {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final List<PipelineStage> stages;
  final Map<String, dynamic>? config;
  final PipelineStats? stats;

  const VisionPipeline({
    required this.id,
    required this.name,
    this.description,
    this.isActive = false,
    this.stages = const [],
    this.config,
    this.stats,
  });
}

/// Pipeline stage
class PipelineStage {
  final String id;
  final String name;
  final String type; // input, process, output
  final bool isActive;
  final Map<String, dynamic>? config;

  const PipelineStage({
    required this.id,
    required this.name,
    required this.type,
    this.isActive = false,
    this.config,
  });

  Color get typeColor {
    switch (type) {
      case 'input':
        return TacticalColors.complete;
      case 'process':
        return TacticalColors.primary;
      case 'output':
        return TacticalColors.operational;
      default:
        return TacticalColors.textMuted;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'input':
        return Icons.input;
      case 'process':
        return Icons.memory;
      case 'output':
        return Icons.output;
      default:
        return Icons.extension;
    }
  }
}

/// Pipeline statistics
class PipelineStats {
  final int framesProcessed;
  final double avgLatencyMs;
  final double fps;
  final int detectionsToday;
  final DateTime? lastRun;

  const PipelineStats({
    this.framesProcessed = 0,
    this.avgLatencyMs = 0,
    this.fps = 0,
    this.detectionsToday = 0,
    this.lastRun,
  });

  factory PipelineStats.fromJson(Map<String, dynamic> json) {
    return PipelineStats(
      framesProcessed: json['frames_processed'] as int? ?? 0,
      avgLatencyMs: (json['avg_latency_ms'] as num?)?.toDouble() ?? 0,
      fps: (json['fps'] as num?)?.toDouble() ?? 0,
      detectionsToday: json['detections_today'] as int? ?? 0,
      lastRun: json['last_run'] != null
          ? DateTime.parse(json['last_run'] as String)
          : null,
    );
  }
}

/// Inference result
class InferenceResult {
  final String id;
  final String pipelineId;
  final String label;
  final double confidence;
  final Map<String, dynamic>? boundingBox;
  final DateTime timestamp;
  final String? imageUrl;

  const InferenceResult({
    required this.id,
    required this.pipelineId,
    required this.label,
    required this.confidence,
    this.boundingBox,
    required this.timestamp,
    this.imageUrl,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';
}
