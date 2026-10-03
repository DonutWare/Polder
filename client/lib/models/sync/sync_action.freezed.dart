// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncAction {

 String get path;
/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncActionCopyWith<SyncAction> get copyWith => _$SyncActionCopyWithImpl<SyncAction>(this as SyncAction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncAction&&(identical(other.path, _this.path) || other.path == _this.path));
}


@override
int get hashCode {
  final _this = this as SyncAction;
  return Object.hash(runtimeType,_this.path);
}

@override
String toString() {
  final _this = this as SyncAction;
  return 'SyncAction(path: ${_this.path})';
}


}

/// @nodoc
abstract mixin class $SyncActionCopyWith<$Res>  {
  factory $SyncActionCopyWith(SyncAction value, $Res Function(SyncAction) _then) = _$SyncActionCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$SyncActionCopyWithImpl<$Res>
    implements $SyncActionCopyWith<$Res> {
  _$SyncActionCopyWithImpl(this._self, this._then);

  final SyncAction _self;
  final $Res Function(SyncAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncAction].
extension SyncActionPatterns on SyncAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateRemoteDirAction value)?  createRemoteDir,TResult Function( CreateLocalDirAction value)?  createLocalDir,TResult Function( UploadAction value)?  upload,TResult Function( DownloadAction value)?  download,TResult Function( DeleteLocalAction value)?  deleteLocal,TResult Function( DeleteRemoteAction value)?  deleteRemote,TResult Function( RecordSyncedAction value)?  recordSynced,TResult Function( UpdatePlaceholderAction value)?  updatePlaceholder,TResult Function( ForgetAction value)?  forget,TResult Function( ConflictAction value)?  conflict,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateRemoteDirAction() when createRemoteDir != null:
return createRemoteDir(_that);case CreateLocalDirAction() when createLocalDir != null:
return createLocalDir(_that);case UploadAction() when upload != null:
return upload(_that);case DownloadAction() when download != null:
return download(_that);case DeleteLocalAction() when deleteLocal != null:
return deleteLocal(_that);case DeleteRemoteAction() when deleteRemote != null:
return deleteRemote(_that);case RecordSyncedAction() when recordSynced != null:
return recordSynced(_that);case UpdatePlaceholderAction() when updatePlaceholder != null:
return updatePlaceholder(_that);case ForgetAction() when forget != null:
return forget(_that);case ConflictAction() when conflict != null:
return conflict(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateRemoteDirAction value)  createRemoteDir,required TResult Function( CreateLocalDirAction value)  createLocalDir,required TResult Function( UploadAction value)  upload,required TResult Function( DownloadAction value)  download,required TResult Function( DeleteLocalAction value)  deleteLocal,required TResult Function( DeleteRemoteAction value)  deleteRemote,required TResult Function( RecordSyncedAction value)  recordSynced,required TResult Function( UpdatePlaceholderAction value)  updatePlaceholder,required TResult Function( ForgetAction value)  forget,required TResult Function( ConflictAction value)  conflict,}){
final _that = this;
switch (_that) {
case CreateRemoteDirAction():
return createRemoteDir(_that);case CreateLocalDirAction():
return createLocalDir(_that);case UploadAction():
return upload(_that);case DownloadAction():
return download(_that);case DeleteLocalAction():
return deleteLocal(_that);case DeleteRemoteAction():
return deleteRemote(_that);case RecordSyncedAction():
return recordSynced(_that);case UpdatePlaceholderAction():
return updatePlaceholder(_that);case ForgetAction():
return forget(_that);case ConflictAction():
return conflict(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateRemoteDirAction value)?  createRemoteDir,TResult? Function( CreateLocalDirAction value)?  createLocalDir,TResult? Function( UploadAction value)?  upload,TResult? Function( DownloadAction value)?  download,TResult? Function( DeleteLocalAction value)?  deleteLocal,TResult? Function( DeleteRemoteAction value)?  deleteRemote,TResult? Function( RecordSyncedAction value)?  recordSynced,TResult? Function( UpdatePlaceholderAction value)?  updatePlaceholder,TResult? Function( ForgetAction value)?  forget,TResult? Function( ConflictAction value)?  conflict,}){
final _that = this;
switch (_that) {
case CreateRemoteDirAction() when createRemoteDir != null:
return createRemoteDir(_that);case CreateLocalDirAction() when createLocalDir != null:
return createLocalDir(_that);case UploadAction() when upload != null:
return upload(_that);case DownloadAction() when download != null:
return download(_that);case DeleteLocalAction() when deleteLocal != null:
return deleteLocal(_that);case DeleteRemoteAction() when deleteRemote != null:
return deleteRemote(_that);case RecordSyncedAction() when recordSynced != null:
return recordSynced(_that);case UpdatePlaceholderAction() when updatePlaceholder != null:
return updatePlaceholder(_that);case ForgetAction() when forget != null:
return forget(_that);case ConflictAction() when conflict != null:
return conflict(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path)?  createRemoteDir,TResult Function( String path,  FileEntry remote)?  createLocalDir,TResult Function( String path,  LocalFileState local,  int baseRev)?  upload,TResult Function( String path,  FileEntry remote)?  download,TResult Function( String path)?  deleteLocal,TResult Function( String path,  int baseRev)?  deleteRemote,TResult Function( String path,  LocalFileState local,  FileEntry remote)?  recordSynced,TResult Function( String path,  FileEntry remote)?  updatePlaceholder,TResult Function( String path)?  forget,TResult Function( String path,  Conflict conflict)?  conflict,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateRemoteDirAction() when createRemoteDir != null:
return createRemoteDir(_that.path);case CreateLocalDirAction() when createLocalDir != null:
return createLocalDir(_that.path,_that.remote);case UploadAction() when upload != null:
return upload(_that.path,_that.local,_that.baseRev);case DownloadAction() when download != null:
return download(_that.path,_that.remote);case DeleteLocalAction() when deleteLocal != null:
return deleteLocal(_that.path);case DeleteRemoteAction() when deleteRemote != null:
return deleteRemote(_that.path,_that.baseRev);case RecordSyncedAction() when recordSynced != null:
return recordSynced(_that.path,_that.local,_that.remote);case UpdatePlaceholderAction() when updatePlaceholder != null:
return updatePlaceholder(_that.path,_that.remote);case ForgetAction() when forget != null:
return forget(_that.path);case ConflictAction() when conflict != null:
return conflict(_that.path,_that.conflict);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path)  createRemoteDir,required TResult Function( String path,  FileEntry remote)  createLocalDir,required TResult Function( String path,  LocalFileState local,  int baseRev)  upload,required TResult Function( String path,  FileEntry remote)  download,required TResult Function( String path)  deleteLocal,required TResult Function( String path,  int baseRev)  deleteRemote,required TResult Function( String path,  LocalFileState local,  FileEntry remote)  recordSynced,required TResult Function( String path,  FileEntry remote)  updatePlaceholder,required TResult Function( String path)  forget,required TResult Function( String path,  Conflict conflict)  conflict,}) {final _that = this;
switch (_that) {
case CreateRemoteDirAction():
return createRemoteDir(_that.path);case CreateLocalDirAction():
return createLocalDir(_that.path,_that.remote);case UploadAction():
return upload(_that.path,_that.local,_that.baseRev);case DownloadAction():
return download(_that.path,_that.remote);case DeleteLocalAction():
return deleteLocal(_that.path);case DeleteRemoteAction():
return deleteRemote(_that.path,_that.baseRev);case RecordSyncedAction():
return recordSynced(_that.path,_that.local,_that.remote);case UpdatePlaceholderAction():
return updatePlaceholder(_that.path,_that.remote);case ForgetAction():
return forget(_that.path);case ConflictAction():
return conflict(_that.path,_that.conflict);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path)?  createRemoteDir,TResult? Function( String path,  FileEntry remote)?  createLocalDir,TResult? Function( String path,  LocalFileState local,  int baseRev)?  upload,TResult? Function( String path,  FileEntry remote)?  download,TResult? Function( String path)?  deleteLocal,TResult? Function( String path,  int baseRev)?  deleteRemote,TResult? Function( String path,  LocalFileState local,  FileEntry remote)?  recordSynced,TResult? Function( String path,  FileEntry remote)?  updatePlaceholder,TResult? Function( String path)?  forget,TResult? Function( String path,  Conflict conflict)?  conflict,}) {final _that = this;
switch (_that) {
case CreateRemoteDirAction() when createRemoteDir != null:
return createRemoteDir(_that.path);case CreateLocalDirAction() when createLocalDir != null:
return createLocalDir(_that.path,_that.remote);case UploadAction() when upload != null:
return upload(_that.path,_that.local,_that.baseRev);case DownloadAction() when download != null:
return download(_that.path,_that.remote);case DeleteLocalAction() when deleteLocal != null:
return deleteLocal(_that.path);case DeleteRemoteAction() when deleteRemote != null:
return deleteRemote(_that.path,_that.baseRev);case RecordSyncedAction() when recordSynced != null:
return recordSynced(_that.path,_that.local,_that.remote);case UpdatePlaceholderAction() when updatePlaceholder != null:
return updatePlaceholder(_that.path,_that.remote);case ForgetAction() when forget != null:
return forget(_that.path);case ConflictAction() when conflict != null:
return conflict(_that.path,_that.conflict);case _:
  return null;

}
}

}

