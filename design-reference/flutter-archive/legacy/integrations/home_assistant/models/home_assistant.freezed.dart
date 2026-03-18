// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_assistant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HAConnectionStatus {
  bool get connected;
  String? get haVersion;
  String? get locationName;
  DateTime? get lastSync;
  String? get lastError;

  /// Create a copy of HAConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAConnectionStatusCopyWith<HAConnectionStatus> get copyWith =>
      _$HAConnectionStatusCopyWithImpl<HAConnectionStatus>(
          this as HAConnectionStatus, _$identity);

  /// Serializes this HAConnectionStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAConnectionStatus &&
            (identical(other.connected, connected) ||
                other.connected == connected) &&
            (identical(other.haVersion, haVersion) ||
                other.haVersion == haVersion) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.lastSync, lastSync) ||
                other.lastSync == lastSync) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, connected, haVersion, locationName, lastSync, lastError);

  @override
  String toString() {
    return 'HAConnectionStatus(connected: $connected, haVersion: $haVersion, locationName: $locationName, lastSync: $lastSync, lastError: $lastError)';
  }
}

/// @nodoc
abstract mixin class $HAConnectionStatusCopyWith<$Res> {
  factory $HAConnectionStatusCopyWith(
          HAConnectionStatus value, $Res Function(HAConnectionStatus) _then) =
      _$HAConnectionStatusCopyWithImpl;
  @useResult
  $Res call(
      {bool connected,
      String? haVersion,
      String? locationName,
      DateTime? lastSync,
      String? lastError});
}

/// @nodoc
class _$HAConnectionStatusCopyWithImpl<$Res>
    implements $HAConnectionStatusCopyWith<$Res> {
  _$HAConnectionStatusCopyWithImpl(this._self, this._then);

  final HAConnectionStatus _self;
  final $Res Function(HAConnectionStatus) _then;

  /// Create a copy of HAConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connected = null,
    Object? haVersion = freezed,
    Object? locationName = freezed,
    Object? lastSync = freezed,
    Object? lastError = freezed,
  }) {
    return _then(_self.copyWith(
      connected: null == connected
          ? _self.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      haVersion: freezed == haVersion
          ? _self.haVersion
          : haVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSync: freezed == lastSync
          ? _self.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAConnectionStatus].
extension HAConnectionStatusPatterns on HAConnectionStatus {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAConnectionStatus value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAConnectionStatus value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAConnectionStatus value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(bool connected, String? haVersion, String? locationName,
            DateTime? lastSync, String? lastError)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus() when $default != null:
        return $default(_that.connected, _that.haVersion, _that.locationName,
            _that.lastSync, _that.lastError);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(bool connected, String? haVersion, String? locationName,
            DateTime? lastSync, String? lastError)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus():
        return $default(_that.connected, _that.haVersion, _that.locationName,
            _that.lastSync, _that.lastError);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(bool connected, String? haVersion, String? locationName,
            DateTime? lastSync, String? lastError)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAConnectionStatus() when $default != null:
        return $default(_that.connected, _that.haVersion, _that.locationName,
            _that.lastSync, _that.lastError);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAConnectionStatus implements HAConnectionStatus {
  const _HAConnectionStatus(
      {this.connected = false,
      this.haVersion,
      this.locationName,
      this.lastSync,
      this.lastError});
  factory _HAConnectionStatus.fromJson(Map<String, dynamic> json) =>
      _$HAConnectionStatusFromJson(json);

  @override
  @JsonKey()
  final bool connected;
  @override
  final String? haVersion;
  @override
  final String? locationName;
  @override
  final DateTime? lastSync;
  @override
  final String? lastError;

  /// Create a copy of HAConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAConnectionStatusCopyWith<_HAConnectionStatus> get copyWith =>
      __$HAConnectionStatusCopyWithImpl<_HAConnectionStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAConnectionStatusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAConnectionStatus &&
            (identical(other.connected, connected) ||
                other.connected == connected) &&
            (identical(other.haVersion, haVersion) ||
                other.haVersion == haVersion) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.lastSync, lastSync) ||
                other.lastSync == lastSync) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, connected, haVersion, locationName, lastSync, lastError);

  @override
  String toString() {
    return 'HAConnectionStatus(connected: $connected, haVersion: $haVersion, locationName: $locationName, lastSync: $lastSync, lastError: $lastError)';
  }
}

/// @nodoc
abstract mixin class _$HAConnectionStatusCopyWith<$Res>
    implements $HAConnectionStatusCopyWith<$Res> {
  factory _$HAConnectionStatusCopyWith(
          _HAConnectionStatus value, $Res Function(_HAConnectionStatus) _then) =
      __$HAConnectionStatusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool connected,
      String? haVersion,
      String? locationName,
      DateTime? lastSync,
      String? lastError});
}

