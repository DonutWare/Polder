// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Change _$ChangeFromJson(Map<String, dynamic> json) => _Change(
  seq: (json['seq'] as num).toInt(),
  type: $enumDecode(_$ChangeTypeEnumMap, json['type']),
  path: json['path'] as String,
  fromPath: json['fromPath'] as String?,
  entry: json['entry'] == null
      ? null
      : FileEntry.fromJson(json['entry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChangeToJson(_Change instance) => <String, dynamic>{
  'seq': instance.seq,
  'type': _$ChangeTypeEnumMap[instance.type]!,
  'path': instance.path,
  'fromPath': ?instance.fromPath,
  'entry': ?instance.entry?.toJson(),
};

const _$ChangeTypeEnumMap = {
  ChangeType.upsert: 'upsert',
  ChangeType.delete: 'delete',
  ChangeType.move: 'move',
};

_ChangeFeedPage _$ChangeFeedPageFromJson(Map<String, dynamic> json) =>
    _ChangeFeedPage(
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map((e) => Change.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Change>[],
      cursor: (json['cursor'] as num).toInt(),
      hasMore: json['hasMore'] as bool? ?? false,
    );

Map<String, dynamic> _$ChangeFeedPageToJson(_ChangeFeedPage instance) =>
    <String, dynamic>{
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'cursor': instance.cursor,
      'hasMore': instance.hasMore,
    };
