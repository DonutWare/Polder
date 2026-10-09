// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get firstName; String get lastName; String get displayName; String get email; int? get age; String get address;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.address, _this.address) || other.address == _this.address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.firstName,_this.lastName,_this.displayName,_this.email,_this.age,_this.address);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(firstName: ${_this.firstName}, lastName: ${_this.lastName}, displayName: ${_this.displayName}, email: ${_this.email}, age: ${_this.age}, address: ${_this.address})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, String displayName, String email, int? age, String address
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? displayName = null,Object? email = null,Object? age = freezed,Object? address = null,}) {
  return _then(UserProfile(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String displayName,  String email,  int? age,  String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.firstName,_that.lastName,_that.displayName,_that.email,_that.age,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String displayName,  String email,  int? age,  String address)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.firstName,_that.lastName,_that.displayName,_that.email,_that.age,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String lastName,  String displayName,  String email,  int? age,  String address)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.firstName,_that.lastName,_that.displayName,_that.email,_that.age,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({this.firstName = "", this.lastName = "", this.displayName = "", this.email = "", this.age, this.address = ""});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String email;
@override final  int? age;
@override@JsonKey() final  String address;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.age, age) || other.age == age)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,firstName,lastName,displayName,email,age,address);
}

@override
String toString() {
    return 'UserProfile(firstName: $firstName, lastName: $lastName, displayName: $displayName, email: $email, age: $age, address: $address)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String lastName, String displayName, String email, int? age, String address
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? displayName = null,Object? email = null,Object? age = freezed,Object? address = null,}) {
  return _then(_UserProfile(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$User {

 int get id; String get username;@JsonKey(unknownEnumValue: UserRole.user) UserRole get role; int get quotaBytes; int get usedBytes; int get historyBytes; bool get disabled; DateTime? get createdAt; UserProfile get profile; ServerImage? get avatar; ThemeMode? get theme;@ColorConverter() Color? get accent;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.quotaBytes, _this.quotaBytes) || other.quotaBytes == _this.quotaBytes)&&(identical(other.usedBytes, _this.usedBytes) || other.usedBytes == _this.usedBytes)&&(identical(other.historyBytes, _this.historyBytes) || other.historyBytes == _this.historyBytes)&&(identical(other.disabled, _this.disabled) || other.disabled == _this.disabled)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.accent, _this.accent) || other.accent == _this.accent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.username,_this.role,_this.quotaBytes,_this.usedBytes,_this.historyBytes,_this.disabled,_this.createdAt,_this.profile,_this.avatar,_this.theme,_this.accent);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, username: ${_this.username}, role: ${_this.role}, quotaBytes: ${_this.quotaBytes}, usedBytes: ${_this.usedBytes}, historyBytes: ${_this.historyBytes}, disabled: ${_this.disabled}, createdAt: ${_this.createdAt}, profile: ${_this.profile}, avatar: ${_this.avatar}, theme: ${_this.theme}, accent: ${_this.accent})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int id, String username,@JsonKey(unknownEnumValue: UserRole.user) UserRole role, int quotaBytes, int usedBytes, int historyBytes, bool disabled, DateTime? createdAt, UserProfile profile, ServerImage? avatar, ThemeMode? theme,@ColorConverter() Color? accent
});


