import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";

final fileContentProvider = FutureProvider.autoDispose.family<Uint8List, FileEntry>(
  (ref, entry) => ref.watch(polderApiProvider).downloadBytes(entry.path),
);
