// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'federation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppPassword {

 int get id; String get name; bool get readOnly; DateTime get createdAt; DateTime? get lastUsedAt; String get lastUsedAddress;
/// Create a copy of AppPassword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPasswordCopyWith<AppPassword> get copyWith => _$AppPasswordCopyWithImpl<AppPassword>(this as AppPassword, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppPassword;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPassword&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.lastUsedAddress, _this.lastUsedAddress) || other.lastUsedAddress == _this.lastUsedAddress));
}


@override
int get hashCode {
  final _this = this as AppPassword;
  return Object.hash(runtimeType,_this.id,_this.name,_this.readOnly,_this.createdAt,_this.lastUsedAt,_this.lastUsedAddress);
}

@override
String toString() {
  final _this = this as AppPassword;
  return 'AppPassword(id: ${_this.id}, name: ${_this.name}, readOnly: ${_this.readOnly}, createdAt: ${_this.createdAt}, lastUsedAt: ${_this.lastUsedAt}, lastUsedAddress: ${_this.lastUsedAddress})';
}


}

/// @nodoc
abstract mixin class $AppPasswordCopyWith<$Res>  {
  factory $AppPasswordCopyWith(AppPassword value, $Res Function(AppPassword) _then) = _$AppPasswordCopyWithImpl;
@useResult
$Res call({
 int id, String name, bool readOnly, DateTime createdAt, DateTime? lastUsedAt, String lastUsedAddress
});




}
/// @nodoc
class _$AppPasswordCopyWithImpl<$Res>
    implements $AppPasswordCopyWith<$Res> {
  _$AppPasswordCopyWithImpl(this._self, this._then);

  final AppPassword _self;
  final $Res Function(AppPassword) _then;

/// Create a copy of AppPassword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? readOnly = null,Object? createdAt = null,Object? lastUsedAt = freezed,Object? lastUsedAddress = null,}) {
  return _then(AppPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAddress: null == lastUsedAddress ? _self.lastUsedAddress : lastUsedAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppPassword].
extension AppPasswordPatterns on AppPassword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppPassword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppPassword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppPassword value)  $default,){
final _that = this;
switch (_that) {
case _AppPassword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppPassword value)?  $default,){
final _that = this;
switch (_that) {
case _AppPassword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  bool readOnly,  DateTime createdAt,  DateTime? lastUsedAt,  String lastUsedAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppPassword() when $default != null:
return $default(_that.id,_that.name,_that.readOnly,_that.createdAt,_that.lastUsedAt,_that.lastUsedAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  bool readOnly,  DateTime createdAt,  DateTime? lastUsedAt,  String lastUsedAddress)  $default,) {final _that = this;
switch (_that) {
case _AppPassword():
return $default(_that.id,_that.name,_that.readOnly,_that.createdAt,_that.lastUsedAt,_that.lastUsedAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  bool readOnly,  DateTime createdAt,  DateTime? lastUsedAt,  String lastUsedAddress)?  $default,) {final _that = this;
switch (_that) {
case _AppPassword() when $default != null:
return $default(_that.id,_that.name,_that.readOnly,_that.createdAt,_that.lastUsedAt,_that.lastUsedAddress);case _:
  return null;

}
}

}

/// @nodoc


class _AppPassword implements AppPassword {
  const _AppPassword({required this.id, required this.name, required this.readOnly, required this.createdAt, this.lastUsedAt, this.lastUsedAddress = ""});
  

@override final  int id;
@override final  String name;
@override final  bool readOnly;
@override final  DateTime createdAt;
@override final  DateTime? lastUsedAt;
@override@JsonKey() final  String lastUsedAddress;

/// Create a copy of AppPassword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppPasswordCopyWith<_AppPassword> get copyWith => __$AppPasswordCopyWithImpl<_AppPassword>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppPassword&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.lastUsedAddress, lastUsedAddress) || other.lastUsedAddress == lastUsedAddress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,readOnly,createdAt,lastUsedAt,lastUsedAddress);
}

@override
String toString() {
    return 'AppPassword(id: $id, name: $name, readOnly: $readOnly, createdAt: $createdAt, lastUsedAt: $lastUsedAt, lastUsedAddress: $lastUsedAddress)';
}


}

/// @nodoc
abstract mixin class _$AppPasswordCopyWith<$Res> implements $AppPasswordCopyWith<$Res> {
  factory _$AppPasswordCopyWith(_AppPassword value, $Res Function(_AppPassword) _then) = __$AppPasswordCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, bool readOnly, DateTime createdAt, DateTime? lastUsedAt, String lastUsedAddress
});




}
/// @nodoc
class __$AppPasswordCopyWithImpl<$Res>
    implements _$AppPasswordCopyWith<$Res> {
  __$AppPasswordCopyWithImpl(this._self, this._then);

  final _AppPassword _self;
  final $Res Function(_AppPassword) _then;

/// Create a copy of AppPassword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? readOnly = null,Object? createdAt = null,Object? lastUsedAt = freezed,Object? lastUsedAddress = null,}) {
  return _then(_AppPassword(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUsedAddress: null == lastUsedAddress ? _self.lastUsedAddress : lastUsedAddress // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CreatedAppPassword {

 AppPassword get password; String get token;
/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedAppPasswordCopyWith<CreatedAppPassword> get copyWith => _$CreatedAppPasswordCopyWithImpl<CreatedAppPassword>(this as CreatedAppPassword, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreatedAppPassword;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatedAppPassword&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.token, _this.token) || other.token == _this.token));
}


