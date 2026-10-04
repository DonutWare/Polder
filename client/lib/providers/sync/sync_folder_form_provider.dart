import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:nomad/models/sync/sync_folder_form.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/service_providers.dart";
import "package:nomad/providers/sync/auto_upload_settings_provider.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/providers/sync/sync_roots_provider.dart";
import "package:nomad/services/api/api_exceptions.dart";
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
    final platform = ref.read(syncPlatformProvider);
    final allowed = await platform.requestStorageAccess();
    if (!ref.mounted) return;
    state = state.copyWith(storageDenied: !allowed);
    if (!allowed) return;
    final picked = await ref.read(filePickerServiceProvider).pickDirectory();
    if (picked == null || !ref.mounted) return;
    final hasExistingFiles = await platform.containsFiles(picked);
    if (!ref.mounted) return;
    state = state.copyWith(
      localPath: picked,
      remotePath: _suggestedRemotePath(picked),
      hasExistingFiles: hasExistingFiles,
    );
  }

  void setRemotePath(String remotePath) => state = state.copyWith(remotePath: remotePath);

  void setUploadExisting(bool uploadExisting) => state = state.copyWith(uploadExisting: uploadExisting);

  Future<bool> submit() async {
    final localPath = state.localPath;
    if (localPath == null || !state.isComplete) return false;
    if (mode == SyncMode.autoUpload) {
      final settings = ref.read(autoUploadSettingsProvider.notifier);
      // Adding a folder is a clear request to upload it, so the switch that gates every folder follows along.
      if (!(await ref.read(autoUploadSettingsProvider.future)).enabled) await settings.setEnabled(true);
    }
    await _createRemoteFolder(state.remotePath);
    await ref
        .read(syncRootsProvider.notifier)
        .add(localPath: localPath, remotePath: state.remotePath, mode: mode, skipExisting: state.skipsExisting);
    return true;
  }

  Future<void> _createRemoteFolder(String remotePath) async {
    if (remotePath == RemotePath.root) return;
    try {
      await ref.read(nomadApiProvider).mkdir(remotePath);
    } on AlreadyExistsException {
      return;
    } on NetworkException {
      return;
    }
  }

  String _suggestedRemotePath(String localPath) {
    if (mode != SyncMode.autoUpload) return state.remotePath;
    final folderName = localPath.split(RegExp(r"[/\\]")).lastWhere((segment) => segment.isNotEmpty, orElse: () => "");
    return RemotePath.join(autoUploadRemoteRoot, folderName);
  }
}
