// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_file_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalFileState {

 String get relativePath; bool get isDir; int get size; DateTime get mtime; String get hash;
/// Create a copy of LocalFileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalFileStateCopyWith<LocalFileState> get copyWith => _$LocalFileStateCopyWithImpl<LocalFileState>(this as LocalFileState, _$identity);

  /// Serializes this LocalFileState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocalFileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalFileState&&(identical(other.relativePath, _this.relativePath) || other.relativePath == _this.relativePath)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.mtime, _this.mtime) || other.mtime == _this.mtime)&&(identical(other.hash, _this.hash) || other.hash == _this.hash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocalFileState;
  return Object.hash(runtimeType,_this.relativePath,_this.isDir,_this.size,_this.mtime,_this.hash);
}

@override
String toString() {
  final _this = this as LocalFileState;
  return 'LocalFileState(relativePath: ${_this.relativePath}, isDir: ${_this.isDir}, size: ${_this.size}, mtime: ${_this.mtime}, hash: ${_this.hash})';
}


}

/// @nodoc
abstract mixin class $LocalFileStateCopyWith<$Res>  {
  factory $LocalFileStateCopyWith(LocalFileState value, $Res Function(LocalFileState) _then) = _$LocalFileStateCopyWithImpl;
@useResult
$Res call({
 String relativePath, bool isDir, int size, DateTime mtime, String hash
});




}
/// @nodoc
class _$LocalFileStateCopyWithImpl<$Res>
    implements $LocalFileStateCopyWith<$Res> {
  _$LocalFileStateCopyWithImpl(this._self, this._then);

  final LocalFileState _self;
  final $Res Function(LocalFileState) _then;

/// Create a copy of LocalFileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? relativePath = null,Object? isDir = null,Object? size = null,Object? mtime = null,Object? hash = null,}) {
  return _then(LocalFileState(
relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalFileState].
extension LocalFileStatePatterns on LocalFileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalFileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalFileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalFileState value)  $default,){
final _that = this;
switch (_that) {
case _LocalFileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalFileState value)?  $default,){
final _that = this;
switch (_that) {
case _LocalFileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String relativePath,  bool isDir,  int size,  DateTime mtime,  String hash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalFileState() when $default != null:
return $default(_that.relativePath,_that.isDir,_that.size,_that.mtime,_that.hash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String relativePath,  bool isDir,  int size,  DateTime mtime,  String hash)  $default,) {final _that = this;
switch (_that) {
case _LocalFileState():
return $default(_that.relativePath,_that.isDir,_that.size,_that.mtime,_that.hash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String relativePath,  bool isDir,  int size,  DateTime mtime,  String hash)?  $default,) {final _that = this;
switch (_that) {
case _LocalFileState() when $default != null:
return $default(_that.relativePath,_that.isDir,_that.size,_that.mtime,_that.hash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalFileState implements LocalFileState {
  const _LocalFileState({required this.relativePath, this.isDir = false, this.size = 0, required this.mtime, this.hash = ""});
  factory _LocalFileState.fromJson(Map<String, dynamic> json) => _$LocalFileStateFromJson(json);

@override final  String relativePath;
@override@JsonKey() final  bool isDir;
@override@JsonKey() final  int size;
@override final  DateTime mtime;
@override@JsonKey() final  String hash;

/// Create a copy of LocalFileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalFileStateCopyWith<_LocalFileState> get copyWith => __$LocalFileStateCopyWithImpl<_LocalFileState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalFileStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalFileState&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.size, size) || other.size == size)&&(identical(other.mtime, mtime) || other.mtime == mtime)&&(identical(other.hash, hash) || other.hash == hash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,relativePath,isDir,size,mtime,hash);
}

@override
String toString() {
    return 'LocalFileState(relativePath: $relativePath, isDir: $isDir, size: $size, mtime: $mtime, hash: $hash)';
}


}

/// @nodoc
abstract mixin class _$LocalFileStateCopyWith<$Res> implements $LocalFileStateCopyWith<$Res> {
  factory _$LocalFileStateCopyWith(_LocalFileState value, $Res Function(_LocalFileState) _then) = __$LocalFileStateCopyWithImpl;
@override @useResult
$Res call({
 String relativePath, bool isDir, int size, DateTime mtime, String hash
});




}
/// @nodoc
class __$LocalFileStateCopyWithImpl<$Res>
    implements _$LocalFileStateCopyWith<$Res> {
  __$LocalFileStateCopyWithImpl(this._self, this._then);

  final _LocalFileState _self;
  final $Res Function(_LocalFileState) _then;

/// Create a copy of LocalFileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? relativePath = null,Object? isDir = null,Object? size = null,Object? mtime = null,Object? hash = null,}) {
  return _then(_LocalFileState(
relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mtime: null == mtime ? _self.mtime : mtime // ignore: cast_nullable_to_non_nullable
as DateTime,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
