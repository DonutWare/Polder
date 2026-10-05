import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/file_entry.dart";
import "package:nomad/providers/nomad_api_provider.dart";

final fileContentProvider = FutureProvider.autoDispose.family<Uint8List, FileEntry>(
  (ref, entry) => ref.watch(nomadApiProvider).downloadBytes(entry.path),
);
