// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadSession {

 String get uploadId; List<String> get missing;
/// Create a copy of UploadSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadSessionCopyWith<UploadSession> get copyWith => _$UploadSessionCopyWithImpl<UploadSession>(this as UploadSession, _$identity);

  /// Serializes this UploadSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadSession&&(identical(other.uploadId, _this.uploadId) || other.uploadId == _this.uploadId)&&const DeepCollectionEquality().equals(other.missing, _this.missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadSession;
  return Object.hash(runtimeType,_this.uploadId,const DeepCollectionEquality().hash(_this.missing));
}

@override
String toString() {
  final _this = this as UploadSession;
  return 'UploadSession(uploadId: ${_this.uploadId}, missing: ${_this.missing})';
}


}

/// @nodoc
abstract mixin class $UploadSessionCopyWith<$Res>  {
  factory $UploadSessionCopyWith(UploadSession value, $Res Function(UploadSession) _then) = _$UploadSessionCopyWithImpl;
@useResult
$Res call({
 String uploadId, List<String> missing
});




}
/// @nodoc
class _$UploadSessionCopyWithImpl<$Res>
    implements $UploadSessionCopyWith<$Res> {
  _$UploadSessionCopyWithImpl(this._self, this._then);

  final UploadSession _self;
  final $Res Function(UploadSession) _then;

/// Create a copy of UploadSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadId = null,Object? missing = null,}) {
  return _then(UploadSession(
uploadId: null == uploadId ? _self.uploadId : uploadId // ignore: cast_nullable_to_non_nullable
as String,missing: null == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadSession].
extension UploadSessionPatterns on UploadSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadSession value)  $default,){
final _that = this;
switch (_that) {
case _UploadSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadSession value)?  $default,){
final _that = this;
switch (_that) {
case _UploadSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uploadId,  List<String> missing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadSession() when $default != null:
return $default(_that.uploadId,_that.missing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uploadId,  List<String> missing)  $default,) {final _that = this;
switch (_that) {
case _UploadSession():
return $default(_that.uploadId,_that.missing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uploadId,  List<String> missing)?  $default,) {final _that = this;
switch (_that) {
case _UploadSession() when $default != null:
return $default(_that.uploadId,_that.missing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadSession implements UploadSession {
  const _UploadSession({required this.uploadId,  List<String> missing = const <String>[]}): _missing = missing;
  factory _UploadSession.fromJson(Map<String, dynamic> json) => _$UploadSessionFromJson(json);

@override final  String uploadId;
 final  List<String> _missing;
@override@JsonKey() List<String> get missing {
  if (_missing is EqualUnmodifiableListView) return _missing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missing);
}


/// Create a copy of UploadSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadSessionCopyWith<_UploadSession> get copyWith => __$UploadSessionCopyWithImpl<_UploadSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadSession&&(identical(other.uploadId, uploadId) || other.uploadId == uploadId)&&const DeepCollectionEquality().equals(other.missing, _missing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uploadId,const DeepCollectionEquality().hash(_missing));
}

@override
String toString() {
    return 'UploadSession(uploadId: $uploadId, missing: $missing)';
}


}

/// @nodoc
abstract mixin class _$UploadSessionCopyWith<$Res> implements $UploadSessionCopyWith<$Res> {
  factory _$UploadSessionCopyWith(_UploadSession value, $Res Function(_UploadSession) _then) = __$UploadSessionCopyWithImpl;
@override @useResult
$Res call({
 String uploadId, List<String> missing
});




}
/// @nodoc
class __$UploadSessionCopyWithImpl<$Res>
    implements _$UploadSessionCopyWith<$Res> {
  __$UploadSessionCopyWithImpl(this._self, this._then);

  final _UploadSession _self;
  final $Res Function(_UploadSession) _then;

/// Create a copy of UploadSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadId = null,Object? missing = null,}) {
  return _then(_UploadSession(
uploadId: null == uploadId ? _self.uploadId : uploadId // ignore: cast_nullable_to_non_nullable
as String,missing: null == missing ? _self._missing : missing // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$UploadChunkSpec {

 String get hash; int get size;
/// Create a copy of UploadChunkSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadChunkSpecCopyWith<UploadChunkSpec> get copyWith => _$UploadChunkSpecCopyWithImpl<UploadChunkSpec>(this as UploadChunkSpec, _$identity);

  /// Serializes this UploadChunkSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadChunkSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadChunkSpec&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.size, _this.size) || other.size == _this.size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadChunkSpec;
  return Object.hash(runtimeType,_this.hash,_this.size);
}

@override
String toString() {
  final _this = this as UploadChunkSpec;
  return 'UploadChunkSpec(hash: ${_this.hash}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $UploadChunkSpecCopyWith<$Res>  {
  factory $UploadChunkSpecCopyWith(UploadChunkSpec value, $Res Function(UploadChunkSpec) _then) = _$UploadChunkSpecCopyWithImpl;
@useResult
$Res call({
 String hash, int size
});




}
/// @nodoc
class _$UploadChunkSpecCopyWithImpl<$Res>
    implements $UploadChunkSpecCopyWith<$Res> {
  _$UploadChunkSpecCopyWithImpl(this._self, this._then);

  final UploadChunkSpec _self;
  final $Res Function(UploadChunkSpec) _then;

/// Create a copy of UploadChunkSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hash = null,Object? size = null,}) {
  return _then(UploadChunkSpec(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadChunkSpec].
extension UploadChunkSpecPatterns on UploadChunkSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadChunkSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadChunkSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadChunkSpec value)  $default,){
final _that = this;
switch (_that) {
case _UploadChunkSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadChunkSpec value)?  $default,){
final _that = this;
switch (_that) {
case _UploadChunkSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hash,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadChunkSpec() when $default != null:
return $default(_that.hash,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hash,  int size)  $default,) {final _that = this;
switch (_that) {
case _UploadChunkSpec():
return $default(_that.hash,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hash,  int size)?  $default,) {final _that = this;
switch (_that) {
case _UploadChunkSpec() when $default != null:
return $default(_that.hash,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadChunkSpec implements UploadChunkSpec {
  const _UploadChunkSpec({required this.hash, required this.size});
  factory _UploadChunkSpec.fromJson(Map<String, dynamic> json) => _$UploadChunkSpecFromJson(json);

@override final  String hash;
@override final  int size;

/// Create a copy of UploadChunkSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadChunkSpecCopyWith<_UploadChunkSpec> get copyWith => __$UploadChunkSpecCopyWithImpl<_UploadChunkSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadChunkSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadChunkSpec&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,hash,size);
}

@override
String toString() {
    return 'UploadChunkSpec(hash: $hash, size: $size)';
}


}

/// @nodoc
abstract mixin class _$UploadChunkSpecCopyWith<$Res> implements $UploadChunkSpecCopyWith<$Res> {
  factory _$UploadChunkSpecCopyWith(_UploadChunkSpec value, $Res Function(_UploadChunkSpec) _then) = __$UploadChunkSpecCopyWithImpl;
@override @useResult
$Res call({
 String hash, int size
});




}
/// @nodoc
class __$UploadChunkSpecCopyWithImpl<$Res>
    implements _$UploadChunkSpecCopyWith<$Res> {
  __$UploadChunkSpecCopyWithImpl(this._self, this._then);

  final _UploadChunkSpec _self;
  final $Res Function(_UploadChunkSpec) _then;

/// Create a copy of UploadChunkSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hash = null,Object? size = null,}) {
  return _then(_UploadChunkSpec(
hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UploadRequest {

 String get path; int get baseRev; int get size; String get hash; DateTime get mtime; List<UploadChunkSpec> get chunks;
/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadRequestCopyWith<UploadRequest> get copyWith => _$UploadRequestCopyWithImpl<UploadRequest>(this as UploadRequest, _$identity);

  /// Serializes this UploadRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UploadRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadRequest&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.baseRev, _this.baseRev) || other.baseRev == _this.baseRev)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.mtime, _this.mtime) || other.mtime == _this.mtime)&&const DeepCollectionEquality().equals(other.chunks, _this.chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UploadRequest;
  return Object.hash(runtimeType,_this.path,_this.baseRev,_this.size,_this.hash,_this.mtime,const DeepCollectionEquality().hash(_this.chunks));
}

@override
String toString() {
  final _this = this as UploadRequest;
  return 'UploadRequest(path: ${_this.path}, baseRev: ${_this.baseRev}, size: ${_this.size}, hash: ${_this.hash}, mtime: ${_this.mtime}, chunks: ${_this.chunks})';
}


}

/// @nodoc
abstract mixin class $UploadRequestCopyWith<$Res>  {
  factory $UploadRequestCopyWith(UploadRequest value, $Res Function(UploadRequest) _then) = _$UploadRequestCopyWithImpl;
@useResult
$Res call({
 String path, int baseRev, int size, String hash, DateTime mtime, List<UploadChunkSpec> chunks
});




}
/// @nodoc
class _$UploadRequestCopyWithImpl<$Res>
    implements $UploadRequestCopyWith<$Res> {
  _$UploadRequestCopyWithImpl(this._self, this._then);

  final UploadRequest _self;
  final $Res Function(UploadRequest) _then;

/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? baseRev = null,Object? size = null,Object? hash = null,Object? mtime = null,Object? chunks = null,}) {
  return _then(UploadRequest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,chunks: null == chunks ? _self.chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<UploadChunkSpec>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadRequest].
extension UploadRequestPatterns on UploadRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadRequest value)  $default,){
final _that = this;
switch (_that) {
case _UploadRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int baseRev,  int size,  String hash,  DateTime mtime,  List<UploadChunkSpec> chunks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
return $default(_that.path,_that.baseRev,_that.size,_that.hash,_that.mtime,_that.chunks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int baseRev,  int size,  String hash,  DateTime mtime,  List<UploadChunkSpec> chunks)  $default,) {final _that = this;
switch (_that) {
case _UploadRequest():
return $default(_that.path,_that.baseRev,_that.size,_that.hash,_that.mtime,_that.chunks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int baseRev,  int size,  String hash,  DateTime mtime,  List<UploadChunkSpec> chunks)?  $default,) {final _that = this;
switch (_that) {
case _UploadRequest() when $default != null:
return $default(_that.path,_that.baseRev,_that.size,_that.hash,_that.mtime,_that.chunks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadRequest implements UploadRequest {
  const _UploadRequest({required this.path, required this.baseRev, required this.size, required this.hash, required this.mtime, required  List<UploadChunkSpec> chunks}): _chunks = chunks;
  factory _UploadRequest.fromJson(Map<String, dynamic> json) => _$UploadRequestFromJson(json);

@override final  String path;
@override final  int baseRev;
@override final  int size;
@override final  String hash;
@override final  DateTime mtime;
 final  List<UploadChunkSpec> _chunks;
@override List<UploadChunkSpec> get chunks {
  if (_chunks is EqualUnmodifiableListView) return _chunks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chunks);
}


/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadRequestCopyWith<_UploadRequest> get copyWith => __$UploadRequestCopyWithImpl<_UploadRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadRequest&&(identical(other.path, path) || other.path == path)&&(identical(other.baseRev, baseRev) || other.baseRev == baseRev)&&(identical(other.size, size) || other.size == size)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.mtime, mtime) || other.mtime == mtime)&&const DeepCollectionEquality().equals(other.chunks, _chunks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,baseRev,size,hash,mtime,const DeepCollectionEquality().hash(_chunks));
}

@override
String toString() {
    return 'UploadRequest(path: $path, baseRev: $baseRev, size: $size, hash: $hash, mtime: $mtime, chunks: $chunks)';
}


}

/// @nodoc
abstract mixin class _$UploadRequestCopyWith<$Res> implements $UploadRequestCopyWith<$Res> {
  factory _$UploadRequestCopyWith(_UploadRequest value, $Res Function(_UploadRequest) _then) = __$UploadRequestCopyWithImpl;
@override @useResult
$Res call({
 String path, int baseRev, int size, String hash, DateTime mtime, List<UploadChunkSpec> chunks
});




}
/// @nodoc
class __$UploadRequestCopyWithImpl<$Res>
    implements _$UploadRequestCopyWith<$Res> {
  __$UploadRequestCopyWithImpl(this._self, this._then);

  final _UploadRequest _self;
  final $Res Function(_UploadRequest) _then;

/// Create a copy of UploadRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? baseRev = null,Object? size = null,Object? hash = null,Object? mtime = null,Object? chunks = null,}) {
  return _then(_UploadRequest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,chunks: null == chunks ? _self._chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<UploadChunkSpec>,
  ));
}


}

// dart format on
