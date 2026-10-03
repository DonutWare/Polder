// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_requests.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateUserRequest {

 String get username; String get password; UserRole get role; int get quotaBytes;
/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateUserRequestCopyWith<CreateUserRequest> get copyWith => _$CreateUserRequestCopyWithImpl<CreateUserRequest>(this as CreateUserRequest, _$identity);

  /// Serializes this CreateUserRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateUserRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateUserRequest&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.quotaBytes, _this.quotaBytes) || other.quotaBytes == _this.quotaBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateUserRequest;
  return Object.hash(runtimeType,_this.username,_this.password,_this.role,_this.quotaBytes);
}

@override
String toString() {
  final _this = this as CreateUserRequest;
  return 'CreateUserRequest(username: ${_this.username}, password: ${_this.password}, role: ${_this.role}, quotaBytes: ${_this.quotaBytes})';
}


}

/// @nodoc
abstract mixin class $CreateUserRequestCopyWith<$Res>  {
  factory $CreateUserRequestCopyWith(CreateUserRequest value, $Res Function(CreateUserRequest) _then) = _$CreateUserRequestCopyWithImpl;
@useResult
$Res call({
 String username, String password, UserRole role, int quotaBytes
});




}
/// @nodoc
class _$CreateUserRequestCopyWithImpl<$Res>
    implements $CreateUserRequestCopyWith<$Res> {
  _$CreateUserRequestCopyWithImpl(this._self, this._then);

  final CreateUserRequest _self;
  final $Res Function(CreateUserRequest) _then;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,Object? role = null,Object? quotaBytes = null,}) {
  return _then(CreateUserRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaBytes: null == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateUserRequest].
extension CreateUserRequestPatterns on CreateUserRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateUserRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateUserRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateUserRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateUserRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password,  UserRole role,  int quotaBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
return $default(_that.username,_that.password,_that.role,_that.quotaBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password,  UserRole role,  int quotaBytes)  $default,) {final _that = this;
switch (_that) {
case _CreateUserRequest():
return $default(_that.username,_that.password,_that.role,_that.quotaBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password,  UserRole role,  int quotaBytes)?  $default,) {final _that = this;
switch (_that) {
case _CreateUserRequest() when $default != null:
return $default(_that.username,_that.password,_that.role,_that.quotaBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateUserRequest implements CreateUserRequest {
  const _CreateUserRequest({required this.username, required this.password, required this.role, required this.quotaBytes});
  factory _CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);

@override final  String username;
@override final  String password;
@override final  UserRole role;
@override final  int quotaBytes;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateUserRequestCopyWith<_CreateUserRequest> get copyWith => __$CreateUserRequestCopyWithImpl<_CreateUserRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateUserRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateUserRequest&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.quotaBytes, quotaBytes) || other.quotaBytes == quotaBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,username,password,role,quotaBytes);
}

@override
String toString() {
    return 'CreateUserRequest(username: $username, password: $password, role: $role, quotaBytes: $quotaBytes)';
}


}

