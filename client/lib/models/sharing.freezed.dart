// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sharing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SharePermissions {

 bool get create; bool get edit; bool get delete;
/// Create a copy of SharePermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<SharePermissions> get copyWith => _$SharePermissionsCopyWithImpl<SharePermissions>(this as SharePermissions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SharePermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharePermissions&&(identical(other.create, _this.create) || other.create == _this.create)&&(identical(other.edit, _this.edit) || other.edit == _this.edit)&&(identical(other.delete, _this.delete) || other.delete == _this.delete));
}


@override
int get hashCode {
  final _this = this as SharePermissions;
  return Object.hash(runtimeType,_this.create,_this.edit,_this.delete);
}

@override
String toString() {
  final _this = this as SharePermissions;
  return 'SharePermissions(create: ${_this.create}, edit: ${_this.edit}, delete: ${_this.delete})';
}


}

/// @nodoc
abstract mixin class $SharePermissionsCopyWith<$Res>  {
  factory $SharePermissionsCopyWith(SharePermissions value, $Res Function(SharePermissions) _then) = _$SharePermissionsCopyWithImpl;
@useResult
$Res call({
 bool create, bool edit, bool delete
});




}
/// @nodoc
class _$SharePermissionsCopyWithImpl<$Res>
    implements $SharePermissionsCopyWith<$Res> {
  _$SharePermissionsCopyWithImpl(this._self, this._then);

  final SharePermissions _self;
  final $Res Function(SharePermissions) _then;

/// Create a copy of SharePermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? create = null,Object? edit = null,Object? delete = null,}) {
  return _then(SharePermissions(
create: null == create ? _self.create : create // ignore: cast_nullable_to_non_nullable
as bool,edit: null == edit ? _self.edit : edit // ignore: cast_nullable_to_non_nullable
as bool,delete: null == delete ? _self.delete : delete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SharePermissions].
extension SharePermissionsPatterns on SharePermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharePermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharePermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharePermissions value)  $default,){
final _that = this;
switch (_that) {
case _SharePermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharePermissions value)?  $default,){
final _that = this;
switch (_that) {
case _SharePermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool create,  bool edit,  bool delete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharePermissions() when $default != null:
return $default(_that.create,_that.edit,_that.delete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool create,  bool edit,  bool delete)  $default,) {final _that = this;
switch (_that) {
case _SharePermissions():
return $default(_that.create,_that.edit,_that.delete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool create,  bool edit,  bool delete)?  $default,) {final _that = this;
switch (_that) {
case _SharePermissions() when $default != null:
return $default(_that.create,_that.edit,_that.delete);case _:
  return null;

}
}

}

/// @nodoc


class _SharePermissions extends SharePermissions {
  const _SharePermissions({this.create = false, this.edit = false, this.delete = false}): super._();
  

@override@JsonKey() final  bool create;
@override@JsonKey() final  bool edit;
@override@JsonKey() final  bool delete;

/// Create a copy of SharePermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharePermissionsCopyWith<_SharePermissions> get copyWith => __$SharePermissionsCopyWithImpl<_SharePermissions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharePermissions&&(identical(other.create, create) || other.create == create)&&(identical(other.edit, edit) || other.edit == edit)&&(identical(other.delete, delete) || other.delete == delete));
}


@override
int get hashCode {
    return Object.hash(runtimeType,create,edit,delete);
}

@override
String toString() {
    return 'SharePermissions(create: $create, edit: $edit, delete: $delete)';
}


}

/// @nodoc
abstract mixin class _$SharePermissionsCopyWith<$Res> implements $SharePermissionsCopyWith<$Res> {
  factory _$SharePermissionsCopyWith(_SharePermissions value, $Res Function(_SharePermissions) _then) = __$SharePermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool create, bool edit, bool delete
});




}
/// @nodoc
class __$SharePermissionsCopyWithImpl<$Res>
    implements _$SharePermissionsCopyWith<$Res> {
  __$SharePermissionsCopyWithImpl(this._self, this._then);

  final _SharePermissions _self;
  final $Res Function(_SharePermissions) _then;

/// Create a copy of SharePermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? create = null,Object? edit = null,Object? delete = null,}) {
  return _then(_SharePermissions(
create: null == create ? _self.create : create // ignore: cast_nullable_to_non_nullable
as bool,edit: null == edit ? _self.edit : edit // ignore: cast_nullable_to_non_nullable
as bool,delete: null == delete ? _self.delete : delete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LinkPermissions {

 bool get view; bool get download; bool get upload;
/// Create a copy of LinkPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<LinkPermissions> get copyWith => _$LinkPermissionsCopyWithImpl<LinkPermissions>(this as LinkPermissions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LinkPermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkPermissions&&(identical(other.view, _this.view) || other.view == _this.view)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.upload, _this.upload) || other.upload == _this.upload));
}


@override
int get hashCode {
  final _this = this as LinkPermissions;
  return Object.hash(runtimeType,_this.view,_this.download,_this.upload);
}

@override
String toString() {
  final _this = this as LinkPermissions;
  return 'LinkPermissions(view: ${_this.view}, download: ${_this.download}, upload: ${_this.upload})';
}


}

/// @nodoc
abstract mixin class $LinkPermissionsCopyWith<$Res>  {
  factory $LinkPermissionsCopyWith(LinkPermissions value, $Res Function(LinkPermissions) _then) = _$LinkPermissionsCopyWithImpl;
@useResult
$Res call({
 bool view, bool download, bool upload
});




}
/// @nodoc
class _$LinkPermissionsCopyWithImpl<$Res>
    implements $LinkPermissionsCopyWith<$Res> {
  _$LinkPermissionsCopyWithImpl(this._self, this._then);

  final LinkPermissions _self;
  final $Res Function(LinkPermissions) _then;

/// Create a copy of LinkPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = null,Object? download = null,Object? upload = null,}) {
  return _then(LinkPermissions(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as bool,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as bool,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkPermissions].
extension LinkPermissionsPatterns on LinkPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkPermissions value)  $default,){
final _that = this;
switch (_that) {
case _LinkPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _LinkPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool view,  bool download,  bool upload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkPermissions() when $default != null:
return $default(_that.view,_that.download,_that.upload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool view,  bool download,  bool upload)  $default,) {final _that = this;
switch (_that) {
case _LinkPermissions():
return $default(_that.view,_that.download,_that.upload);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool view,  bool download,  bool upload)?  $default,) {final _that = this;
switch (_that) {
case _LinkPermissions() when $default != null:
return $default(_that.view,_that.download,_that.upload);case _:
  return null;

}
}

}

/// @nodoc


class _LinkPermissions extends LinkPermissions {
  const _LinkPermissions({this.view = true, this.download = true, this.upload = false}): super._();
  

@override@JsonKey() final  bool view;
@override@JsonKey() final  bool download;
@override@JsonKey() final  bool upload;

/// Create a copy of LinkPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkPermissionsCopyWith<_LinkPermissions> get copyWith => __$LinkPermissionsCopyWithImpl<_LinkPermissions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkPermissions&&(identical(other.view, view) || other.view == view)&&(identical(other.download, download) || other.download == download)&&(identical(other.upload, upload) || other.upload == upload));
}


@override
int get hashCode {
    return Object.hash(runtimeType,view,download,upload);
}

@override
String toString() {
    return 'LinkPermissions(view: $view, download: $download, upload: $upload)';
}


}

/// @nodoc
abstract mixin class _$LinkPermissionsCopyWith<$Res> implements $LinkPermissionsCopyWith<$Res> {
  factory _$LinkPermissionsCopyWith(_LinkPermissions value, $Res Function(_LinkPermissions) _then) = __$LinkPermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool view, bool download, bool upload
});




}
/// @nodoc
class __$LinkPermissionsCopyWithImpl<$Res>
    implements _$LinkPermissionsCopyWith<$Res> {
  __$LinkPermissionsCopyWithImpl(this._self, this._then);

  final _LinkPermissions _self;
  final $Res Function(_LinkPermissions) _then;

/// Create a copy of LinkPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? view = null,Object? download = null,Object? upload = null,}) {
  return _then(_LinkPermissions(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as bool,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as bool,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ShareTarget {

 ShareTargetKind get kind; int get id; String get name; String? get username; ServerImage? get avatar; int? get memberCount;
/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<ShareTarget> get copyWith => _$ShareTargetCopyWithImpl<ShareTarget>(this as ShareTarget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShareTarget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareTarget&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatar, _this.avatar) || other.avatar == _this.avatar)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount));
}


