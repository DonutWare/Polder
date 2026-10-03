// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appearance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Appearance {

 ThemeMode get mode; Color? get accent; Color? get systemAccent;
/// Create a copy of Appearance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppearanceCopyWith<Appearance> get copyWith => _$AppearanceCopyWithImpl<Appearance>(this as Appearance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Appearance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appearance&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.systemAccent, _this.systemAccent) || other.systemAccent == _this.systemAccent));
}


@override
int get hashCode {
  final _this = this as Appearance;
  return Object.hash(runtimeType,_this.mode,_this.accent,_this.systemAccent);
}

@override
String toString() {
  final _this = this as Appearance;
  return 'Appearance(mode: ${_this.mode}, accent: ${_this.accent}, systemAccent: ${_this.systemAccent})';
}


}

/// @nodoc
abstract mixin class $AppearanceCopyWith<$Res>  {
  factory $AppearanceCopyWith(Appearance value, $Res Function(Appearance) _then) = _$AppearanceCopyWithImpl;
@useResult
$Res call({
 ThemeMode mode, Color? accent, Color? systemAccent
});




}
/// @nodoc
class _$AppearanceCopyWithImpl<$Res>
    implements $AppearanceCopyWith<$Res> {
  _$AppearanceCopyWithImpl(this._self, this._then);

  final Appearance _self;
  final $Res Function(Appearance) _then;

/// Create a copy of Appearance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? accent = freezed,Object? systemAccent = freezed,}) {
  return _then(Appearance(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,systemAccent: freezed == systemAccent ? _self.systemAccent : systemAccent // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appearance].
extension AppearancePatterns on Appearance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appearance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appearance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appearance value)  $default,){
final _that = this;
switch (_that) {
case _Appearance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appearance value)?  $default,){
final _that = this;
switch (_that) {
case _Appearance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode mode,  Color? accent,  Color? systemAccent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appearance() when $default != null:
return $default(_that.mode,_that.accent,_that.systemAccent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode mode,  Color? accent,  Color? systemAccent)  $default,) {final _that = this;
switch (_that) {
case _Appearance():
return $default(_that.mode,_that.accent,_that.systemAccent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode mode,  Color? accent,  Color? systemAccent)?  $default,) {final _that = this;
switch (_that) {
case _Appearance() when $default != null:
return $default(_that.mode,_that.accent,_that.systemAccent);case _:
  return null;

}
}

}

/// @nodoc


class _Appearance extends Appearance {
  const _Appearance({this.mode = ThemeMode.system, this.accent, this.systemAccent}): super._();
  

@override@JsonKey() final  ThemeMode mode;
@override final  Color? accent;
@override final  Color? systemAccent;

/// Create a copy of Appearance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppearanceCopyWith<_Appearance> get copyWith => __$AppearanceCopyWithImpl<_Appearance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appearance&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.systemAccent, systemAccent) || other.systemAccent == systemAccent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,accent,systemAccent);
}

@override
String toString() {
    return 'Appearance(mode: $mode, accent: $accent, systemAccent: $systemAccent)';
}


}

/// @nodoc
abstract mixin class _$AppearanceCopyWith<$Res> implements $AppearanceCopyWith<$Res> {
  factory _$AppearanceCopyWith(_Appearance value, $Res Function(_Appearance) _then) = __$AppearanceCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode mode, Color? accent, Color? systemAccent
});




}
/// @nodoc
class __$AppearanceCopyWithImpl<$Res>
    implements _$AppearanceCopyWith<$Res> {
  __$AppearanceCopyWithImpl(this._self, this._then);

  final _Appearance _self;
  final $Res Function(_Appearance) _then;

/// Create a copy of Appearance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? accent = freezed,Object? systemAccent = freezed,}) {
  return _then(_Appearance(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ThemeMode,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,systemAccent: freezed == systemAccent ? _self.systemAccent : systemAccent // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}


}

// dart format on
