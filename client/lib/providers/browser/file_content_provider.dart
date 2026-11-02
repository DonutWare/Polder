import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";

final fileContentProvider = FutureProvider.autoDispose.family<Uint8List, (FileEntry, FileSpace?)>(
  (ref, request) => switch (request) {
    (final entry, final space?) => ref.watch(fileSpaceApiProvider(space)).download(entry.path),
    (final entry, null) => ref.watch(polderApiProvider).downloadBytes(entry.path),
  },
);
