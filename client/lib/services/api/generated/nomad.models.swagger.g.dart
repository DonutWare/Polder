// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nomad.models.swagger.dart';

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
);

Map<String, dynamic> _$ChangesToJson(Changes instance) => <String, dynamic>{
  'disabled': ?instance.disabled,
  'password': ?instance.password,
  'quotaBytes': ?instance.quotaBytes,
  'role': ?changesRoleNullableToJson(instance.role),
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
    RefreshRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) => <String, dynamic>{
  'refreshToken': instance.refreshToken,
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
  usedBytes: (json['usedBytes'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'disabled': instance.disabled,
  'id': instance.id,
  'quotaBytes': instance.quotaBytes,
  'role': ?userRoleToJson(instance.role),
  'usedBytes': instance.usedBytes,
  'username': instance.username,
};
