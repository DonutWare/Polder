// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    _CreateUserRequest(
      username: json['username'] as String,
      password: json['password'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      quotaBytes: (json['quotaBytes'] as num).toInt(),
    );

Map<String, dynamic> _$CreateUserRequestToJson(_CreateUserRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'role': _$UserRoleEnumMap[instance.role]!,
      'quotaBytes': instance.quotaBytes,
    };

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.user: 'user'};

_UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    _UpdateUserRequest(
      password: json['password'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      quotaBytes: (json['quotaBytes'] as num?)?.toInt(),
      disabled: json['disabled'] as bool?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(_UpdateUserRequest instance) =>
    <String, dynamic>{
      'password': ?instance.password,
      'role': ?_$UserRoleEnumMap[instance.role],
      'quotaBytes': ?instance.quotaBytes,
      'disabled': ?instance.disabled,
    };
