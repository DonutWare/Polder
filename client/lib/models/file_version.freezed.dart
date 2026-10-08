// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileVersion {

 int get id; int get size; String get hash; DateTime get modifiedAt; DateTime get replacedAt; bool get hasPreview;
/// Create a copy of FileVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileVersionCopyWith<FileVersion> get copyWith => _$FileVersionCopyWithImpl<FileVersion>(this as FileVersion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileVersion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileVersion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.modifiedAt, _this.modifiedAt) || other.modifiedAt == _this.modifiedAt)&&(identical(other.replacedAt, _this.replacedAt) || other.replacedAt == _this.replacedAt)&&(identical(other.hasPreview, _this.hasPreview) || other.hasPreview == _this.hasPreview));
}


@override
int get hashCode {
  final _this = this as FileVersion;
  return Object.hash(runtimeType,_this.id,_this.size,_this.hash,_this.modifiedAt,_this.replacedAt,_this.hasPreview);
}

@override
String toString() {
  final _this = this as FileVersion;
  return 'FileVersion(id: ${_this.id}, size: ${_this.size}, hash: ${_this.hash}, modifiedAt: ${_this.modifiedAt}, replacedAt: ${_this.replacedAt}, hasPreview: ${_this.hasPreview})';
}


}

/// @nodoc
abstract mixin class $FileVersionCopyWith<$Res>  {
  factory $FileVersionCopyWith(FileVersion value, $Res Function(FileVersion) _then) = _$FileVersionCopyWithImpl;
@useResult
$Res call({
 int id, int size, String hash, DateTime modifiedAt, DateTime replacedAt, bool hasPreview
});




}
/// @nodoc
class _$FileVersionCopyWithImpl<$Res>
    implements $FileVersionCopyWith<$Res> {
  _$FileVersionCopyWithImpl(this._self, this._then);

  final FileVersion _self;
  final $Res Function(FileVersion) _then;

/// Create a copy of FileVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? size = null,Object? hash = null,Object? modifiedAt = null,Object? replacedAt = null,Object? hasPreview = null,}) {
  return _then(FileVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,replacedAt: null == replacedAt ? _self.replacedAt : replacedAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasPreview: null == hasPreview ? _self.hasPreview : hasPreview // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FileVersion].
extension FileVersionPatterns on FileVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileVersion value)  $default,){
final _that = this;
switch (_that) {
case _FileVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileVersion value)?  $default,){
final _that = this;
switch (_that) {
case _FileVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int size,  String hash,  DateTime modifiedAt,  DateTime replacedAt,  bool hasPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileVersion() when $default != null:
return $default(_that.id,_that.size,_that.hash,_that.modifiedAt,_that.replacedAt,_that.hasPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int size,  String hash,  DateTime modifiedAt,  DateTime replacedAt,  bool hasPreview)  $default,) {final _that = this;
switch (_that) {
case _FileVersion():
return $default(_that.id,_that.size,_that.hash,_that.modifiedAt,_that.replacedAt,_that.hasPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int size,  String hash,  DateTime modifiedAt,  DateTime replacedAt,  bool hasPreview)?  $default,) {final _that = this;
switch (_that) {
case _FileVersion() when $default != null:
return $default(_that.id,_that.size,_that.hash,_that.modifiedAt,_that.replacedAt,_that.hasPreview);case _:
  return null;

}
}

}

/// @nodoc


class _FileVersion implements FileVersion {
  const _FileVersion({required this.id, this.size = 0, this.hash = "", required this.modifiedAt, required this.replacedAt, this.hasPreview = false});
  

@override final  int id;
@override@JsonKey() final  int size;
@override@JsonKey() final  String hash;
@override final  DateTime modifiedAt;
@override final  DateTime replacedAt;
@override@JsonKey() final  bool hasPreview;

/// Create a copy of FileVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileVersionCopyWith<_FileVersion> get copyWith => __$FileVersionCopyWithImpl<_FileVersion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.size, size) || other.size == size)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.replacedAt, replacedAt) || other.replacedAt == replacedAt)&&(identical(other.hasPreview, hasPreview) || other.hasPreview == hasPreview));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,size,hash,modifiedAt,replacedAt,hasPreview);
}

@override
String toString() {
    return 'FileVersion(id: $id, size: $size, hash: $hash, modifiedAt: $modifiedAt, replacedAt: $replacedAt, hasPreview: $hasPreview)';
}


}

