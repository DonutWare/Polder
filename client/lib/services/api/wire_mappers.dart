import "package:flutter/widgets.dart";

import "package:polder/models/activity.dart";
import "package:polder/models/admin_user_requests.dart";
import "package:polder/models/change.dart";
import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/manifest.dart";
import "package:polder/models/search.dart";
import "package:polder/models/server_event.dart";
import "package:polder/models/server_log.dart";
import "package:polder/models/server_settings.dart";
import "package:polder/models/setup_status.dart";
import "package:polder/models/token_pair.dart";
import "package:polder/models/trash.dart";
import "package:polder/models/upload_session.dart";
import "package:polder/models/user.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;

extension EntryToModel on wire.Entry {
  FileEntry toModel() => FileEntry(
    path: path,
    name: name,
    isDir: isDir,
    size: size,
    mtime: mtime,
    rev: rev,
    hash: hash,
    mime: mime,
    meta: meta,
    previewState: _previewState(previewState.value),
  );
}

PreviewState _previewState(String? name) => PreviewState.values.asNameMap()[name] ?? PreviewState.none;

extension ListResponseToModel on wire.ListResponse {
  DirectoryListing toModel() => DirectoryListing(
    path: path,
    entries: [for (final entry in entries ?? <wire.Entry>[]) entry.toModel()],
    indexing: indexing,
  );
}

extension ChangeToModel on wire.Change {
  Change toModel() => Change(
    seq: seq,
    type: switch (type) {
      wire.ChangeType.upsert => ChangeType.upsert,
      wire.ChangeType.delete => ChangeType.delete,
      wire.ChangeType.move => ChangeType.move,
      wire.ChangeType.swaggerGeneratedUnknown => throw FormatException("unknown change type for $path"),
    },
    path: path,
    fromPath: fromPath,
    entry: entry?.toModel(),
  );
}

extension ChangePageToModel on wire.ChangePage {
  ChangeFeedPage toModel() => ChangeFeedPage(
    changes: [for (final change in changes ?? <wire.Change>[]) change.toModel()],
    cursor: cursor,
    hasMore: hasMore,
  );
}

extension ManifestToModel on wire.Manifest {
  Manifest toModel() => Manifest(
    path: path,
    rev: rev,
    size: size,
    hash: hash,
    chunks: [
      for (final chunk in chunks ?? <wire.Chunk>[]) ChunkRef(hash: chunk.hash, offset: chunk.offset, size: chunk.size),
    ],
  );
}

extension SetupStatusToModel on wire.SetupStatus {
  SetupStatus toModel() => SetupStatus(needsSetup: needsSetup);
}

extension TokenPairToModel on wire.TokenPair {
  TokenPair toModel() =>
      TokenPair(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, user: user.toModel());
}

extension UserToModel on wire.User {
  User toModel() => User(
    id: id,
    username: username,
    role: switch (role) {
      wire.UserRole.admin => UserRole.admin,
      wire.UserRole.user || wire.UserRole.swaggerGeneratedUnknown => UserRole.user,
    },
    quotaBytes: quotaBytes,
    usedBytes: usedBytes,
    disabled: disabled,
    createdAt: createdAt,
    trashRetentionOverrideDays: trashRetentionOverrideDays,
  );
}

extension TrashItemToModel on wire.TrashItem {
  TrashItem toModel() => TrashItem(
    id: id,
    name: name,
    originalPath: originalPath,
    isDir: isDir,
    size: size,
    mime: mime,
    hash: hash,
    previewState: _previewState(previewState.value),
    deletedAt: deletedAt,
    expiresAt: expiresAt,
  );
}

extension TrashRetentionToModel on wire.TrashRetention {
  TrashRetention toModel() => TrashRetention(
    days: days,
    source: switch (source) {
      wire.TrashRetentionSource.user => RetentionSource.user,
      wire.TrashRetentionSource.server => RetentionSource.server,
      wire.TrashRetentionSource.admin => RetentionSource.admin,
      wire.TrashRetentionSource.$default ||
      wire.TrashRetentionSource.swaggerGeneratedUnknown => RetentionSource.serverDefault,
    },
    locked: locked,
    userDays: userDays,
    defaultDays: defaultDays,
  );
}

extension TrashListingToModel on wire.TrashListing {
  TrashListing toModel() => TrashListing(
    items: [for (final item in items ?? <wire.TrashItem>[]) item.toModel()],
    totalBytes: totalBytes,
    retention: retention.toModel(),
  );
}

extension ServerSettingsToModel on wire.ServerSettings {
  ServerSettings toModel() => ServerSettings(
    trashRetentionDays: trashRetentionDays,
    trashRetentionEnforced: trashRetentionEnforced,
    searchContentEnabled: searchContentEnabled,
    ocrEnabled: ocrEnabled,
    ocrLanguages: ocrLanguages ?? const <String>[],
    ocrMaxPages: ocrMaxPages,
  );
}

