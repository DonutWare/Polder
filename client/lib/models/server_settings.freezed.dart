// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerSettings {

 int get trashRetentionDays; bool get trashRetentionEnforced; bool get searchContentEnabled; bool get ocrEnabled; List<String> get ocrLanguages; int get ocrMaxPages; String get instanceName; String get welcomeMessage; Color? get accentColor; bool get versionsEnabled; bool get versionsEnforced; int get versionsKeepAllHours; int get versionsMaxAgeDays; int get versionsMaxPerFile;
/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerSettingsCopyWith<ServerSettings> get copyWith => _$ServerSettingsCopyWithImpl<ServerSettings>(this as ServerSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSettings&&(identical(other.trashRetentionDays, _this.trashRetentionDays) || other.trashRetentionDays == _this.trashRetentionDays)&&(identical(other.trashRetentionEnforced, _this.trashRetentionEnforced) || other.trashRetentionEnforced == _this.trashRetentionEnforced)&&(identical(other.searchContentEnabled, _this.searchContentEnabled) || other.searchContentEnabled == _this.searchContentEnabled)&&(identical(other.ocrEnabled, _this.ocrEnabled) || other.ocrEnabled == _this.ocrEnabled)&&const DeepCollectionEquality().equals(other.ocrLanguages, _this.ocrLanguages)&&(identical(other.ocrMaxPages, _this.ocrMaxPages) || other.ocrMaxPages == _this.ocrMaxPages)&&(identical(other.instanceName, _this.instanceName) || other.instanceName == _this.instanceName)&&(identical(other.welcomeMessage, _this.welcomeMessage) || other.welcomeMessage == _this.welcomeMessage)&&(identical(other.accentColor, _this.accentColor) || other.accentColor == _this.accentColor)&&(identical(other.versionsEnabled, _this.versionsEnabled) || other.versionsEnabled == _this.versionsEnabled)&&(identical(other.versionsEnforced, _this.versionsEnforced) || other.versionsEnforced == _this.versionsEnforced)&&(identical(other.versionsKeepAllHours, _this.versionsKeepAllHours) || other.versionsKeepAllHours == _this.versionsKeepAllHours)&&(identical(other.versionsMaxAgeDays, _this.versionsMaxAgeDays) || other.versionsMaxAgeDays == _this.versionsMaxAgeDays)&&(identical(other.versionsMaxPerFile, _this.versionsMaxPerFile) || other.versionsMaxPerFile == _this.versionsMaxPerFile));
}


@override
int get hashCode {
  final _this = this as ServerSettings;
  return Object.hash(runtimeType,_this.trashRetentionDays,_this.trashRetentionEnforced,_this.searchContentEnabled,_this.ocrEnabled,const DeepCollectionEquality().hash(_this.ocrLanguages),_this.ocrMaxPages,_this.instanceName,_this.welcomeMessage,_this.accentColor,_this.versionsEnabled,_this.versionsEnforced,_this.versionsKeepAllHours,_this.versionsMaxAgeDays,_this.versionsMaxPerFile);
}

@override
String toString() {
  final _this = this as ServerSettings;
  return 'ServerSettings(trashRetentionDays: ${_this.trashRetentionDays}, trashRetentionEnforced: ${_this.trashRetentionEnforced}, searchContentEnabled: ${_this.searchContentEnabled}, ocrEnabled: ${_this.ocrEnabled}, ocrLanguages: ${_this.ocrLanguages}, ocrMaxPages: ${_this.ocrMaxPages}, instanceName: ${_this.instanceName}, welcomeMessage: ${_this.welcomeMessage}, accentColor: ${_this.accentColor}, versionsEnabled: ${_this.versionsEnabled}, versionsEnforced: ${_this.versionsEnforced}, versionsKeepAllHours: ${_this.versionsKeepAllHours}, versionsMaxAgeDays: ${_this.versionsMaxAgeDays}, versionsMaxPerFile: ${_this.versionsMaxPerFile})';
}


}

