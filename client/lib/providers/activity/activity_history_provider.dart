import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/models/server_event.dart";
import "package:nomad/providers/activity/activity_scope_provider.dart";
import "package:nomad/providers/nomad_api_provider.dart";
import "package:nomad/providers/realtime/events_provider.dart";

class ActivityHistory {
  const ActivityHistory({required this.entries, required this.nextCursor});

  final List<ActivityEntry> entries;
  final int nextCursor;

  bool get hasMore => nextCursor != 0;
}

final activityHistoryProvider = AsyncNotifierProvider.autoDispose
    .family<ActivityHistoryNotifier, ActivityHistory, ActivityScope>(ActivityHistoryNotifier.new);

class ActivityHistoryNotifier extends AsyncNotifier<ActivityHistory> {
  ActivityHistoryNotifier(this.scope);

  final ActivityScope scope;
  var _loadingMore = false;
  var _missedEvents = false;

  @override
  Future<ActivityHistory> build() async {
    final selfId = ref.watch(selfUserIdProvider) ?? 0;
    final client = ref.watch(eventsClientProvider);
    if (client != null) {
      final subscription = client.events.listen((event) {
        switch (event) {
          case ActivityCreatedEvent(:final entry) when scope.includes(entry.userId, selfId: selfId):
            _prepend(entry);
          case DisconnectedEvent():
            _missedEvents = true;
          case ReadyEvent() when _missedEvents:
            _missedEvents = false;
            refresh();
          default:
        }
      });
      ref.onDispose(subscription.cancel);
    }
    return _firstPage();
  }

  Future<ActivityHistory> _firstPage() async {
    final page = await ref.read(nomadApiProvider).activity(scope: scope);
    return ActivityHistory(entries: page.entries, nextCursor: page.nextCursor);
  }

  Future<void> refresh() async {
    final refreshed = await AsyncValue.guard(_firstPage);
    if (ref.mounted) state = refreshed;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref.read(nomadApiProvider).activity(scope: scope, before: current.nextCursor);
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      final known = {for (final entry in latest.entries) entry.id};
      state = AsyncData(
        ActivityHistory(
          entries: [...latest.entries, ...page.entries.where((entry) => !known.contains(entry.id))],
          nextCursor: page.nextCursor,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  void _prepend(ActivityEntry entry) {
    final current = state.value;
    if (current == null || current.entries.any((existing) => existing.id == entry.id)) return;
    state = AsyncData(ActivityHistory(entries: [entry, ...current.entries], nextCursor: current.nextCursor));
  }
}
