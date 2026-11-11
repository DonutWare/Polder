import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/services/api/api_exceptions.dart";

final fileContentProvider = FutureProvider.autoDispose.family<Uint8List, (FileEntry, FileSpace?)>(
  (ref, request) => switch (request) {
    (final entry, final space?) => ref.watch(fileSpaceApiProvider(space)).download(entry.path),
    (final entry, null) => ownFileContent(ref, entry),
  },
);

Future<Uint8List> ownFileContent(Ref ref, FileEntry entry) async {
  final files = await ref.watch(offlineFilesProvider.future);
  final local = await files.readMatching(entry);
  if (local != null) return local;
  try {
    return await ref.watch(polderApiProvider).downloadBytes(entry.path);
  } on NetworkException {
    final stale = await files.read(entry.path);
    if (stale != null) return stale;
    rethrow;
  }
}