/// @nodoc
class __$HAConnectionStatusCopyWithImpl<$Res>
    implements _$HAConnectionStatusCopyWith<$Res> {
  __$HAConnectionStatusCopyWithImpl(this._self, this._then);

  final _HAConnectionStatus _self;
  final $Res Function(_HAConnectionStatus) _then;

  /// Create a copy of HAConnectionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? connected = null,
    Object? haVersion = freezed,
    Object? locationName = freezed,
    Object? lastSync = freezed,
    Object? lastError = freezed,
  }) {
    return _then(_HAConnectionStatus(
      connected: null == connected
          ? _self.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      haVersion: freezed == haVersion
          ? _self.haVersion
          : haVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSync: freezed == lastSync
          ? _self.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastError: freezed == lastError
          ? _self.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$HAHomeSummary {
  String get locationName;
  int get lightsOn;
  int get lightsTotal;
  int get locksLocked;
  int get locksTotal;
  double? get temperature;
  String? get temperatureUnit;
  double? get humidity;
  List<String> get alerts;
  List<String> get activeScenes;
  int? get personsHome;

  /// Create a copy of HAHomeSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAHomeSummaryCopyWith<HAHomeSummary> get copyWith =>
      _$HAHomeSummaryCopyWithImpl<HAHomeSummary>(
          this as HAHomeSummary, _$identity);

  /// Serializes this HAHomeSummary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAHomeSummary &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.lightsOn, lightsOn) ||
                other.lightsOn == lightsOn) &&
            (identical(other.lightsTotal, lightsTotal) ||
                other.lightsTotal == lightsTotal) &&
            (identical(other.locksLocked, locksLocked) ||
                other.locksLocked == locksLocked) &&
            (identical(other.locksTotal, locksTotal) ||
                other.locksTotal == locksTotal) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.temperatureUnit, temperatureUnit) ||
                other.temperatureUnit == temperatureUnit) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            const DeepCollectionEquality().equals(other.alerts, alerts) &&
            const DeepCollectionEquality()
                .equals(other.activeScenes, activeScenes) &&
            (identical(other.personsHome, personsHome) ||
                other.personsHome == personsHome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      locationName,
      lightsOn,
      lightsTotal,
      locksLocked,
      locksTotal,
      temperature,
      temperatureUnit,
      humidity,
      const DeepCollectionEquality().hash(alerts),
      const DeepCollectionEquality().hash(activeScenes),
      personsHome);

  @override
  String toString() {
    return 'HAHomeSummary(locationName: $locationName, lightsOn: $lightsOn, lightsTotal: $lightsTotal, locksLocked: $locksLocked, locksTotal: $locksTotal, temperature: $temperature, temperatureUnit: $temperatureUnit, humidity: $humidity, alerts: $alerts, activeScenes: $activeScenes, personsHome: $personsHome)';
  }
}

/// @nodoc
abstract mixin class $HAHomeSummaryCopyWith<$Res> {
  factory $HAHomeSummaryCopyWith(
          HAHomeSummary value, $Res Function(HAHomeSummary) _then) =
      _$HAHomeSummaryCopyWithImpl;
  @useResult
  $Res call(
      {String locationName,
      int lightsOn,
      int lightsTotal,
      int locksLocked,
      int locksTotal,
      double? temperature,
      String? temperatureUnit,
      double? humidity,
      List<String> alerts,
      List<String> activeScenes,
      int? personsHome});
}

/// @nodoc
class _$HAHomeSummaryCopyWithImpl<$Res>
    implements $HAHomeSummaryCopyWith<$Res> {
  _$HAHomeSummaryCopyWithImpl(this._self, this._then);

  final HAHomeSummary _self;
  final $Res Function(HAHomeSummary) _then;

  /// Create a copy of HAHomeSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationName = null,
    Object? lightsOn = null,
    Object? lightsTotal = null,
    Object? locksLocked = null,
    Object? locksTotal = null,
    Object? temperature = freezed,
    Object? temperatureUnit = freezed,
    Object? humidity = freezed,
    Object? alerts = null,
    Object? activeScenes = null,
    Object? personsHome = freezed,
  }) {
    return _then(_self.copyWith(
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
      lightsOn: null == lightsOn
          ? _self.lightsOn
          : lightsOn // ignore: cast_nullable_to_non_nullable
              as int,
      lightsTotal: null == lightsTotal
          ? _self.lightsTotal
          : lightsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      locksLocked: null == locksLocked
          ? _self.locksLocked
          : locksLocked // ignore: cast_nullable_to_non_nullable
              as int,
      locksTotal: null == locksTotal
          ? _self.locksTotal
          : locksTotal // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: freezed == temperature
          ? _self.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      temperatureUnit: freezed == temperatureUnit
          ? _self.temperatureUnit
          : temperatureUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      humidity: freezed == humidity
          ? _self.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      alerts: null == alerts
          ? _self.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeScenes: null == activeScenes
          ? _self.activeScenes
          : activeScenes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personsHome: freezed == personsHome
          ? _self.personsHome
          : personsHome // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAHomeSummary].
extension HAHomeSummaryPatterns on HAHomeSummary {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAHomeSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAHomeSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAHomeSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String locationName,
            int lightsOn,
            int lightsTotal,
            int locksLocked,
            int locksTotal,
            double? temperature,
            String? temperatureUnit,
            double? humidity,
            List<String> alerts,
            List<String> activeScenes,
            int? personsHome)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary() when $default != null:
        return $default(
            _that.locationName,
            _that.lightsOn,
            _that.lightsTotal,
            _that.locksLocked,
            _that.locksTotal,
            _that.temperature,
            _that.temperatureUnit,
            _that.humidity,
            _that.alerts,
            _that.activeScenes,
            _that.personsHome);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String locationName,
            int lightsOn,
            int lightsTotal,
            int locksLocked,
            int locksTotal,
            double? temperature,
            String? temperatureUnit,
            double? humidity,
            List<String> alerts,
            List<String> activeScenes,
            int? personsHome)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary():
        return $default(
            _that.locationName,
            _that.lightsOn,
            _that.lightsTotal,
            _that.locksLocked,
            _that.locksTotal,
            _that.temperature,
            _that.temperatureUnit,
            _that.humidity,
            _that.alerts,
            _that.activeScenes,
            _that.personsHome);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String locationName,
            int lightsOn,
            int lightsTotal,
            int locksLocked,
            int locksTotal,
            double? temperature,
            String? temperatureUnit,
            double? humidity,
            List<String> alerts,
            List<String> activeScenes,
            int? personsHome)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAHomeSummary() when $default != null:
        return $default(
            _that.locationName,
            _that.lightsOn,
            _that.lightsTotal,
            _that.locksLocked,
            _that.locksTotal,
            _that.temperature,
            _that.temperatureUnit,
            _that.humidity,
            _that.alerts,
            _that.activeScenes,
            _that.personsHome);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAHomeSummary implements HAHomeSummary {
  const _HAHomeSummary(
      {this.locationName = 'Home',
      this.lightsOn = 0,
      this.lightsTotal = 0,
      this.locksLocked = 0,
      this.locksTotal = 0,
      this.temperature,
      this.temperatureUnit,
      this.humidity,
      final List<String> alerts = const [],
      final List<String> activeScenes = const [],
      this.personsHome})
      : _alerts = alerts,
        _activeScenes = activeScenes;
  factory _HAHomeSummary.fromJson(Map<String, dynamic> json) =>
      _$HAHomeSummaryFromJson(json);

  @override
  @JsonKey()
  final String locationName;
  @override
  @JsonKey()
  final int lightsOn;
  @override
  @JsonKey()
  final int lightsTotal;
  @override
  @JsonKey()
  final int locksLocked;
  @override
  @JsonKey()
  final int locksTotal;
  @override
  final double? temperature;
  @override
  final String? temperatureUnit;
  @override
  final double? humidity;
  final List<String> _alerts;
  @override
  @JsonKey()
  List<String> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  final List<String> _activeScenes;
  @override
  @JsonKey()
  List<String> get activeScenes {
    if (_activeScenes is EqualUnmodifiableListView) return _activeScenes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeScenes);
  }

  @override
  final int? personsHome;

  /// Create a copy of HAHomeSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAHomeSummaryCopyWith<_HAHomeSummary> get copyWith =>
      __$HAHomeSummaryCopyWithImpl<_HAHomeSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAHomeSummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAHomeSummary &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.lightsOn, lightsOn) ||
                other.lightsOn == lightsOn) &&
            (identical(other.lightsTotal, lightsTotal) ||
                other.lightsTotal == lightsTotal) &&
            (identical(other.locksLocked, locksLocked) ||
                other.locksLocked == locksLocked) &&
            (identical(other.locksTotal, locksTotal) ||
                other.locksTotal == locksTotal) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.temperatureUnit, temperatureUnit) ||
                other.temperatureUnit == temperatureUnit) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            const DeepCollectionEquality()
                .equals(other._activeScenes, _activeScenes) &&
            (identical(other.personsHome, personsHome) ||
                other.personsHome == personsHome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      locationName,
      lightsOn,
      lightsTotal,
      locksLocked,
      locksTotal,
      temperature,
      temperatureUnit,
      humidity,
      const DeepCollectionEquality().hash(_alerts),
      const DeepCollectionEquality().hash(_activeScenes),
      personsHome);

  @override
  String toString() {
    return 'HAHomeSummary(locationName: $locationName, lightsOn: $lightsOn, lightsTotal: $lightsTotal, locksLocked: $locksLocked, locksTotal: $locksTotal, temperature: $temperature, temperatureUnit: $temperatureUnit, humidity: $humidity, alerts: $alerts, activeScenes: $activeScenes, personsHome: $personsHome)';
  }
}

