import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/link_preview.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/util/ref_cache.dart";

final linkPreviewProvider = FutureProvider.autoDispose.family<LinkPreview, String>((ref, url) async {
  ref.cacheFor(const Duration(minutes: 30));
  return ref.watch(polderApiProvider).linkPreview(url);
});
