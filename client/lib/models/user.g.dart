// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  firstName: json['firstName'] as String? ?? "",
  lastName: json['lastName'] as String? ?? "",
  displayName: json['displayName'] as String? ?? "",
  email: json['email'] as String? ?? "",
  age: (json['age'] as num?)?.toInt(),
  address: json['address'] as String? ?? "",
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'email': instance.email,
      'age': ?instance.age,
      'address': instance.address,
    };

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  role:
      $enumDecodeNullable(
        _$UserRoleEnumMap,
        json['role'],
        unknownValue: UserRole.user,
      ) ??
      UserRole.user,
  quotaBytes: (json['quotaBytes'] as num?)?.toInt() ?? 0,
  usedBytes: (json['usedBytes'] as num?)?.toInt() ?? 0,
  historyBytes: (json['historyBytes'] as num?)?.toInt() ?? 0,
  disabled: json['disabled'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  profile: json['profile'] == null
      ? const UserProfile()
      : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
  avatar: json['avatar'] == null
      ? null
      : ServerImage.fromJson(json['avatar'] as Map<String, dynamic>),
  theme: $enumDecodeNullable(_$ThemeModeEnumMap, json['theme']),
  accent: _$JsonConverterFromJson<int, Color>(
    json['accent'],
    const ColorConverter().fromJson,
  ),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'role': _$UserRoleEnumMap[instance.role]!,
  'quotaBytes': instance.quotaBytes,
  'usedBytes': instance.usedBytes,
  'historyBytes': instance.historyBytes,
  'disabled': instance.disabled,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'profile': instance.profile.toJson(),
  'avatar': ?instance.avatar?.toJson(),
  'theme': ?_$ThemeModeEnumMap[instance.theme],
  'accent': ?_$JsonConverterToJson<int, Color>(
    instance.accent,
    const ColorConverter().toJson,
  ),
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.user: 'user'};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
