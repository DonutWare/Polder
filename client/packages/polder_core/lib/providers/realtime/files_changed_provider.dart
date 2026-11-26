import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/server_event.dart";
import "package:polder_core/providers/activity/activity_scope_provider.dart";
import "package:polder_core/providers/realtime/events_provider.dart";

final filesChangedProvider = StreamProvider<List<String>>((ref) {
  final client = ref.watch(eventsClientProvider);
  final selfId = ref.watch(selfUserIdProvider);
  if (client == null || selfId == null) return const Stream.empty();
  return client.events
      .where((event) => event is FilesChangedEvent && event.userId == selfId)
      .cast<FilesChangedEvent>()
      .map((event) => event.dirs);
});
