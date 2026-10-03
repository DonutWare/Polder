// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncEntry {

 String get syncRootId; String get relativePath; bool get isDir; String? get localHash; int? get localSize; DateTime? get localMtime; int get syncedRev; String get syncedHash; String? get manifestJson; EntryState get state;
/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncEntryCopyWith<SyncEntry> get copyWith => _$SyncEntryCopyWithImpl<SyncEntry>(this as SyncEntry, _$identity);

  /// Serializes this SyncEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncEntry&&(identical(other.syncRootId, _this.syncRootId) || other.syncRootId == _this.syncRootId)&&(identical(other.relativePath, _this.relativePath) || other.relativePath == _this.relativePath)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.localHash, _this.localHash) || other.localHash == _this.localHash)&&(identical(other.localSize, _this.localSize) || other.localSize == _this.localSize)&&(identical(other.localMtime, _this.localMtime) || other.localMtime == _this.localMtime)&&(identical(other.syncedRev, _this.syncedRev) || other.syncedRev == _this.syncedRev)&&(identical(other.syncedHash, _this.syncedHash) || other.syncedHash == _this.syncedHash)&&(identical(other.manifestJson, _this.manifestJson) || other.manifestJson == _this.manifestJson)&&(identical(other.state, _this.state) || other.state == _this.state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncEntry;
  return Object.hash(runtimeType,_this.syncRootId,_this.relativePath,_this.isDir,_this.localHash,_this.localSize,_this.localMtime,_this.syncedRev,_this.syncedHash,_this.manifestJson,_this.state);
}

@override
String toString() {
  final _this = this as SyncEntry;
  return 'SyncEntry(syncRootId: ${_this.syncRootId}, relativePath: ${_this.relativePath}, isDir: ${_this.isDir}, localHash: ${_this.localHash}, localSize: ${_this.localSize}, localMtime: ${_this.localMtime}, syncedRev: ${_this.syncedRev}, syncedHash: ${_this.syncedHash}, manifestJson: ${_this.manifestJson}, state: ${_this.state})';
}


}

