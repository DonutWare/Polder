// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offline_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxError {

 OutboxErrorKind get kind; String get message;
/// Create a copy of OutboxError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxErrorCopyWith<OutboxError> get copyWith => _$OutboxErrorCopyWithImpl<OutboxError>(this as OutboxError, _$identity);

  /// Serializes this OutboxError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboxError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxError&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboxError;
  return Object.hash(runtimeType,_this.kind,_this.message);
}

@override
String toString() {
  final _this = this as OutboxError;
  return 'OutboxError(kind: ${_this.kind}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $OutboxErrorCopyWith<$Res>  {
  factory $OutboxErrorCopyWith(OutboxError value, $Res Function(OutboxError) _then) = _$OutboxErrorCopyWithImpl;
@useResult
$Res call({
 OutboxErrorKind kind, String message
});




}
/// @nodoc
class _$OutboxErrorCopyWithImpl<$Res>
    implements $OutboxErrorCopyWith<$Res> {
  _$OutboxErrorCopyWithImpl(this._self, this._then);

  final OutboxError _self;
  final $Res Function(OutboxError) _then;

/// Create a copy of OutboxError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? message = null,}) {
  return _then(OutboxError(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OutboxErrorKind,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxError].
extension OutboxErrorPatterns on OutboxError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxError value)  $default,){
final _that = this;
switch (_that) {
case _OutboxError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxError value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OutboxErrorKind kind,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxError() when $default != null:
return $default(_that.kind,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OutboxErrorKind kind,  String message)  $default,) {final _that = this;
switch (_that) {
case _OutboxError():
return $default(_that.kind,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OutboxErrorKind kind,  String message)?  $default,) {final _that = this;
switch (_that) {
case _OutboxError() when $default != null:
return $default(_that.kind,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxError implements OutboxError {
  const _OutboxError({required this.kind, this.message = ""});
  factory _OutboxError.fromJson(Map<String, dynamic> json) => _$OutboxErrorFromJson(json);

@override final  OutboxErrorKind kind;
@override@JsonKey() final  String message;

/// Create a copy of OutboxError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxErrorCopyWith<_OutboxError> get copyWith => __$OutboxErrorCopyWithImpl<_OutboxError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxError&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,message);
}

@override
String toString() {
    return 'OutboxError(kind: $kind, message: $message)';
}


}

/// @nodoc
abstract mixin class _$OutboxErrorCopyWith<$Res> implements $OutboxErrorCopyWith<$Res> {
  factory _$OutboxErrorCopyWith(_OutboxError value, $Res Function(_OutboxError) _then) = __$OutboxErrorCopyWithImpl;
@override @useResult
$Res call({
 OutboxErrorKind kind, String message
});




}
/// @nodoc
class __$OutboxErrorCopyWithImpl<$Res>
    implements _$OutboxErrorCopyWith<$Res> {
  __$OutboxErrorCopyWithImpl(this._self, this._then);

  final _OutboxError _self;
  final $Res Function(_OutboxError) _then;

/// Create a copy of OutboxError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? message = null,}) {
  return _then(_OutboxError(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OutboxErrorKind,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

OutboxOp _$OutboxOpFromJson(
  Map<String, dynamic> json
) {
        switch (json['op']) {
                  case 'put':
          return PutOp.fromJson(
            json
          );
                case 'move':
          return MoveOp.fromJson(
            json
          );
                case 'delete':
          return DeleteOp.fromJson(
            json
          );
                case 'calendar':
          return CalendarOp.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'op',
  'OutboxOp',
  'Invalid union type "${json['op']}"!'
);
        }
      
}

/// @nodoc
mixin _$OutboxOp {



  /// Serializes this OutboxOp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxOp);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OutboxOp()';
}


}

/// @nodoc
class $OutboxOpCopyWith<$Res>  {
$OutboxOpCopyWith(OutboxOp _, $Res Function(OutboxOp) __);
}


/// Adds pattern-matching-related methods to [OutboxOp].
extension OutboxOpPatterns on OutboxOp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PutOp value)?  put,TResult Function( MoveOp value)?  move,TResult Function( DeleteOp value)?  delete,TResult Function( CalendarOp value)?  calendar,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PutOp() when put != null:
return put(_that);case MoveOp() when move != null:
return move(_that);case DeleteOp() when delete != null:
return delete(_that);case CalendarOp() when calendar != null:
return calendar(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PutOp value)  put,required TResult Function( MoveOp value)  move,required TResult Function( DeleteOp value)  delete,required TResult Function( CalendarOp value)  calendar,}){
final _that = this;
switch (_that) {
case PutOp():
return put(_that);case MoveOp():
return move(_that);case DeleteOp():
return delete(_that);case CalendarOp():
return calendar(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PutOp value)?  put,TResult? Function( MoveOp value)?  move,TResult? Function( DeleteOp value)?  delete,TResult? Function( CalendarOp value)?  calendar,}){
final _that = this;
switch (_that) {
case PutOp() when put != null:
return put(_that);case MoveOp() when move != null:
return move(_that);case DeleteOp() when delete != null:
return delete(_that);case CalendarOp() when calendar != null:
return calendar(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path,  String hash,  int size)?  put,TResult Function( String from,  String to)?  move,TResult Function( String path,  int baseRev)?  delete,TResult Function( String eventKey,  Map<String, dynamic> change)?  calendar,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PutOp() when put != null:
return put(_that.path,_that.hash,_that.size);case MoveOp() when move != null:
return move(_that.from,_that.to);case DeleteOp() when delete != null:
return delete(_that.path,_that.baseRev);case CalendarOp() when calendar != null:
return calendar(_that.eventKey,_that.change);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path,  String hash,  int size)  put,required TResult Function( String from,  String to)  move,required TResult Function( String path,  int baseRev)  delete,required TResult Function( String eventKey,  Map<String, dynamic> change)  calendar,}) {final _that = this;
switch (_that) {
case PutOp():
return put(_that.path,_that.hash,_that.size);case MoveOp():
return move(_that.from,_that.to);case DeleteOp():
return delete(_that.path,_that.baseRev);case CalendarOp():
return calendar(_that.eventKey,_that.change);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path,  String hash,  int size)?  put,TResult? Function( String from,  String to)?  move,TResult? Function( String path,  int baseRev)?  delete,TResult? Function( String eventKey,  Map<String, dynamic> change)?  calendar,}) {final _that = this;
switch (_that) {
case PutOp() when put != null:
return put(_that.path,_that.hash,_that.size);case MoveOp() when move != null:
return move(_that.from,_that.to);case DeleteOp() when delete != null:
return delete(_that.path,_that.baseRev);case CalendarOp() when calendar != null:
return calendar(_that.eventKey,_that.change);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class PutOp extends OutboxOp {
  const PutOp({required this.path, required this.hash, required this.size,  String? $type}): $type = $type ?? 'put',super._();
  factory PutOp.fromJson(Map<String, dynamic> json) => _$PutOpFromJson(json);

 final  String path;
 final  String hash;
 final  int size;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PutOpCopyWith<PutOp> get copyWith => _$PutOpCopyWithImpl<PutOp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PutOpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PutOp&&(identical(other.path, path) || other.path == path)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,hash,size);
}

@override
String toString() {
    return 'OutboxOp.put(path: $path, hash: $hash, size: $size)';
}


}

