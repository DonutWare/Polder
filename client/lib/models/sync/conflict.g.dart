// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conflict _$ConflictFromJson(Map<String, dynamic> json) => _Conflict(
  syncRootId: json['syncRootId'] as String,
  relativePath: json['relativePath'] as String,
  kind: $enumDecode(_$ConflictKindEnumMap, json['kind']),
  local: json['local'] == null
      ? null
      : LocalFileState.fromJson(json['local'] as Map<String, dynamic>),
  remote: json['remote'] == null
      ? null
      : FileEntry.fromJson(json['remote'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConflictToJson(_Conflict instance) => <String, dynamic>{
  'syncRootId': instance.syncRootId,
  'relativePath': instance.relativePath,
  'kind': _$ConflictKindEnumMap[instance.kind]!,
  'local': ?instance.local?.toJson(),
  'remote': ?instance.remote?.toJson(),
};

const _$ConflictKindEnumMap = {
  ConflictKind.bothModified: 'bothModified',
  ConflictKind.bothCreated: 'bothCreated',
  ConflictKind.localModifiedRemoteDeleted: 'localModifiedRemoteDeleted',
  ConflictKind.localDeletedRemoteModified: 'localDeletedRemoteModified',
};
