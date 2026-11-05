// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarInfo {

 CalendarRef get ref; String get name; Color? get color; CalendarAccess get access; bool get hidden; bool get isDefault; bool get subscription; String? get ownerName;
/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarInfoCopyWith<CalendarInfo> get copyWith => _$CalendarInfoCopyWithImpl<CalendarInfo>(this as CalendarInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarInfo&&(identical(other.ref, _this.ref) || other.ref == _this.ref)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName));
}


@override
int get hashCode {
  final _this = this as CalendarInfo;
  return Object.hash(runtimeType,_this.ref,_this.name,_this.color,_this.access,_this.hidden,_this.isDefault,_this.subscription,_this.ownerName);
}

@override
String toString() {
  final _this = this as CalendarInfo;
  return 'CalendarInfo(ref: ${_this.ref}, name: ${_this.name}, color: ${_this.color}, access: ${_this.access}, hidden: ${_this.hidden}, isDefault: ${_this.isDefault}, subscription: ${_this.subscription}, ownerName: ${_this.ownerName})';
}


}

/// @nodoc
abstract mixin class $CalendarInfoCopyWith<$Res>  {
  factory $CalendarInfoCopyWith(CalendarInfo value, $Res Function(CalendarInfo) _then) = _$CalendarInfoCopyWithImpl;
@useResult
$Res call({
 CalendarRef ref, String name, Color? color, CalendarAccess access, bool hidden, bool isDefault, bool subscription, String? ownerName
});


$CalendarRefCopyWith<$Res> get ref;

}
/// @nodoc
class _$CalendarInfoCopyWithImpl<$Res>
    implements $CalendarInfoCopyWith<$Res> {
  _$CalendarInfoCopyWithImpl(this._self, this._then);

  final CalendarInfo _self;
  final $Res Function(CalendarInfo) _then;

/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? name = null,Object? color = freezed,Object? access = null,Object? hidden = null,Object? isDefault = null,Object? subscription = null,Object? ownerName = freezed,}) {
  return _then(CalendarInfo(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as CalendarRef,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarAccess,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarRefCopyWith<$Res> get ref {
  
  return $CalendarRefCopyWith<$Res>(_self.ref, (value) {
    return _then(_self.copyWith(ref: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarInfo].
extension CalendarInfoPatterns on CalendarInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarInfo value)  $default,){
final _that = this;
switch (_that) {
case _CalendarInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarRef ref,  String name,  Color? color,  CalendarAccess access,  bool hidden,  bool isDefault,  bool subscription,  String? ownerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarInfo() when $default != null:
return $default(_that.ref,_that.name,_that.color,_that.access,_that.hidden,_that.isDefault,_that.subscription,_that.ownerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarRef ref,  String name,  Color? color,  CalendarAccess access,  bool hidden,  bool isDefault,  bool subscription,  String? ownerName)  $default,) {final _that = this;
switch (_that) {
case _CalendarInfo():
return $default(_that.ref,_that.name,_that.color,_that.access,_that.hidden,_that.isDefault,_that.subscription,_that.ownerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarRef ref,  String name,  Color? color,  CalendarAccess access,  bool hidden,  bool isDefault,  bool subscription,  String? ownerName)?  $default,) {final _that = this;
switch (_that) {
case _CalendarInfo() when $default != null:
return $default(_that.ref,_that.name,_that.color,_that.access,_that.hidden,_that.isDefault,_that.subscription,_that.ownerName);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarInfo extends CalendarInfo {
  const _CalendarInfo({required this.ref, required this.name, this.color, required this.access, this.hidden = false, this.isDefault = false, this.subscription = false, this.ownerName}): super._();
  

@override final  CalendarRef ref;
@override final  String name;
@override final  Color? color;
@override final  CalendarAccess access;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool subscription;
@override final  String? ownerName;

/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarInfoCopyWith<_CalendarInfo> get copyWith => __$CalendarInfoCopyWithImpl<_CalendarInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarInfo&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.access, access) || other.access == access)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ref,name,color,access,hidden,isDefault,subscription,ownerName);
}

@override
String toString() {
    return 'CalendarInfo(ref: $ref, name: $name, color: $color, access: $access, hidden: $hidden, isDefault: $isDefault, subscription: $subscription, ownerName: $ownerName)';
}


}

/// @nodoc
abstract mixin class _$CalendarInfoCopyWith<$Res> implements $CalendarInfoCopyWith<$Res> {
  factory _$CalendarInfoCopyWith(_CalendarInfo value, $Res Function(_CalendarInfo) _then) = __$CalendarInfoCopyWithImpl;
@override @useResult
$Res call({
 CalendarRef ref, String name, Color? color, CalendarAccess access, bool hidden, bool isDefault, bool subscription, String? ownerName
});


@override $CalendarRefCopyWith<$Res> get ref;

}
/// @nodoc
class __$CalendarInfoCopyWithImpl<$Res>
    implements _$CalendarInfoCopyWith<$Res> {
  __$CalendarInfoCopyWithImpl(this._self, this._then);

  final _CalendarInfo _self;
  final $Res Function(_CalendarInfo) _then;

/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? name = null,Object? color = freezed,Object? access = null,Object? hidden = null,Object? isDefault = null,Object? subscription = null,Object? ownerName = freezed,}) {
  return _then(_CalendarInfo(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as CalendarRef,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarAccess,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CalendarInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarRefCopyWith<$Res> get ref {
  
  return $CalendarRefCopyWith<$Res>(_self.ref, (value) {
    return _then(_self.copyWith(ref: value));
  });
}
}

// dart format on
