// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityEntry {

 int get id; int get userId; String get username; String get device; ActivityKind get kind; String get path; String? get fromPath; bool get isDir; int? get size; int? get bytes; int? get durationMs; int? get count; ActivityStatus get status; String get detail; DateTime get createdAt;
/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEntryCopyWith<ActivityEntry> get copyWith => _$ActivityEntryCopyWithImpl<ActivityEntry>(this as ActivityEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.fromPath, _this.fromPath) || other.fromPath == _this.fromPath)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as ActivityEntry;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.username,_this.device,_this.kind,_this.path,_this.fromPath,_this.isDir,_this.size,_this.bytes,_this.durationMs,_this.count,_this.status,_this.detail,_this.createdAt);
}

@override
String toString() {
  final _this = this as ActivityEntry;
  return 'ActivityEntry(id: ${_this.id}, userId: ${_this.userId}, username: ${_this.username}, device: ${_this.device}, kind: ${_this.kind}, path: ${_this.path}, fromPath: ${_this.fromPath}, isDir: ${_this.isDir}, size: ${_this.size}, bytes: ${_this.bytes}, durationMs: ${_this.durationMs}, count: ${_this.count}, status: ${_this.status}, detail: ${_this.detail}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ActivityEntryCopyWith<$Res>  {
  factory $ActivityEntryCopyWith(ActivityEntry value, $Res Function(ActivityEntry) _then) = _$ActivityEntryCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String username, String device, ActivityKind kind, String path, String? fromPath, bool isDir, int? size, int? bytes, int? durationMs, int? count, ActivityStatus status, String detail, DateTime createdAt
});




}
/// @nodoc
class _$ActivityEntryCopyWithImpl<$Res>
    implements $ActivityEntryCopyWith<$Res> {
  _$ActivityEntryCopyWithImpl(this._self, this._then);

  final ActivityEntry _self;
  final $Res Function(ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? username = null,Object? device = null,Object? kind = null,Object? path = null,Object? fromPath = freezed,Object? isDir = null,Object? size = freezed,Object? bytes = freezed,Object? durationMs = freezed,Object? count = freezed,Object? status = null,Object? detail = null,Object? createdAt = null,}) {
  return _then(ActivityEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActivityKind,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fromPath: freezed == fromPath ? _self.fromPath : fromPath // ignore: cast_nullable_to_non_nullable
as String?,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,bytes: freezed == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityEntry].
extension ActivityEntryPatterns on ActivityEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEntry value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String username,  String device,  ActivityKind kind,  String path,  String? fromPath,  bool isDir,  int? size,  int? bytes,  int? durationMs,  int? count,  ActivityStatus status,  String detail,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.device,_that.kind,_that.path,_that.fromPath,_that.isDir,_that.size,_that.bytes,_that.durationMs,_that.count,_that.status,_that.detail,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String username,  String device,  ActivityKind kind,  String path,  String? fromPath,  bool isDir,  int? size,  int? bytes,  int? durationMs,  int? count,  ActivityStatus status,  String detail,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry():
return $default(_that.id,_that.userId,_that.username,_that.device,_that.kind,_that.path,_that.fromPath,_that.isDir,_that.size,_that.bytes,_that.durationMs,_that.count,_that.status,_that.detail,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String username,  String device,  ActivityKind kind,  String path,  String? fromPath,  bool isDir,  int? size,  int? bytes,  int? durationMs,  int? count,  ActivityStatus status,  String detail,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.device,_that.kind,_that.path,_that.fromPath,_that.isDir,_that.size,_that.bytes,_that.durationMs,_that.count,_that.status,_that.detail,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityEntry extends ActivityEntry {
  const _ActivityEntry({required this.id, required this.userId, required this.username, required this.device, required this.kind, required this.path, this.fromPath, this.isDir = false, this.size, this.bytes, this.durationMs, this.count, this.status = ActivityStatus.ok, this.detail = "", required this.createdAt}): super._();
  

@override final  int id;
@override final  int userId;
@override final  String username;
@override final  String device;
@override final  ActivityKind kind;
@override final  String path;
@override final  String? fromPath;
@override@JsonKey() final  bool isDir;
@override final  int? size;
@override final  int? bytes;
@override final  int? durationMs;
@override final  int? count;
@override@JsonKey() final  ActivityStatus status;
@override@JsonKey() final  String detail;
@override final  DateTime createdAt;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEntryCopyWith<_ActivityEntry> get copyWith => __$ActivityEntryCopyWithImpl<_ActivityEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.device, device) || other.device == device)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.path, path) || other.path == path)&&(identical(other.fromPath, fromPath) || other.fromPath == fromPath)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.size, size) || other.size == size)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.count, count) || other.count == count)&&(identical(other.status, status) || other.status == status)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,username,device,kind,path,fromPath,isDir,size,bytes,durationMs,count,status,detail,createdAt);
}

