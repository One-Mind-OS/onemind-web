import 'package:flutter/material.dart';

enum EntityType {
  human,
  agent,
  robot,
  drone,
  structure,
  sensor,
  machine, // Added machine
  unknown
}

enum EntityStatus {
  active,
  idle,
  offline,
  maintenance,
  combat
}

class UnifiedEntity {
  final String id;
  final String name;
  final EntityType type;
  final EntityStatus status;
  final int level;
  final double health;
  final double maxHealth;
  final double battery;
  final int tasksCompleted;
  final int tasksFailed; // Added
  final String? location;
  final List<String> capabilities;
  final String? currentTask;
  final String description;
  final Map<String, double> stats; // Added
  final int xp; // Added
  final String role; // Added
  final List<String> skills; // Added
  final List<String> activeTools; // Added
  final List<String> protocols; // Added
  final double uptime; // Changed to double (percent)

  const UnifiedEntity({
    required this.id,
    required this.name,
    required this.type,
    this.status = EntityStatus.active,
    this.level = 1,
    this.health = 100.0,
    this.maxHealth = 100.0,
    this.battery = 100.0,
    this.tasksCompleted = 0,
    this.tasksFailed = 0,
    this.location,
    this.capabilities = const [],
    this.currentTask,
    this.description = '',
    this.stats = const {},
    this.xp = 0,
    this.role = 'Unit',
    this.skills = const [],
    this.activeTools = const [],
    this.protocols = const [],
    this.uptime = 0.0,
  });

  // Helper getters for UI consistency
  Color get typeColor => color;
  String get typeLabel => type.name.toUpperCase();
  
  Color get statusColor {
    switch (status) {
      case EntityStatus.active: return Colors.green;
      case EntityStatus.idle: return Colors.amber;
      case EntityStatus.offline: return Colors.grey;
      case EntityStatus.maintenance: return Colors.orange;
      case EntityStatus.combat: return Colors.red;
    }
  }

  Color get color {
    switch (type) {
      case EntityType.human:
        return Colors.blue;
      case EntityType.agent:
        return Colors.purple;
      case EntityType.robot:
      case EntityType.machine: // Handle machine
        return Colors.orange;
      case EntityType.drone:
        return Colors.cyan;
      case EntityType.structure:
        return Colors.grey;
      case EntityType.sensor:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  IconData get icon {
    switch (type) {
      case EntityType.human:
        return Icons.person;
      case EntityType.agent:
        return Icons.support_agent;
      case EntityType.robot:
      case EntityType.machine: // Handle machine
        return Icons.smart_toy;
      case EntityType.drone:
        return Icons.flight;
      case EntityType.structure:
        return Icons.domain;
      case EntityType.sensor:
        return Icons.sensors;
      default:
        return Icons.help_outline;
    }
  }

  String get emoji {
    switch (type) {
      case EntityType.human: return '👤';
      case EntityType.agent: return '🤖';
      case EntityType.robot:
      case EntityType.machine: return '⚙️';
      case EntityType.drone: return '🚁';
      case EntityType.structure: return '🏢';
      case EntityType.sensor: return '📡';
      default: return '❓';
    }
  }
}
