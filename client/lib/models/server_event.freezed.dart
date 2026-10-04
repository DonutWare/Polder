// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ServerEvent()';
}


}

/// @nodoc
class $ServerEventCopyWith<$Res>  {
$ServerEventCopyWith(ServerEvent _, $Res Function(ServerEvent) __);
}


/// Adds pattern-matching-related methods to [ServerEvent].
extension ServerEventPatterns on ServerEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReadyEvent value)?  ready,TResult Function( SnapshotEvent value)?  snapshot,TResult Function( TransferEvent value)?  transfer,TResult Function( ActivityCreatedEvent value)?  activityCreated,TResult Function( FilesChangedEvent value)?  filesChanged,TResult Function( ServerErrorEvent value)?  error,TResult Function( DisconnectedEvent value)?  disconnected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReadyEvent() when ready != null:
return ready(_that);case SnapshotEvent() when snapshot != null:
return snapshot(_that);case TransferEvent() when transfer != null:
return transfer(_that);case ActivityCreatedEvent() when activityCreated != null:
return activityCreated(_that);case FilesChangedEvent() when filesChanged != null:
return filesChanged(_that);case ServerErrorEvent() when error != null:
return error(_that);case DisconnectedEvent() when disconnected != null:
return disconnected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReadyEvent value)  ready,required TResult Function( SnapshotEvent value)  snapshot,required TResult Function( TransferEvent value)  transfer,required TResult Function( ActivityCreatedEvent value)  activityCreated,required TResult Function( FilesChangedEvent value)  filesChanged,required TResult Function( ServerErrorEvent value)  error,required TResult Function( DisconnectedEvent value)  disconnected,}){
final _that = this;
switch (_that) {
case ReadyEvent():
return ready(_that);case SnapshotEvent():
return snapshot(_that);case TransferEvent():
return transfer(_that);case ActivityCreatedEvent():
return activityCreated(_that);case FilesChangedEvent():
return filesChanged(_that);case ServerErrorEvent():
return error(_that);case DisconnectedEvent():
return disconnected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReadyEvent value)?  ready,TResult? Function( SnapshotEvent value)?  snapshot,TResult? Function( TransferEvent value)?  transfer,TResult? Function( ActivityCreatedEvent value)?  activityCreated,TResult? Function( FilesChangedEvent value)?  filesChanged,TResult? Function( ServerErrorEvent value)?  error,TResult? Function( DisconnectedEvent value)?  disconnected,}){
final _that = this;
switch (_that) {
case ReadyEvent() when ready != null:
return ready(_that);case SnapshotEvent() when snapshot != null:
return snapshot(_that);case TransferEvent() when transfer != null:
return transfer(_that);case ActivityCreatedEvent() when activityCreated != null:
return activityCreated(_that);case FilesChangedEvent() when filesChanged != null:
return filesChanged(_that);case ServerErrorEvent() when error != null:
return error(_that);case DisconnectedEvent() when disconnected != null:
return disconnected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ready,TResult Function( List<LiveTransfer> transfers)?  snapshot,TResult Function( TransferPhase phase,  LiveTransfer transfer)?  transfer,TResult Function( ActivityEntry entry)?  activityCreated,TResult Function( int userId,  List<String> dirs)?  filesChanged,TResult Function( String code,  String message)?  error,TResult Function()?  disconnected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReadyEvent() when ready != null:
return ready();case SnapshotEvent() when snapshot != null:
return snapshot(_that.transfers);case TransferEvent() when transfer != null:
return transfer(_that.phase,_that.transfer);case ActivityCreatedEvent() when activityCreated != null:
return activityCreated(_that.entry);case FilesChangedEvent() when filesChanged != null:
return filesChanged(_that.userId,_that.dirs);case ServerErrorEvent() when error != null:
return error(_that.code,_that.message);case DisconnectedEvent() when disconnected != null:
return disconnected();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ready,required TResult Function( List<LiveTransfer> transfers)  snapshot,required TResult Function( TransferPhase phase,  LiveTransfer transfer)  transfer,required TResult Function( ActivityEntry entry)  activityCreated,required TResult Function( int userId,  List<String> dirs)  filesChanged,required TResult Function( String code,  String message)  error,required TResult Function()  disconnected,}) {final _that = this;
switch (_that) {
case ReadyEvent():
return ready();case SnapshotEvent():
return snapshot(_that.transfers);case TransferEvent():
return transfer(_that.phase,_that.transfer);case ActivityCreatedEvent():
return activityCreated(_that.entry);case FilesChangedEvent():
return filesChanged(_that.userId,_that.dirs);case ServerErrorEvent():
return error(_that.code,_that.message);case DisconnectedEvent():
return disconnected();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ready,TResult? Function( List<LiveTransfer> transfers)?  snapshot,TResult? Function( TransferPhase phase,  LiveTransfer transfer)?  transfer,TResult? Function( ActivityEntry entry)?  activityCreated,TResult? Function( int userId,  List<String> dirs)?  filesChanged,TResult? Function( String code,  String message)?  error,TResult? Function()?  disconnected,}) {final _that = this;
switch (_that) {
case ReadyEvent() when ready != null:
return ready();case SnapshotEvent() when snapshot != null:
return snapshot(_that.transfers);case TransferEvent() when transfer != null:
return transfer(_that.phase,_that.transfer);case ActivityCreatedEvent() when activityCreated != null:
return activityCreated(_that.entry);case FilesChangedEvent() when filesChanged != null:
return filesChanged(_that.userId,_that.dirs);case ServerErrorEvent() when error != null:
return error(_that.code,_that.message);case DisconnectedEvent() when disconnected != null:
return disconnected();case _:
  return null;

}
}

}

