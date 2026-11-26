// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShareNotice {

 int get shareId; String get ownerName; String get owner; String get name; bool get isDir; String get note; String? get group; String? get server;
/// Create a copy of ShareNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareNoticeCopyWith<ShareNotice> get copyWith => _$ShareNoticeCopyWithImpl<ShareNotice>(this as ShareNotice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShareNotice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareNotice&&(identical(other.shareId, _this.shareId) || other.shareId == _this.shareId)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.server, _this.server) || other.server == _this.server));
}


@override
int get hashCode {
  final _this = this as ShareNotice;
  return Object.hash(runtimeType,_this.shareId,_this.ownerName,_this.owner,_this.name,_this.isDir,_this.note,_this.group,_this.server);
}

@override
String toString() {
  final _this = this as ShareNotice;
  return 'ShareNotice(shareId: ${_this.shareId}, ownerName: ${_this.ownerName}, owner: ${_this.owner}, name: ${_this.name}, isDir: ${_this.isDir}, note: ${_this.note}, group: ${_this.group}, server: ${_this.server})';
}


}

/// @nodoc
abstract mixin class $ShareNoticeCopyWith<$Res>  {
  factory $ShareNoticeCopyWith(ShareNotice value, $Res Function(ShareNotice) _then) = _$ShareNoticeCopyWithImpl;
@useResult
$Res call({
 int shareId, String ownerName, String owner, String name, bool isDir, String note, String? group, String? server
});




}
/// @nodoc
class _$ShareNoticeCopyWithImpl<$Res>
    implements $ShareNoticeCopyWith<$Res> {
  _$ShareNoticeCopyWithImpl(this._self, this._then);

  final ShareNotice _self;
  final $Res Function(ShareNotice) _then;

/// Create a copy of ShareNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shareId = null,Object? ownerName = null,Object? owner = null,Object? name = null,Object? isDir = null,Object? note = null,Object? group = freezed,Object? server = freezed,}) {
  return _then(ShareNotice(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareNotice].
extension ShareNoticePatterns on ShareNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareNotice value)  $default,){
final _that = this;
switch (_that) {
case _ShareNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareNotice value)?  $default,){
final _that = this;
switch (_that) {
case _ShareNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int shareId,  String ownerName,  String owner,  String name,  bool isDir,  String note,  String? group,  String? server)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareNotice() when $default != null:
return $default(_that.shareId,_that.ownerName,_that.owner,_that.name,_that.isDir,_that.note,_that.group,_that.server);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int shareId,  String ownerName,  String owner,  String name,  bool isDir,  String note,  String? group,  String? server)  $default,) {final _that = this;
switch (_that) {
case _ShareNotice():
return $default(_that.shareId,_that.ownerName,_that.owner,_that.name,_that.isDir,_that.note,_that.group,_that.server);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int shareId,  String ownerName,  String owner,  String name,  bool isDir,  String note,  String? group,  String? server)?  $default,) {final _that = this;
switch (_that) {
case _ShareNotice() when $default != null:
return $default(_that.shareId,_that.ownerName,_that.owner,_that.name,_that.isDir,_that.note,_that.group,_that.server);case _:
  return null;

}
}

}

/// @nodoc


class _ShareNotice implements ShareNotice {
  const _ShareNotice({required this.shareId, required this.ownerName, required this.owner, required this.name, this.isDir = false, this.note = "", this.group, this.server});
  

@override final  int shareId;
@override final  String ownerName;
@override final  String owner;
@override final  String name;
@override@JsonKey() final  bool isDir;
@override@JsonKey() final  String note;
@override final  String? group;
@override final  String? server;

/// Create a copy of ShareNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareNoticeCopyWith<_ShareNotice> get copyWith => __$ShareNoticeCopyWithImpl<_ShareNotice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareNotice&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDir, isDir) || other.isDir == isDir)&&(identical(other.note, note) || other.note == note)&&(identical(other.group, group) || other.group == group)&&(identical(other.server, server) || other.server == server));
}


@override
int get hashCode {
    return Object.hash(runtimeType,shareId,ownerName,owner,name,isDir,note,group,server);
}

@override
String toString() {
    return 'ShareNotice(shareId: $shareId, ownerName: $ownerName, owner: $owner, name: $name, isDir: $isDir, note: $note, group: $group, server: $server)';
}


}