@override
String toString() {
    return 'ActivityEntry(id: $id, userId: $userId, username: $username, device: $device, kind: $kind, path: $path, fromPath: $fromPath, isDir: $isDir, size: $size, bytes: $bytes, durationMs: $durationMs, count: $count, status: $status, detail: $detail, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ActivityEntryCopyWith<$Res> implements $ActivityEntryCopyWith<$Res> {
  factory _$ActivityEntryCopyWith(_ActivityEntry value, $Res Function(_ActivityEntry) _then) = __$ActivityEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String username, String device, ActivityKind kind, String path, String? fromPath, bool isDir, int? size, int? bytes, int? durationMs, int? count, ActivityStatus status, String detail, DateTime createdAt
});




}
/// @nodoc
class __$ActivityEntryCopyWithImpl<$Res>
    implements _$ActivityEntryCopyWith<$Res> {
  __$ActivityEntryCopyWithImpl(this._self, this._then);

  final _ActivityEntry _self;
  final $Res Function(_ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? username = null,Object? device = null,Object? kind = null,Object? path = null,Object? fromPath = freezed,Object? isDir = null,Object? size = freezed,Object? bytes = freezed,Object? durationMs = freezed,Object? count = freezed,Object? status = null,Object? detail = null,Object? createdAt = null,}) {
  return _then(_ActivityEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActivityKind,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fromPath: freezed == fromPath ? _self.fromPath : fromPath // ignore: cast_nullable_to_non_nullable
as String?,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,bytes: freezed == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ActivityPage {

 List<ActivityEntry> get entries; int get nextCursor;
/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityPageCopyWith<ActivityPage> get copyWith => _$ActivityPageCopyWithImpl<ActivityPage>(this as ActivityPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityPage&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}


@override
int get hashCode {
  final _this = this as ActivityPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),_this.nextCursor);
}

@override
String toString() {
  final _this = this as ActivityPage;
  return 'ActivityPage(entries: ${_this.entries}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $ActivityPageCopyWith<$Res>  {
  factory $ActivityPageCopyWith(ActivityPage value, $Res Function(ActivityPage) _then) = _$ActivityPageCopyWithImpl;
@useResult
$Res call({
 List<ActivityEntry> entries, int nextCursor
});




}
/// @nodoc
class _$ActivityPageCopyWithImpl<$Res>
    implements $ActivityPageCopyWith<$Res> {
  _$ActivityPageCopyWithImpl(this._self, this._then);

  final ActivityPage _self;
  final $Res Function(ActivityPage) _then;

/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? nextCursor = null,}) {
  return _then(ActivityPage(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ActivityEntry>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityPage].
extension ActivityPagePatterns on ActivityPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityPage value)  $default,){
final _that = this;
switch (_that) {
case _ActivityPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityPage value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ActivityEntry> entries,  int nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
return $default(_that.entries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ActivityEntry> entries,  int nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ActivityPage():
return $default(_that.entries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ActivityEntry> entries,  int nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ActivityPage() when $default != null:
return $default(_that.entries,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityPage implements ActivityPage {
  const _ActivityPage({ List<ActivityEntry> entries = const <ActivityEntry>[], this.nextCursor = 0}): _entries = entries;
  

 final  List<ActivityEntry> _entries;
@override@JsonKey() List<ActivityEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override@JsonKey() final  int nextCursor;

/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityPageCopyWith<_ActivityPage> get copyWith => __$ActivityPageCopyWithImpl<_ActivityPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityPage&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),nextCursor);
}

@override
String toString() {
    return 'ActivityPage(entries: $entries, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ActivityPageCopyWith<$Res> implements $ActivityPageCopyWith<$Res> {
  factory _$ActivityPageCopyWith(_ActivityPage value, $Res Function(_ActivityPage) _then) = __$ActivityPageCopyWithImpl;
@override @useResult
$Res call({
 List<ActivityEntry> entries, int nextCursor
});




}
/// @nodoc
class __$ActivityPageCopyWithImpl<$Res>
    implements _$ActivityPageCopyWith<$Res> {
  __$ActivityPageCopyWithImpl(this._self, this._then);

  final _ActivityPage _self;
  final $Res Function(_ActivityPage) _then;

/// Create a copy of ActivityPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? nextCursor = null,}) {
  return _then(_ActivityPage(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ActivityEntry>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$LiveTransfer {

 String get id; int get userId; String get username; TransferDirectionKind get direction; String get path; String get device; String? get clientId; int get bytes; int? get total; int get rate; DateTime get startedAt;
/// Create a copy of LiveTransfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveTransferCopyWith<LiveTransfer> get copyWith => _$LiveTransferCopyWithImpl<LiveTransfer>(this as LiveTransfer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveTransfer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveTransfer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.clientId, _this.clientId) || other.clientId == _this.clientId)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt));
}


@override
int get hashCode {
  final _this = this as LiveTransfer;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.username,_this.direction,_this.path,_this.device,_this.clientId,_this.bytes,_this.total,_this.rate,_this.startedAt);
}

@override
String toString() {
  final _this = this as LiveTransfer;
  return 'LiveTransfer(id: ${_this.id}, userId: ${_this.userId}, username: ${_this.username}, direction: ${_this.direction}, path: ${_this.path}, device: ${_this.device}, clientId: ${_this.clientId}, bytes: ${_this.bytes}, total: ${_this.total}, rate: ${_this.rate}, startedAt: ${_this.startedAt})';
}


}

/// @nodoc
abstract mixin class $LiveTransferCopyWith<$Res>  {
  factory $LiveTransferCopyWith(LiveTransfer value, $Res Function(LiveTransfer) _then) = _$LiveTransferCopyWithImpl;
@useResult
$Res call({
 String id, int userId, String username, TransferDirectionKind direction, String path, String device, String? clientId, int bytes, int? total, int rate, DateTime startedAt
});




}
/// @nodoc
class _$LiveTransferCopyWithImpl<$Res>
    implements $LiveTransferCopyWith<$Res> {
  _$LiveTransferCopyWithImpl(this._self, this._then);

  final LiveTransfer _self;
  final $Res Function(LiveTransfer) _then;

/// Create a copy of LiveTransfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? username = null,Object? direction = null,Object? path = null,Object? device = null,Object? clientId = freezed,Object? bytes = null,Object? total = freezed,Object? rate = null,Object? startedAt = null,}) {
  return _then(LiveTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirectionKind,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveTransfer].
extension LiveTransferPatterns on LiveTransfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveTransfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveTransfer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveTransfer value)  $default,){
final _that = this;
switch (_that) {
case _LiveTransfer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveTransfer value)?  $default,){
final _that = this;
switch (_that) {
case _LiveTransfer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int userId,  String username,  TransferDirectionKind direction,  String path,  String device,  String? clientId,  int bytes,  int? total,  int rate,  DateTime startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveTransfer() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.direction,_that.path,_that.device,_that.clientId,_that.bytes,_that.total,_that.rate,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int userId,  String username,  TransferDirectionKind direction,  String path,  String device,  String? clientId,  int bytes,  int? total,  int rate,  DateTime startedAt)  $default,) {final _that = this;
switch (_that) {
case _LiveTransfer():
return $default(_that.id,_that.userId,_that.username,_that.direction,_that.path,_that.device,_that.clientId,_that.bytes,_that.total,_that.rate,_that.startedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int userId,  String username,  TransferDirectionKind direction,  String path,  String device,  String? clientId,  int bytes,  int? total,  int rate,  DateTime startedAt)?  $default,) {final _that = this;
switch (_that) {
case _LiveTransfer() when $default != null:
return $default(_that.id,_that.userId,_that.username,_that.direction,_that.path,_that.device,_that.clientId,_that.bytes,_that.total,_that.rate,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LiveTransfer extends LiveTransfer {
  const _LiveTransfer({required this.id, required this.userId, required this.username, required this.direction, required this.path, required this.device, this.clientId, this.bytes = 0, this.total, this.rate = 0, required this.startedAt}): super._();
  

@override final  String id;
@override final  int userId;
@override final  String username;
@override final  TransferDirectionKind direction;
@override final  String path;
@override final  String device;
@override final  String? clientId;
@override@JsonKey() final  int bytes;
@override final  int? total;
@override@JsonKey() final  int rate;
@override final  DateTime startedAt;

/// Create a copy of LiveTransfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveTransferCopyWith<_LiveTransfer> get copyWith => __$LiveTransferCopyWithImpl<_LiveTransfer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveTransfer&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.path, path) || other.path == path)&&(identical(other.device, device) || other.device == device)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.bytes, bytes) || other.bytes == bytes)&&(identical(other.total, total) || other.total == total)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,username,direction,path,device,clientId,bytes,total,rate,startedAt);
}

@override
String toString() {
    return 'LiveTransfer(id: $id, userId: $userId, username: $username, direction: $direction, path: $path, device: $device, clientId: $clientId, bytes: $bytes, total: $total, rate: $rate, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$LiveTransferCopyWith<$Res> implements $LiveTransferCopyWith<$Res> {
  factory _$LiveTransferCopyWith(_LiveTransfer value, $Res Function(_LiveTransfer) _then) = __$LiveTransferCopyWithImpl;
@override @useResult
$Res call({
 String id, int userId, String username, TransferDirectionKind direction, String path, String device, String? clientId, int bytes, int? total, int rate, DateTime startedAt
});




}
/// @nodoc
class __$LiveTransferCopyWithImpl<$Res>
    implements _$LiveTransferCopyWith<$Res> {
  __$LiveTransferCopyWithImpl(this._self, this._then);

  final _LiveTransfer _self;
  final $Res Function(_LiveTransfer) _then;

/// Create a copy of LiveTransfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? username = null,Object? direction = null,Object? path = null,Object? device = null,Object? clientId = freezed,Object? bytes = null,Object? total = freezed,Object? rate = null,Object? startedAt = null,}) {
  return _then(_LiveTransfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirectionKind,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ActivityScope {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ActivityScope()';
}


}

/// @nodoc
class $ActivityScopeCopyWith<$Res>  {
$ActivityScopeCopyWith(ActivityScope _, $Res Function(ActivityScope) __);
}


/// Adds pattern-matching-related methods to [ActivityScope].
extension ActivityScopePatterns on ActivityScope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ActivityScopeMe value)?  me,TResult Function( ActivityScopeAll value)?  all,TResult Function( ActivityScopeUser value)?  user,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ActivityScopeMe() when me != null:
return me(_that);case ActivityScopeAll() when all != null:
return all(_that);case ActivityScopeUser() when user != null:
return user(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ActivityScopeMe value)  me,required TResult Function( ActivityScopeAll value)  all,required TResult Function( ActivityScopeUser value)  user,}){
final _that = this;
switch (_that) {
case ActivityScopeMe():
return me(_that);case ActivityScopeAll():
return all(_that);case ActivityScopeUser():
return user(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ActivityScopeMe value)?  me,TResult? Function( ActivityScopeAll value)?  all,TResult? Function( ActivityScopeUser value)?  user,}){
final _that = this;
switch (_that) {
case ActivityScopeMe() when me != null:
return me(_that);case ActivityScopeAll() when all != null:
return all(_that);case ActivityScopeUser() when user != null:
return user(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  me,TResult Function()?  all,TResult Function( int id,  String username)?  user,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ActivityScopeMe() when me != null:
return me();case ActivityScopeAll() when all != null:
return all();case ActivityScopeUser() when user != null:
return user(_that.id,_that.username);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  me,required TResult Function()  all,required TResult Function( int id,  String username)  user,}) {final _that = this;
switch (_that) {
case ActivityScopeMe():
return me();case ActivityScopeAll():
return all();case ActivityScopeUser():
return user(_that.id,_that.username);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  me,TResult? Function()?  all,TResult? Function( int id,  String username)?  user,}) {final _that = this;
switch (_that) {
case ActivityScopeMe() when me != null:
return me();case ActivityScopeAll() when all != null:
return all();case ActivityScopeUser() when user != null:
return user(_that.id,_that.username);case _:
  return null;

}
}

}

/// @nodoc


class ActivityScopeMe extends ActivityScope {
  const ActivityScopeMe(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityScopeMe);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ActivityScope.me()';
}


}




/// @nodoc


class ActivityScopeAll extends ActivityScope {
  const ActivityScopeAll(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityScopeAll);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ActivityScope.all()';
}


}




/// @nodoc


class ActivityScopeUser extends ActivityScope {
  const ActivityScopeUser({required this.id, required this.username}): super._();
  

 final  int id;
 final  String username;

/// Create a copy of ActivityScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityScopeUserCopyWith<ActivityScopeUser> get copyWith => _$ActivityScopeUserCopyWithImpl<ActivityScopeUser>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityScopeUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,username);
}

@override
String toString() {
    return 'ActivityScope.user(id: $id, username: $username)';
}


}

/// @nodoc
abstract mixin class $ActivityScopeUserCopyWith<$Res> implements $ActivityScopeCopyWith<$Res> {
  factory $ActivityScopeUserCopyWith(ActivityScopeUser value, $Res Function(ActivityScopeUser) _then) = _$ActivityScopeUserCopyWithImpl;
@useResult
$Res call({
 int id, String username
});




}
/// @nodoc
class _$ActivityScopeUserCopyWithImpl<$Res>
    implements $ActivityScopeUserCopyWith<$Res> {
  _$ActivityScopeUserCopyWithImpl(this._self, this._then);

  final ActivityScopeUser _self;
  final $Res Function(ActivityScopeUser) _then;

/// Create a copy of ActivityScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,}) {
  return _then(ActivityScopeUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
