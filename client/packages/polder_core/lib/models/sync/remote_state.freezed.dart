// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RemoteState()';
}


}

/// @nodoc
class $RemoteStateCopyWith<$Res>  {
$RemoteStateCopyWith(RemoteState _, $Res Function(RemoteState) __);
}


/// Adds pattern-matching-related methods to [RemoteState].
extension RemoteStatePatterns on RemoteState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RemoteUpserted value)?  upserted,TResult Function( RemoteDeleted value)?  deleted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RemoteUpserted() when upserted != null:
return upserted(_that);case RemoteDeleted() when deleted != null:
return deleted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RemoteUpserted value)  upserted,required TResult Function( RemoteDeleted value)  deleted,}){
final _that = this;
switch (_that) {
case RemoteUpserted():
return upserted(_that);case RemoteDeleted():
return deleted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RemoteUpserted value)?  upserted,TResult? Function( RemoteDeleted value)?  deleted,}){
final _that = this;
switch (_that) {
case RemoteUpserted() when upserted != null:
return upserted(_that);case RemoteDeleted() when deleted != null:
return deleted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( FileEntry entry)?  upserted,TResult Function()?  deleted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RemoteUpserted() when upserted != null:
return upserted(_that.entry);case RemoteDeleted() when deleted != null:
return deleted();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( FileEntry entry)  upserted,required TResult Function()  deleted,}) {final _that = this;
switch (_that) {
case RemoteUpserted():
return upserted(_that.entry);case RemoteDeleted():
return deleted();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( FileEntry entry)?  upserted,TResult? Function()?  deleted,}) {final _that = this;
switch (_that) {
case RemoteUpserted() when upserted != null:
return upserted(_that.entry);case RemoteDeleted() when deleted != null:
return deleted();case _:
  return null;

}
}

}

/// @nodoc


class RemoteUpserted implements RemoteState {
  const RemoteUpserted(this.entry);
  

 final  FileEntry entry;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteUpsertedCopyWith<RemoteUpserted> get copyWith => _$RemoteUpsertedCopyWithImpl<RemoteUpserted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteUpserted&&(identical(other.entry, entry) || other.entry == entry));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entry);
}

@override
String toString() {
    return 'RemoteState.upserted(entry: $entry)';
}


}

/// @nodoc
abstract mixin class $RemoteUpsertedCopyWith<$Res> implements $RemoteStateCopyWith<$Res> {
  factory $RemoteUpsertedCopyWith(RemoteUpserted value, $Res Function(RemoteUpserted) _then) = _$RemoteUpsertedCopyWithImpl;
@useResult
$Res call({
 FileEntry entry
});


$FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$RemoteUpsertedCopyWithImpl<$Res>
    implements $RemoteUpsertedCopyWith<$Res> {
  _$RemoteUpsertedCopyWithImpl(this._self, this._then);

  final RemoteUpserted _self;
  final $Res Function(RemoteUpserted) _then;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entry = null,}) {
  return _then(RemoteUpserted(
null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}

/// @nodoc


class RemoteDeleted implements RemoteState {
  const RemoteDeleted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteDeleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RemoteState.deleted()';
}


}




// dart format on
