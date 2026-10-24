// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_space.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileSpace {

 String get serverUrl; String get code;
/// Create a copy of FileSpace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileSpaceCopyWith<FileSpace> get copyWith => _$FileSpaceCopyWithImpl<FileSpace>(this as FileSpace, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileSpace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileSpace&&(identical(other.serverUrl, _this.serverUrl) || other.serverUrl == _this.serverUrl)&&(identical(other.code, _this.code) || other.code == _this.code));
}


@override
int get hashCode {
  final _this = this as FileSpace;
  return Object.hash(runtimeType,_this.serverUrl,_this.code);
}

@override
String toString() {
  final _this = this as FileSpace;
  return 'FileSpace(serverUrl: ${_this.serverUrl}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $FileSpaceCopyWith<$Res>  {
  factory $FileSpaceCopyWith(FileSpace value, $Res Function(FileSpace) _then) = _$FileSpaceCopyWithImpl;
@useResult
$Res call({
 String serverUrl, String code
});




}
/// @nodoc
class _$FileSpaceCopyWithImpl<$Res>
    implements $FileSpaceCopyWith<$Res> {
  _$FileSpaceCopyWithImpl(this._self, this._then);

  final FileSpace _self;
  final $Res Function(FileSpace) _then;

/// Create a copy of FileSpace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? code = null,}) {
  return _then(FileSpace.link(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FileSpace].
extension FileSpacePatterns on FileSpace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LinkSpace value)?  link,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LinkSpace() when link != null:
return link(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LinkSpace value)  link,}){
final _that = this;
switch (_that) {
case LinkSpace():
return link(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LinkSpace value)?  link,}){
final _that = this;
switch (_that) {
case LinkSpace() when link != null:
return link(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String serverUrl,  String code)?  link,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LinkSpace() when link != null:
return link(_that.serverUrl,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String serverUrl,  String code)  link,}) {final _that = this;
switch (_that) {
case LinkSpace():
return link(_that.serverUrl,_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String serverUrl,  String code)?  link,}) {final _that = this;
switch (_that) {
case LinkSpace() when link != null:
return link(_that.serverUrl,_that.code);case _:
  return null;

}
}

}

/// @nodoc


class LinkSpace implements FileSpace {
  const LinkSpace({required this.serverUrl, required this.code});
  

@override final  String serverUrl;
@override final  String code;

/// Create a copy of FileSpace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkSpaceCopyWith<LinkSpace> get copyWith => _$LinkSpaceCopyWithImpl<LinkSpace>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkSpace&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,serverUrl,code);
}

@override
String toString() {
    return 'FileSpace.link(serverUrl: $serverUrl, code: $code)';
}


}