/// @nodoc


class CreateRemoteDirAction extends SyncAction {
  const CreateRemoteDirAction({required this.path}): super._();
  

@override final  String path;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRemoteDirActionCopyWith<CreateRemoteDirAction> get copyWith => _$CreateRemoteDirActionCopyWithImpl<CreateRemoteDirAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRemoteDirAction&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path);
}

@override
String toString() {
    return 'SyncAction.createRemoteDir(path: $path)';
}


}

/// @nodoc
abstract mixin class $CreateRemoteDirActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $CreateRemoteDirActionCopyWith(CreateRemoteDirAction value, $Res Function(CreateRemoteDirAction) _then) = _$CreateRemoteDirActionCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$CreateRemoteDirActionCopyWithImpl<$Res>
    implements $CreateRemoteDirActionCopyWith<$Res> {
  _$CreateRemoteDirActionCopyWithImpl(this._self, this._then);

  final CreateRemoteDirAction _self;
  final $Res Function(CreateRemoteDirAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(CreateRemoteDirAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CreateLocalDirAction extends SyncAction {
  const CreateLocalDirAction({required this.path, required this.remote}): super._();
  

@override final  String path;
 final  FileEntry remote;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateLocalDirActionCopyWith<CreateLocalDirAction> get copyWith => _$CreateLocalDirActionCopyWithImpl<CreateLocalDirAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateLocalDirAction&&(identical(other.path, path) || other.path == path)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,remote);
}

@override
String toString() {
    return 'SyncAction.createLocalDir(path: $path, remote: $remote)';
}


}

/// @nodoc
abstract mixin class $CreateLocalDirActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $CreateLocalDirActionCopyWith(CreateLocalDirAction value, $Res Function(CreateLocalDirAction) _then) = _$CreateLocalDirActionCopyWithImpl;
@override @useResult
$Res call({
 String path, FileEntry remote
});


$FileEntryCopyWith<$Res> get remote;

}
/// @nodoc
class _$CreateLocalDirActionCopyWithImpl<$Res>
    implements $CreateLocalDirActionCopyWith<$Res> {
  _$CreateLocalDirActionCopyWithImpl(this._self, this._then);

  final CreateLocalDirAction _self;
  final $Res Function(CreateLocalDirAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? remote = null,}) {
  return _then(CreateLocalDirAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get remote {
  
  return $FileEntryCopyWith<$Res>(_self.remote, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

/// @nodoc


class UploadAction extends SyncAction {
  const UploadAction({required this.path, required this.local, required this.baseRev}): super._();
  

@override final  String path;
 final  LocalFileState local;
 final  int baseRev;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadActionCopyWith<UploadAction> get copyWith => _$UploadActionCopyWithImpl<UploadAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadAction&&(identical(other.path, path) || other.path == path)&&(identical(other.local, local) || other.local == local)&&(identical(other.baseRev, baseRev) || other.baseRev == baseRev));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,local,baseRev);
}

@override
String toString() {
    return 'SyncAction.upload(path: $path, local: $local, baseRev: $baseRev)';
}


}

/// @nodoc
abstract mixin class $UploadActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $UploadActionCopyWith(UploadAction value, $Res Function(UploadAction) _then) = _$UploadActionCopyWithImpl;
@override @useResult
$Res call({
 String path, LocalFileState local, int baseRev
});


$LocalFileStateCopyWith<$Res> get local;

}
/// @nodoc
class _$UploadActionCopyWithImpl<$Res>
    implements $UploadActionCopyWith<$Res> {
  _$UploadActionCopyWithImpl(this._self, this._then);

  final UploadAction _self;
  final $Res Function(UploadAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? local = null,Object? baseRev = null,}) {
  return _then(UploadAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as LocalFileState,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalFileStateCopyWith<$Res> get local {
  
  return $LocalFileStateCopyWith<$Res>(_self.local, (value) {
    return _then(_self.copyWith(local: value));
  });
}
}

/// @nodoc


class DownloadAction extends SyncAction {
  const DownloadAction({required this.path, required this.remote}): super._();
  

@override final  String path;
 final  FileEntry remote;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadActionCopyWith<DownloadAction> get copyWith => _$DownloadActionCopyWithImpl<DownloadAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadAction&&(identical(other.path, path) || other.path == path)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,remote);
}

