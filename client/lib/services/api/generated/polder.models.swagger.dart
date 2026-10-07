// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import 'dart:convert';

import 'polder.enums.swagger.dart' as enums;

part 'polder.models.swagger.g.dart';

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
  const Changes({this.disabled, this.password, this.quotaBytes, this.role, this.trashRetentionOverrideDays});

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
  @JsonKey(name: 'trashRetentionOverrideDays', includeIfNull: false)
  final int? trashRetentionOverrideDays;
  static const fromJsonFactory = _$ChangesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Changes &&
            (identical(other.disabled, disabled) || const DeepCollectionEquality().equals(other.disabled, disabled)) &&
            (identical(other.password, password) || const DeepCollectionEquality().equals(other.password, password)) &&
            (identical(other.quotaBytes, quotaBytes) ||
                const DeepCollectionEquality().equals(other.quotaBytes, quotaBytes)) &&
            (identical(other.role, role) || const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.trashRetentionOverrideDays, trashRetentionOverrideDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionOverrideDays, trashRetentionOverrideDays)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(quotaBytes) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(trashRetentionOverrideDays) ^
      runtimeType.hashCode;
}

extension $ChangesExtension on Changes {
  Changes copyWith({
    bool? disabled,
    String? password,
    int? quotaBytes,
    enums.ChangesRole? role,
    int? trashRetentionOverrideDays,
  }) {
    return Changes(
      disabled: disabled ?? this.disabled,
      password: password ?? this.password,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
      trashRetentionOverrideDays: trashRetentionOverrideDays ?? this.trashRetentionOverrideDays,
    );
  }

  Changes copyWithWrapped({
    Wrapped<bool?>? disabled,
    Wrapped<String?>? password,
    Wrapped<int?>? quotaBytes,
    Wrapped<enums.ChangesRole?>? role,
    Wrapped<int?>? trashRetentionOverrideDays,
  }) {
    return Changes(
      disabled: (disabled != null ? disabled.value : this.disabled),
      password: (password != null ? password.value : this.password),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
      trashRetentionOverrideDays: (trashRetentionOverrideDays != null
          ? trashRetentionOverrideDays.value
          : this.trashRetentionOverrideDays),
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
class ClientMessage {
  const ClientMessage({this.scope, this.token, required this.type, this.userId});

  factory ClientMessage.fromJson(Map<String, dynamic> json) => _$ClientMessageFromJson(json);

  static const toJsonFactory = _$ClientMessageToJson;
  Map<String, dynamic> toJson() => _$ClientMessageToJson(this);

  @JsonKey(
    name: 'scope',
    includeIfNull: false,
    toJson: clientMessageScopeNullableToJson,
    fromJson: clientMessageScopeNullableFromJson,
  )
  final enums.ClientMessageScope? scope;
  @JsonKey(name: 'token', includeIfNull: false)
  final String? token;
  @JsonKey(name: 'type', includeIfNull: false, toJson: clientMessageTypeToJson, fromJson: clientMessageTypeFromJson)
  final enums.ClientMessageType type;
  @JsonKey(name: 'userId', includeIfNull: false)
  final int? userId;
  static const fromJsonFactory = _$ClientMessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ClientMessage &&
            (identical(other.scope, scope) || const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.token, token) || const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.type, type) || const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.userId, userId) || const DeepCollectionEquality().equals(other.userId, userId)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(userId) ^
      runtimeType.hashCode;
}

extension $ClientMessageExtension on ClientMessage {
  ClientMessage copyWith({enums.ClientMessageScope? scope, String? token, enums.ClientMessageType? type, int? userId}) {
    return ClientMessage(
      scope: scope ?? this.scope,
      token: token ?? this.token,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }

  ClientMessage copyWithWrapped({
    Wrapped<enums.ClientMessageScope?>? scope,
    Wrapped<String?>? token,
    Wrapped<enums.ClientMessageType>? type,
    Wrapped<int?>? userId,
  }) {
    return ClientMessage(
      scope: (scope != null ? scope.value : this.scope),
      token: (token != null ? token.value : this.token),
      type: (type != null ? type.value : this.type),
      userId: (userId != null ? userId.value : this.userId),
    );
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
class EventMessage {
  const EventMessage({
    this.code,
    this.dirs,
    this.entry,
    this.message,
    this.status,
    this.transfer,
    this.transfers,
    required this.type,
    this.user,
    required this.userId,
  });

  factory EventMessage.fromJson(Map<String, dynamic> json) => _$EventMessageFromJson(json);

  static const toJsonFactory = _$EventMessageToJson;
  Map<String, dynamic> toJson() => _$EventMessageToJson(this);

  @JsonKey(name: 'code', includeIfNull: false)
  final String? code;
  @JsonKey(name: 'dirs', includeIfNull: false, defaultValue: <String>[])
  final List<String>? dirs;
  @JsonKey(name: 'entry', includeIfNull: false)
  final LogEntry? entry;
  @JsonKey(name: 'message', includeIfNull: false)
  final String? message;
  @JsonKey(
    name: 'status',
    includeIfNull: false,
    toJson: eventMessageStatusNullableToJson,
    fromJson: eventMessageStatusNullableFromJson,
  )
  final enums.EventMessageStatus? status;
  @JsonKey(name: 'transfer', includeIfNull: false)
  final LiveTransfer? transfer;
  @JsonKey(name: 'transfers', includeIfNull: false, defaultValue: <LiveTransfer>[])
  final List<LiveTransfer>? transfers;
  @JsonKey(name: 'type', includeIfNull: false, toJson: eventMessageTypeToJson, fromJson: eventMessageTypeFromJson)
  final enums.EventMessageType type;
  @JsonKey(name: 'user', includeIfNull: false)
  final User? user;
  @JsonKey(name: 'userId', includeIfNull: false)
  final int userId;
  static const fromJsonFactory = _$EventMessageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EventMessage &&
            (identical(other.code, code) || const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.dirs, dirs) || const DeepCollectionEquality().equals(other.dirs, dirs)) &&
            (identical(other.entry, entry) || const DeepCollectionEquality().equals(other.entry, entry)) &&
            (identical(other.message, message) || const DeepCollectionEquality().equals(other.message, message)) &&
            (identical(other.status, status) || const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.transfer, transfer) || const DeepCollectionEquality().equals(other.transfer, transfer)) &&
            (identical(other.transfers, transfers) ||
                const DeepCollectionEquality().equals(other.transfers, transfers)) &&
            (identical(other.type, type) || const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.user, user) || const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.userId, userId) || const DeepCollectionEquality().equals(other.userId, userId)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(code) ^
      const DeepCollectionEquality().hash(dirs) ^
      const DeepCollectionEquality().hash(entry) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(transfer) ^
      const DeepCollectionEquality().hash(transfers) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(userId) ^
      runtimeType.hashCode;
}

extension $EventMessageExtension on EventMessage {
  EventMessage copyWith({
    String? code,
    List<String>? dirs,
    LogEntry? entry,
    String? message,
    enums.EventMessageStatus? status,
    LiveTransfer? transfer,
    List<LiveTransfer>? transfers,
    enums.EventMessageType? type,
    User? user,
    int? userId,
  }) {
    return EventMessage(
      code: code ?? this.code,
      dirs: dirs ?? this.dirs,
      entry: entry ?? this.entry,
      message: message ?? this.message,
      status: status ?? this.status,
      transfer: transfer ?? this.transfer,
      transfers: transfers ?? this.transfers,
      type: type ?? this.type,
      user: user ?? this.user,
      userId: userId ?? this.userId,
    );
  }