/// @nodoc
abstract mixin class _$ShareNoticeCopyWith<$Res> implements $ShareNoticeCopyWith<$Res> {
  factory _$ShareNoticeCopyWith(_ShareNotice value, $Res Function(_ShareNotice) _then) = __$ShareNoticeCopyWithImpl;
@override @useResult
$Res call({
 int shareId, String ownerName, String owner, String name, bool isDir, String note, String? group, String? server
});




}
/// @nodoc
class __$ShareNoticeCopyWithImpl<$Res>
    implements _$ShareNoticeCopyWith<$Res> {
  __$ShareNoticeCopyWithImpl(this._self, this._then);

  final _ShareNotice _self;
  final $Res Function(_ShareNotice) _then;

/// Create a copy of ShareNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shareId = null,Object? ownerName = null,Object? owner = null,Object? name = null,Object? isDir = null,Object? note = null,Object? group = freezed,Object? server = freezed,}) {
  return _then(_ShareNotice(
shareId: null == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$FeedNotification {

 int get id; FeedNotificationKind get kind; DateTime get createdAt; bool get read; ShareNotice? get share;
/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedNotificationCopyWith<FeedNotification> get copyWith => _$FeedNotificationCopyWithImpl<FeedNotification>(this as FeedNotification, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeedNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedNotification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.read, _this.read) || other.read == _this.read)&&(identical(other.share, _this.share) || other.share == _this.share));
}


@override
int get hashCode {
  final _this = this as FeedNotification;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.createdAt,_this.read,_this.share);
}

@override
String toString() {
  final _this = this as FeedNotification;
  return 'FeedNotification(id: ${_this.id}, kind: ${_this.kind}, createdAt: ${_this.createdAt}, read: ${_this.read}, share: ${_this.share})';
}


}

/// @nodoc
abstract mixin class $FeedNotificationCopyWith<$Res>  {
  factory $FeedNotificationCopyWith(FeedNotification value, $Res Function(FeedNotification) _then) = _$FeedNotificationCopyWithImpl;
@useResult
$Res call({
 int id, FeedNotificationKind kind, DateTime createdAt, bool read, ShareNotice? share
});


$ShareNoticeCopyWith<$Res>? get share;

}
/// @nodoc
class _$FeedNotificationCopyWithImpl<$Res>
    implements $FeedNotificationCopyWith<$Res> {
  _$FeedNotificationCopyWithImpl(this._self, this._then);

  final FeedNotification _self;
  final $Res Function(FeedNotification) _then;

/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? createdAt = null,Object? read = null,Object? share = freezed,}) {
  return _then(FeedNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FeedNotificationKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as ShareNotice?,
  ));
}
/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareNoticeCopyWith<$Res>? get share {
    if (_self.share == null) {
    return null;
  }

  return $ShareNoticeCopyWith<$Res>(_self.share!, (value) {
    return _then(_self.copyWith(share: value));
  });
}
}


/// Adds pattern-matching-related methods to [FeedNotification].
extension FeedNotificationPatterns on FeedNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedNotification value)  $default,){
final _that = this;
switch (_that) {
case _FeedNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedNotification value)?  $default,){
final _that = this;
switch (_that) {
case _FeedNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  FeedNotificationKind kind,  DateTime createdAt,  bool read,  ShareNotice? share)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedNotification() when $default != null:
return $default(_that.id,_that.kind,_that.createdAt,_that.read,_that.share);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  FeedNotificationKind kind,  DateTime createdAt,  bool read,  ShareNotice? share)  $default,) {final _that = this;
switch (_that) {
case _FeedNotification():
return $default(_that.id,_that.kind,_that.createdAt,_that.read,_that.share);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  FeedNotificationKind kind,  DateTime createdAt,  bool read,  ShareNotice? share)?  $default,) {final _that = this;
switch (_that) {
case _FeedNotification() when $default != null:
return $default(_that.id,_that.kind,_that.createdAt,_that.read,_that.share);case _:
  return null;

}
}

}

/// @nodoc


class _FeedNotification extends FeedNotification {
  const _FeedNotification({required this.id, required this.kind, required this.createdAt, this.read = false, this.share}): super._();
  

@override final  int id;
@override final  FeedNotificationKind kind;
@override final  DateTime createdAt;
@override@JsonKey() final  bool read;
@override final  ShareNotice? share;

/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedNotificationCopyWith<_FeedNotification> get copyWith => __$FeedNotificationCopyWithImpl<_FeedNotification>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.read, read) || other.read == read)&&(identical(other.share, share) || other.share == share));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,createdAt,read,share);
}

@override
String toString() {
    return 'FeedNotification(id: $id, kind: $kind, createdAt: $createdAt, read: $read, share: $share)';
}


}

