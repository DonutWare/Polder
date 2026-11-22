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

 int get trashRetentionDays; bool get trashEnabled; bool get searchContentEnabled; bool get ocrEnabled; List<String> get ocrLanguages; int get ocrMaxPages; String get instanceName; String get welcomeMessage; Color? get accentColor; bool get versionsEnabled; int get versionsKeepAllHours; int get versionsMaxAgeDays; int get versionsMaxPerFile; bool get federationEnabled; String get smtpHost; int get smtpPort; String get smtpUsername; bool get smtpPasswordSet; String get smtpFrom; MailSecurity get smtpSecurity; bool get smtpManagedByConfig;
/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerSettingsCopyWith<ServerSettings> get copyWith => _$ServerSettingsCopyWithImpl<ServerSettings>(this as ServerSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServerSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSettings&&(identical(other.trashRetentionDays, _this.trashRetentionDays) || other.trashRetentionDays == _this.trashRetentionDays)&&(identical(other.trashEnabled, _this.trashEnabled) || other.trashEnabled == _this.trashEnabled)&&(identical(other.searchContentEnabled, _this.searchContentEnabled) || other.searchContentEnabled == _this.searchContentEnabled)&&(identical(other.ocrEnabled, _this.ocrEnabled) || other.ocrEnabled == _this.ocrEnabled)&&const DeepCollectionEquality().equals(other.ocrLanguages, _this.ocrLanguages)&&(identical(other.ocrMaxPages, _this.ocrMaxPages) || other.ocrMaxPages == _this.ocrMaxPages)&&(identical(other.instanceName, _this.instanceName) || other.instanceName == _this.instanceName)&&(identical(other.welcomeMessage, _this.welcomeMessage) || other.welcomeMessage == _this.welcomeMessage)&&(identical(other.accentColor, _this.accentColor) || other.accentColor == _this.accentColor)&&(identical(other.versionsEnabled, _this.versionsEnabled) || other.versionsEnabled == _this.versionsEnabled)&&(identical(other.versionsKeepAllHours, _this.versionsKeepAllHours) || other.versionsKeepAllHours == _this.versionsKeepAllHours)&&(identical(other.versionsMaxAgeDays, _this.versionsMaxAgeDays) || other.versionsMaxAgeDays == _this.versionsMaxAgeDays)&&(identical(other.versionsMaxPerFile, _this.versionsMaxPerFile) || other.versionsMaxPerFile == _this.versionsMaxPerFile)&&(identical(other.federationEnabled, _this.federationEnabled) || other.federationEnabled == _this.federationEnabled)&&(identical(other.smtpHost, _this.smtpHost) || other.smtpHost == _this.smtpHost)&&(identical(other.smtpPort, _this.smtpPort) || other.smtpPort == _this.smtpPort)&&(identical(other.smtpUsername, _this.smtpUsername) || other.smtpUsername == _this.smtpUsername)&&(identical(other.smtpPasswordSet, _this.smtpPasswordSet) || other.smtpPasswordSet == _this.smtpPasswordSet)&&(identical(other.smtpFrom, _this.smtpFrom) || other.smtpFrom == _this.smtpFrom)&&(identical(other.smtpSecurity, _this.smtpSecurity) || other.smtpSecurity == _this.smtpSecurity)&&(identical(other.smtpManagedByConfig, _this.smtpManagedByConfig) || other.smtpManagedByConfig == _this.smtpManagedByConfig));
}


@override
int get hashCode {
  final _this = this as ServerSettings;
  return Object.hashAll([runtimeType,_this.trashRetentionDays,_this.trashEnabled,_this.searchContentEnabled,_this.ocrEnabled,const DeepCollectionEquality().hash(_this.ocrLanguages),_this.ocrMaxPages,_this.instanceName,_this.welcomeMessage,_this.accentColor,_this.versionsEnabled,_this.versionsKeepAllHours,_this.versionsMaxAgeDays,_this.versionsMaxPerFile,_this.federationEnabled,_this.smtpHost,_this.smtpPort,_this.smtpUsername,_this.smtpPasswordSet,_this.smtpFrom,_this.smtpSecurity,_this.smtpManagedByConfig]);
}