/// @nodoc
abstract mixin class _$HAHomeSummaryCopyWith<$Res>
    implements $HAHomeSummaryCopyWith<$Res> {
  factory _$HAHomeSummaryCopyWith(
          _HAHomeSummary value, $Res Function(_HAHomeSummary) _then) =
      __$HAHomeSummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String locationName,
      int lightsOn,
      int lightsTotal,
      int locksLocked,
      int locksTotal,
      double? temperature,
      String? temperatureUnit,
      double? humidity,
      List<String> alerts,
      List<String> activeScenes,
      int? personsHome});
}

/// @nodoc
class __$HAHomeSummaryCopyWithImpl<$Res>
    implements _$HAHomeSummaryCopyWith<$Res> {
  __$HAHomeSummaryCopyWithImpl(this._self, this._then);

  final _HAHomeSummary _self;
  final $Res Function(_HAHomeSummary) _then;

  /// Create a copy of HAHomeSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locationName = null,
    Object? lightsOn = null,
    Object? lightsTotal = null,
    Object? locksLocked = null,
    Object? locksTotal = null,
    Object? temperature = freezed,
    Object? temperatureUnit = freezed,
    Object? humidity = freezed,
    Object? alerts = null,
    Object? activeScenes = null,
    Object? personsHome = freezed,
  }) {
    return _then(_HAHomeSummary(
      locationName: null == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String,
      lightsOn: null == lightsOn
          ? _self.lightsOn
          : lightsOn // ignore: cast_nullable_to_non_nullable
              as int,
      lightsTotal: null == lightsTotal
          ? _self.lightsTotal
          : lightsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      locksLocked: null == locksLocked
          ? _self.locksLocked
          : locksLocked // ignore: cast_nullable_to_non_nullable
              as int,
      locksTotal: null == locksTotal
          ? _self.locksTotal
          : locksTotal // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: freezed == temperature
          ? _self.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      temperatureUnit: freezed == temperatureUnit
          ? _self.temperatureUnit
          : temperatureUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      humidity: freezed == humidity
          ? _self.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as double?,
      alerts: null == alerts
          ? _self._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      activeScenes: null == activeScenes
          ? _self._activeScenes
          : activeScenes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      personsHome: freezed == personsHome
          ? _self.personsHome
          : personsHome // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$HAEntityState {
  String get entityId;
  String get state;
  Map<String, dynamic> get attributes;
  DateTime? get lastChanged;
  DateTime? get lastUpdated;

  /// Create a copy of HAEntityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAEntityStateCopyWith<HAEntityState> get copyWith =>
      _$HAEntityStateCopyWithImpl<HAEntityState>(
          this as HAEntityState, _$identity);

  /// Serializes this HAEntityState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAEntityState &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality()
                .equals(other.attributes, attributes) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      entityId,
      state,
      const DeepCollectionEquality().hash(attributes),
      lastChanged,
      lastUpdated);

  @override
  String toString() {
    return 'HAEntityState(entityId: $entityId, state: $state, attributes: $attributes, lastChanged: $lastChanged, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class $HAEntityStateCopyWith<$Res> {
  factory $HAEntityStateCopyWith(
          HAEntityState value, $Res Function(HAEntityState) _then) =
      _$HAEntityStateCopyWithImpl;
  @useResult
  $Res call(
      {String entityId,
      String state,
      Map<String, dynamic> attributes,
      DateTime? lastChanged,
      DateTime? lastUpdated});
}

/// @nodoc
class _$HAEntityStateCopyWithImpl<$Res>
    implements $HAEntityStateCopyWith<$Res> {
  _$HAEntityStateCopyWithImpl(this._self, this._then);

  final HAEntityState _self;
  final $Res Function(HAEntityState) _then;

  /// Create a copy of HAEntityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? state = null,
    Object? attributes = null,
    Object? lastChanged = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_self.copyWith(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _self.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastChanged: freezed == lastChanged
          ? _self.lastChanged
          : lastChanged // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAEntityState].
extension HAEntityStatePatterns on HAEntityState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAEntityState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntityState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAEntityState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityState():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAEntityState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String entityId,
            String state,
            Map<String, dynamic> attributes,
            DateTime? lastChanged,
            DateTime? lastUpdated)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntityState() when $default != null:
        return $default(_that.entityId, _that.state, _that.attributes,
            _that.lastChanged, _that.lastUpdated);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String entityId,
            String state,
            Map<String, dynamic> attributes,
            DateTime? lastChanged,
            DateTime? lastUpdated)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityState():
        return $default(_that.entityId, _that.state, _that.attributes,
            _that.lastChanged, _that.lastUpdated);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String entityId,
            String state,
            Map<String, dynamic> attributes,
            DateTime? lastChanged,
            DateTime? lastUpdated)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityState() when $default != null:
        return $default(_that.entityId, _that.state, _that.attributes,
            _that.lastChanged, _that.lastUpdated);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAEntityState implements HAEntityState {
  const _HAEntityState(
      {required this.entityId,
      required this.state,
      final Map<String, dynamic> attributes = const {},
      this.lastChanged,
      this.lastUpdated})
      : _attributes = attributes;
  factory _HAEntityState.fromJson(Map<String, dynamic> json) =>
      _$HAEntityStateFromJson(json);

  @override
  final String entityId;
  @override
  final String state;
  final Map<String, dynamic> _attributes;
  @override
  @JsonKey()
  Map<String, dynamic> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

  @override
  final DateTime? lastChanged;
  @override
  final DateTime? lastUpdated;

  /// Create a copy of HAEntityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAEntityStateCopyWith<_HAEntityState> get copyWith =>
      __$HAEntityStateCopyWithImpl<_HAEntityState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAEntityStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAEntityState &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      entityId,
      state,
      const DeepCollectionEquality().hash(_attributes),
      lastChanged,
      lastUpdated);

  @override
  String toString() {
    return 'HAEntityState(entityId: $entityId, state: $state, attributes: $attributes, lastChanged: $lastChanged, lastUpdated: $lastUpdated)';
  }
}

