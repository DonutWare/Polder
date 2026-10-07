import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/server_log.dart";
import "package:polder/providers/polder_api_provider.dart";

final serverLogsProvider = AsyncNotifierProvider.autoDispose.family<ServerLogsNotifier, ServerLogPage, ServerLogFilter>(
  ServerLogsNotifier.new,
);

class ServerLogsNotifier extends AsyncNotifier<ServerLogPage> {
  ServerLogsNotifier(this.filter);

  static const followInterval = Duration(seconds: 5);

  final ServerLogFilter filter;
  var _loadingMore = false;
  Timer? _followTimer;

  @override
  Future<ServerLogPage> build() {
    ref.onDispose(() => _followTimer?.cancel());
    return ref.watch(polderApiProvider).serverLogs(filter: filter);
  }

  void follow(bool on) {
    _followTimer?.cancel();
    _followTimer = on ? Timer.periodic(followInterval, (_) => fetchNewer()) : null;
    if (on) unawaited(fetchNewer());
  }

  Future<void> refresh() async {
    final refreshed = await AsyncValue.guard(() => ref.read(polderApiProvider).serverLogs(filter: filter));
    if (ref.mounted) state = refreshed;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref.read(polderApiProvider).serverLogs(filter: filter, before: current.nextCursor);
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      final known = {for (final entry in latest.entries) entry.id};
      state = AsyncData(
        latest.copyWith(
          entries: [...latest.entries, ...page.entries.where((entry) => !known.contains(entry.id))],
          nextCursor: page.nextCursor,
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> fetchNewer() async {
    final current = state.value;
    if (current == null) return;
    final ServerLogPage page;
    try {
      page = await ref.read(polderApiProvider).serverLogs(filter: filter);
    } on Exception {
      return;
    }
    if (!ref.mounted) return;
    final latest = state.value ?? current;
    final known = {for (final entry in latest.entries) entry.id};
    final newer = page.entries.takeWhile((entry) => !known.contains(entry.id)).toList();
    if (newer.isEmpty) return;
    state = AsyncData(
      newer.length == page.entries.length && latest.entries.isNotEmpty
          ? page
          : latest.copyWith(entries: [...newer, ...latest.entries]),
    );
  }
}
