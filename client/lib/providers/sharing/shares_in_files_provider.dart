import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/polder_api_provider.dart";

final sharesInFilesProvider = AsyncNotifierProvider<SharesInFilesNotifier, bool>(SharesInFilesNotifier.new);

class SharesInFilesNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(polderApiProvider).showsSharesInFiles();

  Future<void> setShown(bool shown) async {
    state = AsyncData(await ref.read(polderApiProvider).setShowsSharesInFiles(shown));
    ref.invalidate(directoryProvider);
  }
}