/// @nodoc
abstract mixin class _$HAEntityStateCopyWith<$Res>
    implements $HAEntityStateCopyWith<$Res> {
  factory _$HAEntityStateCopyWith(
          _HAEntityState value, $Res Function(_HAEntityState) _then) =
      __$HAEntityStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String entityId,
      String state,
      Map<String, dynamic> attributes,
      DateTime? lastChanged,
      DateTime? lastUpdated});
}

/// @nodoc
class __$HAEntityStateCopyWithImpl<$Res>
    implements _$HAEntityStateCopyWith<$Res> {
  __$HAEntityStateCopyWithImpl(this._self, this._then);

  final _HAEntityState _self;
  final $Res Function(_HAEntityState) _then;

  /// Create a copy of HAEntityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entityId = null,
    Object? state = null,
    Object? attributes = null,
    Object? lastChanged = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_HAEntityState(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _self._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastChanged: freezed == lastChanged
          ? _self.lastChanged
          : lastChanged // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUpdated: freezed == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$HAEntity {
  String get entityId;
  String get name;
  String get domain;
  String? get areaId;
  String? get deviceId;
  String? get state;
  Map<String, dynamic> get attributes;
  bool get isOn;
  String? get deviceClass;
  String? get icon;

  /// Create a copy of HAEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAEntityCopyWith<HAEntity> get copyWith =>
      _$HAEntityCopyWithImpl<HAEntity>(this as HAEntity, _$identity);

  /// Serializes this HAEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAEntity &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality()
                .equals(other.attributes, attributes) &&
            (identical(other.isOn, isOn) || other.isOn == isOn) &&
            (identical(other.deviceClass, deviceClass) ||
                other.deviceClass == deviceClass) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      entityId,
      name,
      domain,
      areaId,
      deviceId,
      state,
      const DeepCollectionEquality().hash(attributes),
      isOn,
      deviceClass,
      icon);

  @override
  String toString() {
    return 'HAEntity(entityId: $entityId, name: $name, domain: $domain, areaId: $areaId, deviceId: $deviceId, state: $state, attributes: $attributes, isOn: $isOn, deviceClass: $deviceClass, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class $HAEntityCopyWith<$Res> {
  factory $HAEntityCopyWith(HAEntity value, $Res Function(HAEntity) _then) =
      _$HAEntityCopyWithImpl;
  @useResult
  $Res call(
      {String entityId,
      String name,
      String domain,
      String? areaId,
      String? deviceId,
      String? state,
      Map<String, dynamic> attributes,
      bool isOn,
      String? deviceClass,
      String? icon});
}

/// @nodoc
class _$HAEntityCopyWithImpl<$Res> implements $HAEntityCopyWith<$Res> {
  _$HAEntityCopyWithImpl(this._self, this._then);

  final HAEntity _self;
  final $Res Function(HAEntity) _then;

  /// Create a copy of HAEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? domain = null,
    Object? areaId = freezed,
    Object? deviceId = freezed,
    Object? state = freezed,
    Object? attributes = null,
    Object? isOn = null,
    Object? deviceClass = freezed,
    Object? icon = freezed,
  }) {
    return _then(_self.copyWith(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _self.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: freezed == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: null == attributes
          ? _self.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isOn: null == isOn
          ? _self.isOn
          : isOn // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceClass: freezed == deviceClass
          ? _self.deviceClass
          : deviceClass // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAEntity].
extension HAEntityPatterns on HAEntity {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntity():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String entityId,
            String name,
            String domain,
            String? areaId,
            String? deviceId,
            String? state,
            Map<String, dynamic> attributes,
            bool isOn,
            String? deviceClass,
            String? icon)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntity() when $default != null:
        return $default(
            _that.entityId,
            _that.name,
            _that.domain,
            _that.areaId,
            _that.deviceId,
            _that.state,
            _that.attributes,
            _that.isOn,
            _that.deviceClass,
            _that.icon);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String entityId,
            String name,
            String domain,
            String? areaId,
            String? deviceId,
            String? state,
            Map<String, dynamic> attributes,
            bool isOn,
            String? deviceClass,
            String? icon)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntity():
        return $default(
            _that.entityId,
            _that.name,
            _that.domain,
            _that.areaId,
            _that.deviceId,
            _that.state,
            _that.attributes,
            _that.isOn,
            _that.deviceClass,
            _that.icon);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String entityId,
            String name,
            String domain,
            String? areaId,
            String? deviceId,
            String? state,
            Map<String, dynamic> attributes,
            bool isOn,
            String? deviceClass,
            String? icon)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntity() when $default != null:
        return $default(
            _that.entityId,
            _that.name,
            _that.domain,
            _that.areaId,
            _that.deviceId,
            _that.state,
            _that.attributes,
            _that.isOn,
            _that.deviceClass,
            _that.icon);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAEntity implements HAEntity {
  const _HAEntity(
      {required this.entityId,
      required this.name,
      required this.domain,
      this.areaId,
      this.deviceId,
      this.state,
      final Map<String, dynamic> attributes = const {},
      this.isOn = false,
      this.deviceClass,
      this.icon})
      : _attributes = attributes;
  factory _HAEntity.fromJson(Map<String, dynamic> json) =>
      _$HAEntityFromJson(json);

  @override
  final String entityId;
  @override
  final String name;
  @override
  final String domain;
  @override
  final String? areaId;
  @override
  final String? deviceId;
  @override
  final String? state;
  final Map<String, dynamic> _attributes;
  @override
  @JsonKey()
  Map<String, dynamic> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

  @override
  @JsonKey()
  final bool isOn;
  @override
  final String? deviceClass;
  @override
  final String? icon;

  /// Create a copy of HAEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAEntityCopyWith<_HAEntity> get copyWith =>
      __$HAEntityCopyWithImpl<_HAEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAEntity &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.isOn, isOn) || other.isOn == isOn) &&
            (identical(other.deviceClass, deviceClass) ||
                other.deviceClass == deviceClass) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      entityId,
      name,
      domain,
      areaId,
      deviceId,
      state,
      const DeepCollectionEquality().hash(_attributes),
      isOn,
      deviceClass,
      icon);

  @override
  String toString() {
    return 'HAEntity(entityId: $entityId, name: $name, domain: $domain, areaId: $areaId, deviceId: $deviceId, state: $state, attributes: $attributes, isOn: $isOn, deviceClass: $deviceClass, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class _$HAEntityCopyWith<$Res>
    implements $HAEntityCopyWith<$Res> {
  factory _$HAEntityCopyWith(_HAEntity value, $Res Function(_HAEntity) _then) =
      __$HAEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String entityId,
      String name,
      String domain,
      String? areaId,
      String? deviceId,
      String? state,
      Map<String, dynamic> attributes,
      bool isOn,
      String? deviceClass,
      String? icon});
}