/// @nodoc
abstract mixin class $ServerSettingsCopyWith<$Res>  {
  factory $ServerSettingsCopyWith(ServerSettings value, $Res Function(ServerSettings) _then) = _$ServerSettingsCopyWithImpl;
@useResult
$Res call({
 int trashRetentionDays, bool trashRetentionEnforced, bool searchContentEnabled, bool ocrEnabled, List<String> ocrLanguages, int ocrMaxPages, String instanceName, String welcomeMessage, Color? accentColor, bool versionsEnabled, bool versionsEnforced, int versionsKeepAllHours, int versionsMaxAgeDays, int versionsMaxPerFile
});




}
/// @nodoc
class _$ServerSettingsCopyWithImpl<$Res>
    implements $ServerSettingsCopyWith<$Res> {
  _$ServerSettingsCopyWithImpl(this._self, this._then);

  final ServerSettings _self;
  final $Res Function(ServerSettings) _then;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trashRetentionDays = null,Object? trashRetentionEnforced = null,Object? searchContentEnabled = null,Object? ocrEnabled = null,Object? ocrLanguages = null,Object? ocrMaxPages = null,Object? instanceName = null,Object? welcomeMessage = null,Object? accentColor = freezed,Object? versionsEnabled = null,Object? versionsEnforced = null,Object? versionsKeepAllHours = null,Object? versionsMaxAgeDays = null,Object? versionsMaxPerFile = null,}) {
  return _then(ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashRetentionEnforced: null == trashRetentionEnforced ? _self.trashRetentionEnforced : trashRetentionEnforced // ignore: cast_nullable_to_non_nullable
as bool,searchContentEnabled: null == searchContentEnabled ? _self.searchContentEnabled : searchContentEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrEnabled: null == ocrEnabled ? _self.ocrEnabled : ocrEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrLanguages: null == ocrLanguages ? _self.ocrLanguages : ocrLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,ocrMaxPages: null == ocrMaxPages ? _self.ocrMaxPages : ocrMaxPages // ignore: cast_nullable_to_non_nullable
as int,instanceName: null == instanceName ? _self.instanceName : instanceName // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color?,versionsEnabled: null == versionsEnabled ? _self.versionsEnabled : versionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,versionsEnforced: null == versionsEnforced ? _self.versionsEnforced : versionsEnforced // ignore: cast_nullable_to_non_nullable
as bool,versionsKeepAllHours: null == versionsKeepAllHours ? _self.versionsKeepAllHours : versionsKeepAllHours // ignore: cast_nullable_to_non_nullable
as int,versionsMaxAgeDays: null == versionsMaxAgeDays ? _self.versionsMaxAgeDays : versionsMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,versionsMaxPerFile: null == versionsMaxPerFile ? _self.versionsMaxPerFile : versionsMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerSettings].
extension ServerSettingsPatterns on ServerSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerSettings value)  $default,){
final _that = this;
switch (_that) {
case _ServerSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashRetentionEnforced,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  bool versionsEnforced,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsEnforced,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashRetentionEnforced,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  bool versionsEnforced,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile)  $default,) {final _that = this;
switch (_that) {
case _ServerSettings():
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsEnforced,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trashRetentionDays,  bool trashRetentionEnforced,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  bool versionsEnforced,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile)?  $default,) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashRetentionEnforced,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsEnforced,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile);case _:
  return null;

}
}

}

/// @nodoc


class _ServerSettings implements ServerSettings {
  const _ServerSettings({required this.trashRetentionDays, this.trashRetentionEnforced = false, this.searchContentEnabled = true, this.ocrEnabled = true,  List<String> ocrLanguages = const <String>[], this.ocrMaxPages = 1, this.instanceName = "", this.welcomeMessage = "", this.accentColor, this.versionsEnabled = true, this.versionsEnforced = false, this.versionsKeepAllHours = 0, this.versionsMaxAgeDays = 0, this.versionsMaxPerFile = 0}): _ocrLanguages = ocrLanguages;
  

@override final  int trashRetentionDays;
@override@JsonKey() final  bool trashRetentionEnforced;
@override@JsonKey() final  bool searchContentEnabled;
@override@JsonKey() final  bool ocrEnabled;
 final  List<String> _ocrLanguages;
@override@JsonKey() List<String> get ocrLanguages {
  if (_ocrLanguages is EqualUnmodifiableListView) return _ocrLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ocrLanguages);
}

