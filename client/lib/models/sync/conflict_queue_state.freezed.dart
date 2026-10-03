// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict_queue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConflictQueueState {

 List<Conflict> get conflicts; Set<String> get resolving; bool get applyToAll; Object? get lastError;
/// Create a copy of ConflictQueueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictQueueStateCopyWith<ConflictQueueState> get copyWith => _$ConflictQueueStateCopyWithImpl<ConflictQueueState>(this as ConflictQueueState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConflictQueueState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictQueueState&&const DeepCollectionEquality().equals(other.conflicts, _this.conflicts)&&const DeepCollectionEquality().equals(other.resolving, _this.resolving)&&(identical(other.applyToAll, _this.applyToAll) || other.applyToAll == _this.applyToAll)&&const DeepCollectionEquality().equals(other.lastError, _this.lastError));
}


@override
int get hashCode {
  final _this = this as ConflictQueueState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.conflicts),const DeepCollectionEquality().hash(_this.resolving),_this.applyToAll,const DeepCollectionEquality().hash(_this.lastError));
}

@override
String toString() {
  final _this = this as ConflictQueueState;
  return 'ConflictQueueState(conflicts: ${_this.conflicts}, resolving: ${_this.resolving}, applyToAll: ${_this.applyToAll}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $ConflictQueueStateCopyWith<$Res>  {
  factory $ConflictQueueStateCopyWith(ConflictQueueState value, $Res Function(ConflictQueueState) _then) = _$ConflictQueueStateCopyWithImpl;
@useResult
$Res call({
 List<Conflict> conflicts, Set<String> resolving, bool applyToAll, Object? lastError
});




}
/// @nodoc
class _$ConflictQueueStateCopyWithImpl<$Res>
    implements $ConflictQueueStateCopyWith<$Res> {
  _$ConflictQueueStateCopyWithImpl(this._self, this._then);

  final ConflictQueueState _self;
  final $Res Function(ConflictQueueState) _then;

/// Create a copy of ConflictQueueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conflicts = null,Object? resolving = null,Object? applyToAll = null,Object? lastError = freezed,}) {
  return _then(ConflictQueueState(
conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<Conflict>,resolving: null == resolving ? _self.resolving : resolving // ignore: cast_nullable_to_non_nullable
as Set<String>,applyToAll: null == applyToAll ? _self.applyToAll : applyToAll // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError ,
  ));
}

}


/// Adds pattern-matching-related methods to [ConflictQueueState].
extension ConflictQueueStatePatterns on ConflictQueueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConflictQueueState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConflictQueueState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConflictQueueState value)  $default,){
final _that = this;
switch (_that) {
case _ConflictQueueState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConflictQueueState value)?  $default,){
final _that = this;
switch (_that) {
case _ConflictQueueState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Conflict> conflicts,  Set<String> resolving,  bool applyToAll,  Object? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConflictQueueState() when $default != null:
return $default(_that.conflicts,_that.resolving,_that.applyToAll,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Conflict> conflicts,  Set<String> resolving,  bool applyToAll,  Object? lastError)  $default,) {final _that = this;
switch (_that) {
case _ConflictQueueState():
return $default(_that.conflicts,_that.resolving,_that.applyToAll,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Conflict> conflicts,  Set<String> resolving,  bool applyToAll,  Object? lastError)?  $default,) {final _that = this;
switch (_that) {
case _ConflictQueueState() when $default != null:
return $default(_that.conflicts,_that.resolving,_that.applyToAll,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _ConflictQueueState extends ConflictQueueState {
  const _ConflictQueueState({ List<Conflict> conflicts = const <Conflict>[],  Set<String> resolving = const <String>{}, this.applyToAll = false, this.lastError}): _conflicts = conflicts,_resolving = resolving,super._();
  

 final  List<Conflict> _conflicts;
@override@JsonKey() List<Conflict> get conflicts {
  if (_conflicts is EqualUnmodifiableListView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflicts);
}

 final  Set<String> _resolving;
@override@JsonKey() Set<String> get resolving {
  if (_resolving is EqualUnmodifiableSetView) return _resolving;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_resolving);
}

@override@JsonKey() final  bool applyToAll;
@override final  Object? lastError;

/// Create a copy of ConflictQueueState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConflictQueueStateCopyWith<_ConflictQueueState> get copyWith => __$ConflictQueueStateCopyWithImpl<_ConflictQueueState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConflictQueueState&&const DeepCollectionEquality().equals(other.conflicts, _conflicts)&&const DeepCollectionEquality().equals(other.resolving, _resolving)&&(identical(other.applyToAll, applyToAll) || other.applyToAll == applyToAll)&&const DeepCollectionEquality().equals(other.lastError, lastError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_conflicts),const DeepCollectionEquality().hash(_resolving),applyToAll,const DeepCollectionEquality().hash(lastError));
}

@override
String toString() {
    return 'ConflictQueueState(conflicts: $conflicts, resolving: $resolving, applyToAll: $applyToAll, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$ConflictQueueStateCopyWith<$Res> implements $ConflictQueueStateCopyWith<$Res> {
  factory _$ConflictQueueStateCopyWith(_ConflictQueueState value, $Res Function(_ConflictQueueState) _then) = __$ConflictQueueStateCopyWithImpl;
@override @useResult
$Res call({
 List<Conflict> conflicts, Set<String> resolving, bool applyToAll, Object? lastError
});




}
/// @nodoc
class __$ConflictQueueStateCopyWithImpl<$Res>
    implements _$ConflictQueueStateCopyWith<$Res> {
  __$ConflictQueueStateCopyWithImpl(this._self, this._then);

  final _ConflictQueueState _self;
  final $Res Function(_ConflictQueueState) _then;

/// Create a copy of ConflictQueueState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conflicts = null,Object? resolving = null,Object? applyToAll = null,Object? lastError = freezed,}) {
  return _then(_ConflictQueueState(
conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<Conflict>,resolving: null == resolving ? _self._resolving : resolving // ignore: cast_nullable_to_non_nullable
as Set<String>,applyToAll: null == applyToAll ? _self.applyToAll : applyToAll // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError ,
  ));
}


}

// dart format on
