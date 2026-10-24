// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_mount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FileMount {

 FileMountKind get kind; int get shareId; String get path; bool get isDir; String get owner; String get ownerName; String get server; String get provider; List<String> get groups; SharePermissions get permissions; bool get canLeave; String get note; DateTime? get expiresAt; DateTime get sharedAt;
/// Create a copy of FileMount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileMountCopyWith<FileMount> get copyWith => _$FileMountCopyWithImpl<FileMount>(this as FileMount, _$identity);

  /// Serializes this FileMount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FileMount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileMount&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.shareId, _this.shareId) || other.shareId == _this.shareId)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.canLeave, _this.canLeave) || other.canLeave == _this.canLeave)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.sharedAt, _this.sharedAt) || other.sharedAt == _this.sharedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FileMount;
  return Object.hash(runtimeType,_this.kind,_this.shareId,_this.path,_this.isDir,_this.owner,_this.ownerName,_this.server,_this.provider,const DeepCollectionEquality().hash(_this.groups),_this.permissions,_this.canLeave,_this.note,_this.expiresAt,_this.sharedAt);
}

@override
String toString() {
  final _this = this as FileMount;
  return 'FileMount(kind: ${_this.kind}, shareId: ${_this.shareId}, path: ${_this.path}, isDir: ${_this.isDir}, owner: ${_this.owner}, ownerName: ${_this.ownerName}, server: ${_this.server}, provider: ${_this.provider}, groups: ${_this.groups}, permissions: ${_this.permissions}, canLeave: ${_this.canLeave}, note: ${_this.note}, expiresAt: ${_this.expiresAt}, sharedAt: ${_this.sharedAt})';
}


}

