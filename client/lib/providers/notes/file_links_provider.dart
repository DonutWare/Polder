import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_links.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/ref_cache.dart";

final fileLinksProvider = FutureProvider.autoDispose.family<FileLinks, int>(
  (ref, id) => ref.watch(polderApiProvider).fileLinks(id),
);

final filesByIdProvider = FutureProvider.autoDispose.family<Map<int, FileEntry>, String>((ref, key) async {
  ref.cacheFor(const Duration(minutes: 1));
  ref.listen(filesChangedProvider, (_, _) => ref.invalidateSelf());
  final ids = [for (final part in key.split(",")) ?int.tryParse(part)];
  if (ids.isEmpty) return const {};
  return {for (final entry in await ref.watch(polderApiProvider).filesById(ids)) entry.id: entry};
});

String fileIdsKey(Iterable<int> ids) => (ids.toSet().toList()..sort()).join(",");

final fileAtPathProvider = FutureProvider.autoDispose.family<FileEntry?, String>((ref, path) async {
  ref.cacheFor(const Duration(minutes: 1));
  try {
    return await ref.watch(polderApiProvider).stat(path);
  } on NotFoundException {
    return null;
  } on InvalidRequestException {
    return null;
  }
});
