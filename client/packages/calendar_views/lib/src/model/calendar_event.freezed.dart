// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventPerson {

 String get email; String? get name; bool get self;
/// Create a copy of EventPerson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventPersonCopyWith<EventPerson> get copyWith => _$EventPersonCopyWithImpl<EventPerson>(this as EventPerson, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventPerson;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventPerson&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.self, _this.self) || other.self == _this.self));
}


@override
int get hashCode {
  final _this = this as EventPerson;
  return Object.hash(runtimeType,_this.email,_this.name,_this.self);
}

@override
String toString() {
  final _this = this as EventPerson;
  return 'EventPerson(email: ${_this.email}, name: ${_this.name}, self: ${_this.self})';
}


}

/// @nodoc
abstract mixin class $EventPersonCopyWith<$Res>  {
  factory $EventPersonCopyWith(EventPerson value, $Res Function(EventPerson) _then) = _$EventPersonCopyWithImpl;
@useResult
$Res call({
 String email, String? name, bool self
});




}
/// @nodoc
class _$EventPersonCopyWithImpl<$Res>
    implements $EventPersonCopyWith<$Res> {
  _$EventPersonCopyWithImpl(this._self, this._then);

  final EventPerson _self;
  final $Res Function(EventPerson) _then;

/// Create a copy of EventPerson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? name = freezed,Object? self = null,}) {
  return _then(EventPerson(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,self: null == self ? _self.self : self // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EventPerson].
extension EventPersonPatterns on EventPerson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventPerson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventPerson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventPerson value)  $default,){
final _that = this;
switch (_that) {
case _EventPerson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventPerson value)?  $default,){
final _that = this;
switch (_that) {
case _EventPerson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String? name,  bool self)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventPerson() when $default != null:
return $default(_that.email,_that.name,_that.self);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String? name,  bool self)  $default,) {final _that = this;
switch (_that) {
case _EventPerson():
return $default(_that.email,_that.name,_that.self);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String? name,  bool self)?  $default,) {final _that = this;
switch (_that) {
case _EventPerson() when $default != null:
return $default(_that.email,_that.name,_that.self);case _:
  return null;

}
}

}

/// @nodoc


class _EventPerson extends EventPerson {
  const _EventPerson({required this.email, this.name, this.self = false}): super._();
  

@override final  String email;
@override final  String? name;
@override@JsonKey() final  bool self;

/// Create a copy of EventPerson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventPersonCopyWith<_EventPerson> get copyWith => __$EventPersonCopyWithImpl<_EventPerson>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventPerson&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.self, self) || other.self == self));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,name,self);
}

@override
String toString() {
    return 'EventPerson(email: $email, name: $name, self: $self)';
}


}

/// @nodoc
abstract mixin class _$EventPersonCopyWith<$Res> implements $EventPersonCopyWith<$Res> {
  factory _$EventPersonCopyWith(_EventPerson value, $Res Function(_EventPerson) _then) = __$EventPersonCopyWithImpl;
@override @useResult
$Res call({
 String email, String? name, bool self
});




}
/// @nodoc
class __$EventPersonCopyWithImpl<$Res>
    implements _$EventPersonCopyWith<$Res> {
  __$EventPersonCopyWithImpl(this._self, this._then);

  final _EventPerson _self;
  final $Res Function(_EventPerson) _then;

/// Create a copy of EventPerson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? name = freezed,Object? self = null,}) {
  return _then(_EventPerson(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,self: null == self ? _self.self : self // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$EventAttendee {

 EventPerson get person; AttendeeStatus get status; AttendeeRole get role;
/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventAttendeeCopyWith<EventAttendee> get copyWith => _$EventAttendeeCopyWithImpl<EventAttendee>(this as EventAttendee, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventAttendee;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventAttendee&&(identical(other.person, _this.person) || other.person == _this.person)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.role, _this.role) || other.role == _this.role));
}


@override
int get hashCode {
  final _this = this as EventAttendee;
  return Object.hash(runtimeType,_this.person,_this.status,_this.role);
}