$UserProfileCopyWith<$Res> get profile;$ServerImageCopyWith<$Res>? get avatar;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? role = null,Object? quotaBytes = null,Object? usedBytes = null,Object? historyBytes = null,Object? disabled = null,Object? createdAt = freezed,Object? profile = null,Object? avatar = freezed,Object? theme = freezed,Object? accent = freezed,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaBytes: null == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int,usedBytes: null == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int,historyBytes: null == historyBytes ? _self.historyBytes : historyBytes // ignore: cast_nullable_to_non_nullable
as int,disabled: null == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ServerImage?,theme: freezed == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeMode?,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get avatar {
    if (_self.avatar == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.avatar!, (value) {
    return _then(_self.copyWith(avatar: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(unknownEnumValue: UserRole.user)  UserRole role,  int quotaBytes,  int usedBytes,  int historyBytes,  bool disabled,  DateTime? createdAt,  UserProfile profile,  ServerImage? avatar,  ThemeMode? theme, @ColorConverter()  Color? accent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.quotaBytes,_that.usedBytes,_that.historyBytes,_that.disabled,_that.createdAt,_that.profile,_that.avatar,_that.theme,_that.accent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(unknownEnumValue: UserRole.user)  UserRole role,  int quotaBytes,  int usedBytes,  int historyBytes,  bool disabled,  DateTime? createdAt,  UserProfile profile,  ServerImage? avatar,  ThemeMode? theme, @ColorConverter()  Color? accent)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.role,_that.quotaBytes,_that.usedBytes,_that.historyBytes,_that.disabled,_that.createdAt,_that.profile,_that.avatar,_that.theme,_that.accent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username, @JsonKey(unknownEnumValue: UserRole.user)  UserRole role,  int quotaBytes,  int usedBytes,  int historyBytes,  bool disabled,  DateTime? createdAt,  UserProfile profile,  ServerImage? avatar,  ThemeMode? theme, @ColorConverter()  Color? accent)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.quotaBytes,_that.usedBytes,_that.historyBytes,_that.disabled,_that.createdAt,_that.profile,_that.avatar,_that.theme,_that.accent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.id, required this.username, @JsonKey(unknownEnumValue: UserRole.user) this.role = UserRole.user, this.quotaBytes = 0, this.usedBytes = 0, this.historyBytes = 0, this.disabled = false, this.createdAt, this.profile = const UserProfile(), this.avatar, this.theme, @ColorConverter() this.accent}): super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  int id;
@override final  String username;
@override@JsonKey(unknownEnumValue: UserRole.user) final  UserRole role;
@override@JsonKey() final  int quotaBytes;
@override@JsonKey() final  int usedBytes;
@override@JsonKey() final  int historyBytes;
@override@JsonKey() final  bool disabled;
@override final  DateTime? createdAt;
@override@JsonKey() final  UserProfile profile;
@override final  ServerImage? avatar;
@override final  ThemeMode? theme;
@override@ColorConverter() final  Color? accent;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.quotaBytes, quotaBytes) || other.quotaBytes == quotaBytes)&&(identical(other.usedBytes, usedBytes) || other.usedBytes == usedBytes)&&(identical(other.historyBytes, historyBytes) || other.historyBytes == historyBytes)&&(identical(other.disabled, disabled) || other.disabled == disabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.accent, accent) || other.accent == accent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,role,quotaBytes,usedBytes,historyBytes,disabled,createdAt,profile,avatar,theme,accent);
}

@override
String toString() {
    return 'User(id: $id, username: $username, role: $role, quotaBytes: $quotaBytes, usedBytes: $usedBytes, historyBytes: $historyBytes, disabled: $disabled, createdAt: $createdAt, profile: $profile, avatar: $avatar, theme: $theme, accent: $accent)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int id, String username,@JsonKey(unknownEnumValue: UserRole.user) UserRole role, int quotaBytes, int usedBytes, int historyBytes, bool disabled, DateTime? createdAt, UserProfile profile, ServerImage? avatar, ThemeMode? theme,@ColorConverter() Color? accent
});


@override $UserProfileCopyWith<$Res> get profile;@override $ServerImageCopyWith<$Res>? get avatar;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? role = null,Object? quotaBytes = null,Object? usedBytes = null,Object? historyBytes = null,Object? disabled = null,Object? createdAt = freezed,Object? profile = null,Object? avatar = freezed,Object? theme = freezed,Object? accent = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaBytes: null == quotaBytes ? _self.quotaBytes : quotaBytes // ignore: cast_nullable_to_non_nullable
as int,usedBytes: null == usedBytes ? _self.usedBytes : usedBytes // ignore: cast_nullable_to_non_nullable
as int,historyBytes: null == historyBytes ? _self.historyBytes : historyBytes // ignore: cast_nullable_to_non_nullable
as int,disabled: null == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ServerImage?,theme: freezed == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeMode?,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get avatar {
    if (_self.avatar == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.avatar!, (value) {
    return _then(_self.copyWith(avatar: value));
  });
}
}

// dart format on
