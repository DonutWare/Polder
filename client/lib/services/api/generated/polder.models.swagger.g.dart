// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polder.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptInviteRequest _$AcceptInviteRequestFromJson(Map<String, dynamic> json) =>
    AcceptInviteRequest(provider: json['provider'] as String, token: json['token'] as String);

Map<String, dynamic> _$AcceptInviteRequestToJson(AcceptInviteRequest instance) => <String, dynamic>{
  'provider': instance.provider,
  'token': instance.token,
};

AppPassword _$AppPasswordFromJson(Map<String, dynamic> json) => AppPassword(
  createdAt: DateTime.parse(json['createdAt'] as String),
  id: (json['id'] as num).toInt(),
  lastUsedAddress: json['lastUsedAddress'] as String,
  lastUsedAt: json['lastUsedAt'] == null ? null : DateTime.parse(json['lastUsedAt'] as String),
  name: json['name'] as String,
  readOnly: json['readOnly'] as bool,
);

Map<String, dynamic> _$AppPasswordToJson(AppPassword instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'lastUsedAddress': instance.lastUsedAddress,
  'lastUsedAt': ?instance.lastUsedAt?.toIso8601String(),
  'name': instance.name,
  'readOnly': instance.readOnly,
};

AppPasswordRequest _$AppPasswordRequestFromJson(Map<String, dynamic> json) => AppPasswordRequest(
  currentPassword: json['currentPassword'] as String,
  name: json['name'] as String,
  readOnly: json['readOnly'] as bool?,
);

Map<String, dynamic> _$AppPasswordRequestToJson(AppPasswordRequest instance) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'name': instance.name,
  'readOnly': ?instance.readOnly,
};

Appearance _$AppearanceFromJson(Map<String, dynamic> json) =>
    Appearance(accentColor: json['accentColor'] as String?, theme: appearanceThemeNullableFromJson(json['theme']));

Map<String, dynamic> _$AppearanceToJson(Appearance instance) => <String, dynamic>{
  'accentColor': ?instance.accentColor,
  'theme': ?appearanceThemeNullableToJson(instance.theme),
};

Avatar _$AvatarFromJson(Map<String, dynamic> json) =>
    Avatar(contentType: json['contentType'] as String, id: json['id'] as String);

Map<String, dynamic> _$AvatarToJson(Avatar instance) => <String, dynamic>{
  'contentType': instance.contentType,
  'id': instance.id,
};

