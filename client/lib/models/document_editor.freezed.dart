// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_editor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorCapabilities {

 bool get enabled; Set<String> get editableMimes; Set<String> get editableExtensions; Set<String> get viewableMimes; Set<String> get viewableExtensions; Map<String, List<String>> get creatable;
/// Create a copy of EditorCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorCapabilitiesCopyWith<EditorCapabilities> get copyWith => _$EditorCapabilitiesCopyWithImpl<EditorCapabilities>(this as EditorCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EditorCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorCapabilities&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&const DeepCollectionEquality().equals(other.editableMimes, _this.editableMimes)&&const DeepCollectionEquality().equals(other.editableExtensions, _this.editableExtensions)&&const DeepCollectionEquality().equals(other.viewableMimes, _this.viewableMimes)&&const DeepCollectionEquality().equals(other.viewableExtensions, _this.viewableExtensions)&&const DeepCollectionEquality().equals(other.creatable, _this.creatable));
}


@override
int get hashCode {
  final _this = this as EditorCapabilities;
  return Object.hash(runtimeType,_this.enabled,const DeepCollectionEquality().hash(_this.editableMimes),const DeepCollectionEquality().hash(_this.editableExtensions),const DeepCollectionEquality().hash(_this.viewableMimes),const DeepCollectionEquality().hash(_this.viewableExtensions),const DeepCollectionEquality().hash(_this.creatable));
}

@override
String toString() {
  final _this = this as EditorCapabilities;
  return 'EditorCapabilities(enabled: ${_this.enabled}, editableMimes: ${_this.editableMimes}, editableExtensions: ${_this.editableExtensions}, viewableMimes: ${_this.viewableMimes}, viewableExtensions: ${_this.viewableExtensions}, creatable: ${_this.creatable})';
}


}

/// @nodoc
abstract mixin class $EditorCapabilitiesCopyWith<$Res>  {
  factory $EditorCapabilitiesCopyWith(EditorCapabilities value, $Res Function(EditorCapabilities) _then) = _$EditorCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool enabled, Set<String> editableMimes, Set<String> editableExtensions, Set<String> viewableMimes, Set<String> viewableExtensions, Map<String, List<String>> creatable
});




}
/// @nodoc
class _$EditorCapabilitiesCopyWithImpl<$Res>
    implements $EditorCapabilitiesCopyWith<$Res> {
  _$EditorCapabilitiesCopyWithImpl(this._self, this._then);

  final EditorCapabilities _self;
  final $Res Function(EditorCapabilities) _then;

/// Create a copy of EditorCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? editableMimes = null,Object? editableExtensions = null,Object? viewableMimes = null,Object? viewableExtensions = null,Object? creatable = null,}) {
  return _then(EditorCapabilities(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,editableMimes: null == editableMimes ? _self.editableMimes : editableMimes // ignore: cast_nullable_to_non_nullable
as Set<String>,editableExtensions: null == editableExtensions ? _self.editableExtensions : editableExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>,viewableMimes: null == viewableMimes ? _self.viewableMimes : viewableMimes // ignore: cast_nullable_to_non_nullable
as Set<String>,viewableExtensions: null == viewableExtensions ? _self.viewableExtensions : viewableExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>,creatable: null == creatable ? _self.creatable : creatable // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorCapabilities].
extension EditorCapabilitiesPatterns on EditorCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _EditorCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _EditorCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  Set<String> editableMimes,  Set<String> editableExtensions,  Set<String> viewableMimes,  Set<String> viewableExtensions,  Map<String, List<String>> creatable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorCapabilities() when $default != null:
return $default(_that.enabled,_that.editableMimes,_that.editableExtensions,_that.viewableMimes,_that.viewableExtensions,_that.creatable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  Set<String> editableMimes,  Set<String> editableExtensions,  Set<String> viewableMimes,  Set<String> viewableExtensions,  Map<String, List<String>> creatable)  $default,) {final _that = this;
switch (_that) {
case _EditorCapabilities():
return $default(_that.enabled,_that.editableMimes,_that.editableExtensions,_that.viewableMimes,_that.viewableExtensions,_that.creatable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  Set<String> editableMimes,  Set<String> editableExtensions,  Set<String> viewableMimes,  Set<String> viewableExtensions,  Map<String, List<String>> creatable)?  $default,) {final _that = this;
switch (_that) {
case _EditorCapabilities() when $default != null:
return $default(_that.enabled,_that.editableMimes,_that.editableExtensions,_that.viewableMimes,_that.viewableExtensions,_that.creatable);case _:
  return null;

}
}

}

/// @nodoc


class _EditorCapabilities extends EditorCapabilities {
  const _EditorCapabilities({this.enabled = false,  Set<String> editableMimes = const <String>{},  Set<String> editableExtensions = const <String>{},  Set<String> viewableMimes = const <String>{},  Set<String> viewableExtensions = const <String>{},  Map<String, List<String>> creatable = const <String, List<String>>{}}): _editableMimes = editableMimes,_editableExtensions = editableExtensions,_viewableMimes = viewableMimes,_viewableExtensions = viewableExtensions,_creatable = creatable,super._();
  

@override@JsonKey() final  bool enabled;
 final  Set<String> _editableMimes;
@override@JsonKey() Set<String> get editableMimes {
  if (_editableMimes is EqualUnmodifiableSetView) return _editableMimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_editableMimes);
}

 final  Set<String> _editableExtensions;
@override@JsonKey() Set<String> get editableExtensions {
  if (_editableExtensions is EqualUnmodifiableSetView) return _editableExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_editableExtensions);
}

 final  Set<String> _viewableMimes;
@override@JsonKey() Set<String> get viewableMimes {
  if (_viewableMimes is EqualUnmodifiableSetView) return _viewableMimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_viewableMimes);
}

 final  Set<String> _viewableExtensions;
