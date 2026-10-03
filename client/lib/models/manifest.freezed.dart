// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChunkRef {

 String get hash; int get offset; int get size;
/// Create a copy of ChunkRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChunkRefCopyWith<ChunkRef> get copyWith => _$ChunkRefCopyWithImpl<ChunkRef>(this as ChunkRef, _$identity);

  /// Serializes this ChunkRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChunkRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChunkRef&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.offset, _this.offset) || other.offset == _this.offset)&&(identical(other.size, _this.size) || other.size == _this.size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChunkRef;
  return Object.hash(runtimeType,_this.hash,_this.offset,_this.size);
}

@override
String toString() {
  final _this = this as ChunkRef;
  return 'ChunkRef(hash: ${_this.hash}, offset: ${_this.offset}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $ChunkRefCopyWith<$Res>  {
  factory $ChunkRefCopyWith(ChunkRef value, $Res Function(ChunkRef) _then) = _$ChunkRefCopyWithImpl;
@useResult
$Res call({
 String hash, int offset, int size
});




}
/// @nodoc
class _$ChunkRefCopyWithImpl<$Res>
    implements $ChunkRefCopyWith<$Res> {
  _$ChunkRefCopyWithImpl(this._self, this._then);

  final ChunkRef _self;
  final $Res Function(ChunkRef) _then;

/// Create a copy of ChunkRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hash = null,Object? offset = null,Object? size = null,}) {
  return _then(ChunkRef(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChunkRef].
extension ChunkRefPatterns on ChunkRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChunkRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChunkRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChunkRef value)  $default,){
final _that = this;
switch (_that) {
case _ChunkRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChunkRef value)?  $default,){
final _that = this;
switch (_that) {
case _ChunkRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hash,  int offset,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChunkRef() when $default != null:
return $default(_that.hash,_that.offset,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hash,  int offset,  int size)  $default,) {final _that = this;
switch (_that) {
case _ChunkRef():
return $default(_that.hash,_that.offset,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hash,  int offset,  int size)?  $default,) {final _that = this;
switch (_that) {
case _ChunkRef() when $default != null:
return $default(_that.hash,_that.offset,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChunkRef extends ChunkRef {
  const _ChunkRef({required this.hash, this.offset = 0, required this.size}): super._();
  factory _ChunkRef.fromJson(Map<String, dynamic> json) => _$ChunkRefFromJson(json);

@override final  String hash;
@override@JsonKey() final  int offset;
@override final  int size;

/// Create a copy of ChunkRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChunkRefCopyWith<_ChunkRef> get copyWith => __$ChunkRefCopyWithImpl<_ChunkRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChunkRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChunkRef&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hash,offset,size);
}

@override
String toString() {
    return 'ChunkRef(hash: $hash, offset: $offset, size: $size)';
}


}

/// @nodoc
abstract mixin class _$ChunkRefCopyWith<$Res> implements $ChunkRefCopyWith<$Res> {
  factory _$ChunkRefCopyWith(_ChunkRef value, $Res Function(_ChunkRef) _then) = __$ChunkRefCopyWithImpl;
@override @useResult
$Res call({
 String hash, int offset, int size
});




}
/// @nodoc
class __$ChunkRefCopyWithImpl<$Res>
    implements _$ChunkRefCopyWith<$Res> {
  __$ChunkRefCopyWithImpl(this._self, this._then);

  final _ChunkRef _self;
  final $Res Function(_ChunkRef) _then;

/// Create a copy of ChunkRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hash = null,Object? offset = null,Object? size = null,}) {
  return _then(_ChunkRef(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Manifest {

 String get path; int get rev; int get size; String get hash; List<ChunkRef> get chunks;
/// Create a copy of Manifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManifestCopyWith<Manifest> get copyWith => _$ManifestCopyWithImpl<Manifest>(this as Manifest, _$identity);

  /// Serializes this Manifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Manifest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Manifest&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.rev, _this.rev) || other.rev == _this.rev)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&const DeepCollectionEquality().equals(other.chunks, _this.chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Manifest;
  return Object.hash(runtimeType,_this.path,_this.rev,_this.size,_this.hash,const DeepCollectionEquality().hash(_this.chunks));
}

@override
String toString() {
  final _this = this as Manifest;
  return 'Manifest(path: ${_this.path}, rev: ${_this.rev}, size: ${_this.size}, hash: ${_this.hash}, chunks: ${_this.chunks})';
}


}

/// @nodoc
abstract mixin class $ManifestCopyWith<$Res>  {
  factory $ManifestCopyWith(Manifest value, $Res Function(Manifest) _then) = _$ManifestCopyWithImpl;
@useResult
$Res call({
 String path, int rev, int size, String hash, List<ChunkRef> chunks
});




}
/// @nodoc
class _$ManifestCopyWithImpl<$Res>
    implements $ManifestCopyWith<$Res> {
  _$ManifestCopyWithImpl(this._self, this._then);

  final Manifest _self;
  final $Res Function(Manifest) _then;

/// Create a copy of Manifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? rev = null,Object? size = null,Object? hash = null,Object? chunks = null,}) {
  return _then(Manifest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,chunks: null == chunks ? _self.chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<ChunkRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [Manifest].
extension ManifestPatterns on Manifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Manifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Manifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Manifest value)  $default,){
final _that = this;
switch (_that) {
case _Manifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Manifest value)?  $default,){
final _that = this;
switch (_that) {
case _Manifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int rev,  int size,  String hash,  List<ChunkRef> chunks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Manifest() when $default != null:
return $default(_that.path,_that.rev,_that.size,_that.hash,_that.chunks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int rev,  int size,  String hash,  List<ChunkRef> chunks)  $default,) {final _that = this;
switch (_that) {
case _Manifest():
return $default(_that.path,_that.rev,_that.size,_that.hash,_that.chunks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int rev,  int size,  String hash,  List<ChunkRef> chunks)?  $default,) {final _that = this;
switch (_that) {
case _Manifest() when $default != null:
return $default(_that.path,_that.rev,_that.size,_that.hash,_that.chunks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Manifest extends Manifest {
  const _Manifest({this.path = "", this.rev = 0, required this.size, required this.hash,  List<ChunkRef> chunks = const <ChunkRef>[]}): _chunks = chunks,super._();
  factory _Manifest.fromJson(Map<String, dynamic> json) => _$ManifestFromJson(json);

@override@JsonKey() final  String path;
@override@JsonKey() final  int rev;
@override final  int size;
@override final  String hash;
 final  List<ChunkRef> _chunks;
@override@JsonKey() List<ChunkRef> get chunks {
  if (_chunks is EqualUnmodifiableListView) return _chunks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chunks);
}


/// Create a copy of Manifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManifestCopyWith<_Manifest> get copyWith => __$ManifestCopyWithImpl<_Manifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManifestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Manifest&&(identical(other.path, path) || other.path == path)&&(identical(other.rev, rev) || other.rev == rev)&&(identical(other.size, size) || other.size == size)&&(identical(other.hash, hash) || other.hash == hash)&&const DeepCollectionEquality().equals(other.chunks, _chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,rev,size,hash,const DeepCollectionEquality().hash(_chunks));
}

@override
String toString() {
    return 'Manifest(path: $path, rev: $rev, size: $size, hash: $hash, chunks: $chunks)';
}


}

/// @nodoc
abstract mixin class _$ManifestCopyWith<$Res> implements $ManifestCopyWith<$Res> {
  factory _$ManifestCopyWith(_Manifest value, $Res Function(_Manifest) _then) = __$ManifestCopyWithImpl;
@override @useResult
$Res call({
 String path, int rev, int size, String hash, List<ChunkRef> chunks
});




}
/// @nodoc
class __$ManifestCopyWithImpl<$Res>
    implements _$ManifestCopyWith<$Res> {
  __$ManifestCopyWithImpl(this._self, this._then);

  final _Manifest _self;
  final $Res Function(_Manifest) _then;

/// Create a copy of Manifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? rev = null,Object? size = null,Object? hash = null,Object? chunks = null,}) {
  return _then(_Manifest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,chunks: null == chunks ? _self._chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<ChunkRef>,
  ));
}


}

// dart format on