/// @nodoc
abstract mixin class _$FileVersionCopyWith<$Res> implements $FileVersionCopyWith<$Res> {
  factory _$FileVersionCopyWith(_FileVersion value, $Res Function(_FileVersion) _then) = __$FileVersionCopyWithImpl;
@override @useResult
$Res call({
 int id, int size, String hash, DateTime modifiedAt, DateTime replacedAt, bool hasPreview
});




}
/// @nodoc
class __$FileVersionCopyWithImpl<$Res>
    implements _$FileVersionCopyWith<$Res> {
  __$FileVersionCopyWithImpl(this._self, this._then);

  final _FileVersion _self;
  final $Res Function(_FileVersion) _then;

/// Create a copy of FileVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? size = null,Object? hash = null,Object? modifiedAt = null,Object? replacedAt = null,Object? hasPreview = null,}) {
  return _then(_FileVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,replacedAt: null == replacedAt ? _self.replacedAt : replacedAt // ignore: cast_nullable_to_non_nullable
as DateTime,hasPreview: null == hasPreview ? _self.hasPreview : hasPreview // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$VersionRetention {

 bool get enabled; int get keepAllHours; int get maxAgeDays; int get maxPerFile; RetentionSource get source; bool get locked; bool get serverEnabled; int get serverMaxAgeDays; int get serverMaxPerFile; bool? get userEnabled; int? get userMaxAgeDays; int? get userMaxPerFile;
/// Create a copy of VersionRetention
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionRetentionCopyWith<VersionRetention> get copyWith => _$VersionRetentionCopyWithImpl<VersionRetention>(this as VersionRetention, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VersionRetention;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionRetention&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.keepAllHours, _this.keepAllHours) || other.keepAllHours == _this.keepAllHours)&&(identical(other.maxAgeDays, _this.maxAgeDays) || other.maxAgeDays == _this.maxAgeDays)&&(identical(other.maxPerFile, _this.maxPerFile) || other.maxPerFile == _this.maxPerFile)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.serverEnabled, _this.serverEnabled) || other.serverEnabled == _this.serverEnabled)&&(identical(other.serverMaxAgeDays, _this.serverMaxAgeDays) || other.serverMaxAgeDays == _this.serverMaxAgeDays)&&(identical(other.serverMaxPerFile, _this.serverMaxPerFile) || other.serverMaxPerFile == _this.serverMaxPerFile)&&(identical(other.userEnabled, _this.userEnabled) || other.userEnabled == _this.userEnabled)&&(identical(other.userMaxAgeDays, _this.userMaxAgeDays) || other.userMaxAgeDays == _this.userMaxAgeDays)&&(identical(other.userMaxPerFile, _this.userMaxPerFile) || other.userMaxPerFile == _this.userMaxPerFile));
}


@override
int get hashCode {
  final _this = this as VersionRetention;
  return Object.hash(runtimeType,_this.enabled,_this.keepAllHours,_this.maxAgeDays,_this.maxPerFile,_this.source,_this.locked,_this.serverEnabled,_this.serverMaxAgeDays,_this.serverMaxPerFile,_this.userEnabled,_this.userMaxAgeDays,_this.userMaxPerFile);
}

