import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/notes/note_preview.dart";
import "package:polder/util/ref_cache.dart";

typedef NotePreviewKey = ({String path, String hash});

NotePreviewKey notePreviewKey(FileEntry page) => (path: page.path, hash: page.hash.isEmpty ? "${page.rev}" : page.hash);

final notePreviewProvider = FutureProvider.autoDispose.family<NotePreview, NotePreviewKey>((ref, key) async {
  ref.cacheFor(const Duration(minutes: 30));
  final bytes = await ref.watch(polderApiProvider).downloadBytes(key.path);
  return NotePreview.of(utf8.decode(bytes, allowMalformed: true));
});
