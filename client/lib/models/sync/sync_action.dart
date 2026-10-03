import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/local_file_state.dart";

part "sync_action.freezed.dart";

@freezed
sealed class SyncAction with _$SyncAction {
  const SyncAction._();

  const factory SyncAction.createRemoteDir({required String path}) = CreateRemoteDirAction;

  const factory SyncAction.createLocalDir({required String path, required FileEntry remote}) = CreateLocalDirAction;

  const factory SyncAction.upload({required String path, required LocalFileState local, required int baseRev}) =
      UploadAction;

  const factory SyncAction.download({required String path, required FileEntry remote}) = DownloadAction;

  const factory SyncAction.deleteLocal({required String path}) = DeleteLocalAction;

  const factory SyncAction.deleteRemote({required String path, required int baseRev}) = DeleteRemoteAction;

  const factory SyncAction.recordSynced({
    required String path,
    required LocalFileState local,
    required FileEntry remote,
  }) = RecordSyncedAction;

  const factory SyncAction.updatePlaceholder({required String path, required FileEntry remote}) =
      UpdatePlaceholderAction;

  const factory SyncAction.forget({required String path}) = ForgetAction;

  const factory SyncAction.conflict({required String path, required Conflict conflict}) = ConflictAction;

  int get depth => path.split("/").length;

  bool get isDelete => this is DeleteLocalAction || this is DeleteRemoteAction || this is ForgetAction;

  bool get isDirectoryCreation => this is CreateRemoteDirAction || this is CreateLocalDirAction;
}
