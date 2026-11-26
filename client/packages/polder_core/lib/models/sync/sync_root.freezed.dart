// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_root.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncRoot {

 String get id; String get accountId; String get localPath; String get remotePath; SyncMode get mode; bool get enabled;
/// Create a copy of SyncRoot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncRootCopyWith<SyncRoot> get copyWith => _$SyncRootCopyWithImpl<SyncRoot>(this as SyncRoot, _$identity);

  /// Serializes this SyncRoot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncRoot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncRoot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.remotePath, _this.remotePath) || other.remotePath == _this.remotePath)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncRoot;
  return Object.hash(runtimeType,_this.id,_this.accountId,_this.localPath,_this.remotePath,_this.mode,_this.enabled);
}

@override
String toString() {
  final _this = this as SyncRoot;
  return 'SyncRoot(id: ${_this.id}, accountId: ${_this.accountId}, localPath: ${_this.localPath}, remotePath: ${_this.remotePath}, mode: ${_this.mode}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $SyncRootCopyWith<$Res>  {
  factory $SyncRootCopyWith(SyncRoot value, $Res Function(SyncRoot) _then) = _$SyncRootCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String localPath, String remotePath, SyncMode mode, bool enabled
});




}
/// @nodoc
class _$SyncRootCopyWithImpl<$Res>
    implements $SyncRootCopyWith<$Res> {
  _$SyncRootCopyWithImpl(this._self, this._then);

  final SyncRoot _self;
  final $Res Function(SyncRoot) _then;

/// Create a copy of SyncRoot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? localPath = null,Object? remotePath = null,Object? mode = null,Object? enabled = null,}) {
  return _then(SyncRoot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,remotePath: null == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SyncMode,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncRoot].
extension SyncRootPatterns on SyncRoot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncRoot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncRoot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncRoot value)  $default,){
final _that = this;
switch (_that) {
case _SyncRoot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncRoot value)?  $default,){
final _that = this;
switch (_that) {
case _SyncRoot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String localPath,  String remotePath,  SyncMode mode,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncRoot() when $default != null:
return $default(_that.id,_that.accountId,_that.localPath,_that.remotePath,_that.mode,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String localPath,  String remotePath,  SyncMode mode,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _SyncRoot():
return $default(_that.id,_that.accountId,_that.localPath,_that.remotePath,_that.mode,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String localPath,  String remotePath,  SyncMode mode,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _SyncRoot() when $default != null:
return $default(_that.id,_that.accountId,_that.localPath,_that.remotePath,_that.mode,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncRoot implements SyncRoot {
  const _SyncRoot({required this.id, required this.accountId, required this.localPath, required this.remotePath, this.mode = SyncMode.sync, this.enabled = true});
  factory _SyncRoot.fromJson(Map<String, dynamic> json) => _$SyncRootFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String localPath;
@override final  String remotePath;
@override@JsonKey() final  SyncMode mode;
@override@JsonKey() final  bool enabled;

/// Create a copy of SyncRoot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncRootCopyWith<_SyncRoot> get copyWith => __$SyncRootCopyWithImpl<_SyncRoot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncRootToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncRoot&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.remotePath, remotePath) || other.remotePath == remotePath)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,accountId,localPath,remotePath,mode,enabled);
}

@override
String toString() {
    return 'SyncRoot(id: $id, accountId: $accountId, localPath: $localPath, remotePath: $remotePath, mode: $mode, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$SyncRootCopyWith<$Res> implements $SyncRootCopyWith<$Res> {
  factory _$SyncRootCopyWith(_SyncRoot value, $Res Function(_SyncRoot) _then) = __$SyncRootCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String localPath, String remotePath, SyncMode mode, bool enabled
});




}
/// @nodoc
class __$SyncRootCopyWithImpl<$Res>
    implements _$SyncRootCopyWith<$Res> {
  __$SyncRootCopyWithImpl(this._self, this._then);

  final _SyncRoot _self;
  final $Res Function(_SyncRoot) _then;

/// Create a copy of SyncRoot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? localPath = null,Object? remotePath = null,Object? mode = null,Object? enabled = null,}) {
  return _then(_SyncRoot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,remotePath: null == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SyncMode,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