@override
String toString() {
  final _this = this as VersionRetention;
  return 'VersionRetention(enabled: ${_this.enabled}, keepAllHours: ${_this.keepAllHours}, maxAgeDays: ${_this.maxAgeDays}, maxPerFile: ${_this.maxPerFile}, source: ${_this.source}, locked: ${_this.locked}, serverEnabled: ${_this.serverEnabled}, serverMaxAgeDays: ${_this.serverMaxAgeDays}, serverMaxPerFile: ${_this.serverMaxPerFile}, userEnabled: ${_this.userEnabled}, userMaxAgeDays: ${_this.userMaxAgeDays}, userMaxPerFile: ${_this.userMaxPerFile})';
}


}

/// @nodoc
abstract mixin class $VersionRetentionCopyWith<$Res>  {
  factory $VersionRetentionCopyWith(VersionRetention value, $Res Function(VersionRetention) _then) = _$VersionRetentionCopyWithImpl;
@useResult
$Res call({
 bool enabled, int keepAllHours, int maxAgeDays, int maxPerFile, RetentionSource source, bool locked, bool serverEnabled, int serverMaxAgeDays, int serverMaxPerFile, bool? userEnabled, int? userMaxAgeDays, int? userMaxPerFile
});




}
/// @nodoc
class _$VersionRetentionCopyWithImpl<$Res>
    implements $VersionRetentionCopyWith<$Res> {
  _$VersionRetentionCopyWithImpl(this._self, this._then);

  final VersionRetention _self;
  final $Res Function(VersionRetention) _then;

/// Create a copy of VersionRetention
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? keepAllHours = null,Object? maxAgeDays = null,Object? maxPerFile = null,Object? source = null,Object? locked = null,Object? serverEnabled = null,Object? serverMaxAgeDays = null,Object? serverMaxPerFile = null,Object? userEnabled = freezed,Object? userMaxAgeDays = freezed,Object? userMaxPerFile = freezed,}) {
  return _then(VersionRetention(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,keepAllHours: null == keepAllHours ? _self.keepAllHours : keepAllHours // ignore: cast_nullable_to_non_nullable
as int,maxAgeDays: null == maxAgeDays ? _self.maxAgeDays : maxAgeDays // ignore: cast_nullable_to_non_nullable
as int,maxPerFile: null == maxPerFile ? _self.maxPerFile : maxPerFile // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RetentionSource,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,serverEnabled: null == serverEnabled ? _self.serverEnabled : serverEnabled // ignore: cast_nullable_to_non_nullable
as bool,serverMaxAgeDays: null == serverMaxAgeDays ? _self.serverMaxAgeDays : serverMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,serverMaxPerFile: null == serverMaxPerFile ? _self.serverMaxPerFile : serverMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,userEnabled: freezed == userEnabled ? _self.userEnabled : userEnabled // ignore: cast_nullable_to_non_nullable
as bool?,userMaxAgeDays: freezed == userMaxAgeDays ? _self.userMaxAgeDays : userMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int?,userMaxPerFile: freezed == userMaxPerFile ? _self.userMaxPerFile : userMaxPerFile // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VersionRetention].
extension VersionRetentionPatterns on VersionRetention {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionRetention value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionRetention() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionRetention value)  $default,){
final _that = this;
switch (_that) {
case _VersionRetention():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionRetention value)?  $default,){
final _that = this;
switch (_that) {
case _VersionRetention() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int keepAllHours,  int maxAgeDays,  int maxPerFile,  RetentionSource source,  bool locked,  bool serverEnabled,  int serverMaxAgeDays,  int serverMaxPerFile,  bool? userEnabled,  int? userMaxAgeDays,  int? userMaxPerFile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionRetention() when $default != null:
return $default(_that.enabled,_that.keepAllHours,_that.maxAgeDays,_that.maxPerFile,_that.source,_that.locked,_that.serverEnabled,_that.serverMaxAgeDays,_that.serverMaxPerFile,_that.userEnabled,_that.userMaxAgeDays,_that.userMaxPerFile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int keepAllHours,  int maxAgeDays,  int maxPerFile,  RetentionSource source,  bool locked,  bool serverEnabled,  int serverMaxAgeDays,  int serverMaxPerFile,  bool? userEnabled,  int? userMaxAgeDays,  int? userMaxPerFile)  $default,) {final _that = this;
switch (_that) {
case _VersionRetention():
return $default(_that.enabled,_that.keepAllHours,_that.maxAgeDays,_that.maxPerFile,_that.source,_that.locked,_that.serverEnabled,_that.serverMaxAgeDays,_that.serverMaxPerFile,_that.userEnabled,_that.userMaxAgeDays,_that.userMaxPerFile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int keepAllHours,  int maxAgeDays,  int maxPerFile,  RetentionSource source,  bool locked,  bool serverEnabled,  int serverMaxAgeDays,  int serverMaxPerFile,  bool? userEnabled,  int? userMaxAgeDays,  int? userMaxPerFile)?  $default,) {final _that = this;
switch (_that) {
case _VersionRetention() when $default != null:
return $default(_that.enabled,_that.keepAllHours,_that.maxAgeDays,_that.maxPerFile,_that.source,_that.locked,_that.serverEnabled,_that.serverMaxAgeDays,_that.serverMaxPerFile,_that.userEnabled,_that.userMaxAgeDays,_that.userMaxPerFile);case _:
  return null;

}
}

}

/// @nodoc


class _VersionRetention extends VersionRetention {
  const _VersionRetention({this.enabled = false, this.keepAllHours = 0, this.maxAgeDays = 0, this.maxPerFile = 0, this.source = RetentionSource.serverDefault, this.locked = false, this.serverEnabled = false, this.serverMaxAgeDays = 0, this.serverMaxPerFile = 0, this.userEnabled, this.userMaxAgeDays, this.userMaxPerFile}): super._();
  

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int keepAllHours;
@override@JsonKey() final  int maxAgeDays;
@override@JsonKey() final  int maxPerFile;
@override@JsonKey() final  RetentionSource source;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  bool serverEnabled;
@override@JsonKey() final  int serverMaxAgeDays;
@override@JsonKey() final  int serverMaxPerFile;
@override final  bool? userEnabled;
@override final  int? userMaxAgeDays;
@override final  int? userMaxPerFile;

/// Create a copy of VersionRetention
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionRetentionCopyWith<_VersionRetention> get copyWith => __$VersionRetentionCopyWithImpl<_VersionRetention>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionRetention&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.keepAllHours, keepAllHours) || other.keepAllHours == keepAllHours)&&(identical(other.maxAgeDays, maxAgeDays) || other.maxAgeDays == maxAgeDays)&&(identical(other.maxPerFile, maxPerFile) || other.maxPerFile == maxPerFile)&&(identical(other.source, source) || other.source == source)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.serverEnabled, serverEnabled) || other.serverEnabled == serverEnabled)&&(identical(other.serverMaxAgeDays, serverMaxAgeDays) || other.serverMaxAgeDays == serverMaxAgeDays)&&(identical(other.serverMaxPerFile, serverMaxPerFile) || other.serverMaxPerFile == serverMaxPerFile)&&(identical(other.userEnabled, userEnabled) || other.userEnabled == userEnabled)&&(identical(other.userMaxAgeDays, userMaxAgeDays) || other.userMaxAgeDays == userMaxAgeDays)&&(identical(other.userMaxPerFile, userMaxPerFile) || other.userMaxPerFile == userMaxPerFile));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,keepAllHours,maxAgeDays,maxPerFile,source,locked,serverEnabled,serverMaxAgeDays,serverMaxPerFile,userEnabled,userMaxAgeDays,userMaxPerFile);
}

