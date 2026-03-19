// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_assistant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HAConnectionStatus _$HAConnectionStatusFromJson(Map<String, dynamic> json) =>
    _HAConnectionStatus(
      connected: json['connected'] as bool? ?? false,
      haVersion: json['ha_version'] as String?,
      locationName: json['location_name'] as String?,
      lastSync: json['last_sync'] == null
          ? null
          : DateTime.parse(json['last_sync'] as String),
      lastError: json['last_error'] as String?,
    );

Map<String, dynamic> _$HAConnectionStatusToJson(_HAConnectionStatus instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'ha_version': instance.haVersion,
      'location_name': instance.locationName,
      'last_sync': instance.lastSync?.toIso8601String(),
      'last_error': instance.lastError,
    };

_HAHomeSummary _$HAHomeSummaryFromJson(Map<String, dynamic> json) =>
    _HAHomeSummary(
      locationName: json['location_name'] as String? ?? 'Home',
      lightsOn: (json['lights_on'] as num?)?.toInt() ?? 0,
      lightsTotal: (json['lights_total'] as num?)?.toInt() ?? 0,
      locksLocked: (json['locks_locked'] as num?)?.toInt() ?? 0,
      locksTotal: (json['locks_total'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble(),
      temperatureUnit: json['temperature_unit'] as String?,
      humidity: (json['humidity'] as num?)?.toDouble(),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activeScenes: (json['active_scenes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      personsHome: (json['persons_home'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HAHomeSummaryToJson(_HAHomeSummary instance) =>
    <String, dynamic>{
      'location_name': instance.locationName,
      'lights_on': instance.lightsOn,
      'lights_total': instance.lightsTotal,
      'locks_locked': instance.locksLocked,
      'locks_total': instance.locksTotal,
      'temperature': instance.temperature,
      'temperature_unit': instance.temperatureUnit,
      'humidity': instance.humidity,
      'alerts': instance.alerts,
      'active_scenes': instance.activeScenes,
      'persons_home': instance.personsHome,
    };

_HAEntityState _$HAEntityStateFromJson(Map<String, dynamic> json) =>
    _HAEntityState(
      entityId: json['entity_id'] as String,
      state: json['state'] as String,
      attributes: json['attributes'] as Map<String, dynamic>? ?? const {},
      lastChanged: json['last_changed'] == null
          ? null
          : DateTime.parse(json['last_changed'] as String),
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$HAEntityStateToJson(_HAEntityState instance) =>
    <String, dynamic>{
      'entity_id': instance.entityId,
      'state': instance.state,
      'attributes': instance.attributes,
      'last_changed': instance.lastChanged?.toIso8601String(),
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };

_HAEntity _$HAEntityFromJson(Map<String, dynamic> json) => _HAEntity(
      entityId: json['entity_id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      areaId: json['area_id'] as String?,
      deviceId: json['device_id'] as String?,
      state: json['state'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>? ?? const {},
      isOn: json['is_on'] as bool? ?? false,
      deviceClass: json['device_class'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$HAEntityToJson(_HAEntity instance) => <String, dynamic>{
      'entity_id': instance.entityId,
      'name': instance.name,
      'domain': instance.domain,
      'area_id': instance.areaId,
      'device_id': instance.deviceId,
      'state': instance.state,
      'attributes': instance.attributes,
      'is_on': instance.isOn,
      'device_class': instance.deviceClass,
      'icon': instance.icon,
    };

_HAArea _$HAAreaFromJson(Map<String, dynamic> json) => _HAArea(
      areaId: json['area_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      floorId: json['floor_id'] as String?,
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HAAreaToJson(_HAArea instance) => <String, dynamic>{
      'area_id': instance.areaId,
      'name': instance.name,
      'icon': instance.icon,
      'floor_id': instance.floorId,
      'aliases': instance.aliases,
    };

_HAScene _$HASceneFromJson(Map<String, dynamic> json) => _HAScene(
      entityId: json['entity_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$HASceneToJson(_HAScene instance) => <String, dynamic>{
      'entity_id': instance.entityId,
      'name': instance.name,
      'icon': instance.icon,
    };

_HADevice _$HADeviceFromJson(Map<String, dynamic> json) => _HADevice(
      id: json['id'] as String,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      swVersion: json['sw_version'] as String?,
      areaId: json['area_id'] as String?,
      isDisabled: json['is_disabled'] as bool? ?? false,
    );

Map<String, dynamic> _$HADeviceToJson(_HADevice instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'sw_version': instance.swVersion,
      'area_id': instance.areaId,
      'is_disabled': instance.isDisabled,
    };

_HAAlert _$HAAlertFromJson(Map<String, dynamic> json) => _HAAlert(
      type: json['type'] as String,
      entityId: json['entity_id'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$HAAlertToJson(_HAAlert instance) => <String, dynamic>{
      'type': instance.type,
      'entity_id': instance.entityId,
      'message': instance.message,
      'priority': instance.priority,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_HAEntityListResponse _$HAEntityListResponseFromJson(
        Map<String, dynamic> json) =>
    _HAEntityListResponse(
      entities: (json['entities'] as List<dynamic>?)
              ?.map((e) => HAEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      count: (json['count'] as num?)?.toInt() ?? 0,
      domainCounts: (json['domain_counts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$HAEntityListResponseToJson(
        _HAEntityListResponse instance) =>
    <String, dynamic>{
      'entities': instance.entities.map((e) => e.toJson()).toList(),
      'count': instance.count,
      'domain_counts': instance.domainCounts,
    };
