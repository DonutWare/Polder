// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role'], unknownValue: UserRole.user) ?? UserRole.user,
  quotaBytes: (json['quotaBytes'] as num?)?.toInt() ?? 0,
  usedBytes: (json['usedBytes'] as num?)?.toInt() ?? 0,
  disabled: json['disabled'] as bool? ?? false,
  createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'role': _$UserRoleEnumMap[instance.role]!,
  'quotaBytes': instance.quotaBytes,
  'usedBytes': instance.usedBytes,
  'disabled': instance.disabled,
  'createdAt': ?instance.createdAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.user: 'user'};