/// @nodoc
class __$HAEntityCopyWithImpl<$Res> implements _$HAEntityCopyWith<$Res> {
  __$HAEntityCopyWithImpl(this._self, this._then);

  final _HAEntity _self;
  final $Res Function(_HAEntity) _then;

  /// Create a copy of HAEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? domain = null,
    Object? areaId = freezed,
    Object? deviceId = freezed,
    Object? state = freezed,
    Object? attributes = null,
    Object? isOn = null,
    Object? deviceClass = freezed,
    Object? icon = freezed,
  }) {
    return _then(_HAEntity(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _self.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      areaId: freezed == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _self.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      attributes: null == attributes
          ? _self._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isOn: null == isOn
          ? _self.isOn
          : isOn // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceClass: freezed == deviceClass
          ? _self.deviceClass
          : deviceClass // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$HAArea {
  String get areaId;
  String get name;
  String? get icon;
  String? get floorId;
  List<String> get aliases;

  /// Create a copy of HAArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAAreaCopyWith<HAArea> get copyWith =>
      _$HAAreaCopyWithImpl<HAArea>(this as HAArea, _$identity);

  /// Serializes this HAArea to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAArea &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.floorId, floorId) || other.floorId == floorId) &&
            const DeepCollectionEquality().equals(other.aliases, aliases));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, areaId, name, icon, floorId,
      const DeepCollectionEquality().hash(aliases));

  @override
  String toString() {
    return 'HAArea(areaId: $areaId, name: $name, icon: $icon, floorId: $floorId, aliases: $aliases)';
  }
}

/// @nodoc
abstract mixin class $HAAreaCopyWith<$Res> {
  factory $HAAreaCopyWith(HAArea value, $Res Function(HAArea) _then) =
      _$HAAreaCopyWithImpl;
  @useResult
  $Res call(
      {String areaId,
      String name,
      String? icon,
      String? floorId,
      List<String> aliases});
}

/// @nodoc
class _$HAAreaCopyWithImpl<$Res> implements $HAAreaCopyWith<$Res> {
  _$HAAreaCopyWithImpl(this._self, this._then);

  final HAArea _self;
  final $Res Function(HAArea) _then;

  /// Create a copy of HAArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areaId = null,
    Object? name = null,
    Object? icon = freezed,
    Object? floorId = freezed,
    Object? aliases = null,
  }) {
    return _then(_self.copyWith(
      areaId: null == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      floorId: freezed == floorId
          ? _self.floorId
          : floorId // ignore: cast_nullable_to_non_nullable
              as String?,
      aliases: null == aliases
          ? _self.aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAArea].
extension HAAreaPatterns on HAArea {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAArea value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAArea() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAArea value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAArea():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAArea value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAArea() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String areaId, String name, String? icon, String? floorId,
            List<String> aliases)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAArea() when $default != null:
        return $default(
            _that.areaId, _that.name, _that.icon, _that.floorId, _that.aliases);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String areaId, String name, String? icon, String? floorId,
            List<String> aliases)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAArea():
        return $default(
            _that.areaId, _that.name, _that.icon, _that.floorId, _that.aliases);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String areaId, String name, String? icon, String? floorId,
            List<String> aliases)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAArea() when $default != null:
        return $default(
            _that.areaId, _that.name, _that.icon, _that.floorId, _that.aliases);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAArea implements HAArea {
  const _HAArea(
      {required this.areaId,
      required this.name,
      this.icon,
      this.floorId,
      final List<String> aliases = const []})
      : _aliases = aliases;
  factory _HAArea.fromJson(Map<String, dynamic> json) => _$HAAreaFromJson(json);

  @override
  final String areaId;
  @override
  final String name;
  @override
  final String? icon;
  @override
  final String? floorId;
  final List<String> _aliases;
  @override
  @JsonKey()
  List<String> get aliases {
    if (_aliases is EqualUnmodifiableListView) return _aliases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aliases);
  }

  /// Create a copy of HAArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAAreaCopyWith<_HAArea> get copyWith =>
      __$HAAreaCopyWithImpl<_HAArea>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAAreaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAArea &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.floorId, floorId) || other.floorId == floorId) &&
            const DeepCollectionEquality().equals(other._aliases, _aliases));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, areaId, name, icon, floorId,
      const DeepCollectionEquality().hash(_aliases));

  @override
  String toString() {
    return 'HAArea(areaId: $areaId, name: $name, icon: $icon, floorId: $floorId, aliases: $aliases)';
  }
}