@override
int get hashCode {
  final _this = this as ShareTarget;
  return Object.hash(runtimeType,_this.kind,_this.id,_this.name,_this.username,_this.avatar,_this.memberCount);
}

@override
String toString() {
  final _this = this as ShareTarget;
  return 'ShareTarget(kind: ${_this.kind}, id: ${_this.id}, name: ${_this.name}, username: ${_this.username}, avatar: ${_this.avatar}, memberCount: ${_this.memberCount})';
}


}

/// @nodoc
abstract mixin class $ShareTargetCopyWith<$Res>  {
  factory $ShareTargetCopyWith(ShareTarget value, $Res Function(ShareTarget) _then) = _$ShareTargetCopyWithImpl;
@useResult
$Res call({
 ShareTargetKind kind, int id, String name, String? username, ServerImage? avatar, int? memberCount
});


$ServerImageCopyWith<$Res>? get avatar;

}
/// @nodoc
class _$ShareTargetCopyWithImpl<$Res>
    implements $ShareTargetCopyWith<$Res> {
  _$ShareTargetCopyWithImpl(this._self, this._then);

  final ShareTarget _self;
  final $Res Function(ShareTarget) _then;

/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? id = null,Object? name = null,Object? username = freezed,Object? avatar = freezed,Object? memberCount = freezed,}) {
  return _then(ShareTarget(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ShareTargetKind,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ServerImage?,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get avatar {
    if (_self.avatar == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.avatar!, (value) {
    return _then(_self.copyWith(avatar: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShareTarget].
extension ShareTargetPatterns on ShareTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareTarget value)  $default,){
final _that = this;
switch (_that) {
case _ShareTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareTarget value)?  $default,){
final _that = this;
switch (_that) {
case _ShareTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShareTargetKind kind,  int id,  String name,  String? username,  ServerImage? avatar,  int? memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareTarget() when $default != null:
return $default(_that.kind,_that.id,_that.name,_that.username,_that.avatar,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShareTargetKind kind,  int id,  String name,  String? username,  ServerImage? avatar,  int? memberCount)  $default,) {final _that = this;
switch (_that) {
case _ShareTarget():
return $default(_that.kind,_that.id,_that.name,_that.username,_that.avatar,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShareTargetKind kind,  int id,  String name,  String? username,  ServerImage? avatar,  int? memberCount)?  $default,) {final _that = this;
switch (_that) {
case _ShareTarget() when $default != null:
return $default(_that.kind,_that.id,_that.name,_that.username,_that.avatar,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _ShareTarget extends ShareTarget {
  const _ShareTarget({required this.kind, required this.id, required this.name, this.username, this.avatar, this.memberCount}): super._();
  

@override final  ShareTargetKind kind;
@override final  int id;
@override final  String name;
@override final  String? username;
@override final  ServerImage? avatar;
@override final  int? memberCount;

/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareTargetCopyWith<_ShareTarget> get copyWith => __$ShareTargetCopyWithImpl<_ShareTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareTarget&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,id,name,username,avatar,memberCount);
}

@override
String toString() {
    return 'ShareTarget(kind: $kind, id: $id, name: $name, username: $username, avatar: $avatar, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$ShareTargetCopyWith<$Res> implements $ShareTargetCopyWith<$Res> {
  factory _$ShareTargetCopyWith(_ShareTarget value, $Res Function(_ShareTarget) _then) = __$ShareTargetCopyWithImpl;
@override @useResult
$Res call({
 ShareTargetKind kind, int id, String name, String? username, ServerImage? avatar, int? memberCount
});


@override $ServerImageCopyWith<$Res>? get avatar;

}
/// @nodoc
class __$ShareTargetCopyWithImpl<$Res>
    implements _$ShareTargetCopyWith<$Res> {
  __$ShareTargetCopyWithImpl(this._self, this._then);

  final _ShareTarget _self;
  final $Res Function(_ShareTarget) _then;

/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? id = null,Object? name = null,Object? username = freezed,Object? avatar = freezed,Object? memberCount = freezed,}) {
  return _then(_ShareTarget(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ShareTargetKind,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as ServerImage?,memberCount: freezed == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ShareTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerImageCopyWith<$Res>? get avatar {
    if (_self.avatar == null) {
    return null;
  }

  return $ServerImageCopyWith<$Res>(_self.avatar!, (value) {
    return _then(_self.copyWith(avatar: value));
  });
}
}

/// @nodoc
mixin _$SharedFile {

 int get id; String get name; bool get isDir;
/// Create a copy of SharedFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedFileCopyWith<SharedFile> get copyWith => _$SharedFileCopyWithImpl<SharedFile>(this as SharedFile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SharedFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedFile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isDir, _this.isDir) || other.isDir == _this.isDir));
}


@override
int get hashCode {
  final _this = this as SharedFile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.isDir);
}

@override
String toString() {
  final _this = this as SharedFile;
  return 'SharedFile(id: ${_this.id}, name: ${_this.name}, isDir: ${_this.isDir})';
}


}

/// @nodoc
abstract mixin class $SharedFileCopyWith<$Res>  {
  factory $SharedFileCopyWith(SharedFile value, $Res Function(SharedFile) _then) = _$SharedFileCopyWithImpl;
@useResult
$Res call({
 int id, String name, bool isDir
});




}
/// @nodoc
class _$SharedFileCopyWithImpl<$Res>
    implements $SharedFileCopyWith<$Res> {
  _$SharedFileCopyWithImpl(this._self, this._then);

  final SharedFile _self;
  final $Res Function(SharedFile) _then;

/// Create a copy of SharedFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isDir = null,}) {
  return _then(SharedFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedFile].
extension SharedFilePatterns on SharedFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedFile value)  $default,){
final _that = this;
switch (_that) {
case _SharedFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedFile value)?  $default,){
final _that = this;
switch (_that) {
case _SharedFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  bool isDir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedFile() when $default != null:
return $default(_that.id,_that.name,_that.isDir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  bool isDir)  $default,) {final _that = this;
switch (_that) {
case _SharedFile():
return $default(_that.id,_that.name,_that.isDir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  bool isDir)?  $default,) {final _that = this;
switch (_that) {
case _SharedFile() when $default != null:
return $default(_that.id,_that.name,_that.isDir);case _:
  return null;

}
}

}

/// @nodoc


class _SharedFile extends SharedFile {
  const _SharedFile({required this.id, this.name = "", this.isDir = false}): super._();
  

@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool isDir;

/// Create a copy of SharedFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedFileCopyWith<_SharedFile> get copyWith => __$SharedFileCopyWithImpl<_SharedFile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isDir, isDir) || other.isDir == isDir));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,isDir);
}

@override
String toString() {
    return 'SharedFile(id: $id, name: $name, isDir: $isDir)';
}


}

/// @nodoc
abstract mixin class _$SharedFileCopyWith<$Res> implements $SharedFileCopyWith<$Res> {
  factory _$SharedFileCopyWith(_SharedFile value, $Res Function(_SharedFile) _then) = __$SharedFileCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, bool isDir
});




}
/// @nodoc
class __$SharedFileCopyWithImpl<$Res>
    implements _$SharedFileCopyWith<$Res> {
  __$SharedFileCopyWithImpl(this._self, this._then);

  final _SharedFile _self;
  final $Res Function(_SharedFile) _then;

/// Create a copy of SharedFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isDir = null,}) {
  return _then(_SharedFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$OutgoingShare {

 int get id; SharedFile get file; ShareTarget get owner; ShareTarget get recipient; SharePermissions get permissions; DateTime? get expiresAt; String get note; bool get available; bool get canChange; bool get canRemove;
/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutgoingShareCopyWith<OutgoingShare> get copyWith => _$OutgoingShareCopyWithImpl<OutgoingShare>(this as OutgoingShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OutgoingShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutgoingShare&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.recipient, _this.recipient) || other.recipient == _this.recipient)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.canChange, _this.canChange) || other.canChange == _this.canChange)&&(identical(other.canRemove, _this.canRemove) || other.canRemove == _this.canRemove));
}


@override
int get hashCode {
  final _this = this as OutgoingShare;
  return Object.hash(runtimeType,_this.id,_this.file,_this.owner,_this.recipient,_this.permissions,_this.expiresAt,_this.note,_this.available,_this.canChange,_this.canRemove);
}

@override
String toString() {
  final _this = this as OutgoingShare;
  return 'OutgoingShare(id: ${_this.id}, file: ${_this.file}, owner: ${_this.owner}, recipient: ${_this.recipient}, permissions: ${_this.permissions}, expiresAt: ${_this.expiresAt}, note: ${_this.note}, available: ${_this.available}, canChange: ${_this.canChange}, canRemove: ${_this.canRemove})';
}


}

/// @nodoc
abstract mixin class $OutgoingShareCopyWith<$Res>  {
  factory $OutgoingShareCopyWith(OutgoingShare value, $Res Function(OutgoingShare) _then) = _$OutgoingShareCopyWithImpl;
@useResult
$Res call({
 int id, SharedFile file, ShareTarget owner, ShareTarget recipient, SharePermissions permissions, DateTime? expiresAt, String note, bool available, bool canChange, bool canRemove
});


$SharedFileCopyWith<$Res> get file;$ShareTargetCopyWith<$Res> get owner;$ShareTargetCopyWith<$Res> get recipient;$SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$OutgoingShareCopyWithImpl<$Res>
    implements $OutgoingShareCopyWith<$Res> {
  _$OutgoingShareCopyWithImpl(this._self, this._then);

  final OutgoingShare _self;
  final $Res Function(OutgoingShare) _then;

/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? file = null,Object? owner = null,Object? recipient = null,Object? permissions = null,Object? expiresAt = freezed,Object? note = null,Object? available = null,Object? canChange = null,Object? canRemove = null,}) {
  return _then(OutgoingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as ShareTarget,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,canChange: null == canChange ? _self.canChange : canChange // ignore: cast_nullable_to_non_nullable
as bool,canRemove: null == canRemove ? _self.canRemove : canRemove // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get owner {
  
  return $ShareTargetCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get recipient {
  
  return $ShareTargetCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [OutgoingShare].
extension OutgoingSharePatterns on OutgoingShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutgoingShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutgoingShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutgoingShare value)  $default,){
final _that = this;
switch (_that) {
case _OutgoingShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutgoingShare value)?  $default,){
final _that = this;
switch (_that) {
case _OutgoingShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  SharedFile file,  ShareTarget owner,  ShareTarget recipient,  SharePermissions permissions,  DateTime? expiresAt,  String note,  bool available,  bool canChange,  bool canRemove)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutgoingShare() when $default != null:
return $default(_that.id,_that.file,_that.owner,_that.recipient,_that.permissions,_that.expiresAt,_that.note,_that.available,_that.canChange,_that.canRemove);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  SharedFile file,  ShareTarget owner,  ShareTarget recipient,  SharePermissions permissions,  DateTime? expiresAt,  String note,  bool available,  bool canChange,  bool canRemove)  $default,) {final _that = this;
switch (_that) {
case _OutgoingShare():
return $default(_that.id,_that.file,_that.owner,_that.recipient,_that.permissions,_that.expiresAt,_that.note,_that.available,_that.canChange,_that.canRemove);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  SharedFile file,  ShareTarget owner,  ShareTarget recipient,  SharePermissions permissions,  DateTime? expiresAt,  String note,  bool available,  bool canChange,  bool canRemove)?  $default,) {final _that = this;
switch (_that) {
case _OutgoingShare() when $default != null:
return $default(_that.id,_that.file,_that.owner,_that.recipient,_that.permissions,_that.expiresAt,_that.note,_that.available,_that.canChange,_that.canRemove);case _:
  return null;

}
}

}

/// @nodoc


class _OutgoingShare extends OutgoingShare {
  const _OutgoingShare({required this.id, required this.file, required this.owner, required this.recipient, required this.permissions, this.expiresAt, this.note = "", this.available = true, this.canChange = false, this.canRemove = false}): super._();
  

@override final  int id;
@override final  SharedFile file;
@override final  ShareTarget owner;
@override final  ShareTarget recipient;
@override final  SharePermissions permissions;
@override final  DateTime? expiresAt;
@override@JsonKey() final  String note;
@override@JsonKey() final  bool available;
@override@JsonKey() final  bool canChange;
@override@JsonKey() final  bool canRemove;

/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutgoingShareCopyWith<_OutgoingShare> get copyWith => __$OutgoingShareCopyWithImpl<_OutgoingShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutgoingShare&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.available, available) || other.available == available)&&(identical(other.canChange, canChange) || other.canChange == canChange)&&(identical(other.canRemove, canRemove) || other.canRemove == canRemove));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,file,owner,recipient,permissions,expiresAt,note,available,canChange,canRemove);
}