@override
int get hashCode {
  final _this = this as CreatedAppPassword;
  return Object.hash(runtimeType,_this.password,_this.token);
}

@override
String toString() {
  final _this = this as CreatedAppPassword;
  return 'CreatedAppPassword(password: ${_this.password}, token: ${_this.token})';
}


}

/// @nodoc
abstract mixin class $CreatedAppPasswordCopyWith<$Res>  {
  factory $CreatedAppPasswordCopyWith(CreatedAppPassword value, $Res Function(CreatedAppPassword) _then) = _$CreatedAppPasswordCopyWithImpl;
@useResult
$Res call({
 AppPassword password, String token
});


$AppPasswordCopyWith<$Res> get password;

}
/// @nodoc
class _$CreatedAppPasswordCopyWithImpl<$Res>
    implements $CreatedAppPasswordCopyWith<$Res> {
  _$CreatedAppPasswordCopyWithImpl(this._self, this._then);

  final CreatedAppPassword _self;
  final $Res Function(CreatedAppPassword) _then;

/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,Object? token = null,}) {
  return _then(CreatedAppPassword(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as AppPassword,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppPasswordCopyWith<$Res> get password {
  
  return $AppPasswordCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatedAppPassword].
extension CreatedAppPasswordPatterns on CreatedAppPassword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatedAppPassword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatedAppPassword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatedAppPassword value)  $default,){
final _that = this;
switch (_that) {
case _CreatedAppPassword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatedAppPassword value)?  $default,){
final _that = this;
switch (_that) {
case _CreatedAppPassword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppPassword password,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatedAppPassword() when $default != null:
return $default(_that.password,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppPassword password,  String token)  $default,) {final _that = this;
switch (_that) {
case _CreatedAppPassword():
return $default(_that.password,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppPassword password,  String token)?  $default,) {final _that = this;
switch (_that) {
case _CreatedAppPassword() when $default != null:
return $default(_that.password,_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _CreatedAppPassword implements CreatedAppPassword {
  const _CreatedAppPassword({required this.password, required this.token});
  

@override final  AppPassword password;
@override final  String token;

/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatedAppPasswordCopyWith<_CreatedAppPassword> get copyWith => __$CreatedAppPasswordCopyWithImpl<_CreatedAppPassword>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatedAppPassword&&(identical(other.password, password) || other.password == password)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode {
    return Object.hash(runtimeType,password,token);
}

@override
String toString() {
    return 'CreatedAppPassword(password: $password, token: $token)';
}


}

/// @nodoc
abstract mixin class _$CreatedAppPasswordCopyWith<$Res> implements $CreatedAppPasswordCopyWith<$Res> {
  factory _$CreatedAppPasswordCopyWith(_CreatedAppPassword value, $Res Function(_CreatedAppPassword) _then) = __$CreatedAppPasswordCopyWithImpl;
@override @useResult
$Res call({
 AppPassword password, String token
});


@override $AppPasswordCopyWith<$Res> get password;

}
/// @nodoc
class __$CreatedAppPasswordCopyWithImpl<$Res>
    implements _$CreatedAppPasswordCopyWith<$Res> {
  __$CreatedAppPasswordCopyWithImpl(this._self, this._then);

  final _CreatedAppPassword _self;
  final $Res Function(_CreatedAppPassword) _then;

/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,Object? token = null,}) {
  return _then(_CreatedAppPassword(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as AppPassword,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CreatedAppPassword
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppPasswordCopyWith<$Res> get password {
  
  return $AppPasswordCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}
}

/// @nodoc
mixin _$FederationStatus {

 bool get enabled; bool get configured; String get cloudId;
/// Create a copy of FederationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FederationStatusCopyWith<FederationStatus> get copyWith => _$FederationStatusCopyWithImpl<FederationStatus>(this as FederationStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FederationStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FederationStatus&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.configured, _this.configured) || other.configured == _this.configured)&&(identical(other.cloudId, _this.cloudId) || other.cloudId == _this.cloudId));
}


@override
int get hashCode {
  final _this = this as FederationStatus;
  return Object.hash(runtimeType,_this.enabled,_this.configured,_this.cloudId);
}

@override
String toString() {
  final _this = this as FederationStatus;
  return 'FederationStatus(enabled: ${_this.enabled}, configured: ${_this.configured}, cloudId: ${_this.cloudId})';
}


}

/// @nodoc
abstract mixin class $FederationStatusCopyWith<$Res>  {
  factory $FederationStatusCopyWith(FederationStatus value, $Res Function(FederationStatus) _then) = _$FederationStatusCopyWithImpl;
@useResult
$Res call({
 bool enabled, bool configured, String cloudId
});




}
/// @nodoc
class _$FederationStatusCopyWithImpl<$Res>
    implements $FederationStatusCopyWith<$Res> {
  _$FederationStatusCopyWithImpl(this._self, this._then);

  final FederationStatus _self;
  final $Res Function(FederationStatus) _then;

/// Create a copy of FederationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? configured = null,Object? cloudId = null,}) {
  return _then(FederationStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FederationStatus].
extension FederationStatusPatterns on FederationStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FederationStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FederationStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FederationStatus value)  $default,){
final _that = this;
switch (_that) {
case _FederationStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FederationStatus value)?  $default,){
final _that = this;
switch (_that) {
case _FederationStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  bool configured,  String cloudId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FederationStatus() when $default != null:
return $default(_that.enabled,_that.configured,_that.cloudId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  bool configured,  String cloudId)  $default,) {final _that = this;
switch (_that) {
case _FederationStatus():
return $default(_that.enabled,_that.configured,_that.cloudId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  bool configured,  String cloudId)?  $default,) {final _that = this;
switch (_that) {
case _FederationStatus() when $default != null:
return $default(_that.enabled,_that.configured,_that.cloudId);case _:
  return null;

}
}

}

/// @nodoc


class _FederationStatus implements FederationStatus {
  const _FederationStatus({this.enabled = false, this.configured = false, this.cloudId = ""});
  

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool configured;
@override@JsonKey() final  String cloudId;

/// Create a copy of FederationStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FederationStatusCopyWith<_FederationStatus> get copyWith => __$FederationStatusCopyWithImpl<_FederationStatus>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FederationStatus&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.configured, configured) || other.configured == configured)&&(identical(other.cloudId, cloudId) || other.cloudId == cloudId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,configured,cloudId);
}

@override
String toString() {
    return 'FederationStatus(enabled: $enabled, configured: $configured, cloudId: $cloudId)';
}


}

/// @nodoc
abstract mixin class _$FederationStatusCopyWith<$Res> implements $FederationStatusCopyWith<$Res> {
  factory _$FederationStatusCopyWith(_FederationStatus value, $Res Function(_FederationStatus) _then) = __$FederationStatusCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, bool configured, String cloudId
});




}
/// @nodoc
class __$FederationStatusCopyWithImpl<$Res>
    implements _$FederationStatusCopyWith<$Res> {
  __$FederationStatusCopyWithImpl(this._self, this._then);

  final _FederationStatus _self;
  final $Res Function(_FederationStatus) _then;

/// Create a copy of FederationStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? configured = null,Object? cloudId = null,}) {
  return _then(_FederationStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,configured: null == configured ? _self.configured : configured // ignore: cast_nullable_to_non_nullable
as bool,cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TrustedServer {

 int get id; String get remote; String get provider; String get keyFingerprint; bool get allowPrivateNetwork; bool get verifySenderAddress; bool get signsRequests; String get apiVersion; DateTime get createdAt; DateTime? get discoveredAt;
/// Create a copy of TrustedServer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustedServerCopyWith<TrustedServer> get copyWith => _$TrustedServerCopyWithImpl<TrustedServer>(this as TrustedServer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrustedServer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustedServer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.remote, _this.remote) || other.remote == _this.remote)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.keyFingerprint, _this.keyFingerprint) || other.keyFingerprint == _this.keyFingerprint)&&(identical(other.allowPrivateNetwork, _this.allowPrivateNetwork) || other.allowPrivateNetwork == _this.allowPrivateNetwork)&&(identical(other.verifySenderAddress, _this.verifySenderAddress) || other.verifySenderAddress == _this.verifySenderAddress)&&(identical(other.signsRequests, _this.signsRequests) || other.signsRequests == _this.signsRequests)&&(identical(other.apiVersion, _this.apiVersion) || other.apiVersion == _this.apiVersion)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.discoveredAt, _this.discoveredAt) || other.discoveredAt == _this.discoveredAt));
}


@override
int get hashCode {
  final _this = this as TrustedServer;
  return Object.hash(runtimeType,_this.id,_this.remote,_this.provider,_this.keyFingerprint,_this.allowPrivateNetwork,_this.verifySenderAddress,_this.signsRequests,_this.apiVersion,_this.createdAt,_this.discoveredAt);
}

@override
String toString() {
  final _this = this as TrustedServer;
  return 'TrustedServer(id: ${_this.id}, remote: ${_this.remote}, provider: ${_this.provider}, keyFingerprint: ${_this.keyFingerprint}, allowPrivateNetwork: ${_this.allowPrivateNetwork}, verifySenderAddress: ${_this.verifySenderAddress}, signsRequests: ${_this.signsRequests}, apiVersion: ${_this.apiVersion}, createdAt: ${_this.createdAt}, discoveredAt: ${_this.discoveredAt})';
}


}

/// @nodoc
abstract mixin class $TrustedServerCopyWith<$Res>  {
  factory $TrustedServerCopyWith(TrustedServer value, $Res Function(TrustedServer) _then) = _$TrustedServerCopyWithImpl;
@useResult
$Res call({
 int id, String remote, String provider, String keyFingerprint, bool allowPrivateNetwork, bool verifySenderAddress, bool signsRequests, String apiVersion, DateTime createdAt, DateTime? discoveredAt
});




}
/// @nodoc
class _$TrustedServerCopyWithImpl<$Res>
    implements $TrustedServerCopyWith<$Res> {
  _$TrustedServerCopyWithImpl(this._self, this._then);

  final TrustedServer _self;
  final $Res Function(TrustedServer) _then;

/// Create a copy of TrustedServer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? remote = null,Object? provider = null,Object? keyFingerprint = null,Object? allowPrivateNetwork = null,Object? verifySenderAddress = null,Object? signsRequests = null,Object? apiVersion = null,Object? createdAt = null,Object? discoveredAt = freezed,}) {
  return _then(TrustedServer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,keyFingerprint: null == keyFingerprint ? _self.keyFingerprint : keyFingerprint // ignore: cast_nullable_to_non_nullable
as String,allowPrivateNetwork: null == allowPrivateNetwork ? _self.allowPrivateNetwork : allowPrivateNetwork // ignore: cast_nullable_to_non_nullable
as bool,verifySenderAddress: null == verifySenderAddress ? _self.verifySenderAddress : verifySenderAddress // ignore: cast_nullable_to_non_nullable
as bool,signsRequests: null == signsRequests ? _self.signsRequests : signsRequests // ignore: cast_nullable_to_non_nullable
as bool,apiVersion: null == apiVersion ? _self.apiVersion : apiVersion // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,discoveredAt: freezed == discoveredAt ? _self.discoveredAt : discoveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustedServer].
extension TrustedServerPatterns on TrustedServer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustedServer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustedServer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustedServer value)  $default,){
final _that = this;
switch (_that) {
case _TrustedServer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustedServer value)?  $default,){
final _that = this;
switch (_that) {
case _TrustedServer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String remote,  String provider,  String keyFingerprint,  bool allowPrivateNetwork,  bool verifySenderAddress,  bool signsRequests,  String apiVersion,  DateTime createdAt,  DateTime? discoveredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustedServer() when $default != null:
return $default(_that.id,_that.remote,_that.provider,_that.keyFingerprint,_that.allowPrivateNetwork,_that.verifySenderAddress,_that.signsRequests,_that.apiVersion,_that.createdAt,_that.discoveredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String remote,  String provider,  String keyFingerprint,  bool allowPrivateNetwork,  bool verifySenderAddress,  bool signsRequests,  String apiVersion,  DateTime createdAt,  DateTime? discoveredAt)  $default,) {final _that = this;
switch (_that) {
case _TrustedServer():
return $default(_that.id,_that.remote,_that.provider,_that.keyFingerprint,_that.allowPrivateNetwork,_that.verifySenderAddress,_that.signsRequests,_that.apiVersion,_that.createdAt,_that.discoveredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String remote,  String provider,  String keyFingerprint,  bool allowPrivateNetwork,  bool verifySenderAddress,  bool signsRequests,  String apiVersion,  DateTime createdAt,  DateTime? discoveredAt)?  $default,) {final _that = this;
switch (_that) {
case _TrustedServer() when $default != null:
return $default(_that.id,_that.remote,_that.provider,_that.keyFingerprint,_that.allowPrivateNetwork,_that.verifySenderAddress,_that.signsRequests,_that.apiVersion,_that.createdAt,_that.discoveredAt);case _:
  return null;

}
}

}

/// @nodoc


class _TrustedServer implements TrustedServer {
  const _TrustedServer({required this.id, required this.remote, this.provider = "", this.keyFingerprint = "", this.allowPrivateNetwork = false, this.verifySenderAddress = true, this.signsRequests = false, this.apiVersion = "", required this.createdAt, this.discoveredAt});
  

@override final  int id;
@override final  String remote;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String keyFingerprint;
@override@JsonKey() final  bool allowPrivateNetwork;
@override@JsonKey() final  bool verifySenderAddress;
@override@JsonKey() final  bool signsRequests;
@override@JsonKey() final  String apiVersion;
@override final  DateTime createdAt;
@override final  DateTime? discoveredAt;

/// Create a copy of TrustedServer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustedServerCopyWith<_TrustedServer> get copyWith => __$TrustedServerCopyWithImpl<_TrustedServer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustedServer&&(identical(other.id, id) || other.id == id)&&(identical(other.remote, remote) || other.remote == remote)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.keyFingerprint, keyFingerprint) || other.keyFingerprint == keyFingerprint)&&(identical(other.allowPrivateNetwork, allowPrivateNetwork) || other.allowPrivateNetwork == allowPrivateNetwork)&&(identical(other.verifySenderAddress, verifySenderAddress) || other.verifySenderAddress == verifySenderAddress)&&(identical(other.signsRequests, signsRequests) || other.signsRequests == signsRequests)&&(identical(other.apiVersion, apiVersion) || other.apiVersion == apiVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.discoveredAt, discoveredAt) || other.discoveredAt == discoveredAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,remote,provider,keyFingerprint,allowPrivateNetwork,verifySenderAddress,signsRequests,apiVersion,createdAt,discoveredAt);
}

@override
String toString() {
    return 'TrustedServer(id: $id, remote: $remote, provider: $provider, keyFingerprint: $keyFingerprint, allowPrivateNetwork: $allowPrivateNetwork, verifySenderAddress: $verifySenderAddress, signsRequests: $signsRequests, apiVersion: $apiVersion, createdAt: $createdAt, discoveredAt: $discoveredAt)';
}


}

/// @nodoc
abstract mixin class _$TrustedServerCopyWith<$Res> implements $TrustedServerCopyWith<$Res> {
  factory _$TrustedServerCopyWith(_TrustedServer value, $Res Function(_TrustedServer) _then) = __$TrustedServerCopyWithImpl;
@override @useResult
$Res call({
 int id, String remote, String provider, String keyFingerprint, bool allowPrivateNetwork, bool verifySenderAddress, bool signsRequests, String apiVersion, DateTime createdAt, DateTime? discoveredAt
});




}
/// @nodoc
class __$TrustedServerCopyWithImpl<$Res>
    implements _$TrustedServerCopyWith<$Res> {
  __$TrustedServerCopyWithImpl(this._self, this._then);

  final _TrustedServer _self;
  final $Res Function(_TrustedServer) _then;

/// Create a copy of TrustedServer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? remote = null,Object? provider = null,Object? keyFingerprint = null,Object? allowPrivateNetwork = null,Object? verifySenderAddress = null,Object? signsRequests = null,Object? apiVersion = null,Object? createdAt = null,Object? discoveredAt = freezed,}) {
  return _then(_TrustedServer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,keyFingerprint: null == keyFingerprint ? _self.keyFingerprint : keyFingerprint // ignore: cast_nullable_to_non_nullable
as String,allowPrivateNetwork: null == allowPrivateNetwork ? _self.allowPrivateNetwork : allowPrivateNetwork // ignore: cast_nullable_to_non_nullable
as bool,verifySenderAddress: null == verifySenderAddress ? _self.verifySenderAddress : verifySenderAddress // ignore: cast_nullable_to_non_nullable
as bool,signsRequests: null == signsRequests ? _self.signsRequests : signsRequests // ignore: cast_nullable_to_non_nullable
as bool,apiVersion: null == apiVersion ? _self.apiVersion : apiVersion // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,discoveredAt: freezed == discoveredAt ? _self.discoveredAt : discoveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$FederationInvite {

 int get id; String get token; String get provider; DateTime get expiresAt;
/// Create a copy of FederationInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FederationInviteCopyWith<FederationInvite> get copyWith => _$FederationInviteCopyWithImpl<FederationInvite>(this as FederationInvite, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FederationInvite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FederationInvite&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as FederationInvite;
  return Object.hash(runtimeType,_this.id,_this.token,_this.provider,_this.expiresAt);
}

@override
String toString() {
  final _this = this as FederationInvite;
  return 'FederationInvite(id: ${_this.id}, token: ${_this.token}, provider: ${_this.provider}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $FederationInviteCopyWith<$Res>  {
  factory $FederationInviteCopyWith(FederationInvite value, $Res Function(FederationInvite) _then) = _$FederationInviteCopyWithImpl;
@useResult
$Res call({
 int id, String token, String provider, DateTime expiresAt
});




}
/// @nodoc
class _$FederationInviteCopyWithImpl<$Res>
    implements $FederationInviteCopyWith<$Res> {
  _$FederationInviteCopyWithImpl(this._self, this._then);

  final FederationInvite _self;
  final $Res Function(FederationInvite) _then;

/// Create a copy of FederationInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? token = null,Object? provider = null,Object? expiresAt = null,}) {
  return _then(FederationInvite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FederationInvite].
extension FederationInvitePatterns on FederationInvite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FederationInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FederationInvite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FederationInvite value)  $default,){
final _that = this;
switch (_that) {
case _FederationInvite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FederationInvite value)?  $default,){
final _that = this;
switch (_that) {
case _FederationInvite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String token,  String provider,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FederationInvite() when $default != null:
return $default(_that.id,_that.token,_that.provider,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String token,  String provider,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _FederationInvite():
return $default(_that.id,_that.token,_that.provider,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String token,  String provider,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _FederationInvite() when $default != null:
return $default(_that.id,_that.token,_that.provider,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _FederationInvite implements FederationInvite {
  const _FederationInvite({required this.id, this.token = "", required this.provider, required this.expiresAt});
  

@override final  int id;
@override@JsonKey() final  String token;
@override final  String provider;
@override final  DateTime expiresAt;

/// Create a copy of FederationInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FederationInviteCopyWith<_FederationInvite> get copyWith => __$FederationInviteCopyWithImpl<_FederationInvite>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FederationInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.token, token) || other.token == token)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,token,provider,expiresAt);
}

@override
String toString() {
    return 'FederationInvite(id: $id, token: $token, provider: $provider, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$FederationInviteCopyWith<$Res> implements $FederationInviteCopyWith<$Res> {
  factory _$FederationInviteCopyWith(_FederationInvite value, $Res Function(_FederationInvite) _then) = __$FederationInviteCopyWithImpl;
@override @useResult
$Res call({
 int id, String token, String provider, DateTime expiresAt
});




}
/// @nodoc
class __$FederationInviteCopyWithImpl<$Res>
    implements _$FederationInviteCopyWith<$Res> {
  __$FederationInviteCopyWithImpl(this._self, this._then);

  final _FederationInvite _self;
  final $Res Function(_FederationInvite) _then;

/// Create a copy of FederationInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? token = null,Object? provider = null,Object? expiresAt = null,}) {
  return _then(_FederationInvite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$FederationContact {

 int get id; String get cloudId; String get name; String get email; String get server;
/// Create a copy of FederationContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FederationContactCopyWith<FederationContact> get copyWith => _$FederationContactCopyWithImpl<FederationContact>(this as FederationContact, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FederationContact;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FederationContact&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cloudId, _this.cloudId) || other.cloudId == _this.cloudId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.server, _this.server) || other.server == _this.server));
}


@override
int get hashCode {
  final _this = this as FederationContact;
  return Object.hash(runtimeType,_this.id,_this.cloudId,_this.name,_this.email,_this.server);
}

@override
String toString() {
  final _this = this as FederationContact;
  return 'FederationContact(id: ${_this.id}, cloudId: ${_this.cloudId}, name: ${_this.name}, email: ${_this.email}, server: ${_this.server})';
}


}

/// @nodoc
abstract mixin class $FederationContactCopyWith<$Res>  {
  factory $FederationContactCopyWith(FederationContact value, $Res Function(FederationContact) _then) = _$FederationContactCopyWithImpl;
@useResult
$Res call({
 int id, String cloudId, String name, String email, String server
});




}
/// @nodoc
class _$FederationContactCopyWithImpl<$Res>
    implements $FederationContactCopyWith<$Res> {
  _$FederationContactCopyWithImpl(this._self, this._then);

  final FederationContact _self;
  final $Res Function(FederationContact) _then;

/// Create a copy of FederationContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cloudId = null,Object? name = null,Object? email = null,Object? server = null,}) {
  return _then(FederationContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FederationContact].
extension FederationContactPatterns on FederationContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FederationContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FederationContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FederationContact value)  $default,){
final _that = this;
switch (_that) {
case _FederationContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FederationContact value)?  $default,){
final _that = this;
switch (_that) {
case _FederationContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String cloudId,  String name,  String email,  String server)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FederationContact() when $default != null:
return $default(_that.id,_that.cloudId,_that.name,_that.email,_that.server);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String cloudId,  String name,  String email,  String server)  $default,) {final _that = this;
switch (_that) {
case _FederationContact():
return $default(_that.id,_that.cloudId,_that.name,_that.email,_that.server);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String cloudId,  String name,  String email,  String server)?  $default,) {final _that = this;
switch (_that) {
case _FederationContact() when $default != null:
return $default(_that.id,_that.cloudId,_that.name,_that.email,_that.server);case _:
  return null;

}
}

}

/// @nodoc


class _FederationContact extends FederationContact {
  const _FederationContact({required this.id, required this.cloudId, this.name = "", this.email = "", this.server = ""}): super._();
  

@override final  int id;
@override final  String cloudId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override@JsonKey() final  String server;

/// Create a copy of FederationContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FederationContactCopyWith<_FederationContact> get copyWith => __$FederationContactCopyWithImpl<_FederationContact>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FederationContact&&(identical(other.id, id) || other.id == id)&&(identical(other.cloudId, cloudId) || other.cloudId == cloudId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.server, server) || other.server == server));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,cloudId,name,email,server);
}

@override
String toString() {
    return 'FederationContact(id: $id, cloudId: $cloudId, name: $name, email: $email, server: $server)';
}


}

/// @nodoc
abstract mixin class _$FederationContactCopyWith<$Res> implements $FederationContactCopyWith<$Res> {
  factory _$FederationContactCopyWith(_FederationContact value, $Res Function(_FederationContact) _then) = __$FederationContactCopyWithImpl;
@override @useResult
$Res call({
 int id, String cloudId, String name, String email, String server
});




}
/// @nodoc
class __$FederationContactCopyWithImpl<$Res>
    implements _$FederationContactCopyWith<$Res> {
  __$FederationContactCopyWithImpl(this._self, this._then);

  final _FederationContact _self;
  final $Res Function(_FederationContact) _then;

/// Create a copy of FederationContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cloudId = null,Object? name = null,Object? email = null,Object? server = null,}) {
  return _then(_FederationContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$FederatedShare {

 int get id; SharedFile get file; String get recipient; String get recipientName; SharePermissions get permissions; DateTime? get expiresAt; FederatedShareState get state; bool get available;
/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FederatedShareCopyWith<FederatedShare> get copyWith => _$FederatedShareCopyWithImpl<FederatedShare>(this as FederatedShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FederatedShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FederatedShare&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.recipient, _this.recipient) || other.recipient == _this.recipient)&&(identical(other.recipientName, _this.recipientName) || other.recipientName == _this.recipientName)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.available, _this.available) || other.available == _this.available));
}


@override
int get hashCode {
  final _this = this as FederatedShare;
  return Object.hash(runtimeType,_this.id,_this.file,_this.recipient,_this.recipientName,_this.permissions,_this.expiresAt,_this.state,_this.available);
}

@override
String toString() {
  final _this = this as FederatedShare;
  return 'FederatedShare(id: ${_this.id}, file: ${_this.file}, recipient: ${_this.recipient}, recipientName: ${_this.recipientName}, permissions: ${_this.permissions}, expiresAt: ${_this.expiresAt}, state: ${_this.state}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $FederatedShareCopyWith<$Res>  {
  factory $FederatedShareCopyWith(FederatedShare value, $Res Function(FederatedShare) _then) = _$FederatedShareCopyWithImpl;
@useResult
$Res call({
 int id, SharedFile file, String recipient, String recipientName, SharePermissions permissions, DateTime? expiresAt, FederatedShareState state, bool available
});


$SharedFileCopyWith<$Res> get file;$SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$FederatedShareCopyWithImpl<$Res>
    implements $FederatedShareCopyWith<$Res> {
  _$FederatedShareCopyWithImpl(this._self, this._then);

  final FederatedShare _self;
  final $Res Function(FederatedShare) _then;

/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? file = null,Object? recipient = null,Object? recipientName = null,Object? permissions = null,Object? expiresAt = freezed,Object? state = null,Object? available = null,}) {
  return _then(FederatedShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FederatedShareState,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [FederatedShare].
extension FederatedSharePatterns on FederatedShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FederatedShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FederatedShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FederatedShare value)  $default,){
final _that = this;
switch (_that) {
case _FederatedShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FederatedShare value)?  $default,){
final _that = this;
switch (_that) {
case _FederatedShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  SharedFile file,  String recipient,  String recipientName,  SharePermissions permissions,  DateTime? expiresAt,  FederatedShareState state,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FederatedShare() when $default != null:
return $default(_that.id,_that.file,_that.recipient,_that.recipientName,_that.permissions,_that.expiresAt,_that.state,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  SharedFile file,  String recipient,  String recipientName,  SharePermissions permissions,  DateTime? expiresAt,  FederatedShareState state,  bool available)  $default,) {final _that = this;
switch (_that) {
case _FederatedShare():
return $default(_that.id,_that.file,_that.recipient,_that.recipientName,_that.permissions,_that.expiresAt,_that.state,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  SharedFile file,  String recipient,  String recipientName,  SharePermissions permissions,  DateTime? expiresAt,  FederatedShareState state,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _FederatedShare() when $default != null:
return $default(_that.id,_that.file,_that.recipient,_that.recipientName,_that.permissions,_that.expiresAt,_that.state,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _FederatedShare extends FederatedShare {
  const _FederatedShare({required this.id, required this.file, required this.recipient, this.recipientName = "", required this.permissions, this.expiresAt, required this.state, this.available = true}): super._();
  

@override final  int id;
@override final  SharedFile file;
@override final  String recipient;
@override@JsonKey() final  String recipientName;
@override final  SharePermissions permissions;
@override final  DateTime? expiresAt;
@override final  FederatedShareState state;
@override@JsonKey() final  bool available;

/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FederatedShareCopyWith<_FederatedShare> get copyWith => __$FederatedShareCopyWithImpl<_FederatedShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FederatedShare&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,file,recipient,recipientName,permissions,expiresAt,state,available);
}

@override
String toString() {
    return 'FederatedShare(id: $id, file: $file, recipient: $recipient, recipientName: $recipientName, permissions: $permissions, expiresAt: $expiresAt, state: $state, available: $available)';
}


}

/// @nodoc
abstract mixin class _$FederatedShareCopyWith<$Res> implements $FederatedShareCopyWith<$Res> {
  factory _$FederatedShareCopyWith(_FederatedShare value, $Res Function(_FederatedShare) _then) = __$FederatedShareCopyWithImpl;
@override @useResult
$Res call({
 int id, SharedFile file, String recipient, String recipientName, SharePermissions permissions, DateTime? expiresAt, FederatedShareState state, bool available
});


@override $SharedFileCopyWith<$Res> get file;@override $SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$FederatedShareCopyWithImpl<$Res>
    implements _$FederatedShareCopyWith<$Res> {
  __$FederatedShareCopyWithImpl(this._self, this._then);

  final _FederatedShare _self;
  final $Res Function(_FederatedShare) _then;

/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? file = null,Object? recipient = null,Object? recipientName = null,Object? permissions = null,Object? expiresAt = freezed,Object? state = null,Object? available = null,}) {
  return _then(_FederatedShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FederatedShareState,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of FederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

/// @nodoc
mixin _$IncomingFederatedShare {

 int get id; String get name; String get owner; String get ownerName; String get server; String get provider; bool get isDir; SharePermissions get permissions; FederatedShareState get state;
/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingFederatedShareCopyWith<IncomingFederatedShare> get copyWith => _$IncomingFederatedShareCopyWithImpl<IncomingFederatedShare>(this as IncomingFederatedShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IncomingFederatedShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingFederatedShare&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.state, _this.state) || other.state == _this.state));
}


@override
int get hashCode {
  final _this = this as IncomingFederatedShare;
  return Object.hash(runtimeType,_this.id,_this.name,_this.owner,_this.ownerName,_this.server,_this.provider,_this.isDir,_this.permissions,_this.state);
}

@override
String toString() {
  final _this = this as IncomingFederatedShare;
  return 'IncomingFederatedShare(id: ${_this.id}, name: ${_this.name}, owner: ${_this.owner}, ownerName: ${_this.ownerName}, server: ${_this.server}, provider: ${_this.provider}, isDir: ${_this.isDir}, permissions: ${_this.permissions}, state: ${_this.state})';
}


}

/// @nodoc
abstract mixin class $IncomingFederatedShareCopyWith<$Res>  {
  factory $IncomingFederatedShareCopyWith(IncomingFederatedShare value, $Res Function(IncomingFederatedShare) _then) = _$IncomingFederatedShareCopyWithImpl;
@useResult
$Res call({
 int id, String name, String owner, String ownerName, String server, String provider, bool isDir, SharePermissions permissions, FederatedShareState state
});


$SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$IncomingFederatedShareCopyWithImpl<$Res>
    implements $IncomingFederatedShareCopyWith<$Res> {
  _$IncomingFederatedShareCopyWithImpl(this._self, this._then);

  final IncomingFederatedShare _self;
  final $Res Function(IncomingFederatedShare) _then;

/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? owner = null,Object? ownerName = null,Object? server = null,Object? provider = null,Object? isDir = null,Object? permissions = null,Object? state = null,}) {
  return _then(IncomingFederatedShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FederatedShareState,
  ));
}
/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [IncomingFederatedShare].
extension IncomingFederatedSharePatterns on IncomingFederatedShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomingFederatedShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomingFederatedShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomingFederatedShare value)  $default,){
final _that = this;
switch (_that) {
case _IncomingFederatedShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomingFederatedShare value)?  $default,){
final _that = this;
switch (_that) {
case _IncomingFederatedShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String owner,  String ownerName,  String server,  String provider,  bool isDir,  SharePermissions permissions,  FederatedShareState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomingFederatedShare() when $default != null:
return $default(_that.id,_that.name,_that.owner,_that.ownerName,_that.server,_that.provider,_that.isDir,_that.permissions,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String owner,  String ownerName,  String server,  String provider,  bool isDir,  SharePermissions permissions,  FederatedShareState state)  $default,) {final _that = this;
switch (_that) {
case _IncomingFederatedShare():
return $default(_that.id,_that.name,_that.owner,_that.ownerName,_that.server,_that.provider,_that.isDir,_that.permissions,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String owner,  String ownerName,  String server,  String provider,  bool isDir,  SharePermissions permissions,  FederatedShareState state)?  $default,) {final _that = this;
switch (_that) {
case _IncomingFederatedShare() when $default != null:
return $default(_that.id,_that.name,_that.owner,_that.ownerName,_that.server,_that.provider,_that.isDir,_that.permissions,_that.state);case _:
  return null;

}
}

}

/// @nodoc


class _IncomingFederatedShare extends IncomingFederatedShare {
  const _IncomingFederatedShare({required this.id, required this.name, required this.owner, this.ownerName = "", this.server = "", this.provider = "", this.isDir = true, required this.permissions, required this.state}): super._();
  

@override final  int id;
@override final  String name;
@override final  String owner;
@override@JsonKey() final  String ownerName;
@override@JsonKey() final  String server;
@override@JsonKey() final  String provider;
@override@JsonKey() final  bool isDir;
@override final  SharePermissions permissions;
@override final  FederatedShareState state;

/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomingFederatedShareCopyWith<_IncomingFederatedShare> get copyWith => __$IncomingFederatedShareCopyWithImpl<_IncomingFederatedShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomingFederatedShare&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.server, server) || other.server == server)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.state, state) || other.state == state));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,owner,ownerName,server,provider,isDir,permissions,state);
}

