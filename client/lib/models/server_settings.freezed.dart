// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerSettings {

 int get trashRetentionDays; bool get trashRetentionEnforced;
/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerSettingsCopyWith<ServerSettings> get copyWith => _$ServerSettingsCopyWithImpl<ServerSettings>(this as ServerSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSettings&&(identical(other.trashRetentionDays, _this.trashRetentionDays) || other.trashRetentionDays == _this.trashRetentionDays)&&(identical(other.trashRetentionEnforced, _this.trashRetentionEnforced) || other.trashRetentionEnforced == _this.trashRetentionEnforced));
}


@override
int get hashCode {
  final _this = this as ServerSettings;
  return Object.hash(runtimeType,_this.trashRetentionDays,_this.trashRetentionEnforced);
}

@override
String toString() {
  final _this = this as ServerSettings;
  return 'ServerSettings(trashRetentionDays: ${_this.trashRetentionDays}, trashRetentionEnforced: ${_this.trashRetentionEnforced})';
}


}

/// @nodoc
abstract mixin class $ServerSettingsCopyWith<$Res>  {
  factory $ServerSettingsCopyWith(ServerSettings value, $Res Function(ServerSettings) _then) = _$ServerSettingsCopyWithImpl;
@useResult
$Res call({
 int trashRetentionDays, bool trashRetentionEnforced
});




}
/// @nodoc
class _$ServerSettingsCopyWithImpl<$Res>
    implements $ServerSettingsCopyWith<$Res> {
  _$ServerSettingsCopyWithImpl(this._self, this._then);

  final ServerSettings _self;
  final $Res Function(ServerSettings) _then;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trashRetentionDays = null,Object? trashRetentionEnforced = null,}) {
  return _then(ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashRetentionEnforced: null == trashRetentionEnforced ? _self.trashRetentionEnforced : trashRetentionEnforced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerSettings].
extension ServerSettingsPatterns on ServerSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerSettings value)  $default,){
final _that = this;
switch (_that) {
case _ServerSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashRetentionEnforced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashRetentionEnforced)  $default,) {final _that = this;
switch (_that) {
case _ServerSettings():
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trashRetentionDays,  bool trashRetentionEnforced)?  $default,) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced);case _:
  return null;

}
}

}

/// @nodoc


class _ServerSettings implements ServerSettings {
  const _ServerSettings({required this.trashRetentionDays, this.trashRetentionEnforced = false});
  

@override final  int trashRetentionDays;
@override@JsonKey() final  bool trashRetentionEnforced;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerSettingsCopyWith<_ServerSettings> get copyWith => __$ServerSettingsCopyWithImpl<_ServerSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerSettings&&(identical(other.trashRetentionDays, trashRetentionDays) || other.trashRetentionDays == trashRetentionDays)&&(identical(other.trashRetentionEnforced, trashRetentionEnforced) || other.trashRetentionEnforced == trashRetentionEnforced));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trashRetentionDays,trashRetentionEnforced);
}

@override
String toString() {
    return 'ServerSettings(trashRetentionDays: $trashRetentionDays, trashRetentionEnforced: $trashRetentionEnforced)';
}


}

/// @nodoc
abstract mixin class _$ServerSettingsCopyWith<$Res> implements $ServerSettingsCopyWith<$Res> {
  factory _$ServerSettingsCopyWith(_ServerSettings value, $Res Function(_ServerSettings) _then) = __$ServerSettingsCopyWithImpl;
@override @useResult
$Res call({
 int trashRetentionDays, bool trashRetentionEnforced
});




}
/// @nodoc
class __$ServerSettingsCopyWithImpl<$Res>
    implements _$ServerSettingsCopyWith<$Res> {
  __$ServerSettingsCopyWithImpl(this._self, this._then);

  final _ServerSettings _self;
  final $Res Function(_ServerSettings) _then;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trashRetentionDays = null,Object? trashRetentionEnforced = null,}) {
  return _then(_ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashRetentionEnforced: null == trashRetentionEnforced ? _self.trashRetentionEnforced : trashRetentionEnforced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