@override
String toString() {
    return 'OutgoingShare(id: $id, file: $file, owner: $owner, recipient: $recipient, permissions: $permissions, expiresAt: $expiresAt, note: $note, available: $available, canChange: $canChange, canRemove: $canRemove)';
}


}

/// @nodoc
abstract mixin class _$OutgoingShareCopyWith<$Res> implements $OutgoingShareCopyWith<$Res> {
  factory _$OutgoingShareCopyWith(_OutgoingShare value, $Res Function(_OutgoingShare) _then) = __$OutgoingShareCopyWithImpl;
@override @useResult
$Res call({
 int id, SharedFile file, ShareTarget owner, ShareTarget recipient, SharePermissions permissions, DateTime? expiresAt, String note, bool available, bool canChange, bool canRemove
});


@override $SharedFileCopyWith<$Res> get file;@override $ShareTargetCopyWith<$Res> get owner;@override $ShareTargetCopyWith<$Res> get recipient;@override $SharePermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$OutgoingShareCopyWithImpl<$Res>
    implements _$OutgoingShareCopyWith<$Res> {
  __$OutgoingShareCopyWithImpl(this._self, this._then);

  final _OutgoingShare _self;
  final $Res Function(_OutgoingShare) _then;

/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? file = null,Object? owner = null,Object? recipient = null,Object? permissions = null,Object? expiresAt = freezed,Object? note = null,Object? available = null,Object? canChange = null,Object? canRemove = null,}) {
  return _then(_OutgoingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as ShareTarget,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,canChange: null == canChange ? _self.canChange : canChange // ignore: cast_nullable_to_non_nullable
as bool,canRemove: null == canRemove ? _self.canRemove : canRemove // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get owner {
  
  return $ShareTargetCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get recipient {
  
  return $ShareTargetCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of OutgoingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

/// @nodoc
mixin _$IncomingShare {

 int get id; ShareTarget get owner; bool get direct; List<ShareTarget> get groups; SharePermissions get permissions; DateTime? get expiresAt; String get note; FileEntry get entry;
/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomingShareCopyWith<IncomingShare> get copyWith => _$IncomingShareCopyWithImpl<IncomingShare>(this as IncomingShare, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IncomingShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomingShare&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.direct, _this.direct) || other.direct == _this.direct)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.entry, _this.entry) || other.entry == _this.entry));
}


