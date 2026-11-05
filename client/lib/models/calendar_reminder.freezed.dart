// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarReminder {

 int get calendarId; int get eventId; String get uid; String? get recurrenceId; String get summary; String? get location; DateTime get start; DateTime get end; bool get allDay; DateTime get triggerAt;
/// Create a copy of CalendarReminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarReminderCopyWith<CalendarReminder> get copyWith => _$CalendarReminderCopyWithImpl<CalendarReminder>(this as CalendarReminder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarReminder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarReminder&&(identical(other.calendarId, _this.calendarId) || other.calendarId == _this.calendarId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.recurrenceId, _this.recurrenceId) || other.recurrenceId == _this.recurrenceId)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.allDay, _this.allDay) || other.allDay == _this.allDay)&&(identical(other.triggerAt, _this.triggerAt) || other.triggerAt == _this.triggerAt));
}


@override
int get hashCode {
  final _this = this as CalendarReminder;
  return Object.hash(runtimeType,_this.calendarId,_this.eventId,_this.uid,_this.recurrenceId,_this.summary,_this.location,_this.start,_this.end,_this.allDay,_this.triggerAt);
}

@override
String toString() {
  final _this = this as CalendarReminder;
  return 'CalendarReminder(calendarId: ${_this.calendarId}, eventId: ${_this.eventId}, uid: ${_this.uid}, recurrenceId: ${_this.recurrenceId}, summary: ${_this.summary}, location: ${_this.location}, start: ${_this.start}, end: ${_this.end}, allDay: ${_this.allDay}, triggerAt: ${_this.triggerAt})';
}


}

/// @nodoc
abstract mixin class $CalendarReminderCopyWith<$Res>  {
  factory $CalendarReminderCopyWith(CalendarReminder value, $Res Function(CalendarReminder) _then) = _$CalendarReminderCopyWithImpl;
@useResult
$Res call({
 int calendarId, int eventId, String uid, String? recurrenceId, String summary, String? location, DateTime start, DateTime end, bool allDay, DateTime triggerAt
});




}
/// @nodoc
class _$CalendarReminderCopyWithImpl<$Res>
    implements $CalendarReminderCopyWith<$Res> {
  _$CalendarReminderCopyWithImpl(this._self, this._then);

  final CalendarReminder _self;
  final $Res Function(CalendarReminder) _then;

/// Create a copy of CalendarReminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calendarId = null,Object? eventId = null,Object? uid = null,Object? recurrenceId = freezed,Object? summary = null,Object? location = freezed,Object? start = null,Object? end = null,Object? allDay = null,Object? triggerAt = null,}) {
  return _then(CalendarReminder(
calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarReminder].
extension CalendarReminderPatterns on CalendarReminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarReminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarReminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarReminder value)  $default,){
final _that = this;
switch (_that) {
case _CalendarReminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarReminder value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarReminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int calendarId,  int eventId,  String uid,  String? recurrenceId,  String summary,  String? location,  DateTime start,  DateTime end,  bool allDay,  DateTime triggerAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarReminder() when $default != null:
return $default(_that.calendarId,_that.eventId,_that.uid,_that.recurrenceId,_that.summary,_that.location,_that.start,_that.end,_that.allDay,_that.triggerAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int calendarId,  int eventId,  String uid,  String? recurrenceId,  String summary,  String? location,  DateTime start,  DateTime end,  bool allDay,  DateTime triggerAt)  $default,) {final _that = this;
switch (_that) {
case _CalendarReminder():
return $default(_that.calendarId,_that.eventId,_that.uid,_that.recurrenceId,_that.summary,_that.location,_that.start,_that.end,_that.allDay,_that.triggerAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int calendarId,  int eventId,  String uid,  String? recurrenceId,  String summary,  String? location,  DateTime start,  DateTime end,  bool allDay,  DateTime triggerAt)?  $default,) {final _that = this;
switch (_that) {
case _CalendarReminder() when $default != null:
return $default(_that.calendarId,_that.eventId,_that.uid,_that.recurrenceId,_that.summary,_that.location,_that.start,_that.end,_that.allDay,_that.triggerAt);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarReminder implements CalendarReminder {
  const _CalendarReminder({required this.calendarId, required this.eventId, required this.uid, this.recurrenceId, required this.summary, this.location, required this.start, required this.end, required this.allDay, required this.triggerAt});
  

@override final  int calendarId;
@override final  int eventId;
@override final  String uid;
@override final  String? recurrenceId;
@override final  String summary;
@override final  String? location;
@override final  DateTime start;
@override final  DateTime end;
@override final  bool allDay;
@override final  DateTime triggerAt;

/// Create a copy of CalendarReminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarReminderCopyWith<_CalendarReminder> get copyWith => __$CalendarReminderCopyWithImpl<_CalendarReminder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarReminder&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.recurrenceId, recurrenceId) || other.recurrenceId == recurrenceId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.location, location) || other.location == location)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.triggerAt, triggerAt) || other.triggerAt == triggerAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,calendarId,eventId,uid,recurrenceId,summary,location,start,end,allDay,triggerAt);
}

@override
String toString() {
    return 'CalendarReminder(calendarId: $calendarId, eventId: $eventId, uid: $uid, recurrenceId: $recurrenceId, summary: $summary, location: $location, start: $start, end: $end, allDay: $allDay, triggerAt: $triggerAt)';
}


}

/// @nodoc
abstract mixin class _$CalendarReminderCopyWith<$Res> implements $CalendarReminderCopyWith<$Res> {
  factory _$CalendarReminderCopyWith(_CalendarReminder value, $Res Function(_CalendarReminder) _then) = __$CalendarReminderCopyWithImpl;
@override @useResult
$Res call({
 int calendarId, int eventId, String uid, String? recurrenceId, String summary, String? location, DateTime start, DateTime end, bool allDay, DateTime triggerAt
});




}
/// @nodoc
class __$CalendarReminderCopyWithImpl<$Res>
    implements _$CalendarReminderCopyWith<$Res> {
  __$CalendarReminderCopyWithImpl(this._self, this._then);

  final _CalendarReminder _self;
  final $Res Function(_CalendarReminder) _then;

/// Create a copy of CalendarReminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calendarId = null,Object? eventId = null,Object? uid = null,Object? recurrenceId = freezed,Object? summary = null,Object? location = freezed,Object? start = null,Object? end = null,Object? allDay = null,Object? triggerAt = null,}) {
  return _then(_CalendarReminder(
calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
