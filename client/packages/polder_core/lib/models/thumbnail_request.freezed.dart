// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thumbnail_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThumbnailRequest {

 int get size;
/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbnailRequestCopyWith<ThumbnailRequest> get copyWith => _$ThumbnailRequestCopyWithImpl<ThumbnailRequest>(this as ThumbnailRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThumbnailRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThumbnailRequest&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as ThumbnailRequest;
  return Object.hash(runtimeType,_this.size);
}

@override
String toString() {
  final _this = this as ThumbnailRequest;
  return 'ThumbnailRequest(size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $ThumbnailRequestCopyWith<$Res>  {
  factory $ThumbnailRequestCopyWith(ThumbnailRequest value, $Res Function(ThumbnailRequest) _then) = _$ThumbnailRequestCopyWithImpl;
@useResult
$Res call({
 int size
});




}
/// @nodoc
class _$ThumbnailRequestCopyWithImpl<$Res>
    implements $ThumbnailRequestCopyWith<$Res> {
  _$ThumbnailRequestCopyWithImpl(this._self, this._then);

  final ThumbnailRequest _self;
  final $Res Function(ThumbnailRequest) _then;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? size = null,}) {
  return _then(_self.copyWith(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThumbnailRequest].
extension ThumbnailRequestPatterns on ThumbnailRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileThumbnailRequest value)?  file,TResult Function( TrashThumbnailRequest value)?  trash,TResult Function( VersionThumbnailRequest value)?  version,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileThumbnailRequest() when file != null:
return file(_that);case TrashThumbnailRequest() when trash != null:
return trash(_that);case VersionThumbnailRequest() when version != null:
return version(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileThumbnailRequest value)  file,required TResult Function( TrashThumbnailRequest value)  trash,required TResult Function( VersionThumbnailRequest value)  version,}){
final _that = this;
switch (_that) {
case FileThumbnailRequest():
return file(_that);case TrashThumbnailRequest():
return trash(_that);case VersionThumbnailRequest():
return version(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileThumbnailRequest value)?  file,TResult? Function( TrashThumbnailRequest value)?  trash,TResult? Function( VersionThumbnailRequest value)?  version,}){
final _that = this;
switch (_that) {
case FileThumbnailRequest() when file != null:
return file(_that);case TrashThumbnailRequest() when trash != null:
return trash(_that);case VersionThumbnailRequest() when version != null:
return version(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path,  int rev,  int size)?  file,TResult Function( int itemId,  int size)?  trash,TResult Function( int versionId,  int size)?  version,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileThumbnailRequest() when file != null:
return file(_that.path,_that.rev,_that.size);case TrashThumbnailRequest() when trash != null:
return trash(_that.itemId,_that.size);case VersionThumbnailRequest() when version != null:
return version(_that.versionId,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path,  int rev,  int size)  file,required TResult Function( int itemId,  int size)  trash,required TResult Function( int versionId,  int size)  version,}) {final _that = this;
switch (_that) {
case FileThumbnailRequest():
return file(_that.path,_that.rev,_that.size);case TrashThumbnailRequest():
return trash(_that.itemId,_that.size);case VersionThumbnailRequest():
return version(_that.versionId,_that.size);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path,  int rev,  int size)?  file,TResult? Function( int itemId,  int size)?  trash,TResult? Function( int versionId,  int size)?  version,}) {final _that = this;
switch (_that) {
case FileThumbnailRequest() when file != null:
return file(_that.path,_that.rev,_that.size);case TrashThumbnailRequest() when trash != null:
return trash(_that.itemId,_that.size);case VersionThumbnailRequest() when version != null:
return version(_that.versionId,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class FileThumbnailRequest implements ThumbnailRequest {
  const FileThumbnailRequest({required this.path, required this.rev, this.size = 256});
  

 final  String path;
 final  int rev;
@override@JsonKey() final  int size;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileThumbnailRequestCopyWith<FileThumbnailRequest> get copyWith => _$FileThumbnailRequestCopyWithImpl<FileThumbnailRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FileThumbnailRequest&&(identical(other.path, path) || other.path == path)&&(identical(other.rev, rev) || other.rev == rev)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,rev,size);
}

@override
String toString() {
    return 'ThumbnailRequest.file(path: $path, rev: $rev, size: $size)';
}


}

/// @nodoc
abstract mixin class $FileThumbnailRequestCopyWith<$Res> implements $ThumbnailRequestCopyWith<$Res> {
  factory $FileThumbnailRequestCopyWith(FileThumbnailRequest value, $Res Function(FileThumbnailRequest) _then) = _$FileThumbnailRequestCopyWithImpl;
@override @useResult
$Res call({
 String path, int rev, int size
});




}
/// @nodoc
class _$FileThumbnailRequestCopyWithImpl<$Res>
    implements $FileThumbnailRequestCopyWith<$Res> {
  _$FileThumbnailRequestCopyWithImpl(this._self, this._then);

  final FileThumbnailRequest _self;
  final $Res Function(FileThumbnailRequest) _then;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? rev = null,Object? size = null,}) {
  return _then(FileThumbnailRequest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TrashThumbnailRequest implements ThumbnailRequest {
  const TrashThumbnailRequest({required this.itemId, this.size = 256});
  

 final  int itemId;
@override@JsonKey() final  int size;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashThumbnailRequestCopyWith<TrashThumbnailRequest> get copyWith => _$TrashThumbnailRequestCopyWithImpl<TrashThumbnailRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashThumbnailRequest&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemId,size);
}

@override
String toString() {
    return 'ThumbnailRequest.trash(itemId: $itemId, size: $size)';
}


}