@override
String toString() {
    return 'VersionRetention(enabled: $enabled, keepAllHours: $keepAllHours, maxAgeDays: $maxAgeDays, maxPerFile: $maxPerFile, source: $source, locked: $locked, serverEnabled: $serverEnabled, serverMaxAgeDays: $serverMaxAgeDays, serverMaxPerFile: $serverMaxPerFile, userEnabled: $userEnabled, userMaxAgeDays: $userMaxAgeDays, userMaxPerFile: $userMaxPerFile)';
}


}

/// @nodoc
abstract mixin class _$VersionRetentionCopyWith<$Res> implements $VersionRetentionCopyWith<$Res> {
  factory _$VersionRetentionCopyWith(_VersionRetention value, $Res Function(_VersionRetention) _then) = __$VersionRetentionCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int keepAllHours, int maxAgeDays, int maxPerFile, RetentionSource source, bool locked, bool serverEnabled, int serverMaxAgeDays, int serverMaxPerFile, bool? userEnabled, int? userMaxAgeDays, int? userMaxPerFile
});




}
/// @nodoc
class __$VersionRetentionCopyWithImpl<$Res>
    implements _$VersionRetentionCopyWith<$Res> {
  __$VersionRetentionCopyWithImpl(this._self, this._then);

  final _VersionRetention _self;
  final $Res Function(_VersionRetention) _then;

/// Create a copy of VersionRetention
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? keepAllHours = null,Object? maxAgeDays = null,Object? maxPerFile = null,Object? source = null,Object? locked = null,Object? serverEnabled = null,Object? serverMaxAgeDays = null,Object? serverMaxPerFile = null,Object? userEnabled = freezed,Object? userMaxAgeDays = freezed,Object? userMaxPerFile = freezed,}) {
  return _then(_VersionRetention(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,keepAllHours: null == keepAllHours ? _self.keepAllHours : keepAllHours // ignore: cast_nullable_to_non_nullable
as int,maxAgeDays: null == maxAgeDays ? _self.maxAgeDays : maxAgeDays // ignore: cast_nullable_to_non_nullable
as int,maxPerFile: null == maxPerFile ? _self.maxPerFile : maxPerFile // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RetentionSource,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,serverEnabled: null == serverEnabled ? _self.serverEnabled : serverEnabled // ignore: cast_nullable_to_non_nullable
as bool,serverMaxAgeDays: null == serverMaxAgeDays ? _self.serverMaxAgeDays : serverMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,serverMaxPerFile: null == serverMaxPerFile ? _self.serverMaxPerFile : serverMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,userEnabled: freezed == userEnabled ? _self.userEnabled : userEnabled // ignore: cast_nullable_to_non_nullable
as bool?,userMaxAgeDays: freezed == userMaxAgeDays ? _self.userMaxAgeDays : userMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int?,userMaxPerFile: freezed == userMaxPerFile ? _self.userMaxPerFile : userMaxPerFile // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$VersionListing {

 FileEntry get current; List<FileVersion> get versions; VersionRetention get retention;
/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionListingCopyWith<VersionListing> get copyWith => _$VersionListingCopyWithImpl<VersionListing>(this as VersionListing, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VersionListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionListing&&(identical(other.current, _this.current) || other.current == _this.current)&&const DeepCollectionEquality().equals(other.versions, _this.versions)&&(identical(other.retention, _this.retention) || other.retention == _this.retention));
}


@override
int get hashCode {
  final _this = this as VersionListing;
  return Object.hash(runtimeType,_this.current,const DeepCollectionEquality().hash(_this.versions),_this.retention);
}

@override
String toString() {
  final _this = this as VersionListing;
  return 'VersionListing(current: ${_this.current}, versions: ${_this.versions}, retention: ${_this.retention})';
}


}

/// @nodoc
abstract mixin class $VersionListingCopyWith<$Res>  {
  factory $VersionListingCopyWith(VersionListing value, $Res Function(VersionListing) _then) = _$VersionListingCopyWithImpl;
@useResult
$Res call({
 FileEntry current, List<FileVersion> versions, VersionRetention retention
});


$FileEntryCopyWith<$Res> get current;$VersionRetentionCopyWith<$Res> get retention;

}
/// @nodoc
class _$VersionListingCopyWithImpl<$Res>
    implements $VersionListingCopyWith<$Res> {
  _$VersionListingCopyWithImpl(this._self, this._then);

  final VersionListing _self;
  final $Res Function(VersionListing) _then;

/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? versions = null,Object? retention = null,}) {
  return _then(VersionListing(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FileEntry,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as List<FileVersion>,retention: null == retention ? _self.retention : retention // ignore: cast_nullable_to_non_nullable
as VersionRetention,
  ));
}
/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get current {
  
  return $FileEntryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VersionRetentionCopyWith<$Res> get retention {
  
  return $VersionRetentionCopyWith<$Res>(_self.retention, (value) {
    return _then(_self.copyWith(retention: value));
  });
}
}


