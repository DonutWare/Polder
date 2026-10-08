import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/remote_path.dart";

final fileVersionsProvider = AsyncNotifierProvider.autoDispose.family<FileVersionsNotifier, VersionListing, String>(
  FileVersionsNotifier.new,
);

class FileVersionsNotifier extends AsyncNotifier<VersionListing> {
  FileVersionsNotifier(this.path);

  final String path;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<VersionListing> build() => ref.watch(polderApiProvider).fileVersions(path);

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => _api.fileVersions(path));
    if (ref.mounted) state = result;
  }

  Future<FileEntry> restore(FileVersion version) async {
    final restored = await _api.restoreVersion(version.id);
    ref.invalidate(directoryProvider(RemotePath.parent(restored.path)));
    ref.invalidate(currentUserProvider);
    ref.read(syncSchedulerProvider)?.requestRun();
    await refresh();
    return restored;
  }

  Future<void> delete(FileVersion version) async {
    await _api.deleteVersion(version.id);
    ref.invalidate(currentUserProvider);
    await refresh();
  }
}

final versionSettingsProvider = AsyncNotifierProvider.autoDispose<VersionSettingsNotifier, VersionRetention>(
  VersionSettingsNotifier.new,
);

class VersionSettingsNotifier extends AsyncNotifier<VersionRetention> {
  @override
  Future<VersionRetention> build() => ref.watch(polderApiProvider).versionSettings();

  Future<void> choose({required bool? enabled, required int? maxAgeDays, required int? maxPerFile}) async {
    state = AsyncData(
      await ref
          .read(polderApiProvider)
          .setVersionSettings(enabled: enabled, maxAgeDays: maxAgeDays, maxPerFile: maxPerFile),
    );
    ref.invalidate(currentUserProvider);
  }
}