/// @nodoc
abstract mixin class $FileMountCopyWith<$Res>  {
  factory $FileMountCopyWith(FileMount value, $Res Function(FileMount) _then) = _$FileMountCopyWithImpl;
@useResult
$Res call({
 FileMountKind kind, int shareId, String path, bool isDir, String owner, String ownerName, String server, String provider, List<String> groups, SharePermissions permissions, bool canLeave, String note, DateTime? expiresAt, DateTime sharedAt
});


$SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$FileMountCopyWithImpl<$Res>
    implements $FileMountCopyWith<$Res> {
  _$FileMountCopyWithImpl(this._self, this._then);

  final FileMount _self;
  final $Res Function(FileMount) _then;

/// Create a copy of FileMount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? shareId = null,Object? path = null,Object? isDir = null,Object? owner = null,Object? ownerName = null,Object? server = null,Object? provider = null,Object? groups = null,Object? permissions = null,Object? canLeave = null,Object? note = null,Object? expiresAt = freezed,Object? sharedAt = null,}) {
  return _then(FileMount(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FileMountKind,shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,canLeave: null == canLeave ? _self.canLeave : canLeave // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharedAt: null == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of FileMount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [FileMount].
extension FileMountPatterns on FileMount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileMount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileMount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileMount value)  $default,){
final _that = this;
switch (_that) {
case _FileMount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileMount value)?  $default,){
final _that = this;
switch (_that) {
case _FileMount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileMountKind kind,  int shareId,  String path,  bool isDir,  String owner,  String ownerName,  String server,  String provider,  List<String> groups,  SharePermissions permissions,  bool canLeave,  String note,  DateTime? expiresAt,  DateTime sharedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileMount() when $default != null:
return $default(_that.kind,_that.shareId,_that.path,_that.isDir,_that.owner,_that.ownerName,_that.server,_that.provider,_that.groups,_that.permissions,_that.canLeave,_that.note,_that.expiresAt,_that.sharedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileMountKind kind,  int shareId,  String path,  bool isDir,  String owner,  String ownerName,  String server,  String provider,  List<String> groups,  SharePermissions permissions,  bool canLeave,  String note,  DateTime? expiresAt,  DateTime sharedAt)  $default,) {final _that = this;
switch (_that) {
case _FileMount():
return $default(_that.kind,_that.shareId,_that.path,_that.isDir,_that.owner,_that.ownerName,_that.server,_that.provider,_that.groups,_that.permissions,_that.canLeave,_that.note,_that.expiresAt,_that.sharedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileMountKind kind,  int shareId,  String path,  bool isDir,  String owner,  String ownerName,  String server,  String provider,  List<String> groups,  SharePermissions permissions,  bool canLeave,  String note,  DateTime? expiresAt,  DateTime sharedAt)?  $default,) {final _that = this;
switch (_that) {
case _FileMount() when $default != null:
return $default(_that.kind,_that.shareId,_that.path,_that.isDir,_that.owner,_that.ownerName,_that.server,_that.provider,_that.groups,_that.permissions,_that.canLeave,_that.note,_that.expiresAt,_that.sharedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileMount extends FileMount {
  const _FileMount({required this.kind, required this.shareId, required this.path, this.isDir = true, required this.owner, this.ownerName = "", this.server = "", this.provider = "",  List<String> groups = const <String>[], this.permissions = SharePermissions.viewOnly, this.canLeave = false, this.note = "", this.expiresAt, required this.sharedAt}): _groups = groups,super._();
  factory _FileMount.fromJson(Map<String, dynamic> json) => _$FileMountFromJson(json);

@override final  FileMountKind kind;
@override final  int shareId;
@override final  String path;
@override@JsonKey() final  bool isDir;
@override final  String owner;
@override@JsonKey() final  String ownerName;
@override@JsonKey() final  String server;
@override@JsonKey() final  String provider;
 final  List<String> _groups;
@override@JsonKey() List<String> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  SharePermissions permissions;
@override@JsonKey() final  bool canLeave;
@override@JsonKey() final  String note;
@override final  DateTime? expiresAt;
@override final  DateTime sharedAt;

/// Create a copy of FileMount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileMountCopyWith<_FileMount> get copyWith => __$FileMountCopyWithImpl<_FileMount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileMountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileMount&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.path, path) || other.path == path)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.server, server) || other.server == server)&&(identical(other.provider, provider) || other.provider == provider)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.canLeave, canLeave) || other.canLeave == canLeave)&&(identical(other.note, note) || other.note == note)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.sharedAt, sharedAt) || other.sharedAt == sharedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,shareId,path,isDir,owner,ownerName,server,provider,const DeepCollectionEquality().hash(_groups),permissions,canLeave,note,expiresAt,sharedAt);
}

@override
String toString() {
    return 'FileMount(kind: $kind, shareId: $shareId, path: $path, isDir: $isDir, owner: $owner, ownerName: $ownerName, server: $server, provider: $provider, groups: $groups, permissions: $permissions, canLeave: $canLeave, note: $note, expiresAt: $expiresAt, sharedAt: $sharedAt)';
}


}

/// @nodoc
abstract mixin class _$FileMountCopyWith<$Res> implements $FileMountCopyWith<$Res> {
  factory _$FileMountCopyWith(_FileMount value, $Res Function(_FileMount) _then) = __$FileMountCopyWithImpl;
@override @useResult
$Res call({
 FileMountKind kind, int shareId, String path, bool isDir, String owner, String ownerName, String server, String provider, List<String> groups, SharePermissions permissions, bool canLeave, String note, DateTime? expiresAt, DateTime sharedAt
});


@override $SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$FileMountCopyWithImpl<$Res>
    implements _$FileMountCopyWith<$Res> {
  __$FileMountCopyWithImpl(this._self, this._then);

  final _FileMount _self;
  final $Res Function(_FileMount) _then;

/// Create a copy of FileMount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? shareId = null,Object? path = null,Object? isDir = null,Object? owner = null,Object? ownerName = null,Object? server = null,Object? provider = null,Object? groups = null,Object? permissions = null,Object? canLeave = null,Object? note = null,Object? expiresAt = freezed,Object? sharedAt = null,}) {
  return _then(_FileMount(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FileMountKind,shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,canLeave: null == canLeave ? _self.canLeave : canLeave // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sharedAt: null == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of FileMount
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
