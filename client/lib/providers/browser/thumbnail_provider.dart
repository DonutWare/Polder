import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/thumbnail_request.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/util/ref_cache.dart";

final thumbnailProvider = FutureProvider.autoDispose.family<Uint8List?, ThumbnailRequest>((ref, request) async {
  ref.cacheFor(const Duration(minutes: 5));
  final api = ref.watch(polderApiProvider);
  return switch (request) {
    FileThumbnailRequest(:final path, :final size) => api.preview(path, size: size),
    TrashThumbnailRequest(:final itemId, :final size) => api.trashPreview(itemId, size: size),
  };
});
