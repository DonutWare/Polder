// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Conflict {

 String get syncRootId; String get relativePath; ConflictKind get kind; LocalFileState? get local; FileEntry? get remote;
/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictCopyWith<Conflict> get copyWith => _$ConflictCopyWithImpl<Conflict>(this as Conflict, _$identity);

  /// Serializes this Conflict to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Conflict;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conflict&&(identical(other.syncRootId, _this.syncRootId) || other.syncRootId == _this.syncRootId)&&(identical(other.relativePath, _this.relativePath) || other.relativePath == _this.relativePath)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.local, _this.local) || other.local == _this.local)&&(identical(other.remote, _this.remote) || other.remote == _this.remote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Conflict;
  return Object.hash(runtimeType,_this.syncRootId,_this.relativePath,_this.kind,_this.local,_this.remote);
}

@override
String toString() {
  final _this = this as Conflict;
  return 'Conflict(syncRootId: ${_this.syncRootId}, relativePath: ${_this.relativePath}, kind: ${_this.kind}, local: ${_this.local}, remote: ${_this.remote})';
}


}

/// @nodoc
abstract mixin class $ConflictCopyWith<$Res>  {
  factory $ConflictCopyWith(Conflict value, $Res Function(Conflict) _then) = _$ConflictCopyWithImpl;
@useResult
$Res call({
 String syncRootId, String relativePath, ConflictKind kind, LocalFileState? local, FileEntry? remote
});


$LocalFileStateCopyWith<$Res>? get local;$FileEntryCopyWith<$Res>? get remote;

}
/// @nodoc
class _$ConflictCopyWithImpl<$Res>
    implements $ConflictCopyWith<$Res> {
  _$ConflictCopyWithImpl(this._self, this._then);

  final Conflict _self;
  final $Res Function(Conflict) _then;

/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? syncRootId = null,Object? relativePath = null,Object? kind = null,Object? local = freezed,Object? remote = freezed,}) {
  return _then(Conflict(
syncRootId: null == syncRootId ? _self.syncRootId : syncRootId // ignore: cast_nullable_to_non_nullable
as String,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as LocalFileState?,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}
/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalFileStateCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $LocalFileStateCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get remote {
    if (_self.remote == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.remote!, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}


/// Adds pattern-matching-related methods to [Conflict].
extension ConflictPatterns on Conflict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conflict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conflict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conflict value)  $default,){
final _that = this;
switch (_that) {
case _Conflict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conflict value)?  $default,){
final _that = this;
switch (_that) {
case _Conflict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String syncRootId,  String relativePath,  ConflictKind kind,  LocalFileState? local,  FileEntry? remote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conflict() when $default != null:
return $default(_that.syncRootId,_that.relativePath,_that.kind,_that.local,_that.remote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String syncRootId,  String relativePath,  ConflictKind kind,  LocalFileState? local,  FileEntry? remote)  $default,) {final _that = this;
switch (_that) {
case _Conflict():
return $default(_that.syncRootId,_that.relativePath,_that.kind,_that.local,_that.remote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String syncRootId,  String relativePath,  ConflictKind kind,  LocalFileState? local,  FileEntry? remote)?  $default,) {final _that = this;
switch (_that) {
case _Conflict() when $default != null:
return $default(_that.syncRootId,_that.relativePath,_that.kind,_that.local,_that.remote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conflict extends Conflict {
  const _Conflict({required this.syncRootId, required this.relativePath, required this.kind, this.local, this.remote}): super._();
  factory _Conflict.fromJson(Map<String, dynamic> json) => _$ConflictFromJson(json);

@override final  String syncRootId;
@override final  String relativePath;
@override final  ConflictKind kind;
@override final  LocalFileState? local;
@override final  FileEntry? remote;

/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConflictCopyWith<_Conflict> get copyWith => __$ConflictCopyWithImpl<_Conflict>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConflictToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conflict&&(identical(other.syncRootId, syncRootId) || other.syncRootId == syncRootId)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.local, local) || other.local == local)&&(identical(other.remote, remote) || other.remote == remote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,syncRootId,relativePath,kind,local,remote);
}

@override
String toString() {
    return 'Conflict(syncRootId: $syncRootId, relativePath: $relativePath, kind: $kind, local: $local, remote: $remote)';
}


}

/// @nodoc
abstract mixin class _$ConflictCopyWith<$Res> implements $ConflictCopyWith<$Res> {
  factory _$ConflictCopyWith(_Conflict value, $Res Function(_Conflict) _then) = __$ConflictCopyWithImpl;
@override @useResult
$Res call({
 String syncRootId, String relativePath, ConflictKind kind, LocalFileState? local, FileEntry? remote
});


@override $LocalFileStateCopyWith<$Res>? get local;@override $FileEntryCopyWith<$Res>? get remote;

}
/// @nodoc
class __$ConflictCopyWithImpl<$Res>
    implements _$ConflictCopyWith<$Res> {
  __$ConflictCopyWithImpl(this._self, this._then);

  final _Conflict _self;
  final $Res Function(_Conflict) _then;

/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? syncRootId = null,Object? relativePath = null,Object? kind = null,Object? local = freezed,Object? remote = freezed,}) {
  return _then(_Conflict(
syncRootId: null == syncRootId ? _self.syncRootId : syncRootId // ignore: cast_nullable_to_non_nullable
as String,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as LocalFileState?,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}

/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalFileStateCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $LocalFileStateCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}/// Create a copy of Conflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get remote {
    if (_self.remote == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.remote!, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

// dart format on