/// @nodoc
abstract mixin class $PutOpCopyWith<$Res> implements $OutboxOpCopyWith<$Res> {
  factory $PutOpCopyWith(PutOp value, $Res Function(PutOp) _then) = _$PutOpCopyWithImpl;
@useResult
$Res call({
 String path, String hash, int size
});




}
/// @nodoc
class _$PutOpCopyWithImpl<$Res>
    implements $PutOpCopyWith<$Res> {
  _$PutOpCopyWithImpl(this._self, this._then);

  final PutOp _self;
  final $Res Function(PutOp) _then;

/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,Object? hash = null,Object? size = null,}) {
  return _then(PutOp(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MoveOp extends OutboxOp {
  const MoveOp({required this.from, required this.to,  String? $type}): $type = $type ?? 'move',super._();
  factory MoveOp.fromJson(Map<String, dynamic> json) => _$MoveOpFromJson(json);

 final  String from;
 final  String to;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveOpCopyWith<MoveOp> get copyWith => _$MoveOpCopyWithImpl<MoveOp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveOpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveOp&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,from,to);
}

@override
String toString() {
    return 'OutboxOp.move(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $MoveOpCopyWith<$Res> implements $OutboxOpCopyWith<$Res> {
  factory $MoveOpCopyWith(MoveOp value, $Res Function(MoveOp) _then) = _$MoveOpCopyWithImpl;
@useResult
$Res call({
 String from, String to
});




}
/// @nodoc
class _$MoveOpCopyWithImpl<$Res>
    implements $MoveOpCopyWith<$Res> {
  _$MoveOpCopyWithImpl(this._self, this._then);

  final MoveOp _self;
  final $Res Function(MoveOp) _then;

/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(MoveOp(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DeleteOp extends OutboxOp {
  const DeleteOp({required this.path, this.baseRev = -1,  String? $type}): $type = $type ?? 'delete',super._();
  factory DeleteOp.fromJson(Map<String, dynamic> json) => _$DeleteOpFromJson(json);

 final  String path;
@JsonKey() final  int baseRev;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteOpCopyWith<DeleteOp> get copyWith => _$DeleteOpCopyWithImpl<DeleteOp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeleteOpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteOp&&(identical(other.path, path) || other.path == path)&&(identical(other.baseRev, baseRev) || other.baseRev == baseRev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,baseRev);
}

@override
String toString() {
    return 'OutboxOp.delete(path: $path, baseRev: $baseRev)';
}


}

/// @nodoc
abstract mixin class $DeleteOpCopyWith<$Res> implements $OutboxOpCopyWith<$Res> {
  factory $DeleteOpCopyWith(DeleteOp value, $Res Function(DeleteOp) _then) = _$DeleteOpCopyWithImpl;
@useResult
$Res call({
 String path, int baseRev
});




}
/// @nodoc
class _$DeleteOpCopyWithImpl<$Res>
    implements $DeleteOpCopyWith<$Res> {
  _$DeleteOpCopyWithImpl(this._self, this._then);

  final DeleteOp _self;
  final $Res Function(DeleteOp) _then;

/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,Object? baseRev = null,}) {
  return _then(DeleteOp(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CalendarOp extends OutboxOp {
  const CalendarOp({required this.eventKey, required  Map<String, dynamic> change,  String? $type}): _change = change,$type = $type ?? 'calendar',super._();
  factory CalendarOp.fromJson(Map<String, dynamic> json) => _$CalendarOpFromJson(json);

 final  String eventKey;
 final  Map<String, dynamic> _change;
 Map<String, dynamic> get change {
  if (_change is EqualUnmodifiableMapView) return _change;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_change);
}


@JsonKey(name: 'op')
final String $type;


/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarOpCopyWith<CalendarOp> get copyWith => _$CalendarOpCopyWithImpl<CalendarOp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarOpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarOp&&(identical(other.eventKey, eventKey) || other.eventKey == eventKey)&&const DeepCollectionEquality().equals(other.change, _change));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,eventKey,const DeepCollectionEquality().hash(_change));
}

@override
String toString() {
    return 'OutboxOp.calendar(eventKey: $eventKey, change: $change)';
}


}

/// @nodoc
abstract mixin class $CalendarOpCopyWith<$Res> implements $OutboxOpCopyWith<$Res> {
  factory $CalendarOpCopyWith(CalendarOp value, $Res Function(CalendarOp) _then) = _$CalendarOpCopyWithImpl;
@useResult
$Res call({
 String eventKey, Map<String, dynamic> change
});




}
/// @nodoc
class _$CalendarOpCopyWithImpl<$Res>
    implements $CalendarOpCopyWith<$Res> {
  _$CalendarOpCopyWithImpl(this._self, this._then);

  final CalendarOp _self;
  final $Res Function(CalendarOp) _then;

/// Create a copy of OutboxOp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? eventKey = null,Object? change = null,}) {
  return _then(CalendarOp(
eventKey: null == eventKey ? _self.eventKey : eventKey // ignore: cast_nullable_to_non_nullable
as String,change: null == change ? _self._change : change // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc
mixin _$OutboxEntry {

 int get id; OutboxOp get op; DateTime get createdAt; int get attempts; DateTime? get nextAttemptAt; OutboxError? get error;
/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxEntryCopyWith<OutboxEntry> get copyWith => _$OutboxEntryCopyWithImpl<OutboxEntry>(this as OutboxEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutboxEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.op, _this.op) || other.op == _this.op)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.nextAttemptAt, _this.nextAttemptAt) || other.nextAttemptAt == _this.nextAttemptAt)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as OutboxEntry;
  return Object.hash(runtimeType,_this.id,_this.op,_this.createdAt,_this.attempts,_this.nextAttemptAt,_this.error);
}

@override
String toString() {
  final _this = this as OutboxEntry;
  return 'OutboxEntry(id: ${_this.id}, op: ${_this.op}, createdAt: ${_this.createdAt}, attempts: ${_this.attempts}, nextAttemptAt: ${_this.nextAttemptAt}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $OutboxEntryCopyWith<$Res>  {
  factory $OutboxEntryCopyWith(OutboxEntry value, $Res Function(OutboxEntry) _then) = _$OutboxEntryCopyWithImpl;
@useResult
$Res call({
 int id, OutboxOp op, DateTime createdAt, int attempts, DateTime? nextAttemptAt, OutboxError? error
});


$OutboxOpCopyWith<$Res> get op;$OutboxErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$OutboxEntryCopyWithImpl<$Res>
    implements $OutboxEntryCopyWith<$Res> {
  _$OutboxEntryCopyWithImpl(this._self, this._then);

  final OutboxEntry _self;
  final $Res Function(OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? op = null,Object? createdAt = null,Object? attempts = null,Object? nextAttemptAt = freezed,Object? error = freezed,}) {
  return _then(OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as OutboxOp,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxError?,
  ));
}
/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxOpCopyWith<$Res> get op {
  
  return $OutboxOpCopyWith<$Res>(_self.op, (value) {
    return _then(_self.copyWith(op: value));
  });
}/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $OutboxErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutboxEntry].
extension OutboxEntryPatterns on OutboxEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxEntry value)  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  OutboxOp op,  DateTime createdAt,  int attempts,  DateTime? nextAttemptAt,  OutboxError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.op,_that.createdAt,_that.attempts,_that.nextAttemptAt,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  OutboxOp op,  DateTime createdAt,  int attempts,  DateTime? nextAttemptAt,  OutboxError? error)  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry():
return $default(_that.id,_that.op,_that.createdAt,_that.attempts,_that.nextAttemptAt,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  OutboxOp op,  DateTime createdAt,  int attempts,  DateTime? nextAttemptAt,  OutboxError? error)?  $default,) {final _that = this;
switch (_that) {
case _OutboxEntry() when $default != null:
return $default(_that.id,_that.op,_that.createdAt,_that.attempts,_that.nextAttemptAt,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _OutboxEntry extends OutboxEntry {
  const _OutboxEntry({required this.id, required this.op, required this.createdAt, this.attempts = 0, this.nextAttemptAt, this.error}): super._();
  

@override final  int id;
@override final  OutboxOp op;
@override final  DateTime createdAt;
@override@JsonKey() final  int attempts;
@override final  DateTime? nextAttemptAt;
@override final  OutboxError? error;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxEntryCopyWith<_OutboxEntry> get copyWith => __$OutboxEntryCopyWithImpl<_OutboxEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.op, op) || other.op == op)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,op,createdAt,attempts,nextAttemptAt,error);
}

