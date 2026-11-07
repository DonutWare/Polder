// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferences {

 bool get enabled; bool get shares; bool get calendarReminders; bool get autoUploadProgress; bool get autoUploadSummary; bool get autoUploadCheck;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationPreferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.shares, _this.shares) || other.shares == _this.shares)&&(identical(other.calendarReminders, _this.calendarReminders) || other.calendarReminders == _this.calendarReminders)&&(identical(other.autoUploadProgress, _this.autoUploadProgress) || other.autoUploadProgress == _this.autoUploadProgress)&&(identical(other.autoUploadSummary, _this.autoUploadSummary) || other.autoUploadSummary == _this.autoUploadSummary)&&(identical(other.autoUploadCheck, _this.autoUploadCheck) || other.autoUploadCheck == _this.autoUploadCheck));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationPreferences;
  return Object.hash(runtimeType,_this.enabled,_this.shares,_this.calendarReminders,_this.autoUploadProgress,_this.autoUploadSummary,_this.autoUploadCheck);
}

@override
String toString() {
  final _this = this as NotificationPreferences;
  return 'NotificationPreferences(enabled: ${_this.enabled}, shares: ${_this.shares}, calendarReminders: ${_this.calendarReminders}, autoUploadProgress: ${_this.autoUploadProgress}, autoUploadSummary: ${_this.autoUploadSummary}, autoUploadCheck: ${_this.autoUploadCheck})';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool shares, bool calendarReminders, bool autoUploadProgress, bool autoUploadSummary, bool autoUploadCheck
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? shares = null,Object? calendarReminders = null,Object? autoUploadProgress = null,Object? autoUploadSummary = null,Object? autoUploadCheck = null,}) {
  return _then(NotificationPreferences(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as bool,calendarReminders: null == calendarReminders ? _self.calendarReminders : calendarReminders // ignore: cast_nullable_to_non_nullable
as bool,autoUploadProgress: null == autoUploadProgress ? _self.autoUploadProgress : autoUploadProgress // ignore: cast_nullable_to_non_nullable
as bool,autoUploadSummary: null == autoUploadSummary ? _self.autoUploadSummary : autoUploadSummary // ignore: cast_nullable_to_non_nullable
as bool,autoUploadCheck: null == autoUploadCheck ? _self.autoUploadCheck : autoUploadCheck // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool shares,  bool calendarReminders,  bool autoUploadProgress,  bool autoUploadSummary,  bool autoUploadCheck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.enabled,_that.shares,_that.calendarReminders,_that.autoUploadProgress,_that.autoUploadSummary,_that.autoUploadCheck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool shares,  bool calendarReminders,  bool autoUploadProgress,  bool autoUploadSummary,  bool autoUploadCheck)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.enabled,_that.shares,_that.calendarReminders,_that.autoUploadProgress,_that.autoUploadSummary,_that.autoUploadCheck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool shares,  bool calendarReminders,  bool autoUploadProgress,  bool autoUploadSummary,  bool autoUploadCheck)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.enabled,_that.shares,_that.calendarReminders,_that.autoUploadProgress,_that.autoUploadSummary,_that.autoUploadCheck);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.enabled = false, this.shares = true, this.calendarReminders = true, this.autoUploadProgress = true, this.autoUploadSummary = true, this.autoUploadCheck = false}): super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool shares;
@override@JsonKey() final  bool calendarReminders;
@override@JsonKey() final  bool autoUploadProgress;
@override@JsonKey() final  bool autoUploadSummary;
@override@JsonKey() final  bool autoUploadCheck;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.calendarReminders, calendarReminders) || other.calendarReminders == calendarReminders)&&(identical(other.autoUploadProgress, autoUploadProgress) || other.autoUploadProgress == autoUploadProgress)&&(identical(other.autoUploadSummary, autoUploadSummary) || other.autoUploadSummary == autoUploadSummary)&&(identical(other.autoUploadCheck, autoUploadCheck) || other.autoUploadCheck == autoUploadCheck));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,shares,calendarReminders,autoUploadProgress,autoUploadSummary,autoUploadCheck);
}

@override
String toString() {
    return 'NotificationPreferences(enabled: $enabled, shares: $shares, calendarReminders: $calendarReminders, autoUploadProgress: $autoUploadProgress, autoUploadSummary: $autoUploadSummary, autoUploadCheck: $autoUploadCheck)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool shares, bool calendarReminders, bool autoUploadProgress, bool autoUploadSummary, bool autoUploadCheck
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? shares = null,Object? calendarReminders = null,Object? autoUploadProgress = null,Object? autoUploadSummary = null,Object? autoUploadCheck = null,}) {
  return _then(_NotificationPreferences(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as bool,calendarReminders: null == calendarReminders ? _self.calendarReminders : calendarReminders // ignore: cast_nullable_to_non_nullable
as bool,autoUploadProgress: null == autoUploadProgress ? _self.autoUploadProgress : autoUploadProgress // ignore: cast_nullable_to_non_nullable
as bool,autoUploadSummary: null == autoUploadSummary ? _self.autoUploadSummary : autoUploadSummary // ignore: cast_nullable_to_non_nullable
as bool,autoUploadCheck: null == autoUploadCheck ? _self.autoUploadCheck : autoUploadCheck // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
