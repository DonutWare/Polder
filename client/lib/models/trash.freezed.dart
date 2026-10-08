// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trash.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrashItem {

 int get id; String get name; String get originalPath; bool get isDir; int get size; String get mime; String get hash; PreviewState get previewState; DateTime get deletedAt; DateTime? get expiresAt;
/// Create a copy of TrashItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashItemCopyWith<TrashItem> get copyWith => _$TrashItemCopyWithImpl<TrashItem>(this as TrashItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrashItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.originalPath, _this.originalPath) || other.originalPath == _this.originalPath)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.previewState, _this.previewState) || other.previewState == _this.previewState)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as TrashItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.originalPath,_this.isDir,_this.size,_this.mime,_this.hash,_this.previewState,_this.deletedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as TrashItem;
  return 'TrashItem(id: ${_this.id}, name: ${_this.name}, originalPath: ${_this.originalPath}, isDir: ${_this.isDir}, size: ${_this.size}, mime: ${_this.mime}, hash: ${_this.hash}, previewState: ${_this.previewState}, deletedAt: ${_this.deletedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $TrashItemCopyWith<$Res>  {
  factory $TrashItemCopyWith(TrashItem value, $Res Function(TrashItem) _then) = _$TrashItemCopyWithImpl;
@useResult
$Res call({
 int id, String name, String originalPath, bool isDir, int size, String mime, String hash, PreviewState previewState, DateTime deletedAt, DateTime? expiresAt
});




}
/// @nodoc
class _$TrashItemCopyWithImpl<$Res>
    implements $TrashItemCopyWith<$Res> {
  _$TrashItemCopyWithImpl(this._self, this._then);

  final TrashItem _self;
  final $Res Function(TrashItem) _then;

/// Create a copy of TrashItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? originalPath = null,Object? isDir = null,Object? size = null,Object? mime = null,Object? hash = null,Object? previewState = null,Object? deletedAt = null,Object? expiresAt = freezed,}) {
  return _then(TrashItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalPath: null == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,previewState: null == previewState ? _self.previewState : previewState // ignore: cast_nullable_to_non_nullable
as PreviewState,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrashItem].
extension TrashItemPatterns on TrashItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashItem value)  $default,){
final _that = this;
switch (_that) {
case _TrashItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashItem value)?  $default,){
final _that = this;
switch (_that) {
case _TrashItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String originalPath,  bool isDir,  int size,  String mime,  String hash,  PreviewState previewState,  DateTime deletedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashItem() when $default != null:
return $default(_that.id,_that.name,_that.originalPath,_that.isDir,_that.size,_that.mime,_that.hash,_that.previewState,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String originalPath,  bool isDir,  int size,  String mime,  String hash,  PreviewState previewState,  DateTime deletedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TrashItem():
return $default(_that.id,_that.name,_that.originalPath,_that.isDir,_that.size,_that.mime,_that.hash,_that.previewState,_that.deletedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String originalPath,  bool isDir,  int size,  String mime,  String hash,  PreviewState previewState,  DateTime deletedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TrashItem() when $default != null:
return $default(_that.id,_that.name,_that.originalPath,_that.isDir,_that.size,_that.mime,_that.hash,_that.previewState,_that.deletedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _TrashItem extends TrashItem {
  const _TrashItem({required this.id, required this.name, required this.originalPath, this.isDir = false, this.size = 0, this.mime = "", this.hash = "", this.previewState = PreviewState.none, required this.deletedAt, this.expiresAt}): super._();
  

@override final  int id;
@override final  String name;
@override final  String originalPath;
@override@JsonKey() final  bool isDir;
@override@JsonKey() final  int size;
@override@JsonKey() final  String mime;
@override@JsonKey() final  String hash;
@override@JsonKey() final  PreviewState previewState;
@override final  DateTime deletedAt;
@override final  DateTime? expiresAt;

/// Create a copy of TrashItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashItemCopyWith<_TrashItem> get copyWith => __$TrashItemCopyWithImpl<_TrashItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalPath, originalPath) || other.originalPath == originalPath)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.size, size) || other.size == size)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.previewState, previewState) || other.previewState == previewState)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,originalPath,isDir,size,mime,hash,previewState,deletedAt,expiresAt);
}

@override
String toString() {
    return 'TrashItem(id: $id, name: $name, originalPath: $originalPath, isDir: $isDir, size: $size, mime: $mime, hash: $hash, previewState: $previewState, deletedAt: $deletedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$TrashItemCopyWith<$Res> implements $TrashItemCopyWith<$Res> {
  factory _$TrashItemCopyWith(_TrashItem value, $Res Function(_TrashItem) _then) = __$TrashItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String originalPath, bool isDir, int size, String mime, String hash, PreviewState previewState, DateTime deletedAt, DateTime? expiresAt
});




}
/// @nodoc
class __$TrashItemCopyWithImpl<$Res>
    implements _$TrashItemCopyWith<$Res> {
  __$TrashItemCopyWithImpl(this._self, this._then);

  final _TrashItem _self;
  final $Res Function(_TrashItem) _then;

/// Create a copy of TrashItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? originalPath = null,Object? isDir = null,Object? size = null,Object? mime = null,Object? hash = null,Object? previewState = null,Object? deletedAt = null,Object? expiresAt = freezed,}) {
  return _then(_TrashItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalPath: null == originalPath ? _self.originalPath : originalPath // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,previewState: null == previewState ? _self.previewState : previewState // ignore: cast_nullable_to_non_nullable
as PreviewState,deletedAt: null == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$TrashRetention {

 bool get enabled; int get days; RetentionSource get source; bool get serverEnabled; int get serverDays; TrashPreferences get user;
/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashRetentionCopyWith<TrashRetention> get copyWith => _$TrashRetentionCopyWithImpl<TrashRetention>(this as TrashRetention, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrashRetention;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashRetention&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.days, _this.days) || other.days == _this.days)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.serverEnabled, _this.serverEnabled) || other.serverEnabled == _this.serverEnabled)&&(identical(other.serverDays, _this.serverDays) || other.serverDays == _this.serverDays)&&(identical(other.user, _this.user) || other.user == _this.user));
}


@override
int get hashCode {
  final _this = this as TrashRetention;
  return Object.hash(runtimeType,_this.enabled,_this.days,_this.source,_this.serverEnabled,_this.serverDays,_this.user);
}

@override
String toString() {
  final _this = this as TrashRetention;
  return 'TrashRetention(enabled: ${_this.enabled}, days: ${_this.days}, source: ${_this.source}, serverEnabled: ${_this.serverEnabled}, serverDays: ${_this.serverDays}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $TrashRetentionCopyWith<$Res>  {
  factory $TrashRetentionCopyWith(TrashRetention value, $Res Function(TrashRetention) _then) = _$TrashRetentionCopyWithImpl;
@useResult
$Res call({
 bool enabled, int days, RetentionSource source, bool serverEnabled, int serverDays, TrashPreferences user
});


$TrashPreferencesCopyWith<$Res> get user;

}
/// @nodoc
class _$TrashRetentionCopyWithImpl<$Res>
    implements $TrashRetentionCopyWith<$Res> {
  _$TrashRetentionCopyWithImpl(this._self, this._then);

  final TrashRetention _self;
  final $Res Function(TrashRetention) _then;

/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? days = null,Object? source = null,Object? serverEnabled = null,Object? serverDays = null,Object? user = null,}) {
  return _then(TrashRetention(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RetentionSource,serverEnabled: null == serverEnabled ? _self.serverEnabled : serverEnabled // ignore: cast_nullable_to_non_nullable
as bool,serverDays: null == serverDays ? _self.serverDays : serverDays // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TrashPreferences,
  ));
}
/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrashPreferencesCopyWith<$Res> get user {
  
  return $TrashPreferencesCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrashRetention].
