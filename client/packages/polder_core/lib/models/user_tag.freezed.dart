// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserTag {

 int get id; String get name; Color get color; int get count;
/// Create a copy of UserTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTagCopyWith<UserTag> get copyWith => _$UserTagCopyWithImpl<UserTag>(this as UserTag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserTag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserTag&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as UserTag;
  return Object.hash(runtimeType,_this.id,_this.name,_this.color,_this.count);
}

@override
String toString() {
  final _this = this as UserTag;
  return 'UserTag(id: ${_this.id}, name: ${_this.name}, color: ${_this.color}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $UserTagCopyWith<$Res>  {
  factory $UserTagCopyWith(UserTag value, $Res Function(UserTag) _then) = _$UserTagCopyWithImpl;
@useResult
$Res call({
 int id, String name, Color color, int count
});




}
/// @nodoc
class _$UserTagCopyWithImpl<$Res>
    implements $UserTagCopyWith<$Res> {
  _$UserTagCopyWithImpl(this._self, this._then);

  final UserTag _self;
  final $Res Function(UserTag) _then;

/// Create a copy of UserTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? count = null,}) {
  return _then(UserTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserTag].
extension UserTagPatterns on UserTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserTag value)  $default,){
final _that = this;
switch (_that) {
case _UserTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserTag value)?  $default,){
final _that = this;
switch (_that) {
case _UserTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  Color color,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserTag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  Color color,  int count)  $default,) {final _that = this;
switch (_that) {
case _UserTag():
return $default(_that.id,_that.name,_that.color,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  Color color,  int count)?  $default,) {final _that = this;
switch (_that) {
case _UserTag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _UserTag extends UserTag {
  const _UserTag({required this.id, required this.name, required this.color, this.count = 0}): super._();
  

@override final  int id;
@override final  String name;
@override final  Color color;
@override@JsonKey() final  int count;

/// Create a copy of UserTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserTagCopyWith<_UserTag> get copyWith => __$UserTagCopyWithImpl<_UserTag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserTag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,color,count);
}

@override
String toString() {
    return 'UserTag(id: $id, name: $name, color: $color, count: $count)';
}


}

/// @nodoc
abstract mixin class _$UserTagCopyWith<$Res> implements $UserTagCopyWith<$Res> {
  factory _$UserTagCopyWith(_UserTag value, $Res Function(_UserTag) _then) = __$UserTagCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, Color color, int count
});




}
/// @nodoc
class __$UserTagCopyWithImpl<$Res>
    implements _$UserTagCopyWith<$Res> {
  __$UserTagCopyWithImpl(this._self, this._then);

  final _UserTag _self;
  final $Res Function(_UserTag) _then;

/// Create a copy of UserTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? count = null,}) {
  return _then(_UserTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TagAssignmentResult {

 String get path; String? get error;
/// Create a copy of TagAssignmentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagAssignmentResultCopyWith<TagAssignmentResult> get copyWith => _$TagAssignmentResultCopyWithImpl<TagAssignmentResult>(this as TagAssignmentResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TagAssignmentResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagAssignmentResult&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as TagAssignmentResult;
  return Object.hash(runtimeType,_this.path,_this.error);
}

@override
String toString() {
  final _this = this as TagAssignmentResult;
  return 'TagAssignmentResult(path: ${_this.path}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $TagAssignmentResultCopyWith<$Res>  {
  factory $TagAssignmentResultCopyWith(TagAssignmentResult value, $Res Function(TagAssignmentResult) _then) = _$TagAssignmentResultCopyWithImpl;
@useResult
$Res call({
 String path, String? error
});




}
/// @nodoc
class _$TagAssignmentResultCopyWithImpl<$Res>
    implements $TagAssignmentResultCopyWith<$Res> {
  _$TagAssignmentResultCopyWithImpl(this._self, this._then);

  final TagAssignmentResult _self;
  final $Res Function(TagAssignmentResult) _then;

/// Create a copy of TagAssignmentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? error = freezed,}) {
  return _then(TagAssignmentResult(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagAssignmentResult].
extension TagAssignmentResultPatterns on TagAssignmentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagAssignmentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagAssignmentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagAssignmentResult value)  $default,){
final _that = this;
switch (_that) {
case _TagAssignmentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagAssignmentResult value)?  $default,){
final _that = this;
switch (_that) {
case _TagAssignmentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagAssignmentResult() when $default != null:
return $default(_that.path,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String? error)  $default,) {final _that = this;
switch (_that) {
case _TagAssignmentResult():
return $default(_that.path,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _TagAssignmentResult() when $default != null:
return $default(_that.path,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _TagAssignmentResult extends TagAssignmentResult {
  const _TagAssignmentResult({required this.path, this.error}): super._();
  

@override final  String path;
@override final  String? error;

/// Create a copy of TagAssignmentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagAssignmentResultCopyWith<_TagAssignmentResult> get copyWith => __$TagAssignmentResultCopyWithImpl<_TagAssignmentResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagAssignmentResult&&(identical(other.path, path) || other.path == path)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,error);
}

@override
String toString() {
    return 'TagAssignmentResult(path: $path, error: $error)';
}


}

/// @nodoc
abstract mixin class _$TagAssignmentResultCopyWith<$Res> implements $TagAssignmentResultCopyWith<$Res> {
  factory _$TagAssignmentResultCopyWith(_TagAssignmentResult value, $Res Function(_TagAssignmentResult) _then) = __$TagAssignmentResultCopyWithImpl;
@override @useResult
$Res call({
 String path, String? error
});




}
/// @nodoc
class __$TagAssignmentResultCopyWithImpl<$Res>
    implements _$TagAssignmentResultCopyWith<$Res> {
  __$TagAssignmentResultCopyWithImpl(this._self, this._then);

  final _TagAssignmentResult _self;
  final $Res Function(_TagAssignmentResult) _then;

/// Create a copy of TagAssignmentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? error = freezed,}) {
  return _then(_TagAssignmentResult(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