/// Adds pattern-matching-related methods to [VersionListing].
extension VersionListingPatterns on VersionListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionListing value)  $default,){
final _that = this;
switch (_that) {
case _VersionListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionListing value)?  $default,){
final _that = this;
switch (_that) {
case _VersionListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileEntry current,  List<FileVersion> versions,  VersionRetention retention)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionListing() when $default != null:
return $default(_that.current,_that.versions,_that.retention);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileEntry current,  List<FileVersion> versions,  VersionRetention retention)  $default,) {final _that = this;
switch (_that) {
case _VersionListing():
return $default(_that.current,_that.versions,_that.retention);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileEntry current,  List<FileVersion> versions,  VersionRetention retention)?  $default,) {final _that = this;
switch (_that) {
case _VersionListing() when $default != null:
return $default(_that.current,_that.versions,_that.retention);case _:
  return null;

}
}

}

/// @nodoc


class _VersionListing implements VersionListing {
  const _VersionListing({required this.current,  List<FileVersion> versions = const <FileVersion>[], required this.retention}): _versions = versions;
  

@override final  FileEntry current;
 final  List<FileVersion> _versions;
@override@JsonKey() List<FileVersion> get versions {
  if (_versions is EqualUnmodifiableListView) return _versions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versions);
}

