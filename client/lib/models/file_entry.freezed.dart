// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FileEntry {

 String get path; String get name; bool get isDir; int get size; DateTime get mtime; int get rev; String get hash; String get mime; Map<String, dynamic> get meta;@JsonKey(unknownEnumValue: PreviewState.none) PreviewState get previewState;
/// Create a copy of FileEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileEntryCopyWith<FileEntry> get copyWith => _$FileEntryCopyWithImpl<FileEntry>(this as FileEntry, _$identity);

  /// Serializes this FileEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FileEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileEntry&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.mtime, _this.mtime) || other.mtime == _this.mtime)&&(identical(other.rev, _this.rev) || other.rev == _this.rev)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&const DeepCollectionEquality().equals(other.meta, _this.meta)&&(identical(other.previewState, _this.previewState) || other.previewState == _this.previewState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FileEntry;
  return Object.hash(runtimeType,_this.path,_this.name,_this.isDir,_this.size,_this.mtime,_this.rev,_this.hash,_this.mime,const DeepCollectionEquality().hash(_this.meta),_this.previewState);
}

@override
String toString() {
  final _this = this as FileEntry;
  return 'FileEntry(path: ${_this.path}, name: ${_this.name}, isDir: ${_this.isDir}, size: ${_this.size}, mtime: ${_this.mtime}, rev: ${_this.rev}, hash: ${_this.hash}, mime: ${_this.mime}, meta: ${_this.meta}, previewState: ${_this.previewState})';
}


}

/// @nodoc
abstract mixin class $FileEntryCopyWith<$Res>  {
  factory $FileEntryCopyWith(FileEntry value, $Res Function(FileEntry) _then) = _$FileEntryCopyWithImpl;
@useResult
$Res call({
 String path, String name, bool isDir, int size, DateTime mtime, int rev, String hash, String mime, Map<String, dynamic> meta,@JsonKey(unknownEnumValue: PreviewState.none) PreviewState previewState
});




}
/// @nodoc
class _$FileEntryCopyWithImpl<$Res>
    implements $FileEntryCopyWith<$Res> {
  _$FileEntryCopyWithImpl(this._self, this._then);

  final FileEntry _self;
  final $Res Function(FileEntry) _then;

/// Create a copy of FileEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? name = null,Object? isDir = null,Object? size = null,Object? mtime = null,Object? rev = null,Object? hash = null,Object? mime = null,Object? meta = null,Object? previewState = null,}) {
  return _then(FileEntry(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,previewState: null == previewState ? _self.previewState : previewState // ignore: cast_nullable_to_non_nullable
as PreviewState,
  ));
}

}


/// Adds pattern-matching-related methods to [FileEntry].
extension FileEntryPatterns on FileEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileEntry value)  $default,){
final _that = this;
switch (_that) {
case _FileEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FileEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String name,  bool isDir,  int size,  DateTime mtime,  int rev,  String hash,  String mime,  Map<String, dynamic> meta, @JsonKey(unknownEnumValue: PreviewState.none)  PreviewState previewState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileEntry() when $default != null:
return $default(_that.path,_that.name,_that.isDir,_that.size,_that.mtime,_that.rev,_that.hash,_that.mime,_that.meta,_that.previewState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String name,  bool isDir,  int size,  DateTime mtime,  int rev,  String hash,  String mime,  Map<String, dynamic> meta, @JsonKey(unknownEnumValue: PreviewState.none)  PreviewState previewState)  $default,) {final _that = this;
switch (_that) {
case _FileEntry():
return $default(_that.path,_that.name,_that.isDir,_that.size,_that.mtime,_that.rev,_that.hash,_that.mime,_that.meta,_that.previewState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String name,  bool isDir,  int size,  DateTime mtime,  int rev,  String hash,  String mime,  Map<String, dynamic> meta, @JsonKey(unknownEnumValue: PreviewState.none)  PreviewState previewState)?  $default,) {final _that = this;
switch (_that) {
case _FileEntry() when $default != null:
return $default(_that.path,_that.name,_that.isDir,_that.size,_that.mtime,_that.rev,_that.hash,_that.mime,_that.meta,_that.previewState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileEntry extends FileEntry {
  const _FileEntry({required this.path, required this.name, this.isDir = false, this.size = 0, required this.mtime, this.rev = 0, this.hash = "", this.mime = "",  Map<String, dynamic> meta = const <String, dynamic>{}, @JsonKey(unknownEnumValue: PreviewState.none) this.previewState = PreviewState.none}): _meta = meta,super._();
  factory _FileEntry.fromJson(Map<String, dynamic> json) => _$FileEntryFromJson(json);

@override final  String path;
@override final  String name;
@override@JsonKey() final  bool isDir;
@override@JsonKey() final  int size;
@override final  DateTime mtime;
@override@JsonKey() final  int rev;
@override@JsonKey() final  String hash;
@override@JsonKey() final  String mime;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override@JsonKey(unknownEnumValue: PreviewState.none) final  PreviewState previewState;

/// Create a copy of FileEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileEntryCopyWith<_FileEntry> get copyWith => __$FileEntryCopyWithImpl<_FileEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileEntry&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.size, size) || other.size == size)&&(identical(other.mtime, mtime) || other.mtime == mtime)&&(identical(other.rev, rev) || other.rev == rev)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.mime, mime) || other.mime == mime)&&const DeepCollectionEquality().equals(other.meta, _meta)&&(identical(other.previewState, previewState) || other.previewState == previewState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,name,isDir,size,mtime,rev,hash,mime,const DeepCollectionEquality().hash(_meta),previewState);
}

@override
String toString() {
    return 'FileEntry(path: $path, name: $name, isDir: $isDir, size: $size, mtime: $mtime, rev: $rev, hash: $hash, mime: $mime, meta: $meta, previewState: $previewState)';
}


}

/// @nodoc
abstract mixin class _$FileEntryCopyWith<$Res> implements $FileEntryCopyWith<$Res> {
  factory _$FileEntryCopyWith(_FileEntry value, $Res Function(_FileEntry) _then) = __$FileEntryCopyWithImpl;
@override @useResult
$Res call({
 String path, String name, bool isDir, int size, DateTime mtime, int rev, String hash, String mime, Map<String, dynamic> meta,@JsonKey(unknownEnumValue: PreviewState.none) PreviewState previewState
});




}
/// @nodoc
class __$FileEntryCopyWithImpl<$Res>
    implements _$FileEntryCopyWith<$Res> {
  __$FileEntryCopyWithImpl(this._self, this._then);

  final _FileEntry _self;
  final $Res Function(_FileEntry) _then;

/// Create a copy of FileEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,Object? isDir = null,Object? size = null,Object? mtime = null,Object? rev = null,Object? hash = null,Object? mime = null,Object? meta = null,Object? previewState = null,}) {
  return _then(_FileEntry(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,previewState: null == previewState ? _self.previewState : previewState // ignore: cast_nullable_to_non_nullable
as PreviewState,
  ));
}


}

// dart format on