  EventMessage copyWithWrapped({
    Wrapped<String?>? code,
    Wrapped<List<String>?>? dirs,
    Wrapped<LogEntry?>? entry,
    Wrapped<String?>? message,
    Wrapped<enums.EventMessageStatus?>? status,
    Wrapped<LiveTransfer?>? transfer,
    Wrapped<List<LiveTransfer>?>? transfers,
    Wrapped<enums.EventMessageType>? type,
    Wrapped<User?>? user,
    Wrapped<int>? userId,
  }) {
    return EventMessage(
      code: (code != null ? code.value : this.code),
      dirs: (dirs != null ? dirs.value : this.dirs),
      entry: (entry != null ? entry.value : this.entry),
      message: (message != null ? message.value : this.message),
      status: (status != null ? status.value : this.status),
      transfer: (transfer != null ? transfer.value : this.transfer),
      transfers: (transfers != null ? transfers.value : this.transfers),
      type: (type != null ? type.value : this.type),
      user: (user != null ? user.value : this.user),
      userId: (userId != null ? userId.value : this.userId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExtractionStatus {
  const ExtractionStatus({required this.ocr, this.ocrProblem, required this.pending});

  factory ExtractionStatus.fromJson(Map<String, dynamic> json) => _$ExtractionStatusFromJson(json);

  static const toJsonFactory = _$ExtractionStatusToJson;
  Map<String, dynamic> toJson() => _$ExtractionStatusToJson(this);

  @JsonKey(name: 'ocr', includeIfNull: false, toJson: extractionStatusOcrToJson, fromJson: extractionStatusOcrFromJson)
  final enums.ExtractionStatusOcr ocr;
  @JsonKey(name: 'ocrProblem', includeIfNull: false)
  final String? ocrProblem;
  @JsonKey(name: 'pending', includeIfNull: false)
  final int pending;
  static const fromJsonFactory = _$ExtractionStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ExtractionStatus &&
            (identical(other.ocr, ocr) || const DeepCollectionEquality().equals(other.ocr, ocr)) &&
            (identical(other.ocrProblem, ocrProblem) ||
                const DeepCollectionEquality().equals(other.ocrProblem, ocrProblem)) &&
            (identical(other.pending, pending) || const DeepCollectionEquality().equals(other.pending, pending)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(ocr) ^
      const DeepCollectionEquality().hash(ocrProblem) ^
      const DeepCollectionEquality().hash(pending) ^
      runtimeType.hashCode;
}

extension $ExtractionStatusExtension on ExtractionStatus {
  ExtractionStatus copyWith({enums.ExtractionStatusOcr? ocr, String? ocrProblem, int? pending}) {
    return ExtractionStatus(
      ocr: ocr ?? this.ocr,
      ocrProblem: ocrProblem ?? this.ocrProblem,
      pending: pending ?? this.pending,
    );
  }

  ExtractionStatus copyWithWrapped({
    Wrapped<enums.ExtractionStatusOcr>? ocr,
    Wrapped<String?>? ocrProblem,
    Wrapped<int>? pending,
  }) {
    return ExtractionStatus(
      ocr: (ocr != null ? ocr.value : this.ocr),
      ocrProblem: (ocrProblem != null ? ocrProblem.value : this.ocrProblem),
      pending: (pending != null ? pending.value : this.pending),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FacetCount {
  const FacetCount({required this.count, required this.value});

  factory FacetCount.fromJson(Map<String, dynamic> json) => _$FacetCountFromJson(json);

  static const toJsonFactory = _$FacetCountToJson;
  Map<String, dynamic> toJson() => _$FacetCountToJson(this);

  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'value', includeIfNull: false)
  final String value;
  static const fromJsonFactory = _$FacetCountFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FacetCount &&
            (identical(other.count, count) || const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.value, value) || const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^ const DeepCollectionEquality().hash(value) ^ runtimeType.hashCode;
}

extension $FacetCountExtension on FacetCount {
  FacetCount copyWith({int? count, String? value}) {
    return FacetCount(count: count ?? this.count, value: value ?? this.value);
  }

  FacetCount copyWithWrapped({Wrapped<int>? count, Wrapped<String>? value}) {
    return FacetCount(
      count: (count != null ? count.value : this.count),
      value: (value != null ? value.value : this.value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Facets {
  const Facets({this.exts, this.types});

  factory Facets.fromJson(Map<String, dynamic> json) => _$FacetsFromJson(json);

  static const toJsonFactory = _$FacetsToJson;
  Map<String, dynamic> toJson() => _$FacetsToJson(this);

  @JsonKey(name: 'exts', includeIfNull: false, defaultValue: <FacetCount>[])
  final List<FacetCount>? exts;
  @JsonKey(name: 'types', includeIfNull: false, defaultValue: <FacetCount>[])
  final List<FacetCount>? types;
  static const fromJsonFactory = _$FacetsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Facets &&
            (identical(other.exts, exts) || const DeepCollectionEquality().equals(other.exts, exts)) &&
            (identical(other.types, types) || const DeepCollectionEquality().equals(other.types, types)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(exts) ^ const DeepCollectionEquality().hash(types) ^ runtimeType.hashCode;
}

extension $FacetsExtension on Facets {
  Facets copyWith({List<FacetCount>? exts, List<FacetCount>? types}) {
    return Facets(exts: exts ?? this.exts, types: types ?? this.types);
  }

  Facets copyWithWrapped({Wrapped<List<FacetCount>?>? exts, Wrapped<List<FacetCount>?>? types}) {
    return Facets(exts: (exts != null ? exts.value : this.exts), types: (types != null ? types.value : this.types));
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
  const ListResponse({this.entries, required this.indexing, required this.path});

  factory ListResponse.fromJson(Map<String, dynamic> json) => _$ListResponseFromJson(json);

  static const toJsonFactory = _$ListResponseToJson;
  Map<String, dynamic> toJson() => _$ListResponseToJson(this);

  @JsonKey(name: 'entries', includeIfNull: false, defaultValue: <Entry>[])
  final List<Entry>? entries;
  @JsonKey(name: 'indexing', includeIfNull: false)
  final bool indexing;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  static const fromJsonFactory = _$ListResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ListResponse &&
            (identical(other.entries, entries) || const DeepCollectionEquality().equals(other.entries, entries)) &&
            (identical(other.indexing, indexing) || const DeepCollectionEquality().equals(other.indexing, indexing)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entries) ^
      const DeepCollectionEquality().hash(indexing) ^
      const DeepCollectionEquality().hash(path) ^
      runtimeType.hashCode;
}

extension $ListResponseExtension on ListResponse {
  ListResponse copyWith({List<Entry>? entries, bool? indexing, String? path}) {
    return ListResponse(entries: entries ?? this.entries, indexing: indexing ?? this.indexing, path: path ?? this.path);
  }

  ListResponse copyWithWrapped({Wrapped<List<Entry>?>? entries, Wrapped<bool>? indexing, Wrapped<String>? path}) {
    return ListResponse(
      entries: (entries != null ? entries.value : this.entries),
      indexing: (indexing != null ? indexing.value : this.indexing),
      path: (path != null ? path.value : this.path),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LiveTransfer {
  const LiveTransfer({
    required this.bytes,
    this.clientId,
    required this.device,
    required this.direction,
    required this.id,
    required this.path,
    required this.rate,
    required this.startedAt,
    this.total,
    required this.userId,
    required this.username,
  });

  factory LiveTransfer.fromJson(Map<String, dynamic> json) => _$LiveTransferFromJson(json);

  static const toJsonFactory = _$LiveTransferToJson;
  Map<String, dynamic> toJson() => _$LiveTransferToJson(this);

  @JsonKey(name: 'bytes', includeIfNull: false)
  final int bytes;
  @JsonKey(name: 'clientId', includeIfNull: false)
  final String? clientId;
  @JsonKey(name: 'device', includeIfNull: false)
  final String device;
  @JsonKey(
    name: 'direction',
    includeIfNull: false,
    toJson: liveTransferDirectionToJson,
    fromJson: liveTransferDirectionFromJson,
  )
  final enums.LiveTransferDirection direction;
  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'rate', includeIfNull: false)
  final int rate;
  @JsonKey(name: 'startedAt', includeIfNull: false)
  final DateTime startedAt;
  @JsonKey(name: 'total', includeIfNull: false)
  final int? total;
  @JsonKey(name: 'userId', includeIfNull: false)
  final int userId;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  static const fromJsonFactory = _$LiveTransferFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LiveTransfer &&
            (identical(other.bytes, bytes) || const DeepCollectionEquality().equals(other.bytes, bytes)) &&
            (identical(other.clientId, clientId) || const DeepCollectionEquality().equals(other.clientId, clientId)) &&
            (identical(other.device, device) || const DeepCollectionEquality().equals(other.device, device)) &&
            (identical(other.direction, direction) ||
                const DeepCollectionEquality().equals(other.direction, direction)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.rate, rate) || const DeepCollectionEquality().equals(other.rate, rate)) &&
            (identical(other.startedAt, startedAt) ||
                const DeepCollectionEquality().equals(other.startedAt, startedAt)) &&
            (identical(other.total, total) || const DeepCollectionEquality().equals(other.total, total)) &&
            (identical(other.userId, userId) || const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bytes) ^
      const DeepCollectionEquality().hash(clientId) ^
      const DeepCollectionEquality().hash(device) ^
      const DeepCollectionEquality().hash(direction) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(rate) ^
      const DeepCollectionEquality().hash(startedAt) ^
      const DeepCollectionEquality().hash(total) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $LiveTransferExtension on LiveTransfer {
  LiveTransfer copyWith({
    int? bytes,
    String? clientId,
    String? device,
    enums.LiveTransferDirection? direction,
    String? id,
    String? path,
    int? rate,
    DateTime? startedAt,
    int? total,
    int? userId,
    String? username,
  }) {
    return LiveTransfer(
      bytes: bytes ?? this.bytes,
      clientId: clientId ?? this.clientId,
      device: device ?? this.device,
      direction: direction ?? this.direction,
      id: id ?? this.id,
      path: path ?? this.path,
      rate: rate ?? this.rate,
      startedAt: startedAt ?? this.startedAt,
      total: total ?? this.total,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }

  LiveTransfer copyWithWrapped({
    Wrapped<int>? bytes,
    Wrapped<String?>? clientId,
    Wrapped<String>? device,
    Wrapped<enums.LiveTransferDirection>? direction,
    Wrapped<String>? id,
    Wrapped<String>? path,
    Wrapped<int>? rate,
    Wrapped<DateTime>? startedAt,
    Wrapped<int?>? total,
    Wrapped<int>? userId,
    Wrapped<String>? username,
  }) {
    return LiveTransfer(
      bytes: (bytes != null ? bytes.value : this.bytes),
      clientId: (clientId != null ? clientId.value : this.clientId),
      device: (device != null ? device.value : this.device),
      direction: (direction != null ? direction.value : this.direction),
      id: (id != null ? id.value : this.id),
      path: (path != null ? path.value : this.path),
      rate: (rate != null ? rate.value : this.rate),
      startedAt: (startedAt != null ? startedAt.value : this.startedAt),
      total: (total != null ? total.value : this.total),
      userId: (userId != null ? userId.value : this.userId),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LiveTransfers {
  const LiveTransfers({this.transfers});

  factory LiveTransfers.fromJson(Map<String, dynamic> json) => _$LiveTransfersFromJson(json);

  static const toJsonFactory = _$LiveTransfersToJson;
  Map<String, dynamic> toJson() => _$LiveTransfersToJson(this);

  @JsonKey(name: 'transfers', includeIfNull: false, defaultValue: <LiveTransfer>[])
  final List<LiveTransfer>? transfers;
  static const fromJsonFactory = _$LiveTransfersFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LiveTransfers &&
            (identical(other.transfers, transfers) ||
                const DeepCollectionEquality().equals(other.transfers, transfers)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(transfers) ^ runtimeType.hashCode;
}

extension $LiveTransfersExtension on LiveTransfers {
  LiveTransfers copyWith({List<LiveTransfer>? transfers}) {
    return LiveTransfers(transfers: transfers ?? this.transfers);
  }

  LiveTransfers copyWithWrapped({Wrapped<List<LiveTransfer>?>? transfers}) {
    return LiveTransfers(transfers: (transfers != null ? transfers.value : this.transfers));
  }
}

@JsonSerializable(explicitToJson: true)
class LogEntry {
  const LogEntry({
    this.bytes,
    this.count,
    required this.createdAt,
    required this.detail,
    required this.device,
    this.durationMs,
    this.fromPath,
    required this.id,
    required this.isDir,
    required this.kind,
    required this.path,
    this.size,
    required this.status,
    required this.userId,
    required this.username,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) => _$LogEntryFromJson(json);

  static const toJsonFactory = _$LogEntryToJson;
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  @JsonKey(name: 'bytes', includeIfNull: false)
  final int? bytes;
  @JsonKey(name: 'count', includeIfNull: false)
  final int? count;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'detail', includeIfNull: false)
  final String detail;
  @JsonKey(name: 'device', includeIfNull: false)
  final String device;
  @JsonKey(name: 'durationMs', includeIfNull: false)
  final int? durationMs;
  @JsonKey(name: 'fromPath', includeIfNull: false)
  final String? fromPath;
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
  @JsonKey(name: 'isDir', includeIfNull: false)
  final bool isDir;
  @JsonKey(name: 'kind', includeIfNull: false, toJson: logEntryKindToJson, fromJson: logEntryKindFromJson)
  final enums.LogEntryKind kind;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'size', includeIfNull: false)
  final int? size;
  @JsonKey(name: 'status', includeIfNull: false, toJson: logEntryStatusToJson, fromJson: logEntryStatusFromJson)
  final enums.LogEntryStatus status;
  @JsonKey(name: 'userId', includeIfNull: false)
  final int userId;
  @JsonKey(name: 'username', includeIfNull: false)
  final String username;
  static const fromJsonFactory = _$LogEntryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogEntry &&
            (identical(other.bytes, bytes) || const DeepCollectionEquality().equals(other.bytes, bytes)) &&
            (identical(other.count, count) || const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(other.createdAt, createdAt)) &&
            (identical(other.detail, detail) || const DeepCollectionEquality().equals(other.detail, detail)) &&
            (identical(other.device, device) || const DeepCollectionEquality().equals(other.device, device)) &&
            (identical(other.durationMs, durationMs) ||
                const DeepCollectionEquality().equals(other.durationMs, durationMs)) &&
            (identical(other.fromPath, fromPath) || const DeepCollectionEquality().equals(other.fromPath, fromPath)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.isDir, isDir) || const DeepCollectionEquality().equals(other.isDir, isDir)) &&
            (identical(other.kind, kind) || const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)) &&
            (identical(other.status, status) || const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.userId, userId) || const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bytes) ^
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(detail) ^
      const DeepCollectionEquality().hash(device) ^
      const DeepCollectionEquality().hash(durationMs) ^
      const DeepCollectionEquality().hash(fromPath) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(isDir) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(size) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $LogEntryExtension on LogEntry {
  LogEntry copyWith({
    int? bytes,
    int? count,
    DateTime? createdAt,
    String? detail,
    String? device,
    int? durationMs,
    String? fromPath,
    int? id,
    bool? isDir,
    enums.LogEntryKind? kind,
    String? path,
    int? size,
    enums.LogEntryStatus? status,
    int? userId,
    String? username,
  }) {
    return LogEntry(
      bytes: bytes ?? this.bytes,
      count: count ?? this.count,
      createdAt: createdAt ?? this.createdAt,
      detail: detail ?? this.detail,
      device: device ?? this.device,
      durationMs: durationMs ?? this.durationMs,
      fromPath: fromPath ?? this.fromPath,
      id: id ?? this.id,
      isDir: isDir ?? this.isDir,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      size: size ?? this.size,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }

  LogEntry copyWithWrapped({
    Wrapped<int?>? bytes,
    Wrapped<int?>? count,
    Wrapped<DateTime>? createdAt,
    Wrapped<String>? detail,
    Wrapped<String>? device,
    Wrapped<int?>? durationMs,
    Wrapped<String?>? fromPath,
    Wrapped<int>? id,
    Wrapped<bool>? isDir,
    Wrapped<enums.LogEntryKind>? kind,
    Wrapped<String>? path,
    Wrapped<int?>? size,
    Wrapped<enums.LogEntryStatus>? status,
    Wrapped<int>? userId,
    Wrapped<String>? username,
  }) {
    return LogEntry(
      bytes: (bytes != null ? bytes.value : this.bytes),
      count: (count != null ? count.value : this.count),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      detail: (detail != null ? detail.value : this.detail),
      device: (device != null ? device.value : this.device),
      durationMs: (durationMs != null ? durationMs.value : this.durationMs),
      fromPath: (fromPath != null ? fromPath.value : this.fromPath),
      id: (id != null ? id.value : this.id),
      isDir: (isDir != null ? isDir.value : this.isDir),
      kind: (kind != null ? kind.value : this.kind),
      path: (path != null ? path.value : this.path),
      size: (size != null ? size.value : this.size),
      status: (status != null ? status.value : this.status),
      userId: (userId != null ? userId.value : this.userId),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LogPage {
  const LogPage({this.entries, required this.nextCursor});

  factory LogPage.fromJson(Map<String, dynamic> json) => _$LogPageFromJson(json);

  static const toJsonFactory = _$LogPageToJson;
  Map<String, dynamic> toJson() => _$LogPageToJson(this);

  @JsonKey(name: 'entries', includeIfNull: false, defaultValue: <LogEntry>[])
  final List<LogEntry>? entries;
  @JsonKey(name: 'nextCursor', includeIfNull: false)
  final int nextCursor;
  static const fromJsonFactory = _$LogPageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogPage &&
            (identical(other.entries, entries) || const DeepCollectionEquality().equals(other.entries, entries)) &&
            (identical(other.nextCursor, nextCursor) ||
                const DeepCollectionEquality().equals(other.nextCursor, nextCursor)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entries) ^
      const DeepCollectionEquality().hash(nextCursor) ^
      runtimeType.hashCode;
}

extension $LogPageExtension on LogPage {
  LogPage copyWith({List<LogEntry>? entries, int? nextCursor}) {
    return LogPage(entries: entries ?? this.entries, nextCursor: nextCursor ?? this.nextCursor);
  }

  LogPage copyWithWrapped({Wrapped<List<LogEntry>?>? entries, Wrapped<int>? nextCursor}) {
    return LogPage(
      entries: (entries != null ? entries.value : this.entries),
      nextCursor: (nextCursor != null ? nextCursor.value : this.nextCursor),
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
class Match {
  const Match({required this.entry, this.nameMatches, required this.score, this.snippet, this.snippetMatches});

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  static const toJsonFactory = _$MatchToJson;
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  @JsonKey(name: 'entry', includeIfNull: false)
  final Entry entry;
  @JsonKey(name: 'nameMatches', includeIfNull: false, defaultValue: <TextSpan>[])
  final List<TextSpan>? nameMatches;
  @JsonKey(name: 'score', includeIfNull: false)
  final double score;
  @JsonKey(name: 'snippet', includeIfNull: false)
  final String? snippet;
  @JsonKey(name: 'snippetMatches', includeIfNull: false, defaultValue: <TextSpan>[])
  final List<TextSpan>? snippetMatches;
  static const fromJsonFactory = _$MatchFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Match &&
            (identical(other.entry, entry) || const DeepCollectionEquality().equals(other.entry, entry)) &&
            (identical(other.nameMatches, nameMatches) ||
                const DeepCollectionEquality().equals(other.nameMatches, nameMatches)) &&
            (identical(other.score, score) || const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.snippet, snippet) || const DeepCollectionEquality().equals(other.snippet, snippet)) &&
            (identical(other.snippetMatches, snippetMatches) ||
                const DeepCollectionEquality().equals(other.snippetMatches, snippetMatches)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entry) ^
      const DeepCollectionEquality().hash(nameMatches) ^
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(snippet) ^
      const DeepCollectionEquality().hash(snippetMatches) ^
      runtimeType.hashCode;
}

extension $MatchExtension on Match {
  Match copyWith({
    Entry? entry,
    List<TextSpan>? nameMatches,
    double? score,
    String? snippet,
    List<TextSpan>? snippetMatches,
  }) {
    return Match(
      entry: entry ?? this.entry,
      nameMatches: nameMatches ?? this.nameMatches,
      score: score ?? this.score,
      snippet: snippet ?? this.snippet,
      snippetMatches: snippetMatches ?? this.snippetMatches,
    );
  }

  Match copyWithWrapped({
    Wrapped<Entry>? entry,
    Wrapped<List<TextSpan>?>? nameMatches,
    Wrapped<double>? score,
    Wrapped<String?>? snippet,
    Wrapped<List<TextSpan>?>? snippetMatches,
  }) {
    return Match(
      entry: (entry != null ? entry.value : this.entry),
      nameMatches: (nameMatches != null ? nameMatches.value : this.nameMatches),
      score: (score != null ? score.value : this.score),
      snippet: (snippet != null ? snippet.value : this.snippet),
      snippetMatches: (snippetMatches != null ? snippetMatches.value : this.snippetMatches),
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
class QueryFilter {
  const QueryFilter({required this.end, required this.key, required this.op, required this.start, this.values});

  factory QueryFilter.fromJson(Map<String, dynamic> json) => _$QueryFilterFromJson(json);

  static const toJsonFactory = _$QueryFilterToJson;
  Map<String, dynamic> toJson() => _$QueryFilterToJson(this);

  @JsonKey(name: 'end', includeIfNull: false)
  final int end;
  @JsonKey(name: 'key', includeIfNull: false, toJson: queryFilterKeyToJson, fromJson: queryFilterKeyFromJson)
  final enums.QueryFilterKey key;
  @JsonKey(name: 'op', includeIfNull: false, toJson: queryFilterOpToJson, fromJson: queryFilterOpFromJson)
  final enums.QueryFilterOp op;
  @JsonKey(name: 'start', includeIfNull: false)
  final int start;
  @JsonKey(name: 'values', includeIfNull: false, defaultValue: <String>[])
  final List<String>? values;
  static const fromJsonFactory = _$QueryFilterFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is QueryFilter &&
            (identical(other.end, end) || const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.key, key) || const DeepCollectionEquality().equals(other.key, key)) &&
            (identical(other.op, op) || const DeepCollectionEquality().equals(other.op, op)) &&
            (identical(other.start, start) || const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.values, values) || const DeepCollectionEquality().equals(other.values, values)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(key) ^
      const DeepCollectionEquality().hash(op) ^
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(values) ^
      runtimeType.hashCode;
}

extension $QueryFilterExtension on QueryFilter {
  QueryFilter copyWith({
    int? end,
    enums.QueryFilterKey? key,
    enums.QueryFilterOp? op,
    int? start,
    List<String>? values,
  }) {
    return QueryFilter(
      end: end ?? this.end,
      key: key ?? this.key,
      op: op ?? this.op,
      start: start ?? this.start,
      values: values ?? this.values,
    );
  }

  QueryFilter copyWithWrapped({
    Wrapped<int>? end,
    Wrapped<enums.QueryFilterKey>? key,
    Wrapped<enums.QueryFilterOp>? op,
    Wrapped<int>? start,
    Wrapped<List<String>?>? values,
  }) {
    return QueryFilter(
      end: (end != null ? end.value : this.end),
      key: (key != null ? key.value : this.key),
      op: (op != null ? op.value : this.op),
      start: (start != null ? start.value : this.start),
      values: (values != null ? values.value : this.values),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class QueryWarning {
  const QueryWarning({required this.end, required this.message, required this.start});

  factory QueryWarning.fromJson(Map<String, dynamic> json) => _$QueryWarningFromJson(json);

  static const toJsonFactory = _$QueryWarningToJson;
  Map<String, dynamic> toJson() => _$QueryWarningToJson(this);

  @JsonKey(name: 'end', includeIfNull: false)
  final int end;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'start', includeIfNull: false)
  final int start;
  static const fromJsonFactory = _$QueryWarningFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is QueryWarning &&
            (identical(other.end, end) || const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.message, message) || const DeepCollectionEquality().equals(other.message, message)) &&
            (identical(other.start, start) || const DeepCollectionEquality().equals(other.start, start)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(start) ^
      runtimeType.hashCode;
}

extension $QueryWarningExtension on QueryWarning {
  QueryWarning copyWith({int? end, String? message, int? start}) {
    return QueryWarning(end: end ?? this.end, message: message ?? this.message, start: start ?? this.start);
  }

  QueryWarning copyWithWrapped({Wrapped<int>? end, Wrapped<String>? message, Wrapped<int>? start}) {
    return QueryWarning(
      end: (end != null ? end.value : this.end),
      message: (message != null ? message.value : this.message),
      start: (start != null ? start.value : this.start),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RefreshRequest {
  const RefreshRequest({this.deviceName, required this.refreshToken});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) => _$RefreshRequestFromJson(json);

  static const toJsonFactory = _$RefreshRequestToJson;
  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);

  @JsonKey(name: 'deviceName', includeIfNull: false)
  final String? deviceName;
  @JsonKey(name: 'refreshToken', includeIfNull: false)
  final String refreshToken;
  static const fromJsonFactory = _$RefreshRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RefreshRequest &&
            (identical(other.deviceName, deviceName) ||
                const DeepCollectionEquality().equals(other.deviceName, deviceName)) &&
            (identical(other.refreshToken, refreshToken) ||
                const DeepCollectionEquality().equals(other.refreshToken, refreshToken)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(deviceName) ^
      const DeepCollectionEquality().hash(refreshToken) ^
      runtimeType.hashCode;
}

extension $RefreshRequestExtension on RefreshRequest {
  RefreshRequest copyWith({String? deviceName, String? refreshToken}) {
    return RefreshRequest(deviceName: deviceName ?? this.deviceName, refreshToken: refreshToken ?? this.refreshToken);
  }

  RefreshRequest copyWithWrapped({Wrapped<String?>? deviceName, Wrapped<String>? refreshToken}) {
    return RefreshRequest(
      deviceName: (deviceName != null ? deviceName.value : this.deviceName),
      refreshToken: (refreshToken != null ? refreshToken.value : this.refreshToken),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RestoreRequest {
  const RestoreRequest({this.onConflict});

  factory RestoreRequest.fromJson(Map<String, dynamic> json) => _$RestoreRequestFromJson(json);

  static const toJsonFactory = _$RestoreRequestToJson;
  Map<String, dynamic> toJson() => _$RestoreRequestToJson(this);

  @JsonKey(
    name: 'onConflict',
    includeIfNull: false,
    toJson: restoreRequestOnConflictNullableToJson,
    fromJson: restoreRequestOnConflictOnConflictNullableFromJson,
  )
  final enums.RestoreRequestOnConflict? onConflict;
  static enums.RestoreRequestOnConflict? restoreRequestOnConflictOnConflictNullableFromJson(Object? value) =>
      restoreRequestOnConflictNullableFromJson(value, enums.RestoreRequestOnConflict.fail);

  static const fromJsonFactory = _$RestoreRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RestoreRequest &&
            (identical(other.onConflict, onConflict) ||
                const DeepCollectionEquality().equals(other.onConflict, onConflict)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(onConflict) ^ runtimeType.hashCode;
}

extension $RestoreRequestExtension on RestoreRequest {
  RestoreRequest copyWith({enums.RestoreRequestOnConflict? onConflict}) {
    return RestoreRequest(onConflict: onConflict ?? this.onConflict);
  }

  RestoreRequest copyWithWrapped({Wrapped<enums.RestoreRequestOnConflict?>? onConflict}) {
    return RestoreRequest(onConflict: (onConflict != null ? onConflict.value : this.onConflict));
  }
}

@JsonSerializable(explicitToJson: true)
class Results {
  const Results({
    required this.facets,
    this.filters,
    required this.query,
    this.results,
    required this.total,
    this.warnings,
  });

  factory Results.fromJson(Map<String, dynamic> json) => _$ResultsFromJson(json);

  static const toJsonFactory = _$ResultsToJson;
  Map<String, dynamic> toJson() => _$ResultsToJson(this);

  @JsonKey(name: 'facets', includeIfNull: false)
  final Facets facets;
  @JsonKey(name: 'filters', includeIfNull: false, defaultValue: <QueryFilter>[])
  final List<QueryFilter>? filters;
  @JsonKey(name: 'query', includeIfNull: false)
  final String query;
  @JsonKey(name: 'results', includeIfNull: false, defaultValue: <Match>[])
  final List<Match>? results;
  @JsonKey(name: 'total', includeIfNull: false)
  final int total;
  @JsonKey(name: 'warnings', includeIfNull: false, defaultValue: <QueryWarning>[])
  final List<QueryWarning>? warnings;
  static const fromJsonFactory = _$ResultsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Results &&
            (identical(other.facets, facets) || const DeepCollectionEquality().equals(other.facets, facets)) &&
            (identical(other.filters, filters) || const DeepCollectionEquality().equals(other.filters, filters)) &&
            (identical(other.query, query) || const DeepCollectionEquality().equals(other.query, query)) &&
            (identical(other.results, results) || const DeepCollectionEquality().equals(other.results, results)) &&
            (identical(other.total, total) || const DeepCollectionEquality().equals(other.total, total)) &&
            (identical(other.warnings, warnings) || const DeepCollectionEquality().equals(other.warnings, warnings)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(facets) ^
      const DeepCollectionEquality().hash(filters) ^
      const DeepCollectionEquality().hash(query) ^
      const DeepCollectionEquality().hash(results) ^
      const DeepCollectionEquality().hash(total) ^
      const DeepCollectionEquality().hash(warnings) ^
      runtimeType.hashCode;
}

extension $ResultsExtension on Results {
  Results copyWith({
    Facets? facets,
    List<QueryFilter>? filters,
    String? query,
    List<Match>? results,
    int? total,
    List<QueryWarning>? warnings,
  }) {
    return Results(
      facets: facets ?? this.facets,
      filters: filters ?? this.filters,
      query: query ?? this.query,
      results: results ?? this.results,
      total: total ?? this.total,
      warnings: warnings ?? this.warnings,
    );
  }

  Results copyWithWrapped({
    Wrapped<Facets>? facets,
    Wrapped<List<QueryFilter>?>? filters,
    Wrapped<String>? query,
    Wrapped<List<Match>?>? results,
    Wrapped<int>? total,
    Wrapped<List<QueryWarning>?>? warnings,
  }) {
    return Results(
      facets: (facets != null ? facets.value : this.facets),
      filters: (filters != null ? filters.value : this.filters),
      query: (query != null ? query.value : this.query),
      results: (results != null ? results.value : this.results),
      total: (total != null ? total.value : this.total),
      warnings: (warnings != null ? warnings.value : this.warnings),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RetentionRequest {
  const RetentionRequest({this.days});

  factory RetentionRequest.fromJson(Map<String, dynamic> json) => _$RetentionRequestFromJson(json);

  static const toJsonFactory = _$RetentionRequestToJson;
  Map<String, dynamic> toJson() => _$RetentionRequestToJson(this);

  @JsonKey(name: 'days', includeIfNull: false)
  final int? days;
  static const fromJsonFactory = _$RetentionRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RetentionRequest &&
            (identical(other.days, days) || const DeepCollectionEquality().equals(other.days, days)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(days) ^ runtimeType.hashCode;
}

extension $RetentionRequestExtension on RetentionRequest {
  RetentionRequest copyWith({int? days}) {
    return RetentionRequest(days: days ?? this.days);
  }

  RetentionRequest copyWithWrapped({Wrapped<int?>? days}) {
    return RetentionRequest(days: (days != null ? days.value : this.days));
  }
}

@JsonSerializable(explicitToJson: true)
class SearchStatus {
  const SearchStatus({required this.documents, required this.extraction, this.lastSync});

  factory SearchStatus.fromJson(Map<String, dynamic> json) => _$SearchStatusFromJson(json);

  static const toJsonFactory = _$SearchStatusToJson;
  Map<String, dynamic> toJson() => _$SearchStatusToJson(this);

  @JsonKey(name: 'documents', includeIfNull: false)
  final int documents;
  @JsonKey(name: 'extraction', includeIfNull: false)
  final ExtractionStatus extraction;
  @JsonKey(name: 'lastSync', includeIfNull: false)
  final DateTime? lastSync;
  static const fromJsonFactory = _$SearchStatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SearchStatus &&
            (identical(other.documents, documents) ||
                const DeepCollectionEquality().equals(other.documents, documents)) &&
            (identical(other.extraction, extraction) ||
                const DeepCollectionEquality().equals(other.extraction, extraction)) &&
            (identical(other.lastSync, lastSync) || const DeepCollectionEquality().equals(other.lastSync, lastSync)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(documents) ^
      const DeepCollectionEquality().hash(extraction) ^
      const DeepCollectionEquality().hash(lastSync) ^
      runtimeType.hashCode;
}

extension $SearchStatusExtension on SearchStatus {
  SearchStatus copyWith({int? documents, ExtractionStatus? extraction, DateTime? lastSync}) {
    return SearchStatus(
      documents: documents ?? this.documents,
      extraction: extraction ?? this.extraction,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  SearchStatus copyWithWrapped({
    Wrapped<int>? documents,
    Wrapped<ExtractionStatus>? extraction,
    Wrapped<DateTime?>? lastSync,
  }) {
    return SearchStatus(
      documents: (documents != null ? documents.value : this.documents),
      extraction: (extraction != null ? extraction.value : this.extraction),
      lastSync: (lastSync != null ? lastSync.value : this.lastSync),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerSettings {
  const ServerSettings({
    required this.ocrEnabled,
    this.ocrLanguages,
    required this.ocrMaxPages,
    required this.searchContentEnabled,
    required this.trashRetentionDays,
    required this.trashRetentionEnforced,
  });

  factory ServerSettings.fromJson(Map<String, dynamic> json) => _$ServerSettingsFromJson(json);

  static const toJsonFactory = _$ServerSettingsToJson;
  Map<String, dynamic> toJson() => _$ServerSettingsToJson(this);

  @JsonKey(name: 'ocrEnabled', includeIfNull: false)
  final bool ocrEnabled;
  @JsonKey(name: 'ocrLanguages', includeIfNull: false, defaultValue: <String>[])
  final List<String>? ocrLanguages;
  @JsonKey(name: 'ocrMaxPages', includeIfNull: false)
  final int ocrMaxPages;
  @JsonKey(name: 'searchContentEnabled', includeIfNull: false)
  final bool searchContentEnabled;
  @JsonKey(name: 'trashRetentionDays', includeIfNull: false)
  final int trashRetentionDays;
  @JsonKey(name: 'trashRetentionEnforced', includeIfNull: false)
  final bool trashRetentionEnforced;
  static const fromJsonFactory = _$ServerSettingsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerSettings &&
            (identical(other.ocrEnabled, ocrEnabled) ||
                const DeepCollectionEquality().equals(other.ocrEnabled, ocrEnabled)) &&
            (identical(other.ocrLanguages, ocrLanguages) ||
                const DeepCollectionEquality().equals(other.ocrLanguages, ocrLanguages)) &&
            (identical(other.ocrMaxPages, ocrMaxPages) ||
                const DeepCollectionEquality().equals(other.ocrMaxPages, ocrMaxPages)) &&
            (identical(other.searchContentEnabled, searchContentEnabled) ||
                const DeepCollectionEquality().equals(other.searchContentEnabled, searchContentEnabled)) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionDays, trashRetentionDays)) &&
            (identical(other.trashRetentionEnforced, trashRetentionEnforced) ||
                const DeepCollectionEquality().equals(other.trashRetentionEnforced, trashRetentionEnforced)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(ocrEnabled) ^
      const DeepCollectionEquality().hash(ocrLanguages) ^
      const DeepCollectionEquality().hash(ocrMaxPages) ^
      const DeepCollectionEquality().hash(searchContentEnabled) ^
      const DeepCollectionEquality().hash(trashRetentionDays) ^
      const DeepCollectionEquality().hash(trashRetentionEnforced) ^
      runtimeType.hashCode;
}

extension $ServerSettingsExtension on ServerSettings {
  ServerSettings copyWith({
    bool? ocrEnabled,
    List<String>? ocrLanguages,
    int? ocrMaxPages,
    bool? searchContentEnabled,
    int? trashRetentionDays,
    bool? trashRetentionEnforced,
  }) {
    return ServerSettings(
      ocrEnabled: ocrEnabled ?? this.ocrEnabled,
      ocrLanguages: ocrLanguages ?? this.ocrLanguages,
      ocrMaxPages: ocrMaxPages ?? this.ocrMaxPages,
      searchContentEnabled: searchContentEnabled ?? this.searchContentEnabled,
      trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
      trashRetentionEnforced: trashRetentionEnforced ?? this.trashRetentionEnforced,
    );
  }

  ServerSettings copyWithWrapped({
    Wrapped<bool>? ocrEnabled,
    Wrapped<List<String>?>? ocrLanguages,
    Wrapped<int>? ocrMaxPages,
    Wrapped<bool>? searchContentEnabled,
    Wrapped<int>? trashRetentionDays,
    Wrapped<bool>? trashRetentionEnforced,
  }) {
    return ServerSettings(
      ocrEnabled: (ocrEnabled != null ? ocrEnabled.value : this.ocrEnabled),
      ocrLanguages: (ocrLanguages != null ? ocrLanguages.value : this.ocrLanguages),
      ocrMaxPages: (ocrMaxPages != null ? ocrMaxPages.value : this.ocrMaxPages),
      searchContentEnabled: (searchContentEnabled != null ? searchContentEnabled.value : this.searchContentEnabled),
      trashRetentionDays: (trashRetentionDays != null ? trashRetentionDays.value : this.trashRetentionDays),
      trashRetentionEnforced: (trashRetentionEnforced != null
          ? trashRetentionEnforced.value
          : this.trashRetentionEnforced),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerSettingsChanges {
  const ServerSettingsChanges({
    this.ocrEnabled,
    this.ocrLanguages,
    this.ocrMaxPages,
    this.searchContentEnabled,
    this.trashRetentionDays,
    this.trashRetentionEnforced,
  });

  factory ServerSettingsChanges.fromJson(Map<String, dynamic> json) => _$ServerSettingsChangesFromJson(json);

  static const toJsonFactory = _$ServerSettingsChangesToJson;
  Map<String, dynamic> toJson() => _$ServerSettingsChangesToJson(this);

  @JsonKey(name: 'ocrEnabled', includeIfNull: false)
  final bool? ocrEnabled;
  @JsonKey(name: 'ocrLanguages', includeIfNull: false, defaultValue: <String>[])
  final List<String>? ocrLanguages;
  @JsonKey(name: 'ocrMaxPages', includeIfNull: false)
  final int? ocrMaxPages;
  @JsonKey(name: 'searchContentEnabled', includeIfNull: false)
  final bool? searchContentEnabled;
  @JsonKey(name: 'trashRetentionDays', includeIfNull: false)
  final int? trashRetentionDays;
  @JsonKey(name: 'trashRetentionEnforced', includeIfNull: false)
  final bool? trashRetentionEnforced;
  static const fromJsonFactory = _$ServerSettingsChangesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerSettingsChanges &&
            (identical(other.ocrEnabled, ocrEnabled) ||
                const DeepCollectionEquality().equals(other.ocrEnabled, ocrEnabled)) &&
            (identical(other.ocrLanguages, ocrLanguages) ||
                const DeepCollectionEquality().equals(other.ocrLanguages, ocrLanguages)) &&
            (identical(other.ocrMaxPages, ocrMaxPages) ||
                const DeepCollectionEquality().equals(other.ocrMaxPages, ocrMaxPages)) &&
            (identical(other.searchContentEnabled, searchContentEnabled) ||
                const DeepCollectionEquality().equals(other.searchContentEnabled, searchContentEnabled)) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionDays, trashRetentionDays)) &&
            (identical(other.trashRetentionEnforced, trashRetentionEnforced) ||
                const DeepCollectionEquality().equals(other.trashRetentionEnforced, trashRetentionEnforced)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(ocrEnabled) ^
      const DeepCollectionEquality().hash(ocrLanguages) ^
      const DeepCollectionEquality().hash(ocrMaxPages) ^
      const DeepCollectionEquality().hash(searchContentEnabled) ^
      const DeepCollectionEquality().hash(trashRetentionDays) ^
      const DeepCollectionEquality().hash(trashRetentionEnforced) ^
      runtimeType.hashCode;
}

extension $ServerSettingsChangesExtension on ServerSettingsChanges {
  ServerSettingsChanges copyWith({
    bool? ocrEnabled,
    List<String>? ocrLanguages,
    int? ocrMaxPages,
    bool? searchContentEnabled,
    int? trashRetentionDays,
    bool? trashRetentionEnforced,
  }) {
    return ServerSettingsChanges(
      ocrEnabled: ocrEnabled ?? this.ocrEnabled,
      ocrLanguages: ocrLanguages ?? this.ocrLanguages,
      ocrMaxPages: ocrMaxPages ?? this.ocrMaxPages,
      searchContentEnabled: searchContentEnabled ?? this.searchContentEnabled,
      trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
      trashRetentionEnforced: trashRetentionEnforced ?? this.trashRetentionEnforced,
    );
  }

  ServerSettingsChanges copyWithWrapped({
    Wrapped<bool?>? ocrEnabled,
    Wrapped<List<String>?>? ocrLanguages,
    Wrapped<int?>? ocrMaxPages,
    Wrapped<bool?>? searchContentEnabled,
    Wrapped<int?>? trashRetentionDays,
    Wrapped<bool?>? trashRetentionEnforced,
  }) {
    return ServerSettingsChanges(
      ocrEnabled: (ocrEnabled != null ? ocrEnabled.value : this.ocrEnabled),
      ocrLanguages: (ocrLanguages != null ? ocrLanguages.value : this.ocrLanguages),
      ocrMaxPages: (ocrMaxPages != null ? ocrMaxPages.value : this.ocrMaxPages),
      searchContentEnabled: (searchContentEnabled != null ? searchContentEnabled.value : this.searchContentEnabled),
      trashRetentionDays: (trashRetentionDays != null ? trashRetentionDays.value : this.trashRetentionDays),
      trashRetentionEnforced: (trashRetentionEnforced != null
          ? trashRetentionEnforced.value
          : this.trashRetentionEnforced),
    );
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
class Suggestion {
  const Suggestion({required this.count, required this.insert, required this.kind, required this.value});

  factory Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

  static const toJsonFactory = _$SuggestionToJson;
  Map<String, dynamic> toJson() => _$SuggestionToJson(this);

  @JsonKey(name: 'count', includeIfNull: false)
  final int count;
  @JsonKey(name: 'insert', includeIfNull: false)
  final String insert;
  @JsonKey(name: 'kind', includeIfNull: false, toJson: suggestionKindToJson, fromJson: suggestionKindFromJson)
  final enums.SuggestionKind kind;
  @JsonKey(name: 'value', includeIfNull: false)
  final String value;
  static const fromJsonFactory = _$SuggestionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Suggestion &&
            (identical(other.count, count) || const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.insert, insert) || const DeepCollectionEquality().equals(other.insert, insert)) &&
            (identical(other.kind, kind) || const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.value, value) || const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(insert) ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(value) ^
      runtimeType.hashCode;
}

extension $SuggestionExtension on Suggestion {
  Suggestion copyWith({int? count, String? insert, enums.SuggestionKind? kind, String? value}) {
    return Suggestion(
      count: count ?? this.count,
      insert: insert ?? this.insert,
      kind: kind ?? this.kind,
      value: value ?? this.value,
    );
  }

  Suggestion copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String>? insert,
    Wrapped<enums.SuggestionKind>? kind,
    Wrapped<String>? value,
  }) {
    return Suggestion(
      count: (count != null ? count.value : this.count),
      insert: (insert != null ? insert.value : this.insert),
      kind: (kind != null ? kind.value : this.kind),
      value: (value != null ? value.value : this.value),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Suggestions {
  const Suggestions({required this.end, required this.start, this.suggestions});

  factory Suggestions.fromJson(Map<String, dynamic> json) => _$SuggestionsFromJson(json);

  static const toJsonFactory = _$SuggestionsToJson;
  Map<String, dynamic> toJson() => _$SuggestionsToJson(this);

  @JsonKey(name: 'end', includeIfNull: false)
  final int end;
  @JsonKey(name: 'start', includeIfNull: false)
  final int start;
  @JsonKey(name: 'suggestions', includeIfNull: false, defaultValue: <Suggestion>[])
  final List<Suggestion>? suggestions;
  static const fromJsonFactory = _$SuggestionsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Suggestions &&
            (identical(other.end, end) || const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.start, start) || const DeepCollectionEquality().equals(other.start, start)) &&
            (identical(other.suggestions, suggestions) ||
                const DeepCollectionEquality().equals(other.suggestions, suggestions)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(end) ^
      const DeepCollectionEquality().hash(start) ^
      const DeepCollectionEquality().hash(suggestions) ^
      runtimeType.hashCode;
}

extension $SuggestionsExtension on Suggestions {
  Suggestions copyWith({int? end, int? start, List<Suggestion>? suggestions}) {
    return Suggestions(end: end ?? this.end, start: start ?? this.start, suggestions: suggestions ?? this.suggestions);
  }

  Suggestions copyWithWrapped({Wrapped<int>? end, Wrapped<int>? start, Wrapped<List<Suggestion>?>? suggestions}) {
    return Suggestions(
      end: (end != null ? end.value : this.end),
      start: (start != null ? start.value : this.start),
      suggestions: (suggestions != null ? suggestions.value : this.suggestions),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TextSpan {
  const TextSpan({required this.end, required this.start});

  factory TextSpan.fromJson(Map<String, dynamic> json) => _$TextSpanFromJson(json);

  static const toJsonFactory = _$TextSpanToJson;
  Map<String, dynamic> toJson() => _$TextSpanToJson(this);

  @JsonKey(name: 'end', includeIfNull: false)
  final int end;
  @JsonKey(name: 'start', includeIfNull: false)
  final int start;
  static const fromJsonFactory = _$TextSpanFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TextSpan &&
            (identical(other.end, end) || const DeepCollectionEquality().equals(other.end, end)) &&
            (identical(other.start, start) || const DeepCollectionEquality().equals(other.start, start)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(end) ^ const DeepCollectionEquality().hash(start) ^ runtimeType.hashCode;
}

extension $TextSpanExtension on TextSpan {
  TextSpan copyWith({int? end, int? start}) {
    return TextSpan(end: end ?? this.end, start: start ?? this.start);
  }

  TextSpan copyWithWrapped({Wrapped<int>? end, Wrapped<int>? start}) {
    return TextSpan(end: (end != null ? end.value : this.end), start: (start != null ? start.value : this.start));
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
class TrashItem {
  const TrashItem({
    required this.deletedAt,
    this.expiresAt,
    required this.hash,
    required this.id,
    required this.isDir,
    required this.mime,
    required this.name,
    required this.originalPath,
    required this.previewState,
    required this.size,
  });

  factory TrashItem.fromJson(Map<String, dynamic> json) => _$TrashItemFromJson(json);

  static const toJsonFactory = _$TrashItemToJson;
  Map<String, dynamic> toJson() => _$TrashItemToJson(this);

  @JsonKey(name: 'deletedAt', includeIfNull: false)
  final DateTime deletedAt;
  @JsonKey(name: 'expiresAt', includeIfNull: false)
  final DateTime? expiresAt;
  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
  @JsonKey(name: 'isDir', includeIfNull: false)
  final bool isDir;
  @JsonKey(name: 'mime', includeIfNull: false)
  final String mime;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'originalPath', includeIfNull: false)
  final String originalPath;
  @JsonKey(
    name: 'previewState',
    includeIfNull: false,
    toJson: trashItemPreviewStateToJson,
    fromJson: trashItemPreviewStateFromJson,
  )
  final enums.TrashItemPreviewState previewState;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$TrashItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrashItem &&
            (identical(other.deletedAt, deletedAt) ||
                const DeepCollectionEquality().equals(other.deletedAt, deletedAt)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(other.expiresAt, expiresAt)) &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.isDir, isDir) || const DeepCollectionEquality().equals(other.isDir, isDir)) &&
            (identical(other.mime, mime) || const DeepCollectionEquality().equals(other.mime, mime)) &&
            (identical(other.name, name) || const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.originalPath, originalPath) ||
                const DeepCollectionEquality().equals(other.originalPath, originalPath)) &&
            (identical(other.previewState, previewState) ||
                const DeepCollectionEquality().equals(other.previewState, previewState)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(deletedAt) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(isDir) ^
      const DeepCollectionEquality().hash(mime) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(originalPath) ^
      const DeepCollectionEquality().hash(previewState) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $TrashItemExtension on TrashItem {
  TrashItem copyWith({
    DateTime? deletedAt,
    DateTime? expiresAt,
    String? hash,
    int? id,
    bool? isDir,
    String? mime,
    String? name,
    String? originalPath,
    enums.TrashItemPreviewState? previewState,
    int? size,
  }) {
    return TrashItem(
      deletedAt: deletedAt ?? this.deletedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      hash: hash ?? this.hash,
      id: id ?? this.id,
      isDir: isDir ?? this.isDir,
      mime: mime ?? this.mime,
      name: name ?? this.name,
      originalPath: originalPath ?? this.originalPath,
      previewState: previewState ?? this.previewState,
      size: size ?? this.size,
    );
  }

  TrashItem copyWithWrapped({
    Wrapped<DateTime>? deletedAt,
    Wrapped<DateTime?>? expiresAt,
    Wrapped<String>? hash,
    Wrapped<int>? id,
    Wrapped<bool>? isDir,
    Wrapped<String>? mime,
    Wrapped<String>? name,
    Wrapped<String>? originalPath,
    Wrapped<enums.TrashItemPreviewState>? previewState,
    Wrapped<int>? size,
  }) {
    return TrashItem(
      deletedAt: (deletedAt != null ? deletedAt.value : this.deletedAt),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      hash: (hash != null ? hash.value : this.hash),
      id: (id != null ? id.value : this.id),
      isDir: (isDir != null ? isDir.value : this.isDir),
      mime: (mime != null ? mime.value : this.mime),
      name: (name != null ? name.value : this.name),
      originalPath: (originalPath != null ? originalPath.value : this.originalPath),
      previewState: (previewState != null ? previewState.value : this.previewState),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TrashListing {
  const TrashListing({this.items, required this.retention, required this.totalBytes});

  factory TrashListing.fromJson(Map<String, dynamic> json) => _$TrashListingFromJson(json);

  static const toJsonFactory = _$TrashListingToJson;
  Map<String, dynamic> toJson() => _$TrashListingToJson(this);

  @JsonKey(name: 'items', includeIfNull: false, defaultValue: <TrashItem>[])
  final List<TrashItem>? items;
  @JsonKey(name: 'retention', includeIfNull: false)
  final TrashRetention retention;
  @JsonKey(name: 'totalBytes', includeIfNull: false)
  final int totalBytes;
  static const fromJsonFactory = _$TrashListingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrashListing &&
            (identical(other.items, items) || const DeepCollectionEquality().equals(other.items, items)) &&
            (identical(other.retention, retention) ||
                const DeepCollectionEquality().equals(other.retention, retention)) &&
            (identical(other.totalBytes, totalBytes) ||
                const DeepCollectionEquality().equals(other.totalBytes, totalBytes)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(items) ^
      const DeepCollectionEquality().hash(retention) ^
      const DeepCollectionEquality().hash(totalBytes) ^
      runtimeType.hashCode;
}

extension $TrashListingExtension on TrashListing {
  TrashListing copyWith({List<TrashItem>? items, TrashRetention? retention, int? totalBytes}) {
    return TrashListing(
      items: items ?? this.items,
      retention: retention ?? this.retention,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  TrashListing copyWithWrapped({
    Wrapped<List<TrashItem>?>? items,
    Wrapped<TrashRetention>? retention,
    Wrapped<int>? totalBytes,
  }) {
    return TrashListing(
      items: (items != null ? items.value : this.items),
      retention: (retention != null ? retention.value : this.retention),
      totalBytes: (totalBytes != null ? totalBytes.value : this.totalBytes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TrashRetention {
  const TrashRetention({
    required this.days,
    required this.defaultDays,
    required this.locked,
    required this.source,
    this.userDays,
  });

  factory TrashRetention.fromJson(Map<String, dynamic> json) => _$TrashRetentionFromJson(json);

  static const toJsonFactory = _$TrashRetentionToJson;
  Map<String, dynamic> toJson() => _$TrashRetentionToJson(this);

  @JsonKey(name: 'days', includeIfNull: false)
  final int days;
  @JsonKey(name: 'defaultDays', includeIfNull: false)
  final int defaultDays;
  @JsonKey(name: 'locked', includeIfNull: false)
  final bool locked;
  @JsonKey(
    name: 'source',
    includeIfNull: false,
    toJson: trashRetentionSourceToJson,
    fromJson: trashRetentionSourceFromJson,
  )
  final enums.TrashRetentionSource source;
  @JsonKey(name: 'userDays', includeIfNull: false)
  final int? userDays;
  static const fromJsonFactory = _$TrashRetentionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrashRetention &&
            (identical(other.days, days) || const DeepCollectionEquality().equals(other.days, days)) &&
            (identical(other.defaultDays, defaultDays) ||
                const DeepCollectionEquality().equals(other.defaultDays, defaultDays)) &&
            (identical(other.locked, locked) || const DeepCollectionEquality().equals(other.locked, locked)) &&
            (identical(other.source, source) || const DeepCollectionEquality().equals(other.source, source)) &&
            (identical(other.userDays, userDays) || const DeepCollectionEquality().equals(other.userDays, userDays)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(days) ^
      const DeepCollectionEquality().hash(defaultDays) ^
      const DeepCollectionEquality().hash(locked) ^
      const DeepCollectionEquality().hash(source) ^
      const DeepCollectionEquality().hash(userDays) ^
      runtimeType.hashCode;
}

extension $TrashRetentionExtension on TrashRetention {
  TrashRetention copyWith({
    int? days,
    int? defaultDays,
    bool? locked,
    enums.TrashRetentionSource? source,
    int? userDays,
  }) {
    return TrashRetention(
      days: days ?? this.days,
      defaultDays: defaultDays ?? this.defaultDays,
      locked: locked ?? this.locked,
      source: source ?? this.source,
      userDays: userDays ?? this.userDays,
    );
  }

  TrashRetention copyWithWrapped({
    Wrapped<int>? days,
    Wrapped<int>? defaultDays,
    Wrapped<bool>? locked,
    Wrapped<enums.TrashRetentionSource>? source,
    Wrapped<int?>? userDays,
  }) {
    return TrashRetention(
      days: (days != null ? days.value : this.days),
      defaultDays: (defaultDays != null ? defaultDays.value : this.defaultDays),
      locked: (locked != null ? locked.value : this.locked),
      source: (source != null ? source.value : this.source),
      userDays: (userDays != null ? userDays.value : this.userDays),
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
    this.trashRetentionDays,
    this.trashRetentionOverrideDays,
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
  @JsonKey(name: 'trashRetentionDays', includeIfNull: false)
  final int? trashRetentionDays;
  @JsonKey(name: 'trashRetentionOverrideDays', includeIfNull: false)
  final int? trashRetentionOverrideDays;
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
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionDays, trashRetentionDays)) &&
            (identical(other.trashRetentionOverrideDays, trashRetentionOverrideDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionOverrideDays, trashRetentionOverrideDays)) &&
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
      const DeepCollectionEquality().hash(trashRetentionDays) ^
      const DeepCollectionEquality().hash(trashRetentionOverrideDays) ^
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
    int? trashRetentionDays,
    int? trashRetentionOverrideDays,
    int? usedBytes,
    String? username,
  }) {
    return User(
      createdAt: createdAt ?? this.createdAt,
      disabled: disabled ?? this.disabled,
      id: id ?? this.id,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
      trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
      trashRetentionOverrideDays: trashRetentionOverrideDays ?? this.trashRetentionOverrideDays,
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
    Wrapped<int?>? trashRetentionDays,
    Wrapped<int?>? trashRetentionOverrideDays,
    Wrapped<int>? usedBytes,
    Wrapped<String>? username,
  }) {
    return User(
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      disabled: (disabled != null ? disabled.value : this.disabled),
      id: (id != null ? id.value : this.id),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
      trashRetentionDays: (trashRetentionDays != null ? trashRetentionDays.value : this.trashRetentionDays),
      trashRetentionOverrideDays: (trashRetentionOverrideDays != null
          ? trashRetentionOverrideDays.value
          : this.trashRetentionOverrideDays),
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

String? clientMessageScopeNullableToJson(enums.ClientMessageScope? clientMessageScope) {
  return clientMessageScope?.value;
}

String? clientMessageScopeToJson(enums.ClientMessageScope clientMessageScope) {
  return clientMessageScope.value;
}

enums.ClientMessageScope clientMessageScopeFromJson(
  Object? clientMessageScope, [
  enums.ClientMessageScope? defaultValue,
]) {
  return enums.ClientMessageScope.values.firstWhereOrNull((e) => e.value == clientMessageScope) ??
      defaultValue ??
      enums.ClientMessageScope.swaggerGeneratedUnknown;
}

enums.ClientMessageScope? clientMessageScopeNullableFromJson(
  Object? clientMessageScope, [
  enums.ClientMessageScope? defaultValue,
]) {
  if (clientMessageScope == null) {
    return null;
  }
  return enums.ClientMessageScope.values.firstWhereOrNull((e) => e.value == clientMessageScope) ?? defaultValue;
}

String clientMessageScopeExplodedListToJson(List<enums.ClientMessageScope>? clientMessageScope) {
  return clientMessageScope?.map((e) => e.value!).join(',') ?? '';
}

List<String> clientMessageScopeListToJson(List<enums.ClientMessageScope>? clientMessageScope) {
  if (clientMessageScope == null) {
    return [];
  }

  return clientMessageScope.map((e) => e.value!).toList();
}

List<enums.ClientMessageScope> clientMessageScopeListFromJson(
  List? clientMessageScope, [
  List<enums.ClientMessageScope>? defaultValue,
]) {
  if (clientMessageScope == null) {
    return defaultValue ?? [];
  }

  return clientMessageScope.map((e) => clientMessageScopeFromJson(e.toString())).toList();
}

List<enums.ClientMessageScope>? clientMessageScopeNullableListFromJson(
  List? clientMessageScope, [
  List<enums.ClientMessageScope>? defaultValue,
]) {
  if (clientMessageScope == null) {
    return defaultValue;
  }

  return clientMessageScope.map((e) => clientMessageScopeFromJson(e.toString())).toList();
}

String? clientMessageTypeNullableToJson(enums.ClientMessageType? clientMessageType) {
  return clientMessageType?.value;
}

String? clientMessageTypeToJson(enums.ClientMessageType clientMessageType) {
  return clientMessageType.value;
}

enums.ClientMessageType clientMessageTypeFromJson(Object? clientMessageType, [enums.ClientMessageType? defaultValue]) {
  return enums.ClientMessageType.values.firstWhereOrNull((e) => e.value == clientMessageType) ??
      defaultValue ??
      enums.ClientMessageType.swaggerGeneratedUnknown;
}

enums.ClientMessageType? clientMessageTypeNullableFromJson(
  Object? clientMessageType, [
  enums.ClientMessageType? defaultValue,
]) {
  if (clientMessageType == null) {
    return null;
  }
  return enums.ClientMessageType.values.firstWhereOrNull((e) => e.value == clientMessageType) ?? defaultValue;
}

String clientMessageTypeExplodedListToJson(List<enums.ClientMessageType>? clientMessageType) {
  return clientMessageType?.map((e) => e.value!).join(',') ?? '';
}

List<String> clientMessageTypeListToJson(List<enums.ClientMessageType>? clientMessageType) {
  if (clientMessageType == null) {
    return [];
  }

  return clientMessageType.map((e) => e.value!).toList();
}

List<enums.ClientMessageType> clientMessageTypeListFromJson(
  List? clientMessageType, [
  List<enums.ClientMessageType>? defaultValue,
]) {
  if (clientMessageType == null) {
    return defaultValue ?? [];
  }

  return clientMessageType.map((e) => clientMessageTypeFromJson(e.toString())).toList();
}

List<enums.ClientMessageType>? clientMessageTypeNullableListFromJson(
  List? clientMessageType, [
  List<enums.ClientMessageType>? defaultValue,
]) {
  if (clientMessageType == null) {
    return defaultValue;
  }

  return clientMessageType.map((e) => clientMessageTypeFromJson(e.toString())).toList();
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

String? eventMessageStatusNullableToJson(enums.EventMessageStatus? eventMessageStatus) {
  return eventMessageStatus?.value;
}

String? eventMessageStatusToJson(enums.EventMessageStatus eventMessageStatus) {
  return eventMessageStatus.value;
}

enums.EventMessageStatus eventMessageStatusFromJson(
  Object? eventMessageStatus, [
  enums.EventMessageStatus? defaultValue,
]) {
  return enums.EventMessageStatus.values.firstWhereOrNull((e) => e.value == eventMessageStatus) ??
      defaultValue ??
      enums.EventMessageStatus.swaggerGeneratedUnknown;
}

enums.EventMessageStatus? eventMessageStatusNullableFromJson(
  Object? eventMessageStatus, [
  enums.EventMessageStatus? defaultValue,
]) {
  if (eventMessageStatus == null) {
    return null;
  }
  return enums.EventMessageStatus.values.firstWhereOrNull((e) => e.value == eventMessageStatus) ?? defaultValue;
}

String eventMessageStatusExplodedListToJson(List<enums.EventMessageStatus>? eventMessageStatus) {
  return eventMessageStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> eventMessageStatusListToJson(List<enums.EventMessageStatus>? eventMessageStatus) {
  if (eventMessageStatus == null) {
    return [];
  }

  return eventMessageStatus.map((e) => e.value!).toList();
}

List<enums.EventMessageStatus> eventMessageStatusListFromJson(
  List? eventMessageStatus, [
  List<enums.EventMessageStatus>? defaultValue,
]) {
  if (eventMessageStatus == null) {
    return defaultValue ?? [];
  }

  return eventMessageStatus.map((e) => eventMessageStatusFromJson(e.toString())).toList();
}

List<enums.EventMessageStatus>? eventMessageStatusNullableListFromJson(
  List? eventMessageStatus, [
  List<enums.EventMessageStatus>? defaultValue,
]) {
  if (eventMessageStatus == null) {
    return defaultValue;
  }

  return eventMessageStatus.map((e) => eventMessageStatusFromJson(e.toString())).toList();
}

String? eventMessageTypeNullableToJson(enums.EventMessageType? eventMessageType) {
  return eventMessageType?.value;
}

String? eventMessageTypeToJson(enums.EventMessageType eventMessageType) {
  return eventMessageType.value;
}

enums.EventMessageType eventMessageTypeFromJson(Object? eventMessageType, [enums.EventMessageType? defaultValue]) {
  return enums.EventMessageType.values.firstWhereOrNull((e) => e.value == eventMessageType) ??
      defaultValue ??
      enums.EventMessageType.swaggerGeneratedUnknown;
}

enums.EventMessageType? eventMessageTypeNullableFromJson(
  Object? eventMessageType, [
  enums.EventMessageType? defaultValue,
]) {
  if (eventMessageType == null) {
    return null;
  }
  return enums.EventMessageType.values.firstWhereOrNull((e) => e.value == eventMessageType) ?? defaultValue;
}

String eventMessageTypeExplodedListToJson(List<enums.EventMessageType>? eventMessageType) {
  return eventMessageType?.map((e) => e.value!).join(',') ?? '';
}

List<String> eventMessageTypeListToJson(List<enums.EventMessageType>? eventMessageType) {
  if (eventMessageType == null) {
    return [];
  }

  return eventMessageType.map((e) => e.value!).toList();
}

List<enums.EventMessageType> eventMessageTypeListFromJson(
  List? eventMessageType, [
  List<enums.EventMessageType>? defaultValue,
]) {
  if (eventMessageType == null) {
    return defaultValue ?? [];
  }

  return eventMessageType.map((e) => eventMessageTypeFromJson(e.toString())).toList();
}

List<enums.EventMessageType>? eventMessageTypeNullableListFromJson(
  List? eventMessageType, [
  List<enums.EventMessageType>? defaultValue,
]) {
  if (eventMessageType == null) {
    return defaultValue;
  }

  return eventMessageType.map((e) => eventMessageTypeFromJson(e.toString())).toList();
}

String? extractionStatusOcrNullableToJson(enums.ExtractionStatusOcr? extractionStatusOcr) {
  return extractionStatusOcr?.value;
}

String? extractionStatusOcrToJson(enums.ExtractionStatusOcr extractionStatusOcr) {
  return extractionStatusOcr.value;
}

enums.ExtractionStatusOcr extractionStatusOcrFromJson(
  Object? extractionStatusOcr, [
  enums.ExtractionStatusOcr? defaultValue,
]) {
  return enums.ExtractionStatusOcr.values.firstWhereOrNull((e) => e.value == extractionStatusOcr) ??
      defaultValue ??
      enums.ExtractionStatusOcr.swaggerGeneratedUnknown;
}

enums.ExtractionStatusOcr? extractionStatusOcrNullableFromJson(
  Object? extractionStatusOcr, [
  enums.ExtractionStatusOcr? defaultValue,
]) {
  if (extractionStatusOcr == null) {
    return null;
  }
  return enums.ExtractionStatusOcr.values.firstWhereOrNull((e) => e.value == extractionStatusOcr) ?? defaultValue;
}

String extractionStatusOcrExplodedListToJson(List<enums.ExtractionStatusOcr>? extractionStatusOcr) {
  return extractionStatusOcr?.map((e) => e.value!).join(',') ?? '';
}

List<String> extractionStatusOcrListToJson(List<enums.ExtractionStatusOcr>? extractionStatusOcr) {
  if (extractionStatusOcr == null) {
    return [];
  }

  return extractionStatusOcr.map((e) => e.value!).toList();
}

List<enums.ExtractionStatusOcr> extractionStatusOcrListFromJson(
  List? extractionStatusOcr, [
  List<enums.ExtractionStatusOcr>? defaultValue,
]) {
  if (extractionStatusOcr == null) {
    return defaultValue ?? [];
  }

  return extractionStatusOcr.map((e) => extractionStatusOcrFromJson(e.toString())).toList();
}

List<enums.ExtractionStatusOcr>? extractionStatusOcrNullableListFromJson(
  List? extractionStatusOcr, [
  List<enums.ExtractionStatusOcr>? defaultValue,
]) {
  if (extractionStatusOcr == null) {
    return defaultValue;
  }

  return extractionStatusOcr.map((e) => extractionStatusOcrFromJson(e.toString())).toList();
}

String? liveTransferDirectionNullableToJson(enums.LiveTransferDirection? liveTransferDirection) {
  return liveTransferDirection?.value;
}

String? liveTransferDirectionToJson(enums.LiveTransferDirection liveTransferDirection) {
  return liveTransferDirection.value;
}

enums.LiveTransferDirection liveTransferDirectionFromJson(
  Object? liveTransferDirection, [
  enums.LiveTransferDirection? defaultValue,
]) {
  return enums.LiveTransferDirection.values.firstWhereOrNull((e) => e.value == liveTransferDirection) ??
      defaultValue ??
      enums.LiveTransferDirection.swaggerGeneratedUnknown;
}

enums.LiveTransferDirection? liveTransferDirectionNullableFromJson(
  Object? liveTransferDirection, [
  enums.LiveTransferDirection? defaultValue,
]) {
  if (liveTransferDirection == null) {
    return null;
  }
  return enums.LiveTransferDirection.values.firstWhereOrNull((e) => e.value == liveTransferDirection) ?? defaultValue;
}

String liveTransferDirectionExplodedListToJson(List<enums.LiveTransferDirection>? liveTransferDirection) {
  return liveTransferDirection?.map((e) => e.value!).join(',') ?? '';
}

List<String> liveTransferDirectionListToJson(List<enums.LiveTransferDirection>? liveTransferDirection) {
  if (liveTransferDirection == null) {
    return [];
  }

  return liveTransferDirection.map((e) => e.value!).toList();
}

List<enums.LiveTransferDirection> liveTransferDirectionListFromJson(
  List? liveTransferDirection, [
  List<enums.LiveTransferDirection>? defaultValue,
]) {
  if (liveTransferDirection == null) {
    return defaultValue ?? [];
  }

  return liveTransferDirection.map((e) => liveTransferDirectionFromJson(e.toString())).toList();
}

List<enums.LiveTransferDirection>? liveTransferDirectionNullableListFromJson(
  List? liveTransferDirection, [
  List<enums.LiveTransferDirection>? defaultValue,
]) {
  if (liveTransferDirection == null) {
    return defaultValue;
  }

  return liveTransferDirection.map((e) => liveTransferDirectionFromJson(e.toString())).toList();
}

String? logEntryKindNullableToJson(enums.LogEntryKind? logEntryKind) {
  return logEntryKind?.value;
}

String? logEntryKindToJson(enums.LogEntryKind logEntryKind) {
  return logEntryKind.value;
}

enums.LogEntryKind logEntryKindFromJson(Object? logEntryKind, [enums.LogEntryKind? defaultValue]) {
  return enums.LogEntryKind.values.firstWhereOrNull((e) => e.value == logEntryKind) ??
      defaultValue ??
      enums.LogEntryKind.swaggerGeneratedUnknown;
}

enums.LogEntryKind? logEntryKindNullableFromJson(Object? logEntryKind, [enums.LogEntryKind? defaultValue]) {
  if (logEntryKind == null) {
    return null;
  }
  return enums.LogEntryKind.values.firstWhereOrNull((e) => e.value == logEntryKind) ?? defaultValue;
}

String logEntryKindExplodedListToJson(List<enums.LogEntryKind>? logEntryKind) {
  return logEntryKind?.map((e) => e.value!).join(',') ?? '';
}

List<String> logEntryKindListToJson(List<enums.LogEntryKind>? logEntryKind) {
  if (logEntryKind == null) {
    return [];
  }

  return logEntryKind.map((e) => e.value!).toList();
}

List<enums.LogEntryKind> logEntryKindListFromJson(List? logEntryKind, [List<enums.LogEntryKind>? defaultValue]) {
  if (logEntryKind == null) {
    return defaultValue ?? [];
  }

  return logEntryKind.map((e) => logEntryKindFromJson(e.toString())).toList();
}

List<enums.LogEntryKind>? logEntryKindNullableListFromJson(
  List? logEntryKind, [
  List<enums.LogEntryKind>? defaultValue,
]) {
  if (logEntryKind == null) {
    return defaultValue;
  }

  return logEntryKind.map((e) => logEntryKindFromJson(e.toString())).toList();
}

String? logEntryStatusNullableToJson(enums.LogEntryStatus? logEntryStatus) {
  return logEntryStatus?.value;
}

String? logEntryStatusToJson(enums.LogEntryStatus logEntryStatus) {
  return logEntryStatus.value;
}

enums.LogEntryStatus logEntryStatusFromJson(Object? logEntryStatus, [enums.LogEntryStatus? defaultValue]) {
  return enums.LogEntryStatus.values.firstWhereOrNull((e) => e.value == logEntryStatus) ??
      defaultValue ??
      enums.LogEntryStatus.swaggerGeneratedUnknown;
}

enums.LogEntryStatus? logEntryStatusNullableFromJson(Object? logEntryStatus, [enums.LogEntryStatus? defaultValue]) {
  if (logEntryStatus == null) {
    return null;
  }
  return enums.LogEntryStatus.values.firstWhereOrNull((e) => e.value == logEntryStatus) ?? defaultValue;
}

String logEntryStatusExplodedListToJson(List<enums.LogEntryStatus>? logEntryStatus) {
  return logEntryStatus?.map((e) => e.value!).join(',') ?? '';
}

List<String> logEntryStatusListToJson(List<enums.LogEntryStatus>? logEntryStatus) {
  if (logEntryStatus == null) {
    return [];
  }

  return logEntryStatus.map((e) => e.value!).toList();
}

List<enums.LogEntryStatus> logEntryStatusListFromJson(
  List? logEntryStatus, [
  List<enums.LogEntryStatus>? defaultValue,
]) {
  if (logEntryStatus == null) {
    return defaultValue ?? [];
  }

  return logEntryStatus.map((e) => logEntryStatusFromJson(e.toString())).toList();
}

List<enums.LogEntryStatus>? logEntryStatusNullableListFromJson(
  List? logEntryStatus, [
  List<enums.LogEntryStatus>? defaultValue,
]) {
  if (logEntryStatus == null) {
    return defaultValue;
  }

  return logEntryStatus.map((e) => logEntryStatusFromJson(e.toString())).toList();
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

String? queryFilterKeyNullableToJson(enums.QueryFilterKey? queryFilterKey) {
  return queryFilterKey?.value;
}

String? queryFilterKeyToJson(enums.QueryFilterKey queryFilterKey) {
  return queryFilterKey.value;
}

enums.QueryFilterKey queryFilterKeyFromJson(Object? queryFilterKey, [enums.QueryFilterKey? defaultValue]) {
  return enums.QueryFilterKey.values.firstWhereOrNull((e) => e.value == queryFilterKey) ??
      defaultValue ??
      enums.QueryFilterKey.swaggerGeneratedUnknown;
}

enums.QueryFilterKey? queryFilterKeyNullableFromJson(Object? queryFilterKey, [enums.QueryFilterKey? defaultValue]) {
  if (queryFilterKey == null) {
    return null;
  }
  return enums.QueryFilterKey.values.firstWhereOrNull((e) => e.value == queryFilterKey) ?? defaultValue;
}

String queryFilterKeyExplodedListToJson(List<enums.QueryFilterKey>? queryFilterKey) {
  return queryFilterKey?.map((e) => e.value!).join(',') ?? '';
}

List<String> queryFilterKeyListToJson(List<enums.QueryFilterKey>? queryFilterKey) {
  if (queryFilterKey == null) {
    return [];
  }

  return queryFilterKey.map((e) => e.value!).toList();
}

List<enums.QueryFilterKey> queryFilterKeyListFromJson(
  List? queryFilterKey, [
  List<enums.QueryFilterKey>? defaultValue,
]) {
  if (queryFilterKey == null) {
    return defaultValue ?? [];
  }

  return queryFilterKey.map((e) => queryFilterKeyFromJson(e.toString())).toList();
}

List<enums.QueryFilterKey>? queryFilterKeyNullableListFromJson(
  List? queryFilterKey, [
  List<enums.QueryFilterKey>? defaultValue,
]) {
  if (queryFilterKey == null) {
    return defaultValue;
  }

  return queryFilterKey.map((e) => queryFilterKeyFromJson(e.toString())).toList();
}

String? queryFilterOpNullableToJson(enums.QueryFilterOp? queryFilterOp) {
  return queryFilterOp?.value;
}

String? queryFilterOpToJson(enums.QueryFilterOp queryFilterOp) {
  return queryFilterOp.value;
}

enums.QueryFilterOp queryFilterOpFromJson(Object? queryFilterOp, [enums.QueryFilterOp? defaultValue]) {
  return enums.QueryFilterOp.values.firstWhereOrNull((e) => e.value == queryFilterOp) ??
      defaultValue ??
      enums.QueryFilterOp.swaggerGeneratedUnknown;
}

enums.QueryFilterOp? queryFilterOpNullableFromJson(Object? queryFilterOp, [enums.QueryFilterOp? defaultValue]) {
  if (queryFilterOp == null) {
    return null;
  }
  return enums.QueryFilterOp.values.firstWhereOrNull((e) => e.value == queryFilterOp) ?? defaultValue;
}

String queryFilterOpExplodedListToJson(List<enums.QueryFilterOp>? queryFilterOp) {
  return queryFilterOp?.map((e) => e.value!).join(',') ?? '';
}

List<String> queryFilterOpListToJson(List<enums.QueryFilterOp>? queryFilterOp) {
  if (queryFilterOp == null) {
    return [];
  }

  return queryFilterOp.map((e) => e.value!).toList();
}

List<enums.QueryFilterOp> queryFilterOpListFromJson(List? queryFilterOp, [List<enums.QueryFilterOp>? defaultValue]) {
  if (queryFilterOp == null) {
    return defaultValue ?? [];
  }

  return queryFilterOp.map((e) => queryFilterOpFromJson(e.toString())).toList();
}

List<enums.QueryFilterOp>? queryFilterOpNullableListFromJson(
  List? queryFilterOp, [
  List<enums.QueryFilterOp>? defaultValue,
]) {
  if (queryFilterOp == null) {
    return defaultValue;
  }

  return queryFilterOp.map((e) => queryFilterOpFromJson(e.toString())).toList();
}

String? restoreRequestOnConflictNullableToJson(enums.RestoreRequestOnConflict? restoreRequestOnConflict) {
  return restoreRequestOnConflict?.value;
}

String? restoreRequestOnConflictToJson(enums.RestoreRequestOnConflict restoreRequestOnConflict) {
  return restoreRequestOnConflict.value;
}

enums.RestoreRequestOnConflict restoreRequestOnConflictFromJson(
  Object? restoreRequestOnConflict, [
  enums.RestoreRequestOnConflict? defaultValue,
]) {
  return enums.RestoreRequestOnConflict.values.firstWhereOrNull((e) => e.value == restoreRequestOnConflict) ??
      defaultValue ??
      enums.RestoreRequestOnConflict.swaggerGeneratedUnknown;
}

enums.RestoreRequestOnConflict? restoreRequestOnConflictNullableFromJson(
  Object? restoreRequestOnConflict, [
  enums.RestoreRequestOnConflict? defaultValue,
]) {
  if (restoreRequestOnConflict == null) {
    return null;
  }
  return enums.RestoreRequestOnConflict.values.firstWhereOrNull((e) => e.value == restoreRequestOnConflict) ??
      defaultValue;
}

String restoreRequestOnConflictExplodedListToJson(List<enums.RestoreRequestOnConflict>? restoreRequestOnConflict) {
  return restoreRequestOnConflict?.map((e) => e.value!).join(',') ?? '';
}

List<String> restoreRequestOnConflictListToJson(List<enums.RestoreRequestOnConflict>? restoreRequestOnConflict) {
  if (restoreRequestOnConflict == null) {
    return [];
  }

  return restoreRequestOnConflict.map((e) => e.value!).toList();
}

List<enums.RestoreRequestOnConflict> restoreRequestOnConflictListFromJson(
  List? restoreRequestOnConflict, [
  List<enums.RestoreRequestOnConflict>? defaultValue,
]) {
  if (restoreRequestOnConflict == null) {
    return defaultValue ?? [];
  }

  return restoreRequestOnConflict.map((e) => restoreRequestOnConflictFromJson(e.toString())).toList();
}

List<enums.RestoreRequestOnConflict>? restoreRequestOnConflictNullableListFromJson(
  List? restoreRequestOnConflict, [
  List<enums.RestoreRequestOnConflict>? defaultValue,
]) {
  if (restoreRequestOnConflict == null) {
    return defaultValue;
  }

  return restoreRequestOnConflict.map((e) => restoreRequestOnConflictFromJson(e.toString())).toList();
}

String? suggestionKindNullableToJson(enums.SuggestionKind? suggestionKind) {
  return suggestionKind?.value;
}

String? suggestionKindToJson(enums.SuggestionKind suggestionKind) {
  return suggestionKind.value;
}

enums.SuggestionKind suggestionKindFromJson(Object? suggestionKind, [enums.SuggestionKind? defaultValue]) {
  return enums.SuggestionKind.values.firstWhereOrNull((e) => e.value == suggestionKind) ??
      defaultValue ??
      enums.SuggestionKind.swaggerGeneratedUnknown;
}

enums.SuggestionKind? suggestionKindNullableFromJson(Object? suggestionKind, [enums.SuggestionKind? defaultValue]) {
  if (suggestionKind == null) {
    return null;
  }
  return enums.SuggestionKind.values.firstWhereOrNull((e) => e.value == suggestionKind) ?? defaultValue;
}

String suggestionKindExplodedListToJson(List<enums.SuggestionKind>? suggestionKind) {
  return suggestionKind?.map((e) => e.value!).join(',') ?? '';
}

List<String> suggestionKindListToJson(List<enums.SuggestionKind>? suggestionKind) {
  if (suggestionKind == null) {
    return [];
  }

  return suggestionKind.map((e) => e.value!).toList();
}

List<enums.SuggestionKind> suggestionKindListFromJson(
  List? suggestionKind, [
  List<enums.SuggestionKind>? defaultValue,
]) {
  if (suggestionKind == null) {
    return defaultValue ?? [];
  }

  return suggestionKind.map((e) => suggestionKindFromJson(e.toString())).toList();
}

List<enums.SuggestionKind>? suggestionKindNullableListFromJson(
  List? suggestionKind, [
  List<enums.SuggestionKind>? defaultValue,
]) {
  if (suggestionKind == null) {
    return defaultValue;
  }

  return suggestionKind.map((e) => suggestionKindFromJson(e.toString())).toList();
}

String? trashItemPreviewStateNullableToJson(enums.TrashItemPreviewState? trashItemPreviewState) {
  return trashItemPreviewState?.value;
}

String? trashItemPreviewStateToJson(enums.TrashItemPreviewState trashItemPreviewState) {
  return trashItemPreviewState.value;
}

enums.TrashItemPreviewState trashItemPreviewStateFromJson(
  Object? trashItemPreviewState, [
  enums.TrashItemPreviewState? defaultValue,
]) {
  return enums.TrashItemPreviewState.values.firstWhereOrNull((e) => e.value == trashItemPreviewState) ??
      defaultValue ??
      enums.TrashItemPreviewState.swaggerGeneratedUnknown;
}

enums.TrashItemPreviewState? trashItemPreviewStateNullableFromJson(
  Object? trashItemPreviewState, [
  enums.TrashItemPreviewState? defaultValue,
]) {
  if (trashItemPreviewState == null) {
    return null;
  }
  return enums.TrashItemPreviewState.values.firstWhereOrNull((e) => e.value == trashItemPreviewState) ?? defaultValue;
}

String trashItemPreviewStateExplodedListToJson(List<enums.TrashItemPreviewState>? trashItemPreviewState) {
  return trashItemPreviewState?.map((e) => e.value!).join(',') ?? '';
}

List<String> trashItemPreviewStateListToJson(List<enums.TrashItemPreviewState>? trashItemPreviewState) {
  if (trashItemPreviewState == null) {
    return [];
  }

  return trashItemPreviewState.map((e) => e.value!).toList();
}

List<enums.TrashItemPreviewState> trashItemPreviewStateListFromJson(
  List? trashItemPreviewState, [
  List<enums.TrashItemPreviewState>? defaultValue,
]) {
  if (trashItemPreviewState == null) {
    return defaultValue ?? [];
  }

  return trashItemPreviewState.map((e) => trashItemPreviewStateFromJson(e.toString())).toList();
}

List<enums.TrashItemPreviewState>? trashItemPreviewStateNullableListFromJson(
  List? trashItemPreviewState, [
  List<enums.TrashItemPreviewState>? defaultValue,
]) {
  if (trashItemPreviewState == null) {
    return defaultValue;
  }

  return trashItemPreviewState.map((e) => trashItemPreviewStateFromJson(e.toString())).toList();
}

String? trashRetentionSourceNullableToJson(enums.TrashRetentionSource? trashRetentionSource) {
  return trashRetentionSource?.value;
}

String? trashRetentionSourceToJson(enums.TrashRetentionSource trashRetentionSource) {
  return trashRetentionSource.value;
}

enums.TrashRetentionSource trashRetentionSourceFromJson(
  Object? trashRetentionSource, [
  enums.TrashRetentionSource? defaultValue,
]) {
  return enums.TrashRetentionSource.values.firstWhereOrNull((e) => e.value == trashRetentionSource) ??
      defaultValue ??
      enums.TrashRetentionSource.swaggerGeneratedUnknown;
}

enums.TrashRetentionSource? trashRetentionSourceNullableFromJson(
  Object? trashRetentionSource, [
  enums.TrashRetentionSource? defaultValue,
]) {
  if (trashRetentionSource == null) {
    return null;
  }
  return enums.TrashRetentionSource.values.firstWhereOrNull((e) => e.value == trashRetentionSource) ?? defaultValue;
}

String trashRetentionSourceExplodedListToJson(List<enums.TrashRetentionSource>? trashRetentionSource) {
  return trashRetentionSource?.map((e) => e.value!).join(',') ?? '';
}

List<String> trashRetentionSourceListToJson(List<enums.TrashRetentionSource>? trashRetentionSource) {
  if (trashRetentionSource == null) {
    return [];
  }

  return trashRetentionSource.map((e) => e.value!).toList();
}

List<enums.TrashRetentionSource> trashRetentionSourceListFromJson(
  List? trashRetentionSource, [
  List<enums.TrashRetentionSource>? defaultValue,
]) {
  if (trashRetentionSource == null) {
    return defaultValue ?? [];
  }

  return trashRetentionSource.map((e) => trashRetentionSourceFromJson(e.toString())).toList();
}

List<enums.TrashRetentionSource>? trashRetentionSourceNullableListFromJson(
  List? trashRetentionSource, [
  List<enums.TrashRetentionSource>? defaultValue,
]) {
  if (trashRetentionSource == null) {
    return defaultValue;
  }

  return trashRetentionSource.map((e) => trashRetentionSourceFromJson(e.toString())).toList();
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

int? apiV1TrashItemIDPreviewGetSizeNullableToJson(
  enums.ApiV1TrashItemIDPreviewGetSize? apiV1TrashItemIDPreviewGetSize,
) {
  return apiV1TrashItemIDPreviewGetSize?.value;
}

int? apiV1TrashItemIDPreviewGetSizeToJson(enums.ApiV1TrashItemIDPreviewGetSize apiV1TrashItemIDPreviewGetSize) {
  return apiV1TrashItemIDPreviewGetSize.value;
}

enums.ApiV1TrashItemIDPreviewGetSize apiV1TrashItemIDPreviewGetSizeFromJson(
  Object? apiV1TrashItemIDPreviewGetSize, [
  enums.ApiV1TrashItemIDPreviewGetSize? defaultValue,
]) {
  return enums.ApiV1TrashItemIDPreviewGetSize.values.firstWhereOrNull(
        (e) => e.value == apiV1TrashItemIDPreviewGetSize,
      ) ??
      defaultValue ??
      enums.ApiV1TrashItemIDPreviewGetSize.swaggerGeneratedUnknown;
}

enums.ApiV1TrashItemIDPreviewGetSize? apiV1TrashItemIDPreviewGetSizeNullableFromJson(
  Object? apiV1TrashItemIDPreviewGetSize, [
  enums.ApiV1TrashItemIDPreviewGetSize? defaultValue,
]) {
  if (apiV1TrashItemIDPreviewGetSize == null) {
    return null;
  }
  return enums.ApiV1TrashItemIDPreviewGetSize.values.firstWhereOrNull(
        (e) => e.value == apiV1TrashItemIDPreviewGetSize,
      ) ??
      defaultValue;
}

String apiV1TrashItemIDPreviewGetSizeExplodedListToJson(
  List<enums.ApiV1TrashItemIDPreviewGetSize>? apiV1TrashItemIDPreviewGetSize,
) {
  return apiV1TrashItemIDPreviewGetSize?.map((e) => e.value!).join(',') ?? '';
}

List<int> apiV1TrashItemIDPreviewGetSizeListToJson(
  List<enums.ApiV1TrashItemIDPreviewGetSize>? apiV1TrashItemIDPreviewGetSize,
) {
  if (apiV1TrashItemIDPreviewGetSize == null) {
    return [];
  }

  return apiV1TrashItemIDPreviewGetSize.map((e) => e.value!).toList();
}

List<enums.ApiV1TrashItemIDPreviewGetSize> apiV1TrashItemIDPreviewGetSizeListFromJson(
  List? apiV1TrashItemIDPreviewGetSize, [
  List<enums.ApiV1TrashItemIDPreviewGetSize>? defaultValue,
]) {
  if (apiV1TrashItemIDPreviewGetSize == null) {
    return defaultValue ?? [];
  }

  return apiV1TrashItemIDPreviewGetSize.map((e) => apiV1TrashItemIDPreviewGetSizeFromJson(e)).toList();
}

List<enums.ApiV1TrashItemIDPreviewGetSize>? apiV1TrashItemIDPreviewGetSizeNullableListFromJson(
  List? apiV1TrashItemIDPreviewGetSize, [
  List<enums.ApiV1TrashItemIDPreviewGetSize>? defaultValue,
]) {
  if (apiV1TrashItemIDPreviewGetSize == null) {
    return defaultValue;
  }

  return apiV1TrashItemIDPreviewGetSize.map((e) => apiV1TrashItemIDPreviewGetSizeFromJson(e)).toList();
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