@override
String toString() {
    return 'IncomingFederatedShare(id: $id, name: $name, owner: $owner, ownerName: $ownerName, server: $server, provider: $provider, isDir: $isDir, permissions: $permissions, state: $state)';
}


}

/// @nodoc
abstract mixin class _$IncomingFederatedShareCopyWith<$Res> implements $IncomingFederatedShareCopyWith<$Res> {
  factory _$IncomingFederatedShareCopyWith(_IncomingFederatedShare value, $Res Function(_IncomingFederatedShare) _then) = __$IncomingFederatedShareCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String owner, String ownerName, String server, String provider, bool isDir, SharePermissions permissions, FederatedShareState state
});


@override $SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$IncomingFederatedShareCopyWithImpl<$Res>
    implements _$IncomingFederatedShareCopyWith<$Res> {
  __$IncomingFederatedShareCopyWithImpl(this._self, this._then);

  final _IncomingFederatedShare _self;
  final $Res Function(_IncomingFederatedShare) _then;

/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? owner = null,Object? ownerName = null,Object? server = null,Object? provider = null,Object? isDir = null,Object? permissions = null,Object? state = null,}) {
  return _then(_IncomingFederatedShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FederatedShareState,
  ));
}

/// Create a copy of IncomingFederatedShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

// dart format on