/// @nodoc
abstract mixin class _$HAAreaCopyWith<$Res> implements $HAAreaCopyWith<$Res> {
  factory _$HAAreaCopyWith(_HAArea value, $Res Function(_HAArea) _then) =
      __$HAAreaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String areaId,
      String name,
      String? icon,
      String? floorId,
      List<String> aliases});
}

/// @nodoc
class __$HAAreaCopyWithImpl<$Res> implements _$HAAreaCopyWith<$Res> {
  __$HAAreaCopyWithImpl(this._self, this._then);

  final _HAArea _self;
  final $Res Function(_HAArea) _then;

  /// Create a copy of HAArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? areaId = null,
    Object? name = null,
    Object? icon = freezed,
    Object? floorId = freezed,
    Object? aliases = null,
  }) {
    return _then(_HAArea(
      areaId: null == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      floorId: freezed == floorId
          ? _self.floorId
          : floorId // ignore: cast_nullable_to_non_nullable
              as String?,
      aliases: null == aliases
          ? _self._aliases
          : aliases // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$HAScene {
  String get entityId;
  String get name;
  String? get icon;

  /// Create a copy of HAScene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HASceneCopyWith<HAScene> get copyWith =>
      _$HASceneCopyWithImpl<HAScene>(this as HAScene, _$identity);

  /// Serializes this HAScene to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAScene &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, entityId, name, icon);

  @override
  String toString() {
    return 'HAScene(entityId: $entityId, name: $name, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class $HASceneCopyWith<$Res> {
  factory $HASceneCopyWith(HAScene value, $Res Function(HAScene) _then) =
      _$HASceneCopyWithImpl;
  @useResult
  $Res call({String entityId, String name, String? icon});
}

/// @nodoc
class _$HASceneCopyWithImpl<$Res> implements $HASceneCopyWith<$Res> {
  _$HASceneCopyWithImpl(this._self, this._then);

  final HAScene _self;
  final $Res Function(HAScene) _then;

  /// Create a copy of HAScene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? icon = freezed,
  }) {
    return _then(_self.copyWith(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAScene].
extension HAScenePatterns on HAScene {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAScene value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAScene() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAScene value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAScene():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAScene value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAScene() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String entityId, String name, String? icon)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAScene() when $default != null:
        return $default(_that.entityId, _that.name, _that.icon);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String entityId, String name, String? icon) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAScene():
        return $default(_that.entityId, _that.name, _that.icon);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String entityId, String name, String? icon)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAScene() when $default != null:
        return $default(_that.entityId, _that.name, _that.icon);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAScene implements HAScene {
  const _HAScene({required this.entityId, required this.name, this.icon});
  factory _HAScene.fromJson(Map<String, dynamic> json) =>
      _$HASceneFromJson(json);

  @override
  final String entityId;
  @override
  final String name;
  @override
  final String? icon;

  /// Create a copy of HAScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HASceneCopyWith<_HAScene> get copyWith =>
      __$HASceneCopyWithImpl<_HAScene>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HASceneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAScene &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, entityId, name, icon);

  @override
  String toString() {
    return 'HAScene(entityId: $entityId, name: $name, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class _$HASceneCopyWith<$Res> implements $HASceneCopyWith<$Res> {
  factory _$HASceneCopyWith(_HAScene value, $Res Function(_HAScene) _then) =
      __$HASceneCopyWithImpl;
  @override
  @useResult
  $Res call({String entityId, String name, String? icon});
}

/// @nodoc
class __$HASceneCopyWithImpl<$Res> implements _$HASceneCopyWith<$Res> {
  __$HASceneCopyWithImpl(this._self, this._then);

  final _HAScene _self;
  final $Res Function(_HAScene) _then;

  /// Create a copy of HAScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? icon = freezed,
  }) {
    return _then(_HAScene(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$HADevice {
  String get id;
  String get name;
  String? get manufacturer;
  String? get model;
  String? get swVersion;
  String? get areaId;
  bool get isDisabled;

  /// Create a copy of HADevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HADeviceCopyWith<HADevice> get copyWith =>
      _$HADeviceCopyWithImpl<HADevice>(this as HADevice, _$identity);

  /// Serializes this HADevice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HADevice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.swVersion, swVersion) ||
                other.swVersion == swVersion) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.isDisabled, isDisabled) ||
                other.isDisabled == isDisabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, manufacturer, model,
      swVersion, areaId, isDisabled);

  @override
  String toString() {
    return 'HADevice(id: $id, name: $name, manufacturer: $manufacturer, model: $model, swVersion: $swVersion, areaId: $areaId, isDisabled: $isDisabled)';
  }
}

/// @nodoc
abstract mixin class $HADeviceCopyWith<$Res> {
  factory $HADeviceCopyWith(HADevice value, $Res Function(HADevice) _then) =
      _$HADeviceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? manufacturer,
      String? model,
      String? swVersion,
      String? areaId,
      bool isDisabled});
}

/// @nodoc
class _$HADeviceCopyWithImpl<$Res> implements $HADeviceCopyWith<$Res> {
  _$HADeviceCopyWithImpl(this._self, this._then);