@override@JsonKey() final  int ocrMaxPages;
@override@JsonKey() final  String instanceName;
@override@JsonKey() final  String welcomeMessage;
@override final  Color? accentColor;
@override@JsonKey() final  bool versionsEnabled;
@override@JsonKey() final  bool versionsEnforced;
@override@JsonKey() final  int versionsKeepAllHours;
@override@JsonKey() final  int versionsMaxAgeDays;
@override@JsonKey() final  int versionsMaxPerFile;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerSettingsCopyWith<_ServerSettings> get copyWith => __$ServerSettingsCopyWithImpl<_ServerSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerSettings&&(identical(other.trashRetentionDays, trashRetentionDays) || other.trashRetentionDays == trashRetentionDays)&&(identical(other.trashRetentionEnforced, trashRetentionEnforced) || other.trashRetentionEnforced == trashRetentionEnforced)&&(identical(other.searchContentEnabled, searchContentEnabled) || other.searchContentEnabled == searchContentEnabled)&&(identical(other.ocrEnabled, ocrEnabled) || other.ocrEnabled == ocrEnabled)&&const DeepCollectionEquality().equals(other.ocrLanguages, _ocrLanguages)&&(identical(other.ocrMaxPages, ocrMaxPages) || other.ocrMaxPages == ocrMaxPages)&&(identical(other.instanceName, instanceName) || other.instanceName == instanceName)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.versionsEnabled, versionsEnabled) || other.versionsEnabled == versionsEnabled)&&(identical(other.versionsEnforced, versionsEnforced) || other.versionsEnforced == versionsEnforced)&&(identical(other.versionsKeepAllHours, versionsKeepAllHours) || other.versionsKeepAllHours == versionsKeepAllHours)&&(identical(other.versionsMaxAgeDays, versionsMaxAgeDays) || other.versionsMaxAgeDays == versionsMaxAgeDays)&&(identical(other.versionsMaxPerFile, versionsMaxPerFile) || other.versionsMaxPerFile == versionsMaxPerFile));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trashRetentionDays,trashRetentionEnforced,searchContentEnabled,ocrEnabled,const DeepCollectionEquality().hash(_ocrLanguages),ocrMaxPages,instanceName,welcomeMessage,accentColor,versionsEnabled,versionsEnforced,versionsKeepAllHours,versionsMaxAgeDays,versionsMaxPerFile);
}

@override
String toString() {
    return 'ServerSettings(trashRetentionDays: $trashRetentionDays, trashRetentionEnforced: $trashRetentionEnforced, searchContentEnabled: $searchContentEnabled, ocrEnabled: $ocrEnabled, ocrLanguages: $ocrLanguages, ocrMaxPages: $ocrMaxPages, instanceName: $instanceName, welcomeMessage: $welcomeMessage, accentColor: $accentColor, versionsEnabled: $versionsEnabled, versionsEnforced: $versionsEnforced, versionsKeepAllHours: $versionsKeepAllHours, versionsMaxAgeDays: $versionsMaxAgeDays, versionsMaxPerFile: $versionsMaxPerFile)';
}


}

/// @nodoc
abstract mixin class _$ServerSettingsCopyWith<$Res> implements $ServerSettingsCopyWith<$Res> {
  factory _$ServerSettingsCopyWith(_ServerSettings value, $Res Function(_ServerSettings) _then) = __$ServerSettingsCopyWithImpl;
@override @useResult
$Res call({
 int trashRetentionDays, bool trashRetentionEnforced, bool searchContentEnabled, bool ocrEnabled, List<String> ocrLanguages, int ocrMaxPages, String instanceName, String welcomeMessage, Color? accentColor, bool versionsEnabled, bool versionsEnforced, int versionsKeepAllHours, int versionsMaxAgeDays, int versionsMaxPerFile
});




}
/// @nodoc
class __$ServerSettingsCopyWithImpl<$Res>
    implements _$ServerSettingsCopyWith<$Res> {
  __$ServerSettingsCopyWithImpl(this._self, this._then);

  final _ServerSettings _self;
  final $Res Function(_ServerSettings) _then;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trashRetentionDays = null,Object? trashRetentionEnforced = null,Object? searchContentEnabled = null,Object? ocrEnabled = null,Object? ocrLanguages = null,Object? ocrMaxPages = null,Object? instanceName = null,Object? welcomeMessage = null,Object? accentColor = freezed,Object? versionsEnabled = null,Object? versionsEnforced = null,Object? versionsKeepAllHours = null,Object? versionsMaxAgeDays = null,Object? versionsMaxPerFile = null,}) {
  return _then(_ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashRetentionEnforced: null == trashRetentionEnforced ? _self.trashRetentionEnforced : trashRetentionEnforced // ignore: cast_nullable_to_non_nullable
as bool,searchContentEnabled: null == searchContentEnabled ? _self.searchContentEnabled : searchContentEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrEnabled: null == ocrEnabled ? _self.ocrEnabled : ocrEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrLanguages: null == ocrLanguages ? _self._ocrLanguages : ocrLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,ocrMaxPages: null == ocrMaxPages ? _self.ocrMaxPages : ocrMaxPages // ignore: cast_nullable_to_non_nullable
as int,instanceName: null == instanceName ? _self.instanceName : instanceName // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color?,versionsEnabled: null == versionsEnabled ? _self.versionsEnabled : versionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,versionsEnforced: null == versionsEnforced ? _self.versionsEnforced : versionsEnforced // ignore: cast_nullable_to_non_nullable
as bool,versionsKeepAllHours: null == versionsKeepAllHours ? _self.versionsKeepAllHours : versionsKeepAllHours // ignore: cast_nullable_to_non_nullable
as int,versionsMaxAgeDays: null == versionsMaxAgeDays ? _self.versionsMaxAgeDays : versionsMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,versionsMaxPerFile: null == versionsMaxPerFile ? _self.versionsMaxPerFile : versionsMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
