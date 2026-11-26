// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Group {

 int get id; String get name; int get memberCount; ShareTarget? get createdBy; GroupRole? get myRole;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Group;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.myRole, _this.myRole) || other.myRole == _this.myRole));
}


@override
int get hashCode {
  final _this = this as Group;
  return Object.hash(runtimeType,_this.id,_this.name,_this.memberCount,_this.createdBy,_this.myRole);
}

@override
String toString() {
  final _this = this as Group;
  return 'Group(id: ${_this.id}, name: ${_this.name}, memberCount: ${_this.memberCount}, createdBy: ${_this.createdBy}, myRole: ${_this.myRole})';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 int id, String name, int memberCount, ShareTarget? createdBy, GroupRole? myRole
});


$ShareTargetCopyWith<$Res>? get createdBy;

}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? memberCount = null,Object? createdBy = freezed,Object? myRole = freezed,}) {
  return _then(Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as ShareTarget?,myRole: freezed == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as GroupRole?,
  ));
}
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $ShareTargetCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int memberCount,  ShareTarget? createdBy,  GroupRole? myRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.memberCount,_that.createdBy,_that.myRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int memberCount,  ShareTarget? createdBy,  GroupRole? myRole)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.id,_that.name,_that.memberCount,_that.createdBy,_that.myRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int memberCount,  ShareTarget? createdBy,  GroupRole? myRole)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.memberCount,_that.createdBy,_that.myRole);case _:
  return null;

}
}

}

/// @nodoc


class _Group implements Group {
  const _Group({required this.id, required this.name, this.memberCount = 0, this.createdBy, this.myRole});
  

@override final  int id;
@override final  String name;
@override@JsonKey() final  int memberCount;
@override final  ShareTarget? createdBy;
@override final  GroupRole? myRole;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.myRole, myRole) || other.myRole == myRole));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,memberCount,createdBy,myRole);
}

@override
String toString() {
    return 'Group(id: $id, name: $name, memberCount: $memberCount, createdBy: $createdBy, myRole: $myRole)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int memberCount, ShareTarget? createdBy, GroupRole? myRole
});


@override $ShareTargetCopyWith<$Res>? get createdBy;

}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? memberCount = null,Object? createdBy = freezed,Object? myRole = freezed,}) {
  return _then(_Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as ShareTarget?,myRole: freezed == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as GroupRole?,
  ));
}

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res>? get createdBy {
    if (_self.createdBy == null) {
    return null;
  }

  return $ShareTargetCopyWith<$Res>(_self.createdBy!, (value) {
    return _then(_self.copyWith(createdBy: value));
  });
}
}

/// @nodoc
mixin _$GroupMember {

 ShareTarget get user; GroupRole get role;
/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMemberCopyWith<GroupMember> get copyWith => _$GroupMemberCopyWithImpl<GroupMember>(this as GroupMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroupMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMember&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.role, _this.role) || other.role == _this.role));
}


@override
int get hashCode {
  final _this = this as GroupMember;
  return Object.hash(runtimeType,_this.user,_this.role);
}

@override
String toString() {
  final _this = this as GroupMember;
  return 'GroupMember(user: ${_this.user}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $GroupMemberCopyWith<$Res>  {
  factory $GroupMemberCopyWith(GroupMember value, $Res Function(GroupMember) _then) = _$GroupMemberCopyWithImpl;
@useResult
$Res call({
 ShareTarget user, GroupRole role
});


$ShareTargetCopyWith<$Res> get user;

}
/// @nodoc
class _$GroupMemberCopyWithImpl<$Res>
    implements $GroupMemberCopyWith<$Res> {
  _$GroupMemberCopyWithImpl(this._self, this._then);

  final GroupMember _self;
  final $Res Function(GroupMember) _then;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? role = null,}) {
  return _then(GroupMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ShareTarget,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as GroupRole,
  ));
}
/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get user {
  
  return $ShareTargetCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupMember].
