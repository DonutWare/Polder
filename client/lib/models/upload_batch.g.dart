// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadChunkSpec _$UploadChunkSpecFromJson(Map<String, dynamic> json) =>
    _UploadChunkSpec(hash: json['hash'] as String, size: (json['size'] as num).toInt());

Map<String, dynamic> _$UploadChunkSpecToJson(_UploadChunkSpec instance) => <String, dynamic>{
  'hash': instance.hash,
  'size': instance.size,
};

_UploadRequest _$UploadRequestFromJson(Map<String, dynamic> json) => _UploadRequest(
  path: json['path'] as String,
  baseRev: (json['baseRev'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  hash: json['hash'] as String,
  mtime: DateTime.parse(json['mtime'] as String),
  chunks: (json['chunks'] as List<dynamic>).map((e) => UploadChunkSpec.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$UploadRequestToJson(_UploadRequest instance) => <String, dynamic>{
  'path': instance.path,
  'baseRev': instance.baseRev,
  'size': instance.size,
  'hash': instance.hash,
  'mtime': instance.mtime.toIso8601String(),
  'chunks': instance.chunks.map((e) => e.toJson()).toList(),
};
