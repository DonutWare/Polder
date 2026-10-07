import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/search.dart";
import "package:polder/providers/polder_api_provider.dart";

final textExtractionStatusProvider = FutureProvider.autoDispose<TextExtractionStatus>((ref) async {
  final status = await ref.watch(polderApiProvider).textExtractionStatus();
  if (status.pending > 0) {
    final refresh = Timer(const Duration(seconds: 5), ref.invalidateSelf);
    ref.onDispose(refresh.cancel);
  }
  return status;
});