@override
String toString() {
    return 'OutboxEntry(id: $id, op: $op, createdAt: $createdAt, attempts: $attempts, nextAttemptAt: $nextAttemptAt, error: $error)';
}


}

/// @nodoc
abstract mixin class _$OutboxEntryCopyWith<$Res> implements $OutboxEntryCopyWith<$Res> {
  factory _$OutboxEntryCopyWith(_OutboxEntry value, $Res Function(_OutboxEntry) _then) = __$OutboxEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, OutboxOp op, DateTime createdAt, int attempts, DateTime? nextAttemptAt, OutboxError? error
});


@override $OutboxOpCopyWith<$Res> get op;@override $OutboxErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$OutboxEntryCopyWithImpl<$Res>
    implements _$OutboxEntryCopyWith<$Res> {
  __$OutboxEntryCopyWithImpl(this._self, this._then);

  final _OutboxEntry _self;
  final $Res Function(_OutboxEntry) _then;

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? op = null,Object? createdAt = null,Object? attempts = null,Object? nextAttemptAt = freezed,Object? error = freezed,}) {
  return _then(_OutboxEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as OutboxOp,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxError?,
  ));
}

/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxOpCopyWith<$Res> get op {
  
  return $OutboxOpCopyWith<$Res>(_self.op, (value) {
    return _then(_self.copyWith(op: value));
  });
}/// Create a copy of OutboxEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $OutboxErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// @nodoc
mixin _$OfflinePin {

 String get path; OfflinePinKind get kind; bool get populated;
/// Create a copy of OfflinePin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflinePinCopyWith<OfflinePin> get copyWith => _$OfflinePinCopyWithImpl<OfflinePin>(this as OfflinePin, _$identity);

  /// Serializes this OfflinePin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfflinePin;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfflinePin&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.populated, _this.populated) || other.populated == _this.populated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfflinePin;
  return Object.hash(runtimeType,_this.path,_this.kind,_this.populated);
}

