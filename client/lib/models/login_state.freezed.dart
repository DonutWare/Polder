// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 LoginStep get step; String get serverUrl; String get username; String get password; String get passwordConfirmation; bool get loading; bool get completed;/// The server is the one this web client was served from, so it can't be changed.
 bool get serverLocked;/// Checking whether the page's own origin is a Polder server, before showing any form.
 bool get probingHostedServer; LoginFailure? get failure; Object? get failureCause;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.passwordConfirmation, _this.passwordConfirmation) || other.passwordConfirmation == _this.passwordConfirmation)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.serverLocked, _this.serverLocked) || other.serverLocked == _this.serverLocked)&&(identical(other.probingHostedServer, _this.probingHostedServer) || other.probingHostedServer == _this.probingHostedServer)&&(identical(other.failure, _this.failure) || other.failure == _this.failure)&&const DeepCollectionEquality().equals(other.failureCause, _this.failureCause));
}


@override
int get hashCode {
  final _this = this as LoginState;
  return Object.hash(runtimeType,_this.step,_this.serverUrl,_this.username,_this.password,_this.passwordConfirmation,_this.loading,_this.completed,_this.serverLocked,_this.probingHostedServer,_this.failure,const DeepCollectionEquality().hash(_this.failureCause));
}

@override
String toString() {
  final _this = this as LoginState;
  return 'LoginState(step: ${_this.step}, serverUrl: ${_this.serverUrl}, username: ${_this.username}, password: ${_this.password}, passwordConfirmation: ${_this.passwordConfirmation}, loading: ${_this.loading}, completed: ${_this.completed}, serverLocked: ${_this.serverLocked}, probingHostedServer: ${_this.probingHostedServer}, failure: ${_this.failure}, failureCause: ${_this.failureCause})';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 LoginStep step, String serverUrl, String username, String password, String passwordConfirmation, bool loading, bool completed, bool serverLocked, bool probingHostedServer, LoginFailure? failure, Object? failureCause
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? serverUrl = null,Object? username = null,Object? password = null,Object? passwordConfirmation = null,Object? loading = null,Object? completed = null,Object? serverLocked = null,Object? probingHostedServer = null,Object? failure = freezed,Object? failureCause = freezed,}) {
  return _then(LoginState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as LoginStep,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,serverLocked: null == serverLocked ? _self.serverLocked : serverLocked // ignore: cast_nullable_to_non_nullable
as bool,probingHostedServer: null == probingHostedServer ? _self.probingHostedServer : probingHostedServer // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as LoginFailure?,failureCause: freezed == failureCause ? _self.failureCause : failureCause ,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoginStep step,  String serverUrl,  String username,  String password,  String passwordConfirmation,  bool loading,  bool completed,  bool serverLocked,  bool probingHostedServer,  LoginFailure? failure,  Object? failureCause)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.step,_that.serverUrl,_that.username,_that.password,_that.passwordConfirmation,_that.loading,_that.completed,_that.serverLocked,_that.probingHostedServer,_that.failure,_that.failureCause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoginStep step,  String serverUrl,  String username,  String password,  String passwordConfirmation,  bool loading,  bool completed,  bool serverLocked,  bool probingHostedServer,  LoginFailure? failure,  Object? failureCause)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.step,_that.serverUrl,_that.username,_that.password,_that.passwordConfirmation,_that.loading,_that.completed,_that.serverLocked,_that.probingHostedServer,_that.failure,_that.failureCause);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoginStep step,  String serverUrl,  String username,  String password,  String passwordConfirmation,  bool loading,  bool completed,  bool serverLocked,  bool probingHostedServer,  LoginFailure? failure,  Object? failureCause)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.step,_that.serverUrl,_that.username,_that.password,_that.passwordConfirmation,_that.loading,_that.completed,_that.serverLocked,_that.probingHostedServer,_that.failure,_that.failureCause);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState extends LoginState {
  const _LoginState({this.step = LoginStep.server, this.serverUrl = "", this.username = "", this.password = "", this.passwordConfirmation = "", this.loading = false, this.completed = false, this.serverLocked = false, this.probingHostedServer = false, this.failure, this.failureCause}): super._();
  

@override@JsonKey() final  LoginStep step;
@override@JsonKey() final  String serverUrl;
@override@JsonKey() final  String username;
@override@JsonKey() final  String password;
@override@JsonKey() final  String passwordConfirmation;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool completed;
/// The server is the one this web client was served from, so it can't be changed.
@override@JsonKey() final  bool serverLocked;
/// Checking whether the page's own origin is a Polder server, before showing any form.
@override@JsonKey() final  bool probingHostedServer;
@override final  LoginFailure? failure;
@override final  Object? failureCause;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.step, step) || other.step == step)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.passwordConfirmation, passwordConfirmation) || other.passwordConfirmation == passwordConfirmation)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.serverLocked, serverLocked) || other.serverLocked == serverLocked)&&(identical(other.probingHostedServer, probingHostedServer) || other.probingHostedServer == probingHostedServer)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other.failureCause, failureCause));
}


@override
int get hashCode {
    return Object.hash(runtimeType,step,serverUrl,username,password,passwordConfirmation,loading,completed,serverLocked,probingHostedServer,failure,const DeepCollectionEquality().hash(failureCause));
}

@override
String toString() {
    return 'LoginState(step: $step, serverUrl: $serverUrl, username: $username, password: $password, passwordConfirmation: $passwordConfirmation, loading: $loading, completed: $completed, serverLocked: $serverLocked, probingHostedServer: $probingHostedServer, failure: $failure, failureCause: $failureCause)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 LoginStep step, String serverUrl, String username, String password, String passwordConfirmation, bool loading, bool completed, bool serverLocked, bool probingHostedServer, LoginFailure? failure, Object? failureCause
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? serverUrl = null,Object? username = null,Object? password = null,Object? passwordConfirmation = null,Object? loading = null,Object? completed = null,Object? serverLocked = null,Object? probingHostedServer = null,Object? failure = freezed,Object? failureCause = freezed,}) {
  return _then(_LoginState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as LoginStep,serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,passwordConfirmation: null == passwordConfirmation ? _self.passwordConfirmation : passwordConfirmation // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,serverLocked: null == serverLocked ? _self.serverLocked : serverLocked // ignore: cast_nullable_to_non_nullable
as bool,probingHostedServer: null == probingHostedServer ? _self.probingHostedServer : probingHostedServer // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as LoginFailure?,failureCause: freezed == failureCause ? _self.failureCause : failureCause ,
  ));
}


}

// dart format on
