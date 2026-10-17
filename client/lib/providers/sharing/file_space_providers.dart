import "dart:async";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/public_link_session_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/services/sharing/file_space_api.dart";
import "package:polder/util/guarded_refresh.dart";
import "package:polder/util/ref_cache.dart";
import "package:polder/util/remote_path.dart";

final fileSpaceApiProvider = Provider.autoDispose.family<FileSpaceApi, FileSpace>(
  (ref, space) => switch (space) {
    ShareSpace(:final shareId) => ShareSpaceApi(ref.watch(polderApiProvider), shareId),
    final LinkSpace link => LinkSpaceApi(
      ref.watch(serverPolderApiProvider(link.serverUrl)),
      link.code,
      ref.watch(publicLinkSessionProvider(link).notifier).token,
    ),
  },
);

final spaceCapabilitiesProvider = Provider.autoDispose.family<SpaceCapabilities, FileSpace>(
  (ref, space) => switch (space) {
    ShareSpace(:final shareId) => switch (ref.watch(incomingShareProvider(shareId))?.permissions) {
      final permissions? => SpaceCapabilities(
        canCreate: permissions.create,
        canEdit: permissions.edit,
        canDelete: permissions.delete,
        canUpload: permissions.create,
      ),
      null => const SpaceCapabilities(),
    },
    final LinkSpace link => switch (ref.watch(publicLinkSessionProvider(link)).value?.shownInfo.permissions) {
      final permissions? => SpaceCapabilities(canDownload: permissions.download, canUpload: permissions.upload),
      null => const SpaceCapabilities(canDownload: false),
    },
  },
);

final spaceThumbnailProvider = FutureProvider.autoDispose.family<Uint8List?, (SpaceLocation, int)>((
  ref,
  request,
) async {
  ref.cacheFor(const Duration(minutes: 5));
  final (location, size) = request;
  return ref.watch(fileSpaceApiProvider(location.space)).preview(location.path, size: size);
});

final spaceDirectoryProvider = AsyncNotifierProvider.autoDispose
    .family<SpaceDirectoryNotifier, DirectoryListing, SpaceLocation>(SpaceDirectoryNotifier.new);

class SpaceDirectoryNotifier extends AsyncNotifier<DirectoryListing> with GuardedRefresh {
  SpaceDirectoryNotifier(this.location);

  final SpaceLocation location;

  FileSpaceApi get _api => ref.read(fileSpaceApiProvider(location.space));

  String get path => location.path;

  @override
  Future<DirectoryListing> build() => _fetch(ref.watch(fileSpaceApiProvider(location.space)));

  Future<void> refresh() => refreshWith(() => _fetch(_api));

  Future<DirectoryListing> _fetch(FileSpaceApi api) => api.list(path);

  Future<void> createFolder(String name) => _mutate(() => _api.mkdir(RemotePath.join(path, name)));

  Future<void> rename(FileEntry entry, String newName) =>
      _mutate(() => _api.move(from: entry.path, to: RemotePath.join(path, newName), baseRev: entry.rev));

  Future<void> delete(FileEntry entry) => _mutate(() => _api.delete(entry.path, baseRev: entry.rev));

  Future<void> _mutate(Future<Object?> Function() action) async {
    try {
      await action();
    } finally {
      if (ref.mounted) await refresh();
    }
  }
}