@override
String toString() {
  final _this = this as OfflinePin;
  return 'OfflinePin(path: ${_this.path}, kind: ${_this.kind}, populated: ${_this.populated})';
}


}

/// @nodoc
abstract mixin class $OfflinePinCopyWith<$Res>  {
  factory $OfflinePinCopyWith(OfflinePin value, $Res Function(OfflinePin) _then) = _$OfflinePinCopyWithImpl;
@useResult
$Res call({
 String path, OfflinePinKind kind, bool populated
});




}
/// @nodoc
class _$OfflinePinCopyWithImpl<$Res>
    implements $OfflinePinCopyWith<$Res> {
  _$OfflinePinCopyWithImpl(this._self, this._then);

  final OfflinePin _self;
  final $Res Function(OfflinePin) _then;

/// Create a copy of OfflinePin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? kind = null,Object? populated = null,}) {
  return _then(OfflinePin(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfflinePinKind,populated: null == populated ? _self.populated : populated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OfflinePin].
extension OfflinePinPatterns on OfflinePin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfflinePin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfflinePin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfflinePin value)  $default,){
final _that = this;
switch (_that) {
case _OfflinePin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfflinePin value)?  $default,){
final _that = this;
switch (_that) {
case _OfflinePin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  OfflinePinKind kind,  bool populated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfflinePin() when $default != null:
return $default(_that.path,_that.kind,_that.populated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  OfflinePinKind kind,  bool populated)  $default,) {final _that = this;
switch (_that) {
case _OfflinePin():
return $default(_that.path,_that.kind,_that.populated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  OfflinePinKind kind,  bool populated)?  $default,) {final _that = this;
switch (_that) {
case _OfflinePin() when $default != null:
return $default(_that.path,_that.kind,_that.populated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfflinePin extends OfflinePin {
  const _OfflinePin({required this.path, required this.kind, this.populated = false}): super._();
  factory _OfflinePin.fromJson(Map<String, dynamic> json) => _$OfflinePinFromJson(json);

@override final  String path;
@override final  OfflinePinKind kind;
@override@JsonKey() final  bool populated;

/// Create a copy of OfflinePin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfflinePinCopyWith<_OfflinePin> get copyWith => __$OfflinePinCopyWithImpl<_OfflinePin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfflinePinToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfflinePin&&(identical(other.path, path) || other.path == path)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.populated, populated) || other.populated == populated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,kind,populated);
}

@override
String toString() {
    return 'OfflinePin(path: $path, kind: $kind, populated: $populated)';
}


}

/// @nodoc
abstract mixin class _$OfflinePinCopyWith<$Res> implements $OfflinePinCopyWith<$Res> {
  factory _$OfflinePinCopyWith(_OfflinePin value, $Res Function(_OfflinePin) _then) = __$OfflinePinCopyWithImpl;
@override @useResult
$Res call({
 String path, OfflinePinKind kind, bool populated
});




}
/// @nodoc
class __$OfflinePinCopyWithImpl<$Res>
    implements _$OfflinePinCopyWith<$Res> {
  __$OfflinePinCopyWithImpl(this._self, this._then);

  final _OfflinePin _self;
  final $Res Function(_OfflinePin) _then;

/// Create a copy of OfflinePin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? kind = null,Object? populated = null,}) {
  return _then(_OfflinePin(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfflinePinKind,populated: null == populated ? _self.populated : populated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OfflineConflict {

 FileEntry? get server; bool get deletedHere; DateTime get detectedAt;
/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflineConflictCopyWith<OfflineConflict> get copyWith => _$OfflineConflictCopyWithImpl<OfflineConflict>(this as OfflineConflict, _$identity);

  /// Serializes this OfflineConflict to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfflineConflict;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfflineConflict&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.deletedHere, _this.deletedHere) || other.deletedHere == _this.deletedHere)&&(identical(other.detectedAt, _this.detectedAt) || other.detectedAt == _this.detectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfflineConflict;
  return Object.hash(runtimeType,_this.server,_this.deletedHere,_this.detectedAt);
}

@override
String toString() {
  final _this = this as OfflineConflict;
  return 'OfflineConflict(server: ${_this.server}, deletedHere: ${_this.deletedHere}, detectedAt: ${_this.detectedAt})';
}


}

/// @nodoc
abstract mixin class $OfflineConflictCopyWith<$Res>  {
  factory $OfflineConflictCopyWith(OfflineConflict value, $Res Function(OfflineConflict) _then) = _$OfflineConflictCopyWithImpl;
@useResult
$Res call({
 FileEntry? server, bool deletedHere, DateTime detectedAt
});


$FileEntryCopyWith<$Res>? get server;

}
/// @nodoc
class _$OfflineConflictCopyWithImpl<$Res>
    implements $OfflineConflictCopyWith<$Res> {
  _$OfflineConflictCopyWithImpl(this._self, this._then);

  final OfflineConflict _self;
  final $Res Function(OfflineConflict) _then;

/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? server = freezed,Object? deletedHere = null,Object? detectedAt = null,}) {
  return _then(OfflineConflict(
server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as FileEntry?,deletedHere: null == deletedHere ? _self.deletedHere : deletedHere // ignore: cast_nullable_to_non_nullable
as bool,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfflineConflict].
extension OfflineConflictPatterns on OfflineConflict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfflineConflict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfflineConflict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfflineConflict value)  $default,){
final _that = this;
switch (_that) {
case _OfflineConflict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfflineConflict value)?  $default,){
final _that = this;
switch (_that) {
case _OfflineConflict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileEntry? server,  bool deletedHere,  DateTime detectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfflineConflict() when $default != null:
return $default(_that.server,_that.deletedHere,_that.detectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileEntry? server,  bool deletedHere,  DateTime detectedAt)  $default,) {final _that = this;
switch (_that) {
case _OfflineConflict():
return $default(_that.server,_that.deletedHere,_that.detectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileEntry? server,  bool deletedHere,  DateTime detectedAt)?  $default,) {final _that = this;
switch (_that) {
case _OfflineConflict() when $default != null:
return $default(_that.server,_that.deletedHere,_that.detectedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfflineConflict implements OfflineConflict {
  const _OfflineConflict({this.server, this.deletedHere = false, required this.detectedAt});
  factory _OfflineConflict.fromJson(Map<String, dynamic> json) => _$OfflineConflictFromJson(json);

@override final  FileEntry? server;
@override@JsonKey() final  bool deletedHere;
@override final  DateTime detectedAt;

/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfflineConflictCopyWith<_OfflineConflict> get copyWith => __$OfflineConflictCopyWithImpl<_OfflineConflict>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfflineConflictToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfflineConflict&&(identical(other.server, server) || other.server == server)&&(identical(other.deletedHere, deletedHere) || other.deletedHere == deletedHere)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,server,deletedHere,detectedAt);
}

@override
String toString() {
    return 'OfflineConflict(server: $server, deletedHere: $deletedHere, detectedAt: $detectedAt)';
}


}

/// @nodoc
abstract mixin class _$OfflineConflictCopyWith<$Res> implements $OfflineConflictCopyWith<$Res> {
  factory _$OfflineConflictCopyWith(_OfflineConflict value, $Res Function(_OfflineConflict) _then) = __$OfflineConflictCopyWithImpl;
@override @useResult
$Res call({
 FileEntry? server, bool deletedHere, DateTime detectedAt
});


@override $FileEntryCopyWith<$Res>? get server;

}
/// @nodoc
class __$OfflineConflictCopyWithImpl<$Res>
    implements _$OfflineConflictCopyWith<$Res> {
  __$OfflineConflictCopyWithImpl(this._self, this._then);

  final _OfflineConflict _self;
  final $Res Function(_OfflineConflict) _then;

/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = freezed,Object? deletedHere = null,Object? detectedAt = null,}) {
  return _then(_OfflineConflict(
server: freezed == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as FileEntry?,deletedHere: null == deletedHere ? _self.deletedHere : deletedHere // ignore: cast_nullable_to_non_nullable
as bool,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of OfflineConflict
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get server {
    if (_self.server == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.server!, (value) {
    return _then(_self.copyWith(server: value));
  });
}
}


/// @nodoc
mixin _$OfflineFile {

 FileEntry get entry; int get baseRev; String get baseHash; String? get localHash; OfflineFileState get state; OfflineConflict? get conflict; OutboxError? get error; bool get transient;
/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflineFileCopyWith<OfflineFile> get copyWith => _$OfflineFileCopyWithImpl<OfflineFile>(this as OfflineFile, _$identity);

  /// Serializes this OfflineFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfflineFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfflineFile&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.baseRev, _this.baseRev) || other.baseRev == _this.baseRev)&&(identical(other.baseHash, _this.baseHash) || other.baseHash == _this.baseHash)&&(identical(other.localHash, _this.localHash) || other.localHash == _this.localHash)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.conflict, _this.conflict) || other.conflict == _this.conflict)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.transient, _this.transient) || other.transient == _this.transient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfflineFile;
  return Object.hash(runtimeType,_this.entry,_this.baseRev,_this.baseHash,_this.localHash,_this.state,_this.conflict,_this.error,_this.transient);
}

@override
String toString() {
  final _this = this as OfflineFile;
  return 'OfflineFile(entry: ${_this.entry}, baseRev: ${_this.baseRev}, baseHash: ${_this.baseHash}, localHash: ${_this.localHash}, state: ${_this.state}, conflict: ${_this.conflict}, error: ${_this.error}, transient: ${_this.transient})';
}


}

/// @nodoc
abstract mixin class $OfflineFileCopyWith<$Res>  {
  factory $OfflineFileCopyWith(OfflineFile value, $Res Function(OfflineFile) _then) = _$OfflineFileCopyWithImpl;
@useResult
$Res call({
 FileEntry entry, int baseRev, String baseHash, String? localHash, OfflineFileState state, OfflineConflict? conflict, OutboxError? error, bool transient
});


$FileEntryCopyWith<$Res> get entry;$OfflineConflictCopyWith<$Res>? get conflict;$OutboxErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$OfflineFileCopyWithImpl<$Res>
    implements $OfflineFileCopyWith<$Res> {
  _$OfflineFileCopyWithImpl(this._self, this._then);

  final OfflineFile _self;
  final $Res Function(OfflineFile) _then;

/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? baseRev = null,Object? baseHash = null,Object? localHash = freezed,Object? state = null,Object? conflict = freezed,Object? error = freezed,Object? transient = null,}) {
  return _then(OfflineFile(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,baseHash: null == baseHash ? _self.baseHash : baseHash // ignore: cast_nullable_to_non_nullable
as String,localHash: freezed == localHash ? _self.localHash : localHash // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfflineFileState,conflict: freezed == conflict ? _self.conflict : conflict // ignore: cast_nullable_to_non_nullable
as OfflineConflict?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxError?,transient: null == transient ? _self.transient : transient // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfflineConflictCopyWith<$Res>? get conflict {
    if (_self.conflict == null) {
    return null;
  }

  return $OfflineConflictCopyWith<$Res>(_self.conflict!, (value) {
    return _then(_self.copyWith(conflict: value));
  });
}/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $OutboxErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfflineFile].
extension OfflineFilePatterns on OfflineFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfflineFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfflineFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfflineFile value)  $default,){
final _that = this;
switch (_that) {
case _OfflineFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfflineFile value)?  $default,){
final _that = this;
switch (_that) {
case _OfflineFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileEntry entry,  int baseRev,  String baseHash,  String? localHash,  OfflineFileState state,  OfflineConflict? conflict,  OutboxError? error,  bool transient)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfflineFile() when $default != null:
return $default(_that.entry,_that.baseRev,_that.baseHash,_that.localHash,_that.state,_that.conflict,_that.error,_that.transient);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileEntry entry,  int baseRev,  String baseHash,  String? localHash,  OfflineFileState state,  OfflineConflict? conflict,  OutboxError? error,  bool transient)  $default,) {final _that = this;
switch (_that) {
case _OfflineFile():
return $default(_that.entry,_that.baseRev,_that.baseHash,_that.localHash,_that.state,_that.conflict,_that.error,_that.transient);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileEntry entry,  int baseRev,  String baseHash,  String? localHash,  OfflineFileState state,  OfflineConflict? conflict,  OutboxError? error,  bool transient)?  $default,) {final _that = this;
switch (_that) {
case _OfflineFile() when $default != null:
return $default(_that.entry,_that.baseRev,_that.baseHash,_that.localHash,_that.state,_that.conflict,_that.error,_that.transient);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfflineFile extends OfflineFile {
  const _OfflineFile({required this.entry, this.baseRev = 0, this.baseHash = "", this.localHash, this.state = OfflineFileState.synced, this.conflict, this.error, this.transient = false}): super._();
  factory _OfflineFile.fromJson(Map<String, dynamic> json) => _$OfflineFileFromJson(json);

@override final  FileEntry entry;
@override@JsonKey() final  int baseRev;
@override@JsonKey() final  String baseHash;
@override final  String? localHash;
@override@JsonKey() final  OfflineFileState state;
@override final  OfflineConflict? conflict;
@override final  OutboxError? error;
@override@JsonKey() final  bool transient;

/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfflineFileCopyWith<_OfflineFile> get copyWith => __$OfflineFileCopyWithImpl<_OfflineFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfflineFileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfflineFile&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.baseRev, baseRev) || other.baseRev == baseRev)&&(identical(other.baseHash, baseHash) || other.baseHash == baseHash)&&(identical(other.localHash, localHash) || other.localHash == localHash)&&(identical(other.state, state) || other.state == state)&&(identical(other.conflict, conflict) || other.conflict == conflict)&&(identical(other.error, error) || other.error == error)&&(identical(other.transient, transient) || other.transient == transient));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entry,baseRev,baseHash,localHash,state,conflict,error,transient);
}

@override
String toString() {
    return 'OfflineFile(entry: $entry, baseRev: $baseRev, baseHash: $baseHash, localHash: $localHash, state: $state, conflict: $conflict, error: $error, transient: $transient)';
}


}

/// @nodoc
abstract mixin class _$OfflineFileCopyWith<$Res> implements $OfflineFileCopyWith<$Res> {
  factory _$OfflineFileCopyWith(_OfflineFile value, $Res Function(_OfflineFile) _then) = __$OfflineFileCopyWithImpl;
@override @useResult
$Res call({
 FileEntry entry, int baseRev, String baseHash, String? localHash, OfflineFileState state, OfflineConflict? conflict, OutboxError? error, bool transient
});


@override $FileEntryCopyWith<$Res> get entry;@override $OfflineConflictCopyWith<$Res>? get conflict;@override $OutboxErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$OfflineFileCopyWithImpl<$Res>
    implements _$OfflineFileCopyWith<$Res> {
  __$OfflineFileCopyWithImpl(this._self, this._then);

  final _OfflineFile _self;
  final $Res Function(_OfflineFile) _then;

/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? baseRev = null,Object? baseHash = null,Object? localHash = freezed,Object? state = null,Object? conflict = freezed,Object? error = freezed,Object? transient = null,}) {
  return _then(_OfflineFile(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,baseHash: null == baseHash ? _self.baseHash : baseHash // ignore: cast_nullable_to_non_nullable
as String,localHash: freezed == localHash ? _self.localHash : localHash // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfflineFileState,conflict: freezed == conflict ? _self.conflict : conflict // ignore: cast_nullable_to_non_nullable
as OfflineConflict?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as OutboxError?,transient: null == transient ? _self.transient : transient // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfflineConflictCopyWith<$Res>? get conflict {
    if (_self.conflict == null) {
    return null;
  }

  return $OfflineConflictCopyWith<$Res>(_self.conflict!, (value) {
    return _then(_self.copyWith(conflict: value));
  });
}/// Create a copy of OfflineFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutboxErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $OutboxErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