@override
int get hashCode {
  final _this = this as IncomingShare;
  return Object.hash(runtimeType,_this.id,_this.owner,_this.direct,const DeepCollectionEquality().hash(_this.groups),_this.permissions,_this.expiresAt,_this.note,_this.entry);
}

@override
String toString() {
  final _this = this as IncomingShare;
  return 'IncomingShare(id: ${_this.id}, owner: ${_this.owner}, direct: ${_this.direct}, groups: ${_this.groups}, permissions: ${_this.permissions}, expiresAt: ${_this.expiresAt}, note: ${_this.note}, entry: ${_this.entry})';
}


}

/// @nodoc
abstract mixin class $IncomingShareCopyWith<$Res>  {
  factory $IncomingShareCopyWith(IncomingShare value, $Res Function(IncomingShare) _then) = _$IncomingShareCopyWithImpl;
@useResult
$Res call({
 int id, ShareTarget owner, bool direct, List<ShareTarget> groups, SharePermissions permissions, DateTime? expiresAt, String note, FileEntry entry
});


$ShareTargetCopyWith<$Res> get owner;$SharePermissionsCopyWith<$Res> get permissions;$FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$IncomingShareCopyWithImpl<$Res>
    implements $IncomingShareCopyWith<$Res> {
  _$IncomingShareCopyWithImpl(this._self, this._then);

  final IncomingShare _self;
  final $Res Function(IncomingShare) _then;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? owner = null,Object? direct = null,Object? groups = null,Object? permissions = null,Object? expiresAt = freezed,Object? note = null,Object? entry = null,}) {
  return _then(IncomingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget,direct: null == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}
/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get owner {
  
  return $ShareTargetCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get entry {
  
  return $FileEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [IncomingShare].
extension IncomingSharePatterns on IncomingShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncomingShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncomingShare value)  $default,){
final _that = this;
switch (_that) {
case _IncomingShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncomingShare value)?  $default,){
final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ShareTarget owner,  bool direct,  List<ShareTarget> groups,  SharePermissions permissions,  DateTime? expiresAt,  String note,  FileEntry entry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
return $default(_that.id,_that.owner,_that.direct,_that.groups,_that.permissions,_that.expiresAt,_that.note,_that.entry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ShareTarget owner,  bool direct,  List<ShareTarget> groups,  SharePermissions permissions,  DateTime? expiresAt,  String note,  FileEntry entry)  $default,) {final _that = this;
switch (_that) {
case _IncomingShare():
return $default(_that.id,_that.owner,_that.direct,_that.groups,_that.permissions,_that.expiresAt,_that.note,_that.entry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ShareTarget owner,  bool direct,  List<ShareTarget> groups,  SharePermissions permissions,  DateTime? expiresAt,  String note,  FileEntry entry)?  $default,) {final _that = this;
switch (_that) {
case _IncomingShare() when $default != null:
return $default(_that.id,_that.owner,_that.direct,_that.groups,_that.permissions,_that.expiresAt,_that.note,_that.entry);case _:
  return null;

}
}

}

/// @nodoc


class _IncomingShare implements IncomingShare {
  const _IncomingShare({required this.id, required this.owner, this.direct = false,  List<ShareTarget> groups = const <ShareTarget>[], required this.permissions, this.expiresAt, this.note = "", required this.entry}): _groups = groups;
  

@override final  int id;
@override final  ShareTarget owner;
@override@JsonKey() final  bool direct;
 final  List<ShareTarget> _groups;
@override@JsonKey() List<ShareTarget> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  SharePermissions permissions;
@override final  DateTime? expiresAt;
@override@JsonKey() final  String note;
@override final  FileEntry entry;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomingShareCopyWith<_IncomingShare> get copyWith => __$IncomingShareCopyWithImpl<_IncomingShare>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncomingShare&&(identical(other.id, id) || other.id == id)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.direct, direct) || other.direct == direct)&&const DeepCollectionEquality().equals(other.groups, _groups)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.entry, entry) || other.entry == entry));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,owner,direct,const DeepCollectionEquality().hash(_groups),permissions,expiresAt,note,entry);
}

@override
String toString() {
    return 'IncomingShare(id: $id, owner: $owner, direct: $direct, groups: $groups, permissions: $permissions, expiresAt: $expiresAt, note: $note, entry: $entry)';
}


}

