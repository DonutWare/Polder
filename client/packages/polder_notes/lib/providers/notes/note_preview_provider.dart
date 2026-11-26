import "dart:convert";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/services/api/api_exceptions.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder/services/notes/note_preview.dart";
import "package:polder_core/services/offline/offline_files.dart";
import "package:polder_core/util/ref_cache.dart";

typedef NotePreviewKey = ({String path, String hash});

NotePreviewKey notePreviewKey(FileEntry page) => (path: page.path, hash: page.hash.isEmpty ? "${page.rev}" : page.hash);

final notePreviewProvider = FutureProvider.autoDispose.family<NotePreview, NotePreviewKey>((ref, key) async {
  ref.cacheFor(const Duration(minutes: 30));
  final files = await ref.watch(offlineFilesProvider.future);
  final local = await files.read(key.path);
  final row = await files.file(key.path);
  final current = local != null && row != null && (row.unsynced || row.localHash == key.hash);
  final bytes = current ? local : await _download(files, key.path, fallback: local);
  return NotePreview.of(utf8.decode(bytes, allowMalformed: true));
});

Future<Uint8List> _download(OfflineFiles files, String path, {Uint8List? fallback}) async {
  try {
    return await files.download(path, purpose: DownloadPurpose.view);
  } on NetworkException {
    if (fallback != null) return fallback;
    rethrow;
  }
}
