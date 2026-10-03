// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'setup_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetupStatus {

 bool get needsSetup;
/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupStatusCopyWith<SetupStatus> get copyWith => _$SetupStatusCopyWithImpl<SetupStatus>(this as SetupStatus, _$identity);

  /// Serializes this SetupStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetupStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupStatus&&(identical(other.needsSetup, _this.needsSetup) || other.needsSetup == _this.needsSetup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupStatus;
  return Object.hash(runtimeType,_this.needsSetup);
}

@override
String toString() {
  final _this = this as SetupStatus;
  return 'SetupStatus(needsSetup: ${_this.needsSetup})';
}


}

/// @nodoc
abstract mixin class $SetupStatusCopyWith<$Res>  {
  factory $SetupStatusCopyWith(SetupStatus value, $Res Function(SetupStatus) _then) = _$SetupStatusCopyWithImpl;
@useResult
$Res call({
 bool needsSetup
});




}
/// @nodoc
class _$SetupStatusCopyWithImpl<$Res>
    implements $SetupStatusCopyWith<$Res> {
  _$SetupStatusCopyWithImpl(this._self, this._then);

  final SetupStatus _self;
  final $Res Function(SetupStatus) _then;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? needsSetup = null,}) {
  return _then(SetupStatus(
needsSetup: null == needsSetup ? _self.needsSetup : needsSetup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SetupStatus].
extension SetupStatusPatterns on SetupStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupStatus value)  $default,){
final _that = this;
switch (_that) {
case _SetupStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool needsSetup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
return $default(_that.needsSetup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool needsSetup)  $default,) {final _that = this;
switch (_that) {
case _SetupStatus():
return $default(_that.needsSetup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool needsSetup)?  $default,) {final _that = this;
switch (_that) {
case _SetupStatus() when $default != null:
return $default(_that.needsSetup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupStatus implements SetupStatus {
  const _SetupStatus({required this.needsSetup});
  factory _SetupStatus.fromJson(Map<String, dynamic> json) => _$SetupStatusFromJson(json);

@override final  bool needsSetup;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupStatusCopyWith<_SetupStatus> get copyWith => __$SetupStatusCopyWithImpl<_SetupStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupStatus&&(identical(other.needsSetup, needsSetup) || other.needsSetup == needsSetup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,needsSetup);
}

@override
String toString() {
    return 'SetupStatus(needsSetup: $needsSetup)';
}


}

/// @nodoc
abstract mixin class _$SetupStatusCopyWith<$Res> implements $SetupStatusCopyWith<$Res> {
  factory _$SetupStatusCopyWith(_SetupStatus value, $Res Function(_SetupStatus) _then) = __$SetupStatusCopyWithImpl;
@override @useResult
$Res call({
 bool needsSetup
});




}
/// @nodoc
class __$SetupStatusCopyWithImpl<$Res>
    implements _$SetupStatusCopyWith<$Res> {
  __$SetupStatusCopyWithImpl(this._self, this._then);

  final _SetupStatus _self;
  final $Res Function(_SetupStatus) _then;

/// Create a copy of SetupStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? needsSetup = null,}) {
  return _then(_SetupStatus(
needsSetup: null == needsSetup ? _self.needsSetup : needsSetup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
