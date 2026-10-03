// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import 'dart:convert';

import 'nomad.enums.swagger.dart' as enums;

part 'nomad.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class Change {
  const Change({this.entry, this.fromPath, required this.path, required this.seq, required this.type});

  factory Change.fromJson(Map<String, dynamic> json) => _$ChangeFromJson(json);

  static const toJsonFactory = _$ChangeToJson;
  Map<String, dynamic> toJson() => _$ChangeToJson(this);

  @JsonKey(name: 'entry', includeIfNull: false)
  final Entry? entry;
  @JsonKey(name: 'fromPath', includeIfNull: false)
  final String? fromPath;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'seq', includeIfNull: false)
  final int seq;
  @JsonKey(name: 'type', includeIfNull: false, toJson: changeTypeToJson, fromJson: changeTypeFromJson)
  final enums.ChangeType type;
  static const fromJsonFactory = _$ChangeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Change &&
            (identical(other.entry, entry) || const DeepCollectionEquality().equals(other.entry, entry)) &&
            (identical(other.fromPath, fromPath) || const DeepCollectionEquality().equals(other.fromPath, fromPath)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.seq, seq) || const DeepCollectionEquality().equals(other.seq, seq)) &&
            (identical(other.type, type) || const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entry) ^
      const DeepCollectionEquality().hash(fromPath) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(seq) ^
      const DeepCollectionEquality().hash(type) ^
      runtimeType.hashCode;
}

extension $ChangeExtension on Change {
  Change copyWith({Entry? entry, String? fromPath, String? path, int? seq, enums.ChangeType? type}) {
    return Change(
      entry: entry ?? this.entry,
      fromPath: fromPath ?? this.fromPath,
      path: path ?? this.path,
      seq: seq ?? this.seq,
      type: type ?? this.type,
    );
  }