@override@JsonKey() Set<String> get viewableExtensions {
  if (_viewableExtensions is EqualUnmodifiableSetView) return _viewableExtensions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_viewableExtensions);
}

 final  Map<String, List<String>> _creatable;
@override@JsonKey() Map<String, List<String>> get creatable {
  if (_creatable is EqualUnmodifiableMapView) return _creatable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_creatable);
}


/// Create a copy of EditorCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorCapabilitiesCopyWith<_EditorCapabilities> get copyWith => __$EditorCapabilitiesCopyWithImpl<_EditorCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorCapabilities&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.editableMimes, _editableMimes)&&const DeepCollectionEquality().equals(other.editableExtensions, _editableExtensions)&&const DeepCollectionEquality().equals(other.viewableMimes, _viewableMimes)&&const DeepCollectionEquality().equals(other.viewableExtensions, _viewableExtensions)&&const DeepCollectionEquality().equals(other.creatable, _creatable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(_editableMimes),const DeepCollectionEquality().hash(_editableExtensions),const DeepCollectionEquality().hash(_viewableMimes),const DeepCollectionEquality().hash(_viewableExtensions),const DeepCollectionEquality().hash(_creatable));
}

@override
String toString() {
    return 'EditorCapabilities(enabled: $enabled, editableMimes: $editableMimes, editableExtensions: $editableExtensions, viewableMimes: $viewableMimes, viewableExtensions: $viewableExtensions, creatable: $creatable)';
}


}

/// @nodoc
abstract mixin class _$EditorCapabilitiesCopyWith<$Res> implements $EditorCapabilitiesCopyWith<$Res> {
  factory _$EditorCapabilitiesCopyWith(_EditorCapabilities value, $Res Function(_EditorCapabilities) _then) = __$EditorCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, Set<String> editableMimes, Set<String> editableExtensions, Set<String> viewableMimes, Set<String> viewableExtensions, Map<String, List<String>> creatable
});




}
/// @nodoc
class __$EditorCapabilitiesCopyWithImpl<$Res>
    implements _$EditorCapabilitiesCopyWith<$Res> {
  __$EditorCapabilitiesCopyWithImpl(this._self, this._then);

  final _EditorCapabilities _self;
  final $Res Function(_EditorCapabilities) _then;

/// Create a copy of EditorCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? editableMimes = null,Object? editableExtensions = null,Object? viewableMimes = null,Object? viewableExtensions = null,Object? creatable = null,}) {
  return _then(_EditorCapabilities(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,editableMimes: null == editableMimes ? _self._editableMimes : editableMimes // ignore: cast_nullable_to_non_nullable
as Set<String>,editableExtensions: null == editableExtensions ? _self._editableExtensions : editableExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>,viewableMimes: null == viewableMimes ? _self._viewableMimes : viewableMimes // ignore: cast_nullable_to_non_nullable
as Set<String>,viewableExtensions: null == viewableExtensions ? _self._viewableExtensions : viewableExtensions // ignore: cast_nullable_to_non_nullable
as Set<String>,creatable: null == creatable ? _self._creatable : creatable // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

/// @nodoc
mixin _$EditorSession {

 String get editorUrl; String get hostPage; String get accessToken; int get accessTokenTtl; bool get readOnly;
/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSessionCopyWith<EditorSession> get copyWith => _$EditorSessionCopyWithImpl<EditorSession>(this as EditorSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EditorSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSession&&(identical(other.editorUrl, _this.editorUrl) || other.editorUrl == _this.editorUrl)&&(identical(other.hostPage, _this.hostPage) || other.hostPage == _this.hostPage)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.accessTokenTtl, _this.accessTokenTtl) || other.accessTokenTtl == _this.accessTokenTtl)&&(identical(other.readOnly, _this.readOnly) || other.readOnly == _this.readOnly));
}


@override
int get hashCode {
  final _this = this as EditorSession;
  return Object.hash(runtimeType,_this.editorUrl,_this.hostPage,_this.accessToken,_this.accessTokenTtl,_this.readOnly);
}

@override
String toString() {
  final _this = this as EditorSession;
  return 'EditorSession(editorUrl: ${_this.editorUrl}, hostPage: ${_this.hostPage}, accessToken: ${_this.accessToken}, accessTokenTtl: ${_this.accessTokenTtl}, readOnly: ${_this.readOnly})';
}


}

