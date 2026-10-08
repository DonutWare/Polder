// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_root.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncRoot _$SyncRootFromJson(Map<String, dynamic> json) => _SyncRoot(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  localPath: json['localPath'] as String,
  remotePath: json['remotePath'] as String,
  mode: $enumDecodeNullable(_$SyncModeEnumMap, json['mode']) ?? SyncMode.sync,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$SyncRootToJson(_SyncRoot instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'localPath': instance.localPath,
  'remotePath': instance.remotePath,
  'mode': _$SyncModeEnumMap[instance.mode]!,
  'enabled': instance.enabled,
};

const _$SyncModeEnumMap = {SyncMode.sync: 'sync', SyncMode.autoUpload: 'autoUpload'};
