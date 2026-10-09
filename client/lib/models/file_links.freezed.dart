// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_links.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileLinks {

 List<OutgoingLink> get outgoing; List<IncomingLink> get incoming;
/// Create a copy of FileLinks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileLinksCopyWith<FileLinks> get copyWith => _$FileLinksCopyWithImpl<FileLinks>(this as FileLinks, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FileLinks;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileLinks&&const DeepCollectionEquality().equals(other.outgoing, _this.outgoing)&&const DeepCollectionEquality().equals(other.incoming, _this.incoming));
}


@override
int get hashCode {
  final _this = this as FileLinks;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.outgoing),const DeepCollectionEquality().hash(_this.incoming));
}

@override
String toString() {
  final _this = this as FileLinks;
  return 'FileLinks(outgoing: ${_this.outgoing}, incoming: ${_this.incoming})';
}


}

/// @nodoc
abstract mixin class $FileLinksCopyWith<$Res>  {
  factory $FileLinksCopyWith(FileLinks value, $Res Function(FileLinks) _then) = _$FileLinksCopyWithImpl;
@useResult
$Res call({
 List<OutgoingLink> outgoing, List<IncomingLink> incoming
});




}
/// @nodoc
class _$FileLinksCopyWithImpl<$Res>
    implements $FileLinksCopyWith<$Res> {
  _$FileLinksCopyWithImpl(this._self, this._then);

  final FileLinks _self;
  final $Res Function(FileLinks) _then;

/// Create a copy of FileLinks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outgoing = null,Object? incoming = null,}) {
  return _then(FileLinks(
outgoing: null == outgoing ? _self.outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as List<OutgoingLink>,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as List<IncomingLink>,
  ));
}

}


/// Adds pattern-matching-related methods to [FileLinks].
extension FileLinksPatterns on FileLinks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileLinks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileLinks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileLinks value)  $default,){
final _that = this;
switch (_that) {
case _FileLinks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileLinks value)?  $default,){
final _that = this;
switch (_that) {
case _FileLinks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OutgoingLink> outgoing,  List<IncomingLink> incoming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileLinks() when $default != null:
return $default(_that.outgoing,_that.incoming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OutgoingLink> outgoing,  List<IncomingLink> incoming)  $default,) {final _that = this;
switch (_that) {
case _FileLinks():
return $default(_that.outgoing,_that.incoming);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OutgoingLink> outgoing,  List<IncomingLink> incoming)?  $default,) {final _that = this;
switch (_that) {
case _FileLinks() when $default != null:
return $default(_that.outgoing,_that.incoming);case _:
  return null;

}
}

}

/// @nodoc


class _FileLinks implements FileLinks {
  const _FileLinks({ List<OutgoingLink> outgoing = const <OutgoingLink>[],  List<IncomingLink> incoming = const <IncomingLink>[]}): _outgoing = outgoing,_incoming = incoming;
  

 final  List<OutgoingLink> _outgoing;
@override@JsonKey() List<OutgoingLink> get outgoing {
  if (_outgoing is EqualUnmodifiableListView) return _outgoing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outgoing);
}

 final  List<IncomingLink> _incoming;
@override@JsonKey() List<IncomingLink> get incoming {
  if (_incoming is EqualUnmodifiableListView) return _incoming;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incoming);
}


/// Create a copy of FileLinks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileLinksCopyWith<_FileLinks> get copyWith => __$FileLinksCopyWithImpl<_FileLinks>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileLinks&&const DeepCollectionEquality().equals(other.outgoing, _outgoing)&&const DeepCollectionEquality().equals(other.incoming, _incoming));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_outgoing),const DeepCollectionEquality().hash(_incoming));
}

@override
String toString() {
    return 'FileLinks(outgoing: $outgoing, incoming: $incoming)';
}


}