@override
String toString() {
    return 'SyncAction.download(path: $path, remote: $remote)';
}


}

/// @nodoc
abstract mixin class $DownloadActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $DownloadActionCopyWith(DownloadAction value, $Res Function(DownloadAction) _then) = _$DownloadActionCopyWithImpl;
@override @useResult
$Res call({
 String path, FileEntry remote
});


$FileEntryCopyWith<$Res> get remote;

}
/// @nodoc
class _$DownloadActionCopyWithImpl<$Res>
    implements $DownloadActionCopyWith<$Res> {
  _$DownloadActionCopyWithImpl(this._self, this._then);

  final DownloadAction _self;
  final $Res Function(DownloadAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? remote = null,}) {
  return _then(DownloadAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get remote {
  
  return $FileEntryCopyWith<$Res>(_self.remote, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

/// @nodoc


class DeleteLocalAction extends SyncAction {
  const DeleteLocalAction({required this.path}): super._();
  

@override final  String path;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteLocalActionCopyWith<DeleteLocalAction> get copyWith => _$DeleteLocalActionCopyWithImpl<DeleteLocalAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteLocalAction&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path);
}

@override
String toString() {
    return 'SyncAction.deleteLocal(path: $path)';
}


}

/// @nodoc
abstract mixin class $DeleteLocalActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $DeleteLocalActionCopyWith(DeleteLocalAction value, $Res Function(DeleteLocalAction) _then) = _$DeleteLocalActionCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$DeleteLocalActionCopyWithImpl<$Res>
    implements $DeleteLocalActionCopyWith<$Res> {
  _$DeleteLocalActionCopyWithImpl(this._self, this._then);

  final DeleteLocalAction _self;
  final $Res Function(DeleteLocalAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(DeleteLocalAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DeleteRemoteAction extends SyncAction {
  const DeleteRemoteAction({required this.path, required this.baseRev}): super._();
  

@override final  String path;
 final  int baseRev;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteRemoteActionCopyWith<DeleteRemoteAction> get copyWith => _$DeleteRemoteActionCopyWithImpl<DeleteRemoteAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteRemoteAction&&(identical(other.path, path) || other.path == path)&&(identical(other.baseRev, baseRev) || other.baseRev == baseRev));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,baseRev);
}

@override
String toString() {
    return 'SyncAction.deleteRemote(path: $path, baseRev: $baseRev)';
}


}

/// @nodoc
abstract mixin class $DeleteRemoteActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $DeleteRemoteActionCopyWith(DeleteRemoteAction value, $Res Function(DeleteRemoteAction) _then) = _$DeleteRemoteActionCopyWithImpl;
@override @useResult
$Res call({
 String path, int baseRev
});




}
/// @nodoc
class _$DeleteRemoteActionCopyWithImpl<$Res>
    implements $DeleteRemoteActionCopyWith<$Res> {
  _$DeleteRemoteActionCopyWithImpl(this._self, this._then);

  final DeleteRemoteAction _self;
  final $Res Function(DeleteRemoteAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? baseRev = null,}) {
  return _then(DeleteRemoteAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,baseRev: null == baseRev ? _self.baseRev : baseRev // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class RecordSyncedAction extends SyncAction {
  const RecordSyncedAction({required this.path, required this.local, required this.remote}): super._();
  

@override final  String path;
 final  LocalFileState local;
 final  FileEntry remote;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordSyncedActionCopyWith<RecordSyncedAction> get copyWith => _$RecordSyncedActionCopyWithImpl<RecordSyncedAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordSyncedAction&&(identical(other.path, path) || other.path == path)&&(identical(other.local, local) || other.local == local)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,local,remote);
}

@override
String toString() {
    return 'SyncAction.recordSynced(path: $path, local: $local, remote: $remote)';
}


}

