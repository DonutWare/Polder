// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_upload_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AutoUploadSettings _$AutoUploadSettingsFromJson(Map<String, dynamic> json) =>
    _AutoUploadSettings(
      enabled: json['enabled'] as bool? ?? false,
      wifiOnly: json['wifiOnly'] as bool? ?? true,
      chargingOnly: json['chargingOnly'] as bool? ?? false,
    );

Map<String, dynamic> _$AutoUploadSettingsToJson(_AutoUploadSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'wifiOnly': instance.wifiOnly,
      'chargingOnly': instance.chargingOnly,
    };
