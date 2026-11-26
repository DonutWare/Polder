// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServerImage {

 String get id; String get contentType;
/// Create a copy of ServerImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerImageCopyWith<ServerImage> get copyWith => _$ServerImageCopyWithImpl<ServerImage>(this as ServerImage, _$identity);

  /// Serializes this ServerImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServerImage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerImage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServerImage;
  return Object.hash(runtimeType,_this.id,_this.contentType);
}

@override
String toString() {
  final _this = this as ServerImage;
  return 'ServerImage(id: ${_this.id}, contentType: ${_this.contentType})';
}


}

/// @nodoc
abstract mixin class $ServerImageCopyWith<$Res>  {
  factory $ServerImageCopyWith(ServerImage value, $Res Function(ServerImage) _then) = _$ServerImageCopyWithImpl;
@useResult
$Res call({
 String id, String contentType
});




}
/// @nodoc
class _$ServerImageCopyWithImpl<$Res>
    implements $ServerImageCopyWith<$Res> {
  _$ServerImageCopyWithImpl(this._self, this._then);

  final ServerImage _self;
  final $Res Function(ServerImage) _then;

/// Create a copy of ServerImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contentType = null,}) {
  return _then(ServerImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerImage].
extension ServerImagePatterns on ServerImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerImage value)  $default,){
final _that = this;
switch (_that) {
case _ServerImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerImage value)?  $default,){
final _that = this;
switch (_that) {
case _ServerImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerImage() when $default != null:
return $default(_that.id,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String contentType)  $default,) {final _that = this;
switch (_that) {
case _ServerImage():
return $default(_that.id,_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String contentType)?  $default,) {final _that = this;
switch (_that) {
case _ServerImage() when $default != null:
return $default(_that.id,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServerImage extends ServerImage {
  const _ServerImage({required this.id, required this.contentType}): super._();
  factory _ServerImage.fromJson(Map<String, dynamic> json) => _$ServerImageFromJson(json);

@override final  String id;
@override final  String contentType;

/// Create a copy of ServerImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerImageCopyWith<_ServerImage> get copyWith => __$ServerImageCopyWithImpl<_ServerImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerImageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerImage&&(identical(other.id, id) || other.id == id)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,contentType);
}

@override
String toString() {
    return 'ServerImage(id: $id, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$ServerImageCopyWith<$Res> implements $ServerImageCopyWith<$Res> {
  factory _$ServerImageCopyWith(_ServerImage value, $Res Function(_ServerImage) _then) = __$ServerImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String contentType
});




}
/// @nodoc
class __$ServerImageCopyWithImpl<$Res>
    implements _$ServerImageCopyWith<$Res> {
  __$ServerImageCopyWithImpl(this._self, this._then);

  final _ServerImage _self;
  final $Res Function(_ServerImage) _then;

/// Create a copy of ServerImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contentType = null,}) {
  return _then(_ServerImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthProviderOption {

 String get id; String get label; String get icon;
/// Create a copy of AuthProviderOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProviderOptionCopyWith<AuthProviderOption> get copyWith => _$AuthProviderOptionCopyWithImpl<AuthProviderOption>(this as AuthProviderOption, _$identity);

  /// Serializes this AuthProviderOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthProviderOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProviderOption&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.icon, _this.icon) || other.icon == _this.icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthProviderOption;
  return Object.hash(runtimeType,_this.id,_this.label,_this.icon);
}

@override
String toString() {
  final _this = this as AuthProviderOption;
  return 'AuthProviderOption(id: ${_this.id}, label: ${_this.label}, icon: ${_this.icon})';
}


}

/// @nodoc
abstract mixin class $AuthProviderOptionCopyWith<$Res>  {
  factory $AuthProviderOptionCopyWith(AuthProviderOption value, $Res Function(AuthProviderOption) _then) = _$AuthProviderOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, String icon
});




}
/// @nodoc
class _$AuthProviderOptionCopyWithImpl<$Res>
    implements $AuthProviderOptionCopyWith<$Res> {
  _$AuthProviderOptionCopyWithImpl(this._self, this._then);

  final AuthProviderOption _self;
  final $Res Function(AuthProviderOption) _then;

/// Create a copy of AuthProviderOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? icon = null,}) {
  return _then(AuthProviderOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthProviderOption].
extension AuthProviderOptionPatterns on AuthProviderOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthProviderOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthProviderOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthProviderOption value)  $default,){
final _that = this;
switch (_that) {
case _AuthProviderOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthProviderOption value)?  $default,){
final _that = this;
switch (_that) {
case _AuthProviderOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthProviderOption() when $default != null:
return $default(_that.id,_that.label,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String icon)  $default,) {final _that = this;
switch (_that) {
case _AuthProviderOption():
return $default(_that.id,_that.label,_that.icon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String icon)?  $default,) {final _that = this;
switch (_that) {
case _AuthProviderOption() when $default != null:
return $default(_that.id,_that.label,_that.icon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthProviderOption implements AuthProviderOption {
  const _AuthProviderOption({required this.id, required this.label, this.icon = ""});
  factory _AuthProviderOption.fromJson(Map<String, dynamic> json) => _$AuthProviderOptionFromJson(json);

@override final  String id;
@override final  String label;
@override@JsonKey() final  String icon;

/// Create a copy of AuthProviderOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthProviderOptionCopyWith<_AuthProviderOption> get copyWith => __$AuthProviderOptionCopyWithImpl<_AuthProviderOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthProviderOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthProviderOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,icon);
}

@override
String toString() {
    return 'AuthProviderOption(id: $id, label: $label, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$AuthProviderOptionCopyWith<$Res> implements $AuthProviderOptionCopyWith<$Res> {
  factory _$AuthProviderOptionCopyWith(_AuthProviderOption value, $Res Function(_AuthProviderOption) _then) = __$AuthProviderOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String icon
});




}
/// @nodoc
class __$AuthProviderOptionCopyWithImpl<$Res>
    implements _$AuthProviderOptionCopyWith<$Res> {
  __$AuthProviderOptionCopyWithImpl(this._self, this._then);

  final _AuthProviderOption _self;
  final $Res Function(_AuthProviderOption) _then;

/// Create a copy of AuthProviderOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? icon = null,}) {
  return _then(_AuthProviderOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Branding {

 String? get serverUrl; String get name; String get message;@ColorConverter() Color? get accent; ServerImage? get icon; List<ServerImage> get backgrounds; bool get passwordReset; List<AuthProviderOption> get authProviders;
/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrandingCopyWith<Branding> get copyWith => _$BrandingCopyWithImpl<Branding>(this as Branding, _$identity);

  /// Serializes this Branding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Branding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Branding&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.accent, _this.accent) || other.accent == _this.accent)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&const DeepCollectionEquality().equals(other.backgrounds, _this.backgrounds)&&(identical(other.passwordReset, _this.passwordReset) || other.passwordReset == _this.passwordReset)&&const DeepCollectionEquality().equals(other.authProviders, _this.authProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Branding;
  return Object.hash(runtimeType,_this.serverUrl,_this.name,_this.message,_this.accent,_this.icon,const DeepCollectionEquality().hash(_this.backgrounds),_this.passwordReset,const DeepCollectionEquality().hash(_this.authProviders));
}

@override
String toString() {
  final _this = this as Branding;
  return 'Branding(serverUrl: ${_this.serverUrl}, name: ${_this.name}, message: ${_this.message}, accent: ${_this.accent}, icon: ${_this.icon}, backgrounds: ${_this.backgrounds}, passwordReset: ${_this.passwordReset}, authProviders: ${_this.authProviders})';
}


}

/// @nodoc
abstract mixin class $BrandingCopyWith<$Res>  {
  factory $BrandingCopyWith(Branding value, $Res Function(Branding) _then) = _$BrandingCopyWithImpl;
@useResult
$Res call({
 String? serverUrl, String name, String message,@ColorConverter() Color? accent, ServerImage? icon, List<ServerImage> backgrounds, bool passwordReset, List<AuthProviderOption> authProviders
});


$ServerImageCopyWith<$Res>? get icon;

}
/// @nodoc
class _$BrandingCopyWithImpl<$Res>
    implements $BrandingCopyWith<$Res> {
  _$BrandingCopyWithImpl(this._self, this._then);

  final Branding _self;
  final $Res Function(Branding) _then;

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = freezed,Object? name = null,Object? message = null,Object? accent = freezed,Object? icon = freezed,Object? backgrounds = null,Object? passwordReset = null,Object? authProviders = null,}) {
  return _then(Branding(
serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as ServerImage?,backgrounds: null == backgrounds ? _self.backgrounds : backgrounds // ignore: cast_nullable_to_non_nullable
as List<ServerImage>,passwordReset: null == passwordReset ? _self.passwordReset : passwordReset // ignore: cast_nullable_to_non_nullable
as bool,authProviders: null == authProviders ? _self.authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<AuthProviderOption>,
  ));
}
/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}


/// Adds pattern-matching-related methods to [Branding].
extension BrandingPatterns on Branding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Branding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Branding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Branding value)  $default,){
final _that = this;
switch (_that) {
case _Branding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Branding value)?  $default,){
final _that = this;
switch (_that) {
case _Branding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? serverUrl,  String name,  String message, @ColorConverter()  Color? accent,  ServerImage? icon,  List<ServerImage> backgrounds,  bool passwordReset,  List<AuthProviderOption> authProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Branding() when $default != null:
return $default(_that.serverUrl,_that.name,_that.message,_that.accent,_that.icon,_that.backgrounds,_that.passwordReset,_that.authProviders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? serverUrl,  String name,  String message, @ColorConverter()  Color? accent,  ServerImage? icon,  List<ServerImage> backgrounds,  bool passwordReset,  List<AuthProviderOption> authProviders)  $default,) {final _that = this;
switch (_that) {
case _Branding():
return $default(_that.serverUrl,_that.name,_that.message,_that.accent,_that.icon,_that.backgrounds,_that.passwordReset,_that.authProviders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? serverUrl,  String name,  String message, @ColorConverter()  Color? accent,  ServerImage? icon,  List<ServerImage> backgrounds,  bool passwordReset,  List<AuthProviderOption> authProviders)?  $default,) {final _that = this;
switch (_that) {
case _Branding() when $default != null:
return $default(_that.serverUrl,_that.name,_that.message,_that.accent,_that.icon,_that.backgrounds,_that.passwordReset,_that.authProviders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Branding extends Branding {
  const _Branding({this.serverUrl, this.name = "", this.message = "", @ColorConverter() this.accent, this.icon,  List<ServerImage> backgrounds = const <ServerImage>[], this.passwordReset = false,  List<AuthProviderOption> authProviders = const <AuthProviderOption>[]}): _backgrounds = backgrounds,_authProviders = authProviders,super._();
  factory _Branding.fromJson(Map<String, dynamic> json) => _$BrandingFromJson(json);

@override final  String? serverUrl;
@override@JsonKey() final  String name;
@override@JsonKey() final  String message;
@override@ColorConverter() final  Color? accent;
@override final  ServerImage? icon;
 final  List<ServerImage> _backgrounds;
@override@JsonKey() List<ServerImage> get backgrounds {
  if (_backgrounds is EqualUnmodifiableListView) return _backgrounds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_backgrounds);
}

@override@JsonKey() final  bool passwordReset;
 final  List<AuthProviderOption> _authProviders;
@override@JsonKey() List<AuthProviderOption> get authProviders {
  if (_authProviders is EqualUnmodifiableListView) return _authProviders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authProviders);
}


/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrandingCopyWith<_Branding> get copyWith => __$BrandingCopyWithImpl<_Branding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrandingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Branding&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message)&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.backgrounds, _backgrounds)&&(identical(other.passwordReset, passwordReset) || other.passwordReset == passwordReset)&&const DeepCollectionEquality().equals(other.authProviders, _authProviders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,serverUrl,name,message,accent,icon,const DeepCollectionEquality().hash(_backgrounds),passwordReset,const DeepCollectionEquality().hash(_authProviders));
}

@override
String toString() {
    return 'Branding(serverUrl: $serverUrl, name: $name, message: $message, accent: $accent, icon: $icon, backgrounds: $backgrounds, passwordReset: $passwordReset, authProviders: $authProviders)';
}


}

/// @nodoc
abstract mixin class _$BrandingCopyWith<$Res> implements $BrandingCopyWith<$Res> {
  factory _$BrandingCopyWith(_Branding value, $Res Function(_Branding) _then) = __$BrandingCopyWithImpl;
@override @useResult
$Res call({
 String? serverUrl, String name, String message,@ColorConverter() Color? accent, ServerImage? icon, List<ServerImage> backgrounds, bool passwordReset, List<AuthProviderOption> authProviders
});


@override $ServerImageCopyWith<$Res>? get icon;

}
/// @nodoc
class __$BrandingCopyWithImpl<$Res>
    implements _$BrandingCopyWith<$Res> {
  __$BrandingCopyWithImpl(this._self, this._then);

  final _Branding _self;
  final $Res Function(_Branding) _then;

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = freezed,Object? name = null,Object? message = null,Object? accent = freezed,Object? icon = freezed,Object? backgrounds = null,Object? passwordReset = null,Object? authProviders = null,}) {
  return _then(_Branding(
serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,accent: freezed == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as Color?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as ServerImage?,backgrounds: null == backgrounds ? _self._backgrounds : backgrounds // ignore: cast_nullable_to_non_nullable
as List<ServerImage>,passwordReset: null == passwordReset ? _self.passwordReset : passwordReset // ignore: cast_nullable_to_non_nullable
as bool,authProviders: null == authProviders ? _self._authProviders : authProviders // ignore: cast_nullable_to_non_nullable
as List<AuthProviderOption>,
  ));
}

/// Create a copy of Branding
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}

// dart format on
