// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServerImage _$ServerImageFromJson(Map<String, dynamic> json) =>
    _ServerImage(id: json['id'] as String, contentType: json['contentType'] as String);

Map<String, dynamic> _$ServerImageToJson(_ServerImage instance) => <String, dynamic>{
  'id': instance.id,
  'contentType': instance.contentType,
};

_AuthProviderOption _$AuthProviderOptionFromJson(Map<String, dynamic> json) =>
    _AuthProviderOption(id: json['id'] as String, label: json['label'] as String, icon: json['icon'] as String? ?? "");

Map<String, dynamic> _$AuthProviderOptionToJson(_AuthProviderOption instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'icon': instance.icon,
};

_Branding _$BrandingFromJson(Map<String, dynamic> json) => _Branding(
  serverUrl: json['serverUrl'] as String?,
  name: json['name'] as String? ?? "",
  message: json['message'] as String? ?? "",
  accent: _$JsonConverterFromJson<int, Color>(json['accent'], const ColorConverter().fromJson),
  icon: json['icon'] == null ? null : ServerImage.fromJson(json['icon'] as Map<String, dynamic>),
  backgrounds:
      (json['backgrounds'] as List<dynamic>?)?.map((e) => ServerImage.fromJson(e as Map<String, dynamic>)).toList() ??
      const <ServerImage>[],
  passwordReset: json['passwordReset'] as bool? ?? false,
  authProviders:
      (json['authProviders'] as List<dynamic>?)
          ?.map((e) => AuthProviderOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AuthProviderOption>[],
);

Map<String, dynamic> _$BrandingToJson(_Branding instance) => <String, dynamic>{
  'serverUrl': ?instance.serverUrl,
  'name': instance.name,
  'message': instance.message,
  'accent': ?_$JsonConverterToJson<int, Color>(instance.accent, const ColorConverter().toJson),
  'icon': ?instance.icon?.toJson(),
  'backgrounds': instance.backgrounds.map((e) => e.toJson()).toList(),
  'passwordReset': instance.passwordReset,
  'authProviders': instance.authProviders.map((e) => e.toJson()).toList(),
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);