/// @nodoc
abstract mixin class $TrashThumbnailRequestCopyWith<$Res> implements $ThumbnailRequestCopyWith<$Res> {
  factory $TrashThumbnailRequestCopyWith(TrashThumbnailRequest value, $Res Function(TrashThumbnailRequest) _then) = _$TrashThumbnailRequestCopyWithImpl;
@override @useResult
$Res call({
 int itemId, int size
});




}
/// @nodoc
class _$TrashThumbnailRequestCopyWithImpl<$Res>
    implements $TrashThumbnailRequestCopyWith<$Res> {
  _$TrashThumbnailRequestCopyWithImpl(this._self, this._then);

  final TrashThumbnailRequest _self;
  final $Res Function(TrashThumbnailRequest) _then;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? size = null,}) {
  return _then(TrashThumbnailRequest(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class VersionThumbnailRequest implements ThumbnailRequest {
  const VersionThumbnailRequest({required this.versionId, this.size = 256});
  

 final  int versionId;
@override@JsonKey() final  int size;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionThumbnailRequestCopyWith<VersionThumbnailRequest> get copyWith => _$VersionThumbnailRequestCopyWithImpl<VersionThumbnailRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionThumbnailRequest&&(identical(other.versionId, versionId) || other.versionId == versionId)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,versionId,size);
}

@override
String toString() {
    return 'ThumbnailRequest.version(versionId: $versionId, size: $size)';
}


}

/// @nodoc
abstract mixin class $VersionThumbnailRequestCopyWith<$Res> implements $ThumbnailRequestCopyWith<$Res> {
  factory $VersionThumbnailRequestCopyWith(VersionThumbnailRequest value, $Res Function(VersionThumbnailRequest) _then) = _$VersionThumbnailRequestCopyWithImpl;
@override @useResult
$Res call({
 int versionId, int size
});




}
/// @nodoc
class _$VersionThumbnailRequestCopyWithImpl<$Res>
    implements $VersionThumbnailRequestCopyWith<$Res> {
  _$VersionThumbnailRequestCopyWithImpl(this._self, this._then);

  final VersionThumbnailRequest _self;
  final $Res Function(VersionThumbnailRequest) _then;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? versionId = null,Object? size = null,}) {
  return _then(VersionThumbnailRequest(
versionId: null == versionId ? _self.versionId : versionId // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