/// @nodoc
abstract mixin class _$FileLinksCopyWith<$Res> implements $FileLinksCopyWith<$Res> {
  factory _$FileLinksCopyWith(_FileLinks value, $Res Function(_FileLinks) _then) = __$FileLinksCopyWithImpl;
@override @useResult
$Res call({
 List<OutgoingLink> outgoing, List<IncomingLink> incoming
});




}
/// @nodoc
class __$FileLinksCopyWithImpl<$Res>
    implements _$FileLinksCopyWith<$Res> {
  __$FileLinksCopyWithImpl(this._self, this._then);

  final _FileLinks _self;
  final $Res Function(_FileLinks) _then;

/// Create a copy of FileLinks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outgoing = null,Object? incoming = null,}) {
  return _then(_FileLinks(
outgoing: null == outgoing ? _self._outgoing : outgoing // ignore: cast_nullable_to_non_nullable
as List<OutgoingLink>,incoming: null == incoming ? _self._incoming : incoming // ignore: cast_nullable_to_non_nullable
as List<IncomingLink>,
  ));
}


}

/// @nodoc
mixin _$OutgoingLink {

 String get title; String get targetPath; FileEntry? get target;
/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutgoingLinkCopyWith<OutgoingLink> get copyWith => _$OutgoingLinkCopyWithImpl<OutgoingLink>(this as OutgoingLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutgoingLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingLink&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.targetPath, _this.targetPath) || other.targetPath == _this.targetPath)&&(identical(other.target, _this.target) || other.target == _this.target));
}


@override
int get hashCode {
  final _this = this as OutgoingLink;
  return Object.hash(runtimeType,_this.title,_this.targetPath,_this.target);
}

@override
String toString() {
  final _this = this as OutgoingLink;
  return 'OutgoingLink(title: ${_this.title}, targetPath: ${_this.targetPath}, target: ${_this.target})';
}


}