  final HADevice _self;
  final $Res Function(HADevice) _then;

  /// Create a copy of HADevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = freezed,
    Object? model = freezed,
    Object? swVersion = freezed,
    Object? areaId = freezed,
    Object? isDisabled = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      manufacturer: freezed == manufacturer
          ? _self.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      swVersion: freezed == swVersion
          ? _self.swVersion
          : swVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      areaId: freezed == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDisabled: null == isDisabled
          ? _self.isDisabled
          : isDisabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [HADevice].
extension HADevicePatterns on HADevice {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HADevice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HADevice() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HADevice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HADevice():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HADevice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HADevice() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name, String? manufacturer,
            String? model, String? swVersion, String? areaId, bool isDisabled)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HADevice() when $default != null:
        return $default(_that.id, _that.name, _that.manufacturer, _that.model,
            _that.swVersion, _that.areaId, _that.isDisabled);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name, String? manufacturer,
            String? model, String? swVersion, String? areaId, bool isDisabled)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HADevice():
        return $default(_that.id, _that.name, _that.manufacturer, _that.model,
            _that.swVersion, _that.areaId, _that.isDisabled);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name, String? manufacturer,
            String? model, String? swVersion, String? areaId, bool isDisabled)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HADevice() when $default != null:
        return $default(_that.id, _that.name, _that.manufacturer, _that.model,
            _that.swVersion, _that.areaId, _that.isDisabled);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HADevice implements HADevice {
  const _HADevice(
      {required this.id,
      required this.name,
      this.manufacturer,
      this.model,
      this.swVersion,
      this.areaId,
      this.isDisabled = false});
  factory _HADevice.fromJson(Map<String, dynamic> json) =>
      _$HADeviceFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? manufacturer;
  @override
  final String? model;
  @override
  final String? swVersion;
  @override
  final String? areaId;
  @override
  @JsonKey()
  final bool isDisabled;

  /// Create a copy of HADevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HADeviceCopyWith<_HADevice> get copyWith =>
      __$HADeviceCopyWithImpl<_HADevice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HADeviceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HADevice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.swVersion, swVersion) ||
                other.swVersion == swVersion) &&
            (identical(other.areaId, areaId) || other.areaId == areaId) &&
            (identical(other.isDisabled, isDisabled) ||
                other.isDisabled == isDisabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, manufacturer, model,
      swVersion, areaId, isDisabled);

  @override
  String toString() {
    return 'HADevice(id: $id, name: $name, manufacturer: $manufacturer, model: $model, swVersion: $swVersion, areaId: $areaId, isDisabled: $isDisabled)';
  }
}

/// @nodoc
abstract mixin class _$HADeviceCopyWith<$Res>
    implements $HADeviceCopyWith<$Res> {
  factory _$HADeviceCopyWith(_HADevice value, $Res Function(_HADevice) _then) =
      __$HADeviceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? manufacturer,
      String? model,
      String? swVersion,
      String? areaId,
      bool isDisabled});
}

/// @nodoc
class __$HADeviceCopyWithImpl<$Res> implements _$HADeviceCopyWith<$Res> {
  __$HADeviceCopyWithImpl(this._self, this._then);

  final _HADevice _self;
  final $Res Function(_HADevice) _then;

  /// Create a copy of HADevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = freezed,
    Object? model = freezed,
    Object? swVersion = freezed,
    Object? areaId = freezed,
    Object? isDisabled = null,
  }) {
    return _then(_HADevice(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      manufacturer: freezed == manufacturer
          ? _self.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      swVersion: freezed == swVersion
          ? _self.swVersion
          : swVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      areaId: freezed == areaId
          ? _self.areaId
          : areaId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDisabled: null == isDisabled
          ? _self.isDisabled
          : isDisabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$HAAlert {
  String get type;
  String get entityId;
  String get message;
  String get priority;
  DateTime get timestamp;

  /// Create a copy of HAAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAAlertCopyWith<HAAlert> get copyWith =>
      _$HAAlertCopyWithImpl<HAAlert>(this as HAAlert, _$identity);

  /// Serializes this HAAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAAlert &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, entityId, message, priority, timestamp);

  @override
  String toString() {
    return 'HAAlert(type: $type, entityId: $entityId, message: $message, priority: $priority, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class $HAAlertCopyWith<$Res> {
  factory $HAAlertCopyWith(HAAlert value, $Res Function(HAAlert) _then) =
      _$HAAlertCopyWithImpl;
  @useResult
  $Res call(
      {String type,
      String entityId,
      String message,
      String priority,
      DateTime timestamp});
}

/// @nodoc
class _$HAAlertCopyWithImpl<$Res> implements $HAAlertCopyWith<$Res> {
  _$HAAlertCopyWithImpl(this._self, this._then);

  final HAAlert _self;
  final $Res Function(HAAlert) _then;

  /// Create a copy of HAAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? entityId = null,
    Object? message = null,
    Object? priority = null,
    Object? timestamp = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAAlert].
extension HAAlertPatterns on HAAlert {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAAlert value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAAlert() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAAlert value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAAlert():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAAlert value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAAlert() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String type, String entityId, String message,
            String priority, DateTime timestamp)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAAlert() when $default != null:
        return $default(_that.type, _that.entityId, _that.message,
            _that.priority, _that.timestamp);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String type, String entityId, String message,
            String priority, DateTime timestamp)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAAlert():
        return $default(_that.type, _that.entityId, _that.message,
            _that.priority, _that.timestamp);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String type, String entityId, String message,
            String priority, DateTime timestamp)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAAlert() when $default != null:
        return $default(_that.type, _that.entityId, _that.message,
            _that.priority, _that.timestamp);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAAlert implements HAAlert {
  const _HAAlert(
      {required this.type,
      required this.entityId,
      required this.message,
      required this.priority,
      required this.timestamp});
  factory _HAAlert.fromJson(Map<String, dynamic> json) =>
      _$HAAlertFromJson(json);

  @override
  final String type;
  @override
  final String entityId;
  @override
  final String message;
  @override
  final String priority;
  @override
  final DateTime timestamp;

  /// Create a copy of HAAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAAlertCopyWith<_HAAlert> get copyWith =>
      __$HAAlertCopyWithImpl<_HAAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAAlert &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, entityId, message, priority, timestamp);

  @override
  String toString() {
    return 'HAAlert(type: $type, entityId: $entityId, message: $message, priority: $priority, timestamp: $timestamp)';
  }
}

/// @nodoc
abstract mixin class _$HAAlertCopyWith<$Res> implements $HAAlertCopyWith<$Res> {
  factory _$HAAlertCopyWith(_HAAlert value, $Res Function(_HAAlert) _then) =
      __$HAAlertCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String type,
      String entityId,
      String message,
      String priority,
      DateTime timestamp});
}

