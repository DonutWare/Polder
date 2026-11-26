// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SharePermissions _$SharePermissionsFromJson(Map<String, dynamic> json) => _SharePermissions(
  create: json['create'] as bool? ?? false,
  edit: json['edit'] as bool? ?? false,
  delete: json['delete'] as bool? ?? false,
);

Map<String, dynamic> _$SharePermissionsToJson(_SharePermissions instance) => <String, dynamic>{
  'create': instance.create,
  'edit': instance.edit,
  'delete': instance.delete,
};
