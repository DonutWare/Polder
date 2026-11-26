import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/sharing.dart";
import "package:polder_core/providers/polder_api_provider.dart";

final shareTargetSearchProvider = FutureProvider.autoDispose.family<ShareTargets, String>((ref, query) async {
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (cancelled) return const ShareTargets();
  return ref.watch(polderApiProvider).searchShareTargets(query);
});