  Change copyWithWrapped({
    Wrapped<Entry?>? entry,
    Wrapped<String?>? fromPath,
    Wrapped<String>? path,
    Wrapped<int>? seq,
    Wrapped<enums.ChangeType>? type,
  }) {
    return Change(
      entry: (entry != null ? entry.value : this.entry),
      fromPath: (fromPath != null ? fromPath.value : this.fromPath),
      path: (path != null ? path.value : this.path),
      seq: (seq != null ? seq.value : this.seq),
      type: (type != null ? type.value : this.type),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChangePage {
  const ChangePage({this.changes, required this.cursor, required this.hasMore});

  factory ChangePage.fromJson(Map<String, dynamic> json) => _$ChangePageFromJson(json);

  static const toJsonFactory = _$ChangePageToJson;
  Map<String, dynamic> toJson() => _$ChangePageToJson(this);

  @JsonKey(name: 'changes', includeIfNull: false, defaultValue: <Change>[])
  final List<Change>? changes;
  @JsonKey(name: 'cursor', includeIfNull: false)
  final int cursor;
  @JsonKey(name: 'hasMore', includeIfNull: false)
  final bool hasMore;
  static const fromJsonFactory = _$ChangePageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChangePage &&
            (identical(other.changes, changes) || const DeepCollectionEquality().equals(other.changes, changes)) &&
            (identical(other.cursor, cursor) || const DeepCollectionEquality().equals(other.cursor, cursor)) &&
            (identical(other.hasMore, hasMore) || const DeepCollectionEquality().equals(other.hasMore, hasMore)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(changes) ^
      const DeepCollectionEquality().hash(cursor) ^
      const DeepCollectionEquality().hash(hasMore) ^
      runtimeType.hashCode;
}

extension $ChangePageExtension on ChangePage {
  ChangePage copyWith({List<Change>? changes, int? cursor, bool? hasMore}) {
    return ChangePage(
      changes: changes ?? this.changes,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  ChangePage copyWithWrapped({Wrapped<List<Change>?>? changes, Wrapped<int>? cursor, Wrapped<bool>? hasMore}) {
    return ChangePage(
      changes: (changes != null ? changes.value : this.changes),
      cursor: (cursor != null ? cursor.value : this.cursor),
      hasMore: (hasMore != null ? hasMore.value : this.hasMore),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Changes {
  const Changes({this.disabled, this.password, this.quotaBytes, this.role});

  factory Changes.fromJson(Map<String, dynamic> json) => _$ChangesFromJson(json);

  static const toJsonFactory = _$ChangesToJson;
  Map<String, dynamic> toJson() => _$ChangesToJson(this);

  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool? disabled;
  @JsonKey(name: 'password', includeIfNull: false)
  final String? password;
  @JsonKey(name: 'quotaBytes', includeIfNull: false)
  final int? quotaBytes;
  @JsonKey(name: 'role', includeIfNull: false, toJson: changesRoleNullableToJson, fromJson: changesRoleNullableFromJson)
  final enums.ChangesRole? role;
  static const fromJsonFactory = _$ChangesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Changes &&
            (identical(other.disabled, disabled) || const DeepCollectionEquality().equals(other.disabled, disabled)) &&
            (identical(other.password, password) || const DeepCollectionEquality().equals(other.password, password)) &&
            (identical(other.quotaBytes, quotaBytes) ||
                const DeepCollectionEquality().equals(other.quotaBytes, quotaBytes)) &&
            (identical(other.role, role) || const DeepCollectionEquality().equals(other.role, role)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(quotaBytes) ^
      const DeepCollectionEquality().hash(role) ^
      runtimeType.hashCode;
}

extension $ChangesExtension on Changes {
  Changes copyWith({bool? disabled, String? password, int? quotaBytes, enums.ChangesRole? role}) {
    return Changes(
      disabled: disabled ?? this.disabled,
      password: password ?? this.password,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
    );
  }

  Changes copyWithWrapped({
    Wrapped<bool?>? disabled,
    Wrapped<String?>? password,
    Wrapped<int?>? quotaBytes,
    Wrapped<enums.ChangesRole?>? role,
  }) {
    return Changes(
      disabled: (disabled != null ? disabled.value : this.disabled),
      password: (password != null ? password.value : this.password),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Chunk {
  const Chunk({required this.hash, required this.offset, required this.size});

  factory Chunk.fromJson(Map<String, dynamic> json) => _$ChunkFromJson(json);

  static const toJsonFactory = _$ChunkToJson;
  Map<String, dynamic> toJson() => _$ChunkToJson(this);

  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'offset', includeIfNull: false)
  final int offset;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$ChunkFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Chunk &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.offset, offset) || const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $ChunkExtension on Chunk {
  Chunk copyWith({String? hash, int? offset, int? size}) {
    return Chunk(hash: hash ?? this.hash, offset: offset ?? this.offset, size: size ?? this.size);
  }

  Chunk copyWithWrapped({Wrapped<String>? hash, Wrapped<int>? offset, Wrapped<int>? size}) {
    return Chunk(
      hash: (hash != null ? hash.value : this.hash),
      offset: (offset != null ? offset.value : this.offset),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChunkRef {
  const ChunkRef({required this.hash, required this.size});

  factory ChunkRef.fromJson(Map<String, dynamic> json) => _$ChunkRefFromJson(json);

  static const toJsonFactory = _$ChunkRefToJson;
  Map<String, dynamic> toJson() => _$ChunkRefToJson(this);

  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$ChunkRefFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChunkRef &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(hash) ^ const DeepCollectionEquality().hash(size) ^ runtimeType.hashCode;
}

extension $ChunkRefExtension on ChunkRef {
  ChunkRef copyWith({String? hash, int? size}) {
    return ChunkRef(hash: hash ?? this.hash, size: size ?? this.size);
  }

  ChunkRef copyWithWrapped({Wrapped<String>? hash, Wrapped<int>? size}) {
    return ChunkRef(hash: (hash != null ? hash.value : this.hash), size: (size != null ? size.value : this.size));
  }
}

@JsonSerializable(explicitToJson: true)
class CredentialsRequest {
  const CredentialsRequest({this.deviceName, required this.password, required this.username});

  factory CredentialsRequest.fromJson(Map<String, dynamic> json) => _$CredentialsRequestFromJson(json);

  static const toJsonFactory = _$CredentialsRequestToJson;
  Map<String, dynamic> toJson() => _$CredentialsRequestToJson(this);

  @JsonKey(name: 'deviceName', includeIfNull: false)
  final String? deviceName;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  static const fromJsonFactory = _$CredentialsRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CredentialsRequest &&
            (identical(other.deviceName, deviceName) ||
                const DeepCollectionEquality().equals(other.deviceName, deviceName)) &&
            (identical(other.password, password) || const DeepCollectionEquality().equals(other.password, password)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(deviceName) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $CredentialsRequestExtension on CredentialsRequest {
  CredentialsRequest copyWith({String? deviceName, String? password, String? username}) {
    return CredentialsRequest(
      deviceName: deviceName ?? this.deviceName,
      password: password ?? this.password,
      username: username ?? this.username,
    );
  }

  CredentialsRequest copyWithWrapped({
    Wrapped<String?>? deviceName,
    Wrapped<String>? password,
    Wrapped<String>? username,
  }) {
    return CredentialsRequest(
      deviceName: (deviceName != null ? deviceName.value : this.deviceName),
      password: (password != null ? password.value : this.password),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Entry {
  const Entry({
    required this.hash,
    required this.isDir,
    required this.meta,
    required this.mime,
    required this.mtime,
    required this.name,
    required this.path,
    required this.previewState,
    required this.rev,
    required this.size,
  });

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  static const toJsonFactory = _$EntryToJson;
  Map<String, dynamic> toJson() => _$EntryToJson(this);

  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'isDir', includeIfNull: false)
  final bool isDir;
  @JsonKey(name: 'meta', includeIfNull: false)
  final Map<String, dynamic> meta;
  @JsonKey(name: 'mime', includeIfNull: false)
  final String mime;
  @JsonKey(name: 'mtime', includeIfNull: false)
  final DateTime mtime;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(
    name: 'previewState',
    includeIfNull: false,
    toJson: entryPreviewStateToJson,
    fromJson: entryPreviewStateFromJson,
  )
  final enums.EntryPreviewState previewState;
  @JsonKey(name: 'rev', includeIfNull: false)
  final int rev;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$EntryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Entry &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.isDir, isDir) || const DeepCollectionEquality().equals(other.isDir, isDir)) &&
            (identical(other.meta, meta) || const DeepCollectionEquality().equals(other.meta, meta)) &&
            (identical(other.mime, mime) || const DeepCollectionEquality().equals(other.mime, mime)) &&
            (identical(other.mtime, mtime) || const DeepCollectionEquality().equals(other.mtime, mtime)) &&
            (identical(other.name, name) || const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.previewState, previewState) ||
                const DeepCollectionEquality().equals(other.previewState, previewState)) &&
            (identical(other.rev, rev) || const DeepCollectionEquality().equals(other.rev, rev)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(isDir) ^
      const DeepCollectionEquality().hash(meta) ^
      const DeepCollectionEquality().hash(mime) ^
      const DeepCollectionEquality().hash(mtime) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(previewState) ^
      const DeepCollectionEquality().hash(rev) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $EntryExtension on Entry {
  Entry copyWith({
    String? hash,
    bool? isDir,
    Map<String, dynamic>? meta,
    String? mime,
    DateTime? mtime,
    String? name,
    String? path,
    enums.EntryPreviewState? previewState,
    int? rev,
    int? size,
  }) {
    return Entry(
      hash: hash ?? this.hash,
      isDir: isDir ?? this.isDir,
      meta: meta ?? this.meta,
      mime: mime ?? this.mime,
      mtime: mtime ?? this.mtime,
      name: name ?? this.name,
      path: path ?? this.path,
      previewState: previewState ?? this.previewState,
      rev: rev ?? this.rev,
      size: size ?? this.size,
    );
  }

  Entry copyWithWrapped({
    Wrapped<String>? hash,
    Wrapped<bool>? isDir,
    Wrapped<Map<String, dynamic>>? meta,
    Wrapped<String>? mime,
    Wrapped<DateTime>? mtime,
    Wrapped<String>? name,
    Wrapped<String>? path,
    Wrapped<enums.EntryPreviewState>? previewState,
    Wrapped<int>? rev,
    Wrapped<int>? size,
  }) {
    return Entry(
      hash: (hash != null ? hash.value : this.hash),
      isDir: (isDir != null ? isDir.value : this.isDir),
      meta: (meta != null ? meta.value : this.meta),
      mime: (mime != null ? mime.value : this.mime),
      mtime: (mtime != null ? mtime.value : this.mtime),
      name: (name != null ? name.value : this.name),
      path: (path != null ? path.value : this.path),
      previewState: (previewState != null ? previewState.value : this.previewState),
      rev: (rev != null ? rev.value : this.rev),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ErrorDetail {
  const ErrorDetail({required this.code, required this.message});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) => _$ErrorDetailFromJson(json);

  static const toJsonFactory = _$ErrorDetailToJson;
  Map<String, dynamic> toJson() => _$ErrorDetailToJson(this);

  @JsonKey(name: 'code', includeIfNull: false)
  final String code;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  static const fromJsonFactory = _$ErrorDetailFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorDetail &&
            (identical(other.code, code) || const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.message, message) || const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(code) ^ const DeepCollectionEquality().hash(message) ^ runtimeType.hashCode;
}

extension $ErrorDetailExtension on ErrorDetail {
  ErrorDetail copyWith({String? code, String? message}) {
    return ErrorDetail(code: code ?? this.code, message: message ?? this.message);
  }

  ErrorDetail copyWithWrapped({Wrapped<String>? code, Wrapped<String>? message}) {
    return ErrorDetail(
      code: (code != null ? code.value : this.code),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ErrorResponse {
  const ErrorResponse({this.current, required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);

  static const toJsonFactory = _$ErrorResponseToJson;
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @JsonKey(name: 'current', includeIfNull: false)
  final dynamic current;
  @JsonKey(name: 'error', includeIfNull: false)
  final ErrorDetail error;
  static const fromJsonFactory = _$ErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ErrorResponse &&
            (identical(other.current, current) || const DeepCollectionEquality().equals(other.current, current)) &&
            (identical(other.error, error) || const DeepCollectionEquality().equals(other.error, error)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(current) ^ const DeepCollectionEquality().hash(error) ^ runtimeType.hashCode;
}

extension $ErrorResponseExtension on ErrorResponse {
  ErrorResponse copyWith({dynamic current, ErrorDetail? error}) {
    return ErrorResponse(current: current ?? this.current, error: error ?? this.error);
  }

  ErrorResponse copyWithWrapped({Wrapped<dynamic>? current, Wrapped<ErrorDetail>? error}) {
    return ErrorResponse(
      current: (current != null ? current.value : this.current),
      error: (error != null ? error.value : this.error),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HealthStatus {
  const HealthStatus({required this.status});

  factory HealthStatus.fromJson(Map<String, dynamic> json) => _$HealthStatusFromJson(json);

  static const toJsonFactory = _$HealthStatusToJson;
  Map<String, dynamic> toJson() => _$HealthStatusToJson(this);

  @JsonKey(name: 'status', includeIfNull: false)
  final String status;
  static const fromJsonFactory = _$HealthStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HealthStatus &&
            (identical(other.status, status) || const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(status) ^ runtimeType.hashCode;
}

extension $HealthStatusExtension on HealthStatus {
  HealthStatus copyWith({String? status}) {
    return HealthStatus(status: status ?? this.status);
  }

  HealthStatus copyWithWrapped({Wrapped<String>? status}) {
    return HealthStatus(status: (status != null ? status.value : this.status));
  }
}

@JsonSerializable(explicitToJson: true)
class ListResponse {
  const ListResponse({this.entries, required this.path});

  factory ListResponse.fromJson(Map<String, dynamic> json) => _$ListResponseFromJson(json);

  static const toJsonFactory = _$ListResponseToJson;
  Map<String, dynamic> toJson() => _$ListResponseToJson(this);

  @JsonKey(name: 'entries', includeIfNull: false, defaultValue: <Entry>[])
  final List<Entry>? entries;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  static const fromJsonFactory = _$ListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ListResponse &&
            (identical(other.entries, entries) || const DeepCollectionEquality().equals(other.entries, entries)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entries) ^ const DeepCollectionEquality().hash(path) ^ runtimeType.hashCode;
}

extension $ListResponseExtension on ListResponse {
  ListResponse copyWith({List<Entry>? entries, String? path}) {
    return ListResponse(entries: entries ?? this.entries, path: path ?? this.path);
  }

  ListResponse copyWithWrapped({Wrapped<List<Entry>?>? entries, Wrapped<String>? path}) {
    return ListResponse(
      entries: (entries != null ? entries.value : this.entries),
      path: (path != null ? path.value : this.path),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Manifest {
  const Manifest({this.chunks, required this.hash, required this.path, required this.rev, required this.size});

  factory Manifest.fromJson(Map<String, dynamic> json) => _$ManifestFromJson(json);

  static const toJsonFactory = _$ManifestToJson;
  Map<String, dynamic> toJson() => _$ManifestToJson(this);

  @JsonKey(name: 'chunks', includeIfNull: false, defaultValue: <Chunk>[])
  final List<Chunk>? chunks;
  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'rev', includeIfNull: false)
  final int rev;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$ManifestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Manifest &&
            (identical(other.chunks, chunks) || const DeepCollectionEquality().equals(other.chunks, chunks)) &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.rev, rev) || const DeepCollectionEquality().equals(other.rev, rev)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(chunks) ^
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(rev) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $ManifestExtension on Manifest {
  Manifest copyWith({List<Chunk>? chunks, String? hash, String? path, int? rev, int? size}) {
    return Manifest(
      chunks: chunks ?? this.chunks,
      hash: hash ?? this.hash,
      path: path ?? this.path,
      rev: rev ?? this.rev,
      size: size ?? this.size,
    );
  }

  Manifest copyWithWrapped({
    Wrapped<List<Chunk>?>? chunks,
    Wrapped<String>? hash,
    Wrapped<String>? path,
    Wrapped<int>? rev,
    Wrapped<int>? size,
  }) {
    return Manifest(
      chunks: (chunks != null ? chunks.value : this.chunks),
      hash: (hash != null ? hash.value : this.hash),
      path: (path != null ? path.value : this.path),
      rev: (rev != null ? rev.value : this.rev),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class MoveRequest {
  const MoveRequest({this.baseRev, required this.from, required this.to});

  factory MoveRequest.fromJson(Map<String, dynamic> json) => _$MoveRequestFromJson(json);

  static const toJsonFactory = _$MoveRequestToJson;
  Map<String, dynamic> toJson() => _$MoveRequestToJson(this);

  @JsonKey(name: 'baseRev', includeIfNull: false)
  final int? baseRev;
  @JsonKey(name: 'from', includeIfNull: false)
  final String from;
  @JsonKey(name: 'to', includeIfNull: false)
  final String to;
  static const fromJsonFactory = _$MoveRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MoveRequest &&
            (identical(other.baseRev, baseRev) || const DeepCollectionEquality().equals(other.baseRev, baseRev)) &&
            (identical(other.from, from) || const DeepCollectionEquality().equals(other.from, from)) &&
            (identical(other.to, to) || const DeepCollectionEquality().equals(other.to, to)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(baseRev) ^
      const DeepCollectionEquality().hash(from) ^
      const DeepCollectionEquality().hash(to) ^
      runtimeType.hashCode;
}

extension $MoveRequestExtension on MoveRequest {
  MoveRequest copyWith({int? baseRev, String? from, String? to}) {
    return MoveRequest(baseRev: baseRev ?? this.baseRev, from: from ?? this.from, to: to ?? this.to);
  }

  MoveRequest copyWithWrapped({Wrapped<int?>? baseRev, Wrapped<String>? from, Wrapped<String>? to}) {
    return MoveRequest(
      baseRev: (baseRev != null ? baseRev.value : this.baseRev),
      from: (from != null ? from.value : this.from),
      to: (to != null ? to.value : this.to),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NewUser {
  const NewUser({required this.password, this.quotaBytes, required this.role, required this.username});

  factory NewUser.fromJson(Map<String, dynamic> json) => _$NewUserFromJson(json);

  static const toJsonFactory = _$NewUserToJson;
  Map<String, dynamic> toJson() => _$NewUserToJson(this);

  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  @JsonKey(name: 'quotaBytes', includeIfNull: false)
  final int? quotaBytes;
  @JsonKey(name: 'role', includeIfNull: false, toJson: newUserRoleToJson, fromJson: newUserRoleFromJson)
  final enums.NewUserRole role;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  static const fromJsonFactory = _$NewUserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NewUser &&
            (identical(other.password, password) || const DeepCollectionEquality().equals(other.password, password)) &&
            (identical(other.quotaBytes, quotaBytes) ||
                const DeepCollectionEquality().equals(other.quotaBytes, quotaBytes)) &&
            (identical(other.role, role) || const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(quotaBytes) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $NewUserExtension on NewUser {
  NewUser copyWith({String? password, int? quotaBytes, enums.NewUserRole? role, String? username}) {
    return NewUser(
      password: password ?? this.password,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
      username: username ?? this.username,
    );
  }

  NewUser copyWithWrapped({
    Wrapped<String>? password,
    Wrapped<int?>? quotaBytes,
    Wrapped<enums.NewUserRole>? role,
    Wrapped<String>? username,
  }) {
    return NewUser(
      password: (password != null ? password.value : this.password),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PathRequest {
  const PathRequest({required this.path});

  factory PathRequest.fromJson(Map<String, dynamic> json) => _$PathRequestFromJson(json);

  static const toJsonFactory = _$PathRequestToJson;
  Map<String, dynamic> toJson() => _$PathRequestToJson(this);

  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  static const fromJsonFactory = _$PathRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PathRequest &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(path) ^ runtimeType.hashCode;
}

extension $PathRequestExtension on PathRequest {
  PathRequest copyWith({String? path}) {
    return PathRequest(path: path ?? this.path);
  }

  PathRequest copyWithWrapped({Wrapped<String>? path}) {
    return PathRequest(path: (path != null ? path.value : this.path));
  }
}

@JsonSerializable(explicitToJson: true)
class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) => _$RefreshRequestFromJson(json);

  static const toJsonFactory = _$RefreshRequestToJson;
  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);

  @JsonKey(name: 'refreshToken', includeIfNull: false)
  final String refreshToken;
  static const fromJsonFactory = _$RefreshRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RefreshRequest &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(other.refreshToken, refreshToken)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(refreshToken) ^ runtimeType.hashCode;
}

extension $RefreshRequestExtension on RefreshRequest {
  RefreshRequest copyWith({String? refreshToken}) {
    return RefreshRequest(refreshToken: refreshToken ?? this.refreshToken);
  }

  RefreshRequest copyWithWrapped({Wrapped<String>? refreshToken}) {
    return RefreshRequest(refreshToken: (refreshToken != null ? refreshToken.value : this.refreshToken));
  }
}

@JsonSerializable(explicitToJson: true)
class SetupStatus {
  const SetupStatus({required this.needsSetup});

  factory SetupStatus.fromJson(Map<String, dynamic> json) => _$SetupStatusFromJson(json);

  static const toJsonFactory = _$SetupStatusToJson;
  Map<String, dynamic> toJson() => _$SetupStatusToJson(this);

  @JsonKey(name: 'needsSetup', includeIfNull: false)
  final bool needsSetup;
  static const fromJsonFactory = _$SetupStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SetupStatus &&
            (identical(other.needsSetup, needsSetup) ||
                const DeepCollectionEquality().equals(other.needsSetup, needsSetup)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(needsSetup) ^ runtimeType.hashCode;
}

extension $SetupStatusExtension on SetupStatus {
  SetupStatus copyWith({bool? needsSetup}) {
    return SetupStatus(needsSetup: needsSetup ?? this.needsSetup);
  }

  SetupStatus copyWithWrapped({Wrapped<bool>? needsSetup}) {
    return SetupStatus(needsSetup: (needsSetup != null ? needsSetup.value : this.needsSetup));
  }
}

@JsonSerializable(explicitToJson: true)
class TokenPair {
  const TokenPair({required this.accessToken, required this.expiresIn, required this.refreshToken, required this.user});

  factory TokenPair.fromJson(Map<String, dynamic> json) => _$TokenPairFromJson(json);

  static const toJsonFactory = _$TokenPairToJson;
  Map<String, dynamic> toJson() => _$TokenPairToJson(this);

  @JsonKey(name: 'accessToken', includeIfNull: false)
  final String accessToken;
  @JsonKey(name: 'expiresIn', includeIfNull: false)
  final int expiresIn;
  @JsonKey(name: 'refreshToken', includeIfNull: false)
  final String refreshToken;
  @JsonKey(name: 'user', includeIfNull: false)
  final User user;
  static const fromJsonFactory = _$TokenPairFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenPair &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality().equals(other.accessToken, accessToken)) &&
            (identical(other.expiresIn, expiresIn) ||
                const DeepCollectionEquality().equals(other.expiresIn, expiresIn)) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(other.refreshToken, refreshToken)) &&
            (identical(other.user, user) || const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(expiresIn) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $TokenPairExtension on TokenPair {
  TokenPair copyWith({String? accessToken, int? expiresIn, String? refreshToken, User? user}) {
    return TokenPair(
      accessToken: accessToken ?? this.accessToken,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  TokenPair copyWithWrapped({
    Wrapped<String>? accessToken,
    Wrapped<int>? expiresIn,
    Wrapped<String>? refreshToken,
    Wrapped<User>? user,
  }) {
    return TokenPair(
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      expiresIn: (expiresIn != null ? expiresIn.value : this.expiresIn),
      refreshToken: (refreshToken != null ? refreshToken.value : this.refreshToken),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UploadRequest {
  const UploadRequest({
    this.baseRev,
    this.chunks,
    required this.hash,
    this.mtime,
    required this.path,
    required this.size,
  });

  factory UploadRequest.fromJson(Map<String, dynamic> json) => _$UploadRequestFromJson(json);

  static const toJsonFactory = _$UploadRequestToJson;
  Map<String, dynamic> toJson() => _$UploadRequestToJson(this);

  @JsonKey(name: 'baseRev', includeIfNull: false)
  final int? baseRev;
  @JsonKey(name: 'chunks', includeIfNull: false, defaultValue: <ChunkRef>[])
  final List<ChunkRef>? chunks;
  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'mtime', includeIfNull: false)
  final DateTime? mtime;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$UploadRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UploadRequest &&
            (identical(other.baseRev, baseRev) || const DeepCollectionEquality().equals(other.baseRev, baseRev)) &&
            (identical(other.chunks, chunks) || const DeepCollectionEquality().equals(other.chunks, chunks)) &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.mtime, mtime) || const DeepCollectionEquality().equals(other.mtime, mtime)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(baseRev) ^
      const DeepCollectionEquality().hash(chunks) ^
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(mtime) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $UploadRequestExtension on UploadRequest {
  UploadRequest copyWith({
    int? baseRev,
    List<ChunkRef>? chunks,
    String? hash,
    DateTime? mtime,
    String? path,
    int? size,
  }) {
    return UploadRequest(
      baseRev: baseRev ?? this.baseRev,
      chunks: chunks ?? this.chunks,
      hash: hash ?? this.hash,
      mtime: mtime ?? this.mtime,
      path: path ?? this.path,
      size: size ?? this.size,
    );
  }

  UploadRequest copyWithWrapped({
    Wrapped<int?>? baseRev,
    Wrapped<List<ChunkRef>?>? chunks,
    Wrapped<String>? hash,
    Wrapped<DateTime?>? mtime,
    Wrapped<String>? path,
    Wrapped<int>? size,
  }) {
    return UploadRequest(
      baseRev: (baseRev != null ? baseRev.value : this.baseRev),
      chunks: (chunks != null ? chunks.value : this.chunks),
      hash: (hash != null ? hash.value : this.hash),
      mtime: (mtime != null ? mtime.value : this.mtime),
      path: (path != null ? path.value : this.path),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UploadStatus {
  const UploadStatus({this.missing, required this.uploadId});

  factory UploadStatus.fromJson(Map<String, dynamic> json) => _$UploadStatusFromJson(json);

  static const toJsonFactory = _$UploadStatusToJson;
  Map<String, dynamic> toJson() => _$UploadStatusToJson(this);

  @JsonKey(name: 'missing', includeIfNull: false, defaultValue: <String>[])
  final List<String>? missing;
  @JsonKey(name: 'uploadId', includeIfNull: false)
  final String uploadId;
  static const fromJsonFactory = _$UploadStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UploadStatus &&
            (identical(other.missing, missing) || const DeepCollectionEquality().equals(other.missing, missing)) &&
            (identical(other.uploadId, uploadId) || const DeepCollectionEquality().equals(other.uploadId, uploadId)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(missing) ^
      const DeepCollectionEquality().hash(uploadId) ^
      runtimeType.hashCode;
}

extension $UploadStatusExtension on UploadStatus {
  UploadStatus copyWith({List<String>? missing, String? uploadId}) {
    return UploadStatus(missing: missing ?? this.missing, uploadId: uploadId ?? this.uploadId);
  }

  UploadStatus copyWithWrapped({Wrapped<List<String>?>? missing, Wrapped<String>? uploadId}) {
    return UploadStatus(
      missing: (missing != null ? missing.value : this.missing),
      uploadId: (uploadId != null ? uploadId.value : this.uploadId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class User {
  const User({
    required this.createdAt,
    required this.disabled,
    required this.id,
    required this.quotaBytes,
    required this.role,
    required this.usedBytes,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  static const toJsonFactory = _$UserToJson;
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool disabled;
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
  @JsonKey(name: 'quotaBytes', includeIfNull: false)
  final int quotaBytes;
  @JsonKey(name: 'role', includeIfNull: false, toJson: userRoleToJson, fromJson: userRoleFromJson)
  final enums.UserRole role;
  @JsonKey(name: 'usedBytes', includeIfNull: false)
  final int usedBytes;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  static const fromJsonFactory = _$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is User &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(other.createdAt, createdAt)) &&
            (identical(other.disabled, disabled) || const DeepCollectionEquality().equals(other.disabled, disabled)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.quotaBytes, quotaBytes) ||
                const DeepCollectionEquality().equals(other.quotaBytes, quotaBytes)) &&
            (identical(other.role, role) || const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.usedBytes, usedBytes) ||
                const DeepCollectionEquality().equals(other.usedBytes, usedBytes)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(quotaBytes) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(usedBytes) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $UserExtension on User {
  User copyWith({
    DateTime? createdAt,
    bool? disabled,
    int? id,
    int? quotaBytes,
    enums.UserRole? role,
    int? usedBytes,
    String? username,
  }) {
    return User(
      createdAt: createdAt ?? this.createdAt,
      disabled: disabled ?? this.disabled,
      id: id ?? this.id,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
      usedBytes: usedBytes ?? this.usedBytes,
      username: username ?? this.username,
    );
  }

  User copyWithWrapped({
    Wrapped<DateTime>? createdAt,
    Wrapped<bool>? disabled,
    Wrapped<int>? id,
    Wrapped<int>? quotaBytes,
    Wrapped<enums.UserRole>? role,
    Wrapped<int>? usedBytes,
    Wrapped<String>? username,
  }) {
    return User(
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      disabled: (disabled != null ? disabled.value : this.disabled),
      id: (id != null ? id.value : this.id),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
      usedBytes: (usedBytes != null ? usedBytes.value : this.usedBytes),
      username: (username != null ? username.value : this.username),
    );
  }
}

String? changeTypeNullableToJson(enums.ChangeType? changeType) {
  return changeType?.value;
}

String? changeTypeToJson(enums.ChangeType changeType) {
  return changeType.value;
}

enums.ChangeType changeTypeFromJson(Object? changeType, [enums.ChangeType? defaultValue]) {
  return enums.ChangeType.values.firstWhereOrNull((e) => e.value == changeType) ??
      defaultValue ??
      enums.ChangeType.swaggerGeneratedUnknown;
}

enums.ChangeType? changeTypeNullableFromJson(Object? changeType, [enums.ChangeType? defaultValue]) {
  if (changeType == null) {
    return null;
  }
  return enums.ChangeType.values.firstWhereOrNull((e) => e.value == changeType) ?? defaultValue;
}

String changeTypeExplodedListToJson(List<enums.ChangeType>? changeType) {
  return changeType?.map((e) => e.value!).join(',') ?? '';
}

List<String> changeTypeListToJson(List<enums.ChangeType>? changeType) {
  if (changeType == null) {
    return [];
  }

  return changeType.map((e) => e.value!).toList();
}

List<enums.ChangeType> changeTypeListFromJson(List? changeType, [List<enums.ChangeType>? defaultValue]) {
  if (changeType == null) {
    return defaultValue ?? [];
  }

  return changeType.map((e) => changeTypeFromJson(e.toString())).toList();
}

List<enums.ChangeType>? changeTypeNullableListFromJson(List? changeType, [List<enums.ChangeType>? defaultValue]) {
  if (changeType == null) {
    return defaultValue;
  }

  return changeType.map((e) => changeTypeFromJson(e.toString())).toList();
}

String? changesRoleNullableToJson(enums.ChangesRole? changesRole) {
  return changesRole?.value;
}

String? changesRoleToJson(enums.ChangesRole changesRole) {
  return changesRole.value;
}

enums.ChangesRole changesRoleFromJson(Object? changesRole, [enums.ChangesRole? defaultValue]) {
  return enums.ChangesRole.values.firstWhereOrNull((e) => e.value == changesRole) ??
      defaultValue ??
      enums.ChangesRole.swaggerGeneratedUnknown;
}

enums.ChangesRole? changesRoleNullableFromJson(Object? changesRole, [enums.ChangesRole? defaultValue]) {
  if (changesRole == null) {
    return null;
  }
  return enums.ChangesRole.values.firstWhereOrNull((e) => e.value == changesRole) ?? defaultValue;
}

String changesRoleExplodedListToJson(List<enums.ChangesRole>? changesRole) {
  return changesRole?.map((e) => e.value!).join(',') ?? '';
}

List<String> changesRoleListToJson(List<enums.ChangesRole>? changesRole) {
  if (changesRole == null) {
    return [];
  }

  return changesRole.map((e) => e.value!).toList();
}

List<enums.ChangesRole> changesRoleListFromJson(List? changesRole, [List<enums.ChangesRole>? defaultValue]) {
  if (changesRole == null) {
    return defaultValue ?? [];
  }

  return changesRole.map((e) => changesRoleFromJson(e.toString())).toList();
}

List<enums.ChangesRole>? changesRoleNullableListFromJson(List? changesRole, [List<enums.ChangesRole>? defaultValue]) {
  if (changesRole == null) {
    return defaultValue;
  }

  return changesRole.map((e) => changesRoleFromJson(e.toString())).toList();
}

String? entryPreviewStateNullableToJson(enums.EntryPreviewState? entryPreviewState) {
  return entryPreviewState?.value;
}

String? entryPreviewStateToJson(enums.EntryPreviewState entryPreviewState) {
  return entryPreviewState.value;
}

enums.EntryPreviewState entryPreviewStateFromJson(Object? entryPreviewState, [enums.EntryPreviewState? defaultValue]) {
  return enums.EntryPreviewState.values.firstWhereOrNull((e) => e.value == entryPreviewState) ??
      defaultValue ??
      enums.EntryPreviewState.swaggerGeneratedUnknown;
}

enums.EntryPreviewState? entryPreviewStateNullableFromJson(
  Object? entryPreviewState, [
  enums.EntryPreviewState? defaultValue,
]) {
  if (entryPreviewState == null) {
    return null;
  }
  return enums.EntryPreviewState.values.firstWhereOrNull((e) => e.value == entryPreviewState) ?? defaultValue;
}

String entryPreviewStateExplodedListToJson(List<enums.EntryPreviewState>? entryPreviewState) {
  return entryPreviewState?.map((e) => e.value!).join(',') ?? '';
}

List<String> entryPreviewStateListToJson(List<enums.EntryPreviewState>? entryPreviewState) {
  if (entryPreviewState == null) {
    return [];
  }

  return entryPreviewState.map((e) => e.value!).toList();
}

List<enums.EntryPreviewState> entryPreviewStateListFromJson(
  List? entryPreviewState, [
  List<enums.EntryPreviewState>? defaultValue,
]) {
  if (entryPreviewState == null) {
    return defaultValue ?? [];
  }

  return entryPreviewState.map((e) => entryPreviewStateFromJson(e.toString())).toList();
}

List<enums.EntryPreviewState>? entryPreviewStateNullableListFromJson(
  List? entryPreviewState, [
  List<enums.EntryPreviewState>? defaultValue,
]) {
  if (entryPreviewState == null) {
    return defaultValue;
  }

  return entryPreviewState.map((e) => entryPreviewStateFromJson(e.toString())).toList();
}

String? newUserRoleNullableToJson(enums.NewUserRole? newUserRole) {
  return newUserRole?.value;
}

String? newUserRoleToJson(enums.NewUserRole newUserRole) {
  return newUserRole.value;
}

enums.NewUserRole newUserRoleFromJson(Object? newUserRole, [enums.NewUserRole? defaultValue]) {
  return enums.NewUserRole.values.firstWhereOrNull((e) => e.value == newUserRole) ??
      defaultValue ??
      enums.NewUserRole.swaggerGeneratedUnknown;
}

enums.NewUserRole? newUserRoleNullableFromJson(Object? newUserRole, [enums.NewUserRole? defaultValue]) {
  if (newUserRole == null) {
    return null;
  }
  return enums.NewUserRole.values.firstWhereOrNull((e) => e.value == newUserRole) ?? defaultValue;
}

String newUserRoleExplodedListToJson(List<enums.NewUserRole>? newUserRole) {
  return newUserRole?.map((e) => e.value!).join(',') ?? '';
}

List<String> newUserRoleListToJson(List<enums.NewUserRole>? newUserRole) {
  if (newUserRole == null) {
    return [];
  }

  return newUserRole.map((e) => e.value!).toList();
}

List<enums.NewUserRole> newUserRoleListFromJson(List? newUserRole, [List<enums.NewUserRole>? defaultValue]) {
  if (newUserRole == null) {
    return defaultValue ?? [];
  }

  return newUserRole.map((e) => newUserRoleFromJson(e.toString())).toList();
}

List<enums.NewUserRole>? newUserRoleNullableListFromJson(List? newUserRole, [List<enums.NewUserRole>? defaultValue]) {
  if (newUserRole == null) {
    return defaultValue;
  }

  return newUserRole.map((e) => newUserRoleFromJson(e.toString())).toList();
}

String? userRoleNullableToJson(enums.UserRole? userRole) {
  return userRole?.value;
}

String? userRoleToJson(enums.UserRole userRole) {
  return userRole.value;
}

enums.UserRole userRoleFromJson(Object? userRole, [enums.UserRole? defaultValue]) {
  return enums.UserRole.values.firstWhereOrNull((e) => e.value == userRole) ??
      defaultValue ??
      enums.UserRole.swaggerGeneratedUnknown;
}

enums.UserRole? userRoleNullableFromJson(Object? userRole, [enums.UserRole? defaultValue]) {
  if (userRole == null) {
    return null;
  }
  return enums.UserRole.values.firstWhereOrNull((e) => e.value == userRole) ?? defaultValue;
}

String userRoleExplodedListToJson(List<enums.UserRole>? userRole) {
  return userRole?.map((e) => e.value!).join(',') ?? '';
}

List<String> userRoleListToJson(List<enums.UserRole>? userRole) {
  if (userRole == null) {
    return [];
  }

  return userRole.map((e) => e.value!).toList();
}

List<enums.UserRole> userRoleListFromJson(List? userRole, [List<enums.UserRole>? defaultValue]) {
  if (userRole == null) {
    return defaultValue ?? [];
  }

  return userRole.map((e) => userRoleFromJson(e.toString())).toList();
}

List<enums.UserRole>? userRoleNullableListFromJson(List? userRole, [List<enums.UserRole>? defaultValue]) {
  if (userRole == null) {
    return defaultValue;
  }

  return userRole.map((e) => userRoleFromJson(e.toString())).toList();
}

int? apiV1FilesPreviewGetSizeNullableToJson(enums.ApiV1FilesPreviewGetSize? apiV1FilesPreviewGetSize) {
  return apiV1FilesPreviewGetSize?.value;
}

int? apiV1FilesPreviewGetSizeToJson(enums.ApiV1FilesPreviewGetSize apiV1FilesPreviewGetSize) {
  return apiV1FilesPreviewGetSize.value;
}

enums.ApiV1FilesPreviewGetSize apiV1FilesPreviewGetSizeFromJson(
  Object? apiV1FilesPreviewGetSize, [
  enums.ApiV1FilesPreviewGetSize? defaultValue,
]) {
  return enums.ApiV1FilesPreviewGetSize.values.firstWhereOrNull((e) => e.value == apiV1FilesPreviewGetSize) ??
      defaultValue ??
      enums.ApiV1FilesPreviewGetSize.swaggerGeneratedUnknown;
}

enums.ApiV1FilesPreviewGetSize? apiV1FilesPreviewGetSizeNullableFromJson(
  Object? apiV1FilesPreviewGetSize, [
  enums.ApiV1FilesPreviewGetSize? defaultValue,
]) {
  if (apiV1FilesPreviewGetSize == null) {
    return null;
  }
  return enums.ApiV1FilesPreviewGetSize.values.firstWhereOrNull((e) => e.value == apiV1FilesPreviewGetSize) ??
      defaultValue;
}

String apiV1FilesPreviewGetSizeExplodedListToJson(List<enums.ApiV1FilesPreviewGetSize>? apiV1FilesPreviewGetSize) {
  return apiV1FilesPreviewGetSize?.map((e) => e.value!).join(',') ?? '';
}

List<int> apiV1FilesPreviewGetSizeListToJson(List<enums.ApiV1FilesPreviewGetSize>? apiV1FilesPreviewGetSize) {
  if (apiV1FilesPreviewGetSize == null) {
    return [];
  }

  return apiV1FilesPreviewGetSize.map((e) => e.value!).toList();
}

List<enums.ApiV1FilesPreviewGetSize> apiV1FilesPreviewGetSizeListFromJson(
  List? apiV1FilesPreviewGetSize, [
  List<enums.ApiV1FilesPreviewGetSize>? defaultValue,
]) {
  if (apiV1FilesPreviewGetSize == null) {
    return defaultValue ?? [];
  }

  return apiV1FilesPreviewGetSize.map((e) => apiV1FilesPreviewGetSizeFromJson(e)).toList();
}

List<enums.ApiV1FilesPreviewGetSize>? apiV1FilesPreviewGetSizeNullableListFromJson(
  List? apiV1FilesPreviewGetSize, [
  List<enums.ApiV1FilesPreviewGetSize>? defaultValue,
]) {
  if (apiV1FilesPreviewGetSize == null) {
    return defaultValue;
  }

  return apiV1FilesPreviewGetSize.map((e) => apiV1FilesPreviewGetSizeFromJson(e)).toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