@override
String toString() {
  final _this = this as EventAttendee;
  return 'EventAttendee(person: ${_this.person}, status: ${_this.status}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $EventAttendeeCopyWith<$Res>  {
  factory $EventAttendeeCopyWith(EventAttendee value, $Res Function(EventAttendee) _then) = _$EventAttendeeCopyWithImpl;
@useResult
$Res call({
 EventPerson person, AttendeeStatus status, AttendeeRole role
});


$EventPersonCopyWith<$Res> get person;

}
/// @nodoc
class _$EventAttendeeCopyWithImpl<$Res>
    implements $EventAttendeeCopyWith<$Res> {
  _$EventAttendeeCopyWithImpl(this._self, this._then);

  final EventAttendee _self;
  final $Res Function(EventAttendee) _then;

/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? status = null,Object? role = null,}) {
  return _then(EventAttendee(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as EventPerson,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendeeStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AttendeeRole,
  ));
}
/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPersonCopyWith<$Res> get person {
  
  return $EventPersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventAttendee].
extension EventAttendeePatterns on EventAttendee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventAttendee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventAttendee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventAttendee value)  $default,){
final _that = this;
switch (_that) {
case _EventAttendee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventAttendee value)?  $default,){
final _that = this;
switch (_that) {
case _EventAttendee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EventPerson person,  AttendeeStatus status,  AttendeeRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventAttendee() when $default != null:
return $default(_that.person,_that.status,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EventPerson person,  AttendeeStatus status,  AttendeeRole role)  $default,) {final _that = this;
switch (_that) {
case _EventAttendee():
return $default(_that.person,_that.status,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EventPerson person,  AttendeeStatus status,  AttendeeRole role)?  $default,) {final _that = this;
switch (_that) {
case _EventAttendee() when $default != null:
return $default(_that.person,_that.status,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _EventAttendee implements EventAttendee {
  const _EventAttendee({required this.person, this.status = AttendeeStatus.needsAction, this.role = AttendeeRole.required});
  

@override final  EventPerson person;
@override@JsonKey() final  AttendeeStatus status;
@override@JsonKey() final  AttendeeRole role;

/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventAttendeeCopyWith<_EventAttendee> get copyWith => __$EventAttendeeCopyWithImpl<_EventAttendee>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventAttendee&&(identical(other.person, person) || other.person == person)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode {
    return Object.hash(runtimeType,person,status,role);
}

@override
String toString() {
    return 'EventAttendee(person: $person, status: $status, role: $role)';
}


}

/// @nodoc
abstract mixin class _$EventAttendeeCopyWith<$Res> implements $EventAttendeeCopyWith<$Res> {
  factory _$EventAttendeeCopyWith(_EventAttendee value, $Res Function(_EventAttendee) _then) = __$EventAttendeeCopyWithImpl;
@override @useResult
$Res call({
 EventPerson person, AttendeeStatus status, AttendeeRole role
});


@override $EventPersonCopyWith<$Res> get person;

}
/// @nodoc
class __$EventAttendeeCopyWithImpl<$Res>
    implements _$EventAttendeeCopyWith<$Res> {
  __$EventAttendeeCopyWithImpl(this._self, this._then);

  final _EventAttendee _self;
  final $Res Function(_EventAttendee) _then;

/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? status = null,Object? role = null,}) {
  return _then(_EventAttendee(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as EventPerson,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendeeStatus,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AttendeeRole,
  ));
}

/// Create a copy of EventAttendee
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPersonCopyWith<$Res> get person {
  
  return $EventPersonCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}

/// @nodoc
mixin _$EventReminder {

 ReminderAction get action; int? get offsetMinutes; bool get relativeToEnd; DateTime? get at;
/// Create a copy of EventReminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventReminderCopyWith<EventReminder> get copyWith => _$EventReminderCopyWithImpl<EventReminder>(this as EventReminder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventReminder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventReminder&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.offsetMinutes, _this.offsetMinutes) || other.offsetMinutes == _this.offsetMinutes)&&(identical(other.relativeToEnd, _this.relativeToEnd) || other.relativeToEnd == _this.relativeToEnd)&&(identical(other.at, _this.at) || other.at == _this.at));
}


@override
int get hashCode {
  final _this = this as EventReminder;
  return Object.hash(runtimeType,_this.action,_this.offsetMinutes,_this.relativeToEnd,_this.at);
}

@override
String toString() {
  final _this = this as EventReminder;
  return 'EventReminder(action: ${_this.action}, offsetMinutes: ${_this.offsetMinutes}, relativeToEnd: ${_this.relativeToEnd}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $EventReminderCopyWith<$Res>  {
  factory $EventReminderCopyWith(EventReminder value, $Res Function(EventReminder) _then) = _$EventReminderCopyWithImpl;
@useResult
$Res call({
 ReminderAction action, int? offsetMinutes, bool relativeToEnd, DateTime? at
});




}
/// @nodoc
class _$EventReminderCopyWithImpl<$Res>
    implements $EventReminderCopyWith<$Res> {
  _$EventReminderCopyWithImpl(this._self, this._then);

  final EventReminder _self;
  final $Res Function(EventReminder) _then;

/// Create a copy of EventReminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? offsetMinutes = freezed,Object? relativeToEnd = null,Object? at = freezed,}) {
  return _then(EventReminder(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ReminderAction,offsetMinutes: freezed == offsetMinutes ? _self.offsetMinutes : offsetMinutes // ignore: cast_nullable_to_non_nullable
as int?,relativeToEnd: null == relativeToEnd ? _self.relativeToEnd : relativeToEnd // ignore: cast_nullable_to_non_nullable
as bool,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventReminder].
extension EventReminderPatterns on EventReminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventReminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventReminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventReminder value)  $default,){
final _that = this;
switch (_that) {
case _EventReminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventReminder value)?  $default,){
final _that = this;
switch (_that) {
case _EventReminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReminderAction action,  int? offsetMinutes,  bool relativeToEnd,  DateTime? at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventReminder() when $default != null:
return $default(_that.action,_that.offsetMinutes,_that.relativeToEnd,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReminderAction action,  int? offsetMinutes,  bool relativeToEnd,  DateTime? at)  $default,) {final _that = this;
switch (_that) {
case _EventReminder():
return $default(_that.action,_that.offsetMinutes,_that.relativeToEnd,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReminderAction action,  int? offsetMinutes,  bool relativeToEnd,  DateTime? at)?  $default,) {final _that = this;
switch (_that) {
case _EventReminder() when $default != null:
return $default(_that.action,_that.offsetMinutes,_that.relativeToEnd,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _EventReminder implements EventReminder {
  const _EventReminder({this.action = ReminderAction.display, this.offsetMinutes, this.relativeToEnd = false, this.at});
  

@override@JsonKey() final  ReminderAction action;
@override final  int? offsetMinutes;
@override@JsonKey() final  bool relativeToEnd;
@override final  DateTime? at;

/// Create a copy of EventReminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventReminderCopyWith<_EventReminder> get copyWith => __$EventReminderCopyWithImpl<_EventReminder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventReminder&&(identical(other.action, action) || other.action == action)&&(identical(other.offsetMinutes, offsetMinutes) || other.offsetMinutes == offsetMinutes)&&(identical(other.relativeToEnd, relativeToEnd) || other.relativeToEnd == relativeToEnd)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode {
    return Object.hash(runtimeType,action,offsetMinutes,relativeToEnd,at);
}

@override
String toString() {
    return 'EventReminder(action: $action, offsetMinutes: $offsetMinutes, relativeToEnd: $relativeToEnd, at: $at)';
}


}

/// @nodoc
abstract mixin class _$EventReminderCopyWith<$Res> implements $EventReminderCopyWith<$Res> {
  factory _$EventReminderCopyWith(_EventReminder value, $Res Function(_EventReminder) _then) = __$EventReminderCopyWithImpl;
@override @useResult
$Res call({
 ReminderAction action, int? offsetMinutes, bool relativeToEnd, DateTime? at
});




}
/// @nodoc
class __$EventReminderCopyWithImpl<$Res>
    implements _$EventReminderCopyWith<$Res> {
  __$EventReminderCopyWithImpl(this._self, this._then);

  final _EventReminder _self;
  final $Res Function(_EventReminder) _then;

/// Create a copy of EventReminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? offsetMinutes = freezed,Object? relativeToEnd = null,Object? at = freezed,}) {
  return _then(_EventReminder(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ReminderAction,offsetMinutes: freezed == offsetMinutes ? _self.offsetMinutes : offsetMinutes // ignore: cast_nullable_to_non_nullable
as int?,relativeToEnd: null == relativeToEnd ? _self.relativeToEnd : relativeToEnd // ignore: cast_nullable_to_non_nullable
as bool,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$CalendarEvent {

 EventRef get ref; String get etag; String get summary; DateTime get start; DateTime get end; bool get allDay; String? get description; String? get location; String? get url; String? get timezone; String? get rrule; bool get recurring; bool get modifiedOccurrence; EventStatus get status; EventShowAs get showAs; bool get busyOnly; EventPerson? get organizer; List<EventAttendee> get attendees; List<EventReminder> get reminders;
/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventCopyWith<CalendarEvent> get copyWith => _$CalendarEventCopyWithImpl<CalendarEvent>(this as CalendarEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEvent&&(identical(other.ref, _this.ref) || other.ref == _this.ref)&&(identical(other.etag, _this.etag) || other.etag == _this.etag)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.allDay, _this.allDay) || other.allDay == _this.allDay)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.rrule, _this.rrule) || other.rrule == _this.rrule)&&(identical(other.recurring, _this.recurring) || other.recurring == _this.recurring)&&(identical(other.modifiedOccurrence, _this.modifiedOccurrence) || other.modifiedOccurrence == _this.modifiedOccurrence)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.showAs, _this.showAs) || other.showAs == _this.showAs)&&(identical(other.busyOnly, _this.busyOnly) || other.busyOnly == _this.busyOnly)&&(identical(other.organizer, _this.organizer) || other.organizer == _this.organizer)&&const DeepCollectionEquality().equals(other.attendees, _this.attendees)&&const DeepCollectionEquality().equals(other.reminders, _this.reminders));
}


@override
int get hashCode {
  final _this = this as CalendarEvent;
  return Object.hashAll([runtimeType,_this.ref,_this.etag,_this.summary,_this.start,_this.end,_this.allDay,_this.description,_this.location,_this.url,_this.timezone,_this.rrule,_this.recurring,_this.modifiedOccurrence,_this.status,_this.showAs,_this.busyOnly,_this.organizer,const DeepCollectionEquality().hash(_this.attendees),const DeepCollectionEquality().hash(_this.reminders)]);
}

@override
String toString() {
  final _this = this as CalendarEvent;
  return 'CalendarEvent(ref: ${_this.ref}, etag: ${_this.etag}, summary: ${_this.summary}, start: ${_this.start}, end: ${_this.end}, allDay: ${_this.allDay}, description: ${_this.description}, location: ${_this.location}, url: ${_this.url}, timezone: ${_this.timezone}, rrule: ${_this.rrule}, recurring: ${_this.recurring}, modifiedOccurrence: ${_this.modifiedOccurrence}, status: ${_this.status}, showAs: ${_this.showAs}, busyOnly: ${_this.busyOnly}, organizer: ${_this.organizer}, attendees: ${_this.attendees}, reminders: ${_this.reminders})';
}


}

/// @nodoc
abstract mixin class $CalendarEventCopyWith<$Res>  {
  factory $CalendarEventCopyWith(CalendarEvent value, $Res Function(CalendarEvent) _then) = _$CalendarEventCopyWithImpl;
@useResult
$Res call({
 EventRef ref, String etag, String summary, DateTime start, DateTime end, bool allDay, String? description, String? location, String? url, String? timezone, String? rrule, bool recurring, bool modifiedOccurrence, EventStatus status, EventShowAs showAs, bool busyOnly, EventPerson? organizer, List<EventAttendee> attendees, List<EventReminder> reminders
});


$EventRefCopyWith<$Res> get ref;$EventPersonCopyWith<$Res>? get organizer;

}
/// @nodoc
class _$CalendarEventCopyWithImpl<$Res>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._self, this._then);

  final CalendarEvent _self;
  final $Res Function(CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? etag = null,Object? summary = null,Object? start = null,Object? end = null,Object? allDay = null,Object? description = freezed,Object? location = freezed,Object? url = freezed,Object? timezone = freezed,Object? rrule = freezed,Object? recurring = null,Object? modifiedOccurrence = null,Object? status = null,Object? showAs = null,Object? busyOnly = null,Object? organizer = freezed,Object? attendees = null,Object? reminders = null,}) {
  return _then(CalendarEvent(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as EventRef,etag: null == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,rrule: freezed == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,modifiedOccurrence: null == modifiedOccurrence ? _self.modifiedOccurrence : modifiedOccurrence // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,showAs: null == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as EventShowAs,busyOnly: null == busyOnly ? _self.busyOnly : busyOnly // ignore: cast_nullable_to_non_nullable
as bool,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as EventPerson?,attendees: null == attendees ? _self.attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<EventAttendee>,reminders: null == reminders ? _self.reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<EventReminder>,
  ));
}
/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventRefCopyWith<$Res> get ref {
  
  return $EventRefCopyWith<$Res>(_self.ref, (value) {
    return _then(_self.copyWith(ref: value));
  });
}/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPersonCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $EventPersonCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarEvent].
extension CalendarEventPatterns on CalendarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEvent value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EventRef ref,  String etag,  String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  bool recurring,  bool modifiedOccurrence,  EventStatus status,  EventShowAs showAs,  bool busyOnly,  EventPerson? organizer,  List<EventAttendee> attendees,  List<EventReminder> reminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.ref,_that.etag,_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.recurring,_that.modifiedOccurrence,_that.status,_that.showAs,_that.busyOnly,_that.organizer,_that.attendees,_that.reminders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EventRef ref,  String etag,  String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  bool recurring,  bool modifiedOccurrence,  EventStatus status,  EventShowAs showAs,  bool busyOnly,  EventPerson? organizer,  List<EventAttendee> attendees,  List<EventReminder> reminders)  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent():
return $default(_that.ref,_that.etag,_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.recurring,_that.modifiedOccurrence,_that.status,_that.showAs,_that.busyOnly,_that.organizer,_that.attendees,_that.reminders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EventRef ref,  String etag,  String summary,  DateTime start,  DateTime end,  bool allDay,  String? description,  String? location,  String? url,  String? timezone,  String? rrule,  bool recurring,  bool modifiedOccurrence,  EventStatus status,  EventShowAs showAs,  bool busyOnly,  EventPerson? organizer,  List<EventAttendee> attendees,  List<EventReminder> reminders)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.ref,_that.etag,_that.summary,_that.start,_that.end,_that.allDay,_that.description,_that.location,_that.url,_that.timezone,_that.rrule,_that.recurring,_that.modifiedOccurrence,_that.status,_that.showAs,_that.busyOnly,_that.organizer,_that.attendees,_that.reminders);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarEvent extends CalendarEvent {
  const _CalendarEvent({required this.ref, required this.etag, required this.summary, required this.start, required this.end, this.allDay = false, this.description, this.location, this.url, this.timezone, this.rrule, this.recurring = false, this.modifiedOccurrence = false, this.status = EventStatus.confirmed, this.showAs = EventShowAs.busy, this.busyOnly = false, this.organizer,  List<EventAttendee> attendees = const [],  List<EventReminder> reminders = const []}): _attendees = attendees,_reminders = reminders,super._();
  

@override final  EventRef ref;
@override final  String etag;
@override final  String summary;
@override final  DateTime start;
@override final  DateTime end;
@override@JsonKey() final  bool allDay;
@override final  String? description;
@override final  String? location;
@override final  String? url;
@override final  String? timezone;
@override final  String? rrule;
@override@JsonKey() final  bool recurring;
@override@JsonKey() final  bool modifiedOccurrence;
@override@JsonKey() final  EventStatus status;
@override@JsonKey() final  EventShowAs showAs;
@override@JsonKey() final  bool busyOnly;
@override final  EventPerson? organizer;
 final  List<EventAttendee> _attendees;
@override@JsonKey() List<EventAttendee> get attendees {
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


/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventCopyWith<_CalendarEvent> get copyWith => __$CalendarEventCopyWithImpl<_CalendarEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEvent&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.etag, etag) || other.etag == etag)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.url, url) || other.url == url)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.rrule, rrule) || other.rrule == rrule)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.modifiedOccurrence, modifiedOccurrence) || other.modifiedOccurrence == modifiedOccurrence)&&(identical(other.status, status) || other.status == status)&&(identical(other.showAs, showAs) || other.showAs == showAs)&&(identical(other.busyOnly, busyOnly) || other.busyOnly == busyOnly)&&(identical(other.organizer, organizer) || other.organizer == organizer)&&const DeepCollectionEquality().equals(other.attendees, _attendees)&&const DeepCollectionEquality().equals(other.reminders, _reminders));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,ref,etag,summary,start,end,allDay,description,location,url,timezone,rrule,recurring,modifiedOccurrence,status,showAs,busyOnly,organizer,const DeepCollectionEquality().hash(_attendees),const DeepCollectionEquality().hash(_reminders)]);
}

