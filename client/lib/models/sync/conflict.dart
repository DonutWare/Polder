import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/local_file_state.dart";

part "conflict.freezed.dart";
part "conflict.g.dart";

enum ConflictKind { bothModified, bothCreated, localModifiedRemoteDeleted, localDeletedRemoteModified }

enum ConflictResolution { keepMine, keepServer, keepBoth }

@freezed
abstract class Conflict with _$Conflict {
  const Conflict._();

  const factory Conflict({
    required String syncRootId,
    required String relativePath,
    required ConflictKind kind,
    LocalFileState? local,
    FileEntry? remote,
  }) = _Conflict;

  factory Conflict.fromJson(Map<String, dynamic> json) => _$ConflictFromJson(json);

  String get id => "$syncRootId:$relativePath";

  String get name => relativePath.split("/").last;

  bool get isDeleteVersusModify =>
      kind == ConflictKind.localModifiedRemoteDeleted || kind == ConflictKind.localDeletedRemoteModified;
}
