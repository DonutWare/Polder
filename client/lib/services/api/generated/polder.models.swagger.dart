// coverage:ignore-file
// ignore_for_file: type=lint

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'polder.enums.swagger.dart' as enums;

part 'polder.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class Appearance {
  const Appearance({this.accentColor, this.theme});

  factory Appearance.fromJson(Map<String, dynamic> json) => _$AppearanceFromJson(json);

  static const toJsonFactory = _$AppearanceToJson;
  Map<String, dynamic> toJson() => _$AppearanceToJson(this);

  @JsonKey(name: 'accentColor', includeIfNull: false)
  final String? accentColor;
  @JsonKey(
    name: 'theme',
    includeIfNull: false,
    toJson: appearanceThemeNullableToJson,
    fromJson: appearanceThemeNullableFromJson,
  )
  final enums.AppearanceTheme? theme;
  static const fromJsonFactory = _$AppearanceFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Appearance &&
            (identical(other.accentColor, accentColor) ||
                const DeepCollectionEquality().equals(other.accentColor, accentColor)) &&
            (identical(other.theme, theme) || const DeepCollectionEquality().equals(other.theme, theme)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accentColor) ^
      const DeepCollectionEquality().hash(theme) ^
      runtimeType.hashCode;
}

extension $AppearanceExtension on Appearance {
  Appearance copyWith({String? accentColor, enums.AppearanceTheme? theme}) {
    return Appearance(accentColor: accentColor ?? this.accentColor, theme: theme ?? this.theme);
  }

