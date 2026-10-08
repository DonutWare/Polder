// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'polder.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branding _$BrandingFromJson(Map<String, dynamic> json) => Branding(
  accentColor: json['accentColor'] as String,
  backgrounds:
      (json['backgrounds'] as List<dynamic>?)
          ?.map((e) => ImageInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  icon: json['icon'] == null
      ? null
      : ImageInfo.fromJson(json['icon'] as Map<String, dynamic>),
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
  entry: json['entry'] == null
      ? null
      : Entry.fromJson(json['entry'] as Map<String, dynamic>),
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
  changes:
      (json['changes'] as List<dynamic>?)
          ?.map((e) => Change.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  cursor: (json['cursor'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$ChangePageToJson(ChangePage instance) =>
    <String, dynamic>{
      'changes': ?instance.changes?.map((e) => e.toJson()).toList(),
      'cursor': instance.cursor,
      'hasMore': instance.hasMore,
    };

Changes _$ChangesFromJson(Map<String, dynamic> json) => Changes(
  disabled: json['disabled'] as bool?,
  password: json['password'] as String?,
  quotaBytes: (json['quotaBytes'] as num?)?.toInt(),
  role: changesRoleNullableFromJson(json['role']),
  trashRetentionOverrideDays: (json['trashRetentionOverrideDays'] as num?)
      ?.toInt(),
);

Map<String, dynamic> _$ChangesToJson(Changes instance) => <String, dynamic>{
  'disabled': ?instance.disabled,
  'password': ?instance.password,
  'quotaBytes': ?instance.quotaBytes,
  'role': ?changesRoleNullableToJson(instance.role),
  'trashRetentionOverrideDays': ?instance.trashRetentionOverrideDays,
};

Chunk _$ChunkFromJson(Map<String, dynamic> json) => Chunk(
  hash: json['hash'] as String,
  offset: (json['offset'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

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

ClientMessage _$ClientMessageFromJson(Map<String, dynamic> json) =>
    ClientMessage(
      scope: clientMessageScopeNullableFromJson(json['scope']),
      token: json['token'] as String?,
      type: clientMessageTypeFromJson(json['type']),
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClientMessageToJson(ClientMessage instance) =>
    <String, dynamic>{
      'scope': ?clientMessageScopeNullableToJson(instance.scope),
      'token': ?instance.token,
      'type': ?clientMessageTypeToJson(instance.type),
      'userId': ?instance.userId,
    };

CreatableApp _$CreatableAppFromJson(Map<String, dynamic> json) => CreatableApp(
  app: json['app'] as String,
  extensions:
      (json['extensions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$CreatableAppToJson(CreatableApp instance) =>
    <String, dynamic>{'app': instance.app, 'extensions': ?instance.extensions};

CredentialsRequest _$CredentialsRequestFromJson(Map<String, dynamic> json) =>
    CredentialsRequest(
      deviceName: json['deviceName'] as String?,
      password: json['password'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$CredentialsRequestToJson(CredentialsRequest instance) =>
    <String, dynamic>{
      'deviceName': ?instance.deviceName,
      'password': instance.password,
      'username': instance.username,
    };

EditorCapabilities _$EditorCapabilitiesFromJson(Map<String, dynamic> json) =>
    EditorCapabilities(
      creatable:
          (json['creatable'] as List<dynamic>?)
              ?.map((e) => CreatableApp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      editableExtensions:
          (json['editableExtensions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      editableMimes:
          (json['editableMimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      enabled: json['enabled'] as bool,
      viewableExtensions:
          (json['viewableExtensions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      viewableMimes:
          (json['viewableMimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$EditorCapabilitiesToJson(EditorCapabilities instance) =>
    <String, dynamic>{
      'creatable': ?instance.creatable?.map((e) => e.toJson()).toList(),
      'editableExtensions': ?instance.editableExtensions,
      'editableMimes': ?instance.editableMimes,
      'enabled': instance.enabled,
      'viewableExtensions': ?instance.viewableExtensions,
      'viewableMimes': ?instance.viewableMimes,
    };

EditorSession _$EditorSessionFromJson(Map<String, dynamic> json) =>
    EditorSession(
      accessToken: json['accessToken'] as String,
      accessTokenTtl: (json['accessTokenTtl'] as num).toInt(),
      editorUrl: json['editorUrl'] as String,
      hostPage: json['hostPage'] as String,
      readOnly: json['readOnly'] as bool,
    );

Map<String, dynamic> _$EditorSessionToJson(EditorSession instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'accessTokenTtl': instance.accessTokenTtl,
      'editorUrl': instance.editorUrl,
      'hostPage': instance.hostPage,
      'readOnly': instance.readOnly,
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

ErrorDetail _$ErrorDetailFromJson(Map<String, dynamic> json) => ErrorDetail(
  code: json['code'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$ErrorDetailToJson(ErrorDetail instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      current: json['current'],
      error: ErrorDetail.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'current': ?instance.current,
      'error': instance.error.toJson(),
    };

EventMessage _$EventMessageFromJson(Map<String, dynamic> json) => EventMessage(
  code: json['code'] as String?,
  dirs:
      (json['dirs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  entry: json['entry'] == null
      ? null
      : LogEntry.fromJson(json['entry'] as Map<String, dynamic>),
  message: json['message'] as String?,
  status: eventMessageStatusNullableFromJson(json['status']),
  transfer: json['transfer'] == null
      ? null
      : LiveTransfer.fromJson(json['transfer'] as Map<String, dynamic>),
  transfers:
      (json['transfers'] as List<dynamic>?)
          ?.map((e) => LiveTransfer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  type: eventMessageTypeFromJson(json['type']),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$EventMessageToJson(EventMessage instance) =>
    <String, dynamic>{
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

ExtractionStatus _$ExtractionStatusFromJson(Map<String, dynamic> json) =>
    ExtractionStatus(
      ocr: extractionStatusOcrFromJson(json['ocr']),
      ocrProblem: json['ocrProblem'] as String?,
      pending: (json['pending'] as num).toInt(),
    );

Map<String, dynamic> _$ExtractionStatusToJson(ExtractionStatus instance) =>
    <String, dynamic>{
      'ocr': ?extractionStatusOcrToJson(instance.ocr),
      'ocrProblem': ?instance.ocrProblem,
      'pending': instance.pending,
    };

FacetCount _$FacetCountFromJson(Map<String, dynamic> json) => FacetCount(
  count: (json['count'] as num).toInt(),
  value: json['value'] as String,
);

Map<String, dynamic> _$FacetCountToJson(FacetCount instance) =>
    <String, dynamic>{'count': instance.count, 'value': instance.value};

Facets _$FacetsFromJson(Map<String, dynamic> json) => Facets(
  exts:
      (json['exts'] as List<dynamic>?)
          ?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  types:
      (json['types'] as List<dynamic>?)
          ?.map((e) => FacetCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$FacetsToJson(Facets instance) => <String, dynamic>{
  'exts': ?instance.exts?.map((e) => e.toJson()).toList(),
  'types': ?instance.types?.map((e) => e.toJson()).toList(),
};

HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) =>
    HealthStatus(status: json['status'] as String);

Map<String, dynamic> _$HealthStatusToJson(HealthStatus instance) =>
    <String, dynamic>{'status': instance.status};

ImageInfo _$ImageInfoFromJson(Map<String, dynamic> json) => ImageInfo(
  contentType: json['contentType'] as String,
  id: json['id'] as String,
);

Map<String, dynamic> _$ImageInfoToJson(ImageInfo instance) => <String, dynamic>{
  'contentType': instance.contentType,
  'id': instance.id,
};

ListResponse _$ListResponseFromJson(Map<String, dynamic> json) => ListResponse(
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  indexing: json['indexing'] as bool,
  path: json['path'] as String,
);

Map<String, dynamic> _$ListResponseToJson(ListResponse instance) =>
    <String, dynamic>{
      'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
      'indexing': instance.indexing,
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

Map<String, dynamic> _$LiveTransferToJson(LiveTransfer instance) =>
    <String, dynamic>{
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

LiveTransfers _$LiveTransfersFromJson(Map<String, dynamic> json) =>
    LiveTransfers(
      transfers:
          (json['transfers'] as List<dynamic>?)
              ?.map((e) => LiveTransfer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$LiveTransfersToJson(LiveTransfers instance) =>
    <String, dynamic>{
      'transfers': ?instance.transfers?.map((e) => e.toJson()).toList(),
    };

LogComponents _$LogComponentsFromJson(Map<String, dynamic> json) =>
    LogComponents(
      components:
          (json['components'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$LogComponentsToJson(LogComponents instance) =>
    <String, dynamic>{'components': ?instance.components};

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

LogFiles _$LogFilesFromJson(Map<String, dynamic> json) => LogFiles(
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => ServerLogFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$LogFilesToJson(LogFiles instance) => <String, dynamic>{
  'files': ?instance.files?.map((e) => e.toJson()).toList(),
};

LogPage _$LogPageFromJson(Map<String, dynamic> json) => LogPage(
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  nextCursor: (json['nextCursor'] as num).toInt(),
);

Map<String, dynamic> _$LogPageToJson(LogPage instance) => <String, dynamic>{
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
  'nextCursor': instance.nextCursor,
};

Manifest _$ManifestFromJson(Map<String, dynamic> json) => Manifest(
  chunks:
      (json['chunks'] as List<dynamic>?)
          ?.map((e) => Chunk.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
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
      (json['nameMatches'] as List<dynamic>?)
          ?.map((e) => TextSpan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  score: (json['score'] as num).toDouble(),
  snippet: json['snippet'] as String?,
  snippetMatches:
      (json['snippetMatches'] as List<dynamic>?)
          ?.map((e) => TextSpan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
  'entry': instance.entry.toJson(),
  'nameMatches': ?instance.nameMatches?.map((e) => e.toJson()).toList(),
  'score': instance.score,
  'snippet': ?instance.snippet,
  'snippetMatches': ?instance.snippetMatches?.map((e) => e.toJson()).toList(),
};

MoveRequest _$MoveRequestFromJson(Map<String, dynamic> json) => MoveRequest(
  baseRev: (json['baseRev'] as num?)?.toInt(),
  from: json['from'] as String,
  to: json['to'] as String,
);

Map<String, dynamic> _$MoveRequestToJson(MoveRequest instance) =>
    <String, dynamic>{
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

OfficeSessionRequest _$OfficeSessionRequestFromJson(
  Map<String, dynamic> json,
) => OfficeSessionRequest(
  origin: json['origin'] as String,
  path: json['path'] as String,
  versionId: (json['versionId'] as num?)?.toInt(),
);

Map<String, dynamic> _$OfficeSessionRequestToJson(
  OfficeSessionRequest instance,
) => <String, dynamic>{
  'origin': instance.origin,
  'path': instance.path,
  'versionId': ?instance.versionId,
};

PathRequest _$PathRequestFromJson(Map<String, dynamic> json) =>
    PathRequest(path: json['path'] as String);

Map<String, dynamic> _$PathRequestToJson(PathRequest instance) =>
    <String, dynamic>{'path': instance.path};

QueryFilter _$QueryFilterFromJson(Map<String, dynamic> json) => QueryFilter(
  end: (json['end'] as num).toInt(),
  key: queryFilterKeyFromJson(json['key']),
  op: queryFilterOpFromJson(json['op']),
  start: (json['start'] as num).toInt(),
  values:
      (json['values'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$QueryFilterToJson(QueryFilter instance) =>
    <String, dynamic>{
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

Map<String, dynamic> _$QueryWarningToJson(QueryWarning instance) =>
    <String, dynamic>{
      'end': instance.end,
      'message': instance.message,
      'start': instance.start,
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(
      deviceName: json['deviceName'] as String?,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{
      'deviceName': ?instance.deviceName,
      'refreshToken': instance.refreshToken,
    };

RestoreRequest _$RestoreRequestFromJson(Map<String, dynamic> json) =>
    RestoreRequest(
      onConflict:
          RestoreRequest.restoreRequestOnConflictOnConflictNullableFromJson(
            json['onConflict'],
          ),
    );

Map<String, dynamic> _$RestoreRequestToJson(
  RestoreRequest instance,
) => <String, dynamic>{
  'onConflict': ?restoreRequestOnConflictNullableToJson(instance.onConflict),
};

Results _$ResultsFromJson(Map<String, dynamic> json) => Results(
  facets: Facets.fromJson(json['facets'] as Map<String, dynamic>),
  filters:
      (json['filters'] as List<dynamic>?)
          ?.map((e) => QueryFilter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  query: json['query'] as String,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  total: (json['total'] as num).toInt(),
  warnings:
      (json['warnings'] as List<dynamic>?)
          ?.map((e) => QueryWarning.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
  'facets': instance.facets.toJson(),
  'filters': ?instance.filters?.map((e) => e.toJson()).toList(),
  'query': instance.query,
  'results': ?instance.results?.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'warnings': ?instance.warnings?.map((e) => e.toJson()).toList(),
};

RetentionRequest _$RetentionRequestFromJson(Map<String, dynamic> json) =>
    RetentionRequest(days: (json['days'] as num?)?.toInt());

Map<String, dynamic> _$RetentionRequestToJson(RetentionRequest instance) =>
    <String, dynamic>{'days': ?instance.days};

SearchStatus _$SearchStatusFromJson(Map<String, dynamic> json) => SearchStatus(
  documents: (json['documents'] as num).toInt(),
  extraction: ExtractionStatus.fromJson(
    json['extraction'] as Map<String, dynamic>,
  ),
  lastSync: json['lastSync'] == null
      ? null
      : DateTime.parse(json['lastSync'] as String),
);

Map<String, dynamic> _$SearchStatusToJson(SearchStatus instance) =>
    <String, dynamic>{
      'documents': instance.documents,
      'extraction': instance.extraction.toJson(),
      'lastSync': ?instance.lastSync?.toIso8601String(),
    };

ServerLogEntry _$ServerLogEntryFromJson(Map<String, dynamic> json) =>
    ServerLogEntry(
      attrs: json['attrs'] as Map<String, dynamic>,
      component: json['component'] as String,
      id: json['id'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      time: json['time'] == null
          ? null
          : DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$ServerLogEntryToJson(ServerLogEntry instance) =>
    <String, dynamic>{
      'attrs': instance.attrs,
      'component': instance.component,
      'id': instance.id,
      'level': instance.level,
      'message': instance.message,
      'time': ?instance.time?.toIso8601String(),
    };

ServerLogFile _$ServerLogFileFromJson(Map<String, dynamic> json) =>
    ServerLogFile(
      day: DateTime.parse(json['day'] as String),
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$ServerLogFileToJson(ServerLogFile instance) =>
    <String, dynamic>{
      'day': ?_dateToJson(instance.day),
      'name': instance.name,
      'size': instance.size,
    };

ServerLogPage _$ServerLogPageFromJson(Map<String, dynamic> json) =>
    ServerLogPage(
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => ServerLogEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextCursor: json['nextCursor'] as String,
    );

Map<String, dynamic> _$ServerLogPageToJson(ServerLogPage instance) =>
    <String, dynamic>{
      'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
    };

ServerSettings _$ServerSettingsFromJson(Map<String, dynamic> json) =>
    ServerSettings(
      accentColor: json['accentColor'] as String,
      instanceName: json['instanceName'] as String,
      ocrEnabled: json['ocrEnabled'] as bool,
      ocrLanguages:
          (json['ocrLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ocrMaxPages: (json['ocrMaxPages'] as num).toInt(),
      searchContentEnabled: json['searchContentEnabled'] as bool,
      trashRetentionDays: (json['trashRetentionDays'] as num).toInt(),
      trashRetentionEnforced: json['trashRetentionEnforced'] as bool,
      versionsEnabled: json['versionsEnabled'] as bool,
      versionsEnforced: json['versionsEnforced'] as bool,
      versionsKeepAllHours: (json['versionsKeepAllHours'] as num).toInt(),
      versionsMaxAgeDays: (json['versionsMaxAgeDays'] as num).toInt(),
      versionsMaxPerFile: (json['versionsMaxPerFile'] as num).toInt(),
      welcomeMessage: json['welcomeMessage'] as String,
    );

Map<String, dynamic> _$ServerSettingsToJson(ServerSettings instance) =>
    <String, dynamic>{
      'accentColor': instance.accentColor,
      'instanceName': instance.instanceName,
      'ocrEnabled': instance.ocrEnabled,
      'ocrLanguages': ?instance.ocrLanguages,
      'ocrMaxPages': instance.ocrMaxPages,
      'searchContentEnabled': instance.searchContentEnabled,
      'trashRetentionDays': instance.trashRetentionDays,
      'trashRetentionEnforced': instance.trashRetentionEnforced,
      'versionsEnabled': instance.versionsEnabled,
      'versionsEnforced': instance.versionsEnforced,
      'versionsKeepAllHours': instance.versionsKeepAllHours,
      'versionsMaxAgeDays': instance.versionsMaxAgeDays,
      'versionsMaxPerFile': instance.versionsMaxPerFile,
      'welcomeMessage': instance.welcomeMessage,
    };

ServerSettingsChanges _$ServerSettingsChangesFromJson(
  Map<String, dynamic> json,
) => ServerSettingsChanges(
  accentColor: json['accentColor'] as String?,
  instanceName: json['instanceName'] as String?,
  ocrEnabled: json['ocrEnabled'] as bool?,
  ocrLanguages:
      (json['ocrLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  ocrMaxPages: (json['ocrMaxPages'] as num?)?.toInt(),
  searchContentEnabled: json['searchContentEnabled'] as bool?,
  trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt(),
  trashRetentionEnforced: json['trashRetentionEnforced'] as bool?,
  versionsEnabled: json['versionsEnabled'] as bool?,
  versionsEnforced: json['versionsEnforced'] as bool?,
  versionsKeepAllHours: (json['versionsKeepAllHours'] as num?)?.toInt(),
  versionsMaxAgeDays: (json['versionsMaxAgeDays'] as num?)?.toInt(),
  versionsMaxPerFile: (json['versionsMaxPerFile'] as num?)?.toInt(),
  welcomeMessage: json['welcomeMessage'] as String?,
);

Map<String, dynamic> _$ServerSettingsChangesToJson(
  ServerSettingsChanges instance,
) => <String, dynamic>{
  'accentColor': ?instance.accentColor,
  'instanceName': ?instance.instanceName,
  'ocrEnabled': ?instance.ocrEnabled,
  'ocrLanguages': ?instance.ocrLanguages,
  'ocrMaxPages': ?instance.ocrMaxPages,
  'searchContentEnabled': ?instance.searchContentEnabled,
  'trashRetentionDays': ?instance.trashRetentionDays,
  'trashRetentionEnforced': ?instance.trashRetentionEnforced,
  'versionsEnabled': ?instance.versionsEnabled,
  'versionsEnforced': ?instance.versionsEnforced,
  'versionsKeepAllHours': ?instance.versionsKeepAllHours,
  'versionsMaxAgeDays': ?instance.versionsMaxAgeDays,
  'versionsMaxPerFile': ?instance.versionsMaxPerFile,
  'welcomeMessage': ?instance.welcomeMessage,
};

SetupStatus _$SetupStatusFromJson(Map<String, dynamic> json) =>
    SetupStatus(needsSetup: json['needsSetup'] as bool);

Map<String, dynamic> _$SetupStatusToJson(SetupStatus instance) =>
    <String, dynamic>{'needsSetup': instance.needsSetup};

Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => Suggestion(
  count: (json['count'] as num).toInt(),
  insert: json['insert'] as String,
  kind: suggestionKindFromJson(json['kind']),
  value: json['value'] as String,
);

Map<String, dynamic> _$SuggestionToJson(Suggestion instance) =>
    <String, dynamic>{
      'count': instance.count,
      'insert': instance.insert,
      'kind': ?suggestionKindToJson(instance.kind),
      'value': instance.value,
    };

Suggestions _$SuggestionsFromJson(Map<String, dynamic> json) => Suggestions(
  end: (json['end'] as num).toInt(),
  start: (json['start'] as num).toInt(),
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$SuggestionsToJson(Suggestions instance) =>
    <String, dynamic>{
      'end': instance.end,
      'start': instance.start,
      'suggestions': ?instance.suggestions?.map((e) => e.toJson()).toList(),
    };

TextSpan _$TextSpanFromJson(Map<String, dynamic> json) => TextSpan(
  end: (json['end'] as num).toInt(),
  start: (json['start'] as num).toInt(),
);

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
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
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
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TrashItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  retention: TrashRetention.fromJson(json['retention'] as Map<String, dynamic>),
  totalBytes: (json['totalBytes'] as num).toInt(),
);

Map<String, dynamic> _$TrashListingToJson(TrashListing instance) =>
    <String, dynamic>{
      'items': ?instance.items?.map((e) => e.toJson()).toList(),
      'retention': instance.retention.toJson(),
      'totalBytes': instance.totalBytes,
    };

TrashRetention _$TrashRetentionFromJson(Map<String, dynamic> json) =>
    TrashRetention(
      days: (json['days'] as num).toInt(),
      defaultDays: (json['defaultDays'] as num).toInt(),
      locked: json['locked'] as bool,
      source: trashRetentionSourceFromJson(json['source']),
      userDays: (json['userDays'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrashRetentionToJson(TrashRetention instance) =>
    <String, dynamic>{
      'days': instance.days,
      'defaultDays': instance.defaultDays,
      'locked': instance.locked,
      'source': ?trashRetentionSourceToJson(instance.source),
      'userDays': ?instance.userDays,
    };

UploadRequest _$UploadRequestFromJson(Map<String, dynamic> json) =>
    UploadRequest(
      baseRev: (json['baseRev'] as num?)?.toInt(),
      chunks:
          (json['chunks'] as List<dynamic>?)
              ?.map((e) => ChunkRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hash: json['hash'] as String,
      mtime: json['mtime'] == null
          ? null
          : DateTime.parse(json['mtime'] as String),
      path: json['path'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$UploadRequestToJson(UploadRequest instance) =>
    <String, dynamic>{
      'baseRev': ?instance.baseRev,
      'chunks': ?instance.chunks?.map((e) => e.toJson()).toList(),
      'hash': instance.hash,
      'mtime': ?instance.mtime?.toIso8601String(),
      'path': instance.path,
      'size': instance.size,
    };

UploadStatus _$UploadStatusFromJson(Map<String, dynamic> json) => UploadStatus(
  missing:
      (json['missing'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  uploadId: json['uploadId'] as String,
);

Map<String, dynamic> _$UploadStatusToJson(UploadStatus instance) =>
    <String, dynamic>{
      'missing': ?instance.missing,
      'uploadId': instance.uploadId,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  createdAt: DateTime.parse(json['createdAt'] as String),
  disabled: json['disabled'] as bool,
  historyBytes: (json['historyBytes'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  quotaBytes: (json['quotaBytes'] as num).toInt(),
  role: userRoleFromJson(json['role']),
  trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt(),
  trashRetentionOverrideDays: (json['trashRetentionOverrideDays'] as num?)
      ?.toInt(),
  usedBytes: (json['usedBytes'] as num).toInt(),
  username: json['username'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'createdAt': instance.createdAt.toIso8601String(),
  'disabled': instance.disabled,
  'historyBytes': instance.historyBytes,
  'id': instance.id,
  'quotaBytes': instance.quotaBytes,
  'role': ?userRoleToJson(instance.role),
  'trashRetentionDays': ?instance.trashRetentionDays,
  'trashRetentionOverrideDays': ?instance.trashRetentionOverrideDays,
  'usedBytes': instance.usedBytes,
  'username': instance.username,
};

VersionListing _$VersionListingFromJson(Map<String, dynamic> json) =>
    VersionListing(
      current: Entry.fromJson(json['current'] as Map<String, dynamic>),
      path: json['path'] as String,
      retention: VersionRetention.fromJson(
        json['retention'] as Map<String, dynamic>,
      ),
      versions:
          (json['versions'] as List<dynamic>?)
              ?.map((e) => VersionView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$VersionListingToJson(VersionListing instance) =>
    <String, dynamic>{
      'current': instance.current.toJson(),
      'path': instance.path,
      'retention': instance.retention.toJson(),
      'versions': ?instance.versions?.map((e) => e.toJson()).toList(),
    };

VersionPreferences _$VersionPreferencesFromJson(Map<String, dynamic> json) =>
    VersionPreferences(
      enabled: json['enabled'] as bool?,
      maxAgeDays: (json['maxAgeDays'] as num?)?.toInt(),
      maxPerFile: (json['maxPerFile'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VersionPreferencesToJson(VersionPreferences instance) =>
    <String, dynamic>{
      'enabled': ?instance.enabled,
      'maxAgeDays': ?instance.maxAgeDays,
      'maxPerFile': ?instance.maxPerFile,
    };

VersionRestoreRequest _$VersionRestoreRequestFromJson(
  Map<String, dynamic> json,
) => VersionRestoreRequest(baseRev: (json['baseRev'] as num?)?.toInt());

Map<String, dynamic> _$VersionRestoreRequestToJson(
  VersionRestoreRequest instance,
) => <String, dynamic>{'baseRev': ?instance.baseRev};

VersionRetention _$VersionRetentionFromJson(Map<String, dynamic> json) =>
    VersionRetention(
      enabled: json['enabled'] as bool,
      keepAllHours: (json['keepAllHours'] as num).toInt(),
      locked: json['locked'] as bool,
      maxAgeDays: (json['maxAgeDays'] as num).toInt(),
      maxPerFile: (json['maxPerFile'] as num).toInt(),
      serverEnabled: json['serverEnabled'] as bool,
      serverMaxAgeDays: (json['serverMaxAgeDays'] as num).toInt(),
      serverMaxPerFile: (json['serverMaxPerFile'] as num).toInt(),
      source: versionRetentionSourceFromJson(json['source']),
      user: VersionPreferences.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersionRetentionToJson(VersionRetention instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'keepAllHours': instance.keepAllHours,
      'locked': instance.locked,
      'maxAgeDays': instance.maxAgeDays,
      'maxPerFile': instance.maxPerFile,
      'serverEnabled': instance.serverEnabled,
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

Map<String, dynamic> _$VersionViewToJson(VersionView instance) =>
    <String, dynamic>{
      'hasPreview': instance.hasPreview,
      'hash': instance.hash,
      'id': instance.id,
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'replacedAt': instance.replacedAt.toIso8601String(),
      'size': instance.size,
    };
