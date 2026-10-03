// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Change {

 int get seq; ChangeType get type; String get path; String? get fromPath; FileEntry? get entry;
/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeCopyWith<Change> get copyWith => _$ChangeCopyWithImpl<Change>(this as Change, _$identity);

  /// Serializes this Change to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Change;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Change&&(identical(other.seq, _this.seq) || other.seq == _this.seq)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.fromPath, _this.fromPath) || other.fromPath == _this.fromPath)&&(identical(other.entry, _this.entry) || other.entry == _this.entry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Change;
  return Object.hash(runtimeType,_this.seq,_this.type,_this.path,_this.fromPath,_this.entry);
}

@override
String toString() {
  final _this = this as Change;
  return 'Change(seq: ${_this.seq}, type: ${_this.type}, path: ${_this.path}, fromPath: ${_this.fromPath}, entry: ${_this.entry})';
}


}

/// @nodoc
abstract mixin class $ChangeCopyWith<$Res>  {
  factory $ChangeCopyWith(Change value, $Res Function(Change) _then) = _$ChangeCopyWithImpl;
@useResult
$Res call({
 int seq, ChangeType type, String path, String? fromPath, FileEntry? entry
});


$FileEntryCopyWith<$Res>? get entry;

}
/// @nodoc
class _$ChangeCopyWithImpl<$Res>
    implements $ChangeCopyWith<$Res> {
  _$ChangeCopyWithImpl(this._self, this._then);

  final Change _self;
  final $Res Function(Change) _then;

/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seq = null,Object? type = null,Object? path = null,Object? fromPath = freezed,Object? entry = freezed,}) {
  return _then(Change(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangeType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fromPath: freezed == fromPath ? _self.fromPath : fromPath // ignore: cast_nullable_to_non_nullable
as String?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}
/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [Change].
extension ChangePatterns on Change {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Change value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Change() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Change value)  $default,){
final _that = this;
switch (_that) {
case _Change():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Change value)?  $default,){
final _that = this;
switch (_that) {
case _Change() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seq,  ChangeType type,  String path,  String? fromPath,  FileEntry? entry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Change() when $default != null:
return $default(_that.seq,_that.type,_that.path,_that.fromPath,_that.entry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seq,  ChangeType type,  String path,  String? fromPath,  FileEntry? entry)  $default,) {final _that = this;
switch (_that) {
case _Change():
return $default(_that.seq,_that.type,_that.path,_that.fromPath,_that.entry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seq,  ChangeType type,  String path,  String? fromPath,  FileEntry? entry)?  $default,) {final _that = this;
switch (_that) {
case _Change() when $default != null:
return $default(_that.seq,_that.type,_that.path,_that.fromPath,_that.entry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Change implements Change {
  const _Change({required this.seq, required this.type, required this.path, this.fromPath, this.entry});
  factory _Change.fromJson(Map<String, dynamic> json) => _$ChangeFromJson(json);

@override final  int seq;
@override final  ChangeType type;
@override final  String path;
@override final  String? fromPath;
@override final  FileEntry? entry;

/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeCopyWith<_Change> get copyWith => __$ChangeCopyWithImpl<_Change>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Change&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.fromPath, fromPath) || other.fromPath == fromPath)&&(identical(other.entry, entry) || other.entry == entry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,seq,type,path,fromPath,entry);
}

@override
String toString() {
    return 'Change(seq: $seq, type: $type, path: $path, fromPath: $fromPath, entry: $entry)';
}


}

/// @nodoc
abstract mixin class _$ChangeCopyWith<$Res> implements $ChangeCopyWith<$Res> {
  factory _$ChangeCopyWith(_Change value, $Res Function(_Change) _then) = __$ChangeCopyWithImpl;
@override @useResult
$Res call({
 int seq, ChangeType type, String path, String? fromPath, FileEntry? entry
});


@override $FileEntryCopyWith<$Res>? get entry;

}
/// @nodoc
class __$ChangeCopyWithImpl<$Res>
    implements _$ChangeCopyWith<$Res> {
  __$ChangeCopyWithImpl(this._self, this._then);

  final _Change _self;
  final $Res Function(_Change) _then;

/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seq = null,Object? type = null,Object? path = null,Object? fromPath = freezed,Object? entry = freezed,}) {
  return _then(_Change(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangeType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fromPath: freezed == fromPath ? _self.fromPath : fromPath // ignore: cast_nullable_to_non_nullable
as String?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}

/// Create a copy of Change
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// @nodoc
mixin _$ChangeFeedPage {

 List<Change> get changes; int get cursor; bool get hasMore;
/// Create a copy of ChangeFeedPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeFeedPageCopyWith<ChangeFeedPage> get copyWith => _$ChangeFeedPageCopyWithImpl<ChangeFeedPage>(this as ChangeFeedPage, _$identity);

  /// Serializes this ChangeFeedPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangeFeedPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeFeedPage&&const DeepCollectionEquality().equals(other.changes, _this.changes)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeFeedPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.changes),_this.cursor,_this.hasMore);
}

@override
String toString() {
  final _this = this as ChangeFeedPage;
  return 'ChangeFeedPage(changes: ${_this.changes}, cursor: ${_this.cursor}, hasMore: ${_this.hasMore})';
}


}

/// @nodoc
abstract mixin class $ChangeFeedPageCopyWith<$Res>  {
  factory $ChangeFeedPageCopyWith(ChangeFeedPage value, $Res Function(ChangeFeedPage) _then) = _$ChangeFeedPageCopyWithImpl;
@useResult
$Res call({
 List<Change> changes, int cursor, bool hasMore
});




}
/// @nodoc
class _$ChangeFeedPageCopyWithImpl<$Res>
    implements $ChangeFeedPageCopyWith<$Res> {
  _$ChangeFeedPageCopyWithImpl(this._self, this._then);

  final ChangeFeedPage _self;
  final $Res Function(ChangeFeedPage) _then;

/// Create a copy of ChangeFeedPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changes = null,Object? cursor = null,Object? hasMore = null,}) {
  return _then(ChangeFeedPage(
changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<Change>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeFeedPage].
extension ChangeFeedPagePatterns on ChangeFeedPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeFeedPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeFeedPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeFeedPage value)  $default,){
final _that = this;
switch (_that) {
case _ChangeFeedPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeFeedPage value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeFeedPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Change> changes,  int cursor,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeFeedPage() when $default != null:
return $default(_that.changes,_that.cursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Change> changes,  int cursor,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _ChangeFeedPage():
return $default(_that.changes,_that.cursor,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Change> changes,  int cursor,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _ChangeFeedPage() when $default != null:
return $default(_that.changes,_that.cursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeFeedPage implements ChangeFeedPage {
  const _ChangeFeedPage({ List<Change> changes = const <Change>[], required this.cursor, this.hasMore = false}): _changes = changes;
  factory _ChangeFeedPage.fromJson(Map<String, dynamic> json) => _$ChangeFeedPageFromJson(json);

 final  List<Change> _changes;
@override@JsonKey() List<Change> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

@override final  int cursor;
@override@JsonKey() final  bool hasMore;

/// Create a copy of ChangeFeedPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeFeedPageCopyWith<_ChangeFeedPage> get copyWith => __$ChangeFeedPageCopyWithImpl<_ChangeFeedPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeFeedPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeFeedPage&&const DeepCollectionEquality().equals(other.changes, _changes)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_changes),cursor,hasMore);
}

@override
String toString() {
    return 'ChangeFeedPage(changes: $changes, cursor: $cursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$ChangeFeedPageCopyWith<$Res> implements $ChangeFeedPageCopyWith<$Res> {
  factory _$ChangeFeedPageCopyWith(_ChangeFeedPage value, $Res Function(_ChangeFeedPage) _then) = __$ChangeFeedPageCopyWithImpl;
@override @useResult
$Res call({
 List<Change> changes, int cursor, bool hasMore
});




}
/// @nodoc
class __$ChangeFeedPageCopyWithImpl<$Res>
    implements _$ChangeFeedPageCopyWith<$Res> {
  __$ChangeFeedPageCopyWithImpl(this._self, this._then);

  final _ChangeFeedPage _self;
  final $Res Function(_ChangeFeedPage) _then;

/// Create a copy of ChangeFeedPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changes = null,Object? cursor = null,Object? hasMore = null,}) {
  return _then(_ChangeFeedPage(
changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<Change>,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
