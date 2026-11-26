import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/link_preview.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/util/ref_cache.dart";

final linkPreviewProvider = FutureProvider.autoDispose.family<LinkPreview, String>((ref, url) async {
  ref.cacheFor(const Duration(minutes: 30));
  return ref.watch(polderApiProvider).linkPreview(url);
});