/// @nodoc
abstract mixin class _$IncomingShareCopyWith<$Res> implements $IncomingShareCopyWith<$Res> {
  factory _$IncomingShareCopyWith(_IncomingShare value, $Res Function(_IncomingShare) _then) = __$IncomingShareCopyWithImpl;
@override @useResult
$Res call({
 int id, ShareTarget owner, bool direct, List<ShareTarget> groups, SharePermissions permissions, DateTime? expiresAt, String note, FileEntry entry
});


@override $ShareTargetCopyWith<$Res> get owner;@override $SharePermissionsCopyWith<$Res> get permissions;@override $FileEntryCopyWith<$Res> get entry;

}
/// @nodoc
class __$IncomingShareCopyWithImpl<$Res>
    implements _$IncomingShareCopyWith<$Res> {
  __$IncomingShareCopyWithImpl(this._self, this._then);

  final _IncomingShare _self;
  final $Res Function(_IncomingShare) _then;

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? owner = null,Object? direct = null,Object? groups = null,Object? permissions = null,Object? expiresAt = freezed,Object? note = null,Object? entry = null,}) {
  return _then(_IncomingShare(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget,direct: null == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as SharePermissions,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get owner {
  
  return $ShareTargetCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of IncomingShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharePermissionsCopyWith<$Res> get permissions {
  
  return $SharePermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of IncomingShare
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
mixin _$ShareLink {

 int get id; String get code; SharedFile get file; LinkPermissions get permissions; bool get hasPassword; DateTime? get expiresAt; bool get available;
/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareLinkCopyWith<ShareLink> get copyWith => _$ShareLinkCopyWithImpl<ShareLink>(this as ShareLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShareLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareLink&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.hasPassword, _this.hasPassword) || other.hasPassword == _this.hasPassword)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.available, _this.available) || other.available == _this.available));
}


@override
int get hashCode {
  final _this = this as ShareLink;
  return Object.hash(runtimeType,_this.id,_this.code,_this.file,_this.permissions,_this.hasPassword,_this.expiresAt,_this.available);
}

@override
String toString() {
  final _this = this as ShareLink;
  return 'ShareLink(id: ${_this.id}, code: ${_this.code}, file: ${_this.file}, permissions: ${_this.permissions}, hasPassword: ${_this.hasPassword}, expiresAt: ${_this.expiresAt}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $ShareLinkCopyWith<$Res>  {
  factory $ShareLinkCopyWith(ShareLink value, $Res Function(ShareLink) _then) = _$ShareLinkCopyWithImpl;
@useResult
$Res call({
 int id, String code, SharedFile file, LinkPermissions permissions, bool hasPassword, DateTime? expiresAt, bool available
});


$SharedFileCopyWith<$Res> get file;$LinkPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$ShareLinkCopyWithImpl<$Res>
    implements $ShareLinkCopyWith<$Res> {
  _$ShareLinkCopyWithImpl(this._self, this._then);

  final ShareLink _self;
  final $Res Function(ShareLink) _then;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? file = null,Object? permissions = null,Object? hasPassword = null,Object? expiresAt = freezed,Object? available = null,}) {
  return _then(ShareLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShareLink].
extension ShareLinkPatterns on ShareLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareLink value)  $default,){
final _that = this;
switch (_that) {
case _ShareLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareLink value)?  $default,){
final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  SharedFile file,  LinkPermissions permissions,  bool hasPassword,  DateTime? expiresAt,  bool available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
return $default(_that.id,_that.code,_that.file,_that.permissions,_that.hasPassword,_that.expiresAt,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  SharedFile file,  LinkPermissions permissions,  bool hasPassword,  DateTime? expiresAt,  bool available)  $default,) {final _that = this;
switch (_that) {
case _ShareLink():
return $default(_that.id,_that.code,_that.file,_that.permissions,_that.hasPassword,_that.expiresAt,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  SharedFile file,  LinkPermissions permissions,  bool hasPassword,  DateTime? expiresAt,  bool available)?  $default,) {final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
return $default(_that.id,_that.code,_that.file,_that.permissions,_that.hasPassword,_that.expiresAt,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _ShareLink extends ShareLink {
  const _ShareLink({required this.id, required this.code, required this.file, required this.permissions, this.hasPassword = false, this.expiresAt, this.available = true}): super._();
  

@override final  int id;
@override final  String code;
@override final  SharedFile file;
@override final  LinkPermissions permissions;
@override@JsonKey() final  bool hasPassword;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool available;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareLinkCopyWith<_ShareLink> get copyWith => __$ShareLinkCopyWithImpl<_ShareLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareLink&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.file, file) || other.file == file)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,code,file,permissions,hasPassword,expiresAt,available);
}

@override
String toString() {
    return 'ShareLink(id: $id, code: $code, file: $file, permissions: $permissions, hasPassword: $hasPassword, expiresAt: $expiresAt, available: $available)';
}


}

/// @nodoc
abstract mixin class _$ShareLinkCopyWith<$Res> implements $ShareLinkCopyWith<$Res> {
  factory _$ShareLinkCopyWith(_ShareLink value, $Res Function(_ShareLink) _then) = __$ShareLinkCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, SharedFile file, LinkPermissions permissions, bool hasPassword, DateTime? expiresAt, bool available
});


@override $SharedFileCopyWith<$Res> get file;@override $LinkPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$ShareLinkCopyWithImpl<$Res>
    implements _$ShareLinkCopyWith<$Res> {
  __$ShareLinkCopyWithImpl(this._self, this._then);

  final _ShareLink _self;
  final $Res Function(_ShareLink) _then;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? file = null,Object? permissions = null,Object? hasPassword = null,Object? expiresAt = freezed,Object? available = null,}) {
  return _then(_ShareLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SharedFile,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedFileCopyWith<$Res> get file {
  
  return $SharedFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

/// @nodoc
mixin _$PublicLinkInfo {

 bool get needsPassword; LinkPermissions get permissions; String? get name; ShareTarget? get owner;
/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicLinkInfoCopyWith<PublicLinkInfo> get copyWith => _$PublicLinkInfoCopyWithImpl<PublicLinkInfo>(this as PublicLinkInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PublicLinkInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicLinkInfo&&(identical(other.needsPassword, _this.needsPassword) || other.needsPassword == _this.needsPassword)&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.owner, _this.owner) || other.owner == _this.owner));
}


@override
int get hashCode {
  final _this = this as PublicLinkInfo;
  return Object.hash(runtimeType,_this.needsPassword,_this.permissions,_this.name,_this.owner);
}

@override
String toString() {
  final _this = this as PublicLinkInfo;
  return 'PublicLinkInfo(needsPassword: ${_this.needsPassword}, permissions: ${_this.permissions}, name: ${_this.name}, owner: ${_this.owner})';
}


}

/// @nodoc
abstract mixin class $PublicLinkInfoCopyWith<$Res>  {
  factory $PublicLinkInfoCopyWith(PublicLinkInfo value, $Res Function(PublicLinkInfo) _then) = _$PublicLinkInfoCopyWithImpl;
@useResult
$Res call({
 bool needsPassword, LinkPermissions permissions, String? name, ShareTarget? owner
});


$LinkPermissionsCopyWith<$Res> get permissions;$ShareTargetCopyWith<$Res>? get owner;

}
/// @nodoc
class _$PublicLinkInfoCopyWithImpl<$Res>
    implements $PublicLinkInfoCopyWith<$Res> {
  _$PublicLinkInfoCopyWithImpl(this._self, this._then);

  final PublicLinkInfo _self;
  final $Res Function(PublicLinkInfo) _then;

/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? needsPassword = null,Object? permissions = null,Object? name = freezed,Object? owner = freezed,}) {
  return _then(PublicLinkInfo(
needsPassword: null == needsPassword ? _self.needsPassword : needsPassword // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget?,
  ));
}
/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res>? get owner {
    if (_self.owner == null) {
    return null;
  }

  return $ShareTargetCopyWith<$Res>(_self.owner!, (value) {
    return _then(_self.copyWith(owner: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicLinkInfo].
extension PublicLinkInfoPatterns on PublicLinkInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicLinkInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicLinkInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicLinkInfo value)  $default,){
final _that = this;
switch (_that) {
case _PublicLinkInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicLinkInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PublicLinkInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool needsPassword,  LinkPermissions permissions,  String? name,  ShareTarget? owner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicLinkInfo() when $default != null:
return $default(_that.needsPassword,_that.permissions,_that.name,_that.owner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool needsPassword,  LinkPermissions permissions,  String? name,  ShareTarget? owner)  $default,) {final _that = this;
switch (_that) {
case _PublicLinkInfo():
return $default(_that.needsPassword,_that.permissions,_that.name,_that.owner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool needsPassword,  LinkPermissions permissions,  String? name,  ShareTarget? owner)?  $default,) {final _that = this;
switch (_that) {
case _PublicLinkInfo() when $default != null:
return $default(_that.needsPassword,_that.permissions,_that.name,_that.owner);case _:
  return null;

}
}

}

/// @nodoc


class _PublicLinkInfo implements PublicLinkInfo {
  const _PublicLinkInfo({required this.needsPassword, required this.permissions, this.name, this.owner});
  

@override final  bool needsPassword;
@override final  LinkPermissions permissions;
@override final  String? name;
@override final  ShareTarget? owner;

/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicLinkInfoCopyWith<_PublicLinkInfo> get copyWith => __$PublicLinkInfoCopyWithImpl<_PublicLinkInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicLinkInfo&&(identical(other.needsPassword, needsPassword) || other.needsPassword == needsPassword)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.name, name) || other.name == name)&&(identical(other.owner, owner) || other.owner == owner));
}


