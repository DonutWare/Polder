// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarSummary {

 int get id; String get uri; String get name; Color? get color; CalendarAccess get access; bool get subscription; String? get ownerName;
/// Create a copy of CalendarSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarSummaryCopyWith<CalendarSummary> get copyWith => _$CalendarSummaryCopyWithImpl<CalendarSummary>(this as CalendarSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.access, _this.access) || other.access == _this.access)&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName));
}


@override
int get hashCode {
  final _this = this as CalendarSummary;
  return Object.hash(runtimeType,_this.id,_this.uri,_this.name,_this.color,_this.access,_this.subscription,_this.ownerName);
}

@override
String toString() {
  final _this = this as CalendarSummary;
  return 'CalendarSummary(id: ${_this.id}, uri: ${_this.uri}, name: ${_this.name}, color: ${_this.color}, access: ${_this.access}, subscription: ${_this.subscription}, ownerName: ${_this.ownerName})';
}


}

/// @nodoc
abstract mixin class $CalendarSummaryCopyWith<$Res>  {
  factory $CalendarSummaryCopyWith(CalendarSummary value, $Res Function(CalendarSummary) _then) = _$CalendarSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String uri, String name, Color? color, CalendarAccess access, bool subscription, String? ownerName
});




}
/// @nodoc
class _$CalendarSummaryCopyWithImpl<$Res>
    implements $CalendarSummaryCopyWith<$Res> {
  _$CalendarSummaryCopyWithImpl(this._self, this._then);

  final CalendarSummary _self;
  final $Res Function(CalendarSummary) _then;

/// Create a copy of CalendarSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uri = null,Object? name = null,Object? color = freezed,Object? access = null,Object? subscription = null,Object? ownerName = freezed,}) {
  return _then(CalendarSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarAccess,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarSummary].
extension CalendarSummaryPatterns on CalendarSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarSummary value)  $default,){
final _that = this;
switch (_that) {
case _CalendarSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String uri,  String name,  Color? color,  CalendarAccess access,  bool subscription,  String? ownerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarSummary() when $default != null:
return $default(_that.id,_that.uri,_that.name,_that.color,_that.access,_that.subscription,_that.ownerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String uri,  String name,  Color? color,  CalendarAccess access,  bool subscription,  String? ownerName)  $default,) {final _that = this;
switch (_that) {
case _CalendarSummary():
return $default(_that.id,_that.uri,_that.name,_that.color,_that.access,_that.subscription,_that.ownerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String uri,  String name,  Color? color,  CalendarAccess access,  bool subscription,  String? ownerName)?  $default,) {final _that = this;
switch (_that) {
case _CalendarSummary() when $default != null:
return $default(_that.id,_that.uri,_that.name,_that.color,_that.access,_that.subscription,_that.ownerName);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarSummary extends CalendarSummary {
  const _CalendarSummary({required this.id, required this.uri, required this.name, this.color, required this.access, this.subscription = false, this.ownerName}): super._();
  

@override final  int id;
@override final  String uri;
@override final  String name;
@override final  Color? color;
@override final  CalendarAccess access;
@override@JsonKey() final  bool subscription;
@override final  String? ownerName;

/// Create a copy of CalendarSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarSummaryCopyWith<_CalendarSummary> get copyWith => __$CalendarSummaryCopyWithImpl<_CalendarSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.access, access) || other.access == access)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,uri,name,color,access,subscription,ownerName);
}

@override
String toString() {
    return 'CalendarSummary(id: $id, uri: $uri, name: $name, color: $color, access: $access, subscription: $subscription, ownerName: $ownerName)';
}


}

/// @nodoc
abstract mixin class _$CalendarSummaryCopyWith<$Res> implements $CalendarSummaryCopyWith<$Res> {
  factory _$CalendarSummaryCopyWith(_CalendarSummary value, $Res Function(_CalendarSummary) _then) = __$CalendarSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String uri, String name, Color? color, CalendarAccess access, bool subscription, String? ownerName
});




}
/// @nodoc
class __$CalendarSummaryCopyWithImpl<$Res>
    implements _$CalendarSummaryCopyWith<$Res> {
  __$CalendarSummaryCopyWithImpl(this._self, this._then);

  final _CalendarSummary _self;
  final $Res Function(_CalendarSummary) _then;

/// Create a copy of CalendarSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uri = null,Object? name = null,Object? color = freezed,Object? access = null,Object? subscription = null,Object? ownerName = freezed,}) {
  return _then(_CalendarSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color?,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarAccess,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as bool,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CalendarFeed {

 int get id; int get calendarId; String get name; CalendarFeedMode get mode; DateTime get createdAt; DateTime? get lastUsedAt;
/// Create a copy of CalendarFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarFeedCopyWith<CalendarFeed> get copyWith => _$CalendarFeedCopyWithImpl<CalendarFeed>(this as CalendarFeed, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarFeed;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarFeed&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.calendarId, _this.calendarId) || other.calendarId == _this.calendarId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt));
}


@override
int get hashCode {
  final _this = this as CalendarFeed;
  return Object.hash(runtimeType,_this.id,_this.calendarId,_this.name,_this.mode,_this.createdAt,_this.lastUsedAt);
}

@override
String toString() {
  final _this = this as CalendarFeed;
  return 'CalendarFeed(id: ${_this.id}, calendarId: ${_this.calendarId}, name: ${_this.name}, mode: ${_this.mode}, createdAt: ${_this.createdAt}, lastUsedAt: ${_this.lastUsedAt})';
}


}

/// @nodoc
abstract mixin class $CalendarFeedCopyWith<$Res>  {
  factory $CalendarFeedCopyWith(CalendarFeed value, $Res Function(CalendarFeed) _then) = _$CalendarFeedCopyWithImpl;
@useResult
$Res call({
 int id, int calendarId, String name, CalendarFeedMode mode, DateTime createdAt, DateTime? lastUsedAt
});




}
/// @nodoc
class _$CalendarFeedCopyWithImpl<$Res>
    implements $CalendarFeedCopyWith<$Res> {
  _$CalendarFeedCopyWithImpl(this._self, this._then);

  final CalendarFeed _self;
  final $Res Function(CalendarFeed) _then;

/// Create a copy of CalendarFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? calendarId = null,Object? name = null,Object? mode = null,Object? createdAt = null,Object? lastUsedAt = freezed,}) {
  return _then(CalendarFeed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CalendarFeedMode,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarFeed].
extension CalendarFeedPatterns on CalendarFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarFeed value)  $default,){
final _that = this;
switch (_that) {
case _CalendarFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarFeed value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int calendarId,  String name,  CalendarFeedMode mode,  DateTime createdAt,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarFeed() when $default != null:
return $default(_that.id,_that.calendarId,_that.name,_that.mode,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int calendarId,  String name,  CalendarFeedMode mode,  DateTime createdAt,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarFeed():
return $default(_that.id,_that.calendarId,_that.name,_that.mode,_that.createdAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int calendarId,  String name,  CalendarFeedMode mode,  DateTime createdAt,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarFeed() when $default != null:
return $default(_that.id,_that.calendarId,_that.name,_that.mode,_that.createdAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarFeed implements CalendarFeed {
  const _CalendarFeed({required this.id, required this.calendarId, this.name = "", required this.mode, required this.createdAt, this.lastUsedAt});
  

@override final  int id;
@override final  int calendarId;
@override@JsonKey() final  String name;
@override final  CalendarFeedMode mode;
@override final  DateTime createdAt;
@override final  DateTime? lastUsedAt;

/// Create a copy of CalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarFeedCopyWith<_CalendarFeed> get copyWith => __$CalendarFeedCopyWithImpl<_CalendarFeed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarFeed&&(identical(other.id, id) || other.id == id)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.name, name) || other.name == name)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,calendarId,name,mode,createdAt,lastUsedAt);
}

@override
String toString() {
    return 'CalendarFeed(id: $id, calendarId: $calendarId, name: $name, mode: $mode, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarFeedCopyWith<$Res> implements $CalendarFeedCopyWith<$Res> {
  factory _$CalendarFeedCopyWith(_CalendarFeed value, $Res Function(_CalendarFeed) _then) = __$CalendarFeedCopyWithImpl;
@override @useResult
$Res call({
 int id, int calendarId, String name, CalendarFeedMode mode, DateTime createdAt, DateTime? lastUsedAt
});




}
/// @nodoc
class __$CalendarFeedCopyWithImpl<$Res>
    implements _$CalendarFeedCopyWith<$Res> {
  __$CalendarFeedCopyWithImpl(this._self, this._then);

  final _CalendarFeed _self;
  final $Res Function(_CalendarFeed) _then;

/// Create a copy of CalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? calendarId = null,Object? name = null,Object? mode = null,Object? createdAt = null,Object? lastUsedAt = freezed,}) {
  return _then(_CalendarFeed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CalendarFeedMode,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$CreatedCalendarFeed {

 CalendarFeed get feed; String get url;
/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatedCalendarFeedCopyWith<CreatedCalendarFeed> get copyWith => _$CreatedCalendarFeedCopyWithImpl<CreatedCalendarFeed>(this as CreatedCalendarFeed, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreatedCalendarFeed;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatedCalendarFeed&&(identical(other.feed, _this.feed) || other.feed == _this.feed)&&(identical(other.url, _this.url) || other.url == _this.url));
}


@override
int get hashCode {
  final _this = this as CreatedCalendarFeed;
  return Object.hash(runtimeType,_this.feed,_this.url);
}

@override
String toString() {
  final _this = this as CreatedCalendarFeed;
  return 'CreatedCalendarFeed(feed: ${_this.feed}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $CreatedCalendarFeedCopyWith<$Res>  {
  factory $CreatedCalendarFeedCopyWith(CreatedCalendarFeed value, $Res Function(CreatedCalendarFeed) _then) = _$CreatedCalendarFeedCopyWithImpl;
@useResult
$Res call({
 CalendarFeed feed, String url
});


$CalendarFeedCopyWith<$Res> get feed;

}
/// @nodoc
class _$CreatedCalendarFeedCopyWithImpl<$Res>
    implements $CreatedCalendarFeedCopyWith<$Res> {
  _$CreatedCalendarFeedCopyWithImpl(this._self, this._then);

  final CreatedCalendarFeed _self;
  final $Res Function(CreatedCalendarFeed) _then;

/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feed = null,Object? url = null,}) {
  return _then(CreatedCalendarFeed(
feed: null == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as CalendarFeed,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarFeedCopyWith<$Res> get feed {
  
  return $CalendarFeedCopyWith<$Res>(_self.feed, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatedCalendarFeed].
extension CreatedCalendarFeedPatterns on CreatedCalendarFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatedCalendarFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatedCalendarFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatedCalendarFeed value)  $default,){
final _that = this;
switch (_that) {
case _CreatedCalendarFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatedCalendarFeed value)?  $default,){
final _that = this;
switch (_that) {
case _CreatedCalendarFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarFeed feed,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatedCalendarFeed() when $default != null:
return $default(_that.feed,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarFeed feed,  String url)  $default,) {final _that = this;
switch (_that) {
case _CreatedCalendarFeed():
return $default(_that.feed,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarFeed feed,  String url)?  $default,) {final _that = this;
switch (_that) {
case _CreatedCalendarFeed() when $default != null:
return $default(_that.feed,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _CreatedCalendarFeed implements CreatedCalendarFeed {
  const _CreatedCalendarFeed({required this.feed, required this.url});
  

@override final  CalendarFeed feed;
@override final  String url;

/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatedCalendarFeedCopyWith<_CreatedCalendarFeed> get copyWith => __$CreatedCalendarFeedCopyWithImpl<_CreatedCalendarFeed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatedCalendarFeed&&(identical(other.feed, feed) || other.feed == feed)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode {
    return Object.hash(runtimeType,feed,url);
}

@override
String toString() {
    return 'CreatedCalendarFeed(feed: $feed, url: $url)';
}


}

/// @nodoc
abstract mixin class _$CreatedCalendarFeedCopyWith<$Res> implements $CreatedCalendarFeedCopyWith<$Res> {
  factory _$CreatedCalendarFeedCopyWith(_CreatedCalendarFeed value, $Res Function(_CreatedCalendarFeed) _then) = __$CreatedCalendarFeedCopyWithImpl;
@override @useResult
$Res call({
 CalendarFeed feed, String url
});


@override $CalendarFeedCopyWith<$Res> get feed;

}
/// @nodoc
class __$CreatedCalendarFeedCopyWithImpl<$Res>
    implements _$CreatedCalendarFeedCopyWith<$Res> {
  __$CreatedCalendarFeedCopyWithImpl(this._self, this._then);

  final _CreatedCalendarFeed _self;
  final $Res Function(_CreatedCalendarFeed) _then;

/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feed = null,Object? url = null,}) {
  return _then(_CreatedCalendarFeed(
feed: null == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as CalendarFeed,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CreatedCalendarFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarFeedCopyWith<$Res> get feed {
  
  return $CalendarFeedCopyWith<$Res>(_self.feed, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}

/// @nodoc
mixin _$CalendarShare {

 int get id; int get calendarId; ShareTarget get recipient; CalendarShareAccess get access;
/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarShareCopyWith<CalendarShare> get copyWith => _$CalendarShareCopyWithImpl<CalendarShare>(this as CalendarShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarShare&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.calendarId, _this.calendarId) || other.calendarId == _this.calendarId)&&(identical(other.recipient, _this.recipient) || other.recipient == _this.recipient)&&(identical(other.access, _this.access) || other.access == _this.access));
}


@override
int get hashCode {
  final _this = this as CalendarShare;
  return Object.hash(runtimeType,_this.id,_this.calendarId,_this.recipient,_this.access);
}

@override
String toString() {
  final _this = this as CalendarShare;
  return 'CalendarShare(id: ${_this.id}, calendarId: ${_this.calendarId}, recipient: ${_this.recipient}, access: ${_this.access})';
}


}

/// @nodoc
abstract mixin class $CalendarShareCopyWith<$Res>  {
  factory $CalendarShareCopyWith(CalendarShare value, $Res Function(CalendarShare) _then) = _$CalendarShareCopyWithImpl;
@useResult
$Res call({
 int id, int calendarId, ShareTarget recipient, CalendarShareAccess access
});


$ShareTargetCopyWith<$Res> get recipient;

}
/// @nodoc
class _$CalendarShareCopyWithImpl<$Res>
    implements $CalendarShareCopyWith<$Res> {
  _$CalendarShareCopyWithImpl(this._self, this._then);

  final CalendarShare _self;
  final $Res Function(CalendarShare) _then;

/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? calendarId = null,Object? recipient = null,Object? access = null,}) {
  return _then(CalendarShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as ShareTarget,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarShareAccess,
  ));
}
/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get recipient {
  
  return $ShareTargetCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarShare].
extension CalendarSharePatterns on CalendarShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarShare value)  $default,){
final _that = this;
switch (_that) {
case _CalendarShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarShare value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int calendarId,  ShareTarget recipient,  CalendarShareAccess access)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarShare() when $default != null:
return $default(_that.id,_that.calendarId,_that.recipient,_that.access);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int calendarId,  ShareTarget recipient,  CalendarShareAccess access)  $default,) {final _that = this;
switch (_that) {
case _CalendarShare():
return $default(_that.id,_that.calendarId,_that.recipient,_that.access);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int calendarId,  ShareTarget recipient,  CalendarShareAccess access)?  $default,) {final _that = this;
switch (_that) {
case _CalendarShare() when $default != null:
return $default(_that.id,_that.calendarId,_that.recipient,_that.access);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarShare implements CalendarShare {
  const _CalendarShare({required this.id, required this.calendarId, required this.recipient, required this.access});
  

@override final  int id;
@override final  int calendarId;
@override final  ShareTarget recipient;
@override final  CalendarShareAccess access;

/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarShareCopyWith<_CalendarShare> get copyWith => __$CalendarShareCopyWithImpl<_CalendarShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarShare&&(identical(other.id, id) || other.id == id)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.access, access) || other.access == access));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,calendarId,recipient,access);
}

@override
String toString() {
    return 'CalendarShare(id: $id, calendarId: $calendarId, recipient: $recipient, access: $access)';
}


}

/// @nodoc
abstract mixin class _$CalendarShareCopyWith<$Res> implements $CalendarShareCopyWith<$Res> {
  factory _$CalendarShareCopyWith(_CalendarShare value, $Res Function(_CalendarShare) _then) = __$CalendarShareCopyWithImpl;
@override @useResult
$Res call({
 int id, int calendarId, ShareTarget recipient, CalendarShareAccess access
});


@override $ShareTargetCopyWith<$Res> get recipient;

}
/// @nodoc
class __$CalendarShareCopyWithImpl<$Res>
    implements _$CalendarShareCopyWith<$Res> {
  __$CalendarShareCopyWithImpl(this._self, this._then);

  final _CalendarShare _self;
  final $Res Function(_CalendarShare) _then;

/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? calendarId = null,Object? recipient = null,Object? access = null,}) {
  return _then(_CalendarShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as ShareTarget,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as CalendarShareAccess,
  ));
}

/// Create a copy of CalendarShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get recipient {
  
  return $ShareTargetCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}

/// @nodoc
mixin _$CalendarImportResult {

 int get created; int get updated; int get skipped; List<String> get errors;
/// Create a copy of CalendarImportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarImportResultCopyWith<CalendarImportResult> get copyWith => _$CalendarImportResultCopyWithImpl<CalendarImportResult>(this as CalendarImportResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarImportResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarImportResult&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.updated, _this.updated) || other.updated == _this.updated)&&(identical(other.skipped, _this.skipped) || other.skipped == _this.skipped)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}


@override
int get hashCode {
  final _this = this as CalendarImportResult;
  return Object.hash(runtimeType,_this.created,_this.updated,_this.skipped,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as CalendarImportResult;
  return 'CalendarImportResult(created: ${_this.created}, updated: ${_this.updated}, skipped: ${_this.skipped}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $CalendarImportResultCopyWith<$Res>  {
  factory $CalendarImportResultCopyWith(CalendarImportResult value, $Res Function(CalendarImportResult) _then) = _$CalendarImportResultCopyWithImpl;
@useResult
$Res call({
 int created, int updated, int skipped, List<String> errors
});




}
/// @nodoc
class _$CalendarImportResultCopyWithImpl<$Res>
    implements $CalendarImportResultCopyWith<$Res> {
  _$CalendarImportResultCopyWithImpl(this._self, this._then);

  final CalendarImportResult _self;
  final $Res Function(CalendarImportResult) _then;

/// Create a copy of CalendarImportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? created = null,Object? updated = null,Object? skipped = null,Object? errors = null,}) {
  return _then(CalendarImportResult(
created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarImportResult].
extension CalendarImportResultPatterns on CalendarImportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarImportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarImportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarImportResult value)  $default,){
final _that = this;
switch (_that) {
case _CalendarImportResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarImportResult value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarImportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int created,  int updated,  int skipped,  List<String> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarImportResult() when $default != null:
return $default(_that.created,_that.updated,_that.skipped,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int created,  int updated,  int skipped,  List<String> errors)  $default,) {final _that = this;
switch (_that) {
case _CalendarImportResult():
return $default(_that.created,_that.updated,_that.skipped,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int created,  int updated,  int skipped,  List<String> errors)?  $default,) {final _that = this;
switch (_that) {
case _CalendarImportResult() when $default != null:
return $default(_that.created,_that.updated,_that.skipped,_that.errors);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarImportResult implements CalendarImportResult {
  const _CalendarImportResult({required this.created, required this.updated, required this.skipped,  List<String> errors = const []}): _errors = errors;
  

@override final  int created;
@override final  int updated;
@override final  int skipped;
 final  List<String> _errors;
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of CalendarImportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarImportResultCopyWith<_CalendarImportResult> get copyWith => __$CalendarImportResultCopyWithImpl<_CalendarImportResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarImportResult&&(identical(other.created, created) || other.created == created)&&(identical(other.updated, updated) || other.updated == updated)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&const DeepCollectionEquality().equals(other.errors, _errors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,created,updated,skipped,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'CalendarImportResult(created: $created, updated: $updated, skipped: $skipped, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$CalendarImportResultCopyWith<$Res> implements $CalendarImportResultCopyWith<$Res> {
  factory _$CalendarImportResultCopyWith(_CalendarImportResult value, $Res Function(_CalendarImportResult) _then) = __$CalendarImportResultCopyWithImpl;
@override @useResult
$Res call({
 int created, int updated, int skipped, List<String> errors
});




}
/// @nodoc
class __$CalendarImportResultCopyWithImpl<$Res>
    implements _$CalendarImportResultCopyWith<$Res> {
  __$CalendarImportResultCopyWithImpl(this._self, this._then);

  final _CalendarImportResult _self;
  final $Res Function(_CalendarImportResult) _then;

/// Create a copy of CalendarImportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? created = null,Object? updated = null,Object? skipped = null,Object? errors = null,}) {
  return _then(_CalendarImportResult(
created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as int,updated: null == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as int,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