/// @nodoc
abstract mixin class _$FeedNotificationCopyWith<$Res> implements $FeedNotificationCopyWith<$Res> {
  factory _$FeedNotificationCopyWith(_FeedNotification value, $Res Function(_FeedNotification) _then) = __$FeedNotificationCopyWithImpl;
@override @useResult
$Res call({
 int id, FeedNotificationKind kind, DateTime createdAt, bool read, ShareNotice? share
});


@override $ShareNoticeCopyWith<$Res>? get share;

}
/// @nodoc
class __$FeedNotificationCopyWithImpl<$Res>
    implements _$FeedNotificationCopyWith<$Res> {
  __$FeedNotificationCopyWithImpl(this._self, this._then);

  final _FeedNotification _self;
  final $Res Function(_FeedNotification) _then;

/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? createdAt = null,Object? read = null,Object? share = freezed,}) {
  return _then(_FeedNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FeedNotificationKind,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as ShareNotice?,
  ));
}

/// Create a copy of FeedNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareNoticeCopyWith<$Res>? get share {
    if (_self.share == null) {
    return null;
  }

  return $ShareNoticeCopyWith<$Res>(_self.share!, (value) {
    return _then(_self.copyWith(share: value));
  });
}
}

/// @nodoc
mixin _$FeedPage {

 List<FeedNotification> get notifications; int get cursor; bool get hasMore;
/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedPageCopyWith<FeedPage> get copyWith => _$FeedPageCopyWithImpl<FeedPage>(this as FeedPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeedPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedPage&&const DeepCollectionEquality().equals(other.notifications, _this.notifications)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore));
}


@override
int get hashCode {
  final _this = this as FeedPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.notifications),_this.cursor,_this.hasMore);
}

@override
String toString() {
  final _this = this as FeedPage;
  return 'FeedPage(notifications: ${_this.notifications}, cursor: ${_this.cursor}, hasMore: ${_this.hasMore})';
}


}

/// @nodoc
abstract mixin class $FeedPageCopyWith<$Res>  {
  factory $FeedPageCopyWith(FeedPage value, $Res Function(FeedPage) _then) = _$FeedPageCopyWithImpl;
@useResult
$Res call({
 List<FeedNotification> notifications, int cursor, bool hasMore
});




}
/// @nodoc
class _$FeedPageCopyWithImpl<$Res>
    implements $FeedPageCopyWith<$Res> {
  _$FeedPageCopyWithImpl(this._self, this._then);

  final FeedPage _self;
  final $Res Function(FeedPage) _then;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notifications = null,Object? cursor = null,Object? hasMore = null,}) {
  return _then(FeedPage(
notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<FeedNotification>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedPage].
extension FeedPagePatterns on FeedPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedPage value)  $default,){
final _that = this;
switch (_that) {
case _FeedPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedPage value)?  $default,){
final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FeedNotification> notifications,  int cursor,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
return $default(_that.notifications,_that.cursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FeedNotification> notifications,  int cursor,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _FeedPage():
return $default(_that.notifications,_that.cursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FeedNotification> notifications,  int cursor,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
return $default(_that.notifications,_that.cursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _FeedPage implements FeedPage {
  const _FeedPage({ List<FeedNotification> notifications = const <FeedNotification>[], required this.cursor, this.hasMore = false}): _notifications = notifications;
  

 final  List<FeedNotification> _notifications;
@override@JsonKey() List<FeedNotification> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override final  int cursor;
@override@JsonKey() final  bool hasMore;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedPageCopyWith<_FeedPage> get copyWith => __$FeedPageCopyWithImpl<_FeedPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedPage&&const DeepCollectionEquality().equals(other.notifications, _notifications)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_notifications),cursor,hasMore);
}

@override
String toString() {
    return 'FeedPage(notifications: $notifications, cursor: $cursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$FeedPageCopyWith<$Res> implements $FeedPageCopyWith<$Res> {
  factory _$FeedPageCopyWith(_FeedPage value, $Res Function(_FeedPage) _then) = __$FeedPageCopyWithImpl;
@override @useResult
$Res call({
 List<FeedNotification> notifications, int cursor, bool hasMore
});




}
/// @nodoc
class __$FeedPageCopyWithImpl<$Res>
    implements _$FeedPageCopyWith<$Res> {
  __$FeedPageCopyWithImpl(this._self, this._then);

  final _FeedPage _self;
  final $Res Function(_FeedPage) _then;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notifications = null,Object? cursor = null,Object? hasMore = null,}) {
  return _then(_FeedPage(
notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<FeedNotification>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