BatchRequest _$BatchRequestFromJson(Map<String, dynamic> json) => BatchRequest(
  files:
      (json['files'] as List<dynamic>?)?.map((e) => UploadRequest.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$BatchRequestToJson(BatchRequest instance) => <String, dynamic>{
  'files': ?instance.files?.map((e) => e.toJson()).toList(),
};

BatchStatus _$BatchStatusFromJson(Map<String, dynamic> json) => BatchStatus(
  batchId: json['batchId'] as String,
  missing: (json['missing'] as List<dynamic>?)?.map((e) => ChunkRef.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  results:
      (json['results'] as List<dynamic>?)?.map((e) => FileResult.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$BatchStatusToJson(BatchStatus instance) => <String, dynamic>{
  'batchId': instance.batchId,
  'missing': ?instance.missing?.map((e) => e.toJson()).toList(),
  'results': ?instance.results?.map((e) => e.toJson()).toList(),
};

Branding _$BrandingFromJson(Map<String, dynamic> json) => Branding(
  accentColor: json['accentColor'] as String,
  backgrounds:
      (json['backgrounds'] as List<dynamic>?)?.map((e) => ImageInfo.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  icon: json['icon'] == null ? null : ImageInfo.fromJson(json['icon'] as Map<String, dynamic>),
  message: json['message'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$BrandingToJson(Branding instance) => <String, dynamic>{
  'accentColor': instance.accentColor,
  'backgrounds': ?instance.backgrounds?.map((e) => e.toJson()).toList(),
  'icon': ?instance.icon?.toJson(),
  'message': instance.message,
  'name': instance.name,
};

Change _$ChangeFromJson(Map<String, dynamic> json) => Change(
  entry: json['entry'] == null ? null : Entry.fromJson(json['entry'] as Map<String, dynamic>),
  fileId: (json['fileId'] as num?)?.toInt(),
  fromPath: json['fromPath'] as String?,
  path: json['path'] as String,
  seq: (json['seq'] as num).toInt(),
  type: changeTypeFromJson(json['type']),
);

Map<String, dynamic> _$ChangeToJson(Change instance) => <String, dynamic>{
  'entry': ?instance.entry?.toJson(),
  'fileId': ?instance.fileId,
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

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
  cloudId: json['cloudId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  email: json['email'] as String,
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  server: json['server'] as String,
);

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
  'cloudId': instance.cloudId,
  'createdAt': instance.createdAt.toIso8601String(),
  'email': instance.email,
  'id': instance.id,
  'name': instance.name,
  'server': instance.server,
};

CopyRequest _$CopyRequestFromJson(Map<String, dynamic> json) =>
    CopyRequest(from: json['from'] as String, to: json['to'] as String);

Map<String, dynamic> _$CopyRequestToJson(CopyRequest instance) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
};

CreatableApp _$CreatableAppFromJson(Map<String, dynamic> json) => CreatableApp(
  app: json['app'] as String,
  extensions: (json['extensions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$CreatableAppToJson(CreatableApp instance) => <String, dynamic>{
  'app': instance.app,
  'extensions': ?instance.extensions,
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

DirectoryResponse _$DirectoryResponseFromJson(Map<String, dynamic> json) => DirectoryResponse(
  groups: (json['groups'] as List<dynamic>?)?.map((e) => Group.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  users: (json['users'] as List<dynamic>?)?.map((e) => UserSummary.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$DirectoryResponseToJson(DirectoryResponse instance) => <String, dynamic>{
  'groups': ?instance.groups?.map((e) => e.toJson()).toList(),
  'users': ?instance.users?.map((e) => e.toJson()).toList(),
};

DownloadFile _$DownloadFileFromJson(Map<String, dynamic> json) =>
    DownloadFile(path: json['path'] as String, rev: (json['rev'] as num?)?.toInt());

Map<String, dynamic> _$DownloadFileToJson(DownloadFile instance) => <String, dynamic>{
  'path': instance.path,
  'rev': ?instance.rev,
};

DownloadRequest _$DownloadRequestFromJson(Map<String, dynamic> json) => DownloadRequest(
  files: (json['files'] as List<dynamic>?)?.map((e) => DownloadFile.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$DownloadRequestToJson(DownloadRequest instance) => <String, dynamic>{
  'files': ?instance.files?.map((e) => e.toJson()).toList(),
};

EditorCapabilities _$EditorCapabilitiesFromJson(Map<String, dynamic> json) => EditorCapabilities(
  creatable:
      (json['creatable'] as List<dynamic>?)?.map((e) => CreatableApp.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
  editableExtensions: (json['editableExtensions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  editableMimes: (json['editableMimes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  enabled: json['enabled'] as bool,
  viewableExtensions: (json['viewableExtensions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  viewableMimes: (json['viewableMimes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$EditorCapabilitiesToJson(EditorCapabilities instance) => <String, dynamic>{
  'creatable': ?instance.creatable?.map((e) => e.toJson()).toList(),
  'editableExtensions': ?instance.editableExtensions,
  'editableMimes': ?instance.editableMimes,
  'enabled': instance.enabled,
  'viewableExtensions': ?instance.viewableExtensions,
  'viewableMimes': ?instance.viewableMimes,
};

EditorSession _$EditorSessionFromJson(Map<String, dynamic> json) => EditorSession(
  accessToken: json['accessToken'] as String,
  accessTokenTtl: (json['accessTokenTtl'] as num).toInt(),
  editorUrl: json['editorUrl'] as String,
  hostPage: json['hostPage'] as String,
  readOnly: json['readOnly'] as bool,
);

Map<String, dynamic> _$EditorSessionToJson(EditorSession instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'accessTokenTtl': instance.accessTokenTtl,
  'editorUrl': instance.editorUrl,
  'hostPage': instance.hostPage,
  'readOnly': instance.readOnly,
};

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  hash: json['hash'] as String,
  id: (json['id'] as num).toInt(),
  isDir: json['isDir'] as bool,
  meta: json['meta'] as Map<String, dynamic>,
  mime: json['mime'] as String,
  mount: json['mount'] == null ? null : Mount.fromJson(json['mount'] as Map<String, dynamic>),
  mtime: DateTime.parse(json['mtime'] as String),
  name: json['name'] as String,
  path: json['path'] as String,
  previewState: entryPreviewStateFromJson(json['previewState']),
  rev: (json['rev'] as num).toInt(),
  shared: json['shared'] as bool?,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'hash': instance.hash,
  'id': instance.id,
  'isDir': instance.isDir,
  'meta': instance.meta,
  'mime': instance.mime,
  'mount': ?instance.mount?.toJson(),
  'mtime': instance.mtime.toIso8601String(),
  'name': instance.name,
  'path': instance.path,
  'previewState': ?entryPreviewStateToJson(instance.previewState),
  'rev': instance.rev,
  'shared': ?instance.shared,
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

ExtractionStatus _$ExtractionStatusFromJson(Map<String, dynamic> json) => ExtractionStatus(
  ocr: extractionStatusOcrFromJson(json['ocr']),
  ocrProblem: json['ocrProblem'] as String?,
  pending: (json['pending'] as num).toInt(),
);

Map<String, dynamic> _$ExtractionStatusToJson(ExtractionStatus instance) => <String, dynamic>{
  'ocr': ?extractionStatusOcrToJson(instance.ocr),
  'ocrProblem': ?instance.ocrProblem,
  'pending': instance.pending,
};

FacetCount _$FacetCountFromJson(Map<String, dynamic> json) =>
    FacetCount(count: (json['count'] as num).toInt(), value: json['value'] as String);

Map<String, dynamic> _$FacetCountToJson(FacetCount instance) => <String, dynamic>{
  'count': instance.count,
  'value': instance.value,
};

Facets _$FacetsFromJson(Map<String, dynamic> json) => Facets(
  exts: (json['exts'] as List<dynamic>?)?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  types: (json['types'] as List<dynamic>?)?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$FacetsToJson(Facets instance) => <String, dynamic>{
  'exts': ?instance.exts?.map((e) => e.toJson()).toList(),
  'types': ?instance.types?.map((e) => e.toJson()).toList(),
};

FederationStatus _$FederationStatusFromJson(Map<String, dynamic> json) => FederationStatus(
  cloudId: json['cloudId'] as String,
  configured: json['configured'] as bool,
  enabled: json['enabled'] as bool,
);

Map<String, dynamic> _$FederationStatusToJson(FederationStatus instance) => <String, dynamic>{
  'cloudId': instance.cloudId,
  'configured': instance.configured,
  'enabled': instance.enabled,
};

FileError _$FileErrorFromJson(Map<String, dynamic> json) => FileError(
  code: json['code'] as String,
  current: json['current'] == null ? null : Entry.fromJson(json['current'] as Map<String, dynamic>),
  message: json['message'] as String,
);

Map<String, dynamic> _$FileErrorToJson(FileError instance) => <String, dynamic>{
  'code': instance.code,
  'current': ?instance.current?.toJson(),
  'message': instance.message,
};

FileResult _$FileResultFromJson(Map<String, dynamic> json) => FileResult(
  entry: json['entry'] == null ? null : Entry.fromJson(json['entry'] as Map<String, dynamic>),
  error: json['error'] == null ? null : FileError.fromJson(json['error'] as Map<String, dynamic>),
  path: json['path'] as String,
);

Map<String, dynamic> _$FileResultToJson(FileResult instance) => <String, dynamic>{
  'entry': ?instance.entry?.toJson(),
  'error': ?instance.error?.toJson(),
  'path': instance.path,
};

FileSummary _$FileSummaryFromJson(Map<String, dynamic> json) => FileSummary(
  id: (json['id'] as num).toInt(),
  isDir: json['isDir'] as bool,
  name: json['name'] as String,
  path: json['path'] as String,
);

Map<String, dynamic> _$FileSummaryToJson(FileSummary instance) => <String, dynamic>{
  'id': instance.id,
  'isDir': instance.isDir,
  'name': instance.name,
  'path': instance.path,
};

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  createdAt: DateTime.parse(json['createdAt'] as String),
  createdBy: json['createdBy'] == null ? null : UserSummary.fromJson(json['createdBy'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  memberCount: (json['memberCount'] as num).toInt(),
  myRole: groupMyRoleNullableFromJson(json['myRole']),
  name: json['name'] as String,
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'createdBy': ?instance.createdBy?.toJson(),
  'id': instance.id,
  'memberCount': instance.memberCount,
  'myRole': ?groupMyRoleNullableToJson(instance.myRole),
  'name': instance.name,
};

GroupDetails _$GroupDetailsFromJson(Map<String, dynamic> json) => GroupDetails(
  canManage: json['canManage'] as bool,
  group: Group.fromJson(json['group'] as Map<String, dynamic>),
  members: (json['members'] as List<dynamic>?)?.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$GroupDetailsToJson(GroupDetails instance) => <String, dynamic>{
  'canManage': instance.canManage,
  'group': instance.group.toJson(),
  'members': ?instance.members?.map((e) => e.toJson()).toList(),
};

GroupNameRequest _$GroupNameRequestFromJson(Map<String, dynamic> json) =>
    GroupNameRequest(name: json['name'] as String);

Map<String, dynamic> _$GroupNameRequestToJson(GroupNameRequest instance) => <String, dynamic>{'name': instance.name};

GroupRef _$GroupRefFromJson(Map<String, dynamic> json) =>
    GroupRef(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$GroupRefToJson(GroupRef instance) => <String, dynamic>{'id': instance.id, 'name': instance.name};

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) => HealthStatus(status: json['status'] as String);

Map<String, dynamic> _$HealthStatusToJson(HealthStatus instance) => <String, dynamic>{'status': instance.status};

ImageInfo _$ImageInfoFromJson(Map<String, dynamic> json) =>
    ImageInfo(contentType: json['contentType'] as String, id: json['id'] as String);

Map<String, dynamic> _$ImageInfoToJson(ImageInfo instance) => <String, dynamic>{
  'contentType': instance.contentType,
  'id': instance.id,
};

Incoming _$IncomingFromJson(Map<String, dynamic> json) => Incoming(
  kind: json['kind'] as String,
  source: Entry.fromJson(json['source'] as Map<String, dynamic>),
  title: json['title'] as String,
);

Map<String, dynamic> _$IncomingToJson(Incoming instance) => <String, dynamic>{
  'kind': instance.kind,
  'source': instance.source.toJson(),
  'title': instance.title,
};

IncomingFederatedShare _$IncomingFederatedShareFromJson(Map<String, dynamic> json) => IncomingFederatedShare(
  createdAt: DateTime.parse(json['createdAt'] as String),
  id: (json['id'] as num).toInt(),
  isDir: json['isDir'] as bool,
  mountPath: json['mountPath'] as String,
  mtime: json['mtime'] == null ? null : DateTime.parse(json['mtime'] as String),
  name: json['name'] as String,
  owner: json['owner'] as String,
  ownerName: json['ownerName'] as String,
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  provider: json['provider'] as String,
  server: json['server'] as String,
  sharedBy: json['sharedBy'] as String,
  size: (json['size'] as num).toInt(),
  state: incomingFederatedShareStateFromJson(json['state']),
);

Map<String, dynamic> _$IncomingFederatedShareToJson(IncomingFederatedShare instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'isDir': instance.isDir,
  'mountPath': instance.mountPath,
  'mtime': ?instance.mtime?.toIso8601String(),
  'name': instance.name,
  'owner': instance.owner,
  'ownerName': instance.ownerName,
  'permissions': instance.permissions.toJson(),
  'provider': instance.provider,
  'server': instance.server,
  'sharedBy': instance.sharedBy,
  'size': instance.size,
  'state': ?incomingFederatedShareStateToJson(instance.state),
};

IncomingShare _$IncomingShareFromJson(Map<String, dynamic> json) => IncomingShare(
  createdAt: DateTime.parse(json['createdAt'] as String),
  direct: json['direct'] as bool,
  entry: Entry.fromJson(json['entry'] as Map<String, dynamic>),
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  groups: (json['groups'] as List<dynamic>?)?.map((e) => GroupRef.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  id: (json['id'] as num).toInt(),
  mountPath: json['mountPath'] as String,
  note: json['note'] as String,
  owner: UserSummary.fromJson(json['owner'] as Map<String, dynamic>),
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IncomingShareToJson(IncomingShare instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'direct': instance.direct,
  'entry': instance.entry.toJson(),
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'groups': ?instance.groups?.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'mountPath': instance.mountPath,
  'note': instance.note,
  'owner': instance.owner.toJson(),
  'permissions': instance.permissions.toJson(),
};

Invite _$InviteFromJson(Map<String, dynamic> json) => Invite(
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  id: (json['id'] as num).toInt(),
  provider: json['provider'] as String,
  token: json['token'] as String?,
);

Map<String, dynamic> _$InviteToJson(Invite instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'id': instance.id,
  'provider': instance.provider,
  'token': ?instance.token,
};

LinkChanges _$LinkChangesFromJson(Map<String, dynamic> json) => LinkChanges(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  password: json['password'] as String?,
  permissions: json['permissions'] == null
      ? null
      : LinkPermissionChanges.fromJson(json['permissions'] as Map<String, dynamic>),
  removeExpiry: json['removeExpiry'] as bool?,
  removePassword: json['removePassword'] as bool?,
);

Map<String, dynamic> _$LinkChangesToJson(LinkChanges instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'password': ?instance.password,
  'permissions': ?instance.permissions?.toJson(),
  'removeExpiry': ?instance.removeExpiry,
  'removePassword': ?instance.removePassword,
};

LinkInfo _$LinkInfoFromJson(Map<String, dynamic> json) => LinkInfo(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  isDir: json['isDir'] as bool?,
  name: json['name'] as String?,
  needsPassword: json['needsPassword'] as bool,
  owner: json['owner'] == null ? null : UserSummary.fromJson(json['owner'] as Map<String, dynamic>),
  permissions: LinkPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LinkInfoToJson(LinkInfo instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'isDir': ?instance.isDir,
  'name': ?instance.name,
  'needsPassword': instance.needsPassword,
  'owner': ?instance.owner?.toJson(),
  'permissions': instance.permissions.toJson(),
};

LinkMatch _$LinkMatchFromJson(Map<String, dynamic> json) => LinkMatch(
  ownPath: json['ownPath'] as String?,
  path: json['path'] as String?,
  shareId: (json['shareId'] as num?)?.toInt(),
);

Map<String, dynamic> _$LinkMatchToJson(LinkMatch instance) => <String, dynamic>{
  'ownPath': ?instance.ownPath,
  'path': ?instance.path,
  'shareId': ?instance.shareId,
};

LinkPermissionChanges _$LinkPermissionChangesFromJson(Map<String, dynamic> json) => LinkPermissionChanges(
  download: json['download'] as bool?,
  upload: json['upload'] as bool?,
  view: json['view'] as bool?,
);

Map<String, dynamic> _$LinkPermissionChangesToJson(LinkPermissionChanges instance) => <String, dynamic>{
  'download': ?instance.download,
  'upload': ?instance.upload,
  'view': ?instance.view,
};

LinkPermissions _$LinkPermissionsFromJson(Map<String, dynamic> json) =>
    LinkPermissions(download: json['download'] as bool, upload: json['upload'] as bool, view: json['view'] as bool);

Map<String, dynamic> _$LinkPermissionsToJson(LinkPermissions instance) => <String, dynamic>{
  'download': instance.download,
  'upload': instance.upload,
  'view': instance.view,
};

LinkUnlock _$LinkUnlockFromJson(Map<String, dynamic> json) => LinkUnlock(
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  info: LinkInfo.fromJson(json['info'] as Map<String, dynamic>),
  root: Entry.fromJson(json['root'] as Map<String, dynamic>),
  token: json['token'] as String,
);

Map<String, dynamic> _$LinkUnlockToJson(LinkUnlock instance) => <String, dynamic>{
  'expiresAt': instance.expiresAt.toIso8601String(),
  'info': instance.info.toJson(),
  'root': instance.root.toJson(),
  'token': instance.token,
};

LinksResponse _$LinksResponseFromJson(Map<String, dynamic> json) => LinksResponse(
  incoming:
      (json['incoming'] as List<dynamic>?)?.map((e) => Incoming.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  outgoing:
      (json['outgoing'] as List<dynamic>?)?.map((e) => Outgoing.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$LinksResponseToJson(LinksResponse instance) => <String, dynamic>{
  'incoming': ?instance.incoming?.map((e) => e.toJson()).toList(),
  'outgoing': ?instance.outgoing?.map((e) => e.toJson()).toList(),
};

ListResponse _$ListResponseFromJson(Map<String, dynamic> json) => ListResponse(
  entries: (json['entries'] as List<dynamic>?)?.map((e) => Entry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  indexing: json['indexing'] as bool,
  mount: json['mount'] == null ? null : Mount.fromJson(json['mount'] as Map<String, dynamic>),
  path: json['path'] as String,
);

Map<String, dynamic> _$ListResponseToJson(ListResponse instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'indexing': instance.indexing,
  'mount': ?instance.mount?.toJson(),
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
  via: json['via'] as String?,
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
  'via': ?instance.via,
};

LiveTransfers _$LiveTransfersFromJson(Map<String, dynamic> json) => LiveTransfers(
  transfers:
      (json['transfers'] as List<dynamic>?)?.map((e) => LiveTransfer.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
);

Map<String, dynamic> _$LiveTransfersToJson(LiveTransfers instance) => <String, dynamic>{
  'transfers': ?instance.transfers?.map((e) => e.toJson()).toList(),
};

LogComponents _$LogComponentsFromJson(Map<String, dynamic> json) =>
    LogComponents(components: (json['components'] as List<dynamic>?)?.map((e) => e as String).toList() ?? []);

Map<String, dynamic> _$LogComponentsToJson(LogComponents instance) => <String, dynamic>{
  'components': ?instance.components,
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
  via: json['via'] as String?,
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
  'via': ?instance.via,
};

LogFiles _$LogFilesFromJson(Map<String, dynamic> json) => LogFiles(
  files:
      (json['files'] as List<dynamic>?)?.map((e) => ServerLogFile.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$LogFilesToJson(LogFiles instance) => <String, dynamic>{
  'files': ?instance.files?.map((e) => e.toJson()).toList(),
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

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
  entry: Entry.fromJson(json['entry'] as Map<String, dynamic>),
  nameMatches:
      (json['nameMatches'] as List<dynamic>?)?.map((e) => TextSpan.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  score: (json['score'] as num).toDouble(),
  snippet: json['snippet'] as String?,
  snippetMatches:
      (json['snippetMatches'] as List<dynamic>?)?.map((e) => TextSpan.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
);

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
  'entry': instance.entry.toJson(),
  'nameMatches': ?instance.nameMatches?.map((e) => e.toJson()).toList(),
  'score': instance.score,
  'snippet': ?instance.snippet,
  'snippetMatches': ?instance.snippetMatches?.map((e) => e.toJson()).toList(),
};

Member _$MemberFromJson(Map<String, dynamic> json) =>
    Member(role: memberRoleFromJson(json['role']), user: UserSummary.fromJson(json['user'] as Map<String, dynamic>));

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
  'role': ?memberRoleToJson(instance.role),
  'user': instance.user.toJson(),
};

Mount _$MountFromJson(Map<String, dynamic> json) => Mount(
  canLeave: json['canLeave'] as bool,
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  groups: (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  isDir: json['isDir'] as bool,
  kind: mountKindFromJson(json['kind']),
  note: json['note'] as String?,
  owner: json['owner'] as String,
  ownerName: json['ownerName'] as String,
  path: json['path'] as String,
  permissions: MountPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  provider: json['provider'] as String?,
  server: json['server'] as String?,
  shareId: (json['shareId'] as num).toInt(),
  sharedAt: DateTime.parse(json['sharedAt'] as String),
);

Map<String, dynamic> _$MountToJson(Mount instance) => <String, dynamic>{
  'canLeave': instance.canLeave,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'groups': ?instance.groups,
  'isDir': instance.isDir,
  'kind': ?mountKindToJson(instance.kind),
  'note': ?instance.note,
  'owner': instance.owner,
  'ownerName': instance.ownerName,
  'path': instance.path,
  'permissions': instance.permissions.toJson(),
  'provider': ?instance.provider,
  'server': ?instance.server,
  'shareId': instance.shareId,
  'sharedAt': instance.sharedAt.toIso8601String(),
};

MountPermissions _$MountPermissionsFromJson(Map<String, dynamic> json) =>
    MountPermissions(create: json['create'] as bool, delete: json['delete'] as bool, edit: json['edit'] as bool);

Map<String, dynamic> _$MountPermissionsToJson(MountPermissions instance) => <String, dynamic>{
  'create': instance.create,
  'delete': instance.delete,
  'edit': instance.edit,
};

MoveRequest _$MoveRequestFromJson(Map<String, dynamic> json) =>
    MoveRequest(baseRev: (json['baseRev'] as num?)?.toInt(), from: json['from'] as String, to: json['to'] as String);

Map<String, dynamic> _$MoveRequestToJson(MoveRequest instance) => <String, dynamic>{
  'baseRev': ?instance.baseRev,
  'from': instance.from,
  'to': instance.to,
};

NewAppPassword _$NewAppPasswordFromJson(Map<String, dynamic> json) => NewAppPassword(
  createdAt: DateTime.parse(json['createdAt'] as String),
  id: (json['id'] as num).toInt(),
  lastUsedAddress: json['lastUsedAddress'] as String,
  lastUsedAt: json['lastUsedAt'] == null ? null : DateTime.parse(json['lastUsedAt'] as String),
  name: json['name'] as String,
  readOnly: json['readOnly'] as bool,
  token: json['token'] as String,
);

Map<String, dynamic> _$NewAppPasswordToJson(NewAppPassword instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'id': instance.id,
  'lastUsedAddress': instance.lastUsedAddress,
  'lastUsedAt': ?instance.lastUsedAt?.toIso8601String(),
  'name': instance.name,
  'readOnly': instance.readOnly,
  'token': instance.token,
};

NewMember _$NewMemberFromJson(Map<String, dynamic> json) =>
    NewMember(role: NewMember.newMemberRoleRoleNullableFromJson(json['role']), userId: (json['userId'] as num).toInt());

Map<String, dynamic> _$NewMemberToJson(NewMember instance) => <String, dynamic>{
  'role': ?newMemberRoleNullableToJson(instance.role),
  'userId': instance.userId,
};

NewOutgoingShare _$NewOutgoingShareFromJson(Map<String, dynamic> json) => NewOutgoingShare(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  fileId: (json['fileId'] as num).toInt(),
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  recipient: json['recipient'] as String,
);

Map<String, dynamic> _$NewOutgoingShareToJson(NewOutgoingShare instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'fileId': instance.fileId,
  'permissions': instance.permissions.toJson(),
  'recipient': instance.recipient,
};

NewShare _$NewShareFromJson(Map<String, dynamic> json) => NewShare(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  fileId: (json['fileId'] as num).toInt(),
  note: json['note'] as String?,
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  recipient: RecipientRef.fromJson(json['recipient'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NewShareToJson(NewShare instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'fileId': instance.fileId,
  'note': ?instance.note,
  'permissions': instance.permissions.toJson(),
  'recipient': instance.recipient.toJson(),
};

NewShareLink _$NewShareLinkFromJson(Map<String, dynamic> json) => NewShareLink(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  fileId: (json['fileId'] as num).toInt(),
  password: json['password'] as String?,
  permissions: json['permissions'] == null
      ? null
      : LinkPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NewShareLinkToJson(NewShareLink instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'fileId': instance.fileId,
  'password': ?instance.password,
  'permissions': ?instance.permissions?.toJson(),
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

NotesItem _$NotesItemFromJson(Map<String, dynamic> json) => NotesItem(
  entry: Entry.fromJson(json['entry'] as Map<String, dynamic>),
  hasNotes: json['hasNotes'] as bool?,
  hasReadme: json['hasReadme'] as bool?,
);

Map<String, dynamic> _$NotesItemToJson(NotesItem instance) => <String, dynamic>{
  'entry': instance.entry.toJson(),
  'hasNotes': ?instance.hasNotes,
  'hasReadme': ?instance.hasReadme,
};

NotesListing _$NotesListingFromJson(Map<String, dynamic> json) => NotesListing(
  items: (json['items'] as List<dynamic>?)?.map((e) => NotesItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  path: json['path'] as String,
);

Map<String, dynamic> _$NotesListingToJson(NotesListing instance) => <String, dynamic>{
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
  'path': instance.path,
};

NotesSettings _$NotesSettingsFromJson(Map<String, dynamic> json) => NotesSettings(path: json['path'] as String?);

Map<String, dynamic> _$NotesSettingsToJson(NotesSettings instance) => <String, dynamic>{'path': ?instance.path};

OfficeSessionRequest _$OfficeSessionRequestFromJson(Map<String, dynamic> json) => OfficeSessionRequest(
  origin: json['origin'] as String,
  path: json['path'] as String,
  versionId: (json['versionId'] as num?)?.toInt(),
);

Map<String, dynamic> _$OfficeSessionRequestToJson(OfficeSessionRequest instance) => <String, dynamic>{
  'origin': instance.origin,
  'path': instance.path,
  'versionId': ?instance.versionId,
};

Outgoing _$OutgoingFromJson(Map<String, dynamic> json) => Outgoing(
  kind: json['kind'] as String,
  target: json['target'] == null ? null : Entry.fromJson(json['target'] as Map<String, dynamic>),
  targetPath: json['targetPath'] as String,
  title: json['title'] as String,
);

Map<String, dynamic> _$OutgoingToJson(Outgoing instance) => <String, dynamic>{
  'kind': instance.kind,
  'target': ?instance.target?.toJson(),
  'targetPath': instance.targetPath,
  'title': instance.title,
};

OutgoingShare _$OutgoingShareFromJson(Map<String, dynamic> json) => OutgoingShare(
  available: json['available'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  file: FileSummary.fromJson(json['file'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  recipient: json['recipient'] as String,
  recipientName: json['recipientName'] as String,
  state: outgoingShareStateFromJson(json['state']),
);

Map<String, dynamic> _$OutgoingShareToJson(OutgoingShare instance) => <String, dynamic>{
  'available': instance.available,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'file': instance.file.toJson(),
  'id': instance.id,
  'permissions': instance.permissions.toJson(),
  'recipient': instance.recipient,
  'recipientName': instance.recipientName,
  'state': ?outgoingShareStateToJson(instance.state),
};

OutgoingShareChanges _$OutgoingShareChangesFromJson(Map<String, dynamic> json) => OutgoingShareChanges(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  noExpiry: json['noExpiry'] as bool?,
  permissions: json['permissions'] == null
      ? null
      : SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OutgoingShareChangesToJson(OutgoingShareChanges instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'noExpiry': ?instance.noExpiry,
  'permissions': ?instance.permissions?.toJson(),
};

PasswordChange _$PasswordChangeFromJson(Map<String, dynamic> json) =>
    PasswordChange(currentPassword: json['currentPassword'] as String, newPassword: json['newPassword'] as String);

Map<String, dynamic> _$PasswordChangeToJson(PasswordChange instance) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};

PathRequest _$PathRequestFromJson(Map<String, dynamic> json) => PathRequest(path: json['path'] as String);

Map<String, dynamic> _$PathRequestToJson(PathRequest instance) => <String, dynamic>{'path': instance.path};

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  address: json['address'] as String,
  age: (json['age'] as num?)?.toInt(),
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'address': instance.address,
  'age': ?instance.age,
  'displayName': instance.displayName,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};

QueryFilter _$QueryFilterFromJson(Map<String, dynamic> json) => QueryFilter(
  end: (json['end'] as num).toInt(),
  key: queryFilterKeyFromJson(json['key']),
  op: queryFilterOpFromJson(json['op']),
  start: (json['start'] as num).toInt(),
  values: (json['values'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$QueryFilterToJson(QueryFilter instance) => <String, dynamic>{
  'end': instance.end,
  'key': ?queryFilterKeyToJson(instance.key),
  'op': ?queryFilterOpToJson(instance.op),
  'start': instance.start,
  'values': ?instance.values,
};

QueryWarning _$QueryWarningFromJson(Map<String, dynamic> json) => QueryWarning(
  end: (json['end'] as num).toInt(),
  message: json['message'] as String,
  start: (json['start'] as num).toInt(),
);

Map<String, dynamic> _$QueryWarningToJson(QueryWarning instance) => <String, dynamic>{
  'end': instance.end,
  'message': instance.message,
  'start': instance.start,
};

Recipient _$RecipientFromJson(Map<String, dynamic> json) => Recipient(
  avatar: json['avatar'] == null ? null : Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  kind: recipientKindFromJson(json['kind']),
  name: json['name'] as String,
  username: json['username'] as String?,
);

Map<String, dynamic> _$RecipientToJson(Recipient instance) => <String, dynamic>{
  'avatar': ?instance.avatar?.toJson(),
  'id': instance.id,
  'kind': ?recipientKindToJson(instance.kind),
  'name': instance.name,
  'username': ?instance.username,
};

RecipientRef _$RecipientRefFromJson(Map<String, dynamic> json) =>
    RecipientRef(id: (json['id'] as num).toInt(), kind: recipientRefKindFromJson(json['kind']));

Map<String, dynamic> _$RecipientRefToJson(RecipientRef instance) => <String, dynamic>{
  'id': instance.id,
  'kind': ?recipientRefKindToJson(instance.kind),
};

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(deviceName: json['deviceName'] as String?, refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) => <String, dynamic>{
  'deviceName': ?instance.deviceName,
  'refreshToken': instance.refreshToken,
};

RemoteEntry _$RemoteEntryFromJson(Map<String, dynamic> json) => RemoteEntry(
  etag: json['etag'] as String,
  isDir: json['isDir'] as bool,
  mime: json['mime'] as String,
  mtime: DateTime.parse(json['mtime'] as String),
  name: json['name'] as String,
  path: json['path'] as String,
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  rev: (json['rev'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$RemoteEntryToJson(RemoteEntry instance) => <String, dynamic>{
  'etag': instance.etag,
  'isDir': instance.isDir,
  'mime': instance.mime,
  'mtime': instance.mtime.toIso8601String(),
  'name': instance.name,
  'path': instance.path,
  'permissions': instance.permissions.toJson(),
  'rev': instance.rev,
  'size': instance.size,
};

RemoteListResponse _$RemoteListResponseFromJson(Map<String, dynamic> json) => RemoteListResponse(
  entries:
      (json['entries'] as List<dynamic>?)?.map((e) => RemoteEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  item: RemoteEntry.fromJson(json['item'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RemoteListResponseToJson(RemoteListResponse instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'item': instance.item.toJson(),
};

ResolveRequest _$ResolveRequestFromJson(Map<String, dynamic> json) =>
    ResolveRequest(ids: (json['ids'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? []);

Map<String, dynamic> _$ResolveRequestToJson(ResolveRequest instance) => <String, dynamic>{'ids': ?instance.ids};

ResolveResponse _$ResolveResponseFromJson(Map<String, dynamic> json) => ResolveResponse(
  entries: (json['entries'] as List<dynamic>?)?.map((e) => Entry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$ResolveResponseToJson(ResolveResponse instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
};

RestoreRequest _$RestoreRequestFromJson(Map<String, dynamic> json) =>
    RestoreRequest(onConflict: RestoreRequest.restoreRequestOnConflictOnConflictNullableFromJson(json['onConflict']));

Map<String, dynamic> _$RestoreRequestToJson(RestoreRequest instance) => <String, dynamic>{
  'onConflict': ?restoreRequestOnConflictNullableToJson(instance.onConflict),
};

Results _$ResultsFromJson(Map<String, dynamic> json) => Results(
  facets: Facets.fromJson(json['facets'] as Map<String, dynamic>),
  filters:
      (json['filters'] as List<dynamic>?)?.map((e) => QueryFilter.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  query: json['query'] as String,
  results: (json['results'] as List<dynamic>?)?.map((e) => Match.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  total: (json['total'] as num).toInt(),
  warnings:
      (json['warnings'] as List<dynamic>?)?.map((e) => QueryWarning.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
  'facets': instance.facets.toJson(),
  'filters': ?instance.filters?.map((e) => e.toJson()).toList(),
  'query': instance.query,
  'results': ?instance.results?.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'warnings': ?instance.warnings?.map((e) => e.toJson()).toList(),
};

RoleChange _$RoleChangeFromJson(Map<String, dynamic> json) => RoleChange(role: roleChangeRoleFromJson(json['role']));

Map<String, dynamic> _$RoleChangeToJson(RoleChange instance) => <String, dynamic>{
  'role': ?roleChangeRoleToJson(instance.role),
};

SearchStatus _$SearchStatusFromJson(Map<String, dynamic> json) => SearchStatus(
  documents: (json['documents'] as num).toInt(),
  extraction: ExtractionStatus.fromJson(json['extraction'] as Map<String, dynamic>),
  lastSync: json['lastSync'] == null ? null : DateTime.parse(json['lastSync'] as String),
);

Map<String, dynamic> _$SearchStatusToJson(SearchStatus instance) => <String, dynamic>{
  'documents': instance.documents,
  'extraction': instance.extraction.toJson(),
  'lastSync': ?instance.lastSync?.toIso8601String(),
};

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
  allowPrivateNetwork: json['allowPrivateNetwork'] as bool,
  apiVersion: json['apiVersion'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  discoveredAt: json['discoveredAt'] == null ? null : DateTime.parse(json['discoveredAt'] as String),
  id: (json['id'] as num).toInt(),
  keyFingerprint: json['keyFingerprint'] as String,
  provider: json['provider'] as String,
  remote: json['remote'] as String,
  signsRequests: json['signsRequests'] as bool,
  verifySenderAddress: json['verifySenderAddress'] as bool,
);

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
  'allowPrivateNetwork': instance.allowPrivateNetwork,
  'apiVersion': instance.apiVersion,
  'createdAt': instance.createdAt.toIso8601String(),
  'discoveredAt': ?instance.discoveredAt?.toIso8601String(),
  'id': instance.id,
  'keyFingerprint': instance.keyFingerprint,
  'provider': instance.provider,
  'remote': instance.remote,
  'signsRequests': instance.signsRequests,
  'verifySenderAddress': instance.verifySenderAddress,
};

ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) =>
    ServerInfo(buildNumber: json['buildNumber'] as String, version: json['version'] as String);

Map<String, dynamic> _$ServerInfoToJson(ServerInfo instance) => <String, dynamic>{
  'buildNumber': instance.buildNumber,
  'version': instance.version,
};

ServerLogEntry _$ServerLogEntryFromJson(Map<String, dynamic> json) => ServerLogEntry(
  attrs: json['attrs'] as Map<String, dynamic>,
  component: json['component'] as String,
  id: json['id'] as String,
  level: json['level'] as String,
  message: json['message'] as String,
  time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
);

Map<String, dynamic> _$ServerLogEntryToJson(ServerLogEntry instance) => <String, dynamic>{
  'attrs': instance.attrs,
  'component': instance.component,
  'id': instance.id,
  'level': instance.level,
  'message': instance.message,
  'time': ?instance.time?.toIso8601String(),
};

ServerLogFile _$ServerLogFileFromJson(Map<String, dynamic> json) => ServerLogFile(
  day: DateTime.parse(json['day'] as String),
  name: json['name'] as String,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$ServerLogFileToJson(ServerLogFile instance) => <String, dynamic>{
  'day': ?_dateToJson(instance.day),
  'name': instance.name,
  'size': instance.size,
};

ServerLogPage _$ServerLogPageFromJson(Map<String, dynamic> json) => ServerLogPage(
  entries:
      (json['entries'] as List<dynamic>?)?.map((e) => ServerLogEntry.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
  nextCursor: json['nextCursor'] as String,
);

Map<String, dynamic> _$ServerLogPageToJson(ServerLogPage instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'nextCursor': instance.nextCursor,
};

ServerOptions _$ServerOptionsFromJson(Map<String, dynamic> json) => ServerOptions(
  allowPrivateNetwork: json['allowPrivateNetwork'] as bool?,
  skipAddressCheck: json['skipAddressCheck'] as bool?,
);

Map<String, dynamic> _$ServerOptionsToJson(ServerOptions instance) => <String, dynamic>{
  'allowPrivateNetwork': ?instance.allowPrivateNetwork,
  'skipAddressCheck': ?instance.skipAddressCheck,
};

ServerSettings _$ServerSettingsFromJson(Map<String, dynamic> json) => ServerSettings(
  accentColor: json['accentColor'] as String,
  federationEnabled: json['federationEnabled'] as bool,
  instanceName: json['instanceName'] as String,
  ocrEnabled: json['ocrEnabled'] as bool,
  ocrLanguages: (json['ocrLanguages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  ocrMaxPages: (json['ocrMaxPages'] as num).toInt(),
  searchContentEnabled: json['searchContentEnabled'] as bool,
  trashEnabled: json['trashEnabled'] as bool,
  trashRetentionDays: (json['trashRetentionDays'] as num).toInt(),
  versionsEnabled: json['versionsEnabled'] as bool,
  versionsKeepAllHours: (json['versionsKeepAllHours'] as num).toInt(),
  versionsMaxAgeDays: (json['versionsMaxAgeDays'] as num).toInt(),
  versionsMaxPerFile: (json['versionsMaxPerFile'] as num).toInt(),
  welcomeMessage: json['welcomeMessage'] as String,
);

Map<String, dynamic> _$ServerSettingsToJson(ServerSettings instance) => <String, dynamic>{
  'accentColor': instance.accentColor,
  'federationEnabled': instance.federationEnabled,
  'instanceName': instance.instanceName,
  'ocrEnabled': instance.ocrEnabled,
  'ocrLanguages': ?instance.ocrLanguages,
  'ocrMaxPages': instance.ocrMaxPages,
  'searchContentEnabled': instance.searchContentEnabled,
  'trashEnabled': instance.trashEnabled,
  'trashRetentionDays': instance.trashRetentionDays,
  'versionsEnabled': instance.versionsEnabled,
  'versionsKeepAllHours': instance.versionsKeepAllHours,
  'versionsMaxAgeDays': instance.versionsMaxAgeDays,
  'versionsMaxPerFile': instance.versionsMaxPerFile,
  'welcomeMessage': instance.welcomeMessage,
};

ServerSettingsChanges _$ServerSettingsChangesFromJson(Map<String, dynamic> json) => ServerSettingsChanges(
  accentColor: json['accentColor'] as String?,
  federationEnabled: json['federationEnabled'] as bool?,
  instanceName: json['instanceName'] as String?,
  ocrEnabled: json['ocrEnabled'] as bool?,
  ocrLanguages: (json['ocrLanguages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  ocrMaxPages: (json['ocrMaxPages'] as num?)?.toInt(),
  searchContentEnabled: json['searchContentEnabled'] as bool?,
  trashEnabled: json['trashEnabled'] as bool?,
  trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt(),
  versionsEnabled: json['versionsEnabled'] as bool?,
  versionsKeepAllHours: (json['versionsKeepAllHours'] as num?)?.toInt(),
  versionsMaxAgeDays: (json['versionsMaxAgeDays'] as num?)?.toInt(),
  versionsMaxPerFile: (json['versionsMaxPerFile'] as num?)?.toInt(),
  welcomeMessage: json['welcomeMessage'] as String?,
);

Map<String, dynamic> _$ServerSettingsChangesToJson(ServerSettingsChanges instance) => <String, dynamic>{
  'accentColor': ?instance.accentColor,
  'federationEnabled': ?instance.federationEnabled,
  'instanceName': ?instance.instanceName,
  'ocrEnabled': ?instance.ocrEnabled,
  'ocrLanguages': ?instance.ocrLanguages,
  'ocrMaxPages': ?instance.ocrMaxPages,
  'searchContentEnabled': ?instance.searchContentEnabled,
  'trashEnabled': ?instance.trashEnabled,
  'trashRetentionDays': ?instance.trashRetentionDays,
  'versionsEnabled': ?instance.versionsEnabled,
  'versionsKeepAllHours': ?instance.versionsKeepAllHours,
  'versionsMaxAgeDays': ?instance.versionsMaxAgeDays,
  'versionsMaxPerFile': ?instance.versionsMaxPerFile,
  'welcomeMessage': ?instance.welcomeMessage,
};

SessionRequest _$SessionRequestFromJson(Map<String, dynamic> json) =>
    SessionRequest(deviceName: json['deviceName'] as String?);

Map<String, dynamic> _$SessionRequestToJson(SessionRequest instance) => <String, dynamic>{
  'deviceName': ?instance.deviceName,
};

SetupStatus _$SetupStatusFromJson(Map<String, dynamic> json) => SetupStatus(needsSetup: json['needsSetup'] as bool);

Map<String, dynamic> _$SetupStatusToJson(SetupStatus instance) => <String, dynamic>{'needsSetup': instance.needsSetup};

Share _$ShareFromJson(Map<String, dynamic> json) => Share(
  available: json['available'] as bool,
  canChange: json['canChange'] as bool,
  canRemove: json['canRemove'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  file: FileSummary.fromJson(json['file'] as Map<String, dynamic>),
  id: (json['id'] as num).toInt(),
  note: json['note'] as String,
  owner: UserSummary.fromJson(json['owner'] as Map<String, dynamic>),
  permissions: SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  recipient: Recipient.fromJson(json['recipient'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShareToJson(Share instance) => <String, dynamic>{
  'available': instance.available,
  'canChange': instance.canChange,
  'canRemove': instance.canRemove,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'file': instance.file.toJson(),
  'id': instance.id,
  'note': instance.note,
  'owner': instance.owner.toJson(),
  'permissions': instance.permissions.toJson(),
  'recipient': instance.recipient.toJson(),
};

ShareChanges _$ShareChangesFromJson(Map<String, dynamic> json) => ShareChanges(
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  note: json['note'] as String?,
  permissions: json['permissions'] == null
      ? null
      : SharePermissions.fromJson(json['permissions'] as Map<String, dynamic>),
  removeExpiry: json['removeExpiry'] as bool?,
);

Map<String, dynamic> _$ShareChangesToJson(ShareChanges instance) => <String, dynamic>{
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'note': ?instance.note,
  'permissions': ?instance.permissions?.toJson(),
  'removeExpiry': ?instance.removeExpiry,
};

ShareDisplaySettings _$ShareDisplaySettingsFromJson(Map<String, dynamic> json) =>
    ShareDisplaySettings(showInFiles: json['showInFiles'] as bool);

Map<String, dynamic> _$ShareDisplaySettingsToJson(ShareDisplaySettings instance) => <String, dynamic>{
  'showInFiles': instance.showInFiles,
};

ShareLink _$ShareLinkFromJson(Map<String, dynamic> json) => ShareLink(
  available: json['available'] as bool,
  code: json['code'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
  file: FileSummary.fromJson(json['file'] as Map<String, dynamic>),
  hasPassword: json['hasPassword'] as bool,
  id: (json['id'] as num).toInt(),
  permissions: LinkPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShareLinkToJson(ShareLink instance) => <String, dynamic>{
  'available': instance.available,
  'code': instance.code,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'file': instance.file.toJson(),
  'hasPassword': instance.hasPassword,
  'id': instance.id,
  'permissions': instance.permissions.toJson(),
};

SharePermissions _$SharePermissionsFromJson(Map<String, dynamic> json) =>
    SharePermissions(create: json['create'] as bool?, delete: json['delete'] as bool?, edit: json['edit'] as bool?);

Map<String, dynamic> _$SharePermissionsToJson(SharePermissions instance) => <String, dynamic>{
  'create': ?instance.create,
  'delete': ?instance.delete,
  'edit': ?instance.edit,
};

Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => Suggestion(
  count: (json['count'] as num).toInt(),
  insert: json['insert'] as String,
  kind: suggestionKindFromJson(json['kind']),
  value: json['value'] as String,
);

Map<String, dynamic> _$SuggestionToJson(Suggestion instance) => <String, dynamic>{
  'count': instance.count,
  'insert': instance.insert,
  'kind': ?suggestionKindToJson(instance.kind),
  'value': instance.value,
};

Suggestions _$SuggestionsFromJson(Map<String, dynamic> json) => Suggestions(
  end: (json['end'] as num).toInt(),
  start: (json['start'] as num).toInt(),
  suggestions:
      (json['suggestions'] as List<dynamic>?)?.map((e) => Suggestion.fromJson(e as Map<String, dynamic>)).toList() ??
      [],
);

Map<String, dynamic> _$SuggestionsToJson(Suggestions instance) => <String, dynamic>{
  'end': instance.end,
  'start': instance.start,
  'suggestions': ?instance.suggestions?.map((e) => e.toJson()).toList(),
};

TextSpan _$TextSpanFromJson(Map<String, dynamic> json) =>
    TextSpan(end: (json['end'] as num).toInt(), start: (json['start'] as num).toInt());

Map<String, dynamic> _$TextSpanToJson(TextSpan instance) => <String, dynamic>{
  'end': instance.end,
  'start': instance.start,
};

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

TrashPreferences _$TrashPreferencesFromJson(Map<String, dynamic> json) =>
    TrashPreferences(days: (json['days'] as num?)?.toInt(), enabled: json['enabled'] as bool?);

Map<String, dynamic> _$TrashPreferencesToJson(TrashPreferences instance) => <String, dynamic>{
  'days': ?instance.days,
  'enabled': ?instance.enabled,
};

TrashRetention _$TrashRetentionFromJson(Map<String, dynamic> json) => TrashRetention(
  days: (json['days'] as num).toInt(),
  enabled: json['enabled'] as bool,
  serverDays: (json['serverDays'] as num).toInt(),
  serverEnabled: json['serverEnabled'] as bool,
  source: trashRetentionSourceFromJson(json['source']),
  user: TrashPreferences.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TrashRetentionToJson(TrashRetention instance) => <String, dynamic>{
  'days': instance.days,
  'enabled': instance.enabled,
  'serverDays': instance.serverDays,
  'serverEnabled': instance.serverEnabled,
  'source': ?trashRetentionSourceToJson(instance.source),
  'user': instance.user.toJson(),
};

TrustedServerRequest _$TrustedServerRequestFromJson(Map<String, dynamic> json) => TrustedServerRequest(
  allowPrivateNetwork: json['allowPrivateNetwork'] as bool?,
  remote: json['remote'] as String,
  skipAddressCheck: json['skipAddressCheck'] as bool?,
);

Map<String, dynamic> _$TrustedServerRequestToJson(TrustedServerRequest instance) => <String, dynamic>{
  'allowPrivateNetwork': ?instance.allowPrivateNetwork,
  'remote': instance.remote,
  'skipAddressCheck': ?instance.skipAddressCheck,
};

UnlockRequest _$UnlockRequestFromJson(Map<String, dynamic> json) =>
    UnlockRequest(password: json['password'] as String?);

Map<String, dynamic> _$UnlockRequestToJson(UnlockRequest instance) => <String, dynamic>{'password': ?instance.password};

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

User _$UserFromJson(Map<String, dynamic> json) => User(
  appearance: Appearance.fromJson(json['appearance'] as Map<String, dynamic>),
  avatar: json['avatar'] == null ? null : Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  disabled: json['disabled'] as bool,
  historyBytes: (json['historyBytes'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
  quotaBytes: (json['quotaBytes'] as num).toInt(),
  role: userRoleFromJson(json['role']),
  usedBytes: (json['usedBytes'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'appearance': instance.appearance.toJson(),
  'avatar': ?instance.avatar?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'disabled': instance.disabled,
  'historyBytes': instance.historyBytes,
  'id': instance.id,
  'profile': instance.profile.toJson(),
  'quotaBytes': instance.quotaBytes,
  'role': ?userRoleToJson(instance.role),
  'usedBytes': instance.usedBytes,
  'username': instance.username,
};

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) => UserSummary(
  avatar: json['avatar'] == null ? null : Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
  displayName: json['displayName'] as String,
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$UserSummaryToJson(UserSummary instance) => <String, dynamic>{
  'avatar': ?instance.avatar?.toJson(),
  'displayName': instance.displayName,
  'id': instance.id,
  'username': instance.username,
};

VersionListing _$VersionListingFromJson(Map<String, dynamic> json) => VersionListing(
  current: Entry.fromJson(json['current'] as Map<String, dynamic>),
  path: json['path'] as String,
  retention: VersionRetention.fromJson(json['retention'] as Map<String, dynamic>),
  versions:
      (json['versions'] as List<dynamic>?)?.map((e) => VersionView.fromJson(e as Map<String, dynamic>)).toList() ?? [],
);

Map<String, dynamic> _$VersionListingToJson(VersionListing instance) => <String, dynamic>{
  'current': instance.current.toJson(),
  'path': instance.path,
  'retention': instance.retention.toJson(),
  'versions': ?instance.versions?.map((e) => e.toJson()).toList(),
};

VersionPreferences _$VersionPreferencesFromJson(Map<String, dynamic> json) => VersionPreferences(
  enabled: json['enabled'] as bool?,
  keepAllHours: (json['keepAllHours'] as num?)?.toInt(),
  maxAgeDays: (json['maxAgeDays'] as num?)?.toInt(),
  maxPerFile: (json['maxPerFile'] as num?)?.toInt(),
);

Map<String, dynamic> _$VersionPreferencesToJson(VersionPreferences instance) => <String, dynamic>{
  'enabled': ?instance.enabled,
  'keepAllHours': ?instance.keepAllHours,
  'maxAgeDays': ?instance.maxAgeDays,
  'maxPerFile': ?instance.maxPerFile,
};

VersionRestoreRequest _$VersionRestoreRequestFromJson(Map<String, dynamic> json) =>
    VersionRestoreRequest(baseRev: (json['baseRev'] as num?)?.toInt());

Map<String, dynamic> _$VersionRestoreRequestToJson(VersionRestoreRequest instance) => <String, dynamic>{
  'baseRev': ?instance.baseRev,
};

VersionRetention _$VersionRetentionFromJson(Map<String, dynamic> json) => VersionRetention(
  enabled: json['enabled'] as bool,
  keepAllHours: (json['keepAllHours'] as num).toInt(),
  maxAgeDays: (json['maxAgeDays'] as num).toInt(),
  maxPerFile: (json['maxPerFile'] as num).toInt(),
  serverEnabled: json['serverEnabled'] as bool,
  serverKeepAllHours: (json['serverKeepAllHours'] as num).toInt(),
  serverMaxAgeDays: (json['serverMaxAgeDays'] as num).toInt(),
  serverMaxPerFile: (json['serverMaxPerFile'] as num).toInt(),
  source: versionRetentionSourceFromJson(json['source']),
  user: VersionPreferences.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VersionRetentionToJson(VersionRetention instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'keepAllHours': instance.keepAllHours,
  'maxAgeDays': instance.maxAgeDays,
  'maxPerFile': instance.maxPerFile,
  'serverEnabled': instance.serverEnabled,
  'serverKeepAllHours': instance.serverKeepAllHours,
  'serverMaxAgeDays': instance.serverMaxAgeDays,
  'serverMaxPerFile': instance.serverMaxPerFile,
  'source': ?versionRetentionSourceToJson(instance.source),
  'user': instance.user.toJson(),
};

VersionView _$VersionViewFromJson(Map<String, dynamic> json) => VersionView(
  hasPreview: json['hasPreview'] as bool,
  hash: json['hash'] as String,
  id: (json['id'] as num).toInt(),
  modifiedAt: DateTime.parse(json['modifiedAt'] as String),
  replacedAt: DateTime.parse(json['replacedAt'] as String),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$VersionViewToJson(VersionView instance) => <String, dynamic>{
  'hasPreview': instance.hasPreview,
  'hash': instance.hash,
  'id': instance.id,
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'replacedAt': instance.replacedAt.toIso8601String(),
  'size': instance.size,
};
