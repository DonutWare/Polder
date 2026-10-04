// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChunkRef _$ChunkRefFromJson(Map<String, dynamic> json) => _ChunkRef(
  hash: json['hash'] as String,
  offset: (json['offset'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$ChunkRefToJson(_ChunkRef instance) => <String, dynamic>{
  'hash': instance.hash,
  'offset': instance.offset,
  'size': instance.size,
};

_Manifest _$ManifestFromJson(Map<String, dynamic> json) => _Manifest(
  path: json['path'] as String? ?? "",
  rev: (json['rev'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num).toInt(),
  hash: json['hash'] as String,
  chunks:
      (json['chunks'] as List<dynamic>?)
          ?.map((e) => ChunkRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChunkRef>[],
);

Map<String, dynamic> _$ManifestToJson(_Manifest instance) => <String, dynamic>{
  'path': instance.path,
  'rev': instance.rev,
  'size': instance.size,
  'hash': instance.hash,
  'chunks': instance.chunks.map((e) => e.toJson()).toList(),
};