@override final  VersionRetention retention;

/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionListingCopyWith<_VersionListing> get copyWith => __$VersionListingCopyWithImpl<_VersionListing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionListing&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other.versions, _versions)&&(identical(other.retention, retention) || other.retention == retention));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,const DeepCollectionEquality().hash(_versions),retention);
}

@override
String toString() {
    return 'VersionListing(current: $current, versions: $versions, retention: $retention)';
}


}

/// @nodoc
abstract mixin class _$VersionListingCopyWith<$Res> implements $VersionListingCopyWith<$Res> {
  factory _$VersionListingCopyWith(_VersionListing value, $Res Function(_VersionListing) _then) = __$VersionListingCopyWithImpl;
@override @useResult
$Res call({
 FileEntry current, List<FileVersion> versions, VersionRetention retention
});


@override $FileEntryCopyWith<$Res> get current;@override $VersionRetentionCopyWith<$Res> get retention;

}
/// @nodoc
class __$VersionListingCopyWithImpl<$Res>
    implements _$VersionListingCopyWith<$Res> {
  __$VersionListingCopyWithImpl(this._self, this._then);

  final _VersionListing _self;
  final $Res Function(_VersionListing) _then;

/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? versions = null,Object? retention = null,}) {
  return _then(_VersionListing(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as FileEntry,versions: null == versions ? _self._versions : versions // ignore: cast_nullable_to_non_nullable
as List<FileVersion>,retention: null == retention ? _self.retention : retention // ignore: cast_nullable_to_non_nullable
as VersionRetention,
  ));
}

/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get current {
  
  return $FileEntryCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of VersionListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VersionRetentionCopyWith<$Res> get retention {
  
  return $VersionRetentionCopyWith<$Res>(_self.retention, (value) {
    return _then(_self.copyWith(retention: value));
  });
}
}

// dart format on
