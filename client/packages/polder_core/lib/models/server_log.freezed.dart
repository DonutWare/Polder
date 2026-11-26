// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerLogEntry {

 String get id; DateTime? get time; LogLevel? get level; String get component; String get message; Map<String, String> get attrs;
/// Create a copy of ServerLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerLogEntryCopyWith<ServerLogEntry> get copyWith => _$ServerLogEntryCopyWithImpl<ServerLogEntry>(this as ServerLogEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerLogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerLogEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.component, _this.component) || other.component == _this.component)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.attrs, _this.attrs));
}


@override
int get hashCode {
  final _this = this as ServerLogEntry;
  return Object.hash(runtimeType,_this.id,_this.time,_this.level,_this.component,_this.message,const DeepCollectionEquality().hash(_this.attrs));
}

@override
String toString() {
  final _this = this as ServerLogEntry;
  return 'ServerLogEntry(id: ${_this.id}, time: ${_this.time}, level: ${_this.level}, component: ${_this.component}, message: ${_this.message}, attrs: ${_this.attrs})';
}


}

/// @nodoc
abstract mixin class $ServerLogEntryCopyWith<$Res>  {
  factory $ServerLogEntryCopyWith(ServerLogEntry value, $Res Function(ServerLogEntry) _then) = _$ServerLogEntryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime? time, LogLevel? level, String component, String message, Map<String, String> attrs
});




}
/// @nodoc
class _$ServerLogEntryCopyWithImpl<$Res>
    implements $ServerLogEntryCopyWith<$Res> {
  _$ServerLogEntryCopyWithImpl(this._self, this._then);

  final ServerLogEntry _self;
  final $Res Function(ServerLogEntry) _then;

/// Create a copy of ServerLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? time = freezed,Object? level = freezed,Object? component = null,Object? message = null,Object? attrs = null,}) {
  return _then(ServerLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as LogLevel?,component: null == component ? _self.component : component // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,attrs: null == attrs ? _self.attrs : attrs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerLogEntry].
extension ServerLogEntryPatterns on ServerLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _ServerLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ServerLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime? time,  LogLevel? level,  String component,  String message,  Map<String, String> attrs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerLogEntry() when $default != null:
return $default(_that.id,_that.time,_that.level,_that.component,_that.message,_that.attrs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime? time,  LogLevel? level,  String component,  String message,  Map<String, String> attrs)  $default,) {final _that = this;
switch (_that) {
case _ServerLogEntry():
return $default(_that.id,_that.time,_that.level,_that.component,_that.message,_that.attrs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime? time,  LogLevel? level,  String component,  String message,  Map<String, String> attrs)?  $default,) {final _that = this;
switch (_that) {
case _ServerLogEntry() when $default != null:
return $default(_that.id,_that.time,_that.level,_that.component,_that.message,_that.attrs);case _:
  return null;

}
}

}

/// @nodoc


class _ServerLogEntry implements ServerLogEntry {
  const _ServerLogEntry({required this.id, this.time, this.level, this.component = "", required this.message,  Map<String, String> attrs = const <String, String>{}}): _attrs = attrs;
  

@override final  String id;
@override final  DateTime? time;
@override final  LogLevel? level;
@override@JsonKey() final  String component;
@override final  String message;
 final  Map<String, String> _attrs;
@override@JsonKey() Map<String, String> get attrs {
  if (_attrs is EqualUnmodifiableMapView) return _attrs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attrs);
}


/// Create a copy of ServerLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerLogEntryCopyWith<_ServerLogEntry> get copyWith => __$ServerLogEntryCopyWithImpl<_ServerLogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.time, time) || other.time == time)&&(identical(other.level, level) || other.level == level)&&(identical(other.component, component) || other.component == component)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.attrs, _attrs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,time,level,component,message,const DeepCollectionEquality().hash(_attrs));
}

@override
String toString() {
    return 'ServerLogEntry(id: $id, time: $time, level: $level, component: $component, message: $message, attrs: $attrs)';
}


}

