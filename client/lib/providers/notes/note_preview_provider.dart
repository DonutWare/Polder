import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/services/notes/note_preview.dart";
import "package:polder/util/ref_cache.dart";

final notePreviewProvider = FutureProvider.autoDispose.family<NotePreview, FileEntry>((ref, page) async {
  ref.cacheFor(const Duration(minutes: 5));
  final bytes = await ref.watch(polderApiProvider).downloadBytes(page.path);
  return NotePreview.of(utf8.decode(bytes, allowMalformed: true));
});
