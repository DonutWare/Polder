import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/util/remote_path.dart";

final directoryProvider = AsyncNotifierProvider.autoDispose.family<DirectoryNotifier, DirectoryListing, String>(
  DirectoryNotifier.new,
);

class DirectoryNotifier extends AsyncNotifier<DirectoryListing> {
  DirectoryNotifier(this.path);

  // The server says when it is still indexing but not when it stops, so the listing is fetched
  // again until it is done.
  static const indexingRefresh = Duration(seconds: 3);

  final String path;
  Timer? _indexingTimer;

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<DirectoryListing> build() async {
    ref.onDispose(() => _indexingTimer?.cancel());
    final listing = await ref.watch(polderApiProvider).list(path);
    _followIndexing(listing);
    return listing;
  }

  Future<void> refresh() async {
    final result = await AsyncValue.guard(() => _api.list(path));
    if (!ref.mounted) return;
    state = result;
    if (result.value case final listing?) _followIndexing(listing);
  }

  void _followIndexing(DirectoryListing listing) {
    _indexingTimer?.cancel();
    _indexingTimer = listing.indexing ? Timer(indexingRefresh, refresh) : null;
  }

  Future<void> createFolder(String name) => _mutate(() => _api.mkdir(RemotePath.join(path, name)));

  Future<void> rename(FileEntry entry, String newName) =>
      _mutate(() => _api.move(from: entry.path, to: RemotePath.join(path, newName), baseRev: entry.rev));

  Future<void> moveTo(FileEntry entry, String destination) async {
    await _mutate(() => _api.move(from: entry.path, to: RemotePath.join(destination, entry.name), baseRev: entry.rev));
    if (ref.mounted) ref.invalidate(directoryProvider(destination));
  }

  Future<void> delete(FileEntry entry) => _mutate(() => _api.delete(entry.path, baseRev: entry.rev));

  Future<void> _mutate(Future<Object?> Function() action) async {
    await action();
    if (!ref.mounted) return;
    ref.invalidate(currentUserProvider);
    ref.read(syncSchedulerProvider)?.requestRun();
    await refresh();
  }
}