/// @nodoc
abstract mixin class $OutgoingLinkCopyWith<$Res>  {
  factory $OutgoingLinkCopyWith(OutgoingLink value, $Res Function(OutgoingLink) _then) = _$OutgoingLinkCopyWithImpl;
@useResult
$Res call({
 String title, String targetPath, FileEntry? target
});


$FileEntryCopyWith<$Res>? get target;

}
/// @nodoc
class _$OutgoingLinkCopyWithImpl<$Res>
    implements $OutgoingLinkCopyWith<$Res> {
  _$OutgoingLinkCopyWithImpl(this._self, this._then);

  final OutgoingLink _self;
  final $Res Function(OutgoingLink) _then;

/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? targetPath = null,Object? target = freezed,}) {
  return _then(OutgoingLink(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetPath: null == targetPath ? _self.targetPath : targetPath // ignore: cast_nullable_to_non_nullable
as String,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}
/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutgoingLink].
extension OutgoingLinkPatterns on OutgoingLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutgoingLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutgoingLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutgoingLink value)  $default,){
final _that = this;
switch (_that) {
case _OutgoingLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutgoingLink value)?  $default,){
final _that = this;
switch (_that) {
case _OutgoingLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String targetPath,  FileEntry? target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutgoingLink() when $default != null:
return $default(_that.title,_that.targetPath,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String targetPath,  FileEntry? target)  $default,) {final _that = this;
switch (_that) {
case _OutgoingLink():
return $default(_that.title,_that.targetPath,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String targetPath,  FileEntry? target)?  $default,) {final _that = this;
switch (_that) {
case _OutgoingLink() when $default != null:
return $default(_that.title,_that.targetPath,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _OutgoingLink implements OutgoingLink {
  const _OutgoingLink({required this.title, required this.targetPath, this.target});
  

@override final  String title;
@override final  String targetPath;
@override final  FileEntry? target;

/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutgoingLinkCopyWith<_OutgoingLink> get copyWith => __$OutgoingLinkCopyWithImpl<_OutgoingLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutgoingLink&&(identical(other.title, title) || other.title == title)&&(identical(other.targetPath, targetPath) || other.targetPath == targetPath)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,targetPath,target);
}

@override
String toString() {
    return 'OutgoingLink(title: $title, targetPath: $targetPath, target: $target)';
}


}

/// @nodoc
abstract mixin class _$OutgoingLinkCopyWith<$Res> implements $OutgoingLinkCopyWith<$Res> {
  factory _$OutgoingLinkCopyWith(_OutgoingLink value, $Res Function(_OutgoingLink) _then) = __$OutgoingLinkCopyWithImpl;
@override @useResult
$Res call({
 String title, String targetPath, FileEntry? target
});


@override $FileEntryCopyWith<$Res>? get target;

}
/// @nodoc
class __$OutgoingLinkCopyWithImpl<$Res>
    implements _$OutgoingLinkCopyWith<$Res> {
  __$OutgoingLinkCopyWithImpl(this._self, this._then);

  final _OutgoingLink _self;
  final $Res Function(_OutgoingLink) _then;

/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? targetPath = null,Object? target = freezed,}) {
  return _then(_OutgoingLink(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetPath: null == targetPath ? _self.targetPath : targetPath // ignore: cast_nullable_to_non_nullable
as String,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as FileEntry?,
  ));
}

/// Create a copy of OutgoingLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $FileEntryCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

/// @nodoc
mixin _$IncomingLink {

 String get title; FileEntry get source;
/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingLinkCopyWith<IncomingLink> get copyWith => _$IncomingLinkCopyWithImpl<IncomingLink>(this as IncomingLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IncomingLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingLink&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as IncomingLink;
  return Object.hash(runtimeType,_this.title,_this.source);
}

@override
String toString() {
  final _this = this as IncomingLink;
  return 'IncomingLink(title: ${_this.title}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $IncomingLinkCopyWith<$Res>  {
  factory $IncomingLinkCopyWith(IncomingLink value, $Res Function(IncomingLink) _then) = _$IncomingLinkCopyWithImpl;
@useResult
$Res call({
 String title, FileEntry source
});


$FileEntryCopyWith<$Res> get source;

}
/// @nodoc
class _$IncomingLinkCopyWithImpl<$Res>
    implements $IncomingLinkCopyWith<$Res> {
  _$IncomingLinkCopyWithImpl(this._self, this._then);

  final IncomingLink _self;
  final $Res Function(IncomingLink) _then;

/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? source = null,}) {
  return _then(IncomingLink(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}
/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get source {
  
  return $FileEntryCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [IncomingLink].
extension IncomingLinkPatterns on IncomingLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomingLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomingLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomingLink value)  $default,){
final _that = this;
switch (_that) {
case _IncomingLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomingLink value)?  $default,){
final _that = this;
switch (_that) {
case _IncomingLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  FileEntry source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomingLink() when $default != null:
return $default(_that.title,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  FileEntry source)  $default,) {final _that = this;
switch (_that) {
case _IncomingLink():
return $default(_that.title,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  FileEntry source)?  $default,) {final _that = this;
switch (_that) {
case _IncomingLink() when $default != null:
return $default(_that.title,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _IncomingLink implements IncomingLink {
  const _IncomingLink({required this.title, required this.source});
  

@override final  String title;
@override final  FileEntry source;

/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomingLinkCopyWith<_IncomingLink> get copyWith => __$IncomingLinkCopyWithImpl<_IncomingLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomingLink&&(identical(other.title, title) || other.title == title)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,source);
}

@override
String toString() {
    return 'IncomingLink(title: $title, source: $source)';
}


}

/// @nodoc
abstract mixin class _$IncomingLinkCopyWith<$Res> implements $IncomingLinkCopyWith<$Res> {
  factory _$IncomingLinkCopyWith(_IncomingLink value, $Res Function(_IncomingLink) _then) = __$IncomingLinkCopyWithImpl;
@override @useResult
$Res call({
 String title, FileEntry source
});


@override $FileEntryCopyWith<$Res> get source;

}
/// @nodoc
class __$IncomingLinkCopyWithImpl<$Res>
    implements _$IncomingLinkCopyWith<$Res> {
  __$IncomingLinkCopyWithImpl(this._self, this._then);

  final _IncomingLink _self;
  final $Res Function(_IncomingLink) _then;

/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? source = null,}) {
  return _then(_IncomingLink(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of IncomingLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get source {
  
  return $FileEntryCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

// dart format on
