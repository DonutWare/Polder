import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/calendar.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/util/guarded_refresh.dart";

final calendarsProvider = FutureProvider.autoDispose<List<CalendarSummary>>(
  (ref) => ref.watch(polderApiProvider).calendars(),
);

final calendarFeedsProvider = AsyncNotifierProvider.autoDispose.family<CalendarFeedsNotifier, List<CalendarFeed>, int>(
  CalendarFeedsNotifier.new,
);

class CalendarFeedsNotifier extends AsyncNotifier<List<CalendarFeed>> with GuardedRefresh {
  CalendarFeedsNotifier(this.calendarId);

  final int calendarId;

  @override
  Future<List<CalendarFeed>> build() => ref.watch(polderApiProvider).calendarFeeds(calendarId);

  Future<void> refresh() => refreshWith(() => ref.read(polderApiProvider).calendarFeeds(calendarId));

  Future<CreatedCalendarFeed> create({required CalendarFeedMode mode, String? name}) async {
    final created = await ref.read(polderApiProvider).createCalendarFeed(calendarId, mode: mode, name: name);
    state = AsyncData([...?state.value, created.feed]);
    return created;
  }

  Future<void> revoke(CalendarFeed feed) async {
    await ref.read(polderApiProvider).deleteCalendarFeed(calendarId, feed.id);
    state = AsyncData([...?state.value?.where((existing) => existing.id != feed.id)]);
  }
}