/// @nodoc
abstract mixin class _$ServerLogEntryCopyWith<$Res> implements $ServerLogEntryCopyWith<$Res> {
  factory _$ServerLogEntryCopyWith(_ServerLogEntry value, $Res Function(_ServerLogEntry) _then) = __$ServerLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime? time, LogLevel? level, String component, String message, Map<String, String> attrs
});




}
/// @nodoc
class __$ServerLogEntryCopyWithImpl<$Res>
    implements _$ServerLogEntryCopyWith<$Res> {
  __$ServerLogEntryCopyWithImpl(this._self, this._then);

  final _ServerLogEntry _self;
  final $Res Function(_ServerLogEntry) _then;

/// Create a copy of ServerLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? time = freezed,Object? level = freezed,Object? component = null,Object? message = null,Object? attrs = null,}) {
  return _then(_ServerLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as LogLevel?,component: null == component ? _self.component : component // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,attrs: null == attrs ? _self._attrs : attrs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$ServerLogPage {

 List<ServerLogEntry> get entries; String get nextCursor;
/// Create a copy of ServerLogPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerLogPageCopyWith<ServerLogPage> get copyWith => _$ServerLogPageCopyWithImpl<ServerLogPage>(this as ServerLogPage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerLogPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerLogPage&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}


@override
int get hashCode {
  final _this = this as ServerLogPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.entries),_this.nextCursor);
}

