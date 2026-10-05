import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/server_event.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";

final directoryRefresherProvider = Provider<void>((ref) {
  final client = ref.watch(eventsClientProvider);
  final selfId = ref.watch(selfUserIdProvider);
  if (client == null || selfId == null) return;

  final pending = <String, Timer>{};
  Timer? quota;
  final subscription = client.events.listen((event) {
    if (event is! FilesChangedEvent || event.userId != selfId) return;
    for (final directory in event.dirs) {
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
    subscription.cancel();
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