@override
int get hashCode {
    return Object.hash(runtimeType,needsPassword,permissions,name,owner);
}

@override
String toString() {
    return 'PublicLinkInfo(needsPassword: $needsPassword, permissions: $permissions, name: $name, owner: $owner)';
}


}

/// @nodoc
abstract mixin class _$PublicLinkInfoCopyWith<$Res> implements $PublicLinkInfoCopyWith<$Res> {
  factory _$PublicLinkInfoCopyWith(_PublicLinkInfo value, $Res Function(_PublicLinkInfo) _then) = __$PublicLinkInfoCopyWithImpl;
@override @useResult
$Res call({
 bool needsPassword, LinkPermissions permissions, String? name, ShareTarget? owner
});


@override $LinkPermissionsCopyWith<$Res> get permissions;@override $ShareTargetCopyWith<$Res>? get owner;

}
/// @nodoc
class __$PublicLinkInfoCopyWithImpl<$Res>
    implements _$PublicLinkInfoCopyWith<$Res> {
  __$PublicLinkInfoCopyWithImpl(this._self, this._then);

  final _PublicLinkInfo _self;
  final $Res Function(_PublicLinkInfo) _then;

/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? needsPassword = null,Object? permissions = null,Object? name = freezed,Object? owner = freezed,}) {
  return _then(_PublicLinkInfo(
needsPassword: null == needsPassword ? _self.needsPassword : needsPassword // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as ShareTarget?,
  ));
}

/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}/// Create a copy of PublicLinkInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res>? get owner {
    if (_self.owner == null) {
    return null;
  }

  return $ShareTargetCopyWith<$Res>(_self.owner!, (value) {
    return _then(_self.copyWith(owner: value));
  });
}
}

/// @nodoc
mixin _$PublicLinkUnlock {

 String get token; DateTime get expiresAt; PublicLinkInfo get info; FileEntry get root;
/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicLinkUnlockCopyWith<PublicLinkUnlock> get copyWith => _$PublicLinkUnlockCopyWithImpl<PublicLinkUnlock>(this as PublicLinkUnlock, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PublicLinkUnlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicLinkUnlock&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.info, _this.info) || other.info == _this.info)&&(identical(other.root, _this.root) || other.root == _this.root));
}


@override
int get hashCode {
  final _this = this as PublicLinkUnlock;
  return Object.hash(runtimeType,_this.token,_this.expiresAt,_this.info,_this.root);
}

@override
String toString() {
  final _this = this as PublicLinkUnlock;
  return 'PublicLinkUnlock(token: ${_this.token}, expiresAt: ${_this.expiresAt}, info: ${_this.info}, root: ${_this.root})';
}


}

/// @nodoc
abstract mixin class $PublicLinkUnlockCopyWith<$Res>  {
  factory $PublicLinkUnlockCopyWith(PublicLinkUnlock value, $Res Function(PublicLinkUnlock) _then) = _$PublicLinkUnlockCopyWithImpl;
@useResult
$Res call({
 String token, DateTime expiresAt, PublicLinkInfo info, FileEntry root
});


$PublicLinkInfoCopyWith<$Res> get info;$FileEntryCopyWith<$Res> get root;

}
/// @nodoc
class _$PublicLinkUnlockCopyWithImpl<$Res>
    implements $PublicLinkUnlockCopyWith<$Res> {
  _$PublicLinkUnlockCopyWithImpl(this._self, this._then);

  final PublicLinkUnlock _self;
  final $Res Function(PublicLinkUnlock) _then;

/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? expiresAt = null,Object? info = null,Object? root = null,}) {
  return _then(PublicLinkUnlock(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as PublicLinkInfo,root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}
/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicLinkInfoCopyWith<$Res> get info {
  
  return $PublicLinkInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get root {
  
  return $FileEntryCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicLinkUnlock].
extension PublicLinkUnlockPatterns on PublicLinkUnlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicLinkUnlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicLinkUnlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicLinkUnlock value)  $default,){
final _that = this;
switch (_that) {
case _PublicLinkUnlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicLinkUnlock value)?  $default,){
final _that = this;
switch (_that) {
case _PublicLinkUnlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt,  PublicLinkInfo info,  FileEntry root)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicLinkUnlock() when $default != null:
return $default(_that.token,_that.expiresAt,_that.info,_that.root);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt,  PublicLinkInfo info,  FileEntry root)  $default,) {final _that = this;
switch (_that) {
case _PublicLinkUnlock():
return $default(_that.token,_that.expiresAt,_that.info,_that.root);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  DateTime expiresAt,  PublicLinkInfo info,  FileEntry root)?  $default,) {final _that = this;
switch (_that) {
case _PublicLinkUnlock() when $default != null:
return $default(_that.token,_that.expiresAt,_that.info,_that.root);case _:
  return null;

}
}

}

/// @nodoc


class _PublicLinkUnlock implements PublicLinkUnlock {
  const _PublicLinkUnlock({required this.token, required this.expiresAt, required this.info, required this.root});
  

@override final  String token;
@override final  DateTime expiresAt;
@override final  PublicLinkInfo info;
@override final  FileEntry root;

/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicLinkUnlockCopyWith<_PublicLinkUnlock> get copyWith => __$PublicLinkUnlockCopyWithImpl<_PublicLinkUnlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicLinkUnlock&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.info, info) || other.info == info)&&(identical(other.root, root) || other.root == root));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,expiresAt,info,root);
}

@override
String toString() {
    return 'PublicLinkUnlock(token: $token, expiresAt: $expiresAt, info: $info, root: $root)';
}


}