/// @nodoc
abstract mixin class $RecordSyncedActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $RecordSyncedActionCopyWith(RecordSyncedAction value, $Res Function(RecordSyncedAction) _then) = _$RecordSyncedActionCopyWithImpl;
@override @useResult
$Res call({
 String path, LocalFileState local, FileEntry remote
});


$LocalFileStateCopyWith<$Res> get local;$FileEntryCopyWith<$Res> get remote;

}
/// @nodoc
class _$RecordSyncedActionCopyWithImpl<$Res>
    implements $RecordSyncedActionCopyWith<$Res> {
  _$RecordSyncedActionCopyWithImpl(this._self, this._then);

  final RecordSyncedAction _self;
  final $Res Function(RecordSyncedAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? local = null,Object? remote = null,}) {
  return _then(RecordSyncedAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,local: null == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as LocalFileState,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalFileStateCopyWith<$Res> get local {
  
  return $LocalFileStateCopyWith<$Res>(_self.local, (value) {
    return _then(_self.copyWith(local: value));
  });
}/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get remote {
  
  return $FileEntryCopyWith<$Res>(_self.remote, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

/// @nodoc


class UpdatePlaceholderAction extends SyncAction {
  const UpdatePlaceholderAction({required this.path, required this.remote}): super._();
  

@override final  String path;
 final  FileEntry remote;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePlaceholderActionCopyWith<UpdatePlaceholderAction> get copyWith => _$UpdatePlaceholderActionCopyWithImpl<UpdatePlaceholderAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePlaceholderAction&&(identical(other.path, path) || other.path == path)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,remote);
}

@override
String toString() {
    return 'SyncAction.updatePlaceholder(path: $path, remote: $remote)';
}


}

/// @nodoc
abstract mixin class $UpdatePlaceholderActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $UpdatePlaceholderActionCopyWith(UpdatePlaceholderAction value, $Res Function(UpdatePlaceholderAction) _then) = _$UpdatePlaceholderActionCopyWithImpl;
@override @useResult
$Res call({
 String path, FileEntry remote
});


$FileEntryCopyWith<$Res> get remote;

}
/// @nodoc
class _$UpdatePlaceholderActionCopyWithImpl<$Res>
    implements $UpdatePlaceholderActionCopyWith<$Res> {
  _$UpdatePlaceholderActionCopyWithImpl(this._self, this._then);

  final UpdatePlaceholderAction _self;
  final $Res Function(UpdatePlaceholderAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? remote = null,}) {
  return _then(UpdatePlaceholderAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,remote: null == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as FileEntry,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileEntryCopyWith<$Res> get remote {
  
  return $FileEntryCopyWith<$Res>(_self.remote, (value) {
    return _then(_self.copyWith(remote: value));
  });
}
}

/// @nodoc


class ForgetAction extends SyncAction {
  const ForgetAction({required this.path}): super._();
  

@override final  String path;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgetActionCopyWith<ForgetAction> get copyWith => _$ForgetActionCopyWithImpl<ForgetAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgetAction&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path);
}

@override
String toString() {
    return 'SyncAction.forget(path: $path)';
}


}