@override
String toString() {
    return 'CalendarEvent(ref: $ref, etag: $etag, summary: $summary, start: $start, end: $end, allDay: $allDay, description: $description, location: $location, url: $url, timezone: $timezone, rrule: $rrule, recurring: $recurring, modifiedOccurrence: $modifiedOccurrence, status: $status, showAs: $showAs, busyOnly: $busyOnly, organizer: $organizer, attendees: $attendees, reminders: $reminders)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventCopyWith<$Res> implements $CalendarEventCopyWith<$Res> {
  factory _$CalendarEventCopyWith(_CalendarEvent value, $Res Function(_CalendarEvent) _then) = __$CalendarEventCopyWithImpl;
@override @useResult
$Res call({
 EventRef ref, String etag, String summary, DateTime start, DateTime end, bool allDay, String? description, String? location, String? url, String? timezone, String? rrule, bool recurring, bool modifiedOccurrence, EventStatus status, EventShowAs showAs, bool busyOnly, EventPerson? organizer, List<EventAttendee> attendees, List<EventReminder> reminders
});


@override $EventRefCopyWith<$Res> get ref;@override $EventPersonCopyWith<$Res>? get organizer;

}
/// @nodoc
class __$CalendarEventCopyWithImpl<$Res>
    implements _$CalendarEventCopyWith<$Res> {
  __$CalendarEventCopyWithImpl(this._self, this._then);

  final _CalendarEvent _self;
  final $Res Function(_CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? etag = null,Object? summary = null,Object? start = null,Object? end = null,Object? allDay = null,Object? description = freezed,Object? location = freezed,Object? url = freezed,Object? timezone = freezed,Object? rrule = freezed,Object? recurring = null,Object? modifiedOccurrence = null,Object? status = null,Object? showAs = null,Object? busyOnly = null,Object? organizer = freezed,Object? attendees = null,Object? reminders = null,}) {
  return _then(_CalendarEvent(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as EventRef,etag: null == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,timezone: freezed == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String?,rrule: freezed == rrule ? _self.rrule : rrule // ignore: cast_nullable_to_non_nullable
as String?,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,modifiedOccurrence: null == modifiedOccurrence ? _self.modifiedOccurrence : modifiedOccurrence // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventStatus,showAs: null == showAs ? _self.showAs : showAs // ignore: cast_nullable_to_non_nullable
as EventShowAs,busyOnly: null == busyOnly ? _self.busyOnly : busyOnly // ignore: cast_nullable_to_non_nullable
as bool,organizer: freezed == organizer ? _self.organizer : organizer // ignore: cast_nullable_to_non_nullable
as EventPerson?,attendees: null == attendees ? _self._attendees : attendees // ignore: cast_nullable_to_non_nullable
as List<EventAttendee>,reminders: null == reminders ? _self._reminders : reminders // ignore: cast_nullable_to_non_nullable
as List<EventReminder>,
  ));
}

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventRefCopyWith<$Res> get ref {
  
  return $EventRefCopyWith<$Res>(_self.ref, (value) {
    return _then(_self.copyWith(ref: value));
  });
}/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPersonCopyWith<$Res>? get organizer {
    if (_self.organizer == null) {
    return null;
  }

  return $EventPersonCopyWith<$Res>(_self.organizer!, (value) {
    return _then(_self.copyWith(organizer: value));
  });
}
}

