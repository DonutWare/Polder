// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(Map<String, dynamic> json) => _NotificationPreferences(
  enabled: json['enabled'] as bool? ?? false,
  shares: json['shares'] as bool? ?? true,
  calendarReminders: json['calendarReminders'] as bool? ?? true,
  autoUploadProgress: json['autoUploadProgress'] as bool? ?? true,
  autoUploadSummary: json['autoUploadSummary'] as bool? ?? true,
  autoUploadCheck: json['autoUploadCheck'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationPreferencesToJson(_NotificationPreferences instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'shares': instance.shares,
  'calendarReminders': instance.calendarReminders,
  'autoUploadProgress': instance.autoUploadProgress,
  'autoUploadSummary': instance.autoUploadSummary,
  'autoUploadCheck': instance.autoUploadCheck,
};
