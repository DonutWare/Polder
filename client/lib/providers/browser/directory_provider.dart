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

  Future<FileEntry> createEmptyFile(String name) async {
    late FileEntry created;
    await _mutate(
      () async => created = await _api.putContent(RemotePath.join(path, name), const Stream.empty(), length: 0),
    );
    return created;
  }

  Future<void> rename(FileEntry entry, String newName) =>
      _mutate(() => _api.move(from: entry.path, to: RemotePath.join(path, newName), baseRev: entry.rev));

  Future<void> moveTo(FileEntry entry, String destination) => moveAllTo([entry], destination);

  Future<void> moveAllTo(Iterable<FileEntry> entries, String destination) async {
    try {
      await _mutateEach(
        entries,
        (entry) => _api.move(from: entry.path, to: RemotePath.join(destination, entry.name), baseRev: entry.rev),
      );
    } finally {
      if (ref.mounted) ref.invalidate(directoryProvider(destination));
    }
  }

  /// Copies [entries] into [destination]. One whose name is taken there is called "name (copy)" instead,
  /// numbered when that is taken too; [copySuffix] is the localized word for "copy".
  Future<void> copyAllTo(Iterable<FileEntry> entries, String destination, {required String copySuffix}) async {
    try {
      final taken = {for (final entry in (await _api.list(destination)).entries) entry.name};
      await _mutateEach(entries, (entry) {
        final name = _freeName(entry, taken, copySuffix);
        taken.add(name);
        return _api.copy(from: entry.path, to: RemotePath.join(destination, name));
      });
    } finally {
      if (ref.mounted && destination != path) ref.invalidate(directoryProvider(destination));
    }
  }

  static String _freeName(FileEntry entry, Set<String> taken, String copySuffix) {
    if (!taken.contains(entry.name)) return entry.name;
    final base = entry.isDir ? entry.name : RemotePath.withoutExtension(entry.name);
    final extension = entry.isDir ? "" : RemotePath.extension(entry.name);
    for (var number = 1; ; number++) {
      final name =
          "$base (${number == 1 ? copySuffix : "$copySuffix $number"})${extension.isEmpty ? "" : ".$extension"}";
      if (!taken.contains(name)) return name;
    }
  }

  Future<void> delete(FileEntry entry) => deleteAll([entry]);

  Future<void> deleteAll(Iterable<FileEntry> entries) =>
      _mutateEach(entries, (entry) => _api.delete(entry.path, baseRev: entry.rev));

  // One failing entry doesn't stop the others; the first failure is rethrown once all were tried.
  Future<void> _mutateEach(Iterable<FileEntry> entries, Future<Object?> Function(FileEntry entry) action) =>
      _mutate(() async {
        (Object, StackTrace)? failure;
        for (final entry in entries) {
          try {
            await action(entry);
          } catch (error, stack) {
            failure ??= (error, stack);
          }
        }
        if (failure case (final error, final stack)) Error.throwWithStackTrace(error, stack);
      });

  // The listing is refreshed even when the action fails, since part of it may have gone through.
  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } finally {
      if (ref.mounted) {
        ref.invalidate(currentUserProvider);
        ref.read(syncSchedulerProvider)?.requestRun();
        await refresh();
      }
    }
  }
}
