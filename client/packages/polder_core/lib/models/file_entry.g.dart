// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileEntry _$FileEntryFromJson(Map<String, dynamic> json) => _FileEntry(
  id: (json['id'] as num?)?.toInt() ?? 0,
  path: json['path'] as String,
  name: json['name'] as String,
  isDir: json['isDir'] as bool? ?? false,
  size: (json['size'] as num?)?.toInt() ?? 0,
  mtime: DateTime.parse(json['mtime'] as String),
  rev: (json['rev'] as num?)?.toInt() ?? 0,
  hash: json['hash'] as String? ?? "",
  mime: json['mime'] as String? ?? "",
  meta: json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  previewState:
      $enumDecodeNullable(_$PreviewStateEnumMap, json['previewState'], unknownValue: PreviewState.none) ??
      PreviewState.none,
  mount: json['mount'] == null ? null : FileMount.fromJson(json['mount'] as Map<String, dynamic>),
  sharedByYou: json['sharedByYou'] as bool? ?? false,
  tagIds: (json['tagIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const <int>[],
  otherTags: (json['otherTags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
);

Map<String, dynamic> _$FileEntryToJson(_FileEntry instance) => <String, dynamic>{
  'id': instance.id,
  'path': instance.path,
  'name': instance.name,
  'isDir': instance.isDir,
  'size': instance.size,
  'mtime': instance.mtime.toIso8601String(),
  'rev': instance.rev,
  'hash': instance.hash,
  'mime': instance.mime,
  'meta': instance.meta,
  'previewState': _$PreviewStateEnumMap[instance.previewState]!,
  'mount': ?instance.mount?.toJson(),
  'sharedByYou': instance.sharedByYou,
  'tagIds': instance.tagIds,
  'otherTags': instance.otherTags,
};

const _$PreviewStateEnumMap = {
  PreviewState.none: 'none',
  PreviewState.pending: 'pending',
  PreviewState.ready: 'ready',
  PreviewState.failed: 'failed',
};