/// @nodoc
abstract mixin class $SyncEntryCopyWith<$Res>  {
  factory $SyncEntryCopyWith(SyncEntry value, $Res Function(SyncEntry) _then) = _$SyncEntryCopyWithImpl;
@useResult
$Res call({
 String syncRootId, String relativePath, bool isDir, String? localHash, int? localSize, DateTime? localMtime, int syncedRev, String syncedHash, String? manifestJson, EntryState state
});




}
/// @nodoc
class _$SyncEntryCopyWithImpl<$Res>
    implements $SyncEntryCopyWith<$Res> {
  _$SyncEntryCopyWithImpl(this._self, this._then);

  final SyncEntry _self;
  final $Res Function(SyncEntry) _then;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? syncRootId = null,Object? relativePath = null,Object? isDir = null,Object? localHash = freezed,Object? localSize = freezed,Object? localMtime = freezed,Object? syncedRev = null,Object? syncedHash = null,Object? manifestJson = freezed,Object? state = null,}) {
  return _then(SyncEntry(
syncRootId: null == syncRootId ? _self.syncRootId : syncRootId // ignore: cast_nullable_to_non_nullable
as String,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,localHash: freezed == localHash ? _self.localHash : localHash // ignore: cast_nullable_to_non_nullable
as String?,localSize: freezed == localSize ? _self.localSize : localSize // ignore: cast_nullable_to_non_nullable
as int?,localMtime: freezed == localMtime ? _self.localMtime : localMtime // ignore: cast_nullable_to_non_nullable
as DateTime?,syncedRev: null == syncedRev ? _self.syncedRev : syncedRev // ignore: cast_nullable_to_non_nullable
as int,syncedHash: null == syncedHash ? _self.syncedHash : syncedHash // ignore: cast_nullable_to_non_nullable
as String,manifestJson: freezed == manifestJson ? _self.manifestJson : manifestJson // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EntryState,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncEntry].
extension SyncEntryPatterns on SyncEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncEntry value)  $default,){
final _that = this;
switch (_that) {
case _SyncEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String syncRootId,  String relativePath,  bool isDir,  String? localHash,  int? localSize,  DateTime? localMtime,  int syncedRev,  String syncedHash,  String? manifestJson,  EntryState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
return $default(_that.syncRootId,_that.relativePath,_that.isDir,_that.localHash,_that.localSize,_that.localMtime,_that.syncedRev,_that.syncedHash,_that.manifestJson,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String syncRootId,  String relativePath,  bool isDir,  String? localHash,  int? localSize,  DateTime? localMtime,  int syncedRev,  String syncedHash,  String? manifestJson,  EntryState state)  $default,) {final _that = this;
switch (_that) {
case _SyncEntry():
return $default(_that.syncRootId,_that.relativePath,_that.isDir,_that.localHash,_that.localSize,_that.localMtime,_that.syncedRev,_that.syncedHash,_that.manifestJson,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String syncRootId,  String relativePath,  bool isDir,  String? localHash,  int? localSize,  DateTime? localMtime,  int syncedRev,  String syncedHash,  String? manifestJson,  EntryState state)?  $default,) {final _that = this;
switch (_that) {
case _SyncEntry() when $default != null:
return $default(_that.syncRootId,_that.relativePath,_that.isDir,_that.localHash,_that.localSize,_that.localMtime,_that.syncedRev,_that.syncedHash,_that.manifestJson,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncEntry extends SyncEntry {
  const _SyncEntry({required this.syncRootId, required this.relativePath, this.isDir = false, this.localHash, this.localSize, this.localMtime, this.syncedRev = 0, this.syncedHash = "", this.manifestJson, this.state = EntryState.hydrated}): super._();
  factory _SyncEntry.fromJson(Map<String, dynamic> json) => _$SyncEntryFromJson(json);

@override final  String syncRootId;
@override final  String relativePath;
@override@JsonKey() final  bool isDir;
@override final  String? localHash;
@override final  int? localSize;
@override final  DateTime? localMtime;
@override@JsonKey() final  int syncedRev;
@override@JsonKey() final  String syncedHash;
@override final  String? manifestJson;
@override@JsonKey() final  EntryState state;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncEntryCopyWith<_SyncEntry> get copyWith => __$SyncEntryCopyWithImpl<_SyncEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncEntry&&(identical(other.syncRootId, syncRootId) || other.syncRootId == syncRootId)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.localHash, localHash) || other.localHash == localHash)&&(identical(other.localSize, localSize) || other.localSize == localSize)&&(identical(other.localMtime, localMtime) || other.localMtime == localMtime)&&(identical(other.syncedRev, syncedRev) || other.syncedRev == syncedRev)&&(identical(other.syncedHash, syncedHash) || other.syncedHash == syncedHash)&&(identical(other.manifestJson, manifestJson) || other.manifestJson == manifestJson)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,syncRootId,relativePath,isDir,localHash,localSize,localMtime,syncedRev,syncedHash,manifestJson,state);
}

@override
String toString() {
    return 'SyncEntry(syncRootId: $syncRootId, relativePath: $relativePath, isDir: $isDir, localHash: $localHash, localSize: $localSize, localMtime: $localMtime, syncedRev: $syncedRev, syncedHash: $syncedHash, manifestJson: $manifestJson, state: $state)';
}


}

/// @nodoc
abstract mixin class _$SyncEntryCopyWith<$Res> implements $SyncEntryCopyWith<$Res> {
  factory _$SyncEntryCopyWith(_SyncEntry value, $Res Function(_SyncEntry) _then) = __$SyncEntryCopyWithImpl;
@override @useResult
$Res call({
 String syncRootId, String relativePath, bool isDir, String? localHash, int? localSize, DateTime? localMtime, int syncedRev, String syncedHash, String? manifestJson, EntryState state
});




}
/// @nodoc
class __$SyncEntryCopyWithImpl<$Res>
    implements _$SyncEntryCopyWith<$Res> {
  __$SyncEntryCopyWithImpl(this._self, this._then);

  final _SyncEntry _self;
  final $Res Function(_SyncEntry) _then;

/// Create a copy of SyncEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? syncRootId = null,Object? relativePath = null,Object? isDir = null,Object? localHash = freezed,Object? localSize = freezed,Object? localMtime = freezed,Object? syncedRev = null,Object? syncedHash = null,Object? manifestJson = freezed,Object? state = null,}) {
  return _then(_SyncEntry(
syncRootId: null == syncRootId ? _self.syncRootId : syncRootId // ignore: cast_nullable_to_non_nullable
as String,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,localHash: freezed == localHash ? _self.localHash : localHash // ignore: cast_nullable_to_non_nullable
as String?,localSize: freezed == localSize ? _self.localSize : localSize // ignore: cast_nullable_to_non_nullable
as int?,localMtime: freezed == localMtime ? _self.localMtime : localMtime // ignore: cast_nullable_to_non_nullable
as DateTime?,syncedRev: null == syncedRev ? _self.syncedRev : syncedRev // ignore: cast_nullable_to_non_nullable
as int,syncedHash: null == syncedHash ? _self.syncedHash : syncedHash // ignore: cast_nullable_to_non_nullable
as String,manifestJson: freezed == manifestJson ? _self.manifestJson : manifestJson // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as EntryState,
  ));
}


}

// dart format on
