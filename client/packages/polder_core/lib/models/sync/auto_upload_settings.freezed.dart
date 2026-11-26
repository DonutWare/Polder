// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_upload_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AutoUploadSettings {

 bool get enabled; bool get wifiOnly; bool get chargingOnly;
/// Create a copy of AutoUploadSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoUploadSettingsCopyWith<AutoUploadSettings> get copyWith => _$AutoUploadSettingsCopyWithImpl<AutoUploadSettings>(this as AutoUploadSettings, _$identity);

  /// Serializes this AutoUploadSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AutoUploadSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoUploadSettings&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.wifiOnly, _this.wifiOnly) || other.wifiOnly == _this.wifiOnly)&&(identical(other.chargingOnly, _this.chargingOnly) || other.chargingOnly == _this.chargingOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AutoUploadSettings;
  return Object.hash(runtimeType,_this.enabled,_this.wifiOnly,_this.chargingOnly);
}

@override
String toString() {
  final _this = this as AutoUploadSettings;
  return 'AutoUploadSettings(enabled: ${_this.enabled}, wifiOnly: ${_this.wifiOnly}, chargingOnly: ${_this.chargingOnly})';
}


}

/// @nodoc
abstract mixin class $AutoUploadSettingsCopyWith<$Res>  {
  factory $AutoUploadSettingsCopyWith(AutoUploadSettings value, $Res Function(AutoUploadSettings) _then) = _$AutoUploadSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool wifiOnly, bool chargingOnly
});




}
/// @nodoc
class _$AutoUploadSettingsCopyWithImpl<$Res>
    implements $AutoUploadSettingsCopyWith<$Res> {
  _$AutoUploadSettingsCopyWithImpl(this._self, this._then);

  final AutoUploadSettings _self;
  final $Res Function(AutoUploadSettings) _then;

/// Create a copy of AutoUploadSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? wifiOnly = null,Object? chargingOnly = null,}) {
  return _then(AutoUploadSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,chargingOnly: null == chargingOnly ? _self.chargingOnly : chargingOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoUploadSettings].
extension AutoUploadSettingsPatterns on AutoUploadSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoUploadSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoUploadSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoUploadSettings value)  $default,){
final _that = this;
switch (_that) {
case _AutoUploadSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoUploadSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AutoUploadSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool wifiOnly,  bool chargingOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoUploadSettings() when $default != null:
return $default(_that.enabled,_that.wifiOnly,_that.chargingOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool wifiOnly,  bool chargingOnly)  $default,) {final _that = this;
switch (_that) {
case _AutoUploadSettings():
return $default(_that.enabled,_that.wifiOnly,_that.chargingOnly);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool wifiOnly,  bool chargingOnly)?  $default,) {final _that = this;
switch (_that) {
case _AutoUploadSettings() when $default != null:
return $default(_that.enabled,_that.wifiOnly,_that.chargingOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoUploadSettings implements AutoUploadSettings {
  const _AutoUploadSettings({this.enabled = false, this.wifiOnly = true, this.chargingOnly = false});
  factory _AutoUploadSettings.fromJson(Map<String, dynamic> json) => _$AutoUploadSettingsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool wifiOnly;
@override@JsonKey() final  bool chargingOnly;

/// Create a copy of AutoUploadSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoUploadSettingsCopyWith<_AutoUploadSettings> get copyWith => __$AutoUploadSettingsCopyWithImpl<_AutoUploadSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoUploadSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoUploadSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.wifiOnly, wifiOnly) || other.wifiOnly == wifiOnly)&&(identical(other.chargingOnly, chargingOnly) || other.chargingOnly == chargingOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,wifiOnly,chargingOnly);
}

@override
String toString() {
    return 'AutoUploadSettings(enabled: $enabled, wifiOnly: $wifiOnly, chargingOnly: $chargingOnly)';
}


}

/// @nodoc
abstract mixin class _$AutoUploadSettingsCopyWith<$Res> implements $AutoUploadSettingsCopyWith<$Res> {
  factory _$AutoUploadSettingsCopyWith(_AutoUploadSettings value, $Res Function(_AutoUploadSettings) _then) = __$AutoUploadSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool wifiOnly, bool chargingOnly
});




}
/// @nodoc
class __$AutoUploadSettingsCopyWithImpl<$Res>
    implements _$AutoUploadSettingsCopyWith<$Res> {
  __$AutoUploadSettingsCopyWithImpl(this._self, this._then);

  final _AutoUploadSettings _self;
  final $Res Function(_AutoUploadSettings) _then;

/// Create a copy of AutoUploadSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? wifiOnly = null,Object? chargingOnly = null,}) {
  return _then(_AutoUploadSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,chargingOnly: null == chargingOnly ? _self.chargingOnly : chargingOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