@override
String toString() {
  final _this = this as ServerLogPage;
  return 'ServerLogPage(entries: ${_this.entries}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $ServerLogPageCopyWith<$Res>  {
  factory $ServerLogPageCopyWith(ServerLogPage value, $Res Function(ServerLogPage) _then) = _$ServerLogPageCopyWithImpl;
@useResult
$Res call({
 List<ServerLogEntry> entries, String nextCursor
});




}
/// @nodoc
class _$ServerLogPageCopyWithImpl<$Res>
    implements $ServerLogPageCopyWith<$Res> {
  _$ServerLogPageCopyWithImpl(this._self, this._then);

  final ServerLogPage _self;
  final $Res Function(ServerLogPage) _then;

/// Create a copy of ServerLogPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? nextCursor = null,}) {
  return _then(ServerLogPage(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ServerLogEntry>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerLogPage].
extension ServerLogPagePatterns on ServerLogPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerLogPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerLogPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerLogPage value)  $default,){
final _that = this;
switch (_that) {
case _ServerLogPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerLogPage value)?  $default,){
final _that = this;
switch (_that) {
case _ServerLogPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ServerLogEntry> entries,  String nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerLogPage() when $default != null:
return $default(_that.entries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ServerLogEntry> entries,  String nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ServerLogPage():
return $default(_that.entries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ServerLogEntry> entries,  String nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ServerLogPage() when $default != null:
return $default(_that.entries,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _ServerLogPage extends ServerLogPage {
  const _ServerLogPage({ List<ServerLogEntry> entries = const <ServerLogEntry>[], this.nextCursor = ""}): _entries = entries,super._();
  

 final  List<ServerLogEntry> _entries;
@override@JsonKey() List<ServerLogEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override@JsonKey() final  String nextCursor;

/// Create a copy of ServerLogPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerLogPageCopyWith<_ServerLogPage> get copyWith => __$ServerLogPageCopyWithImpl<_ServerLogPage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerLogPage&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),nextCursor);
}

@override
String toString() {
    return 'ServerLogPage(entries: $entries, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ServerLogPageCopyWith<$Res> implements $ServerLogPageCopyWith<$Res> {
  factory _$ServerLogPageCopyWith(_ServerLogPage value, $Res Function(_ServerLogPage) _then) = __$ServerLogPageCopyWithImpl;
@override @useResult
$Res call({
 List<ServerLogEntry> entries, String nextCursor
});




}
/// @nodoc
class __$ServerLogPageCopyWithImpl<$Res>
    implements _$ServerLogPageCopyWith<$Res> {
  __$ServerLogPageCopyWithImpl(this._self, this._then);

  final _ServerLogPage _self;
  final $Res Function(_ServerLogPage) _then;

/// Create a copy of ServerLogPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? nextCursor = null,}) {
  return _then(_ServerLogPage(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ServerLogEntry>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ServerLogFile {

 String get name; DateTime get day; int get size;
/// Create a copy of ServerLogFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerLogFileCopyWith<ServerLogFile> get copyWith => _$ServerLogFileCopyWithImpl<ServerLogFile>(this as ServerLogFile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerLogFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerLogFile&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.day, _this.day) || other.day == _this.day)&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as ServerLogFile;
  return Object.hash(runtimeType,_this.name,_this.day,_this.size);
}

@override
String toString() {
  final _this = this as ServerLogFile;
  return 'ServerLogFile(name: ${_this.name}, day: ${_this.day}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $ServerLogFileCopyWith<$Res>  {
  factory $ServerLogFileCopyWith(ServerLogFile value, $Res Function(ServerLogFile) _then) = _$ServerLogFileCopyWithImpl;
@useResult
$Res call({
 String name, DateTime day, int size
});




}
/// @nodoc
class _$ServerLogFileCopyWithImpl<$Res>
    implements $ServerLogFileCopyWith<$Res> {
  _$ServerLogFileCopyWithImpl(this._self, this._then);

  final ServerLogFile _self;
  final $Res Function(ServerLogFile) _then;

/// Create a copy of ServerLogFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? day = null,Object? size = null,}) {
  return _then(ServerLogFile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerLogFile].
extension ServerLogFilePatterns on ServerLogFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerLogFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerLogFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerLogFile value)  $default,){
final _that = this;
switch (_that) {
case _ServerLogFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerLogFile value)?  $default,){
final _that = this;
switch (_that) {
case _ServerLogFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime day,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerLogFile() when $default != null:
return $default(_that.name,_that.day,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime day,  int size)  $default,) {final _that = this;
switch (_that) {
case _ServerLogFile():
return $default(_that.name,_that.day,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime day,  int size)?  $default,) {final _that = this;
switch (_that) {
case _ServerLogFile() when $default != null:
return $default(_that.name,_that.day,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _ServerLogFile implements ServerLogFile {
  const _ServerLogFile({required this.name, required this.day, required this.size});
  

@override final  String name;
@override final  DateTime day;
@override final  int size;

/// Create a copy of ServerLogFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerLogFileCopyWith<_ServerLogFile> get copyWith => __$ServerLogFileCopyWithImpl<_ServerLogFile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerLogFile&&(identical(other.name, name) || other.name == name)&&(identical(other.day, day) || other.day == day)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,day,size);
}

@override
String toString() {
    return 'ServerLogFile(name: $name, day: $day, size: $size)';
}


}

/// @nodoc
abstract mixin class _$ServerLogFileCopyWith<$Res> implements $ServerLogFileCopyWith<$Res> {
  factory _$ServerLogFileCopyWith(_ServerLogFile value, $Res Function(_ServerLogFile) _then) = __$ServerLogFileCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime day, int size
});




}
/// @nodoc
class __$ServerLogFileCopyWithImpl<$Res>
    implements _$ServerLogFileCopyWith<$Res> {
  __$ServerLogFileCopyWithImpl(this._self, this._then);

  final _ServerLogFile _self;
  final $Res Function(_ServerLogFile) _then;

/// Create a copy of ServerLogFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? day = null,Object? size = null,}) {
  return _then(_ServerLogFile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ServerLogFilter {

 LogLevel get minLevel; String? get component; String get query;
/// Create a copy of ServerLogFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerLogFilterCopyWith<ServerLogFilter> get copyWith => _$ServerLogFilterCopyWithImpl<ServerLogFilter>(this as ServerLogFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerLogFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerLogFilter&&(identical(other.minLevel, _this.minLevel) || other.minLevel == _this.minLevel)&&(identical(other.component, _this.component) || other.component == _this.component)&&(identical(other.query, _this.query) || other.query == _this.query));
}


@override
int get hashCode {
  final _this = this as ServerLogFilter;
  return Object.hash(runtimeType,_this.minLevel,_this.component,_this.query);
}

@override
String toString() {
  final _this = this as ServerLogFilter;
  return 'ServerLogFilter(minLevel: ${_this.minLevel}, component: ${_this.component}, query: ${_this.query})';
}


}

/// @nodoc
abstract mixin class $ServerLogFilterCopyWith<$Res>  {
  factory $ServerLogFilterCopyWith(ServerLogFilter value, $Res Function(ServerLogFilter) _then) = _$ServerLogFilterCopyWithImpl;
@useResult
$Res call({
 LogLevel minLevel, String? component, String query
});




}
/// @nodoc
class _$ServerLogFilterCopyWithImpl<$Res>
    implements $ServerLogFilterCopyWith<$Res> {
  _$ServerLogFilterCopyWithImpl(this._self, this._then);

  final ServerLogFilter _self;
  final $Res Function(ServerLogFilter) _then;

/// Create a copy of ServerLogFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minLevel = null,Object? component = freezed,Object? query = null,}) {
  return _then(ServerLogFilter(
minLevel: null == minLevel ? _self.minLevel : minLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,component: freezed == component ? _self.component : component // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerLogFilter].
extension ServerLogFilterPatterns on ServerLogFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerLogFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerLogFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerLogFilter value)  $default,){
final _that = this;
switch (_that) {
case _ServerLogFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerLogFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ServerLogFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogLevel minLevel,  String? component,  String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerLogFilter() when $default != null:
return $default(_that.minLevel,_that.component,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogLevel minLevel,  String? component,  String query)  $default,) {final _that = this;
switch (_that) {
case _ServerLogFilter():
return $default(_that.minLevel,_that.component,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogLevel minLevel,  String? component,  String query)?  $default,) {final _that = this;
switch (_that) {
case _ServerLogFilter() when $default != null:
return $default(_that.minLevel,_that.component,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _ServerLogFilter implements ServerLogFilter {
  const _ServerLogFilter({this.minLevel = LogLevel.debug, this.component, this.query = ""});
  

@override@JsonKey() final  LogLevel minLevel;
@override final  String? component;
@override@JsonKey() final  String query;

/// Create a copy of ServerLogFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerLogFilterCopyWith<_ServerLogFilter> get copyWith => __$ServerLogFilterCopyWithImpl<_ServerLogFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerLogFilter&&(identical(other.minLevel, minLevel) || other.minLevel == minLevel)&&(identical(other.component, component) || other.component == component)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minLevel,component,query);
}

@override
String toString() {
    return 'ServerLogFilter(minLevel: $minLevel, component: $component, query: $query)';
}


}

/// @nodoc
abstract mixin class _$ServerLogFilterCopyWith<$Res> implements $ServerLogFilterCopyWith<$Res> {
  factory _$ServerLogFilterCopyWith(_ServerLogFilter value, $Res Function(_ServerLogFilter) _then) = __$ServerLogFilterCopyWithImpl;
@override @useResult
$Res call({
 LogLevel minLevel, String? component, String query
});




}
/// @nodoc
class __$ServerLogFilterCopyWithImpl<$Res>
    implements _$ServerLogFilterCopyWith<$Res> {
  __$ServerLogFilterCopyWithImpl(this._self, this._then);

  final _ServerLogFilter _self;
  final $Res Function(_ServerLogFilter) _then;

/// Create a copy of ServerLogFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minLevel = null,Object? component = freezed,Object? query = null,}) {
  return _then(_ServerLogFilter(
minLevel: null == minLevel ? _self.minLevel : minLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,component: freezed == component ? _self.component : component // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
