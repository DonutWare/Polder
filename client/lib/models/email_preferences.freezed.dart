// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmailPreferences {

 bool get security; bool get quota; bool get shares; bool get hasEmail; bool get enabled;
/// Create a copy of EmailPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailPreferencesCopyWith<EmailPreferences> get copyWith => _$EmailPreferencesCopyWithImpl<EmailPreferences>(this as EmailPreferences, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EmailPreferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailPreferences&&(identical(other.security, _this.security) || other.security == _this.security)&&(identical(other.quota, _this.quota) || other.quota == _this.quota)&&(identical(other.shares, _this.shares) || other.shares == _this.shares)&&(identical(other.hasEmail, _this.hasEmail) || other.hasEmail == _this.hasEmail)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}


@override
int get hashCode {
  final _this = this as EmailPreferences;
  return Object.hash(runtimeType,_this.security,_this.quota,_this.shares,_this.hasEmail,_this.enabled);
}

@override
String toString() {
  final _this = this as EmailPreferences;
  return 'EmailPreferences(security: ${_this.security}, quota: ${_this.quota}, shares: ${_this.shares}, hasEmail: ${_this.hasEmail}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $EmailPreferencesCopyWith<$Res>  {
  factory $EmailPreferencesCopyWith(EmailPreferences value, $Res Function(EmailPreferences) _then) = _$EmailPreferencesCopyWithImpl;
@useResult
$Res call({
 bool security, bool quota, bool shares, bool hasEmail, bool enabled
});




}
/// @nodoc
class _$EmailPreferencesCopyWithImpl<$Res>
    implements $EmailPreferencesCopyWith<$Res> {
  _$EmailPreferencesCopyWithImpl(this._self, this._then);

  final EmailPreferences _self;
  final $Res Function(EmailPreferences) _then;

/// Create a copy of EmailPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? security = null,Object? quota = null,Object? shares = null,Object? hasEmail = null,Object? enabled = null,}) {
  return _then(EmailPreferences(
security: null == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as bool,quota: null == quota ? _self.quota : quota // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as bool,hasEmail: null == hasEmail ? _self.hasEmail : hasEmail // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailPreferences].
extension EmailPreferencesPatterns on EmailPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailPreferences value)  $default,){
final _that = this;
switch (_that) {
case _EmailPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _EmailPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool security,  bool quota,  bool shares,  bool hasEmail,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailPreferences() when $default != null:
return $default(_that.security,_that.quota,_that.shares,_that.hasEmail,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool security,  bool quota,  bool shares,  bool hasEmail,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _EmailPreferences():
return $default(_that.security,_that.quota,_that.shares,_that.hasEmail,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool security,  bool quota,  bool shares,  bool hasEmail,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _EmailPreferences() when $default != null:
return $default(_that.security,_that.quota,_that.shares,_that.hasEmail,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc


class _EmailPreferences implements EmailPreferences {
  const _EmailPreferences({this.security = true, this.quota = true, this.shares = true, this.hasEmail = false, this.enabled = false});
  

@override@JsonKey() final  bool security;
@override@JsonKey() final  bool quota;
@override@JsonKey() final  bool shares;
@override@JsonKey() final  bool hasEmail;
@override@JsonKey() final  bool enabled;

/// Create a copy of EmailPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailPreferencesCopyWith<_EmailPreferences> get copyWith => __$EmailPreferencesCopyWithImpl<_EmailPreferences>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailPreferences&&(identical(other.security, security) || other.security == security)&&(identical(other.quota, quota) || other.quota == quota)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.hasEmail, hasEmail) || other.hasEmail == hasEmail)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,security,quota,shares,hasEmail,enabled);
}

@override
String toString() {
    return 'EmailPreferences(security: $security, quota: $quota, shares: $shares, hasEmail: $hasEmail, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$EmailPreferencesCopyWith<$Res> implements $EmailPreferencesCopyWith<$Res> {
  factory _$EmailPreferencesCopyWith(_EmailPreferences value, $Res Function(_EmailPreferences) _then) = __$EmailPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool security, bool quota, bool shares, bool hasEmail, bool enabled
});




}
/// @nodoc
class __$EmailPreferencesCopyWithImpl<$Res>
    implements _$EmailPreferencesCopyWith<$Res> {
  __$EmailPreferencesCopyWithImpl(this._self, this._then);

  final _EmailPreferences _self;
  final $Res Function(_EmailPreferences) _then;

/// Create a copy of EmailPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? security = null,Object? quota = null,Object? shares = null,Object? hasEmail = null,Object? enabled = null,}) {
  return _then(_EmailPreferences(
security: null == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as bool,quota: null == quota ? _self.quota : quota // ignore: cast_nullable_to_non_nullable
as bool,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as bool,hasEmail: null == hasEmail ? _self.hasEmail : hasEmail // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
