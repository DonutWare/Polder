// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncEntry _$SyncEntryFromJson(Map<String, dynamic> json) => _SyncEntry(
  syncRootId: json['syncRootId'] as String,
  relativePath: json['relativePath'] as String,
  isDir: json['isDir'] as bool? ?? false,
  localHash: json['localHash'] as String?,
  localSize: (json['localSize'] as num?)?.toInt(),
  localMtime: json['localMtime'] == null ? null : DateTime.parse(json['localMtime'] as String),
  syncedRev: (json['syncedRev'] as num?)?.toInt() ?? 0,
  syncedHash: json['syncedHash'] as String? ?? "",
  manifestJson: json['manifestJson'] as String?,
  state: $enumDecodeNullable(_$EntryStateEnumMap, json['state']) ?? EntryState.hydrated,
);

Map<String, dynamic> _$SyncEntryToJson(_SyncEntry instance) => <String, dynamic>{
  'syncRootId': instance.syncRootId,
  'relativePath': instance.relativePath,
  'isDir': instance.isDir,
  'localHash': ?instance.localHash,
  'localSize': ?instance.localSize,
  'localMtime': ?instance.localMtime?.toIso8601String(),
  'syncedRev': instance.syncedRev,
  'syncedHash': instance.syncedHash,
  'manifestJson': ?instance.manifestJson,
  'state': _$EntryStateEnumMap[instance.state]!,
};

const _$EntryStateEnumMap = {
  EntryState.placeholder: 'placeholder',
  EntryState.hydrating: 'hydrating',
  EntryState.hydrated: 'hydrated',
  EntryState.pinned: 'pinned',
  EntryState.dirty: 'dirty',
};
