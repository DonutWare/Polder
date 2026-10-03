// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'directory_listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DirectoryListing {

 String get path; List<FileEntry> get entries;
/// Create a copy of DirectoryListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectoryListingCopyWith<DirectoryListing> get copyWith => _$DirectoryListingCopyWithImpl<DirectoryListing>(this as DirectoryListing, _$identity);

  /// Serializes this DirectoryListing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DirectoryListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectoryListing&&(identical(other.path, _this.path) || other.path == _this.path)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DirectoryListing;
  return Object.hash(runtimeType,_this.path,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as DirectoryListing;
  return 'DirectoryListing(path: ${_this.path}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $DirectoryListingCopyWith<$Res>  {
  factory $DirectoryListingCopyWith(DirectoryListing value, $Res Function(DirectoryListing) _then) = _$DirectoryListingCopyWithImpl;
@useResult
$Res call({
 String path, List<FileEntry> entries
});




}
/// @nodoc
class _$DirectoryListingCopyWithImpl<$Res>
    implements $DirectoryListingCopyWith<$Res> {
  _$DirectoryListingCopyWithImpl(this._self, this._then);

  final DirectoryListing _self;
  final $Res Function(DirectoryListing) _then;

/// Create a copy of DirectoryListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? entries = null,}) {
  return _then(DirectoryListing(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FileEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [DirectoryListing].
extension DirectoryListingPatterns on DirectoryListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DirectoryListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DirectoryListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DirectoryListing value)  $default,){
final _that = this;
switch (_that) {
case _DirectoryListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DirectoryListing value)?  $default,){
final _that = this;
switch (_that) {
case _DirectoryListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  List<FileEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DirectoryListing() when $default != null:
return $default(_that.path,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  List<FileEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _DirectoryListing():
return $default(_that.path,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  List<FileEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _DirectoryListing() when $default != null:
return $default(_that.path,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DirectoryListing extends DirectoryListing {
  const _DirectoryListing({required this.path,  List<FileEntry> entries = const <FileEntry>[]}): _entries = entries,super._();
  factory _DirectoryListing.fromJson(Map<String, dynamic> json) => _$DirectoryListingFromJson(json);

@override final  String path;
 final  List<FileEntry> _entries;
@override@JsonKey() List<FileEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of DirectoryListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirectoryListingCopyWith<_DirectoryListing> get copyWith => __$DirectoryListingCopyWithImpl<_DirectoryListing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DirectoryListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DirectoryListing&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'DirectoryListing(path: $path, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$DirectoryListingCopyWith<$Res> implements $DirectoryListingCopyWith<$Res> {
  factory _$DirectoryListingCopyWith(_DirectoryListing value, $Res Function(_DirectoryListing) _then) = __$DirectoryListingCopyWithImpl;
@override @useResult
$Res call({
 String path, List<FileEntry> entries
});




}
/// @nodoc
class __$DirectoryListingCopyWithImpl<$Res>
    implements _$DirectoryListingCopyWith<$Res> {
  __$DirectoryListingCopyWithImpl(this._self, this._then);

  final _DirectoryListing _self;
  final $Res Function(_DirectoryListing) _then;

/// Create a copy of DirectoryListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? entries = null,}) {
  return _then(_DirectoryListing(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FileEntry>,
  ));
}


}

// dart format on
