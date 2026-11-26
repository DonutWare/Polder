// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transfer {

 int get id; String get clientId; String get name; TransferDirection get direction; String? get remotePath; int get transferred; int get total; int get rate; TransferStatus get status; Object? get error;
/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferCopyWith<Transfer> get copyWith => _$TransferCopyWithImpl<Transfer>(this as Transfer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Transfer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transfer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.clientId, _this.clientId) || other.clientId == _this.clientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.remotePath, _this.remotePath) || other.remotePath == _this.remotePath)&&(identical(other.transferred, _this.transferred) || other.transferred == _this.transferred)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.error, _this.error));
}


@override
int get hashCode {
  final _this = this as Transfer;
  return Object.hash(runtimeType,_this.id,_this.clientId,_this.name,_this.direction,_this.remotePath,_this.transferred,_this.total,_this.rate,_this.status,const DeepCollectionEquality().hash(_this.error));
}

@override
String toString() {
  final _this = this as Transfer;
  return 'Transfer(id: ${_this.id}, clientId: ${_this.clientId}, name: ${_this.name}, direction: ${_this.direction}, remotePath: ${_this.remotePath}, transferred: ${_this.transferred}, total: ${_this.total}, rate: ${_this.rate}, status: ${_this.status}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $TransferCopyWith<$Res>  {
  factory $TransferCopyWith(Transfer value, $Res Function(Transfer) _then) = _$TransferCopyWithImpl;
@useResult
$Res call({
 int id, String clientId, String name, TransferDirection direction, String? remotePath, int transferred, int total, int rate, TransferStatus status, Object? error
});




}
/// @nodoc
class _$TransferCopyWithImpl<$Res>
    implements $TransferCopyWith<$Res> {
  _$TransferCopyWithImpl(this._self, this._then);

  final Transfer _self;
  final $Res Function(Transfer) _then;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientId = null,Object? name = null,Object? direction = null,Object? remotePath = freezed,Object? transferred = null,Object? total = null,Object? rate = null,Object? status = null,Object? error = freezed,}) {
  return _then(Transfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirection,remotePath: freezed == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String?,transferred: null == transferred ? _self.transferred : transferred // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,error: freezed == error ? _self.error : error ,
  ));
}

}


/// Adds pattern-matching-related methods to [Transfer].
extension TransferPatterns on Transfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transfer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transfer value)  $default,){
final _that = this;
switch (_that) {
case _Transfer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transfer value)?  $default,){
final _that = this;
switch (_that) {
case _Transfer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String clientId,  String name,  TransferDirection direction,  String? remotePath,  int transferred,  int total,  int rate,  TransferStatus status,  Object? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transfer() when $default != null:
return $default(_that.id,_that.clientId,_that.name,_that.direction,_that.remotePath,_that.transferred,_that.total,_that.rate,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String clientId,  String name,  TransferDirection direction,  String? remotePath,  int transferred,  int total,  int rate,  TransferStatus status,  Object? error)  $default,) {final _that = this;
switch (_that) {
case _Transfer():
return $default(_that.id,_that.clientId,_that.name,_that.direction,_that.remotePath,_that.transferred,_that.total,_that.rate,_that.status,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String clientId,  String name,  TransferDirection direction,  String? remotePath,  int transferred,  int total,  int rate,  TransferStatus status,  Object? error)?  $default,) {final _that = this;
switch (_that) {
case _Transfer() when $default != null:
return $default(_that.id,_that.clientId,_that.name,_that.direction,_that.remotePath,_that.transferred,_that.total,_that.rate,_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Transfer extends Transfer {
  const _Transfer({required this.id, required this.clientId, required this.name, required this.direction, this.remotePath, this.transferred = 0, this.total = 0, this.rate = 0, this.status = TransferStatus.running, this.error}): super._();
  

@override final  int id;
@override final  String clientId;
@override final  String name;
@override final  TransferDirection direction;
@override final  String? remotePath;
@override@JsonKey() final  int transferred;
@override@JsonKey() final  int total;
@override@JsonKey() final  int rate;
@override@JsonKey() final  TransferStatus status;
@override final  Object? error;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferCopyWith<_Transfer> get copyWith => __$TransferCopyWithImpl<_Transfer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transfer&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.remotePath, remotePath) || other.remotePath == remotePath)&&(identical(other.transferred, transferred) || other.transferred == transferred)&&(identical(other.total, total) || other.total == total)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,clientId,name,direction,remotePath,transferred,total,rate,status,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Transfer(id: $id, clientId: $clientId, name: $name, direction: $direction, remotePath: $remotePath, transferred: $transferred, total: $total, rate: $rate, status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$TransferCopyWith<$Res> implements $TransferCopyWith<$Res> {
  factory _$TransferCopyWith(_Transfer value, $Res Function(_Transfer) _then) = __$TransferCopyWithImpl;
@override @useResult
$Res call({
 int id, String clientId, String name, TransferDirection direction, String? remotePath, int transferred, int total, int rate, TransferStatus status, Object? error
});




}
/// @nodoc
class __$TransferCopyWithImpl<$Res>
    implements _$TransferCopyWith<$Res> {
  __$TransferCopyWithImpl(this._self, this._then);

  final _Transfer _self;
  final $Res Function(_Transfer) _then;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientId = null,Object? name = null,Object? direction = null,Object? remotePath = freezed,Object? transferred = null,Object? total = null,Object? rate = null,Object? status = null,Object? error = freezed,}) {
  return _then(_Transfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TransferDirection,remotePath: freezed == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String?,transferred: null == transferred ? _self.transferred : transferred // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,error: freezed == error ? _self.error : error ,
  ));
}


}

// dart format on
