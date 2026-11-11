import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_entry.dart";

part "offline_models.freezed.dart";
part "offline_models.g.dart";

enum OutboxErrorKind {
  unreachable,
  timedOut,
  serverError,
  storageFull,
  deviceFull,
  serverDidNotStore,
  quota,
  conflict,
  forbidden,
  notFound,
  rejected;

  bool get retries => switch (this) {
    unreachable || timedOut || serverError || storageFull || deviceFull || serverDidNotStore => true,
    quota || conflict || forbidden || notFound || rejected => false,
  };
}

@freezed
abstract class OutboxError with _$OutboxError {
  const factory OutboxError({required OutboxErrorKind kind, @Default("") String message}) = _OutboxError;

  factory OutboxError.fromJson(Map<String, dynamic> json) => _$OutboxErrorFromJson(json);
}

enum OutboxDomain { files, calendar }

@Freezed(unionKey: "op")
sealed class OutboxOp with _$OutboxOp {
  const OutboxOp._();

  const factory OutboxOp.put({required String path, required String hash, required int size}) = PutOp;

  const factory OutboxOp.move({required String from, required String to}) = MoveOp;

  const factory OutboxOp.delete({required String path, @Default(-1) int baseRev}) = DeleteOp;

  const factory OutboxOp.calendar({required String eventKey, required Map<String, dynamic> change}) = CalendarOp;

  factory OutboxOp.fromJson(Map<String, dynamic> json) => _$OutboxOpFromJson(json);

  OutboxDomain get domain => this is CalendarOp ? OutboxDomain.calendar : OutboxDomain.files;

  String get path => switch (this) {
    PutOp(:final path) || DeleteOp(:final path) => path,
    MoveOp(:final to) => to,
    CalendarOp(:final eventKey) => eventKey,
  };
}

@freezed
abstract class OutboxEntry with _$OutboxEntry {
  const OutboxEntry._();

  const factory OutboxEntry({
    required int id,
    required OutboxOp op,
    required DateTime createdAt,
    @Default(0) int attempts,
    DateTime? nextAttemptAt,
    OutboxError? error,
  }) = _OutboxEntry;

  OutboxDomain get domain => op.domain;

  String get path => op.path;

  bool get blocked => error != null && !error!.kind.retries;

  bool get failing => error != null;

  bool readyAt(DateTime now) => !blocked && (nextAttemptAt == null || !nextAttemptAt!.isAfter(now));
}

enum OfflinePinKind { notes, user, excluded }

@freezed
abstract class OfflinePin with _$OfflinePin {
  const OfflinePin._();

  const factory OfflinePin({required String path, required OfflinePinKind kind, @Default(false) bool populated}) =
      _OfflinePin;

  factory OfflinePin.fromJson(Map<String, dynamic> json) => _$OfflinePinFromJson(json);

  static const notesContentLimit = 20 * 1024 * 1024;

  bool covers(String candidate) => candidate == path || path == "/" || candidate.startsWith("$path/");

  bool get mirrors => kind != OfflinePinKind.excluded;
}

extension OfflinePins on Iterable<OfflinePin> {
  OfflinePin? governing(String path) {
    OfflinePin? best;
    for (final pin in this) {
      if (pin.covers(path) && (best == null || pin.path.length > best.path.length)) best = pin;
    }
    return best;
  }

  bool mirrors(String path) => any((pin) => pin.mirrors && pin.covers(path));

  bool wantsContent(String path, int size) => switch (governing(path)?.kind) {
    OfflinePinKind.user => true,
    OfflinePinKind.notes => size <= OfflinePin.notesContentLimit,
    _ => false,
  };

  Iterable<OfflinePin> nestedIn(String root) =>
      where((pin) => pin.path != root && (root == "/" || pin.path.startsWith("$root/")));

  Iterable<OfflinePin> ofKind(OfflinePinKind kind) => where((pin) => pin.kind == kind);
}

enum OfflineFileState { synced, pending, conflict, failed }

@freezed
abstract class OfflineConflict with _$OfflineConflict {
  const factory OfflineConflict({FileEntry? server, @Default(false) bool deletedHere, required DateTime detectedAt}) =
      _OfflineConflict;

  factory OfflineConflict.fromJson(Map<String, dynamic> json) => _$OfflineConflictFromJson(json);
}

@freezed
abstract class OfflineFile with _$OfflineFile {
  const OfflineFile._();

  const factory OfflineFile({
    required FileEntry entry,
    @Default(0) int baseRev,
    @Default("") String baseHash,
    String? localHash,
    @Default(OfflineFileState.synced) OfflineFileState state,
    OfflineConflict? conflict,
    OutboxError? error,
    @Default(false) bool transient,
  }) = _OfflineFile;

  factory OfflineFile.fromServer(FileEntry entry, {String? localHash}) =>
      OfflineFile(entry: entry, baseRev: entry.rev, baseHash: entry.hash, localHash: localHash);

  factory OfflineFile.fromJson(Map<String, dynamic> json) => _$OfflineFileFromJson(json);

  String get path => entry.path;

  bool get isDir => entry.isDir;

  bool get onServer => baseRev > 0;

  bool get unsynced => state != OfflineFileState.synced;

  bool get hasCurrentContent => localHash != null && localHash == entry.hash;

  bool get contentReady => localHash != null && (unsynced || localHash == entry.hash);
}