/// @nodoc
abstract mixin class $LinkSpaceCopyWith<$Res> implements $FileSpaceCopyWith<$Res> {
  factory $LinkSpaceCopyWith(LinkSpace value, $Res Function(LinkSpace) _then) = _$LinkSpaceCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, String code
});




}
/// @nodoc
class _$LinkSpaceCopyWithImpl<$Res>
    implements $LinkSpaceCopyWith<$Res> {
  _$LinkSpaceCopyWithImpl(this._self, this._then);

  final LinkSpace _self;
  final $Res Function(LinkSpace) _then;

/// Create a copy of FileSpace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? code = null,}) {
  return _then(LinkSpace(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SpaceLocation {

 FileSpace get space; String get path;
/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceLocationCopyWith<SpaceLocation> get copyWith => _$SpaceLocationCopyWithImpl<SpaceLocation>(this as SpaceLocation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SpaceLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceLocation&&(identical(other.space, _this.space) || other.space == _this.space)&&(identical(other.path, _this.path) || other.path == _this.path));
}


@override
int get hashCode {
  final _this = this as SpaceLocation;
  return Object.hash(runtimeType,_this.space,_this.path);
}

@override
String toString() {
  final _this = this as SpaceLocation;
  return 'SpaceLocation(space: ${_this.space}, path: ${_this.path})';
}


}

/// @nodoc
abstract mixin class $SpaceLocationCopyWith<$Res>  {
  factory $SpaceLocationCopyWith(SpaceLocation value, $Res Function(SpaceLocation) _then) = _$SpaceLocationCopyWithImpl;
@useResult
$Res call({
 FileSpace space, String path
});


$FileSpaceCopyWith<$Res> get space;

}
/// @nodoc
class _$SpaceLocationCopyWithImpl<$Res>
    implements $SpaceLocationCopyWith<$Res> {
  _$SpaceLocationCopyWithImpl(this._self, this._then);

  final SpaceLocation _self;
  final $Res Function(SpaceLocation) _then;

/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? space = null,Object? path = null,}) {
  return _then(SpaceLocation(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as FileSpace,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileSpaceCopyWith<$Res> get space {
  
  return $FileSpaceCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceLocation].
extension SpaceLocationPatterns on SpaceLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceLocation value)  $default,){
final _that = this;
switch (_that) {
case _SpaceLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceLocation value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileSpace space,  String path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceLocation() when $default != null:
return $default(_that.space,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileSpace space,  String path)  $default,) {final _that = this;
switch (_that) {
case _SpaceLocation():
return $default(_that.space,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileSpace space,  String path)?  $default,) {final _that = this;
switch (_that) {
case _SpaceLocation() when $default != null:
return $default(_that.space,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceLocation implements SpaceLocation {
  const _SpaceLocation({required this.space, required this.path});
  

@override final  FileSpace space;
@override final  String path;

/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceLocationCopyWith<_SpaceLocation> get copyWith => __$SpaceLocationCopyWithImpl<_SpaceLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceLocation&&(identical(other.space, space) || other.space == space)&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,space,path);
}

@override
String toString() {
    return 'SpaceLocation(space: $space, path: $path)';
}


}

/// @nodoc
abstract mixin class _$SpaceLocationCopyWith<$Res> implements $SpaceLocationCopyWith<$Res> {
  factory _$SpaceLocationCopyWith(_SpaceLocation value, $Res Function(_SpaceLocation) _then) = __$SpaceLocationCopyWithImpl;
@override @useResult
$Res call({
 FileSpace space, String path
});


@override $FileSpaceCopyWith<$Res> get space;

}
/// @nodoc
class __$SpaceLocationCopyWithImpl<$Res>
    implements _$SpaceLocationCopyWith<$Res> {
  __$SpaceLocationCopyWithImpl(this._self, this._then);

  final _SpaceLocation _self;
  final $Res Function(_SpaceLocation) _then;

/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? space = null,Object? path = null,}) {
  return _then(_SpaceLocation(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as FileSpace,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SpaceLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileSpaceCopyWith<$Res> get space {
  
  return $FileSpaceCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}
}

/// @nodoc
mixin _$SpaceCapabilities {

 bool get canDownload; bool get canCreate; bool get canEdit; bool get canDelete; bool get canUpload; bool get canDownloadArchive;
/// Create a copy of SpaceCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceCapabilitiesCopyWith<SpaceCapabilities> get copyWith => _$SpaceCapabilitiesCopyWithImpl<SpaceCapabilities>(this as SpaceCapabilities, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SpaceCapabilities;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceCapabilities&&(identical(other.canDownload, _this.canDownload) || other.canDownload == _this.canDownload)&&(identical(other.canCreate, _this.canCreate) || other.canCreate == _this.canCreate)&&(identical(other.canEdit, _this.canEdit) || other.canEdit == _this.canEdit)&&(identical(other.canDelete, _this.canDelete) || other.canDelete == _this.canDelete)&&(identical(other.canUpload, _this.canUpload) || other.canUpload == _this.canUpload)&&(identical(other.canDownloadArchive, _this.canDownloadArchive) || other.canDownloadArchive == _this.canDownloadArchive));
}


@override
int get hashCode {
  final _this = this as SpaceCapabilities;
  return Object.hash(runtimeType,_this.canDownload,_this.canCreate,_this.canEdit,_this.canDelete,_this.canUpload,_this.canDownloadArchive);
}

@override
String toString() {
  final _this = this as SpaceCapabilities;
  return 'SpaceCapabilities(canDownload: ${_this.canDownload}, canCreate: ${_this.canCreate}, canEdit: ${_this.canEdit}, canDelete: ${_this.canDelete}, canUpload: ${_this.canUpload}, canDownloadArchive: ${_this.canDownloadArchive})';
}


}

/// @nodoc
abstract mixin class $SpaceCapabilitiesCopyWith<$Res>  {
  factory $SpaceCapabilitiesCopyWith(SpaceCapabilities value, $Res Function(SpaceCapabilities) _then) = _$SpaceCapabilitiesCopyWithImpl;
@useResult
$Res call({
 bool canDownload, bool canCreate, bool canEdit, bool canDelete, bool canUpload, bool canDownloadArchive
});




}
/// @nodoc
class _$SpaceCapabilitiesCopyWithImpl<$Res>
    implements $SpaceCapabilitiesCopyWith<$Res> {
  _$SpaceCapabilitiesCopyWithImpl(this._self, this._then);

  final SpaceCapabilities _self;
  final $Res Function(SpaceCapabilities) _then;

/// Create a copy of SpaceCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canDownload = null,Object? canCreate = null,Object? canEdit = null,Object? canDelete = null,Object? canUpload = null,Object? canDownloadArchive = null,}) {
  return _then(SpaceCapabilities(
canDownload: null == canDownload ? _self.canDownload : canDownload // ignore: cast_nullable_to_non_nullable
as bool,canCreate: null == canCreate ? _self.canCreate : canCreate // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,canUpload: null == canUpload ? _self.canUpload : canUpload // ignore: cast_nullable_to_non_nullable
as bool,canDownloadArchive: null == canDownloadArchive ? _self.canDownloadArchive : canDownloadArchive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SpaceCapabilities].
extension SpaceCapabilitiesPatterns on SpaceCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _SpaceCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canDownload,  bool canCreate,  bool canEdit,  bool canDelete,  bool canUpload,  bool canDownloadArchive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceCapabilities() when $default != null:
return $default(_that.canDownload,_that.canCreate,_that.canEdit,_that.canDelete,_that.canUpload,_that.canDownloadArchive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canDownload,  bool canCreate,  bool canEdit,  bool canDelete,  bool canUpload,  bool canDownloadArchive)  $default,) {final _that = this;
switch (_that) {
case _SpaceCapabilities():
return $default(_that.canDownload,_that.canCreate,_that.canEdit,_that.canDelete,_that.canUpload,_that.canDownloadArchive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canDownload,  bool canCreate,  bool canEdit,  bool canDelete,  bool canUpload,  bool canDownloadArchive)?  $default,) {final _that = this;
switch (_that) {
case _SpaceCapabilities() when $default != null:
return $default(_that.canDownload,_that.canCreate,_that.canEdit,_that.canDelete,_that.canUpload,_that.canDownloadArchive);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceCapabilities implements SpaceCapabilities {
  const _SpaceCapabilities({this.canDownload = true, this.canCreate = false, this.canEdit = false, this.canDelete = false, this.canUpload = false, this.canDownloadArchive = true});
  

@override@JsonKey() final  bool canDownload;
@override@JsonKey() final  bool canCreate;
@override@JsonKey() final  bool canEdit;
@override@JsonKey() final  bool canDelete;
@override@JsonKey() final  bool canUpload;
@override@JsonKey() final  bool canDownloadArchive;

/// Create a copy of SpaceCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceCapabilitiesCopyWith<_SpaceCapabilities> get copyWith => __$SpaceCapabilitiesCopyWithImpl<_SpaceCapabilities>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceCapabilities&&(identical(other.canDownload, canDownload) || other.canDownload == canDownload)&&(identical(other.canCreate, canCreate) || other.canCreate == canCreate)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&(identical(other.canUpload, canUpload) || other.canUpload == canUpload)&&(identical(other.canDownloadArchive, canDownloadArchive) || other.canDownloadArchive == canDownloadArchive));
}


@override
int get hashCode {
    return Object.hash(runtimeType,canDownload,canCreate,canEdit,canDelete,canUpload,canDownloadArchive);
}

@override
String toString() {
    return 'SpaceCapabilities(canDownload: $canDownload, canCreate: $canCreate, canEdit: $canEdit, canDelete: $canDelete, canUpload: $canUpload, canDownloadArchive: $canDownloadArchive)';
}


}

/// @nodoc
abstract mixin class _$SpaceCapabilitiesCopyWith<$Res> implements $SpaceCapabilitiesCopyWith<$Res> {
  factory _$SpaceCapabilitiesCopyWith(_SpaceCapabilities value, $Res Function(_SpaceCapabilities) _then) = __$SpaceCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 bool canDownload, bool canCreate, bool canEdit, bool canDelete, bool canUpload, bool canDownloadArchive
});




}
/// @nodoc
class __$SpaceCapabilitiesCopyWithImpl<$Res>
    implements _$SpaceCapabilitiesCopyWith<$Res> {
  __$SpaceCapabilitiesCopyWithImpl(this._self, this._then);

  final _SpaceCapabilities _self;
  final $Res Function(_SpaceCapabilities) _then;

/// Create a copy of SpaceCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canDownload = null,Object? canCreate = null,Object? canEdit = null,Object? canDelete = null,Object? canUpload = null,Object? canDownloadArchive = null,}) {
  return _then(_SpaceCapabilities(
canDownload: null == canDownload ? _self.canDownload : canDownload // ignore: cast_nullable_to_non_nullable
as bool,canCreate: null == canCreate ? _self.canCreate : canCreate // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,canUpload: null == canUpload ? _self.canUpload : canUpload // ignore: cast_nullable_to_non_nullable
as bool,canDownloadArchive: null == canDownloadArchive ? _self.canDownloadArchive : canDownloadArchive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
