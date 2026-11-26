// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_mount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileMount _$FileMountFromJson(Map<String, dynamic> json) => _FileMount(
  kind: $enumDecode(_$FileMountKindEnumMap, json['kind']),
  shareId: (json['shareId'] as num).toInt(),
  path: json['path'] as String,
  isDir: json['isDir'] as bool? ?? true,
  owner: json['owner'] as String,
  ownerName: json['ownerName'] as String? ?? "",
  server: json['server'] as String? ?? "",
  provider: json['provider'] as String? ?? "",
  groups: (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  permissions: json['permissions'] == null
      ? SharePermissions.viewOnly
      : SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  canLeave: json['canLeave'] as bool? ?? false,
  note: json['note'] as String? ?? "",
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  sharedAt: DateTime.parse(json['sharedAt'] as String),
);

Map<String, dynamic> _$FileMountToJson(_FileMount instance) => <String, dynamic>{
  'kind': _$FileMountKindEnumMap[instance.kind]!,
  'shareId': instance.shareId,
  'path': instance.path,
  'isDir': instance.isDir,
  'owner': instance.owner,
  'ownerName': instance.ownerName,
  'server': instance.server,
  'provider': instance.provider,
  'groups': instance.groups,
  'permissions': instance.permissions.toJson(),
  'canLeave': instance.canLeave,
  'note': instance.note,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'sharedAt': instance.sharedAt.toIso8601String(),
};

const _$FileMountKindEnumMap = {FileMountKind.share: 'share', FileMountKind.federated: 'federated'};
