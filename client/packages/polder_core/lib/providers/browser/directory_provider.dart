import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/directory_listing.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder/providers/browser/file_operations_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder/providers/sync/sync_scheduler_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder_core/util/guarded_refresh.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_core/providers/tags/tags_provider.dart";

final directoryProvider = AsyncNotifierProvider.autoDispose.family<DirectoryNotifier, DirectoryListing, String>(
  DirectoryNotifier.new,
);

class DirectoryNotifier extends AsyncNotifier<DirectoryListing> with GuardedRefresh {
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
    ref.watch(polderApiProvider);
    ref.watch(tagAssignmentsRevisionProvider);
    return localFirst(local: _offlineListing, remote: _fetch);
  }

  Future<void> refresh() => refreshWith(_fetch);

  Future<DirectoryListing?> _offlineListing() async {
    final files = ref.read(offlineFilesProvider).value;
    if (files == null || !await files.availableOffline(path)) return null;
    return _cachedListing();
  }

  Future<DirectoryListing> _fetch() async {
    try {
      final listing = await _api.list(path);
      _followIndexing(listing);
      return listing;
    } on NetworkException {
      final cached = await _cachedListing();
      if (cached == null) rethrow;
      return cached;
    }
  }

  Future<DirectoryListing?> _cachedListing() async {
    final files = await ref.read(offlineFilesProvider.future);
    final children = await files.children(path);
    if (children.isEmpty && !await files.availableOffline(path)) return null;
    return DirectoryListing(path: path, entries: [for (final child in children) child.entry]);
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

  FileOperationsNotifier get _operations => ref.read(fileOperationsProvider.notifier);

  Future<void> rename(FileEntry entry, String newName) async {
    if (_operations.isBusy(entry.path)) return;
    await _mutate(
      () => _operations.runSingle(
        kind: FileOperationKind.rename,
        item: FileOperationItem.of(entry, targetName: newName),
        perform: () => _api.move(from: entry.path, to: RemotePath.join(path, newName), baseRev: entry.rev),
      ),
    );
  }

  Future<void> moveTo(FileEntry entry, String destination) => moveAllTo([entry], destination);

  Future<void> moveAllTo(Iterable<FileEntry> entries, String destination) async {
    final api = _api;
    final container = ref.container;
    final byPath = _idleByPath(entries);
    if (byPath.isEmpty) return;
    try {
      await _mutate(
        () => _operations.run(
          kind: FileOperationKind.move,
          destination: destination,
          items: [for (final entry in byPath.values) FileOperationItem.of(entry)],
          onItemDone: (_) => unawaited(_refreshIfShown(container, destination)),
          perform: (item) {
            final entry = byPath[item.path]!;
            return api.move(from: entry.path, to: RemotePath.join(destination, entry.name), baseRev: entry.rev);
          },
        ),
      );
    } finally {
      container.invalidate(directoryProvider(destination));
    }
  }

  /// Copies [entries] into [destination]. One whose name is taken there is called "name (copy)" instead,
  /// numbered when that is taken too; [copySuffix] is the localized word for "copy".
  Future<void> copyAllTo(Iterable<FileEntry> entries, String destination, {required String copySuffix}) async {
    final api = _api;
    final operations = _operations;
    final container = ref.container;
    try {
      final taken = {for (final entry in (await api.list(destination)).entries) entry.name};
      final items = <FileOperationItem>[];
      for (final entry in entries) {
        final name = _freeName(entry, taken, copySuffix);
        taken.add(name);
        items.add(FileOperationItem.of(entry, targetName: name));
      }
      await _mutate(
        () => operations.run(
          kind: FileOperationKind.copy,
          destination: destination,
          items: items,
          onItemDone: (_) => unawaited(_refreshIfShown(container, destination)),
          perform: (item) => api.copy(from: item.path, to: RemotePath.join(destination, item.targetName!)),
        ),
      );
    } finally {
      if (destination != path) container.invalidate(directoryProvider(destination));
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

  Future<void> deleteAll(Iterable<FileEntry> entries) {
    final api = _api;
    final byPath = _idleByPath(entries);
    if (byPath.isEmpty) return Future.value();
    return _mutate(
      () => _operations.run(
        kind: FileOperationKind.delete,
        items: [for (final entry in byPath.values) FileOperationItem.of(entry)],
        perform: (item) => api.delete(item.path, baseRev: byPath[item.path]!.rev),
      ),
    );
  }

  Map<String, FileEntry> _idleByPath(Iterable<FileEntry> entries) => {
    for (final entry in entries)
      if (!_operations.isBusy(entry.path)) entry.path: entry,
  };

  static Future<void> _refreshIfShown(ProviderContainer container, String directory) async {
    if (!container.exists(directoryProvider(directory))) return;
    await container.read(directoryProvider(directory).notifier).refresh();
  }

  // The listing is refreshed even when the action fails, since part of it may have gone through.
  Future<void> _mutate(Future<void> Function() action) async {
    final container = ref.container;
    try {
      await action();
    } finally {
      container.invalidate(currentUserProvider);
      container.read(syncSchedulerProvider)?.requestRun();
      await _refreshIfShown(container, path);
    }
  }
}