/// @nodoc
abstract mixin class $EditorSessionCopyWith<$Res>  {
  factory $EditorSessionCopyWith(EditorSession value, $Res Function(EditorSession) _then) = _$EditorSessionCopyWithImpl;
@useResult
$Res call({
 String editorUrl, String hostPage, String accessToken, int accessTokenTtl, bool readOnly
});




}
/// @nodoc
class _$EditorSessionCopyWithImpl<$Res>
    implements $EditorSessionCopyWith<$Res> {
  _$EditorSessionCopyWithImpl(this._self, this._then);

  final EditorSession _self;
  final $Res Function(EditorSession) _then;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editorUrl = null,Object? hostPage = null,Object? accessToken = null,Object? accessTokenTtl = null,Object? readOnly = null,}) {
  return _then(EditorSession(
editorUrl: null == editorUrl ? _self.editorUrl : editorUrl // ignore: cast_nullable_to_non_nullable
as String,hostPage: null == hostPage ? _self.hostPage : hostPage // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenTtl: null == accessTokenTtl ? _self.accessTokenTtl : accessTokenTtl // ignore: cast_nullable_to_non_nullable
as int,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorSession].
extension EditorSessionPatterns on EditorSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSession value)  $default,){
final _that = this;
switch (_that) {
case _EditorSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSession value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String editorUrl,  String hostPage,  String accessToken,  int accessTokenTtl,  bool readOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
return $default(_that.editorUrl,_that.hostPage,_that.accessToken,_that.accessTokenTtl,_that.readOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String editorUrl,  String hostPage,  String accessToken,  int accessTokenTtl,  bool readOnly)  $default,) {final _that = this;
switch (_that) {
case _EditorSession():
return $default(_that.editorUrl,_that.hostPage,_that.accessToken,_that.accessTokenTtl,_that.readOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String editorUrl,  String hostPage,  String accessToken,  int accessTokenTtl,  bool readOnly)?  $default,) {final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
return $default(_that.editorUrl,_that.hostPage,_that.accessToken,_that.accessTokenTtl,_that.readOnly);case _:
  return null;

}
}

}

/// @nodoc


class _EditorSession implements EditorSession {
  const _EditorSession({required this.editorUrl, required this.hostPage, required this.accessToken, required this.accessTokenTtl, this.readOnly = false});
  

@override final  String editorUrl;
@override final  String hostPage;
@override final  String accessToken;
@override final  int accessTokenTtl;
@override@JsonKey() final  bool readOnly;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSessionCopyWith<_EditorSession> get copyWith => __$EditorSessionCopyWithImpl<_EditorSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSession&&(identical(other.editorUrl, editorUrl) || other.editorUrl == editorUrl)&&(identical(other.hostPage, hostPage) || other.hostPage == hostPage)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.accessTokenTtl, accessTokenTtl) || other.accessTokenTtl == accessTokenTtl)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly));
}


@override
int get hashCode {
    return Object.hash(runtimeType,editorUrl,hostPage,accessToken,accessTokenTtl,readOnly);
}

@override
String toString() {
    return 'EditorSession(editorUrl: $editorUrl, hostPage: $hostPage, accessToken: $accessToken, accessTokenTtl: $accessTokenTtl, readOnly: $readOnly)';
}


}

/// @nodoc
abstract mixin class _$EditorSessionCopyWith<$Res> implements $EditorSessionCopyWith<$Res> {
  factory _$EditorSessionCopyWith(_EditorSession value, $Res Function(_EditorSession) _then) = __$EditorSessionCopyWithImpl;
@override @useResult
$Res call({
 String editorUrl, String hostPage, String accessToken, int accessTokenTtl, bool readOnly
});




}
/// @nodoc
class __$EditorSessionCopyWithImpl<$Res>
    implements _$EditorSessionCopyWith<$Res> {
  __$EditorSessionCopyWithImpl(this._self, this._then);

  final _EditorSession _self;
  final $Res Function(_EditorSession) _then;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editorUrl = null,Object? hostPage = null,Object? accessToken = null,Object? accessTokenTtl = null,Object? readOnly = null,}) {
  return _then(_EditorSession(
editorUrl: null == editorUrl ? _self.editorUrl : editorUrl // ignore: cast_nullable_to_non_nullable
as String,hostPage: null == hostPage ? _self.hostPage : hostPage // ignore: cast_nullable_to_non_nullable
as String,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenTtl: null == accessTokenTtl ? _self.accessTokenTtl : accessTokenTtl // ignore: cast_nullable_to_non_nullable
as int,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