extension ExtractionStatusToModel on wire.ExtractionStatus {
  TextExtractionStatus toModel() => TextExtractionStatus(
    pending: pending,
    ocr: switch (ocr) {
      wire.ExtractionStatusOcr.ready => OcrState.ready,
      wire.ExtractionStatusOcr.unavailable => OcrState.unavailable,
      _ => OcrState.off,
    },
    ocrProblem: ocrProblem,
  );
}

extension RestoreModeToWire on RestoreMode {
  wire.RestoreRequestOnConflict toWire() => switch (this) {
    RestoreMode.fail => wire.RestoreRequestOnConflict.fail,
    RestoreMode.overwrite => wire.RestoreRequestOnConflict.overwrite,
    RestoreMode.keepBoth => wire.RestoreRequestOnConflict.keepboth,
  };
}

extension UploadStatusToModel on wire.UploadStatus {
  UploadSession toModel() => UploadSession(uploadId: uploadId, missing: missing ?? const []);
}

extension CreateUserRequestToWire on CreateUserRequest {
  wire.NewUser toWire() => wire.NewUser(
    username: username,
    password: password,
    role: switch (role) {
      UserRole.admin => wire.NewUserRole.admin,
      UserRole.user => wire.NewUserRole.user,
    },
    quotaBytes: quotaBytes,
  );
}

extension UpdateUserRequestToWire on UpdateUserRequest {
  wire.Changes toWire() => wire.Changes(
    password: password,
    role: switch (role) {
      UserRole.admin => wire.ChangesRole.admin,
      UserRole.user => wire.ChangesRole.user,
      null => null,
    },
    quotaBytes: quotaBytes,
    disabled: disabled,
    trashRetentionOverrideDays: trashRetentionOverrideDays,
  );
}

extension UploadRequestToWire on UploadRequest {
  wire.UploadRequest toWire() => wire.UploadRequest(
    path: path,
    baseRev: baseRev,
    size: size,
    hash: hash,
    mtime: mtime,
    chunks: [for (final chunk in chunks) wire.ChunkRef(hash: chunk.hash, size: chunk.size)],
  );
}

extension LogEntryToModel on wire.LogEntry {
  ActivityEntry toModel() => ActivityEntry(
    id: id,
    userId: userId,
    username: username,
    device: device,
    kind: switch (kind) {
      wire.LogEntryKind.upload => ActivityKind.upload,
      wire.LogEntryKind.download => ActivityKind.download,
      wire.LogEntryKind.mkdir => ActivityKind.mkdir,
      wire.LogEntryKind.move => ActivityKind.move,
      wire.LogEntryKind.delete => ActivityKind.delete,
      wire.LogEntryKind.restore => ActivityKind.restore,
      wire.LogEntryKind.trashdelete => ActivityKind.trashDelete,
      wire.LogEntryKind.trashempty => ActivityKind.trashEmpty,
      wire.LogEntryKind.trashexpire => ActivityKind.trashExpire,
      wire.LogEntryKind.rescan => ActivityKind.rescan,
      wire.LogEntryKind.login => ActivityKind.login,
      wire.LogEntryKind.logout => ActivityKind.logout,
      wire.LogEntryKind.swaggerGeneratedUnknown => ActivityKind.unknown,
    },
    path: path,
    fromPath: fromPath,
    isDir: isDir,
    size: size,
    bytes: bytes,
    durationMs: durationMs,
    count: count,
    status: switch (status) {
      wire.LogEntryStatus.failed => ActivityStatus.failed,
      wire.LogEntryStatus.cancelled => ActivityStatus.cancelled,
      wire.LogEntryStatus.ok || wire.LogEntryStatus.swaggerGeneratedUnknown => ActivityStatus.ok,
    },
    detail: detail,
    createdAt: createdAt,
  );
}

extension LogPageToModel on wire.LogPage {
  ActivityPage toModel() => ActivityPage(
    entries: [for (final entry in entries ?? <wire.LogEntry>[]) entry.toModel()],
    nextCursor: nextCursor,
  );
}

extension ServerLogEntryToModel on wire.ServerLogEntry {
  ServerLogEntry toModel() => ServerLogEntry(
    id: id,
    time: time,
    level: LogLevel.parseLogLevels(level),
    component: component,
    message: message,
    attrs: {for (final MapEntry(:key, :value) in attrs.entries) key: "$value"},
  );
}

extension ServerLogPageToModel on wire.ServerLogPage {
  ServerLogPage toModel() => ServerLogPage(
    entries: [for (final entry in entries ?? <wire.ServerLogEntry>[]) entry.toModel()],
    nextCursor: nextCursor,
  );
}

extension ServerLogFileToModel on wire.ServerLogFile {
  ServerLogFile toModel() => ServerLogFile(name: name, day: day, size: size);
}

extension LiveTransferToModel on wire.LiveTransfer {
  LiveTransfer toModel() => LiveTransfer(
    id: id,
    userId: userId,
    username: username,
    direction: direction == wire.LiveTransferDirection.download
        ? TransferDirectionKind.download
        : TransferDirectionKind.upload,
    path: path,
    device: device,
    clientId: clientId,
    bytes: bytes,
    total: total,
    rate: rate,
    startedAt: startedAt,
  );
}