extension GroupMemberPatterns on GroupMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMember value)  $default,){
final _that = this;
switch (_that) {
case _GroupMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMember value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShareTarget user,  GroupRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShareTarget user,  GroupRole role)  $default,) {final _that = this;
switch (_that) {
case _GroupMember():
return $default(_that.user,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShareTarget user,  GroupRole role)?  $default,) {final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
return $default(_that.user,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMember implements GroupMember {
  const _GroupMember({required this.user, required this.role});
  

@override final  ShareTarget user;
@override final  GroupRole role;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMemberCopyWith<_GroupMember> get copyWith => __$GroupMemberCopyWithImpl<_GroupMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMember&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,role);
}

@override
String toString() {
    return 'GroupMember(user: $user, role: $role)';
}


}

/// @nodoc
abstract mixin class _$GroupMemberCopyWith<$Res> implements $GroupMemberCopyWith<$Res> {
  factory _$GroupMemberCopyWith(_GroupMember value, $Res Function(_GroupMember) _then) = __$GroupMemberCopyWithImpl;
@override @useResult
$Res call({
 ShareTarget user, GroupRole role
});


@override $ShareTargetCopyWith<$Res> get user;

}
/// @nodoc
class __$GroupMemberCopyWithImpl<$Res>
    implements _$GroupMemberCopyWith<$Res> {
  __$GroupMemberCopyWithImpl(this._self, this._then);

  final _GroupMember _self;
  final $Res Function(_GroupMember) _then;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? role = null,}) {
  return _then(_GroupMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ShareTarget,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as GroupRole,
  ));
}

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShareTargetCopyWith<$Res> get user {
  
  return $ShareTargetCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc
mixin _$GroupDetails {

 Group get group; List<GroupMember> get members; bool get canManage;
/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupDetailsCopyWith<GroupDetails> get copyWith => _$GroupDetailsCopyWithImpl<GroupDetails>(this as GroupDetails, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroupDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupDetails&&(identical(other.group, _this.group) || other.group == _this.group)&&const DeepCollectionEquality().equals(other.members, _this.members)&&(identical(other.canManage, _this.canManage) || other.canManage == _this.canManage));
}


@override
int get hashCode {
  final _this = this as GroupDetails;
  return Object.hash(runtimeType,_this.group,const DeepCollectionEquality().hash(_this.members),_this.canManage);
}

@override
String toString() {
  final _this = this as GroupDetails;
  return 'GroupDetails(group: ${_this.group}, members: ${_this.members}, canManage: ${_this.canManage})';
}


}

/// @nodoc
abstract mixin class $GroupDetailsCopyWith<$Res>  {
  factory $GroupDetailsCopyWith(GroupDetails value, $Res Function(GroupDetails) _then) = _$GroupDetailsCopyWithImpl;
@useResult
$Res call({
 Group group, List<GroupMember> members, bool canManage
});


$GroupCopyWith<$Res> get group;

}
/// @nodoc
class _$GroupDetailsCopyWithImpl<$Res>
    implements $GroupDetailsCopyWith<$Res> {
  _$GroupDetailsCopyWithImpl(this._self, this._then);

  final GroupDetails _self;
  final $Res Function(GroupDetails) _then;

/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? members = null,Object? canManage = null,}) {
  return _then(GroupDetails(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<GroupMember>,canManage: null == canManage ? _self.canManage : canManage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res> get group {
  
  return $GroupCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupDetails].
extension GroupDetailsPatterns on GroupDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupDetails value)  $default,){
final _that = this;
switch (_that) {
case _GroupDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupDetails value)?  $default,){
final _that = this;
switch (_that) {
case _GroupDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Group group,  List<GroupMember> members,  bool canManage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupDetails() when $default != null:
return $default(_that.group,_that.members,_that.canManage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Group group,  List<GroupMember> members,  bool canManage)  $default,) {final _that = this;
switch (_that) {
case _GroupDetails():
return $default(_that.group,_that.members,_that.canManage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Group group,  List<GroupMember> members,  bool canManage)?  $default,) {final _that = this;
switch (_that) {
case _GroupDetails() when $default != null:
return $default(_that.group,_that.members,_that.canManage);case _:
  return null;

}
}

}

/// @nodoc


class _GroupDetails extends GroupDetails {
  const _GroupDetails({required this.group,  List<GroupMember> members = const <GroupMember>[], this.canManage = false}): _members = members,super._();
  

@override final  Group group;
 final  List<GroupMember> _members;
@override@JsonKey() List<GroupMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  bool canManage;

/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupDetailsCopyWith<_GroupDetails> get copyWith => __$GroupDetailsCopyWithImpl<_GroupDetails>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupDetails&&(identical(other.group, group) || other.group == group)&&const DeepCollectionEquality().equals(other.members, _members)&&(identical(other.canManage, canManage) || other.canManage == canManage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,group,const DeepCollectionEquality().hash(_members),canManage);
}

@override
String toString() {
    return 'GroupDetails(group: $group, members: $members, canManage: $canManage)';
}


}

/// @nodoc
abstract mixin class _$GroupDetailsCopyWith<$Res> implements $GroupDetailsCopyWith<$Res> {
  factory _$GroupDetailsCopyWith(_GroupDetails value, $Res Function(_GroupDetails) _then) = __$GroupDetailsCopyWithImpl;
@override @useResult
$Res call({
 Group group, List<GroupMember> members, bool canManage
});


@override $GroupCopyWith<$Res> get group;

}
/// @nodoc
class __$GroupDetailsCopyWithImpl<$Res>
    implements _$GroupDetailsCopyWith<$Res> {
  __$GroupDetailsCopyWithImpl(this._self, this._then);

  final _GroupDetails _self;
  final $Res Function(_GroupDetails) _then;

/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? members = null,Object? canManage = null,}) {
  return _then(_GroupDetails(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<GroupMember>,canManage: null == canManage ? _self.canManage : canManage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of GroupDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res> get group {
  
  return $GroupCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}

// dart format on