extension TrashRetentionPatterns on TrashRetention {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashRetention value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashRetention() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashRetention value)  $default,){
final _that = this;
switch (_that) {
case _TrashRetention():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashRetention value)?  $default,){
final _that = this;
switch (_that) {
case _TrashRetention() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int days,  RetentionSource source,  bool serverEnabled,  int serverDays,  TrashPreferences user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashRetention() when $default != null:
return $default(_that.enabled,_that.days,_that.source,_that.serverEnabled,_that.serverDays,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int days,  RetentionSource source,  bool serverEnabled,  int serverDays,  TrashPreferences user)  $default,) {final _that = this;
switch (_that) {
case _TrashRetention():
return $default(_that.enabled,_that.days,_that.source,_that.serverEnabled,_that.serverDays,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int days,  RetentionSource source,  bool serverEnabled,  int serverDays,  TrashPreferences user)?  $default,) {final _that = this;
switch (_that) {
case _TrashRetention() when $default != null:
return $default(_that.enabled,_that.days,_that.source,_that.serverEnabled,_that.serverDays,_that.user);case _:
  return null;

}
}

}

/// @nodoc


class _TrashRetention extends TrashRetention {
  const _TrashRetention({this.enabled = true, required this.days, required this.source, this.serverEnabled = true, this.serverDays = 0, this.user = const TrashPreferences()}): super._();
  

@override@JsonKey() final  bool enabled;
@override final  int days;
@override final  RetentionSource source;
@override@JsonKey() final  bool serverEnabled;
@override@JsonKey() final  int serverDays;
@override@JsonKey() final  TrashPreferences user;

/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashRetentionCopyWith<_TrashRetention> get copyWith => __$TrashRetentionCopyWithImpl<_TrashRetention>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashRetention&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.days, days) || other.days == days)&&(identical(other.source, source) || other.source == source)&&(identical(other.serverEnabled, serverEnabled) || other.serverEnabled == serverEnabled)&&(identical(other.serverDays, serverDays) || other.serverDays == serverDays)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,days,source,serverEnabled,serverDays,user);
}

