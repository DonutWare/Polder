import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/sync_folder_form.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/providers/sync/sync_roots_provider.dart";
import "package:nomad/util/remote_path.dart";

final syncFolderFormProvider = NotifierProvider.autoDispose.family<SyncFolderFormNotifier, SyncFolderForm, SyncMode>(
  SyncFolderFormNotifier.new,
);

class SyncFolderFormNotifier extends Notifier<SyncFolderForm> {
  SyncFolderFormNotifier(this.mode);

  static const autoUploadRemoteRoot = "/Camera Uploads";

  final SyncMode mode;

  @override
  SyncFolderForm build() =>
      SyncFolderForm(mode: mode, remotePath: mode == SyncMode.autoUpload ? autoUploadRemoteRoot : "/");

  Future<void> pickLocalFolder() async {
    final picked = await ref.read(filePickerServiceProvider).pickDirectory();
    if (picked == null) return;
    state = state.copyWith(localPath: picked, remotePath: _suggestedRemotePath(picked));
  }

  void setRemotePath(String remotePath) => state = state.copyWith(remotePath: remotePath);

  Future<bool> submit() async {
    final localPath = state.localPath;
    if (localPath == null || !state.isComplete) return false;
    await ref.read(syncRootsProvider.notifier).add(localPath: localPath, remotePath: state.remotePath, mode: mode);
    return true;
  }

  String _suggestedRemotePath(String localPath) {
    if (mode != SyncMode.autoUpload) return state.remotePath;
    final folderName = localPath.split(RegExp(r"[/\\]")).lastWhere((segment) => segment.isNotEmpty, orElse: () => "");
    return RemotePath.join(autoUploadRemoteRoot, folderName);
  }
}