/// @nodoc


class ReadyEvent extends ServerEvent {
  const ReadyEvent(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadyEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ServerEvent.ready()';
}


}




/// @nodoc


class SnapshotEvent extends ServerEvent {
  const SnapshotEvent( List<LiveTransfer> transfers): _transfers = transfers,super._();
  

 final  List<LiveTransfer> _transfers;
 List<LiveTransfer> get transfers {
  if (_transfers is EqualUnmodifiableListView) return _transfers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transfers);
}


/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnapshotEventCopyWith<SnapshotEvent> get copyWith => _$SnapshotEventCopyWithImpl<SnapshotEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SnapshotEvent&&const DeepCollectionEquality().equals(other.transfers, _transfers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_transfers));
}

@override
String toString() {
    return 'ServerEvent.snapshot(transfers: $transfers)';
}


}

/// @nodoc
abstract mixin class $SnapshotEventCopyWith<$Res> implements $ServerEventCopyWith<$Res> {
  factory $SnapshotEventCopyWith(SnapshotEvent value, $Res Function(SnapshotEvent) _then) = _$SnapshotEventCopyWithImpl;
@useResult
$Res call({
 List<LiveTransfer> transfers
});




}
/// @nodoc
class _$SnapshotEventCopyWithImpl<$Res>
    implements $SnapshotEventCopyWith<$Res> {
  _$SnapshotEventCopyWithImpl(this._self, this._then);

  final SnapshotEvent _self;
  final $Res Function(SnapshotEvent) _then;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? transfers = null,}) {
  return _then(SnapshotEvent(
null == transfers ? _self._transfers : transfers // ignore: cast_nullable_to_non_nullable
as List<LiveTransfer>,
  ));
}


}

/// @nodoc


class TransferEvent extends ServerEvent {
  const TransferEvent(this.phase, this.transfer): super._();
  

 final  TransferPhase phase;
 final  LiveTransfer transfer;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferEventCopyWith<TransferEvent> get copyWith => _$TransferEventCopyWithImpl<TransferEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferEvent&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.transfer, transfer) || other.transfer == transfer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,transfer);
}

@override
String toString() {
    return 'ServerEvent.transfer(phase: $phase, transfer: $transfer)';
}


}

/// @nodoc
abstract mixin class $TransferEventCopyWith<$Res> implements $ServerEventCopyWith<$Res> {
  factory $TransferEventCopyWith(TransferEvent value, $Res Function(TransferEvent) _then) = _$TransferEventCopyWithImpl;
@useResult
$Res call({
 TransferPhase phase, LiveTransfer transfer
});


$LiveTransferCopyWith<$Res> get transfer;

}
/// @nodoc
class _$TransferEventCopyWithImpl<$Res>
    implements $TransferEventCopyWith<$Res> {
  _$TransferEventCopyWithImpl(this._self, this._then);

  final TransferEvent _self;
  final $Res Function(TransferEvent) _then;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? transfer = null,}) {
  return _then(TransferEvent(
null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TransferPhase,null == transfer ? _self.transfer : transfer // ignore: cast_nullable_to_non_nullable
as LiveTransfer,
  ));
}

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LiveTransferCopyWith<$Res> get transfer {
  
  return $LiveTransferCopyWith<$Res>(_self.transfer, (value) {
    return _then(_self.copyWith(transfer: value));
  });
}
}