@override
String toString() {
    return 'TrashRetention(enabled: $enabled, days: $days, source: $source, serverEnabled: $serverEnabled, serverDays: $serverDays, user: $user)';
}


}

/// @nodoc
abstract mixin class _$TrashRetentionCopyWith<$Res> implements $TrashRetentionCopyWith<$Res> {
  factory _$TrashRetentionCopyWith(_TrashRetention value, $Res Function(_TrashRetention) _then) = __$TrashRetentionCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int days, RetentionSource source, bool serverEnabled, int serverDays, TrashPreferences user
});


@override $TrashPreferencesCopyWith<$Res> get user;

}
/// @nodoc
class __$TrashRetentionCopyWithImpl<$Res>
    implements _$TrashRetentionCopyWith<$Res> {
  __$TrashRetentionCopyWithImpl(this._self, this._then);

  final _TrashRetention _self;
  final $Res Function(_TrashRetention) _then;

/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? days = null,Object? source = null,Object? serverEnabled = null,Object? serverDays = null,Object? user = null,}) {
  return _then(_TrashRetention(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RetentionSource,serverEnabled: null == serverEnabled ? _self.serverEnabled : serverEnabled // ignore: cast_nullable_to_non_nullable
as bool,serverDays: null == serverDays ? _self.serverDays : serverDays // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TrashPreferences,
  ));
}

/// Create a copy of TrashRetention
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrashPreferencesCopyWith<$Res> get user {
  
  return $TrashPreferencesCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc
mixin _$TrashPreferences {

 bool? get enabled; int? get days;
/// Create a copy of TrashPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashPreferencesCopyWith<TrashPreferences> get copyWith => _$TrashPreferencesCopyWithImpl<TrashPreferences>(this as TrashPreferences, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrashPreferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashPreferences&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.days, _this.days) || other.days == _this.days));
}


@override
int get hashCode {
  final _this = this as TrashPreferences;
  return Object.hash(runtimeType,_this.enabled,_this.days);
}

@override
String toString() {
  final _this = this as TrashPreferences;
  return 'TrashPreferences(enabled: ${_this.enabled}, days: ${_this.days})';
}


}

