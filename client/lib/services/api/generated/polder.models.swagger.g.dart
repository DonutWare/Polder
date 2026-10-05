// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polder.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Change _$ChangeFromJson(Map<String, dynamic> json) => Change(
  entry: json['entry'] == null ? null : Entry.fromJson(json['entry'] as Map<String, dynamic>),
  fromPath: json['fromPath'] as String?,
  path: json['path'] as String,
  seq: (json['seq'] as num).toInt(),
  type: changeTypeFromJson(json['type']),
);

Map<String, dynamic> _$ChangeToJson(Change instance) => <String, dynamic>{
  'entry': ?instance.entry?.toJson(),
  'fromPath': ?instance.fromPath,
  'path': instance.path,
  'seq': instance.seq,
  'type': ?changeTypeToJson(instance.type),
};

ChangePage _$ChangePageFromJson(Map<String, dynamic> json) => ChangePage(
  changes: (json['changes'] as List<dynamic>?)?.map((e) => Change.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  cursor: (json['cursor'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$ChangePageToJson(ChangePage instance) => <String, dynamic>{
  'changes': ?instance.changes?.map((e) => e.toJson()).toList(),
  'cursor': instance.cursor,
  'hasMore': instance.hasMore,
};

Changes _$ChangesFromJson(Map<String, dynamic> json) => Changes(
  disabled: json['disabled'] as bool?,
  password: json['password'] as String?,
  quotaBytes: (json['quotaBytes'] as num?)?.toInt(),
  role: changesRoleNullableFromJson(json['role']),
  trashRetentionOverrideDays: (json['trashRetentionOverrideDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChangesToJson(Changes instance) => <String, dynamic>{
  'disabled': ?instance.disabled,
  'password': ?instance.password,
  'quotaBytes': ?instance.quotaBytes,
  'role': ?changesRoleNullableToJson(instance.role),
  'trashRetentionOverrideDays': ?instance.trashRetentionOverrideDays,
};

Chunk _$ChunkFromJson(Map<String, dynamic> json) =>
    Chunk(hash: json['hash'] as String, offset: (json['offset'] as num).toInt(), size: (json['size'] as num).toInt());

Map<String, dynamic> _$ChunkToJson(Chunk instance) => <String, dynamic>{
  'hash': instance.hash,
  'offset': instance.offset,
  'size': instance.size,
};

ChunkRef _$ChunkRefFromJson(Map<String, dynamic> json) =>
    ChunkRef(hash: json['hash'] as String, size: (json['size'] as num).toInt());

Map<String, dynamic> _$ChunkRefToJson(ChunkRef instance) => <String, dynamic>{
  'hash': instance.hash,
  'size': instance.size,
};

ClientMessage _$ClientMessageFromJson(Map<String, dynamic> json) => ClientMessage(
  scope: clientMessageScopeNullableFromJson(json['scope']),
  token: json['token'] as String?,
  type: clientMessageTypeFromJson(json['type']),
  userId: (json['userId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ClientMessageToJson(ClientMessage instance) => <String, dynamic>{
  'scope': ?clientMessageScopeNullableToJson(instance.scope),
  'token': ?instance.token,
  'type': ?clientMessageTypeToJson(instance.type),
  'userId': ?instance.userId,
};

CredentialsRequest _$CredentialsRequestFromJson(Map<String, dynamic> json) => CredentialsRequest(
  deviceName: json['deviceName'] as String?,
  password: json['password'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$CredentialsRequestToJson(CredentialsRequest instance) => <String, dynamic>{
  'deviceName': ?instance.deviceName,
  'password': instance.password,
  'username': instance.username,
};

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  hash: json['hash'] as String,
  isDir: json['isDir'] as bool,
  meta: json['meta'] as Map<String, dynamic>,
  mime: json['mime'] as String,
  mtime: DateTime.parse(json['mtime'] as String),
  name: json['name'] as String,
  path: json['path'] as String,
  previewState: entryPreviewStateFromJson(json['previewState']),
  rev: (json['rev'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'hash': instance.hash,
  'isDir': instance.isDir,
  'meta': instance.meta,
  'mime': instance.mime,
  'mtime': instance.mtime.toIso8601String(),
  'name': instance.name,
  'path': instance.path,
  'previewState': ?entryPreviewStateToJson(instance.previewState),
  'rev': instance.rev,
  'size': instance.size,
};

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) =>
    ErrorDetail(code: json['code'] as String, message: json['message'] as String);

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(current: json['current'], error: ErrorDetail.fromJson(json['error'] as Map<String, dynamic>));

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) => <String, dynamic>{
  'current': ?instance.current,
  'error': instance.error.toJson(),
};

EventMessage _$EventMessageFromJson(Map<String, dynamic> json) => EventMessage(
  code: json['code'] as String?,
  dirs: (json['dirs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  entry: json['entry'] == null ? null : LogEntry.fromJson(json['entry'] as Map<String, dynamic>),
  message: json['message'] as String?,
  status: eventMessageStatusNullableFromJson(json['status']),
  transfer: json['transfer'] == null ? null : LiveTransfer.fromJson(json['transfer'] as Map<String, dynamic>),
  transfers:
      (json['transfers'] as List<dynamic>?)?.map((e) => LiveTransfer.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
  type: eventMessageTypeFromJson(json['type']),
  user: json['user'] == null ? null : User.fromJson(json['user'] as Map<String, dynamic>),
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$EventMessageToJson(EventMessage instance) => <String, dynamic>{
  'code': ?instance.code,
  'dirs': ?instance.dirs,
  'entry': ?instance.entry?.toJson(),
  'message': ?instance.message,
  'status': ?eventMessageStatusNullableToJson(instance.status),
  'transfer': ?instance.transfer?.toJson(),
  'transfers': ?instance.transfers?.map((e) => e.toJson()).toList(),
  'type': ?eventMessageTypeToJson(instance.type),
  'user': ?instance.user?.toJson(),
  'userId': instance.userId,
};

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) => HealthStatus(status: json['status'] as String);

Map<String, dynamic> _$HealthStatusToJson(HealthStatus instance) => <String, dynamic>{'status': instance.status};

ListResponse _$ListResponseFromJson(Map<String, dynamic> json) => ListResponse(
  entries: (json['entries'] as List<dynamic>?)?.map((e) => Entry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  path: json['path'] as String,
);

Map<String, dynamic> _$ListResponseToJson(ListResponse instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'path': instance.path,
};

LiveTransfer _$LiveTransferFromJson(Map<String, dynamic> json) => LiveTransfer(
  bytes: (json['bytes'] as num).toInt(),
  clientId: json['clientId'] as String?,
  device: json['device'] as String,
  direction: liveTransferDirectionFromJson(json['direction']),
  id: json['id'] as String,
  path: json['path'] as String,
  rate: (json['rate'] as num).toInt(),
  startedAt: DateTime.parse(json['startedAt'] as String),
  total: (json['total'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$LiveTransferToJson(LiveTransfer instance) => <String, dynamic>{
  'bytes': instance.bytes,
  'clientId': ?instance.clientId,
  'device': instance.device,
  'direction': ?liveTransferDirectionToJson(instance.direction),
  'id': instance.id,
  'path': instance.path,
  'rate': instance.rate,
  'startedAt': instance.startedAt.toIso8601String(),
  'total': ?instance.total,
  'userId': instance.userId,
  'username': instance.username,
};

LiveTransfers _$LiveTransfersFromJson(Map<String, dynamic> json) => LiveTransfers(
  transfers:
      (json['transfers'] as List<dynamic>?)?.map((e) => LiveTransfer.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
);

Map<String, dynamic> _$LiveTransfersToJson(LiveTransfers instance) => <String, dynamic>{
  'transfers': ?instance.transfers?.map((e) => e.toJson()).toList(),
};

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
  bytes: (json['bytes'] as num?)?.toInt(),
  count: (json['count'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  detail: json['detail'] as String,
  device: json['device'] as String,
  durationMs: (json['durationMs'] as num?)?.toInt(),
  fromPath: json['fromPath'] as String?,
  id: (json['id'] as num).toInt(),
  isDir: json['isDir'] as bool,
  kind: logEntryKindFromJson(json['kind']),
  path: json['path'] as String,
  size: (json['size'] as num?)?.toInt(),
  status: logEntryStatusFromJson(json['status']),
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
  'bytes': ?instance.bytes,
  'count': ?instance.count,
  'createdAt': instance.createdAt.toIso8601String(),
  'detail': instance.detail,
  'device': instance.device,
  'durationMs': ?instance.durationMs,
  'fromPath': ?instance.fromPath,
  'id': instance.id,
  'isDir': instance.isDir,
  'kind': ?logEntryKindToJson(instance.kind),
  'path': instance.path,
  'size': ?instance.size,
  'status': ?logEntryStatusToJson(instance.status),
  'userId': instance.userId,
  'username': instance.username,
};

LogPage _$LogPageFromJson(Map<String, dynamic> json) => LogPage(
  entries: (json['entries'] as List<dynamic>?)?.map((e) => LogEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  nextCursor: (json['nextCursor'] as num).toInt(),
);

Map<String, dynamic> _$LogPageToJson(LogPage instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'nextCursor': instance.nextCursor,
};

Manifest _$ManifestFromJson(Map<String, dynamic> json) => Manifest(
  chunks: (json['chunks'] as List<dynamic>?)?.map((e) => Chunk.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  hash: json['hash'] as String,
  path: json['path'] as String,
  rev: (json['rev'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$ManifestToJson(Manifest instance) => <String, dynamic>{
  'chunks': ?instance.chunks?.map((e) => e.toJson()).toList(),
  'hash': instance.hash,
  'path': instance.path,
  'rev': instance.rev,
  'size': instance.size,
};

MoveRequest _$MoveRequestFromJson(Map<String, dynamic> json) =>
    MoveRequest(baseRev: (json['baseRev'] as num?)?.toInt(), from: json['from'] as String, to: json['to'] as String);

Map<String, dynamic> _$MoveRequestToJson(MoveRequest instance) => <String, dynamic>{
  'baseRev': ?instance.baseRev,
  'from': instance.from,
  'to': instance.to,
};

NewUser _$NewUserFromJson(Map<String, dynamic> json) => NewUser(
  password: json['password'] as String,
  quotaBytes: (json['quotaBytes'] as num?)?.toInt(),
  role: newUserRoleFromJson(json['role']),
  username: json['username'] as String,
);

Map<String, dynamic> _$NewUserToJson(NewUser instance) => <String, dynamic>{
  'password': instance.password,
  'quotaBytes': ?instance.quotaBytes,
  'role': ?newUserRoleToJson(instance.role),
  'username': instance.username,
};

PathRequest _$PathRequestFromJson(Map<String, dynamic> json) => PathRequest(path: json['path'] as String);

Map<String, dynamic> _$PathRequestToJson(PathRequest instance) => <String, dynamic>{'path': instance.path};

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(deviceName: json['deviceName'] as String?, refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) => <String, dynamic>{
  'deviceName': ?instance.deviceName,
  'refreshToken': instance.refreshToken,
};

RestoreRequest _$RestoreRequestFromJson(Map<String, dynamic> json) =>
    RestoreRequest(onConflict: RestoreRequest.restoreRequestOnConflictOnConflictNullableFromJson(json['onConflict']));

Map<String, dynamic> _$RestoreRequestToJson(RestoreRequest instance) => <String, dynamic>{
  'onConflict': ?restoreRequestOnConflictNullableToJson(instance.onConflict),
};

RetentionRequest _$RetentionRequestFromJson(Map<String, dynamic> json) =>
    RetentionRequest(days: (json['days'] as num?)?.toInt());

Map<String, dynamic> _$RetentionRequestToJson(RetentionRequest instance) => <String, dynamic>{'days': ?instance.days};

ServerSettings _$ServerSettingsFromJson(Map<String, dynamic> json) => ServerSettings(
  trashRetentionDays: (json['trashRetentionDays'] as num).toInt(),
  trashRetentionEnforced: json['trashRetentionEnforced'] as bool,
);

Map<String, dynamic> _$ServerSettingsToJson(ServerSettings instance) => <String, dynamic>{
  'trashRetentionDays': instance.trashRetentionDays,
  'trashRetentionEnforced': instance.trashRetentionEnforced,
};

ServerSettingsChanges _$ServerSettingsChangesFromJson(Map<String, dynamic> json) => ServerSettingsChanges(
  trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt(),
  trashRetentionEnforced: json['trashRetentionEnforced'] as bool?,
);

Map<String, dynamic> _$ServerSettingsChangesToJson(ServerSettingsChanges instance) => <String, dynamic>{
  'trashRetentionDays': ?instance.trashRetentionDays,
  'trashRetentionEnforced': ?instance.trashRetentionEnforced,
};

SetupStatus _$SetupStatusFromJson(Map<String, dynamic> json) => SetupStatus(needsSetup: json['needsSetup'] as bool);

Map<String, dynamic> _$SetupStatusToJson(SetupStatus instance) => <String, dynamic>{'needsSetup': instance.needsSetup};

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => TokenPair(
  accessToken: json['accessToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
  refreshToken: json['refreshToken'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'expiresIn': instance.expiresIn,
  'refreshToken': instance.refreshToken,
  'user': instance.user.toJson(),
};

TrashItem _$TrashItemFromJson(Map<String, dynamic> json) => TrashItem(
  deletedAt: DateTime.parse(json['deletedAt'] as String),
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  hash: json['hash'] as String,
  id: (json['id'] as num).toInt(),
  isDir: json['isDir'] as bool,
  mime: json['mime'] as String,
  name: json['name'] as String,
  originalPath: json['originalPath'] as String,
  previewState: trashItemPreviewStateFromJson(json['previewState']),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$TrashItemToJson(TrashItem instance) => <String, dynamic>{
  'deletedAt': instance.deletedAt.toIso8601String(),
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'hash': instance.hash,
  'id': instance.id,
  'isDir': instance.isDir,
  'mime': instance.mime,
  'name': instance.name,
  'originalPath': instance.originalPath,
  'previewState': ?trashItemPreviewStateToJson(instance.previewState),
  'size': instance.size,
};

TrashListing _$TrashListingFromJson(Map<String, dynamic> json) => TrashListing(
  items: (json['items'] as List<dynamic>?)?.map((e) => TrashItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  retention: TrashRetention.fromJson(json['retention'] as Map<String, dynamic>),
  totalBytes: (json['totalBytes'] as num).toInt(),
);

Map<String, dynamic> _$TrashListingToJson(TrashListing instance) => <String, dynamic>{
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
  'retention': instance.retention.toJson(),
  'totalBytes': instance.totalBytes,
};

TrashRetention _$TrashRetentionFromJson(Map<String, dynamic> json) => TrashRetention(
  days: (json['days'] as num).toInt(),
  defaultDays: (json['defaultDays'] as num).toInt(),
  locked: json['locked'] as bool,
  source: trashRetentionSourceFromJson(json['source']),
  userDays: (json['userDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrashRetentionToJson(TrashRetention instance) => <String, dynamic>{
  'days': instance.days,
  'defaultDays': instance.defaultDays,
  'locked': instance.locked,
  'source': ?trashRetentionSourceToJson(instance.source),
  'userDays': ?instance.userDays,
};

UploadRequest _$UploadRequestFromJson(Map<String, dynamic> json) => UploadRequest(
  baseRev: (json['baseRev'] as num?)?.toInt(),
  chunks: (json['chunks'] as List<dynamic>?)?.map((e) => ChunkRef.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  hash: json['hash'] as String,
  mtime: json['mtime'] == null ? null : DateTime.parse(json['mtime'] as String),
  path: json['path'] as String,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$UploadRequestToJson(UploadRequest instance) => <String, dynamic>{
  'baseRev': ?instance.baseRev,
  'chunks': ?instance.chunks?.map((e) => e.toJson()).toList(),
  'hash': instance.hash,
  'mtime': ?instance.mtime?.toIso8601String(),
  'path': instance.path,
  'size': instance.size,
};

UploadStatus _$UploadStatusFromJson(Map<String, dynamic> json) => UploadStatus(
  missing: (json['missing'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  uploadId: json['uploadId'] as String,
);

Map<String, dynamic> _$UploadStatusToJson(UploadStatus instance) => <String, dynamic>{
  'missing': ?instance.missing,
  'uploadId': instance.uploadId,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  createdAt: DateTime.parse(json['createdAt'] as String),
  disabled: json['disabled'] as bool,
  id: (json['id'] as num).toInt(),
  quotaBytes: (json['quotaBytes'] as num).toInt(),
  role: userRoleFromJson(json['role']),
  trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt(),
  trashRetentionOverrideDays: (json['trashRetentionOverrideDays'] as num?)?.toInt(),
  usedBytes: (json['usedBytes'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'disabled': instance.disabled,
  'id': instance.id,
  'quotaBytes': instance.quotaBytes,
  'role': ?userRoleToJson(instance.role),
  'trashRetentionDays': ?instance.trashRetentionDays,
  'trashRetentionOverrideDays': ?instance.trashRetentionOverrideDays,
  'usedBytes': instance.usedBytes,
  'username': instance.username,
};