extension EventMessageToModel on wire.EventMessage {
  ServerEvent? toModel() => switch (type) {
    wire.EventMessageType.ready => const ServerEvent.ready(),
    wire.EventMessageType.snapshot => ServerEvent.snapshot([...?transfers?.map((transfer) => transfer.toModel())]),
    wire.EventMessageType.transferStarted => _transfer(TransferPhase.started),
    wire.EventMessageType.transferProgress => _transfer(TransferPhase.progress),
    wire.EventMessageType.transferFinished => _transfer(TransferPhase.finished),
    wire.EventMessageType.activityCreated => entry == null ? null : ServerEvent.activityCreated(entry!.toModel()),
    wire.EventMessageType.filesChanged => ServerEvent.filesChanged(userId, dirs ?? const []),
    wire.EventMessageType.error => ServerEvent.error(code ?? "", message ?? ""),
    wire.EventMessageType.swaggerGeneratedUnknown => null,
  };

  ServerEvent? _transfer(TransferPhase phase) =>
      transfer == null ? null : ServerEvent.transfer(phase, transfer!.toModel());
}

extension ActivityScopeToWire on ActivityScope {
  wire.ClientMessage toSubscribeMessage() => wire.ClientMessage(
    type: wire.ClientMessageType.subscribe,
    scope: switch (this) {
      ActivityScopeMe() => wire.ClientMessageScope.me,
      ActivityScopeAll() => wire.ClientMessageScope.all,
      ActivityScopeUser() => wire.ClientMessageScope.user,
    },
    userId: switch (this) {
      ActivityScopeUser(:final id) => id,
      _ => null,
    },
  );
}

extension ResultsToModel on wire.Results {
  SearchResults toModel() => SearchResults(
    query: query,
    total: total,
    hits: [for (final match in results ?? <wire.Match>[]) match.toModel()],
    filters: [for (final filter in filters ?? <wire.QueryFilter>[]) ?filter.toModel()],
    typeFacets: [for (final facet in facets.types ?? <wire.FacetCount>[]) facet.toModel()],
    extFacets: [for (final facet in facets.exts ?? <wire.FacetCount>[]) facet.toModel()],
    warnings: [
      for (final warning in warnings ?? <wire.QueryWarning>[])
        SearchWarning(
          range: TextRange(start: warning.start, end: warning.end),
          message: warning.message,
        ),
    ],
  );
}

extension MatchToModel on wire.Match {
  SearchHit toModel() => SearchHit(
    entry: entry.toModel(),
    score: score,
    nameMatches: [for (final span in nameMatches ?? <wire.TextSpan>[]) TextRange(start: span.start, end: span.end)],
    snippet: snippet,
    snippetMatches: [
      for (final span in snippetMatches ?? <wire.TextSpan>[]) TextRange(start: span.start, end: span.end),
    ],
  );
}

extension FacetCountToModel on wire.FacetCount {
  SearchFacet toModel() => SearchFacet(value: value, count: count);
}

extension QueryFilterToModel on wire.QueryFilter {
  SearchFilter? toModel() {
    final searchKey = switch (key) {
      wire.QueryFilterKey.type => SearchKey.type,
      wire.QueryFilterKey.ext => SearchKey.ext,
      wire.QueryFilterKey.$in => SearchKey.folder,
      wire.QueryFilterKey.modified => SearchKey.modified,
      wire.QueryFilterKey.size => SearchKey.size,
      wire.QueryFilterKey.swaggerGeneratedUnknown => null,
    };
    final searchOp = switch (op) {
      wire.QueryFilterOp.$is => SearchOp.equals,
      wire.QueryFilterOp.isnot => SearchOp.notEquals,
      wire.QueryFilterOp.gt => SearchOp.greater,
      wire.QueryFilterOp.gte => SearchOp.greaterOrEqual,
      wire.QueryFilterOp.lt => SearchOp.less,
      wire.QueryFilterOp.lte => SearchOp.lessOrEqual,
      wire.QueryFilterOp.between => SearchOp.between,
      wire.QueryFilterOp.swaggerGeneratedUnknown => null,
    };
    if (searchKey == null || searchOp == null) return null;
    return SearchFilter(
      key: searchKey,
      op: searchOp,
      values: values ?? const [],
      range: TextRange(start: start, end: end),
    );
  }
}

extension SuggestionsToModel on wire.Suggestions {
  SearchSuggestions toModel() => SearchSuggestions(
    range: TextRange(start: start, end: end),
    suggestions: [
      for (final suggestion in suggestions ?? <wire.Suggestion>[])
        SearchSuggestion(
          value: suggestion.value,
          insert: suggestion.insert,
          isKey: suggestion.kind == wire.SuggestionKind.key,
          count: suggestion.count,
        ),
    ],
  );
}