/// @nodoc
abstract mixin class $TrashPreferencesCopyWith<$Res>  {
  factory $TrashPreferencesCopyWith(TrashPreferences value, $Res Function(TrashPreferences) _then) = _$TrashPreferencesCopyWithImpl;
@useResult
$Res call({
 bool? enabled, int? days
});




}
/// @nodoc
class _$TrashPreferencesCopyWithImpl<$Res>
    implements $TrashPreferencesCopyWith<$Res> {
  _$TrashPreferencesCopyWithImpl(this._self, this._then);

  final TrashPreferences _self;
  final $Res Function(TrashPreferences) _then;

/// Create a copy of TrashPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = freezed,Object? days = freezed,}) {
  return _then(TrashPreferences(
enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,days: freezed == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrashPreferences].
extension TrashPreferencesPatterns on TrashPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashPreferences value)  $default,){
final _that = this;
switch (_that) {
case _TrashPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _TrashPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? enabled,  int? days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashPreferences() when $default != null:
return $default(_that.enabled,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? enabled,  int? days)  $default,) {final _that = this;
switch (_that) {
case _TrashPreferences():
return $default(_that.enabled,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? enabled,  int? days)?  $default,) {final _that = this;
switch (_that) {
case _TrashPreferences() when $default != null:
return $default(_that.enabled,_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _TrashPreferences implements TrashPreferences {
  const _TrashPreferences({this.enabled, this.days});
  

@override final  bool? enabled;
@override final  int? days;

/// Create a copy of TrashPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashPreferencesCopyWith<_TrashPreferences> get copyWith => __$TrashPreferencesCopyWithImpl<_TrashPreferences>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashPreferences&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.days, days) || other.days == days));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,days);
}

@override
String toString() {
    return 'TrashPreferences(enabled: $enabled, days: $days)';
}


}

/// @nodoc
abstract mixin class _$TrashPreferencesCopyWith<$Res> implements $TrashPreferencesCopyWith<$Res> {
  factory _$TrashPreferencesCopyWith(_TrashPreferences value, $Res Function(_TrashPreferences) _then) = __$TrashPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool? enabled, int? days
});




}
/// @nodoc
class __$TrashPreferencesCopyWithImpl<$Res>
    implements _$TrashPreferencesCopyWith<$Res> {
  __$TrashPreferencesCopyWithImpl(this._self, this._then);

  final _TrashPreferences _self;
  final $Res Function(_TrashPreferences) _then;

/// Create a copy of TrashPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = freezed,Object? days = freezed,}) {
  return _then(_TrashPreferences(
enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,days: freezed == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$TrashListing {

 List<TrashItem> get items; int get totalBytes; TrashRetention get retention;
/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrashListingCopyWith<TrashListing> get copyWith => _$TrashListingCopyWithImpl<TrashListing>(this as TrashListing, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrashListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrashListing&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.totalBytes, _this.totalBytes) || other.totalBytes == _this.totalBytes)&&(identical(other.retention, _this.retention) || other.retention == _this.retention));
}


@override
int get hashCode {
  final _this = this as TrashListing;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.totalBytes,_this.retention);
}

@override
String toString() {
  final _this = this as TrashListing;
  return 'TrashListing(items: ${_this.items}, totalBytes: ${_this.totalBytes}, retention: ${_this.retention})';
}


}

/// @nodoc
abstract mixin class $TrashListingCopyWith<$Res>  {
  factory $TrashListingCopyWith(TrashListing value, $Res Function(TrashListing) _then) = _$TrashListingCopyWithImpl;
@useResult
$Res call({
 List<TrashItem> items, int totalBytes, TrashRetention retention
});


$TrashRetentionCopyWith<$Res> get retention;

}
/// @nodoc
class _$TrashListingCopyWithImpl<$Res>
    implements $TrashListingCopyWith<$Res> {
  _$TrashListingCopyWithImpl(this._self, this._then);

  final TrashListing _self;
  final $Res Function(TrashListing) _then;

/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalBytes = null,Object? retention = null,}) {
  return _then(TrashListing(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TrashItem>,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,retention: null == retention ? _self.retention : retention // ignore: cast_nullable_to_non_nullable
as TrashRetention,
  ));
}
/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrashRetentionCopyWith<$Res> get retention {
  
  return $TrashRetentionCopyWith<$Res>(_self.retention, (value) {
    return _then(_self.copyWith(retention: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrashListing].
extension TrashListingPatterns on TrashListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrashListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrashListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrashListing value)  $default,){
final _that = this;
switch (_that) {
case _TrashListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrashListing value)?  $default,){
final _that = this;
switch (_that) {
case _TrashListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrashItem> items,  int totalBytes,  TrashRetention retention)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrashListing() when $default != null:
return $default(_that.items,_that.totalBytes,_that.retention);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrashItem> items,  int totalBytes,  TrashRetention retention)  $default,) {final _that = this;
switch (_that) {
case _TrashListing():
return $default(_that.items,_that.totalBytes,_that.retention);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrashItem> items,  int totalBytes,  TrashRetention retention)?  $default,) {final _that = this;
switch (_that) {
case _TrashListing() when $default != null:
return $default(_that.items,_that.totalBytes,_that.retention);case _:
  return null;

}
}

}

/// @nodoc


class _TrashListing implements TrashListing {
  const _TrashListing({ List<TrashItem> items = const <TrashItem>[], this.totalBytes = 0, required this.retention}): _items = items;
  

 final  List<TrashItem> _items;
@override@JsonKey() List<TrashItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int totalBytes;
@override final  TrashRetention retention;

/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrashListingCopyWith<_TrashListing> get copyWith => __$TrashListingCopyWithImpl<_TrashListing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrashListing&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.retention, retention) || other.retention == retention));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalBytes,retention);
}

@override
String toString() {
    return 'TrashListing(items: $items, totalBytes: $totalBytes, retention: $retention)';
}


}

/// @nodoc
abstract mixin class _$TrashListingCopyWith<$Res> implements $TrashListingCopyWith<$Res> {
  factory _$TrashListingCopyWith(_TrashListing value, $Res Function(_TrashListing) _then) = __$TrashListingCopyWithImpl;
@override @useResult
$Res call({
 List<TrashItem> items, int totalBytes, TrashRetention retention
});


@override $TrashRetentionCopyWith<$Res> get retention;

}
/// @nodoc
class __$TrashListingCopyWithImpl<$Res>
    implements _$TrashListingCopyWith<$Res> {
  __$TrashListingCopyWithImpl(this._self, this._then);

  final _TrashListing _self;
  final $Res Function(_TrashListing) _then;

/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalBytes = null,Object? retention = null,}) {
  return _then(_TrashListing(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TrashItem>,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,retention: null == retention ? _self.retention : retention // ignore: cast_nullable_to_non_nullable
as TrashRetention,
  ));
}

/// Create a copy of TrashListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrashRetentionCopyWith<$Res> get retention {
  
  return $TrashRetentionCopyWith<$Res>(_self.retention, (value) {
    return _then(_self.copyWith(retention: value));
  });
}
}

// dart format on
