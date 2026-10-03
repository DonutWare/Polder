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

 String get path; int get rev; int get size;
/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbnailRequestCopyWith<ThumbnailRequest> get copyWith => _$ThumbnailRequestCopyWithImpl<ThumbnailRequest>(this as ThumbnailRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThumbnailRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThumbnailRequest&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.rev, _this.rev) || other.rev == _this.rev)&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as ThumbnailRequest;
  return Object.hash(runtimeType,_this.path,_this.rev,_this.size);
}

@override
String toString() {
  final _this = this as ThumbnailRequest;
  return 'ThumbnailRequest(path: ${_this.path}, rev: ${_this.rev}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $ThumbnailRequestCopyWith<$Res>  {
  factory $ThumbnailRequestCopyWith(ThumbnailRequest value, $Res Function(ThumbnailRequest) _then) = _$ThumbnailRequestCopyWithImpl;
@useResult
$Res call({
 String path, int rev, int size
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
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? rev = null,Object? size = null,}) {
  return _then(ThumbnailRequest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThumbnailRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThumbnailRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThumbnailRequest value)  $default,){
final _that = this;
switch (_that) {
case _ThumbnailRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThumbnailRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ThumbnailRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int rev,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThumbnailRequest() when $default != null:
return $default(_that.path,_that.rev,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int rev,  int size)  $default,) {final _that = this;
switch (_that) {
case _ThumbnailRequest():
return $default(_that.path,_that.rev,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int rev,  int size)?  $default,) {final _that = this;
switch (_that) {
case _ThumbnailRequest() when $default != null:
return $default(_that.path,_that.rev,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _ThumbnailRequest implements ThumbnailRequest {
  const _ThumbnailRequest({required this.path, required this.rev, this.size = 256});
  

@override final  String path;
@override final  int rev;
@override@JsonKey() final  int size;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThumbnailRequestCopyWith<_ThumbnailRequest> get copyWith => __$ThumbnailRequestCopyWithImpl<_ThumbnailRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThumbnailRequest&&(identical(other.path, path) || other.path == path)&&(identical(other.rev, rev) || other.rev == rev)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,rev,size);
}

@override
String toString() {
    return 'ThumbnailRequest(path: $path, rev: $rev, size: $size)';
}


}

/// @nodoc
abstract mixin class _$ThumbnailRequestCopyWith<$Res> implements $ThumbnailRequestCopyWith<$Res> {
  factory _$ThumbnailRequestCopyWith(_ThumbnailRequest value, $Res Function(_ThumbnailRequest) _then) = __$ThumbnailRequestCopyWithImpl;
@override @useResult
$Res call({
 String path, int rev, int size
});




}
/// @nodoc
class __$ThumbnailRequestCopyWithImpl<$Res>
    implements _$ThumbnailRequestCopyWith<$Res> {
  __$ThumbnailRequestCopyWithImpl(this._self, this._then);

  final _ThumbnailRequest _self;
  final $Res Function(_ThumbnailRequest) _then;

/// Create a copy of ThumbnailRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? rev = null,Object? size = null,}) {
  return _then(_ThumbnailRequest(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,rev: null == rev ? _self.rev : rev // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