/// @nodoc
abstract mixin class _$CreateUserRequestCopyWith<$Res> implements $CreateUserRequestCopyWith<$Res> {
  factory _$CreateUserRequestCopyWith(_CreateUserRequest value, $Res Function(_CreateUserRequest) _then) = __$CreateUserRequestCopyWithImpl;
@override @useResult
$Res call({
 String username, String password, UserRole role, int quotaBytes
});




}
/// @nodoc
class __$CreateUserRequestCopyWithImpl<$Res>
    implements _$CreateUserRequestCopyWith<$Res> {
  __$CreateUserRequestCopyWithImpl(this._self, this._then);

  final _CreateUserRequest _self;
  final $Res Function(_CreateUserRequest) _then;

/// Create a copy of CreateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,Object? role = null,Object? quotaBytes = null,}) {
  return _then(_CreateUserRequest(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaBytes: null == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UpdateUserRequest {

 String? get password; UserRole? get role; int? get quotaBytes; bool? get disabled;
/// Create a copy of UpdateUserRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserRequestCopyWith<UpdateUserRequest> get copyWith => _$UpdateUserRequestCopyWithImpl<UpdateUserRequest>(this as UpdateUserRequest, _$identity);

  /// Serializes this UpdateUserRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateUserRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserRequest&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.quotaBytes, _this.quotaBytes) || other.quotaBytes == _this.quotaBytes)&&(identical(other.disabled, _this.disabled) || other.disabled == _this.disabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateUserRequest;
  return Object.hash(runtimeType,_this.password,_this.role,_this.quotaBytes,_this.disabled);
}

@override
String toString() {
  final _this = this as UpdateUserRequest;
  return 'UpdateUserRequest(password: ${_this.password}, role: ${_this.role}, quotaBytes: ${_this.quotaBytes}, disabled: ${_this.disabled})';
}


}

/// @nodoc
abstract mixin class $UpdateUserRequestCopyWith<$Res>  {
  factory $UpdateUserRequestCopyWith(UpdateUserRequest value, $Res Function(UpdateUserRequest) _then) = _$UpdateUserRequestCopyWithImpl;
@useResult
$Res call({
 String? password, UserRole? role, int? quotaBytes, bool? disabled
});




}
/// @nodoc
class _$UpdateUserRequestCopyWithImpl<$Res>
    implements $UpdateUserRequestCopyWith<$Res> {
  _$UpdateUserRequestCopyWithImpl(this._self, this._then);

  final UpdateUserRequest _self;
  final $Res Function(UpdateUserRequest) _then;

/// Create a copy of UpdateUserRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = freezed,Object? role = freezed,Object? quotaBytes = freezed,Object? disabled = freezed,}) {
  return _then(UpdateUserRequest(
password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,quotaBytes: freezed == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int?,disabled: freezed == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserRequest].
extension UpdateUserRequestPatterns on UpdateUserRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? password,  UserRole? role,  int? quotaBytes,  bool? disabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserRequest() when $default != null:
return $default(_that.password,_that.role,_that.quotaBytes,_that.disabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? password,  UserRole? role,  int? quotaBytes,  bool? disabled)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserRequest():
return $default(_that.password,_that.role,_that.quotaBytes,_that.disabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? password,  UserRole? role,  int? quotaBytes,  bool? disabled)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserRequest() when $default != null:
return $default(_that.password,_that.role,_that.quotaBytes,_that.disabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateUserRequest extends UpdateUserRequest {
  const _UpdateUserRequest({this.password, this.role, this.quotaBytes, this.disabled}): super._();
  factory _UpdateUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateUserRequestFromJson(json);

@override final  String? password;
@override final  UserRole? role;
@override final  int? quotaBytes;
@override final  bool? disabled;

/// Create a copy of UpdateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserRequestCopyWith<_UpdateUserRequest> get copyWith => __$UpdateUserRequestCopyWithImpl<_UpdateUserRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserRequest&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.quotaBytes, quotaBytes) || other.quotaBytes == quotaBytes)&&(identical(other.disabled, disabled) || other.disabled == disabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,password,role,quotaBytes,disabled);
}

@override
String toString() {
    return 'UpdateUserRequest(password: $password, role: $role, quotaBytes: $quotaBytes, disabled: $disabled)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserRequestCopyWith<$Res> implements $UpdateUserRequestCopyWith<$Res> {
  factory _$UpdateUserRequestCopyWith(_UpdateUserRequest value, $Res Function(_UpdateUserRequest) _then) = __$UpdateUserRequestCopyWithImpl;
@override @useResult
$Res call({
 String? password, UserRole? role, int? quotaBytes, bool? disabled
});




}
/// @nodoc
class __$UpdateUserRequestCopyWithImpl<$Res>
    implements _$UpdateUserRequestCopyWith<$Res> {
  __$UpdateUserRequestCopyWithImpl(this._self, this._then);

  final _UpdateUserRequest _self;
  final $Res Function(_UpdateUserRequest) _then;

/// Create a copy of UpdateUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = freezed,Object? role = freezed,Object? quotaBytes = freezed,Object? disabled = freezed,}) {
  return _then(_UpdateUserRequest(
password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,quotaBytes: freezed == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int?,disabled: freezed == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