/// @nodoc
abstract mixin class _$PublicLinkUnlockCopyWith<$Res> implements $PublicLinkUnlockCopyWith<$Res> {
  factory _$PublicLinkUnlockCopyWith(_PublicLinkUnlock value, $Res Function(_PublicLinkUnlock) _then) = __$PublicLinkUnlockCopyWithImpl;
@override @useResult
$Res call({
 String token, DateTime expiresAt, PublicLinkInfo info, FileEntry root
});


@override $PublicLinkInfoCopyWith<$Res> get info;@override $FileEntryCopyWith<$Res> get root;

}
/// @nodoc
class __$PublicLinkUnlockCopyWithImpl<$Res>
    implements _$PublicLinkUnlockCopyWith<$Res> {
  __$PublicLinkUnlockCopyWithImpl(this._self, this._then);

  final _PublicLinkUnlock _self;
  final $Res Function(_PublicLinkUnlock) _then;

/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? expiresAt = null,Object? info = null,Object? root = null,}) {
  return _then(_PublicLinkUnlock(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as PublicLinkInfo,root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicLinkInfoCopyWith<$Res> get info {
  
  return $PublicLinkInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}/// Create a copy of PublicLinkUnlock
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get root {
  
  return $FileEntryCopyWith<$Res>(_self.root, (value) {
    return _then(_self.copyWith(root: value));
  });
}
}

/// @nodoc
mixin _$LinkMatch {

 String? get ownPath; int? get shareId; String? get path;
/// Create a copy of LinkMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkMatchCopyWith<LinkMatch> get copyWith => _$LinkMatchCopyWithImpl<LinkMatch>(this as LinkMatch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LinkMatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkMatch&&(identical(other.ownPath, _this.ownPath) || other.ownPath == _this.ownPath)&&(identical(other.shareId, _this.shareId) || other.shareId == _this.shareId)&&(identical(other.path, _this.path) || other.path == _this.path));
}


@override
int get hashCode {
  final _this = this as LinkMatch;
  return Object.hash(runtimeType,_this.ownPath,_this.shareId,_this.path);
}

@override
String toString() {
  final _this = this as LinkMatch;
  return 'LinkMatch(ownPath: ${_this.ownPath}, shareId: ${_this.shareId}, path: ${_this.path})';
}


}

/// @nodoc
abstract mixin class $LinkMatchCopyWith<$Res>  {
  factory $LinkMatchCopyWith(LinkMatch value, $Res Function(LinkMatch) _then) = _$LinkMatchCopyWithImpl;
@useResult
$Res call({
 String? ownPath, int? shareId, String? path
});




}
/// @nodoc
class _$LinkMatchCopyWithImpl<$Res>
    implements $LinkMatchCopyWith<$Res> {
  _$LinkMatchCopyWithImpl(this._self, this._then);

  final LinkMatch _self;
  final $Res Function(LinkMatch) _then;

/// Create a copy of LinkMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownPath = freezed,Object? shareId = freezed,Object? path = freezed,}) {
  return _then(LinkMatch(
ownPath: freezed == ownPath ? _self.ownPath : ownPath // ignore: cast_nullable_to_non_nullable
as String?,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkMatch].
extension LinkMatchPatterns on LinkMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkMatch value)  $default,){
final _that = this;
switch (_that) {
case _LinkMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkMatch value)?  $default,){
final _that = this;
switch (_that) {
case _LinkMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? ownPath,  int? shareId,  String? path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkMatch() when $default != null:
return $default(_that.ownPath,_that.shareId,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? ownPath,  int? shareId,  String? path)  $default,) {final _that = this;
switch (_that) {
case _LinkMatch():
return $default(_that.ownPath,_that.shareId,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? ownPath,  int? shareId,  String? path)?  $default,) {final _that = this;
switch (_that) {
case _LinkMatch() when $default != null:
return $default(_that.ownPath,_that.shareId,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _LinkMatch implements LinkMatch {
  const _LinkMatch({this.ownPath, this.shareId, this.path});
  

@override final  String? ownPath;
@override final  int? shareId;
@override final  String? path;

/// Create a copy of LinkMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkMatchCopyWith<_LinkMatch> get copyWith => __$LinkMatchCopyWithImpl<_LinkMatch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkMatch&&(identical(other.ownPath, ownPath) || other.ownPath == ownPath)&&(identical(other.shareId, shareId) || other.shareId == shareId)&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ownPath,shareId,path);
}

@override
String toString() {
    return 'LinkMatch(ownPath: $ownPath, shareId: $shareId, path: $path)';
}


}

/// @nodoc
abstract mixin class _$LinkMatchCopyWith<$Res> implements $LinkMatchCopyWith<$Res> {
  factory _$LinkMatchCopyWith(_LinkMatch value, $Res Function(_LinkMatch) _then) = __$LinkMatchCopyWithImpl;
@override @useResult
$Res call({
 String? ownPath, int? shareId, String? path
});




}
/// @nodoc
class __$LinkMatchCopyWithImpl<$Res>
    implements _$LinkMatchCopyWith<$Res> {
  __$LinkMatchCopyWithImpl(this._self, this._then);

  final _LinkMatch _self;
  final $Res Function(_LinkMatch) _then;

/// Create a copy of LinkMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownPath = freezed,Object? shareId = freezed,Object? path = freezed,}) {
  return _then(_LinkMatch(
ownPath: freezed == ownPath ? _self.ownPath : ownPath // ignore: cast_nullable_to_non_nullable
as String?,shareId: freezed == shareId ? _self.shareId : shareId // ignore: cast_nullable_to_non_nullable
as int?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ShareTargets {

 List<ShareTarget> get users; List<ShareTarget> get groups;
/// Create a copy of ShareTargets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareTargetsCopyWith<ShareTargets> get copyWith => _$ShareTargetsCopyWithImpl<ShareTargets>(this as ShareTargets, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShareTargets;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareTargets&&const DeepCollectionEquality().equals(other.users, _this.users)&&const DeepCollectionEquality().equals(other.groups, _this.groups));
}


@override
int get hashCode {
  final _this = this as ShareTargets;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.users),const DeepCollectionEquality().hash(_this.groups));
}

@override
String toString() {
  final _this = this as ShareTargets;
  return 'ShareTargets(users: ${_this.users}, groups: ${_this.groups})';
}


}

/// @nodoc
abstract mixin class $ShareTargetsCopyWith<$Res>  {
  factory $ShareTargetsCopyWith(ShareTargets value, $Res Function(ShareTargets) _then) = _$ShareTargetsCopyWithImpl;
@useResult
$Res call({
 List<ShareTarget> users, List<ShareTarget> groups
});




}
/// @nodoc
class _$ShareTargetsCopyWithImpl<$Res>
    implements $ShareTargetsCopyWith<$Res> {
  _$ShareTargetsCopyWithImpl(this._self, this._then);

  final ShareTargets _self;
  final $Res Function(ShareTargets) _then;

/// Create a copy of ShareTargets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? users = null,Object? groups = null,}) {
  return _then(ShareTargets(
users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareTargets].
extension ShareTargetsPatterns on ShareTargets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareTargets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareTargets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareTargets value)  $default,){
final _that = this;
switch (_that) {
case _ShareTargets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareTargets value)?  $default,){
final _that = this;
switch (_that) {
case _ShareTargets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ShareTarget> users,  List<ShareTarget> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareTargets() when $default != null:
return $default(_that.users,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ShareTarget> users,  List<ShareTarget> groups)  $default,) {final _that = this;
switch (_that) {
case _ShareTargets():
return $default(_that.users,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ShareTarget> users,  List<ShareTarget> groups)?  $default,) {final _that = this;
switch (_that) {
case _ShareTargets() when $default != null:
return $default(_that.users,_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _ShareTargets implements ShareTargets {
  const _ShareTargets({ List<ShareTarget> users = const <ShareTarget>[],  List<ShareTarget> groups = const <ShareTarget>[]}): _users = users,_groups = groups;
  

 final  List<ShareTarget> _users;
@override@JsonKey() List<ShareTarget> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

 final  List<ShareTarget> _groups;
@override@JsonKey() List<ShareTarget> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of ShareTargets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareTargetsCopyWith<_ShareTargets> get copyWith => __$ShareTargetsCopyWithImpl<_ShareTargets>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareTargets&&const DeepCollectionEquality().equals(other.users, _users)&&const DeepCollectionEquality().equals(other.groups, _groups));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_users),const DeepCollectionEquality().hash(_groups));
}

@override
String toString() {
    return 'ShareTargets(users: $users, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$ShareTargetsCopyWith<$Res> implements $ShareTargetsCopyWith<$Res> {
  factory _$ShareTargetsCopyWith(_ShareTargets value, $Res Function(_ShareTargets) _then) = __$ShareTargetsCopyWithImpl;
@override @useResult
$Res call({
 List<ShareTarget> users, List<ShareTarget> groups
});




}
/// @nodoc
class __$ShareTargetsCopyWithImpl<$Res>
    implements _$ShareTargetsCopyWith<$Res> {
  __$ShareTargetsCopyWithImpl(this._self, this._then);

  final _ShareTargets _self;
  final $Res Function(_ShareTargets) _then;

/// Create a copy of ShareTargets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? users = null,Object? groups = null,}) {
  return _then(_ShareTargets(
users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ShareTarget>,
  ));
}


}

/// @nodoc
mixin _$LinkOptions {

 LinkPermissions get permissions; String? get password; bool get removePassword; DateTime? get expiresAt; bool get removeExpiry;
/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkOptionsCopyWith<LinkOptions> get copyWith => _$LinkOptionsCopyWithImpl<LinkOptions>(this as LinkOptions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LinkOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkOptions&&(identical(other.permissions, _this.permissions) || other.permissions == _this.permissions)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.removePassword, _this.removePassword) || other.removePassword == _this.removePassword)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.removeExpiry, _this.removeExpiry) || other.removeExpiry == _this.removeExpiry));
}


@override
int get hashCode {
  final _this = this as LinkOptions;
  return Object.hash(runtimeType,_this.permissions,_this.password,_this.removePassword,_this.expiresAt,_this.removeExpiry);
}

@override
String toString() {
  final _this = this as LinkOptions;
  return 'LinkOptions(permissions: ${_this.permissions}, password: ${_this.password}, removePassword: ${_this.removePassword}, expiresAt: ${_this.expiresAt}, removeExpiry: ${_this.removeExpiry})';
}


}

/// @nodoc
abstract mixin class $LinkOptionsCopyWith<$Res>  {
  factory $LinkOptionsCopyWith(LinkOptions value, $Res Function(LinkOptions) _then) = _$LinkOptionsCopyWithImpl;
@useResult
$Res call({
 LinkPermissions permissions, String? password, bool removePassword, DateTime? expiresAt, bool removeExpiry
});


$LinkPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$LinkOptionsCopyWithImpl<$Res>
    implements $LinkOptionsCopyWith<$Res> {
  _$LinkOptionsCopyWithImpl(this._self, this._then);

  final LinkOptions _self;
  final $Res Function(LinkOptions) _then;

/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? permissions = null,Object? password = freezed,Object? removePassword = null,Object? expiresAt = freezed,Object? removeExpiry = null,}) {
  return _then(LinkOptions(
permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,removePassword: null == removePassword ? _self.removePassword : removePassword // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,removeExpiry: null == removeExpiry ? _self.removeExpiry : removeExpiry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [LinkOptions].
extension LinkOptionsPatterns on LinkOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkOptions value)  $default,){
final _that = this;
switch (_that) {
case _LinkOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkOptions value)?  $default,){
final _that = this;
switch (_that) {
case _LinkOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LinkPermissions permissions,  String? password,  bool removePassword,  DateTime? expiresAt,  bool removeExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkOptions() when $default != null:
return $default(_that.permissions,_that.password,_that.removePassword,_that.expiresAt,_that.removeExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LinkPermissions permissions,  String? password,  bool removePassword,  DateTime? expiresAt,  bool removeExpiry)  $default,) {final _that = this;
switch (_that) {
case _LinkOptions():
return $default(_that.permissions,_that.password,_that.removePassword,_that.expiresAt,_that.removeExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LinkPermissions permissions,  String? password,  bool removePassword,  DateTime? expiresAt,  bool removeExpiry)?  $default,) {final _that = this;
switch (_that) {
case _LinkOptions() when $default != null:
return $default(_that.permissions,_that.password,_that.removePassword,_that.expiresAt,_that.removeExpiry);case _:
  return null;

}
}

}

/// @nodoc


class _LinkOptions implements LinkOptions {
  const _LinkOptions({this.permissions = const LinkPermissions(), this.password, this.removePassword = false, this.expiresAt, this.removeExpiry = false});
  

@override@JsonKey() final  LinkPermissions permissions;
@override final  String? password;
@override@JsonKey() final  bool removePassword;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool removeExpiry;

/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkOptionsCopyWith<_LinkOptions> get copyWith => __$LinkOptionsCopyWithImpl<_LinkOptions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkOptions&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.password, password) || other.password == password)&&(identical(other.removePassword, removePassword) || other.removePassword == removePassword)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.removeExpiry, removeExpiry) || other.removeExpiry == removeExpiry));
}


