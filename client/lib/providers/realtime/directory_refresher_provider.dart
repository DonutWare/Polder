import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";

final directoryRefresherProvider = Provider<void>((ref) {
  final pending = <String, Timer>{};
  Timer? quota;
  ref.listen(filesChangedProvider, (_, next) {
    for (final directory in next.value ?? const <String>[]) {
      pending[directory]?.cancel();
      pending[directory] = Timer(DirectoryRefresher.debounce, () {
        pending.remove(directory);
        if (ref.exists(directoryProvider(directory))) {
          unawaited(ref.read(directoryProvider(directory).notifier).refresh());
        }
      });
    }
    quota ??= Timer(DirectoryRefresher.quotaInterval, () {
      quota = null;
      ref.invalidate(currentUserProvider);
    });
  });
  ref.onDispose(() {
    for (final timer in pending.values) {
      timer.cancel();
    }
    quota?.cancel();
  });
});

abstract final class DirectoryRefresher {
  static const debounce = Duration(milliseconds: 300);
  static const quotaInterval = Duration(seconds: 2);
}
