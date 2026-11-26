// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_file_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalFileState _$LocalFileStateFromJson(Map<String, dynamic> json) => _LocalFileState(
  relativePath: json['relativePath'] as String,
  isDir: json['isDir'] as bool? ?? false,
  size: (json['size'] as num?)?.toInt() ?? 0,
  mtime: DateTime.parse(json['mtime'] as String),
  hash: json['hash'] as String? ?? "",
);

Map<String, dynamic> _$LocalFileStateToJson(_LocalFileState instance) => <String, dynamic>{
  'relativePath': instance.relativePath,
  'isDir': instance.isDir,
  'size': instance.size,
  'mtime': instance.mtime.toIso8601String(),
  'hash': instance.hash,
};