@override
String toString() {
  final _this = this as ServerSettings;
  return 'ServerSettings(trashRetentionDays: ${_this.trashRetentionDays}, trashEnabled: ${_this.trashEnabled}, searchContentEnabled: ${_this.searchContentEnabled}, ocrEnabled: ${_this.ocrEnabled}, ocrLanguages: ${_this.ocrLanguages}, ocrMaxPages: ${_this.ocrMaxPages}, instanceName: ${_this.instanceName}, welcomeMessage: ${_this.welcomeMessage}, accentColor: ${_this.accentColor}, versionsEnabled: ${_this.versionsEnabled}, versionsKeepAllHours: ${_this.versionsKeepAllHours}, versionsMaxAgeDays: ${_this.versionsMaxAgeDays}, versionsMaxPerFile: ${_this.versionsMaxPerFile}, federationEnabled: ${_this.federationEnabled}, smtpHost: ${_this.smtpHost}, smtpPort: ${_this.smtpPort}, smtpUsername: ${_this.smtpUsername}, smtpPasswordSet: ${_this.smtpPasswordSet}, smtpFrom: ${_this.smtpFrom}, smtpSecurity: ${_this.smtpSecurity}, smtpManagedByConfig: ${_this.smtpManagedByConfig})';
}


}

/// @nodoc
abstract mixin class $ServerSettingsCopyWith<$Res>  {
  factory $ServerSettingsCopyWith(ServerSettings value, $Res Function(ServerSettings) _then) = _$ServerSettingsCopyWithImpl;
@useResult
$Res call({
 int trashRetentionDays, bool trashEnabled, bool searchContentEnabled, bool ocrEnabled, List<String> ocrLanguages, int ocrMaxPages, String instanceName, String welcomeMessage, Color? accentColor, bool versionsEnabled, int versionsKeepAllHours, int versionsMaxAgeDays, int versionsMaxPerFile, bool federationEnabled, String smtpHost, int smtpPort, String smtpUsername, bool smtpPasswordSet, String smtpFrom, MailSecurity smtpSecurity, bool smtpManagedByConfig
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
@pragma('vm:prefer-inline') @override $Res call({Object? trashRetentionDays = null,Object? trashEnabled = null,Object? searchContentEnabled = null,Object? ocrEnabled = null,Object? ocrLanguages = null,Object? ocrMaxPages = null,Object? instanceName = null,Object? welcomeMessage = null,Object? accentColor = freezed,Object? versionsEnabled = null,Object? versionsKeepAllHours = null,Object? versionsMaxAgeDays = null,Object? versionsMaxPerFile = null,Object? federationEnabled = null,Object? smtpHost = null,Object? smtpPort = null,Object? smtpUsername = null,Object? smtpPasswordSet = null,Object? smtpFrom = null,Object? smtpSecurity = null,Object? smtpManagedByConfig = null,}) {
  return _then(ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashEnabled: null == trashEnabled ? _self.trashEnabled : trashEnabled // ignore: cast_nullable_to_non_nullable
as bool,searchContentEnabled: null == searchContentEnabled ? _self.searchContentEnabled : searchContentEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrEnabled: null == ocrEnabled ? _self.ocrEnabled : ocrEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrLanguages: null == ocrLanguages ? _self.ocrLanguages : ocrLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,ocrMaxPages: null == ocrMaxPages ? _self.ocrMaxPages : ocrMaxPages // ignore: cast_nullable_to_non_nullable
as int,instanceName: null == instanceName ? _self.instanceName : instanceName // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color?,versionsEnabled: null == versionsEnabled ? _self.versionsEnabled : versionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,versionsKeepAllHours: null == versionsKeepAllHours ? _self.versionsKeepAllHours : versionsKeepAllHours // ignore: cast_nullable_to_non_nullable
as int,versionsMaxAgeDays: null == versionsMaxAgeDays ? _self.versionsMaxAgeDays : versionsMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,versionsMaxPerFile: null == versionsMaxPerFile ? _self.versionsMaxPerFile : versionsMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,federationEnabled: null == federationEnabled ? _self.federationEnabled : federationEnabled // ignore: cast_nullable_to_non_nullable
as bool,smtpHost: null == smtpHost ? _self.smtpHost : smtpHost // ignore: cast_nullable_to_non_nullable
as String,smtpPort: null == smtpPort ? _self.smtpPort : smtpPort // ignore: cast_nullable_to_non_nullable
as int,smtpUsername: null == smtpUsername ? _self.smtpUsername : smtpUsername // ignore: cast_nullable_to_non_nullable
as String,smtpPasswordSet: null == smtpPasswordSet ? _self.smtpPasswordSet : smtpPasswordSet // ignore: cast_nullable_to_non_nullable
as bool,smtpFrom: null == smtpFrom ? _self.smtpFrom : smtpFrom // ignore: cast_nullable_to_non_nullable
as String,smtpSecurity: null == smtpSecurity ? _self.smtpSecurity : smtpSecurity // ignore: cast_nullable_to_non_nullable
as MailSecurity,smtpManagedByConfig: null == smtpManagedByConfig ? _self.smtpManagedByConfig : smtpManagedByConfig // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashEnabled,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile,  bool federationEnabled,  String smtpHost,  int smtpPort,  String smtpUsername,  bool smtpPasswordSet,  String smtpFrom,  MailSecurity smtpSecurity,  bool smtpManagedByConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashEnabled,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile,_that.federationEnabled,_that.smtpHost,_that.smtpPort,_that.smtpUsername,_that.smtpPasswordSet,_that.smtpFrom,_that.smtpSecurity,_that.smtpManagedByConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trashRetentionDays,  bool trashEnabled,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile,  bool federationEnabled,  String smtpHost,  int smtpPort,  String smtpUsername,  bool smtpPasswordSet,  String smtpFrom,  MailSecurity smtpSecurity,  bool smtpManagedByConfig)  $default,) {final _that = this;
switch (_that) {
case _ServerSettings():
return $default(_that.trashRetentionDays,_that.trashEnabled,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile,_that.federationEnabled,_that.smtpHost,_that.smtpPort,_that.smtpUsername,_that.smtpPasswordSet,_that.smtpFrom,_that.smtpSecurity,_that.smtpManagedByConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trashRetentionDays,  bool trashEnabled,  bool searchContentEnabled,  bool ocrEnabled,  List<String> ocrLanguages,  int ocrMaxPages,  String instanceName,  String welcomeMessage,  Color? accentColor,  bool versionsEnabled,  int versionsKeepAllHours,  int versionsMaxAgeDays,  int versionsMaxPerFile,  bool federationEnabled,  String smtpHost,  int smtpPort,  String smtpUsername,  bool smtpPasswordSet,  String smtpFrom,  MailSecurity smtpSecurity,  bool smtpManagedByConfig)?  $default,) {final _that = this;
switch (_that) {
case _ServerSettings() when $default != null:
return $default(_that.trashRetentionDays,_that.trashEnabled,_that.searchContentEnabled,_that.ocrEnabled,_that.ocrLanguages,_that.ocrMaxPages,_that.instanceName,_that.welcomeMessage,_that.accentColor,_that.versionsEnabled,_that.versionsKeepAllHours,_that.versionsMaxAgeDays,_that.versionsMaxPerFile,_that.federationEnabled,_that.smtpHost,_that.smtpPort,_that.smtpUsername,_that.smtpPasswordSet,_that.smtpFrom,_that.smtpSecurity,_that.smtpManagedByConfig);case _:
  return null;

}
}

}

/// @nodoc


class _ServerSettings implements ServerSettings {
  const _ServerSettings({required this.trashRetentionDays, this.trashEnabled = true, this.searchContentEnabled = true, this.ocrEnabled = true,  List<String> ocrLanguages = const <String>[], this.ocrMaxPages = 1, this.instanceName = "", this.welcomeMessage = "", this.accentColor, this.versionsEnabled = true, this.versionsKeepAllHours = 0, this.versionsMaxAgeDays = 0, this.versionsMaxPerFile = 0, this.federationEnabled = false, this.smtpHost = "", this.smtpPort = 0, this.smtpUsername = "", this.smtpPasswordSet = false, this.smtpFrom = "", this.smtpSecurity = MailSecurity.starttls, this.smtpManagedByConfig = false}): _ocrLanguages = ocrLanguages;
  

@override final  int trashRetentionDays;
@override@JsonKey() final  bool trashEnabled;
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
@override@JsonKey() final  int versionsKeepAllHours;
@override@JsonKey() final  int versionsMaxAgeDays;
@override@JsonKey() final  int versionsMaxPerFile;
@override@JsonKey() final  bool federationEnabled;
@override@JsonKey() final  String smtpHost;
@override@JsonKey() final  int smtpPort;
@override@JsonKey() final  String smtpUsername;
@override@JsonKey() final  bool smtpPasswordSet;
@override@JsonKey() final  String smtpFrom;
@override@JsonKey() final  MailSecurity smtpSecurity;
@override@JsonKey() final  bool smtpManagedByConfig;

/// Create a copy of ServerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerSettingsCopyWith<_ServerSettings> get copyWith => __$ServerSettingsCopyWithImpl<_ServerSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerSettings&&(identical(other.trashRetentionDays, trashRetentionDays) || other.trashRetentionDays == trashRetentionDays)&&(identical(other.trashEnabled, trashEnabled) || other.trashEnabled == trashEnabled)&&(identical(other.searchContentEnabled, searchContentEnabled) || other.searchContentEnabled == searchContentEnabled)&&(identical(other.ocrEnabled, ocrEnabled) || other.ocrEnabled == ocrEnabled)&&const DeepCollectionEquality().equals(other.ocrLanguages, _ocrLanguages)&&(identical(other.ocrMaxPages, ocrMaxPages) || other.ocrMaxPages == ocrMaxPages)&&(identical(other.instanceName, instanceName) || other.instanceName == instanceName)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.versionsEnabled, versionsEnabled) || other.versionsEnabled == versionsEnabled)&&(identical(other.versionsKeepAllHours, versionsKeepAllHours) || other.versionsKeepAllHours == versionsKeepAllHours)&&(identical(other.versionsMaxAgeDays, versionsMaxAgeDays) || other.versionsMaxAgeDays == versionsMaxAgeDays)&&(identical(other.versionsMaxPerFile, versionsMaxPerFile) || other.versionsMaxPerFile == versionsMaxPerFile)&&(identical(other.federationEnabled, federationEnabled) || other.federationEnabled == federationEnabled)&&(identical(other.smtpHost, smtpHost) || other.smtpHost == smtpHost)&&(identical(other.smtpPort, smtpPort) || other.smtpPort == smtpPort)&&(identical(other.smtpUsername, smtpUsername) || other.smtpUsername == smtpUsername)&&(identical(other.smtpPasswordSet, smtpPasswordSet) || other.smtpPasswordSet == smtpPasswordSet)&&(identical(other.smtpFrom, smtpFrom) || other.smtpFrom == smtpFrom)&&(identical(other.smtpSecurity, smtpSecurity) || other.smtpSecurity == smtpSecurity)&&(identical(other.smtpManagedByConfig, smtpManagedByConfig) || other.smtpManagedByConfig == smtpManagedByConfig));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,trashRetentionDays,trashEnabled,searchContentEnabled,ocrEnabled,const DeepCollectionEquality().hash(_ocrLanguages),ocrMaxPages,instanceName,welcomeMessage,accentColor,versionsEnabled,versionsKeepAllHours,versionsMaxAgeDays,versionsMaxPerFile,federationEnabled,smtpHost,smtpPort,smtpUsername,smtpPasswordSet,smtpFrom,smtpSecurity,smtpManagedByConfig]);
}

@override
String toString() {
    return 'ServerSettings(trashRetentionDays: $trashRetentionDays, trashEnabled: $trashEnabled, searchContentEnabled: $searchContentEnabled, ocrEnabled: $ocrEnabled, ocrLanguages: $ocrLanguages, ocrMaxPages: $ocrMaxPages, instanceName: $instanceName, welcomeMessage: $welcomeMessage, accentColor: $accentColor, versionsEnabled: $versionsEnabled, versionsKeepAllHours: $versionsKeepAllHours, versionsMaxAgeDays: $versionsMaxAgeDays, versionsMaxPerFile: $versionsMaxPerFile, federationEnabled: $federationEnabled, smtpHost: $smtpHost, smtpPort: $smtpPort, smtpUsername: $smtpUsername, smtpPasswordSet: $smtpPasswordSet, smtpFrom: $smtpFrom, smtpSecurity: $smtpSecurity, smtpManagedByConfig: $smtpManagedByConfig)';
}


}

/// @nodoc
abstract mixin class _$ServerSettingsCopyWith<$Res> implements $ServerSettingsCopyWith<$Res> {
  factory _$ServerSettingsCopyWith(_ServerSettings value, $Res Function(_ServerSettings) _then) = __$ServerSettingsCopyWithImpl;
@override @useResult
$Res call({
 int trashRetentionDays, bool trashEnabled, bool searchContentEnabled, bool ocrEnabled, List<String> ocrLanguages, int ocrMaxPages, String instanceName, String welcomeMessage, Color? accentColor, bool versionsEnabled, int versionsKeepAllHours, int versionsMaxAgeDays, int versionsMaxPerFile, bool federationEnabled, String smtpHost, int smtpPort, String smtpUsername, bool smtpPasswordSet, String smtpFrom, MailSecurity smtpSecurity, bool smtpManagedByConfig
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
@override @pragma('vm:prefer-inline') $Res call({Object? trashRetentionDays = null,Object? trashEnabled = null,Object? searchContentEnabled = null,Object? ocrEnabled = null,Object? ocrLanguages = null,Object? ocrMaxPages = null,Object? instanceName = null,Object? welcomeMessage = null,Object? accentColor = freezed,Object? versionsEnabled = null,Object? versionsKeepAllHours = null,Object? versionsMaxAgeDays = null,Object? versionsMaxPerFile = null,Object? federationEnabled = null,Object? smtpHost = null,Object? smtpPort = null,Object? smtpUsername = null,Object? smtpPasswordSet = null,Object? smtpFrom = null,Object? smtpSecurity = null,Object? smtpManagedByConfig = null,}) {
  return _then(_ServerSettings(
trashRetentionDays: null == trashRetentionDays ? _self.trashRetentionDays : trashRetentionDays // ignore: cast_nullable_to_non_nullable
as int,trashEnabled: null == trashEnabled ? _self.trashEnabled : trashEnabled // ignore: cast_nullable_to_non_nullable
as bool,searchContentEnabled: null == searchContentEnabled ? _self.searchContentEnabled : searchContentEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrEnabled: null == ocrEnabled ? _self.ocrEnabled : ocrEnabled // ignore: cast_nullable_to_non_nullable
as bool,ocrLanguages: null == ocrLanguages ? _self._ocrLanguages : ocrLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,ocrMaxPages: null == ocrMaxPages ? _self.ocrMaxPages : ocrMaxPages // ignore: cast_nullable_to_non_nullable
as int,instanceName: null == instanceName ? _self.instanceName : instanceName // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as Color?,versionsEnabled: null == versionsEnabled ? _self.versionsEnabled : versionsEnabled // ignore: cast_nullable_to_non_nullable
as bool,versionsKeepAllHours: null == versionsKeepAllHours ? _self.versionsKeepAllHours : versionsKeepAllHours // ignore: cast_nullable_to_non_nullable
as int,versionsMaxAgeDays: null == versionsMaxAgeDays ? _self.versionsMaxAgeDays : versionsMaxAgeDays // ignore: cast_nullable_to_non_nullable
as int,versionsMaxPerFile: null == versionsMaxPerFile ? _self.versionsMaxPerFile : versionsMaxPerFile // ignore: cast_nullable_to_non_nullable
as int,federationEnabled: null == federationEnabled ? _self.federationEnabled : federationEnabled // ignore: cast_nullable_to_non_nullable
as bool,smtpHost: null == smtpHost ? _self.smtpHost : smtpHost // ignore: cast_nullable_to_non_nullable
as String,smtpPort: null == smtpPort ? _self.smtpPort : smtpPort // ignore: cast_nullable_to_non_nullable
as int,smtpUsername: null == smtpUsername ? _self.smtpUsername : smtpUsername // ignore: cast_nullable_to_non_nullable
as String,smtpPasswordSet: null == smtpPasswordSet ? _self.smtpPasswordSet : smtpPasswordSet // ignore: cast_nullable_to_non_nullable
as bool,smtpFrom: null == smtpFrom ? _self.smtpFrom : smtpFrom // ignore: cast_nullable_to_non_nullable
as String,smtpSecurity: null == smtpSecurity ? _self.smtpSecurity : smtpSecurity // ignore: cast_nullable_to_non_nullable
as MailSecurity,smtpManagedByConfig: null == smtpManagedByConfig ? _self.smtpManagedByConfig : smtpManagedByConfig // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
