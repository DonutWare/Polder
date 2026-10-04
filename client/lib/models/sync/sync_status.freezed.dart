// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncRunReport {

 int get uploaded; int get downloaded; int get deleted; int get moved; int get failed; int get deferred; List<Conflict> get conflicts; List<String> get errors;
/// Create a copy of SyncRunReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncRunReportCopyWith<SyncRunReport> get copyWith => _$SyncRunReportCopyWithImpl<SyncRunReport>(this as SyncRunReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncRunReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncRunReport&&(identical(other.uploaded, _this.uploaded) || other.uploaded == _this.uploaded)&&(identical(other.downloaded, _this.downloaded) || other.downloaded == _this.downloaded)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.moved, _this.moved) || other.moved == _this.moved)&&(identical(other.failed, _this.failed) || other.failed == _this.failed)&&(identical(other.deferred, _this.deferred) || other.deferred == _this.deferred)&&const DeepCollectionEquality().equals(other.conflicts, _this.conflicts)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}


@override
int get hashCode {
  final _this = this as SyncRunReport;
  return Object.hash(runtimeType,_this.uploaded,_this.downloaded,_this.deleted,_this.moved,_this.failed,_this.deferred,const DeepCollectionEquality().hash(_this.conflicts),const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as SyncRunReport;
  return 'SyncRunReport(uploaded: ${_this.uploaded}, downloaded: ${_this.downloaded}, deleted: ${_this.deleted}, moved: ${_this.moved}, failed: ${_this.failed}, deferred: ${_this.deferred}, conflicts: ${_this.conflicts}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $SyncRunReportCopyWith<$Res>  {
  factory $SyncRunReportCopyWith(SyncRunReport value, $Res Function(SyncRunReport) _then) = _$SyncRunReportCopyWithImpl;
@useResult
$Res call({
 int uploaded, int downloaded, int deleted, int moved, int failed, int deferred, List<Conflict> conflicts, List<String> errors
});




}
/// @nodoc
class _$SyncRunReportCopyWithImpl<$Res>
    implements $SyncRunReportCopyWith<$Res> {
  _$SyncRunReportCopyWithImpl(this._self, this._then);

  final SyncRunReport _self;
  final $Res Function(SyncRunReport) _then;

/// Create a copy of SyncRunReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploaded = null,Object? downloaded = null,Object? deleted = null,Object? moved = null,Object? failed = null,Object? deferred = null,Object? conflicts = null,Object? errors = null,}) {
  return _then(SyncRunReport(
uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as int,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,moved: null == moved ? _self.moved : moved // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as int,conflicts: null == conflicts ? _self.conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<Conflict>,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncRunReport].
extension SyncRunReportPatterns on SyncRunReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncRunReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncRunReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncRunReport value)  $default,){
final _that = this;
switch (_that) {
case _SyncRunReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncRunReport value)?  $default,){
final _that = this;
switch (_that) {
case _SyncRunReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uploaded,  int downloaded,  int deleted,  int moved,  int failed,  int deferred,  List<Conflict> conflicts,  List<String> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncRunReport() when $default != null:
return $default(_that.uploaded,_that.downloaded,_that.deleted,_that.moved,_that.failed,_that.deferred,_that.conflicts,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uploaded,  int downloaded,  int deleted,  int moved,  int failed,  int deferred,  List<Conflict> conflicts,  List<String> errors)  $default,) {final _that = this;
switch (_that) {
case _SyncRunReport():
return $default(_that.uploaded,_that.downloaded,_that.deleted,_that.moved,_that.failed,_that.deferred,_that.conflicts,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uploaded,  int downloaded,  int deleted,  int moved,  int failed,  int deferred,  List<Conflict> conflicts,  List<String> errors)?  $default,) {final _that = this;
switch (_that) {
case _SyncRunReport() when $default != null:
return $default(_that.uploaded,_that.downloaded,_that.deleted,_that.moved,_that.failed,_that.deferred,_that.conflicts,_that.errors);case _:
  return null;

}
}

}

/// @nodoc


class _SyncRunReport extends SyncRunReport {
  const _SyncRunReport({this.uploaded = 0, this.downloaded = 0, this.deleted = 0, this.moved = 0, this.failed = 0, this.deferred = 0,  List<Conflict> conflicts = const <Conflict>[],  List<String> errors = const <String>[]}): _conflicts = conflicts,_errors = errors,super._();
  

@override@JsonKey() final  int uploaded;
@override@JsonKey() final  int downloaded;
@override@JsonKey() final  int deleted;
@override@JsonKey() final  int moved;
@override@JsonKey() final  int failed;
@override@JsonKey() final  int deferred;
 final  List<Conflict> _conflicts;
@override@JsonKey() List<Conflict> get conflicts {
  if (_conflicts is EqualUnmodifiableListView) return _conflicts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflicts);
}

 final  List<String> _errors;
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of SyncRunReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncRunReportCopyWith<_SyncRunReport> get copyWith => __$SyncRunReportCopyWithImpl<_SyncRunReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncRunReport&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.downloaded, downloaded) || other.downloaded == downloaded)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.moved, moved) || other.moved == moved)&&(identical(other.failed, failed) || other.failed == failed)&&(identical(other.deferred, deferred) || other.deferred == deferred)&&const DeepCollectionEquality().equals(other.conflicts, _conflicts)&&const DeepCollectionEquality().equals(other.errors, _errors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uploaded,downloaded,deleted,moved,failed,deferred,const DeepCollectionEquality().hash(_conflicts),const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'SyncRunReport(uploaded: $uploaded, downloaded: $downloaded, deleted: $deleted, moved: $moved, failed: $failed, deferred: $deferred, conflicts: $conflicts, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$SyncRunReportCopyWith<$Res> implements $SyncRunReportCopyWith<$Res> {
  factory _$SyncRunReportCopyWith(_SyncRunReport value, $Res Function(_SyncRunReport) _then) = __$SyncRunReportCopyWithImpl;
@override @useResult
$Res call({
 int uploaded, int downloaded, int deleted, int moved, int failed, int deferred, List<Conflict> conflicts, List<String> errors
});




}
/// @nodoc
class __$SyncRunReportCopyWithImpl<$Res>
    implements _$SyncRunReportCopyWith<$Res> {
  __$SyncRunReportCopyWithImpl(this._self, this._then);

  final _SyncRunReport _self;
  final $Res Function(_SyncRunReport) _then;

/// Create a copy of SyncRunReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploaded = null,Object? downloaded = null,Object? deleted = null,Object? moved = null,Object? failed = null,Object? deferred = null,Object? conflicts = null,Object? errors = null,}) {
  return _then(_SyncRunReport(
uploaded: null == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as int,downloaded: null == downloaded ? _self.downloaded : downloaded // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,moved: null == moved ? _self.moved : moved // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as int,deferred: null == deferred ? _self.deferred : deferred // ignore: cast_nullable_to_non_nullable
as int,conflicts: null == conflicts ? _self._conflicts : conflicts // ignore: cast_nullable_to_non_nullable
as List<Conflict>,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$SyncStatus {

 SyncPhase get phase; SyncRunReport get lastReport; DateTime? get lastRunAt; String? get errorMessage;
/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStatusCopyWith<SyncStatus> get copyWith => _$SyncStatusCopyWithImpl<SyncStatus>(this as SyncStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatus&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.lastReport, _this.lastReport) || other.lastReport == _this.lastReport)&&(identical(other.lastRunAt, _this.lastRunAt) || other.lastRunAt == _this.lastRunAt)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as SyncStatus;
  return Object.hash(runtimeType,_this.phase,_this.lastReport,_this.lastRunAt,_this.errorMessage);
}

@override
String toString() {
  final _this = this as SyncStatus;
  return 'SyncStatus(phase: ${_this.phase}, lastReport: ${_this.lastReport}, lastRunAt: ${_this.lastRunAt}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $SyncStatusCopyWith<$Res>  {
  factory $SyncStatusCopyWith(SyncStatus value, $Res Function(SyncStatus) _then) = _$SyncStatusCopyWithImpl;
@useResult
$Res call({
 SyncPhase phase, SyncRunReport lastReport, DateTime? lastRunAt, String? errorMessage
});


$SyncRunReportCopyWith<$Res> get lastReport;

}
/// @nodoc
class _$SyncStatusCopyWithImpl<$Res>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._self, this._then);

  final SyncStatus _self;
  final $Res Function(SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? lastReport = null,Object? lastRunAt = freezed,Object? errorMessage = freezed,}) {
  return _then(SyncStatus(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SyncPhase,lastReport: null == lastReport ? _self.lastReport : lastReport // ignore: cast_nullable_to_non_nullable
as SyncRunReport,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncRunReportCopyWith<$Res> get lastReport {
  
  return $SyncRunReportCopyWith<$Res>(_self.lastReport, (value) {
    return _then(_self.copyWith(lastReport: value));
  });
}
}


/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncStatus value)  $default,){
final _that = this;
switch (_that) {
case _SyncStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncPhase phase,  SyncRunReport lastReport,  DateTime? lastRunAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.phase,_that.lastReport,_that.lastRunAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncPhase phase,  SyncRunReport lastReport,  DateTime? lastRunAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SyncStatus():
return $default(_that.phase,_that.lastReport,_that.lastRunAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncPhase phase,  SyncRunReport lastReport,  DateTime? lastRunAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.phase,_that.lastReport,_that.lastRunAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SyncStatus extends SyncStatus {
  const _SyncStatus({this.phase = SyncPhase.idle, this.lastReport = const SyncRunReport(), this.lastRunAt, this.errorMessage}): super._();
  

@override@JsonKey() final  SyncPhase phase;
@override@JsonKey() final  SyncRunReport lastReport;
@override final  DateTime? lastRunAt;
@override final  String? errorMessage;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStatusCopyWith<_SyncStatus> get copyWith => __$SyncStatusCopyWithImpl<_SyncStatus>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncStatus&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.lastReport, lastReport) || other.lastReport == lastReport)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,lastReport,lastRunAt,errorMessage);
}

@override
String toString() {
    return 'SyncStatus(phase: $phase, lastReport: $lastReport, lastRunAt: $lastRunAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SyncStatusCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory _$SyncStatusCopyWith(_SyncStatus value, $Res Function(_SyncStatus) _then) = __$SyncStatusCopyWithImpl;
@override @useResult
$Res call({
 SyncPhase phase, SyncRunReport lastReport, DateTime? lastRunAt, String? errorMessage
});


@override $SyncRunReportCopyWith<$Res> get lastReport;

}
/// @nodoc
class __$SyncStatusCopyWithImpl<$Res>
    implements _$SyncStatusCopyWith<$Res> {
  __$SyncStatusCopyWithImpl(this._self, this._then);

  final _SyncStatus _self;
  final $Res Function(_SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? lastReport = null,Object? lastRunAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_SyncStatus(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SyncPhase,lastReport: null == lastReport ? _self.lastReport : lastReport // ignore: cast_nullable_to_non_nullable
as SyncRunReport,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncRunReportCopyWith<$Res> get lastReport {
  
  return $SyncRunReportCopyWith<$Res>(_self.lastReport, (value) {
    return _then(_self.copyWith(lastReport: value));
  });
}
}

// dart format on
