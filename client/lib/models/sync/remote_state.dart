import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";

part "remote_state.freezed.dart";

@freezed
sealed class RemoteState with _$RemoteState {
  const factory RemoteState.upserted(FileEntry entry) = RemoteUpserted;

  const factory RemoteState.deleted() = RemoteDeleted;
}
