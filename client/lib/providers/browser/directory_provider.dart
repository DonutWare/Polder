import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/directory_listing.dart";
import "package:nomad/models/file_entry.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/current_user_provider.dart";
import "package:nomad/providers/sync/sync_scheduler_provider.dart";
import "package:nomad/services/api/nomad_api.dart";
import "package:nomad/util/remote_path.dart";

final directoryProvider = AsyncNotifierProvider.autoDispose.family<DirectoryNotifier, DirectoryListing, String>(
  DirectoryNotifier.new,
);

class DirectoryNotifier extends AsyncNotifier<DirectoryListing> {
  DirectoryNotifier(this.path);

  final String path;

  NomadApi get _api => ref.read(nomadApiProvider);

  @override
  Future<DirectoryListing> build() => ref.watch(nomadApiProvider).list(path);

  Future<void> refresh() async => state = await AsyncValue.guard(() => _api.list(path));

  Future<void> createFolder(String name) => _mutate(() => _api.mkdir(RemotePath.join(path, name)));

  Future<void> rename(FileEntry entry, String newName) =>
      _mutate(() => _api.move(from: entry.path, to: RemotePath.join(path, newName), baseRev: entry.rev));

  Future<void> moveTo(FileEntry entry, String destination) async {
    await _mutate(() => _api.move(from: entry.path, to: RemotePath.join(destination, entry.name), baseRev: entry.rev));
    ref.invalidate(directoryProvider(destination));
  }

  Future<void> delete(FileEntry entry) => _mutate(() => _api.delete(entry.path, baseRev: entry.rev));

  Future<void> _mutate(Future<Object?> Function() action) async {
    await action();
    ref.invalidate(currentUserProvider);
    ref.read(syncSchedulerProvider)?.requestRun();
    if (ref.mounted) await refresh();
  }
}
