// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventDraft {

 String get summary; DateTime get start; DateTime get end; bool get allDay; String? get description; String? get location; String? get url; String? get timezone; String? get rrule; EventStatus get status; EventShowAs get showAs; List<EventPerson> get attendees; List<EventReminder> get reminders;
/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDraftCopyWith<EventDraft> get copyWith => _$EventDraftCopyWithImpl<EventDraft>(this as EventDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDraft&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.allDay, _this.allDay) || other.allDay == _this.allDay)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.rrule, _this.rrule) || other.rrule == _this.rrule)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.showAs, _this.showAs) || other.showAs == _this.showAs)&&const DeepCollectionEquality().equals(other.attendees, _this.attendees)&&const DeepCollectionEquality().equals(other.reminders, _this.reminders));
}


@override
int get hashCode {
  final _this = this as EventDraft;
  return Object.hash(runtimeType,_this.summary,_this.start,_this.end,_this.allDay,_this.description,_this.location,_this.url,_this.timezone,_this.rrule,_this.status,_this.showAs,const DeepCollectionEquality().hash(_this.attendees),const DeepCollectionEquality().hash(_this.reminders));
}

@override
String toString() {
  final _this = this as EventDraft;
  return 'EventDraft(summary: ${_this.summary}, start: ${_this.start}, end: ${_this.end}, allDay: ${_this.allDay}, description: ${_this.description}, location: ${_this.location}, url: ${_this.url}, timezone: ${_this.timezone}, rrule: ${_this.rrule}, status: ${_this.status}, showAs: ${_this.showAs}, attendees: ${_this.attendees}, reminders: ${_this.reminders})';
}


}

/// @nodoc
abstract mixin class $EventDraftCopyWith<$Res>  {
  factory $EventDraftCopyWith(EventDraft value, $Res Function(EventDraft) _then) = _$EventDraftCopyWithImpl;
@useResult
$Res call({
 String summary, DateTime start, DateTime end, bool allDay, String? description, String? location, String? url, String? timezone, String? rrule, EventStatus status, EventShowAs showAs, List<EventPerson> attendees, List<EventReminder> reminders
});




}
/// @nodoc
class _$EventDraftCopyWithImpl<$Res>
    implements $EventDraftCopyWith<$Res> {
  _$EventDraftCopyWithImpl(this._self, this._then);

  final EventDraft _self;
  final $Res Function(EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? start = null,Object? end = null,Object? allDay = null,Object? description = freezed,Object? location = freezed,Object? url = freezed,Object? timezone = freezed,Object? rrule = freezed,Object? status = null,Object? showAs = null,Object? attendees = null,Object? reminders = null,}) {
  return _then(EventDraft(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,rrule: freezed == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,showAs: null == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as EventShowAs,attendees: null == attendees ? _self.attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<EventPerson>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<EventReminder>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDraft].
extension EventDraftPatterns on EventDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDraft value)  $default,){
final _that = this;
switch (_that) {
case _EventDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  EventStatus status,  EventShowAs showAs,  List<EventPerson> attendees,  List<EventReminder> reminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.status,_that.showAs,_that.attendees,_that.reminders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  EventStatus status,  EventShowAs showAs,  List<EventPerson> attendees,  List<EventReminder> reminders)  $default,) {final _that = this;
switch (_that) {
case _EventDraft():
return $default(_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.status,_that.showAs,_that.attendees,_that.reminders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  EventStatus status,  EventShowAs showAs,  List<EventPerson> attendees,  List<EventReminder> reminders)?  $default,) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.status,_that.showAs,_that.attendees,_that.reminders);case _:
  return null;

}
}

}

/// @nodoc


class _EventDraft implements EventDraft {
  const _EventDraft({required this.summary, required this.start, required this.end, this.allDay = false, this.description, this.location, this.url, this.timezone, this.rrule, this.status = EventStatus.confirmed, this.showAs = EventShowAs.busy,  List<EventPerson> attendees = const [],  List<EventReminder> reminders = const []}): _attendees = attendees,_reminders = reminders;
  

@override final  String summary;
@override final  DateTime start;
@override final  DateTime end;
@override@JsonKey() final  bool allDay;
@override final  String? description;
@override final  String? location;
@override final  String? url;
@override final  String? timezone;
@override final  String? rrule;
@override@JsonKey() final  EventStatus status;
@override@JsonKey() final  EventShowAs showAs;
 final  List<EventPerson> _attendees;
@override@JsonKey() List<EventPerson> get attendees {
  if (_attendees is EqualUnmodifiableListView) return _attendees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attendees);
}

 final  List<EventReminder> _reminders;
@override@JsonKey() List<EventReminder> get reminders {
  if (_reminders is EqualUnmodifiableListView) return _reminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminders);
}


/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDraftCopyWith<_EventDraft> get copyWith => __$EventDraftCopyWithImpl<_EventDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDraft&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.url, url) || other.url == url)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.status, status) || other.status == status)&&(identical(other.showAs, showAs) || other.showAs == showAs)&&const DeepCollectionEquality().equals(other.attendees, _attendees)&&const DeepCollectionEquality().equals(other.reminders, _reminders));
}


@override
int get hashCode {
    return Object.hash(runtimeType,summary,start,end,allDay,description,location,url,timezone,rrule,status,showAs,const DeepCollectionEquality().hash(_attendees),const DeepCollectionEquality().hash(_reminders));
}

@override
String toString() {
    return 'EventDraft(summary: $summary, start: $start, end: $end, allDay: $allDay, description: $description, location: $location, url: $url, timezone: $timezone, rrule: $rrule, status: $status, showAs: $showAs, attendees: $attendees, reminders: $reminders)';
}


}

/// @nodoc
abstract mixin class _$EventDraftCopyWith<$Res> implements $EventDraftCopyWith<$Res> {
  factory _$EventDraftCopyWith(_EventDraft value, $Res Function(_EventDraft) _then) = __$EventDraftCopyWithImpl;
@override @useResult
$Res call({
 String summary, DateTime start, DateTime end, bool allDay, String? description, String? location, String? url, String? timezone, String? rrule, EventStatus status, EventShowAs showAs, List<EventPerson> attendees, List<EventReminder> reminders
});




}
/// @nodoc
class __$EventDraftCopyWithImpl<$Res>
    implements _$EventDraftCopyWith<$Res> {
  __$EventDraftCopyWithImpl(this._self, this._then);

  final _EventDraft _self;
  final $Res Function(_EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? start = null,Object? end = null,Object? allDay = null,Object? description = freezed,Object? location = freezed,Object? url = freezed,Object? timezone = freezed,Object? rrule = freezed,Object? status = null,Object? showAs = null,Object? attendees = null,Object? reminders = null,}) {
  return _then(_EventDraft(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,rrule: freezed == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,showAs: null == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as EventShowAs,attendees: null == attendees ? _self._attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<EventPerson>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<EventReminder>,
  ));
}


}

// dart format on