/// @nodoc
abstract mixin class $ForgetActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $ForgetActionCopyWith(ForgetAction value, $Res Function(ForgetAction) _then) = _$ForgetActionCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$ForgetActionCopyWithImpl<$Res>
    implements $ForgetActionCopyWith<$Res> {
  _$ForgetActionCopyWithImpl(this._self, this._then);

  final ForgetAction _self;
  final $Res Function(ForgetAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(ForgetAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConflictAction extends SyncAction {
  const ConflictAction({required this.path, required this.conflict}): super._();
  

@override final  String path;
 final  Conflict conflict;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictActionCopyWith<ConflictAction> get copyWith => _$ConflictActionCopyWithImpl<ConflictAction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictAction&&(identical(other.path, path) || other.path == path)&&(identical(other.conflict, conflict) || other.conflict == conflict));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,conflict);
}

@override
String toString() {
    return 'SyncAction.conflict(path: $path, conflict: $conflict)';
}


}

/// @nodoc
abstract mixin class $ConflictActionCopyWith<$Res> implements $SyncActionCopyWith<$Res> {
  factory $ConflictActionCopyWith(ConflictAction value, $Res Function(ConflictAction) _then) = _$ConflictActionCopyWithImpl;
@override @useResult
$Res call({
 String path, Conflict conflict
});


$ConflictCopyWith<$Res> get conflict;

}
/// @nodoc
class _$ConflictActionCopyWithImpl<$Res>
    implements $ConflictActionCopyWith<$Res> {
  _$ConflictActionCopyWithImpl(this._self, this._then);

  final ConflictAction _self;
  final $Res Function(ConflictAction) _then;

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? conflict = null,}) {
  return _then(ConflictAction(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,conflict: null == conflict ? _self.conflict : conflict // ignore: cast_nullable_to_non_nullable
as Conflict,
  ));
}

/// Create a copy of SyncAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConflictCopyWith<$Res> get conflict {
  
  return $ConflictCopyWith<$Res>(_self.conflict, (value) {
    return _then(_self.copyWith(conflict: value));
  });
}
}

// dart format on
