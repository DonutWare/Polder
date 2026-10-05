// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  serverUrl: json['serverUrl'] as String,
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'serverUrl': instance.serverUrl,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'user': instance.user.toJson(),
};
