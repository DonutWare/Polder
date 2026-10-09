// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteItem {

 FileEntry get entry; bool get hasNotes; bool get hasReadme;
/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteItemCopyWith<NoteItem> get copyWith => _$NoteItemCopyWithImpl<NoteItem>(this as NoteItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteItem&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.hasNotes, _this.hasNotes) || other.hasNotes == _this.hasNotes)&&(identical(other.hasReadme, _this.hasReadme) || other.hasReadme == _this.hasReadme));
}


@override
int get hashCode {
  final _this = this as NoteItem;
  return Object.hash(runtimeType,_this.entry,_this.hasNotes,_this.hasReadme);
}

@override
String toString() {
  final _this = this as NoteItem;
  return 'NoteItem(entry: ${_this.entry}, hasNotes: ${_this.hasNotes}, hasReadme: ${_this.hasReadme})';
}


}

/// @nodoc
abstract mixin class $NoteItemCopyWith<$Res>  {
  factory $NoteItemCopyWith(NoteItem value, $Res Function(NoteItem) _then) = _$NoteItemCopyWithImpl;
@useResult
$Res call({
 FileEntry entry, bool hasNotes, bool hasReadme
});


$FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$NoteItemCopyWithImpl<$Res>
    implements $NoteItemCopyWith<$Res> {
  _$NoteItemCopyWithImpl(this._self, this._then);

  final NoteItem _self;
  final $Res Function(NoteItem) _then;

/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? hasNotes = null,Object? hasReadme = null,}) {
  return _then(NoteItem(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,hasNotes: null == hasNotes ? _self.hasNotes : hasNotes // ignore: cast_nullable_to_non_nullable
as bool,hasReadme: null == hasReadme ? _self.hasReadme : hasReadme // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [NoteItem].
extension NoteItemPatterns on NoteItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteItem value)  $default,){
final _that = this;
switch (_that) {
case _NoteItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteItem value)?  $default,){
final _that = this;
switch (_that) {
case _NoteItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FileEntry entry,  bool hasNotes,  bool hasReadme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteItem() when $default != null:
return $default(_that.entry,_that.hasNotes,_that.hasReadme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FileEntry entry,  bool hasNotes,  bool hasReadme)  $default,) {final _that = this;
switch (_that) {
case _NoteItem():
return $default(_that.entry,_that.hasNotes,_that.hasReadme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FileEntry entry,  bool hasNotes,  bool hasReadme)?  $default,) {final _that = this;
switch (_that) {
case _NoteItem() when $default != null:
return $default(_that.entry,_that.hasNotes,_that.hasReadme);case _:
  return null;

}
}

}

/// @nodoc


class _NoteItem implements NoteItem {
  const _NoteItem({required this.entry, this.hasNotes = false, this.hasReadme = false});
  

@override final  FileEntry entry;
@override@JsonKey() final  bool hasNotes;
@override@JsonKey() final  bool hasReadme;

/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteItemCopyWith<_NoteItem> get copyWith => __$NoteItemCopyWithImpl<_NoteItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteItem&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.hasNotes, hasNotes) || other.hasNotes == hasNotes)&&(identical(other.hasReadme, hasReadme) || other.hasReadme == hasReadme));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entry,hasNotes,hasReadme);
}

@override
String toString() {
    return 'NoteItem(entry: $entry, hasNotes: $hasNotes, hasReadme: $hasReadme)';
}


}

/// @nodoc
abstract mixin class _$NoteItemCopyWith<$Res> implements $NoteItemCopyWith<$Res> {
  factory _$NoteItemCopyWith(_NoteItem value, $Res Function(_NoteItem) _then) = __$NoteItemCopyWithImpl;
@override @useResult
$Res call({
 FileEntry entry, bool hasNotes, bool hasReadme
});


@override $FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class __$NoteItemCopyWithImpl<$Res>
    implements _$NoteItemCopyWith<$Res> {
  __$NoteItemCopyWithImpl(this._self, this._then);

  final _NoteItem _self;
  final $Res Function(_NoteItem) _then;

/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? hasNotes = null,Object? hasReadme = null,}) {
  return _then(_NoteItem(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,hasNotes: null == hasNotes ? _self.hasNotes : hasNotes // ignore: cast_nullable_to_non_nullable
as bool,hasReadme: null == hasReadme ? _self.hasReadme : hasReadme // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of NoteItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}

// dart format on