/// @nodoc


class ActivityCreatedEvent extends ServerEvent {
  const ActivityCreatedEvent(this.entry): super._();
  

 final  ActivityEntry entry;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCreatedEventCopyWith<ActivityCreatedEvent> get copyWith => _$ActivityCreatedEventCopyWithImpl<ActivityCreatedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityCreatedEvent&&(identical(other.entry, entry) || other.entry == entry));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entry);
}

@override
String toString() {
    return 'ServerEvent.activityCreated(entry: $entry)';
}


}

/// @nodoc
abstract mixin class $ActivityCreatedEventCopyWith<$Res> implements $ServerEventCopyWith<$Res> {
  factory $ActivityCreatedEventCopyWith(ActivityCreatedEvent value, $Res Function(ActivityCreatedEvent) _then) = _$ActivityCreatedEventCopyWithImpl;
@useResult
$Res call({
 ActivityEntry entry
});


$ActivityEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$ActivityCreatedEventCopyWithImpl<$Res>
    implements $ActivityCreatedEventCopyWith<$Res> {
  _$ActivityCreatedEventCopyWithImpl(this._self, this._then);

  final ActivityCreatedEvent _self;
  final $Res Function(ActivityCreatedEvent) _then;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entry = null,}) {
  return _then(ActivityCreatedEvent(
null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as ActivityEntry,
  ));
}

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivityEntryCopyWith<$Res> get entry {
  
  return $ActivityEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}

/// @nodoc


class FilesChangedEvent extends ServerEvent {
  const FilesChangedEvent(this.userId,  List<String> dirs): _dirs = dirs,super._();
  

 final  int userId;
 final  List<String> _dirs;
 List<String> get dirs {
  if (_dirs is EqualUnmodifiableListView) return _dirs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dirs);
}


/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesChangedEventCopyWith<FilesChangedEvent> get copyWith => _$FilesChangedEventCopyWithImpl<FilesChangedEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesChangedEvent&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.dirs, _dirs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,const DeepCollectionEquality().hash(_dirs));
}

@override
String toString() {
    return 'ServerEvent.filesChanged(userId: $userId, dirs: $dirs)';
}


}

/// @nodoc
abstract mixin class $FilesChangedEventCopyWith<$Res> implements $ServerEventCopyWith<$Res> {
  factory $FilesChangedEventCopyWith(FilesChangedEvent value, $Res Function(FilesChangedEvent) _then) = _$FilesChangedEventCopyWithImpl;
@useResult
$Res call({
 int userId, List<String> dirs
});




}
/// @nodoc
class _$FilesChangedEventCopyWithImpl<$Res>
    implements $FilesChangedEventCopyWith<$Res> {
  _$FilesChangedEventCopyWithImpl(this._self, this._then);

  final FilesChangedEvent _self;
  final $Res Function(FilesChangedEvent) _then;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? dirs = null,}) {
  return _then(FilesChangedEvent(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,null == dirs ? _self._dirs : dirs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ServerErrorEvent extends ServerEvent {
  const ServerErrorEvent(this.code, this.message): super._();
  

 final  String code;
 final  String message;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorEventCopyWith<ServerErrorEvent> get copyWith => _$ServerErrorEventCopyWithImpl<ServerErrorEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerErrorEvent&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,message);
}

@override
String toString() {
    return 'ServerEvent.error(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerErrorEventCopyWith<$Res> implements $ServerEventCopyWith<$Res> {
  factory $ServerErrorEventCopyWith(ServerErrorEvent value, $Res Function(ServerErrorEvent) _then) = _$ServerErrorEventCopyWithImpl;
@useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$ServerErrorEventCopyWithImpl<$Res>
    implements $ServerErrorEventCopyWith<$Res> {
  _$ServerErrorEventCopyWithImpl(this._self, this._then);

  final ServerErrorEvent _self;
  final $Res Function(ServerErrorEvent) _then;

/// Create a copy of ServerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(ServerErrorEvent(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DisconnectedEvent extends ServerEvent {
  const DisconnectedEvent(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DisconnectedEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ServerEvent.disconnected()';
}


}




// dart format on
