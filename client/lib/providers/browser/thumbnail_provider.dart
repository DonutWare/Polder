import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/thumbnail_request.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/util/ref_cache.dart";

final thumbnailProvider = FutureProvider.autoDispose.family<Uint8List?, ThumbnailRequest>((ref, request) async {
  ref.cacheFor(const Duration(minutes: 5));
  final api = ref.watch(nomadApiProvider);
  return switch (request) {
    FileThumbnailRequest(:final path, :final size) => api.preview(path, size: size),
    TrashThumbnailRequest(:final itemId, :final size) => api.trashPreview(itemId, size: size),
  };
});
