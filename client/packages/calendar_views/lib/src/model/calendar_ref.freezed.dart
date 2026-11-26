// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarRef {

 String get sourceId; String get calendarId;
/// Create a copy of CalendarRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarRefCopyWith<CalendarRef> get copyWith => _$CalendarRefCopyWithImpl<CalendarRef>(this as CalendarRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarRef&&(identical(other.sourceId, _this.sourceId) || other.sourceId == _this.sourceId)&&(identical(other.calendarId, _this.calendarId) || other.calendarId == _this.calendarId));
}


@override
int get hashCode {
  final _this = this as CalendarRef;
  return Object.hash(runtimeType,_this.sourceId,_this.calendarId);
}

@override
String toString() {
  final _this = this as CalendarRef;
  return 'CalendarRef(sourceId: ${_this.sourceId}, calendarId: ${_this.calendarId})';
}


}

/// @nodoc
abstract mixin class $CalendarRefCopyWith<$Res>  {
  factory $CalendarRefCopyWith(CalendarRef value, $Res Function(CalendarRef) _then) = _$CalendarRefCopyWithImpl;
@useResult
$Res call({
 String sourceId, String calendarId
});




}
/// @nodoc
class _$CalendarRefCopyWithImpl<$Res>
    implements $CalendarRefCopyWith<$Res> {
  _$CalendarRefCopyWithImpl(this._self, this._then);

  final CalendarRef _self;
  final $Res Function(CalendarRef) _then;

/// Create a copy of CalendarRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceId = null,Object? calendarId = null,}) {
  return _then(CalendarRef(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarRef].
extension CalendarRefPatterns on CalendarRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarRef value)  $default,){
final _that = this;
switch (_that) {
case _CalendarRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarRef value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceId,  String calendarId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarRef() when $default != null:
return $default(_that.sourceId,_that.calendarId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceId,  String calendarId)  $default,) {final _that = this;
switch (_that) {
case _CalendarRef():
return $default(_that.sourceId,_that.calendarId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceId,  String calendarId)?  $default,) {final _that = this;
switch (_that) {
case _CalendarRef() when $default != null:
return $default(_that.sourceId,_that.calendarId);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarRef implements CalendarRef {
  const _CalendarRef({required this.sourceId, required this.calendarId});
  

@override final  String sourceId;
@override final  String calendarId;

/// Create a copy of CalendarRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarRefCopyWith<_CalendarRef> get copyWith => __$CalendarRefCopyWithImpl<_CalendarRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarRef&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.calendarId, calendarId) || other.calendarId == calendarId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sourceId,calendarId);
}

@override
String toString() {
    return 'CalendarRef(sourceId: $sourceId, calendarId: $calendarId)';
}


}

/// @nodoc
abstract mixin class _$CalendarRefCopyWith<$Res> implements $CalendarRefCopyWith<$Res> {
  factory _$CalendarRefCopyWith(_CalendarRef value, $Res Function(_CalendarRef) _then) = __$CalendarRefCopyWithImpl;
@override @useResult
$Res call({
 String sourceId, String calendarId
});




}
/// @nodoc
class __$CalendarRefCopyWithImpl<$Res>
    implements _$CalendarRefCopyWith<$Res> {
  __$CalendarRefCopyWithImpl(this._self, this._then);

  final _CalendarRef _self;
  final $Res Function(_CalendarRef) _then;

/// Create a copy of CalendarRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceId = null,Object? calendarId = null,}) {
  return _then(_CalendarRef(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,calendarId: null == calendarId ? _self.calendarId : calendarId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$EventRef {

 CalendarRef get calendar; String get eventId; String? get recurrenceId;
/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRefCopyWith<EventRef> get copyWith => _$EventRefCopyWithImpl<EventRef>(this as EventRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRef&&(identical(other.calendar, _this.calendar) || other.calendar == _this.calendar)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.recurrenceId, _this.recurrenceId) || other.recurrenceId == _this.recurrenceId));
}


@override
int get hashCode {
  final _this = this as EventRef;
  return Object.hash(runtimeType,_this.calendar,_this.eventId,_this.recurrenceId);
}

@override
String toString() {
  final _this = this as EventRef;
  return 'EventRef(calendar: ${_this.calendar}, eventId: ${_this.eventId}, recurrenceId: ${_this.recurrenceId})';
}


}

/// @nodoc
abstract mixin class $EventRefCopyWith<$Res>  {
  factory $EventRefCopyWith(EventRef value, $Res Function(EventRef) _then) = _$EventRefCopyWithImpl;
@useResult
$Res call({
 CalendarRef calendar, String eventId, String? recurrenceId
});


$CalendarRefCopyWith<$Res> get calendar;

}
/// @nodoc
class _$EventRefCopyWithImpl<$Res>
    implements $EventRefCopyWith<$Res> {
  _$EventRefCopyWithImpl(this._self, this._then);

  final EventRef _self;
  final $Res Function(EventRef) _then;

/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? calendar = null,Object? eventId = null,Object? recurrenceId = freezed,}) {
  return _then(EventRef(
calendar: null == calendar ? _self.calendar : calendar // ignore: cast_nullable_to_non_nullable
as CalendarRef,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarRefCopyWith<$Res> get calendar {
  
  return $CalendarRefCopyWith<$Res>(_self.calendar, (value) {
    return _then(_self.copyWith(calendar: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventRef].
extension EventRefPatterns on EventRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventRef value)  $default,){
final _that = this;
switch (_that) {
case _EventRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventRef value)?  $default,){
final _that = this;
switch (_that) {
case _EventRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarRef calendar,  String eventId,  String? recurrenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRef() when $default != null:
return $default(_that.calendar,_that.eventId,_that.recurrenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarRef calendar,  String eventId,  String? recurrenceId)  $default,) {final _that = this;
switch (_that) {
case _EventRef():
return $default(_that.calendar,_that.eventId,_that.recurrenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarRef calendar,  String eventId,  String? recurrenceId)?  $default,) {final _that = this;
switch (_that) {
case _EventRef() when $default != null:
return $default(_that.calendar,_that.eventId,_that.recurrenceId);case _:
  return null;

}
}

}

/// @nodoc


class _EventRef extends EventRef {
  const _EventRef({required this.calendar, required this.eventId, this.recurrenceId}): super._();
  

@override final  CalendarRef calendar;
@override final  String eventId;
@override final  String? recurrenceId;

/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventRefCopyWith<_EventRef> get copyWith => __$EventRefCopyWithImpl<_EventRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRef&&(identical(other.calendar, calendar) || other.calendar == calendar)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.recurrenceId, recurrenceId) || other.recurrenceId == recurrenceId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,calendar,eventId,recurrenceId);
}

@override
String toString() {
    return 'EventRef(calendar: $calendar, eventId: $eventId, recurrenceId: $recurrenceId)';
}


}

/// @nodoc
abstract mixin class _$EventRefCopyWith<$Res> implements $EventRefCopyWith<$Res> {
  factory _$EventRefCopyWith(_EventRef value, $Res Function(_EventRef) _then) = __$EventRefCopyWithImpl;
@override @useResult
$Res call({
 CalendarRef calendar, String eventId, String? recurrenceId
});


@override $CalendarRefCopyWith<$Res> get calendar;

}
/// @nodoc
class __$EventRefCopyWithImpl<$Res>
    implements _$EventRefCopyWith<$Res> {
  __$EventRefCopyWithImpl(this._self, this._then);

  final _EventRef _self;
  final $Res Function(_EventRef) _then;

/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? calendar = null,Object? eventId = null,Object? recurrenceId = freezed,}) {
  return _then(_EventRef(
calendar: null == calendar ? _self.calendar : calendar // ignore: cast_nullable_to_non_nullable
as CalendarRef,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,recurrenceId: freezed == recurrenceId ? _self.recurrenceId : recurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EventRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarRefCopyWith<$Res> get calendar {
  
  return $CalendarRefCopyWith<$Res>(_self.calendar, (value) {
    return _then(_self.copyWith(calendar: value));
  });
}
}

// dart format on
