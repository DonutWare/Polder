// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserForm {

 User? get original; String get username; String get password; String get passwordConfirmation; UserRole get role; String get quotaAmount; QuotaUnit get quotaUnit; bool get disabled; bool get saving;
/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFormCopyWith<UserForm> get copyWith => _$UserFormCopyWithImpl<UserForm>(this as UserForm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserForm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserForm&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.passwordConfirmation, _this.passwordConfirmation) || other.passwordConfirmation == _this.passwordConfirmation)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.quotaAmount, _this.quotaAmount) || other.quotaAmount == _this.quotaAmount)&&(identical(other.quotaUnit, _this.quotaUnit) || other.quotaUnit == _this.quotaUnit)&&(identical(other.disabled, _this.disabled) || other.disabled == _this.disabled)&&(identical(other.saving, _this.saving) || other.saving == _this.saving));
}


@override
int get hashCode {
  final _this = this as UserForm;
  return Object.hash(runtimeType,_this.original,_this.username,_this.password,_this.passwordConfirmation,_this.role,_this.quotaAmount,_this.quotaUnit,_this.disabled,_this.saving);
}

@override
String toString() {
  final _this = this as UserForm;
  return 'UserForm(original: ${_this.original}, username: ${_this.username}, password: ${_this.password}, passwordConfirmation: ${_this.passwordConfirmation}, role: ${_this.role}, quotaAmount: ${_this.quotaAmount}, quotaUnit: ${_this.quotaUnit}, disabled: ${_this.disabled}, saving: ${_this.saving})';
}


}

/// @nodoc
abstract mixin class $UserFormCopyWith<$Res>  {
  factory $UserFormCopyWith(UserForm value, $Res Function(UserForm) _then) = _$UserFormCopyWithImpl;
@useResult
$Res call({
 User? original, String username, String password, String passwordConfirmation, UserRole role, String quotaAmount, QuotaUnit quotaUnit, bool disabled, bool saving
});


$UserCopyWith<$Res>? get original;

}
/// @nodoc
class _$UserFormCopyWithImpl<$Res>
    implements $UserFormCopyWith<$Res> {
  _$UserFormCopyWithImpl(this._self, this._then);

  final UserForm _self;
  final $Res Function(UserForm) _then;

/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? original = freezed,Object? username = null,Object? password = null,Object? passwordConfirmation = null,Object? role = null,Object? quotaAmount = null,Object? quotaUnit = null,Object? disabled = null,Object? saving = null,}) {
  return _then(UserForm(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as User?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaAmount: null == quotaAmount ? _self.quotaAmount : quotaAmount // ignore: cast_nullable_to_non_nullable
as String,quotaUnit: null == quotaUnit ? _self.quotaUnit : quotaUnit // ignore: cast_nullable_to_non_nullable
as QuotaUnit,disabled: null == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserForm].
extension UserFormPatterns on UserForm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserForm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserForm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserForm value)  $default,){
final _that = this;
switch (_that) {
case _UserForm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserForm value)?  $default,){
final _that = this;
switch (_that) {
case _UserForm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User? original,  String username,  String password,  String passwordConfirmation,  UserRole role,  String quotaAmount,  QuotaUnit quotaUnit,  bool disabled,  bool saving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserForm() when $default != null:
return $default(_that.original,_that.username,_that.password,_that.passwordConfirmation,_that.role,_that.quotaAmount,_that.quotaUnit,_that.disabled,_that.saving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User? original,  String username,  String password,  String passwordConfirmation,  UserRole role,  String quotaAmount,  QuotaUnit quotaUnit,  bool disabled,  bool saving)  $default,) {final _that = this;
switch (_that) {
case _UserForm():
return $default(_that.original,_that.username,_that.password,_that.passwordConfirmation,_that.role,_that.quotaAmount,_that.quotaUnit,_that.disabled,_that.saving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User? original,  String username,  String password,  String passwordConfirmation,  UserRole role,  String quotaAmount,  QuotaUnit quotaUnit,  bool disabled,  bool saving)?  $default,) {final _that = this;
switch (_that) {
case _UserForm() when $default != null:
return $default(_that.original,_that.username,_that.password,_that.passwordConfirmation,_that.role,_that.quotaAmount,_that.quotaUnit,_that.disabled,_that.saving);case _:
  return null;

}
}

}

/// @nodoc


class _UserForm extends UserForm {
  const _UserForm({this.original, this.username = "", this.password = "", this.passwordConfirmation = "", this.role = UserRole.user, this.quotaAmount = "0", this.quotaUnit = QuotaUnit.gb, this.disabled = false, this.saving = false}): super._();
  

@override final  User? original;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey() final  String passwordConfirmation;
@override@JsonKey() final  UserRole role;
@override@JsonKey() final  String quotaAmount;
@override@JsonKey() final  QuotaUnit quotaUnit;
@override@JsonKey() final  bool disabled;
@override@JsonKey() final  bool saving;

/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFormCopyWith<_UserForm> get copyWith => __$UserFormCopyWithImpl<_UserForm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserForm&&(identical(other.original, original) || other.original == original)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation)&&(identical(other.role, role) || other.role == role)&&(identical(other.quotaAmount, quotaAmount) || other.quotaAmount == quotaAmount)&&(identical(other.quotaUnit, quotaUnit) || other.quotaUnit == quotaUnit)&&(identical(other.disabled, disabled) || other.disabled == disabled)&&(identical(other.saving, saving) || other.saving == saving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,original,username,password,passwordConfirmation,role,quotaAmount,quotaUnit,disabled,saving);
}

@override
String toString() {
    return 'UserForm(original: $original, username: $username, password: $password, passwordConfirmation: $passwordConfirmation, role: $role, quotaAmount: $quotaAmount, quotaUnit: $quotaUnit, disabled: $disabled, saving: $saving)';
}


}

/// @nodoc
abstract mixin class _$UserFormCopyWith<$Res> implements $UserFormCopyWith<$Res> {
  factory _$UserFormCopyWith(_UserForm value, $Res Function(_UserForm) _then) = __$UserFormCopyWithImpl;
@override @useResult
$Res call({
 User? original, String username, String password, String passwordConfirmation, UserRole role, String quotaAmount, QuotaUnit quotaUnit, bool disabled, bool saving
});


@override $UserCopyWith<$Res>? get original;

}
/// @nodoc
class __$UserFormCopyWithImpl<$Res>
    implements _$UserFormCopyWith<$Res> {
  __$UserFormCopyWithImpl(this._self, this._then);

  final _UserForm _self;
  final $Res Function(_UserForm) _then;

/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? original = freezed,Object? username = null,Object? password = null,Object? passwordConfirmation = null,Object? role = null,Object? quotaAmount = null,Object? quotaUnit = null,Object? disabled = null,Object? saving = null,}) {
  return _then(_UserForm(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as User?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,quotaAmount: null == quotaAmount ? _self.quotaAmount : quotaAmount // ignore: cast_nullable_to_non_nullable
as String,quotaUnit: null == quotaUnit ? _self.quotaUnit : quotaUnit // ignore: cast_nullable_to_non_nullable
as QuotaUnit,disabled: null == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserForm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