  Appearance copyWithWrapped({Wrapped<String?>? accentColor, Wrapped<enums.AppearanceTheme?>? theme}) {
    return Appearance(
      accentColor: (accentColor != null ? accentColor.value : this.accentColor),
      theme: (theme != null ? theme.value : this.theme),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Avatar {
  const Avatar({required this.contentType, required this.id});

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);

  static const toJsonFactory = _$AvatarToJson;
  Map<String, dynamic> toJson() => _$AvatarToJson(this);

  @JsonKey(name: 'contentType', includeIfNull: false)
  final String contentType;
  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  static const fromJsonFactory = _$AvatarFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Avatar &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(other.contentType, contentType)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(contentType) ^ const DeepCollectionEquality().hash(id) ^ runtimeType.hashCode;
}

extension $AvatarExtension on Avatar {
  Avatar copyWith({String? contentType, String? id}) {
    return Avatar(contentType: contentType ?? this.contentType, id: id ?? this.id);
  }

  Avatar copyWithWrapped({Wrapped<String>? contentType, Wrapped<String>? id}) {
    return Avatar(
      contentType: (contentType != null ? contentType.value : this.contentType),
      id: (id != null ? id.value : this.id),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Branding {
  const Branding({required this.accentColor, this.backgrounds, this.icon, required this.message, required this.name});

  factory Branding.fromJson(Map<String, dynamic> json) => _$BrandingFromJson(json);

  static const toJsonFactory = _$BrandingToJson;
  Map<String, dynamic> toJson() => _$BrandingToJson(this);

  @JsonKey(name: 'accentColor', includeIfNull: false)
  final String accentColor;
  @JsonKey(name: 'backgrounds', includeIfNull: false, defaultValue: <ImageInfo>[])
  final List<ImageInfo>? backgrounds;
  @JsonKey(name: 'icon', includeIfNull: false)
  final ImageInfo? icon;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  static const fromJsonFactory = _$BrandingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Branding &&
            (identical(other.accentColor, accentColor) ||
                const DeepCollectionEquality().equals(other.accentColor, accentColor)) &&
            (identical(other.backgrounds, backgrounds) ||
                const DeepCollectionEquality().equals(other.backgrounds, backgrounds)) &&
            (identical(other.icon, icon) || const DeepCollectionEquality().equals(other.icon, icon)) &&
            (identical(other.message, message) || const DeepCollectionEquality().equals(other.message, message)) &&
            (identical(other.name, name) || const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accentColor) ^
      const DeepCollectionEquality().hash(backgrounds) ^
      const DeepCollectionEquality().hash(icon) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(name) ^
      runtimeType.hashCode;
}

extension $BrandingExtension on Branding {
  Branding copyWith({
    String? accentColor,
    List<ImageInfo>? backgrounds,
    ImageInfo? icon,
    String? message,
    String? name,
  }) {
    return Branding(
      accentColor: accentColor ?? this.accentColor,
      backgrounds: backgrounds ?? this.backgrounds,
      icon: icon ?? this.icon,
      message: message ?? this.message,
      name: name ?? this.name,
    );
  }

  Branding copyWithWrapped({
    Wrapped<String>? accentColor,
    Wrapped<List<ImageInfo>?>? backgrounds,
    Wrapped<ImageInfo?>? icon,
    Wrapped<String>? message,
    Wrapped<String>? name,
  }) {
    return Branding(
      accentColor: (accentColor != null ? accentColor.value : this.accentColor),
      backgrounds: (backgrounds != null ? backgrounds.value : this.backgrounds),
      icon: (icon != null ? icon.value : this.icon),
      message: (message != null ? message.value : this.message),
      name: (name != null ? name.value : this.name),
    );
  }
}

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
class CopyRequest {
  const CopyRequest({required this.from, required this.to});

  factory CopyRequest.fromJson(Map<String, dynamic> json) => _$CopyRequestFromJson(json);

  static const toJsonFactory = _$CopyRequestToJson;
  Map<String, dynamic> toJson() => _$CopyRequestToJson(this);

  @JsonKey(name: 'from', includeIfNull: false)
  final String from;
  @JsonKey(name: 'to', includeIfNull: false)
  final String to;
  static const fromJsonFactory = _$CopyRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CopyRequest &&
            (identical(other.from, from) || const DeepCollectionEquality().equals(other.from, from)) &&
            (identical(other.to, to) || const DeepCollectionEquality().equals(other.to, to)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(from) ^ const DeepCollectionEquality().hash(to) ^ runtimeType.hashCode;
}

extension $CopyRequestExtension on CopyRequest {
  CopyRequest copyWith({String? from, String? to}) {
    return CopyRequest(from: from ?? this.from, to: to ?? this.to);
  }

  CopyRequest copyWithWrapped({Wrapped<String>? from, Wrapped<String>? to}) {
    return CopyRequest(from: (from != null ? from.value : this.from), to: (to != null ? to.value : this.to));
  }
}

@JsonSerializable(explicitToJson: true)
class CreatableApp {
  const CreatableApp({required this.app, this.extensions});

  factory CreatableApp.fromJson(Map<String, dynamic> json) => _$CreatableAppFromJson(json);

  static const toJsonFactory = _$CreatableAppToJson;
  Map<String, dynamic> toJson() => _$CreatableAppToJson(this);

  @JsonKey(name: 'app', includeIfNull: false)
  final String app;
  @JsonKey(name: 'extensions', includeIfNull: false, defaultValue: <String>[])
  final List<String>? extensions;
  static const fromJsonFactory = _$CreatableAppFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreatableApp &&
            (identical(other.app, app) || const DeepCollectionEquality().equals(other.app, app)) &&
            (identical(other.extensions, extensions) ||
                const DeepCollectionEquality().equals(other.extensions, extensions)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(app) ^ const DeepCollectionEquality().hash(extensions) ^ runtimeType.hashCode;
}

extension $CreatableAppExtension on CreatableApp {
  CreatableApp copyWith({String? app, List<String>? extensions}) {
    return CreatableApp(app: app ?? this.app, extensions: extensions ?? this.extensions);
  }

  CreatableApp copyWithWrapped({Wrapped<String>? app, Wrapped<List<String>?>? extensions}) {
    return CreatableApp(
      app: (app != null ? app.value : this.app),
      extensions: (extensions != null ? extensions.value : this.extensions),
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
class EditorCapabilities {
  const EditorCapabilities({
    this.creatable,
    this.editableExtensions,
    this.editableMimes,
    required this.enabled,
    this.viewableExtensions,
    this.viewableMimes,
  });

  factory EditorCapabilities.fromJson(Map<String, dynamic> json) => _$EditorCapabilitiesFromJson(json);

  static const toJsonFactory = _$EditorCapabilitiesToJson;
  Map<String, dynamic> toJson() => _$EditorCapabilitiesToJson(this);

  @JsonKey(name: 'creatable', includeIfNull: false, defaultValue: <CreatableApp>[])
  final List<CreatableApp>? creatable;
  @JsonKey(name: 'editableExtensions', includeIfNull: false, defaultValue: <String>[])
  final List<String>? editableExtensions;
  @JsonKey(name: 'editableMimes', includeIfNull: false, defaultValue: <String>[])
  final List<String>? editableMimes;
  @JsonKey(name: 'enabled', includeIfNull: false)
  final bool enabled;
  @JsonKey(name: 'viewableExtensions', includeIfNull: false, defaultValue: <String>[])
  final List<String>? viewableExtensions;
  @JsonKey(name: 'viewableMimes', includeIfNull: false, defaultValue: <String>[])
  final List<String>? viewableMimes;
  static const fromJsonFactory = _$EditorCapabilitiesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EditorCapabilities &&
            (identical(other.creatable, creatable) ||
                const DeepCollectionEquality().equals(other.creatable, creatable)) &&
            (identical(other.editableExtensions, editableExtensions) ||
                const DeepCollectionEquality().equals(other.editableExtensions, editableExtensions)) &&
            (identical(other.editableMimes, editableMimes) ||
                const DeepCollectionEquality().equals(other.editableMimes, editableMimes)) &&
            (identical(other.enabled, enabled) || const DeepCollectionEquality().equals(other.enabled, enabled)) &&
            (identical(other.viewableExtensions, viewableExtensions) ||
                const DeepCollectionEquality().equals(other.viewableExtensions, viewableExtensions)) &&
            (identical(other.viewableMimes, viewableMimes) ||
                const DeepCollectionEquality().equals(other.viewableMimes, viewableMimes)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(creatable) ^
      const DeepCollectionEquality().hash(editableExtensions) ^
      const DeepCollectionEquality().hash(editableMimes) ^
      const DeepCollectionEquality().hash(enabled) ^
      const DeepCollectionEquality().hash(viewableExtensions) ^
      const DeepCollectionEquality().hash(viewableMimes) ^
      runtimeType.hashCode;
}

extension $EditorCapabilitiesExtension on EditorCapabilities {
  EditorCapabilities copyWith({
    List<CreatableApp>? creatable,
    List<String>? editableExtensions,
    List<String>? editableMimes,
    bool? enabled,
    List<String>? viewableExtensions,
    List<String>? viewableMimes,
  }) {
    return EditorCapabilities(
      creatable: creatable ?? this.creatable,
      editableExtensions: editableExtensions ?? this.editableExtensions,
      editableMimes: editableMimes ?? this.editableMimes,
      enabled: enabled ?? this.enabled,
      viewableExtensions: viewableExtensions ?? this.viewableExtensions,
      viewableMimes: viewableMimes ?? this.viewableMimes,
    );
  }

  EditorCapabilities copyWithWrapped({
    Wrapped<List<CreatableApp>?>? creatable,
    Wrapped<List<String>?>? editableExtensions,
    Wrapped<List<String>?>? editableMimes,
    Wrapped<bool>? enabled,
    Wrapped<List<String>?>? viewableExtensions,
    Wrapped<List<String>?>? viewableMimes,
  }) {
    return EditorCapabilities(
      creatable: (creatable != null ? creatable.value : this.creatable),
      editableExtensions: (editableExtensions != null ? editableExtensions.value : this.editableExtensions),
      editableMimes: (editableMimes != null ? editableMimes.value : this.editableMimes),
      enabled: (enabled != null ? enabled.value : this.enabled),
      viewableExtensions: (viewableExtensions != null ? viewableExtensions.value : this.viewableExtensions),
      viewableMimes: (viewableMimes != null ? viewableMimes.value : this.viewableMimes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EditorSession {
  const EditorSession({
    required this.accessToken,
    required this.accessTokenTtl,
    required this.editorUrl,
    required this.hostPage,
    required this.readOnly,
  });

  factory EditorSession.fromJson(Map<String, dynamic> json) => _$EditorSessionFromJson(json);

  static const toJsonFactory = _$EditorSessionToJson;
  Map<String, dynamic> toJson() => _$EditorSessionToJson(this);

  @JsonKey(name: 'accessToken', includeIfNull: false)
  final String accessToken;
  @JsonKey(name: 'accessTokenTtl', includeIfNull: false)
  final int accessTokenTtl;
  @JsonKey(name: 'editorUrl', includeIfNull: false)
  final String editorUrl;
  @JsonKey(name: 'hostPage', includeIfNull: false)
  final String hostPage;
  @JsonKey(name: 'readOnly', includeIfNull: false)
  final bool readOnly;
  static const fromJsonFactory = _$EditorSessionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EditorSession &&
            (identical(other.accessToken, accessToken) ||
                const DeepCollectionEquality().equals(other.accessToken, accessToken)) &&
            (identical(other.accessTokenTtl, accessTokenTtl) ||
                const DeepCollectionEquality().equals(other.accessTokenTtl, accessTokenTtl)) &&
            (identical(other.editorUrl, editorUrl) ||
                const DeepCollectionEquality().equals(other.editorUrl, editorUrl)) &&
            (identical(other.hostPage, hostPage) || const DeepCollectionEquality().equals(other.hostPage, hostPage)) &&
            (identical(other.readOnly, readOnly) || const DeepCollectionEquality().equals(other.readOnly, readOnly)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accessToken) ^
      const DeepCollectionEquality().hash(accessTokenTtl) ^
      const DeepCollectionEquality().hash(editorUrl) ^
      const DeepCollectionEquality().hash(hostPage) ^
      const DeepCollectionEquality().hash(readOnly) ^
      runtimeType.hashCode;
}

extension $EditorSessionExtension on EditorSession {
  EditorSession copyWith({
    String? accessToken,
    int? accessTokenTtl,
    String? editorUrl,
    String? hostPage,
    bool? readOnly,
  }) {
    return EditorSession(
      accessToken: accessToken ?? this.accessToken,
      accessTokenTtl: accessTokenTtl ?? this.accessTokenTtl,
      editorUrl: editorUrl ?? this.editorUrl,
      hostPage: hostPage ?? this.hostPage,
      readOnly: readOnly ?? this.readOnly,
    );
  }

  EditorSession copyWithWrapped({
    Wrapped<String>? accessToken,
    Wrapped<int>? accessTokenTtl,
    Wrapped<String>? editorUrl,
    Wrapped<String>? hostPage,
    Wrapped<bool>? readOnly,
  }) {
    return EditorSession(
      accessToken: (accessToken != null ? accessToken.value : this.accessToken),
      accessTokenTtl: (accessTokenTtl != null ? accessTokenTtl.value : this.accessTokenTtl),
      editorUrl: (editorUrl != null ? editorUrl.value : this.editorUrl),
      hostPage: (hostPage != null ? hostPage.value : this.hostPage),
      readOnly: (readOnly != null ? readOnly.value : this.readOnly),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Entry {
  const Entry({
    required this.hash,
    required this.id,
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
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
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
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
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
      const DeepCollectionEquality().hash(id) ^
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
    int? id,
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
      id: id ?? this.id,
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
    Wrapped<int>? id,
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
      id: (id != null ? id.value : this.id),
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
class ImageInfo {
  const ImageInfo({required this.contentType, required this.id});

  factory ImageInfo.fromJson(Map<String, dynamic> json) => _$ImageInfoFromJson(json);

  static const toJsonFactory = _$ImageInfoToJson;
  Map<String, dynamic> toJson() => _$ImageInfoToJson(this);

  @JsonKey(name: 'contentType', includeIfNull: false)
  final String contentType;
  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  static const fromJsonFactory = _$ImageInfoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ImageInfo &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(other.contentType, contentType)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(contentType) ^ const DeepCollectionEquality().hash(id) ^ runtimeType.hashCode;
}

extension $ImageInfoExtension on ImageInfo {
  ImageInfo copyWith({String? contentType, String? id}) {
    return ImageInfo(contentType: contentType ?? this.contentType, id: id ?? this.id);
  }

  ImageInfo copyWithWrapped({Wrapped<String>? contentType, Wrapped<String>? id}) {
    return ImageInfo(
      contentType: (contentType != null ? contentType.value : this.contentType),
      id: (id != null ? id.value : this.id),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Incoming {
  const Incoming({required this.kind, required this.source, required this.title});

  factory Incoming.fromJson(Map<String, dynamic> json) => _$IncomingFromJson(json);

  static const toJsonFactory = _$IncomingToJson;
  Map<String, dynamic> toJson() => _$IncomingToJson(this);

  @JsonKey(name: 'kind', includeIfNull: false)
  final String kind;
  @JsonKey(name: 'source', includeIfNull: false)
  final Entry source;
  @JsonKey(name: 'title', includeIfNull: false)
  final String title;
  static const fromJsonFactory = _$IncomingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Incoming &&
            (identical(other.kind, kind) || const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.source, source) || const DeepCollectionEquality().equals(other.source, source)) &&
            (identical(other.title, title) || const DeepCollectionEquality().equals(other.title, title)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(source) ^
      const DeepCollectionEquality().hash(title) ^
      runtimeType.hashCode;
}

extension $IncomingExtension on Incoming {
  Incoming copyWith({String? kind, Entry? source, String? title}) {
    return Incoming(kind: kind ?? this.kind, source: source ?? this.source, title: title ?? this.title);
  }

  Incoming copyWithWrapped({Wrapped<String>? kind, Wrapped<Entry>? source, Wrapped<String>? title}) {
    return Incoming(
      kind: (kind != null ? kind.value : this.kind),
      source: (source != null ? source.value : this.source),
      title: (title != null ? title.value : this.title),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LinksResponse {
  const LinksResponse({this.incoming, this.outgoing});

  factory LinksResponse.fromJson(Map<String, dynamic> json) => _$LinksResponseFromJson(json);

  static const toJsonFactory = _$LinksResponseToJson;
  Map<String, dynamic> toJson() => _$LinksResponseToJson(this);

  @JsonKey(name: 'incoming', includeIfNull: false, defaultValue: <Incoming>[])
  final List<Incoming>? incoming;
  @JsonKey(name: 'outgoing', includeIfNull: false, defaultValue: <Outgoing>[])
  final List<Outgoing>? outgoing;
  static const fromJsonFactory = _$LinksResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LinksResponse &&
            (identical(other.incoming, incoming) || const DeepCollectionEquality().equals(other.incoming, incoming)) &&
            (identical(other.outgoing, outgoing) || const DeepCollectionEquality().equals(other.outgoing, outgoing)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(incoming) ^
      const DeepCollectionEquality().hash(outgoing) ^
      runtimeType.hashCode;
}

extension $LinksResponseExtension on LinksResponse {
  LinksResponse copyWith({List<Incoming>? incoming, List<Outgoing>? outgoing}) {
    return LinksResponse(incoming: incoming ?? this.incoming, outgoing: outgoing ?? this.outgoing);
  }

  LinksResponse copyWithWrapped({Wrapped<List<Incoming>?>? incoming, Wrapped<List<Outgoing>?>? outgoing}) {
    return LinksResponse(
      incoming: (incoming != null ? incoming.value : this.incoming),
      outgoing: (outgoing != null ? outgoing.value : this.outgoing),
    );
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
class LogComponents {
  const LogComponents({this.components});

  factory LogComponents.fromJson(Map<String, dynamic> json) => _$LogComponentsFromJson(json);

  static const toJsonFactory = _$LogComponentsToJson;
  Map<String, dynamic> toJson() => _$LogComponentsToJson(this);

  @JsonKey(name: 'components', includeIfNull: false, defaultValue: <String>[])
  final List<String>? components;
  static const fromJsonFactory = _$LogComponentsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogComponents &&
            (identical(other.components, components) ||
                const DeepCollectionEquality().equals(other.components, components)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(components) ^ runtimeType.hashCode;
}

extension $LogComponentsExtension on LogComponents {
  LogComponents copyWith({List<String>? components}) {
    return LogComponents(components: components ?? this.components);
  }

  LogComponents copyWithWrapped({Wrapped<List<String>?>? components}) {
    return LogComponents(components: (components != null ? components.value : this.components));
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
class LogFiles {
  const LogFiles({this.files});

  factory LogFiles.fromJson(Map<String, dynamic> json) => _$LogFilesFromJson(json);

  static const toJsonFactory = _$LogFilesToJson;
  Map<String, dynamic> toJson() => _$LogFilesToJson(this);

  @JsonKey(name: 'files', includeIfNull: false, defaultValue: <ServerLogFile>[])
  final List<ServerLogFile>? files;
  static const fromJsonFactory = _$LogFilesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LogFiles &&
            (identical(other.files, files) || const DeepCollectionEquality().equals(other.files, files)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(files) ^ runtimeType.hashCode;
}

extension $LogFilesExtension on LogFiles {
  LogFiles copyWith({List<ServerLogFile>? files}) {
    return LogFiles(files: files ?? this.files);
  }

  LogFiles copyWithWrapped({Wrapped<List<ServerLogFile>?>? files}) {
    return LogFiles(files: (files != null ? files.value : this.files));
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
class NotesItem {
  const NotesItem({required this.entry, this.hasNotes, this.hasReadme});

  factory NotesItem.fromJson(Map<String, dynamic> json) => _$NotesItemFromJson(json);

  static const toJsonFactory = _$NotesItemToJson;
  Map<String, dynamic> toJson() => _$NotesItemToJson(this);

  @JsonKey(name: 'entry', includeIfNull: false)
  final Entry entry;
  @JsonKey(name: 'hasNotes', includeIfNull: false)
  final bool? hasNotes;
  @JsonKey(name: 'hasReadme', includeIfNull: false)
  final bool? hasReadme;
  static const fromJsonFactory = _$NotesItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotesItem &&
            (identical(other.entry, entry) || const DeepCollectionEquality().equals(other.entry, entry)) &&
            (identical(other.hasNotes, hasNotes) || const DeepCollectionEquality().equals(other.hasNotes, hasNotes)) &&
            (identical(other.hasReadme, hasReadme) ||
                const DeepCollectionEquality().equals(other.hasReadme, hasReadme)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(entry) ^
      const DeepCollectionEquality().hash(hasNotes) ^
      const DeepCollectionEquality().hash(hasReadme) ^
      runtimeType.hashCode;
}

extension $NotesItemExtension on NotesItem {
  NotesItem copyWith({Entry? entry, bool? hasNotes, bool? hasReadme}) {
    return NotesItem(
      entry: entry ?? this.entry,
      hasNotes: hasNotes ?? this.hasNotes,
      hasReadme: hasReadme ?? this.hasReadme,
    );
  }

  NotesItem copyWithWrapped({Wrapped<Entry>? entry, Wrapped<bool?>? hasNotes, Wrapped<bool?>? hasReadme}) {
    return NotesItem(
      entry: (entry != null ? entry.value : this.entry),
      hasNotes: (hasNotes != null ? hasNotes.value : this.hasNotes),
      hasReadme: (hasReadme != null ? hasReadme.value : this.hasReadme),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotesListing {
  const NotesListing({this.items, required this.path});

  factory NotesListing.fromJson(Map<String, dynamic> json) => _$NotesListingFromJson(json);

  static const toJsonFactory = _$NotesListingToJson;
  Map<String, dynamic> toJson() => _$NotesListingToJson(this);

  @JsonKey(name: 'items', includeIfNull: false, defaultValue: <NotesItem>[])
  final List<NotesItem>? items;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  static const fromJsonFactory = _$NotesListingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotesListing &&
            (identical(other.items, items) || const DeepCollectionEquality().equals(other.items, items)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(items) ^ const DeepCollectionEquality().hash(path) ^ runtimeType.hashCode;
}

extension $NotesListingExtension on NotesListing {
  NotesListing copyWith({List<NotesItem>? items, String? path}) {
    return NotesListing(items: items ?? this.items, path: path ?? this.path);
  }

  NotesListing copyWithWrapped({Wrapped<List<NotesItem>?>? items, Wrapped<String>? path}) {
    return NotesListing(
      items: (items != null ? items.value : this.items),
      path: (path != null ? path.value : this.path),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class NotesSettings {
  const NotesSettings({this.path});

  factory NotesSettings.fromJson(Map<String, dynamic> json) => _$NotesSettingsFromJson(json);

  static const toJsonFactory = _$NotesSettingsToJson;
  Map<String, dynamic> toJson() => _$NotesSettingsToJson(this);

  @JsonKey(name: 'path', includeIfNull: false)
  final String? path;
  static const fromJsonFactory = _$NotesSettingsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NotesSettings &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(path) ^ runtimeType.hashCode;
}

extension $NotesSettingsExtension on NotesSettings {
  NotesSettings copyWith({String? path}) {
    return NotesSettings(path: path ?? this.path);
  }

  NotesSettings copyWithWrapped({Wrapped<String?>? path}) {
    return NotesSettings(path: (path != null ? path.value : this.path));
  }
}

@JsonSerializable(explicitToJson: true)
class OfficeSessionRequest {
  const OfficeSessionRequest({required this.origin, required this.path, this.versionId});

  factory OfficeSessionRequest.fromJson(Map<String, dynamic> json) => _$OfficeSessionRequestFromJson(json);

  static const toJsonFactory = _$OfficeSessionRequestToJson;
  Map<String, dynamic> toJson() => _$OfficeSessionRequestToJson(this);

  @JsonKey(name: 'origin', includeIfNull: false)
  final String origin;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'versionId', includeIfNull: false)
  final int? versionId;
  static const fromJsonFactory = _$OfficeSessionRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OfficeSessionRequest &&
            (identical(other.origin, origin) || const DeepCollectionEquality().equals(other.origin, origin)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.versionId, versionId) ||
                const DeepCollectionEquality().equals(other.versionId, versionId)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(origin) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(versionId) ^
      runtimeType.hashCode;
}

extension $OfficeSessionRequestExtension on OfficeSessionRequest {
  OfficeSessionRequest copyWith({String? origin, String? path, int? versionId}) {
    return OfficeSessionRequest(
      origin: origin ?? this.origin,
      path: path ?? this.path,
      versionId: versionId ?? this.versionId,
    );
  }

  OfficeSessionRequest copyWithWrapped({Wrapped<String>? origin, Wrapped<String>? path, Wrapped<int?>? versionId}) {
    return OfficeSessionRequest(
      origin: (origin != null ? origin.value : this.origin),
      path: (path != null ? path.value : this.path),
      versionId: (versionId != null ? versionId.value : this.versionId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Outgoing {
  const Outgoing({required this.kind, this.target, required this.targetPath, required this.title});

  factory Outgoing.fromJson(Map<String, dynamic> json) => _$OutgoingFromJson(json);

  static const toJsonFactory = _$OutgoingToJson;
  Map<String, dynamic> toJson() => _$OutgoingToJson(this);

  @JsonKey(name: 'kind', includeIfNull: false)
  final String kind;
  @JsonKey(name: 'target', includeIfNull: false)
  final Entry? target;
  @JsonKey(name: 'targetPath', includeIfNull: false)
  final String targetPath;
  @JsonKey(name: 'title', includeIfNull: false)
  final String title;
  static const fromJsonFactory = _$OutgoingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Outgoing &&
            (identical(other.kind, kind) || const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.target, target) || const DeepCollectionEquality().equals(other.target, target)) &&
            (identical(other.targetPath, targetPath) ||
                const DeepCollectionEquality().equals(other.targetPath, targetPath)) &&
            (identical(other.title, title) || const DeepCollectionEquality().equals(other.title, title)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(target) ^
      const DeepCollectionEquality().hash(targetPath) ^
      const DeepCollectionEquality().hash(title) ^
      runtimeType.hashCode;
}

extension $OutgoingExtension on Outgoing {
  Outgoing copyWith({String? kind, Entry? target, String? targetPath, String? title}) {
    return Outgoing(
      kind: kind ?? this.kind,
      target: target ?? this.target,
      targetPath: targetPath ?? this.targetPath,
      title: title ?? this.title,
    );
  }

  Outgoing copyWithWrapped({
    Wrapped<String>? kind,
    Wrapped<Entry?>? target,
    Wrapped<String>? targetPath,
    Wrapped<String>? title,
  }) {
    return Outgoing(
      kind: (kind != null ? kind.value : this.kind),
      target: (target != null ? target.value : this.target),
      targetPath: (targetPath != null ? targetPath.value : this.targetPath),
      title: (title != null ? title.value : this.title),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PasswordChange {
  const PasswordChange({required this.currentPassword, required this.newPassword});

  factory PasswordChange.fromJson(Map<String, dynamic> json) => _$PasswordChangeFromJson(json);

  static const toJsonFactory = _$PasswordChangeToJson;
  Map<String, dynamic> toJson() => _$PasswordChangeToJson(this);

  @JsonKey(name: 'currentPassword', includeIfNull: false)
  final String currentPassword;
  @JsonKey(name: 'newPassword', includeIfNull: false)
  final String newPassword;
  static const fromJsonFactory = _$PasswordChangeFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PasswordChange &&
            (identical(other.currentPassword, currentPassword) ||
                const DeepCollectionEquality().equals(other.currentPassword, currentPassword)) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(other.newPassword, newPassword)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(currentPassword) ^
      const DeepCollectionEquality().hash(newPassword) ^
      runtimeType.hashCode;
}

extension $PasswordChangeExtension on PasswordChange {
  PasswordChange copyWith({String? currentPassword, String? newPassword}) {
    return PasswordChange(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
    );
  }

  PasswordChange copyWithWrapped({Wrapped<String>? currentPassword, Wrapped<String>? newPassword}) {
    return PasswordChange(
      currentPassword: (currentPassword != null ? currentPassword.value : this.currentPassword),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
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
class Profile {
  const Profile({
    required this.address,
    this.age,
    required this.displayName,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  static const toJsonFactory = _$ProfileToJson;
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @JsonKey(name: 'address', includeIfNull: false)
  final String address;
  @JsonKey(name: 'age', includeIfNull: false)
  final int? age;
  @JsonKey(name: 'displayName', includeIfNull: false)
  final String displayName;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'firstName', includeIfNull: false)
  final String firstName;
  @JsonKey(name: 'lastName', includeIfNull: false)
  final String lastName;
  static const fromJsonFactory = _$ProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Profile &&
            (identical(other.address, address) || const DeepCollectionEquality().equals(other.address, address)) &&
            (identical(other.age, age) || const DeepCollectionEquality().equals(other.age, age)) &&
            (identical(other.displayName, displayName) ||
                const DeepCollectionEquality().equals(other.displayName, displayName)) &&
            (identical(other.email, email) || const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.firstName, firstName) ||
                const DeepCollectionEquality().equals(other.firstName, firstName)) &&
            (identical(other.lastName, lastName) || const DeepCollectionEquality().equals(other.lastName, lastName)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(address) ^
      const DeepCollectionEquality().hash(age) ^
      const DeepCollectionEquality().hash(displayName) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(firstName) ^
      const DeepCollectionEquality().hash(lastName) ^
      runtimeType.hashCode;
}

extension $ProfileExtension on Profile {
  Profile copyWith({
    String? address,
    int? age,
    String? displayName,
    String? email,
    String? firstName,
    String? lastName,
  }) {
    return Profile(
      address: address ?? this.address,
      age: age ?? this.age,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  Profile copyWithWrapped({
    Wrapped<String>? address,
    Wrapped<int?>? age,
    Wrapped<String>? displayName,
    Wrapped<String>? email,
    Wrapped<String>? firstName,
    Wrapped<String>? lastName,
  }) {
    return Profile(
      address: (address != null ? address.value : this.address),
      age: (age != null ? age.value : this.age),
      displayName: (displayName != null ? displayName.value : this.displayName),
      email: (email != null ? email.value : this.email),
      firstName: (firstName != null ? firstName.value : this.firstName),
      lastName: (lastName != null ? lastName.value : this.lastName),
    );
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
class ResolveRequest {
  const ResolveRequest({this.ids});

  factory ResolveRequest.fromJson(Map<String, dynamic> json) => _$ResolveRequestFromJson(json);

  static const toJsonFactory = _$ResolveRequestToJson;
  Map<String, dynamic> toJson() => _$ResolveRequestToJson(this);

  @JsonKey(name: 'ids', includeIfNull: false, defaultValue: <int>[])
  final List<int>? ids;
  static const fromJsonFactory = _$ResolveRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResolveRequest &&
            (identical(other.ids, ids) || const DeepCollectionEquality().equals(other.ids, ids)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(ids) ^ runtimeType.hashCode;
}

extension $ResolveRequestExtension on ResolveRequest {
  ResolveRequest copyWith({List<int>? ids}) {
    return ResolveRequest(ids: ids ?? this.ids);
  }

  ResolveRequest copyWithWrapped({Wrapped<List<int>?>? ids}) {
    return ResolveRequest(ids: (ids != null ? ids.value : this.ids));
  }
}

@JsonSerializable(explicitToJson: true)
class ResolveResponse {
  const ResolveResponse({this.entries});

  factory ResolveResponse.fromJson(Map<String, dynamic> json) => _$ResolveResponseFromJson(json);

  static const toJsonFactory = _$ResolveResponseToJson;
  Map<String, dynamic> toJson() => _$ResolveResponseToJson(this);

  @JsonKey(name: 'entries', includeIfNull: false, defaultValue: <Entry>[])
  final List<Entry>? entries;
  static const fromJsonFactory = _$ResolveResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResolveResponse &&
            (identical(other.entries, entries) || const DeepCollectionEquality().equals(other.entries, entries)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(entries) ^ runtimeType.hashCode;
}

extension $ResolveResponseExtension on ResolveResponse {
  ResolveResponse copyWith({List<Entry>? entries}) {
    return ResolveResponse(entries: entries ?? this.entries);
  }

  ResolveResponse copyWithWrapped({Wrapped<List<Entry>?>? entries}) {
    return ResolveResponse(entries: (entries != null ? entries.value : this.entries));
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
class ServerInfo {
  const ServerInfo({required this.buildNumber, required this.version});

  factory ServerInfo.fromJson(Map<String, dynamic> json) => _$ServerInfoFromJson(json);

  static const toJsonFactory = _$ServerInfoToJson;
  Map<String, dynamic> toJson() => _$ServerInfoToJson(this);

  @JsonKey(name: 'buildNumber', includeIfNull: false)
  final String buildNumber;
  @JsonKey(name: 'version', includeIfNull: false)
  final String version;
  static const fromJsonFactory = _$ServerInfoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerInfo &&
            (identical(other.buildNumber, buildNumber) ||
                const DeepCollectionEquality().equals(other.buildNumber, buildNumber)) &&
            (identical(other.version, version) || const DeepCollectionEquality().equals(other.version, version)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(buildNumber) ^
      const DeepCollectionEquality().hash(version) ^
      runtimeType.hashCode;
}

extension $ServerInfoExtension on ServerInfo {
  ServerInfo copyWith({String? buildNumber, String? version}) {
    return ServerInfo(buildNumber: buildNumber ?? this.buildNumber, version: version ?? this.version);
  }

  ServerInfo copyWithWrapped({Wrapped<String>? buildNumber, Wrapped<String>? version}) {
    return ServerInfo(
      buildNumber: (buildNumber != null ? buildNumber.value : this.buildNumber),
      version: (version != null ? version.value : this.version),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerLogEntry {
  const ServerLogEntry({
    required this.attrs,
    required this.component,
    required this.id,
    required this.level,
    required this.message,
    this.time,
  });

  factory ServerLogEntry.fromJson(Map<String, dynamic> json) => _$ServerLogEntryFromJson(json);

  static const toJsonFactory = _$ServerLogEntryToJson;
  Map<String, dynamic> toJson() => _$ServerLogEntryToJson(this);

  @JsonKey(name: 'attrs', includeIfNull: false)
  final Map<String, dynamic> attrs;
  @JsonKey(name: 'component', includeIfNull: false)
  final String component;
  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'level', includeIfNull: false)
  final String level;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'time', includeIfNull: false)
  final DateTime? time;
  static const fromJsonFactory = _$ServerLogEntryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerLogEntry &&
            (identical(other.attrs, attrs) || const DeepCollectionEquality().equals(other.attrs, attrs)) &&
            (identical(other.component, component) ||
                const DeepCollectionEquality().equals(other.component, component)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.level, level) || const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.message, message) || const DeepCollectionEquality().equals(other.message, message)) &&
            (identical(other.time, time) || const DeepCollectionEquality().equals(other.time, time)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(attrs) ^
      const DeepCollectionEquality().hash(component) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(time) ^
      runtimeType.hashCode;
}

extension $ServerLogEntryExtension on ServerLogEntry {
  ServerLogEntry copyWith({
    Map<String, dynamic>? attrs,
    String? component,
    String? id,
    String? level,
    String? message,
    DateTime? time,
  }) {
    return ServerLogEntry(
      attrs: attrs ?? this.attrs,
      component: component ?? this.component,
      id: id ?? this.id,
      level: level ?? this.level,
      message: message ?? this.message,
      time: time ?? this.time,
    );
  }

  ServerLogEntry copyWithWrapped({
    Wrapped<Map<String, dynamic>>? attrs,
    Wrapped<String>? component,
    Wrapped<String>? id,
    Wrapped<String>? level,
    Wrapped<String>? message,
    Wrapped<DateTime?>? time,
  }) {
    return ServerLogEntry(
      attrs: (attrs != null ? attrs.value : this.attrs),
      component: (component != null ? component.value : this.component),
      id: (id != null ? id.value : this.id),
      level: (level != null ? level.value : this.level),
      message: (message != null ? message.value : this.message),
      time: (time != null ? time.value : this.time),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerLogFile {
  const ServerLogFile({required this.day, required this.name, required this.size});

  factory ServerLogFile.fromJson(Map<String, dynamic> json) => _$ServerLogFileFromJson(json);

  static const toJsonFactory = _$ServerLogFileToJson;
  Map<String, dynamic> toJson() => _$ServerLogFileToJson(this);

  @JsonKey(name: 'day', includeIfNull: false, toJson: _dateToJson)
  final DateTime day;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$ServerLogFileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerLogFile &&
            (identical(other.day, day) || const DeepCollectionEquality().equals(other.day, day)) &&
            (identical(other.name, name) || const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(day) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $ServerLogFileExtension on ServerLogFile {
  ServerLogFile copyWith({DateTime? day, String? name, int? size}) {
    return ServerLogFile(day: day ?? this.day, name: name ?? this.name, size: size ?? this.size);
  }

  ServerLogFile copyWithWrapped({Wrapped<DateTime>? day, Wrapped<String>? name, Wrapped<int>? size}) {
    return ServerLogFile(
      day: (day != null ? day.value : this.day),
      name: (name != null ? name.value : this.name),
      size: (size != null ? size.value : this.size),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerLogPage {
  const ServerLogPage({this.entries, required this.nextCursor});

  factory ServerLogPage.fromJson(Map<String, dynamic> json) => _$ServerLogPageFromJson(json);

  static const toJsonFactory = _$ServerLogPageToJson;
  Map<String, dynamic> toJson() => _$ServerLogPageToJson(this);

  @JsonKey(name: 'entries', includeIfNull: false, defaultValue: <ServerLogEntry>[])
  final List<ServerLogEntry>? entries;
  @JsonKey(name: 'nextCursor', includeIfNull: false)
  final String nextCursor;
  static const fromJsonFactory = _$ServerLogPageFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerLogPage &&
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

extension $ServerLogPageExtension on ServerLogPage {
  ServerLogPage copyWith({List<ServerLogEntry>? entries, String? nextCursor}) {
    return ServerLogPage(entries: entries ?? this.entries, nextCursor: nextCursor ?? this.nextCursor);
  }

  ServerLogPage copyWithWrapped({Wrapped<List<ServerLogEntry>?>? entries, Wrapped<String>? nextCursor}) {
    return ServerLogPage(
      entries: (entries != null ? entries.value : this.entries),
      nextCursor: (nextCursor != null ? nextCursor.value : this.nextCursor),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerSettings {
  const ServerSettings({
    required this.accentColor,
    required this.instanceName,
    required this.ocrEnabled,
    this.ocrLanguages,
    required this.ocrMaxPages,
    required this.searchContentEnabled,
    required this.trashEnabled,
    required this.trashRetentionDays,
    required this.versionsEnabled,
    required this.versionsKeepAllHours,
    required this.versionsMaxAgeDays,
    required this.versionsMaxPerFile,
    required this.welcomeMessage,
  });

  factory ServerSettings.fromJson(Map<String, dynamic> json) => _$ServerSettingsFromJson(json);

  static const toJsonFactory = _$ServerSettingsToJson;
  Map<String, dynamic> toJson() => _$ServerSettingsToJson(this);

  @JsonKey(name: 'accentColor', includeIfNull: false)
  final String accentColor;
  @JsonKey(name: 'instanceName', includeIfNull: false)
  final String instanceName;
  @JsonKey(name: 'ocrEnabled', includeIfNull: false)
  final bool ocrEnabled;
  @JsonKey(name: 'ocrLanguages', includeIfNull: false, defaultValue: <String>[])
  final List<String>? ocrLanguages;
  @JsonKey(name: 'ocrMaxPages', includeIfNull: false)
  final int ocrMaxPages;
  @JsonKey(name: 'searchContentEnabled', includeIfNull: false)
  final bool searchContentEnabled;
  @JsonKey(name: 'trashEnabled', includeIfNull: false)
  final bool trashEnabled;
  @JsonKey(name: 'trashRetentionDays', includeIfNull: false)
  final int trashRetentionDays;
  @JsonKey(name: 'versionsEnabled', includeIfNull: false)
  final bool versionsEnabled;
  @JsonKey(name: 'versionsKeepAllHours', includeIfNull: false)
  final int versionsKeepAllHours;
  @JsonKey(name: 'versionsMaxAgeDays', includeIfNull: false)
  final int versionsMaxAgeDays;
  @JsonKey(name: 'versionsMaxPerFile', includeIfNull: false)
  final int versionsMaxPerFile;
  @JsonKey(name: 'welcomeMessage', includeIfNull: false)
  final String welcomeMessage;
  static const fromJsonFactory = _$ServerSettingsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerSettings &&
            (identical(other.accentColor, accentColor) ||
                const DeepCollectionEquality().equals(other.accentColor, accentColor)) &&
            (identical(other.instanceName, instanceName) ||
                const DeepCollectionEquality().equals(other.instanceName, instanceName)) &&
            (identical(other.ocrEnabled, ocrEnabled) ||
                const DeepCollectionEquality().equals(other.ocrEnabled, ocrEnabled)) &&
            (identical(other.ocrLanguages, ocrLanguages) ||
                const DeepCollectionEquality().equals(other.ocrLanguages, ocrLanguages)) &&
            (identical(other.ocrMaxPages, ocrMaxPages) ||
                const DeepCollectionEquality().equals(other.ocrMaxPages, ocrMaxPages)) &&
            (identical(other.searchContentEnabled, searchContentEnabled) ||
                const DeepCollectionEquality().equals(other.searchContentEnabled, searchContentEnabled)) &&
            (identical(other.trashEnabled, trashEnabled) ||
                const DeepCollectionEquality().equals(other.trashEnabled, trashEnabled)) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionDays, trashRetentionDays)) &&
            (identical(other.versionsEnabled, versionsEnabled) ||
                const DeepCollectionEquality().equals(other.versionsEnabled, versionsEnabled)) &&
            (identical(other.versionsKeepAllHours, versionsKeepAllHours) ||
                const DeepCollectionEquality().equals(other.versionsKeepAllHours, versionsKeepAllHours)) &&
            (identical(other.versionsMaxAgeDays, versionsMaxAgeDays) ||
                const DeepCollectionEquality().equals(other.versionsMaxAgeDays, versionsMaxAgeDays)) &&
            (identical(other.versionsMaxPerFile, versionsMaxPerFile) ||
                const DeepCollectionEquality().equals(other.versionsMaxPerFile, versionsMaxPerFile)) &&
            (identical(other.welcomeMessage, welcomeMessage) ||
                const DeepCollectionEquality().equals(other.welcomeMessage, welcomeMessage)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accentColor) ^
      const DeepCollectionEquality().hash(instanceName) ^
      const DeepCollectionEquality().hash(ocrEnabled) ^
      const DeepCollectionEquality().hash(ocrLanguages) ^
      const DeepCollectionEquality().hash(ocrMaxPages) ^
      const DeepCollectionEquality().hash(searchContentEnabled) ^
      const DeepCollectionEquality().hash(trashEnabled) ^
      const DeepCollectionEquality().hash(trashRetentionDays) ^
      const DeepCollectionEquality().hash(versionsEnabled) ^
      const DeepCollectionEquality().hash(versionsKeepAllHours) ^
      const DeepCollectionEquality().hash(versionsMaxAgeDays) ^
      const DeepCollectionEquality().hash(versionsMaxPerFile) ^
      const DeepCollectionEquality().hash(welcomeMessage) ^
      runtimeType.hashCode;
}

extension $ServerSettingsExtension on ServerSettings {
  ServerSettings copyWith({
    String? accentColor,
    String? instanceName,
    bool? ocrEnabled,
    List<String>? ocrLanguages,
    int? ocrMaxPages,
    bool? searchContentEnabled,
    bool? trashEnabled,
    int? trashRetentionDays,
    bool? versionsEnabled,
    int? versionsKeepAllHours,
    int? versionsMaxAgeDays,
    int? versionsMaxPerFile,
    String? welcomeMessage,
  }) {
    return ServerSettings(
      accentColor: accentColor ?? this.accentColor,
      instanceName: instanceName ?? this.instanceName,
      ocrEnabled: ocrEnabled ?? this.ocrEnabled,
      ocrLanguages: ocrLanguages ?? this.ocrLanguages,
      ocrMaxPages: ocrMaxPages ?? this.ocrMaxPages,
      searchContentEnabled: searchContentEnabled ?? this.searchContentEnabled,
      trashEnabled: trashEnabled ?? this.trashEnabled,
      trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
      versionsEnabled: versionsEnabled ?? this.versionsEnabled,
      versionsKeepAllHours: versionsKeepAllHours ?? this.versionsKeepAllHours,
      versionsMaxAgeDays: versionsMaxAgeDays ?? this.versionsMaxAgeDays,
      versionsMaxPerFile: versionsMaxPerFile ?? this.versionsMaxPerFile,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    );
  }

  ServerSettings copyWithWrapped({
    Wrapped<String>? accentColor,
    Wrapped<String>? instanceName,
    Wrapped<bool>? ocrEnabled,
    Wrapped<List<String>?>? ocrLanguages,
    Wrapped<int>? ocrMaxPages,
    Wrapped<bool>? searchContentEnabled,
    Wrapped<bool>? trashEnabled,
    Wrapped<int>? trashRetentionDays,
    Wrapped<bool>? versionsEnabled,
    Wrapped<int>? versionsKeepAllHours,
    Wrapped<int>? versionsMaxAgeDays,
    Wrapped<int>? versionsMaxPerFile,
    Wrapped<String>? welcomeMessage,
  }) {
    return ServerSettings(
      accentColor: (accentColor != null ? accentColor.value : this.accentColor),
      instanceName: (instanceName != null ? instanceName.value : this.instanceName),
      ocrEnabled: (ocrEnabled != null ? ocrEnabled.value : this.ocrEnabled),
      ocrLanguages: (ocrLanguages != null ? ocrLanguages.value : this.ocrLanguages),
      ocrMaxPages: (ocrMaxPages != null ? ocrMaxPages.value : this.ocrMaxPages),
      searchContentEnabled: (searchContentEnabled != null ? searchContentEnabled.value : this.searchContentEnabled),
      trashEnabled: (trashEnabled != null ? trashEnabled.value : this.trashEnabled),
      trashRetentionDays: (trashRetentionDays != null ? trashRetentionDays.value : this.trashRetentionDays),
      versionsEnabled: (versionsEnabled != null ? versionsEnabled.value : this.versionsEnabled),
      versionsKeepAllHours: (versionsKeepAllHours != null ? versionsKeepAllHours.value : this.versionsKeepAllHours),
      versionsMaxAgeDays: (versionsMaxAgeDays != null ? versionsMaxAgeDays.value : this.versionsMaxAgeDays),
      versionsMaxPerFile: (versionsMaxPerFile != null ? versionsMaxPerFile.value : this.versionsMaxPerFile),
      welcomeMessage: (welcomeMessage != null ? welcomeMessage.value : this.welcomeMessage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ServerSettingsChanges {
  const ServerSettingsChanges({
    this.accentColor,
    this.instanceName,
    this.ocrEnabled,
    this.ocrLanguages,
    this.ocrMaxPages,
    this.searchContentEnabled,
    this.trashEnabled,
    this.trashRetentionDays,
    this.versionsEnabled,
    this.versionsKeepAllHours,
    this.versionsMaxAgeDays,
    this.versionsMaxPerFile,
    this.welcomeMessage,
  });

  factory ServerSettingsChanges.fromJson(Map<String, dynamic> json) => _$ServerSettingsChangesFromJson(json);

  static const toJsonFactory = _$ServerSettingsChangesToJson;
  Map<String, dynamic> toJson() => _$ServerSettingsChangesToJson(this);

  @JsonKey(name: 'accentColor', includeIfNull: false)
  final String? accentColor;
  @JsonKey(name: 'instanceName', includeIfNull: false)
  final String? instanceName;
  @JsonKey(name: 'ocrEnabled', includeIfNull: false)
  final bool? ocrEnabled;
  @JsonKey(name: 'ocrLanguages', includeIfNull: false, defaultValue: <String>[])
  final List<String>? ocrLanguages;
  @JsonKey(name: 'ocrMaxPages', includeIfNull: false)
  final int? ocrMaxPages;
  @JsonKey(name: 'searchContentEnabled', includeIfNull: false)
  final bool? searchContentEnabled;
  @JsonKey(name: 'trashEnabled', includeIfNull: false)
  final bool? trashEnabled;
  @JsonKey(name: 'trashRetentionDays', includeIfNull: false)
  final int? trashRetentionDays;
  @JsonKey(name: 'versionsEnabled', includeIfNull: false)
  final bool? versionsEnabled;
  @JsonKey(name: 'versionsKeepAllHours', includeIfNull: false)
  final int? versionsKeepAllHours;
  @JsonKey(name: 'versionsMaxAgeDays', includeIfNull: false)
  final int? versionsMaxAgeDays;
  @JsonKey(name: 'versionsMaxPerFile', includeIfNull: false)
  final int? versionsMaxPerFile;
  @JsonKey(name: 'welcomeMessage', includeIfNull: false)
  final String? welcomeMessage;
  static const fromJsonFactory = _$ServerSettingsChangesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ServerSettingsChanges &&
            (identical(other.accentColor, accentColor) ||
                const DeepCollectionEquality().equals(other.accentColor, accentColor)) &&
            (identical(other.instanceName, instanceName) ||
                const DeepCollectionEquality().equals(other.instanceName, instanceName)) &&
            (identical(other.ocrEnabled, ocrEnabled) ||
                const DeepCollectionEquality().equals(other.ocrEnabled, ocrEnabled)) &&
            (identical(other.ocrLanguages, ocrLanguages) ||
                const DeepCollectionEquality().equals(other.ocrLanguages, ocrLanguages)) &&
            (identical(other.ocrMaxPages, ocrMaxPages) ||
                const DeepCollectionEquality().equals(other.ocrMaxPages, ocrMaxPages)) &&
            (identical(other.searchContentEnabled, searchContentEnabled) ||
                const DeepCollectionEquality().equals(other.searchContentEnabled, searchContentEnabled)) &&
            (identical(other.trashEnabled, trashEnabled) ||
                const DeepCollectionEquality().equals(other.trashEnabled, trashEnabled)) &&
            (identical(other.trashRetentionDays, trashRetentionDays) ||
                const DeepCollectionEquality().equals(other.trashRetentionDays, trashRetentionDays)) &&
            (identical(other.versionsEnabled, versionsEnabled) ||
                const DeepCollectionEquality().equals(other.versionsEnabled, versionsEnabled)) &&
            (identical(other.versionsKeepAllHours, versionsKeepAllHours) ||
                const DeepCollectionEquality().equals(other.versionsKeepAllHours, versionsKeepAllHours)) &&
            (identical(other.versionsMaxAgeDays, versionsMaxAgeDays) ||
                const DeepCollectionEquality().equals(other.versionsMaxAgeDays, versionsMaxAgeDays)) &&
            (identical(other.versionsMaxPerFile, versionsMaxPerFile) ||
                const DeepCollectionEquality().equals(other.versionsMaxPerFile, versionsMaxPerFile)) &&
            (identical(other.welcomeMessage, welcomeMessage) ||
                const DeepCollectionEquality().equals(other.welcomeMessage, welcomeMessage)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(accentColor) ^
      const DeepCollectionEquality().hash(instanceName) ^
      const DeepCollectionEquality().hash(ocrEnabled) ^
      const DeepCollectionEquality().hash(ocrLanguages) ^
      const DeepCollectionEquality().hash(ocrMaxPages) ^
      const DeepCollectionEquality().hash(searchContentEnabled) ^
      const DeepCollectionEquality().hash(trashEnabled) ^
      const DeepCollectionEquality().hash(trashRetentionDays) ^
      const DeepCollectionEquality().hash(versionsEnabled) ^
      const DeepCollectionEquality().hash(versionsKeepAllHours) ^
      const DeepCollectionEquality().hash(versionsMaxAgeDays) ^
      const DeepCollectionEquality().hash(versionsMaxPerFile) ^
      const DeepCollectionEquality().hash(welcomeMessage) ^
      runtimeType.hashCode;
}

extension $ServerSettingsChangesExtension on ServerSettingsChanges {
  ServerSettingsChanges copyWith({
    String? accentColor,
    String? instanceName,
    bool? ocrEnabled,
    List<String>? ocrLanguages,
    int? ocrMaxPages,
    bool? searchContentEnabled,
    bool? trashEnabled,
    int? trashRetentionDays,
    bool? versionsEnabled,
    int? versionsKeepAllHours,
    int? versionsMaxAgeDays,
    int? versionsMaxPerFile,
    String? welcomeMessage,
  }) {
    return ServerSettingsChanges(
      accentColor: accentColor ?? this.accentColor,
      instanceName: instanceName ?? this.instanceName,
      ocrEnabled: ocrEnabled ?? this.ocrEnabled,
      ocrLanguages: ocrLanguages ?? this.ocrLanguages,
      ocrMaxPages: ocrMaxPages ?? this.ocrMaxPages,
      searchContentEnabled: searchContentEnabled ?? this.searchContentEnabled,
      trashEnabled: trashEnabled ?? this.trashEnabled,
      trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
      versionsEnabled: versionsEnabled ?? this.versionsEnabled,
      versionsKeepAllHours: versionsKeepAllHours ?? this.versionsKeepAllHours,
      versionsMaxAgeDays: versionsMaxAgeDays ?? this.versionsMaxAgeDays,
      versionsMaxPerFile: versionsMaxPerFile ?? this.versionsMaxPerFile,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    );
  }

  ServerSettingsChanges copyWithWrapped({
    Wrapped<String?>? accentColor,
    Wrapped<String?>? instanceName,
    Wrapped<bool?>? ocrEnabled,
    Wrapped<List<String>?>? ocrLanguages,
    Wrapped<int?>? ocrMaxPages,
    Wrapped<bool?>? searchContentEnabled,
    Wrapped<bool?>? trashEnabled,
    Wrapped<int?>? trashRetentionDays,
    Wrapped<bool?>? versionsEnabled,
    Wrapped<int?>? versionsKeepAllHours,
    Wrapped<int?>? versionsMaxAgeDays,
    Wrapped<int?>? versionsMaxPerFile,
    Wrapped<String?>? welcomeMessage,
  }) {
    return ServerSettingsChanges(
      accentColor: (accentColor != null ? accentColor.value : this.accentColor),
      instanceName: (instanceName != null ? instanceName.value : this.instanceName),
      ocrEnabled: (ocrEnabled != null ? ocrEnabled.value : this.ocrEnabled),
      ocrLanguages: (ocrLanguages != null ? ocrLanguages.value : this.ocrLanguages),
      ocrMaxPages: (ocrMaxPages != null ? ocrMaxPages.value : this.ocrMaxPages),
      searchContentEnabled: (searchContentEnabled != null ? searchContentEnabled.value : this.searchContentEnabled),
      trashEnabled: (trashEnabled != null ? trashEnabled.value : this.trashEnabled),
      trashRetentionDays: (trashRetentionDays != null ? trashRetentionDays.value : this.trashRetentionDays),
      versionsEnabled: (versionsEnabled != null ? versionsEnabled.value : this.versionsEnabled),
      versionsKeepAllHours: (versionsKeepAllHours != null ? versionsKeepAllHours.value : this.versionsKeepAllHours),
      versionsMaxAgeDays: (versionsMaxAgeDays != null ? versionsMaxAgeDays.value : this.versionsMaxAgeDays),
      versionsMaxPerFile: (versionsMaxPerFile != null ? versionsMaxPerFile.value : this.versionsMaxPerFile),
      welcomeMessage: (welcomeMessage != null ? welcomeMessage.value : this.welcomeMessage),
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
class TrashPreferences {
  const TrashPreferences({this.days, this.enabled});

  factory TrashPreferences.fromJson(Map<String, dynamic> json) => _$TrashPreferencesFromJson(json);

  static const toJsonFactory = _$TrashPreferencesToJson;
  Map<String, dynamic> toJson() => _$TrashPreferencesToJson(this);

  @JsonKey(name: 'days', includeIfNull: false)
  final int? days;
  @JsonKey(name: 'enabled', includeIfNull: false)
  final bool? enabled;
  static const fromJsonFactory = _$TrashPreferencesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrashPreferences &&
            (identical(other.days, days) || const DeepCollectionEquality().equals(other.days, days)) &&
            (identical(other.enabled, enabled) || const DeepCollectionEquality().equals(other.enabled, enabled)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(days) ^ const DeepCollectionEquality().hash(enabled) ^ runtimeType.hashCode;
}

extension $TrashPreferencesExtension on TrashPreferences {
  TrashPreferences copyWith({int? days, bool? enabled}) {
    return TrashPreferences(days: days ?? this.days, enabled: enabled ?? this.enabled);
  }

  TrashPreferences copyWithWrapped({Wrapped<int?>? days, Wrapped<bool?>? enabled}) {
    return TrashPreferences(
      days: (days != null ? days.value : this.days),
      enabled: (enabled != null ? enabled.value : this.enabled),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TrashRetention {
  const TrashRetention({
    required this.days,
    required this.enabled,
    required this.serverDays,
    required this.serverEnabled,
    required this.source,
    required this.user,
  });

  factory TrashRetention.fromJson(Map<String, dynamic> json) => _$TrashRetentionFromJson(json);

  static const toJsonFactory = _$TrashRetentionToJson;
  Map<String, dynamic> toJson() => _$TrashRetentionToJson(this);

  @JsonKey(name: 'days', includeIfNull: false)
  final int days;
  @JsonKey(name: 'enabled', includeIfNull: false)
  final bool enabled;
  @JsonKey(name: 'serverDays', includeIfNull: false)
  final int serverDays;
  @JsonKey(name: 'serverEnabled', includeIfNull: false)
  final bool serverEnabled;
  @JsonKey(
    name: 'source',
    includeIfNull: false,
    toJson: trashRetentionSourceToJson,
    fromJson: trashRetentionSourceFromJson,
  )
  final enums.TrashRetentionSource source;
  @JsonKey(name: 'user', includeIfNull: false)
  final TrashPreferences user;
  static const fromJsonFactory = _$TrashRetentionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TrashRetention &&
            (identical(other.days, days) || const DeepCollectionEquality().equals(other.days, days)) &&
            (identical(other.enabled, enabled) || const DeepCollectionEquality().equals(other.enabled, enabled)) &&
            (identical(other.serverDays, serverDays) ||
                const DeepCollectionEquality().equals(other.serverDays, serverDays)) &&
            (identical(other.serverEnabled, serverEnabled) ||
                const DeepCollectionEquality().equals(other.serverEnabled, serverEnabled)) &&
            (identical(other.source, source) || const DeepCollectionEquality().equals(other.source, source)) &&
            (identical(other.user, user) || const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(days) ^
      const DeepCollectionEquality().hash(enabled) ^
      const DeepCollectionEquality().hash(serverDays) ^
      const DeepCollectionEquality().hash(serverEnabled) ^
      const DeepCollectionEquality().hash(source) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $TrashRetentionExtension on TrashRetention {
  TrashRetention copyWith({
    int? days,
    bool? enabled,
    int? serverDays,
    bool? serverEnabled,
    enums.TrashRetentionSource? source,
    TrashPreferences? user,
  }) {
    return TrashRetention(
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
      serverDays: serverDays ?? this.serverDays,
      serverEnabled: serverEnabled ?? this.serverEnabled,
      source: source ?? this.source,
      user: user ?? this.user,
    );
  }

  TrashRetention copyWithWrapped({
    Wrapped<int>? days,
    Wrapped<bool>? enabled,
    Wrapped<int>? serverDays,
    Wrapped<bool>? serverEnabled,
    Wrapped<enums.TrashRetentionSource>? source,
    Wrapped<TrashPreferences>? user,
  }) {
    return TrashRetention(
      days: (days != null ? days.value : this.days),
      enabled: (enabled != null ? enabled.value : this.enabled),
      serverDays: (serverDays != null ? serverDays.value : this.serverDays),
      serverEnabled: (serverEnabled != null ? serverEnabled.value : this.serverEnabled),
      source: (source != null ? source.value : this.source),
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
    required this.appearance,
    this.avatar,
    required this.createdAt,
    required this.disabled,
    required this.historyBytes,
    required this.id,
    required this.profile,
    required this.quotaBytes,
    required this.role,
    required this.usedBytes,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  static const toJsonFactory = _$UserToJson;
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @JsonKey(name: 'appearance', includeIfNull: false)
  final Appearance appearance;
  @JsonKey(name: 'avatar', includeIfNull: false)
  final Avatar? avatar;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool disabled;
  @JsonKey(name: 'historyBytes', includeIfNull: false)
  final int historyBytes;
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
  @JsonKey(name: 'profile', includeIfNull: false)
  final Profile profile;
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
            (identical(other.appearance, appearance) ||
                const DeepCollectionEquality().equals(other.appearance, appearance)) &&
            (identical(other.avatar, avatar) || const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(other.createdAt, createdAt)) &&
            (identical(other.disabled, disabled) || const DeepCollectionEquality().equals(other.disabled, disabled)) &&
            (identical(other.historyBytes, historyBytes) ||
                const DeepCollectionEquality().equals(other.historyBytes, historyBytes)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.profile, profile) || const DeepCollectionEquality().equals(other.profile, profile)) &&
            (identical(other.quotaBytes, quotaBytes) ||
                const DeepCollectionEquality().equals(other.quotaBytes, quotaBytes)) &&
            (identical(other.role, role) || const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.usedBytes, usedBytes) ||
                const DeepCollectionEquality().equals(other.usedBytes, usedBytes)) &&
            (identical(other.username, username) || const DeepCollectionEquality().equals(other.username, username)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(appearance) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(historyBytes) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(quotaBytes) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(usedBytes) ^
      const DeepCollectionEquality().hash(username) ^
      runtimeType.hashCode;
}

extension $UserExtension on User {
  User copyWith({
    Appearance? appearance,
    Avatar? avatar,
    DateTime? createdAt,
    bool? disabled,
    int? historyBytes,
    int? id,
    Profile? profile,
    int? quotaBytes,
    enums.UserRole? role,
    int? usedBytes,
    String? username,
  }) {
    return User(
      appearance: appearance ?? this.appearance,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      disabled: disabled ?? this.disabled,
      historyBytes: historyBytes ?? this.historyBytes,
      id: id ?? this.id,
      profile: profile ?? this.profile,
      quotaBytes: quotaBytes ?? this.quotaBytes,
      role: role ?? this.role,
      usedBytes: usedBytes ?? this.usedBytes,
      username: username ?? this.username,
    );
  }

  User copyWithWrapped({
    Wrapped<Appearance>? appearance,
    Wrapped<Avatar?>? avatar,
    Wrapped<DateTime>? createdAt,
    Wrapped<bool>? disabled,
    Wrapped<int>? historyBytes,
    Wrapped<int>? id,
    Wrapped<Profile>? profile,
    Wrapped<int>? quotaBytes,
    Wrapped<enums.UserRole>? role,
    Wrapped<int>? usedBytes,
    Wrapped<String>? username,
  }) {
    return User(
      appearance: (appearance != null ? appearance.value : this.appearance),
      avatar: (avatar != null ? avatar.value : this.avatar),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      disabled: (disabled != null ? disabled.value : this.disabled),
      historyBytes: (historyBytes != null ? historyBytes.value : this.historyBytes),
      id: (id != null ? id.value : this.id),
      profile: (profile != null ? profile.value : this.profile),
      quotaBytes: (quotaBytes != null ? quotaBytes.value : this.quotaBytes),
      role: (role != null ? role.value : this.role),
      usedBytes: (usedBytes != null ? usedBytes.value : this.usedBytes),
      username: (username != null ? username.value : this.username),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VersionListing {
  const VersionListing({required this.current, required this.path, required this.retention, this.versions});

  factory VersionListing.fromJson(Map<String, dynamic> json) => _$VersionListingFromJson(json);

  static const toJsonFactory = _$VersionListingToJson;
  Map<String, dynamic> toJson() => _$VersionListingToJson(this);

  @JsonKey(name: 'current', includeIfNull: false)
  final Entry current;
  @JsonKey(name: 'path', includeIfNull: false)
  final String path;
  @JsonKey(name: 'retention', includeIfNull: false)
  final VersionRetention retention;
  @JsonKey(name: 'versions', includeIfNull: false, defaultValue: <VersionView>[])
  final List<VersionView>? versions;
  static const fromJsonFactory = _$VersionListingFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VersionListing &&
            (identical(other.current, current) || const DeepCollectionEquality().equals(other.current, current)) &&
            (identical(other.path, path) || const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.retention, retention) ||
                const DeepCollectionEquality().equals(other.retention, retention)) &&
            (identical(other.versions, versions) || const DeepCollectionEquality().equals(other.versions, versions)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(current) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(retention) ^
      const DeepCollectionEquality().hash(versions) ^
      runtimeType.hashCode;
}

extension $VersionListingExtension on VersionListing {
  VersionListing copyWith({Entry? current, String? path, VersionRetention? retention, List<VersionView>? versions}) {
    return VersionListing(
      current: current ?? this.current,
      path: path ?? this.path,
      retention: retention ?? this.retention,
      versions: versions ?? this.versions,
    );
  }

  VersionListing copyWithWrapped({
    Wrapped<Entry>? current,
    Wrapped<String>? path,
    Wrapped<VersionRetention>? retention,
    Wrapped<List<VersionView>?>? versions,
  }) {
    return VersionListing(
      current: (current != null ? current.value : this.current),
      path: (path != null ? path.value : this.path),
      retention: (retention != null ? retention.value : this.retention),
      versions: (versions != null ? versions.value : this.versions),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VersionPreferences {
  const VersionPreferences({this.enabled, this.keepAllHours, this.maxAgeDays, this.maxPerFile});

  factory VersionPreferences.fromJson(Map<String, dynamic> json) => _$VersionPreferencesFromJson(json);

  static const toJsonFactory = _$VersionPreferencesToJson;
  Map<String, dynamic> toJson() => _$VersionPreferencesToJson(this);

  @JsonKey(name: 'enabled', includeIfNull: false)
  final bool? enabled;
  @JsonKey(name: 'keepAllHours', includeIfNull: false)
  final int? keepAllHours;
  @JsonKey(name: 'maxAgeDays', includeIfNull: false)
  final int? maxAgeDays;
  @JsonKey(name: 'maxPerFile', includeIfNull: false)
  final int? maxPerFile;
  static const fromJsonFactory = _$VersionPreferencesFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VersionPreferences &&
            (identical(other.enabled, enabled) || const DeepCollectionEquality().equals(other.enabled, enabled)) &&
            (identical(other.keepAllHours, keepAllHours) ||
                const DeepCollectionEquality().equals(other.keepAllHours, keepAllHours)) &&
            (identical(other.maxAgeDays, maxAgeDays) ||
                const DeepCollectionEquality().equals(other.maxAgeDays, maxAgeDays)) &&
            (identical(other.maxPerFile, maxPerFile) ||
                const DeepCollectionEquality().equals(other.maxPerFile, maxPerFile)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(enabled) ^
      const DeepCollectionEquality().hash(keepAllHours) ^
      const DeepCollectionEquality().hash(maxAgeDays) ^
      const DeepCollectionEquality().hash(maxPerFile) ^
      runtimeType.hashCode;
}

extension $VersionPreferencesExtension on VersionPreferences {
  VersionPreferences copyWith({bool? enabled, int? keepAllHours, int? maxAgeDays, int? maxPerFile}) {
    return VersionPreferences(
      enabled: enabled ?? this.enabled,
      keepAllHours: keepAllHours ?? this.keepAllHours,
      maxAgeDays: maxAgeDays ?? this.maxAgeDays,
      maxPerFile: maxPerFile ?? this.maxPerFile,
    );
  }

  VersionPreferences copyWithWrapped({
    Wrapped<bool?>? enabled,
    Wrapped<int?>? keepAllHours,
    Wrapped<int?>? maxAgeDays,
    Wrapped<int?>? maxPerFile,
  }) {
    return VersionPreferences(
      enabled: (enabled != null ? enabled.value : this.enabled),
      keepAllHours: (keepAllHours != null ? keepAllHours.value : this.keepAllHours),
      maxAgeDays: (maxAgeDays != null ? maxAgeDays.value : this.maxAgeDays),
      maxPerFile: (maxPerFile != null ? maxPerFile.value : this.maxPerFile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VersionRestoreRequest {
  const VersionRestoreRequest({this.baseRev});

  factory VersionRestoreRequest.fromJson(Map<String, dynamic> json) => _$VersionRestoreRequestFromJson(json);

  static const toJsonFactory = _$VersionRestoreRequestToJson;
  Map<String, dynamic> toJson() => _$VersionRestoreRequestToJson(this);

  @JsonKey(name: 'baseRev', includeIfNull: false)
  final int? baseRev;
  static const fromJsonFactory = _$VersionRestoreRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VersionRestoreRequest &&
            (identical(other.baseRev, baseRev) || const DeepCollectionEquality().equals(other.baseRev, baseRev)));
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(baseRev) ^ runtimeType.hashCode;
}

extension $VersionRestoreRequestExtension on VersionRestoreRequest {
  VersionRestoreRequest copyWith({int? baseRev}) {
    return VersionRestoreRequest(baseRev: baseRev ?? this.baseRev);
  }

  VersionRestoreRequest copyWithWrapped({Wrapped<int?>? baseRev}) {
    return VersionRestoreRequest(baseRev: (baseRev != null ? baseRev.value : this.baseRev));
  }
}

@JsonSerializable(explicitToJson: true)
class VersionRetention {
  const VersionRetention({
    required this.enabled,
    required this.keepAllHours,
    required this.maxAgeDays,
    required this.maxPerFile,
    required this.serverEnabled,
    required this.serverKeepAllHours,
    required this.serverMaxAgeDays,
    required this.serverMaxPerFile,
    required this.source,
    required this.user,
  });

  factory VersionRetention.fromJson(Map<String, dynamic> json) => _$VersionRetentionFromJson(json);

  static const toJsonFactory = _$VersionRetentionToJson;
  Map<String, dynamic> toJson() => _$VersionRetentionToJson(this);

  @JsonKey(name: 'enabled', includeIfNull: false)
  final bool enabled;
  @JsonKey(name: 'keepAllHours', includeIfNull: false)
  final int keepAllHours;
  @JsonKey(name: 'maxAgeDays', includeIfNull: false)
  final int maxAgeDays;
  @JsonKey(name: 'maxPerFile', includeIfNull: false)
  final int maxPerFile;
  @JsonKey(name: 'serverEnabled', includeIfNull: false)
  final bool serverEnabled;
  @JsonKey(name: 'serverKeepAllHours', includeIfNull: false)
  final int serverKeepAllHours;
  @JsonKey(name: 'serverMaxAgeDays', includeIfNull: false)
  final int serverMaxAgeDays;
  @JsonKey(name: 'serverMaxPerFile', includeIfNull: false)
  final int serverMaxPerFile;
  @JsonKey(
    name: 'source',
    includeIfNull: false,
    toJson: versionRetentionSourceToJson,
    fromJson: versionRetentionSourceFromJson,
  )
  final enums.VersionRetentionSource source;
  @JsonKey(name: 'user', includeIfNull: false)
  final VersionPreferences user;
  static const fromJsonFactory = _$VersionRetentionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VersionRetention &&
            (identical(other.enabled, enabled) || const DeepCollectionEquality().equals(other.enabled, enabled)) &&
            (identical(other.keepAllHours, keepAllHours) ||
                const DeepCollectionEquality().equals(other.keepAllHours, keepAllHours)) &&
            (identical(other.maxAgeDays, maxAgeDays) ||
                const DeepCollectionEquality().equals(other.maxAgeDays, maxAgeDays)) &&
            (identical(other.maxPerFile, maxPerFile) ||
                const DeepCollectionEquality().equals(other.maxPerFile, maxPerFile)) &&
            (identical(other.serverEnabled, serverEnabled) ||
                const DeepCollectionEquality().equals(other.serverEnabled, serverEnabled)) &&
            (identical(other.serverKeepAllHours, serverKeepAllHours) ||
                const DeepCollectionEquality().equals(other.serverKeepAllHours, serverKeepAllHours)) &&
            (identical(other.serverMaxAgeDays, serverMaxAgeDays) ||
                const DeepCollectionEquality().equals(other.serverMaxAgeDays, serverMaxAgeDays)) &&
            (identical(other.serverMaxPerFile, serverMaxPerFile) ||
                const DeepCollectionEquality().equals(other.serverMaxPerFile, serverMaxPerFile)) &&
            (identical(other.source, source) || const DeepCollectionEquality().equals(other.source, source)) &&
            (identical(other.user, user) || const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(enabled) ^
      const DeepCollectionEquality().hash(keepAllHours) ^
      const DeepCollectionEquality().hash(maxAgeDays) ^
      const DeepCollectionEquality().hash(maxPerFile) ^
      const DeepCollectionEquality().hash(serverEnabled) ^
      const DeepCollectionEquality().hash(serverKeepAllHours) ^
      const DeepCollectionEquality().hash(serverMaxAgeDays) ^
      const DeepCollectionEquality().hash(serverMaxPerFile) ^
      const DeepCollectionEquality().hash(source) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $VersionRetentionExtension on VersionRetention {
  VersionRetention copyWith({
    bool? enabled,
    int? keepAllHours,
    int? maxAgeDays,
    int? maxPerFile,
    bool? serverEnabled,
    int? serverKeepAllHours,
    int? serverMaxAgeDays,
    int? serverMaxPerFile,
    enums.VersionRetentionSource? source,
    VersionPreferences? user,
  }) {
    return VersionRetention(
      enabled: enabled ?? this.enabled,
      keepAllHours: keepAllHours ?? this.keepAllHours,
      maxAgeDays: maxAgeDays ?? this.maxAgeDays,
      maxPerFile: maxPerFile ?? this.maxPerFile,
      serverEnabled: serverEnabled ?? this.serverEnabled,
      serverKeepAllHours: serverKeepAllHours ?? this.serverKeepAllHours,
      serverMaxAgeDays: serverMaxAgeDays ?? this.serverMaxAgeDays,
      serverMaxPerFile: serverMaxPerFile ?? this.serverMaxPerFile,
      source: source ?? this.source,
      user: user ?? this.user,
    );
  }

  VersionRetention copyWithWrapped({
    Wrapped<bool>? enabled,
    Wrapped<int>? keepAllHours,
    Wrapped<int>? maxAgeDays,
    Wrapped<int>? maxPerFile,
    Wrapped<bool>? serverEnabled,
    Wrapped<int>? serverKeepAllHours,
    Wrapped<int>? serverMaxAgeDays,
    Wrapped<int>? serverMaxPerFile,
    Wrapped<enums.VersionRetentionSource>? source,
    Wrapped<VersionPreferences>? user,
  }) {
    return VersionRetention(
      enabled: (enabled != null ? enabled.value : this.enabled),
      keepAllHours: (keepAllHours != null ? keepAllHours.value : this.keepAllHours),
      maxAgeDays: (maxAgeDays != null ? maxAgeDays.value : this.maxAgeDays),
      maxPerFile: (maxPerFile != null ? maxPerFile.value : this.maxPerFile),
      serverEnabled: (serverEnabled != null ? serverEnabled.value : this.serverEnabled),
      serverKeepAllHours: (serverKeepAllHours != null ? serverKeepAllHours.value : this.serverKeepAllHours),
      serverMaxAgeDays: (serverMaxAgeDays != null ? serverMaxAgeDays.value : this.serverMaxAgeDays),
      serverMaxPerFile: (serverMaxPerFile != null ? serverMaxPerFile.value : this.serverMaxPerFile),
      source: (source != null ? source.value : this.source),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VersionView {
  const VersionView({
    required this.hasPreview,
    required this.hash,
    required this.id,
    required this.modifiedAt,
    required this.replacedAt,
    required this.size,
  });

  factory VersionView.fromJson(Map<String, dynamic> json) => _$VersionViewFromJson(json);

  static const toJsonFactory = _$VersionViewToJson;
  Map<String, dynamic> toJson() => _$VersionViewToJson(this);

  @JsonKey(name: 'hasPreview', includeIfNull: false)
  final bool hasPreview;
  @JsonKey(name: 'hash', includeIfNull: false)
  final String hash;
  @JsonKey(name: 'id', includeIfNull: false)
  final int id;
  @JsonKey(name: 'modifiedAt', includeIfNull: false)
  final DateTime modifiedAt;
  @JsonKey(name: 'replacedAt', includeIfNull: false)
  final DateTime replacedAt;
  @JsonKey(name: 'size', includeIfNull: false)
  final int size;
  static const fromJsonFactory = _$VersionViewFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VersionView &&
            (identical(other.hasPreview, hasPreview) ||
                const DeepCollectionEquality().equals(other.hasPreview, hasPreview)) &&
            (identical(other.hash, hash) || const DeepCollectionEquality().equals(other.hash, hash)) &&
            (identical(other.id, id) || const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.modifiedAt, modifiedAt) ||
                const DeepCollectionEquality().equals(other.modifiedAt, modifiedAt)) &&
            (identical(other.replacedAt, replacedAt) ||
                const DeepCollectionEquality().equals(other.replacedAt, replacedAt)) &&
            (identical(other.size, size) || const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(hasPreview) ^
      const DeepCollectionEquality().hash(hash) ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(modifiedAt) ^
      const DeepCollectionEquality().hash(replacedAt) ^
      const DeepCollectionEquality().hash(size) ^
      runtimeType.hashCode;
}

extension $VersionViewExtension on VersionView {
  VersionView copyWith({
    bool? hasPreview,
    String? hash,
    int? id,
    DateTime? modifiedAt,
    DateTime? replacedAt,
    int? size,
  }) {
    return VersionView(
      hasPreview: hasPreview ?? this.hasPreview,
      hash: hash ?? this.hash,
      id: id ?? this.id,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      replacedAt: replacedAt ?? this.replacedAt,
      size: size ?? this.size,
    );
  }

  VersionView copyWithWrapped({
    Wrapped<bool>? hasPreview,
    Wrapped<String>? hash,
    Wrapped<int>? id,
    Wrapped<DateTime>? modifiedAt,
    Wrapped<DateTime>? replacedAt,
    Wrapped<int>? size,
  }) {
    return VersionView(
      hasPreview: (hasPreview != null ? hasPreview.value : this.hasPreview),
      hash: (hash != null ? hash.value : this.hash),
      id: (id != null ? id.value : this.id),
      modifiedAt: (modifiedAt != null ? modifiedAt.value : this.modifiedAt),
      replacedAt: (replacedAt != null ? replacedAt.value : this.replacedAt),
      size: (size != null ? size.value : this.size),
    );
  }
}

String? appearanceThemeNullableToJson(enums.AppearanceTheme? appearanceTheme) {
  return appearanceTheme?.value;
}

String? appearanceThemeToJson(enums.AppearanceTheme appearanceTheme) {
  return appearanceTheme.value;
}

enums.AppearanceTheme appearanceThemeFromJson(Object? appearanceTheme, [enums.AppearanceTheme? defaultValue]) {
  return enums.AppearanceTheme.values.firstWhereOrNull((e) => e.value == appearanceTheme) ??
      defaultValue ??
      enums.AppearanceTheme.swaggerGeneratedUnknown;
}

enums.AppearanceTheme? appearanceThemeNullableFromJson(Object? appearanceTheme, [enums.AppearanceTheme? defaultValue]) {
  if (appearanceTheme == null) {
    return null;
  }
  return enums.AppearanceTheme.values.firstWhereOrNull((e) => e.value == appearanceTheme) ?? defaultValue;
}

String appearanceThemeExplodedListToJson(List<enums.AppearanceTheme>? appearanceTheme) {
  return appearanceTheme?.map((e) => e.value!).join(',') ?? '';
}

List<String> appearanceThemeListToJson(List<enums.AppearanceTheme>? appearanceTheme) {
  if (appearanceTheme == null) {
    return [];
  }

  return appearanceTheme.map((e) => e.value!).toList();
}

List<enums.AppearanceTheme> appearanceThemeListFromJson(
  List? appearanceTheme, [
  List<enums.AppearanceTheme>? defaultValue,
]) {
  if (appearanceTheme == null) {
    return defaultValue ?? [];
  }

  return appearanceTheme.map((e) => appearanceThemeFromJson(e.toString())).toList();
}

List<enums.AppearanceTheme>? appearanceThemeNullableListFromJson(
  List? appearanceTheme, [
  List<enums.AppearanceTheme>? defaultValue,
]) {
  if (appearanceTheme == null) {
    return defaultValue;
  }

  return appearanceTheme.map((e) => appearanceThemeFromJson(e.toString())).toList();
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

String? versionRetentionSourceNullableToJson(enums.VersionRetentionSource? versionRetentionSource) {
  return versionRetentionSource?.value;
}

String? versionRetentionSourceToJson(enums.VersionRetentionSource versionRetentionSource) {
  return versionRetentionSource.value;
}

enums.VersionRetentionSource versionRetentionSourceFromJson(
  Object? versionRetentionSource, [
  enums.VersionRetentionSource? defaultValue,
]) {
  return enums.VersionRetentionSource.values.firstWhereOrNull((e) => e.value == versionRetentionSource) ??
      defaultValue ??
      enums.VersionRetentionSource.swaggerGeneratedUnknown;
}

enums.VersionRetentionSource? versionRetentionSourceNullableFromJson(
  Object? versionRetentionSource, [
  enums.VersionRetentionSource? defaultValue,
]) {
  if (versionRetentionSource == null) {
    return null;
  }
  return enums.VersionRetentionSource.values.firstWhereOrNull((e) => e.value == versionRetentionSource) ?? defaultValue;
}

String versionRetentionSourceExplodedListToJson(List<enums.VersionRetentionSource>? versionRetentionSource) {
  return versionRetentionSource?.map((e) => e.value!).join(',') ?? '';
}

List<String> versionRetentionSourceListToJson(List<enums.VersionRetentionSource>? versionRetentionSource) {
  if (versionRetentionSource == null) {
    return [];
  }

  return versionRetentionSource.map((e) => e.value!).toList();
}

List<enums.VersionRetentionSource> versionRetentionSourceListFromJson(
  List? versionRetentionSource, [
  List<enums.VersionRetentionSource>? defaultValue,
]) {
  if (versionRetentionSource == null) {
    return defaultValue ?? [];
  }

  return versionRetentionSource.map((e) => versionRetentionSourceFromJson(e.toString())).toList();
}

List<enums.VersionRetentionSource>? versionRetentionSourceNullableListFromJson(
  List? versionRetentionSource, [
  List<enums.VersionRetentionSource>? defaultValue,
]) {
  if (versionRetentionSource == null) {
    return defaultValue;
  }

  return versionRetentionSource.map((e) => versionRetentionSourceFromJson(e.toString())).toList();
}

String? apiV1AdminLogsGetLevelNullableToJson(enums.ApiV1AdminLogsGetLevel? apiV1AdminLogsGetLevel) {
  return apiV1AdminLogsGetLevel?.value;
}

String? apiV1AdminLogsGetLevelToJson(enums.ApiV1AdminLogsGetLevel apiV1AdminLogsGetLevel) {
  return apiV1AdminLogsGetLevel.value;
}

enums.ApiV1AdminLogsGetLevel apiV1AdminLogsGetLevelFromJson(
  Object? apiV1AdminLogsGetLevel, [
  enums.ApiV1AdminLogsGetLevel? defaultValue,
]) {
  return enums.ApiV1AdminLogsGetLevel.values.firstWhereOrNull((e) => e.value == apiV1AdminLogsGetLevel) ??
      defaultValue ??
      enums.ApiV1AdminLogsGetLevel.swaggerGeneratedUnknown;
}

enums.ApiV1AdminLogsGetLevel? apiV1AdminLogsGetLevelNullableFromJson(
  Object? apiV1AdminLogsGetLevel, [
  enums.ApiV1AdminLogsGetLevel? defaultValue,
]) {
  if (apiV1AdminLogsGetLevel == null) {
    return null;
  }
  return enums.ApiV1AdminLogsGetLevel.values.firstWhereOrNull((e) => e.value == apiV1AdminLogsGetLevel) ?? defaultValue;
}

String apiV1AdminLogsGetLevelExplodedListToJson(List<enums.ApiV1AdminLogsGetLevel>? apiV1AdminLogsGetLevel) {
  return apiV1AdminLogsGetLevel?.map((e) => e.value!).join(',') ?? '';
}

List<String> apiV1AdminLogsGetLevelListToJson(List<enums.ApiV1AdminLogsGetLevel>? apiV1AdminLogsGetLevel) {
  if (apiV1AdminLogsGetLevel == null) {
    return [];
  }

  return apiV1AdminLogsGetLevel.map((e) => e.value!).toList();
}

List<enums.ApiV1AdminLogsGetLevel> apiV1AdminLogsGetLevelListFromJson(
  List? apiV1AdminLogsGetLevel, [
  List<enums.ApiV1AdminLogsGetLevel>? defaultValue,
]) {
  if (apiV1AdminLogsGetLevel == null) {
    return defaultValue ?? [];
  }

  return apiV1AdminLogsGetLevel.map((e) => apiV1AdminLogsGetLevelFromJson(e.toString())).toList();
}

List<enums.ApiV1AdminLogsGetLevel>? apiV1AdminLogsGetLevelNullableListFromJson(
  List? apiV1AdminLogsGetLevel, [
  List<enums.ApiV1AdminLogsGetLevel>? defaultValue,
]) {
  if (apiV1AdminLogsGetLevel == null) {
    return defaultValue;
  }

  return apiV1AdminLogsGetLevel.map((e) => apiV1AdminLogsGetLevelFromJson(e.toString())).toList();
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

int? apiV1FilesVersionsVersionIDPreviewGetSizeNullableToJson(
  enums.ApiV1FilesVersionsVersionIDPreviewGetSize? apiV1FilesVersionsVersionIDPreviewGetSize,
) {
  return apiV1FilesVersionsVersionIDPreviewGetSize?.value;
}

int? apiV1FilesVersionsVersionIDPreviewGetSizeToJson(
  enums.ApiV1FilesVersionsVersionIDPreviewGetSize apiV1FilesVersionsVersionIDPreviewGetSize,
) {
  return apiV1FilesVersionsVersionIDPreviewGetSize.value;
}

enums.ApiV1FilesVersionsVersionIDPreviewGetSize apiV1FilesVersionsVersionIDPreviewGetSizeFromJson(
  Object? apiV1FilesVersionsVersionIDPreviewGetSize, [
  enums.ApiV1FilesVersionsVersionIDPreviewGetSize? defaultValue,
]) {
  return enums.ApiV1FilesVersionsVersionIDPreviewGetSize.values.firstWhereOrNull(
        (e) => e.value == apiV1FilesVersionsVersionIDPreviewGetSize,
      ) ??
      defaultValue ??
      enums.ApiV1FilesVersionsVersionIDPreviewGetSize.swaggerGeneratedUnknown;
}

enums.ApiV1FilesVersionsVersionIDPreviewGetSize? apiV1FilesVersionsVersionIDPreviewGetSizeNullableFromJson(
  Object? apiV1FilesVersionsVersionIDPreviewGetSize, [
  enums.ApiV1FilesVersionsVersionIDPreviewGetSize? defaultValue,
]) {
  if (apiV1FilesVersionsVersionIDPreviewGetSize == null) {
    return null;
  }
  return enums.ApiV1FilesVersionsVersionIDPreviewGetSize.values.firstWhereOrNull(
        (e) => e.value == apiV1FilesVersionsVersionIDPreviewGetSize,
      ) ??
      defaultValue;
}

String apiV1FilesVersionsVersionIDPreviewGetSizeExplodedListToJson(
  List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize>? apiV1FilesVersionsVersionIDPreviewGetSize,
) {
  return apiV1FilesVersionsVersionIDPreviewGetSize?.map((e) => e.value!).join(',') ?? '';
}

List<int> apiV1FilesVersionsVersionIDPreviewGetSizeListToJson(
  List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize>? apiV1FilesVersionsVersionIDPreviewGetSize,
) {
  if (apiV1FilesVersionsVersionIDPreviewGetSize == null) {
    return [];
  }

  return apiV1FilesVersionsVersionIDPreviewGetSize.map((e) => e.value!).toList();
}

List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize> apiV1FilesVersionsVersionIDPreviewGetSizeListFromJson(
  List? apiV1FilesVersionsVersionIDPreviewGetSize, [
  List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize>? defaultValue,
]) {
  if (apiV1FilesVersionsVersionIDPreviewGetSize == null) {
    return defaultValue ?? [];
  }

  return apiV1FilesVersionsVersionIDPreviewGetSize
      .map((e) => apiV1FilesVersionsVersionIDPreviewGetSizeFromJson(e))
      .toList();
}

List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize>? apiV1FilesVersionsVersionIDPreviewGetSizeNullableListFromJson(
  List? apiV1FilesVersionsVersionIDPreviewGetSize, [
  List<enums.ApiV1FilesVersionsVersionIDPreviewGetSize>? defaultValue,
]) {
  if (apiV1FilesVersionsVersionIDPreviewGetSize == null) {
    return defaultValue;
  }

  return apiV1FilesVersionsVersionIDPreviewGetSize
      .map((e) => apiV1FilesVersionsVersionIDPreviewGetSizeFromJson(e))
      .toList();
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
