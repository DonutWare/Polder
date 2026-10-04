import "package:freezed_annotation/freezed_annotation.dart";

import "package:nomad/models/sync/sync_root.dart";

part "sync_folder_form.freezed.dart";

@freezed
abstract class SyncFolderForm with _$SyncFolderForm {
  const SyncFolderForm._();

  const factory SyncFolderForm({
    @Default(SyncMode.sync) SyncMode mode,
    String? localPath,
    @Default("/") String remotePath,
    @Default(false) bool hasExistingFiles,
    @Default(true) bool uploadExisting,
    @Default(false) bool storageDenied,
  }) = _SyncFolderForm;

  bool get isComplete => localPath != null && remotePath.startsWith("/");

  bool get skipsExisting => mode == SyncMode.autoUpload && hasExistingFiles && !uploadExisting;
}
