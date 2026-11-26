// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_folder_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncFolderForm {

 SyncMode get mode; String? get localPath; String get remotePath; bool get hasExistingFiles; bool get uploadExisting; bool get storageDenied;
/// Create a copy of SyncFolderForm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncFolderFormCopyWith<SyncFolderForm> get copyWith => _$SyncFolderFormCopyWithImpl<SyncFolderForm>(this as SyncFolderForm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncFolderForm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncFolderForm&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.remotePath, _this.remotePath) || other.remotePath == _this.remotePath)&&(identical(other.hasExistingFiles, _this.hasExistingFiles) || other.hasExistingFiles == _this.hasExistingFiles)&&(identical(other.uploadExisting, _this.uploadExisting) || other.uploadExisting == _this.uploadExisting)&&(identical(other.storageDenied, _this.storageDenied) || other.storageDenied == _this.storageDenied));
}


@override
int get hashCode {
  final _this = this as SyncFolderForm;
  return Object.hash(runtimeType,_this.mode,_this.localPath,_this.remotePath,_this.hasExistingFiles,_this.uploadExisting,_this.storageDenied);
}

@override
String toString() {
  final _this = this as SyncFolderForm;
  return 'SyncFolderForm(mode: ${_this.mode}, localPath: ${_this.localPath}, remotePath: ${_this.remotePath}, hasExistingFiles: ${_this.hasExistingFiles}, uploadExisting: ${_this.uploadExisting}, storageDenied: ${_this.storageDenied})';
}


}

/// @nodoc
abstract mixin class $SyncFolderFormCopyWith<$Res>  {
  factory $SyncFolderFormCopyWith(SyncFolderForm value, $Res Function(SyncFolderForm) _then) = _$SyncFolderFormCopyWithImpl;
@useResult
$Res call({
 SyncMode mode, String? localPath, String remotePath, bool hasExistingFiles, bool uploadExisting, bool storageDenied
});




}
/// @nodoc
class _$SyncFolderFormCopyWithImpl<$Res>
    implements $SyncFolderFormCopyWith<$Res> {
  _$SyncFolderFormCopyWithImpl(this._self, this._then);

  final SyncFolderForm _self;
  final $Res Function(SyncFolderForm) _then;

/// Create a copy of SyncFolderForm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? localPath = freezed,Object? remotePath = null,Object? hasExistingFiles = null,Object? uploadExisting = null,Object? storageDenied = null,}) {
  return _then(SyncFolderForm(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SyncMode,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,remotePath: null == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String,hasExistingFiles: null == hasExistingFiles ? _self.hasExistingFiles : hasExistingFiles // ignore: cast_nullable_to_non_nullable
as bool,uploadExisting: null == uploadExisting ? _self.uploadExisting : uploadExisting // ignore: cast_nullable_to_non_nullable
as bool,storageDenied: null == storageDenied ? _self.storageDenied : storageDenied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncFolderForm].
extension SyncFolderFormPatterns on SyncFolderForm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncFolderForm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncFolderForm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncFolderForm value)  $default,){
final _that = this;
switch (_that) {
case _SyncFolderForm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncFolderForm value)?  $default,){
final _that = this;
switch (_that) {
case _SyncFolderForm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncMode mode,  String? localPath,  String remotePath,  bool hasExistingFiles,  bool uploadExisting,  bool storageDenied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncFolderForm() when $default != null:
return $default(_that.mode,_that.localPath,_that.remotePath,_that.hasExistingFiles,_that.uploadExisting,_that.storageDenied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncMode mode,  String? localPath,  String remotePath,  bool hasExistingFiles,  bool uploadExisting,  bool storageDenied)  $default,) {final _that = this;
switch (_that) {
case _SyncFolderForm():
return $default(_that.mode,_that.localPath,_that.remotePath,_that.hasExistingFiles,_that.uploadExisting,_that.storageDenied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncMode mode,  String? localPath,  String remotePath,  bool hasExistingFiles,  bool uploadExisting,  bool storageDenied)?  $default,) {final _that = this;
switch (_that) {
case _SyncFolderForm() when $default != null:
return $default(_that.mode,_that.localPath,_that.remotePath,_that.hasExistingFiles,_that.uploadExisting,_that.storageDenied);case _:
  return null;

}
}

}

/// @nodoc


class _SyncFolderForm extends SyncFolderForm {
  const _SyncFolderForm({this.mode = SyncMode.sync, this.localPath, this.remotePath = "/", this.hasExistingFiles = false, this.uploadExisting = true, this.storageDenied = false}): super._();
  

@override@JsonKey() final  SyncMode mode;
@override final  String? localPath;
@override@JsonKey() final  String remotePath;
@override@JsonKey() final  bool hasExistingFiles;
@override@JsonKey() final  bool uploadExisting;
@override@JsonKey() final  bool storageDenied;

/// Create a copy of SyncFolderForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncFolderFormCopyWith<_SyncFolderForm> get copyWith => __$SyncFolderFormCopyWithImpl<_SyncFolderForm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncFolderForm&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.remotePath, remotePath) || other.remotePath == remotePath)&&(identical(other.hasExistingFiles, hasExistingFiles) || other.hasExistingFiles == hasExistingFiles)&&(identical(other.uploadExisting, uploadExisting) || other.uploadExisting == uploadExisting)&&(identical(other.storageDenied, storageDenied) || other.storageDenied == storageDenied));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,localPath,remotePath,hasExistingFiles,uploadExisting,storageDenied);
}

@override
String toString() {
    return 'SyncFolderForm(mode: $mode, localPath: $localPath, remotePath: $remotePath, hasExistingFiles: $hasExistingFiles, uploadExisting: $uploadExisting, storageDenied: $storageDenied)';
}


}

/// @nodoc
abstract mixin class _$SyncFolderFormCopyWith<$Res> implements $SyncFolderFormCopyWith<$Res> {
  factory _$SyncFolderFormCopyWith(_SyncFolderForm value, $Res Function(_SyncFolderForm) _then) = __$SyncFolderFormCopyWithImpl;
@override @useResult
$Res call({
 SyncMode mode, String? localPath, String remotePath, bool hasExistingFiles, bool uploadExisting, bool storageDenied
});




}
/// @nodoc
class __$SyncFolderFormCopyWithImpl<$Res>
    implements _$SyncFolderFormCopyWith<$Res> {
  __$SyncFolderFormCopyWithImpl(this._self, this._then);

  final _SyncFolderForm _self;
  final $Res Function(_SyncFolderForm) _then;

/// Create a copy of SyncFolderForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? localPath = freezed,Object? remotePath = null,Object? hasExistingFiles = null,Object? uploadExisting = null,Object? storageDenied = null,}) {
  return _then(_SyncFolderForm(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SyncMode,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,remotePath: null == remotePath ? _self.remotePath : remotePath // ignore: cast_nullable_to_non_nullable
as String,hasExistingFiles: null == hasExistingFiles ? _self.hasExistingFiles : hasExistingFiles // ignore: cast_nullable_to_non_nullable
as bool,uploadExisting: null == uploadExisting ? _self.uploadExisting : uploadExisting // ignore: cast_nullable_to_non_nullable
as bool,storageDenied: null == storageDenied ? _self.storageDenied : storageDenied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