@override
int get hashCode {
    return Object.hash(runtimeType,permissions,password,removePassword,expiresAt,removeExpiry);
}

@override
String toString() {
    return 'LinkOptions(permissions: $permissions, password: $password, removePassword: $removePassword, expiresAt: $expiresAt, removeExpiry: $removeExpiry)';
}


}

/// @nodoc
abstract mixin class _$LinkOptionsCopyWith<$Res> implements $LinkOptionsCopyWith<$Res> {
  factory _$LinkOptionsCopyWith(_LinkOptions value, $Res Function(_LinkOptions) _then) = __$LinkOptionsCopyWithImpl;
@override @useResult
$Res call({
 LinkPermissions permissions, String? password, bool removePassword, DateTime? expiresAt, bool removeExpiry
});


@override $LinkPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$LinkOptionsCopyWithImpl<$Res>
    implements _$LinkOptionsCopyWith<$Res> {
  __$LinkOptionsCopyWithImpl(this._self, this._then);

  final _LinkOptions _self;
  final $Res Function(_LinkOptions) _then;

/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? permissions = null,Object? password = freezed,Object? removePassword = null,Object? expiresAt = freezed,Object? removeExpiry = null,}) {
  return _then(_LinkOptions(
permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as LinkPermissions,password: freezed == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String?,removePassword: null == removePassword ? _self.removePassword : removePassword // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,removeExpiry: null == removeExpiry ? _self.removeExpiry : removeExpiry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LinkOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPermissionsCopyWith<$Res> get permissions {
  
  return $LinkPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

// dart format on
