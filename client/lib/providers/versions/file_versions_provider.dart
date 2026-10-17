import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_version.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/guarded_refresh.dart";
import "package:polder/util/remote_path.dart";

final fileVersionsProvider = AsyncNotifierProvider.autoDispose.family<FileVersionsNotifier, VersionListing, String>(
  FileVersionsNotifier.new,
);

class FileVersionsNotifier extends AsyncNotifier<VersionListing> with GuardedRefresh {
  FileVersionsNotifier(this.path);

  final String path;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<VersionListing> build() => _fetch(ref.watch(polderApiProvider));

  Future<void> refresh() => refreshWith(() => _fetch(_api));

  Future<VersionListing> _fetch(PolderApi api) => api.fileVersions(path);

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

  Future<void> choose(VersionPreferences preferences) async {
    state = AsyncData(await ref.read(polderApiProvider).setVersionSettings(preferences));
    ref.invalidate(currentUserProvider);
  }
}