/// @nodoc
mixin _$CalendarEventDetails {

 CalendarEvent get series; List<CalendarEvent> get overrides;
/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventDetailsCopyWith<CalendarEventDetails> get copyWith => _$CalendarEventDetailsCopyWithImpl<CalendarEventDetails>(this as CalendarEventDetails, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CalendarEventDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEventDetails&&(identical(other.series, _this.series) || other.series == _this.series)&&const DeepCollectionEquality().equals(other.overrides, _this.overrides));
}


@override
int get hashCode {
  final _this = this as CalendarEventDetails;
  return Object.hash(runtimeType,_this.series,const DeepCollectionEquality().hash(_this.overrides));
}

@override
String toString() {
  final _this = this as CalendarEventDetails;
  return 'CalendarEventDetails(series: ${_this.series}, overrides: ${_this.overrides})';
}


}

/// @nodoc
abstract mixin class $CalendarEventDetailsCopyWith<$Res>  {
  factory $CalendarEventDetailsCopyWith(CalendarEventDetails value, $Res Function(CalendarEventDetails) _then) = _$CalendarEventDetailsCopyWithImpl;
@useResult
$Res call({
 CalendarEvent series, List<CalendarEvent> overrides
});


$CalendarEventCopyWith<$Res> get series;

}
/// @nodoc
class _$CalendarEventDetailsCopyWithImpl<$Res>
    implements $CalendarEventDetailsCopyWith<$Res> {
  _$CalendarEventDetailsCopyWithImpl(this._self, this._then);

  final CalendarEventDetails _self;
  final $Res Function(CalendarEventDetails) _then;

/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? series = null,Object? overrides = null,}) {
  return _then(CalendarEventDetails(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as CalendarEvent,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<CalendarEvent>,
  ));
}
/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarEventCopyWith<$Res> get series {
  
  return $CalendarEventCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarEventDetails].
