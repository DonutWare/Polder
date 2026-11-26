// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxError _$OutboxErrorFromJson(Map<String, dynamic> json) =>
    _OutboxError(kind: $enumDecode(_$OutboxErrorKindEnumMap, json['kind']), message: json['message'] as String? ?? "");

Map<String, dynamic> _$OutboxErrorToJson(_OutboxError instance) => <String, dynamic>{
  'kind': _$OutboxErrorKindEnumMap[instance.kind]!,
  'message': instance.message,
};

const _$OutboxErrorKindEnumMap = {
  OutboxErrorKind.unreachable: 'unreachable',
  OutboxErrorKind.timedOut: 'timedOut',
  OutboxErrorKind.serverError: 'serverError',
  OutboxErrorKind.storageFull: 'storageFull',
  OutboxErrorKind.deviceFull: 'deviceFull',
  OutboxErrorKind.serverDidNotStore: 'serverDidNotStore',
  OutboxErrorKind.quota: 'quota',
  OutboxErrorKind.conflict: 'conflict',
  OutboxErrorKind.forbidden: 'forbidden',
  OutboxErrorKind.notFound: 'notFound',
  OutboxErrorKind.rejected: 'rejected',
};

PutOp _$PutOpFromJson(Map<String, dynamic> json) => PutOp(
  path: json['path'] as String,
  hash: json['hash'] as String,
  size: (json['size'] as num).toInt(),
  $type: json['op'] as String?,
);

Map<String, dynamic> _$PutOpToJson(PutOp instance) => <String, dynamic>{
  'path': instance.path,
  'hash': instance.hash,
  'size': instance.size,
  'op': instance.$type,
};

MoveOp _$MoveOpFromJson(Map<String, dynamic> json) =>
    MoveOp(from: json['from'] as String, to: json['to'] as String, $type: json['op'] as String?);

Map<String, dynamic> _$MoveOpToJson(MoveOp instance) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'op': instance.$type,
};

DeleteOp _$DeleteOpFromJson(Map<String, dynamic> json) => DeleteOp(
  path: json['path'] as String,
  baseRev: (json['baseRev'] as num?)?.toInt() ?? -1,
  $type: json['op'] as String?,
);

Map<String, dynamic> _$DeleteOpToJson(DeleteOp instance) => <String, dynamic>{
  'path': instance.path,
  'baseRev': instance.baseRev,
  'op': instance.$type,
};

CalendarOp _$CalendarOpFromJson(Map<String, dynamic> json) => CalendarOp(
  eventKey: json['eventKey'] as String,
  change: json['change'] as Map<String, dynamic>,
  $type: json['op'] as String?,
);

Map<String, dynamic> _$CalendarOpToJson(CalendarOp instance) => <String, dynamic>{
  'eventKey': instance.eventKey,
  'change': instance.change,
  'op': instance.$type,
};

_OfflinePin _$OfflinePinFromJson(Map<String, dynamic> json) => _OfflinePin(
  path: json['path'] as String,
  kind: $enumDecode(_$OfflinePinKindEnumMap, json['kind']),
  populated: json['populated'] as bool? ?? false,
);

Map<String, dynamic> _$OfflinePinToJson(_OfflinePin instance) => <String, dynamic>{
  'path': instance.path,
  'kind': _$OfflinePinKindEnumMap[instance.kind]!,
  'populated': instance.populated,
};

const _$OfflinePinKindEnumMap = {
  OfflinePinKind.notes: 'notes',
  OfflinePinKind.user: 'user',
  OfflinePinKind.excluded: 'excluded',
};

_OfflineConflict _$OfflineConflictFromJson(Map<String, dynamic> json) => _OfflineConflict(
  server: json['server'] == null ? null : FileEntry.fromJson(json['server'] as Map<String, dynamic>),
  deletedHere: json['deletedHere'] as bool? ?? false,
  detectedAt: DateTime.parse(json['detectedAt'] as String),
);

Map<String, dynamic> _$OfflineConflictToJson(_OfflineConflict instance) => <String, dynamic>{
  'server': ?instance.server?.toJson(),
  'deletedHere': instance.deletedHere,
  'detectedAt': instance.detectedAt.toIso8601String(),
};

_OfflineFile _$OfflineFileFromJson(Map<String, dynamic> json) => _OfflineFile(
  entry: FileEntry.fromJson(json['entry'] as Map<String, dynamic>),
  baseRev: (json['baseRev'] as num?)?.toInt() ?? 0,
  baseHash: json['baseHash'] as String? ?? "",
  localHash: json['localHash'] as String?,
  state: $enumDecodeNullable(_$OfflineFileStateEnumMap, json['state']) ?? OfflineFileState.synced,
  conflict: json['conflict'] == null ? null : OfflineConflict.fromJson(json['conflict'] as Map<String, dynamic>),
  error: json['error'] == null ? null : OutboxError.fromJson(json['error'] as Map<String, dynamic>),
  transient: json['transient'] as bool? ?? false,
);

Map<String, dynamic> _$OfflineFileToJson(_OfflineFile instance) => <String, dynamic>{
  'entry': instance.entry.toJson(),
  'baseRev': instance.baseRev,
  'baseHash': instance.baseHash,
  'localHash': ?instance.localHash,
  'state': _$OfflineFileStateEnumMap[instance.state]!,
  'conflict': ?instance.conflict?.toJson(),
  'error': ?instance.error?.toJson(),
  'transient': instance.transient,
};

const _$OfflineFileStateEnumMap = {
  OfflineFileState.synced: 'synced',
  OfflineFileState.pending: 'pending',
  OfflineFileState.conflict: 'conflict',
  OfflineFileState.failed: 'failed',
};