/// @nodoc
class __$HAAlertCopyWithImpl<$Res> implements _$HAAlertCopyWith<$Res> {
  __$HAAlertCopyWithImpl(this._self, this._then);

  final _HAAlert _self;
  final $Res Function(_HAAlert) _then;

  /// Create a copy of HAAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? entityId = null,
    Object? message = null,
    Object? priority = null,
    Object? timestamp = null,
  }) {
    return _then(_HAAlert(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$HAEntityListResponse {
  List<HAEntity> get entities;
  int get count;
  Map<String, int> get domainCounts;

  /// Create a copy of HAEntityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HAEntityListResponseCopyWith<HAEntityListResponse> get copyWith =>
      _$HAEntityListResponseCopyWithImpl<HAEntityListResponse>(
          this as HAEntityListResponse, _$identity);

  /// Serializes this HAEntityListResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HAEntityListResponse &&
            const DeepCollectionEquality().equals(other.entities, entities) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality()
                .equals(other.domainCounts, domainCounts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(entities),
      count,
      const DeepCollectionEquality().hash(domainCounts));

  @override
  String toString() {
    return 'HAEntityListResponse(entities: $entities, count: $count, domainCounts: $domainCounts)';
  }
}

/// @nodoc
abstract mixin class $HAEntityListResponseCopyWith<$Res> {
  factory $HAEntityListResponseCopyWith(HAEntityListResponse value,
          $Res Function(HAEntityListResponse) _then) =
      _$HAEntityListResponseCopyWithImpl;
  @useResult
  $Res call(
      {List<HAEntity> entities, int count, Map<String, int> domainCounts});
}

/// @nodoc
class _$HAEntityListResponseCopyWithImpl<$Res>
    implements $HAEntityListResponseCopyWith<$Res> {
  _$HAEntityListResponseCopyWithImpl(this._self, this._then);

  final HAEntityListResponse _self;
  final $Res Function(HAEntityListResponse) _then;

  /// Create a copy of HAEntityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entities = null,
    Object? count = null,
    Object? domainCounts = null,
  }) {
    return _then(_self.copyWith(
      entities: null == entities
          ? _self.entities
          : entities // ignore: cast_nullable_to_non_nullable
              as List<HAEntity>,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      domainCounts: null == domainCounts
          ? _self.domainCounts
          : domainCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// Adds pattern-matching-related methods to [HAEntityListResponse].
extension HAEntityListResponsePatterns on HAEntityListResponse {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HAEntityListResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HAEntityListResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HAEntityListResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<HAEntity> entities, int count, Map<String, int> domainCounts)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse() when $default != null:
        return $default(_that.entities, _that.count, _that.domainCounts);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<HAEntity> entities, int count, Map<String, int> domainCounts)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse():
        return $default(_that.entities, _that.count, _that.domainCounts);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<HAEntity> entities, int count, Map<String, int> domainCounts)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HAEntityListResponse() when $default != null:
        return $default(_that.entities, _that.count, _that.domainCounts);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HAEntityListResponse implements HAEntityListResponse {
  const _HAEntityListResponse(
      {final List<HAEntity> entities = const [],
      this.count = 0,
      final Map<String, int> domainCounts = const {}})
      : _entities = entities,
        _domainCounts = domainCounts;
  factory _HAEntityListResponse.fromJson(Map<String, dynamic> json) =>
      _$HAEntityListResponseFromJson(json);

  final List<HAEntity> _entities;
  @override
  @JsonKey()
  List<HAEntity> get entities {
    if (_entities is EqualUnmodifiableListView) return _entities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entities);
  }

  @override
  @JsonKey()
  final int count;
  final Map<String, int> _domainCounts;
  @override
  @JsonKey()
  Map<String, int> get domainCounts {
    if (_domainCounts is EqualUnmodifiableMapView) return _domainCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_domainCounts);
  }

  /// Create a copy of HAEntityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HAEntityListResponseCopyWith<_HAEntityListResponse> get copyWith =>
      __$HAEntityListResponseCopyWithImpl<_HAEntityListResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HAEntityListResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HAEntityListResponse &&
            const DeepCollectionEquality().equals(other._entities, _entities) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality()
                .equals(other._domainCounts, _domainCounts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entities),
      count,
      const DeepCollectionEquality().hash(_domainCounts));

  @override
  String toString() {
    return 'HAEntityListResponse(entities: $entities, count: $count, domainCounts: $domainCounts)';
  }
}

/// @nodoc
abstract mixin class _$HAEntityListResponseCopyWith<$Res>
    implements $HAEntityListResponseCopyWith<$Res> {
  factory _$HAEntityListResponseCopyWith(_HAEntityListResponse value,
          $Res Function(_HAEntityListResponse) _then) =
      __$HAEntityListResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<HAEntity> entities, int count, Map<String, int> domainCounts});
}

/// @nodoc
class __$HAEntityListResponseCopyWithImpl<$Res>
    implements _$HAEntityListResponseCopyWith<$Res> {
  __$HAEntityListResponseCopyWithImpl(this._self, this._then);

  final _HAEntityListResponse _self;
  final $Res Function(_HAEntityListResponse) _then;

  /// Create a copy of HAEntityListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entities = null,
    Object? count = null,
    Object? domainCounts = null,
  }) {
    return _then(_HAEntityListResponse(
      entities: null == entities
          ? _self._entities
          : entities // ignore: cast_nullable_to_non_nullable
              as List<HAEntity>,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      domainCounts: null == domainCounts
          ? _self._domainCounts
          : domainCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

// dart format on