extension CalendarEventDetailsPatterns on CalendarEventDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEventDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEventDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEventDetails value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEventDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEventDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEventDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarEvent series,  List<CalendarEvent> overrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEventDetails() when $default != null:
return $default(_that.series,_that.overrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarEvent series,  List<CalendarEvent> overrides)  $default,) {final _that = this;
switch (_that) {
case _CalendarEventDetails():
return $default(_that.series,_that.overrides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarEvent series,  List<CalendarEvent> overrides)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEventDetails() when $default != null:
return $default(_that.series,_that.overrides);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarEventDetails implements CalendarEventDetails {
  const _CalendarEventDetails({required this.series,  List<CalendarEvent> overrides = const []}): _overrides = overrides;
  

@override final  CalendarEvent series;
 final  List<CalendarEvent> _overrides;
@override@JsonKey() List<CalendarEvent> get overrides {
  if (_overrides is EqualUnmodifiableListView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overrides);
}


/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventDetailsCopyWith<_CalendarEventDetails> get copyWith => __$CalendarEventDetailsCopyWithImpl<_CalendarEventDetails>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEventDetails&&(identical(other.series, series) || other.series == series)&&const DeepCollectionEquality().equals(other.overrides, _overrides));
}


@override
int get hashCode {
    return Object.hash(runtimeType,series,const DeepCollectionEquality().hash(_overrides));
}

@override
String toString() {
    return 'CalendarEventDetails(series: $series, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventDetailsCopyWith<$Res> implements $CalendarEventDetailsCopyWith<$Res> {
  factory _$CalendarEventDetailsCopyWith(_CalendarEventDetails value, $Res Function(_CalendarEventDetails) _then) = __$CalendarEventDetailsCopyWithImpl;
@override @useResult
$Res call({
 CalendarEvent series, List<CalendarEvent> overrides
});


@override $CalendarEventCopyWith<$Res> get series;

}
/// @nodoc
class __$CalendarEventDetailsCopyWithImpl<$Res>
    implements _$CalendarEventDetailsCopyWith<$Res> {
  __$CalendarEventDetailsCopyWithImpl(this._self, this._then);

  final _CalendarEventDetails _self;
  final $Res Function(_CalendarEventDetails) _then;

/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? series = null,Object? overrides = null,}) {
  return _then(_CalendarEventDetails(
series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as CalendarEvent,overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<CalendarEvent>,
  ));
}

/// Create a copy of CalendarEventDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarEventCopyWith<$Res> get series {
  
  return $CalendarEventCopyWith<$Res>(_self.series, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}

// dart format on
