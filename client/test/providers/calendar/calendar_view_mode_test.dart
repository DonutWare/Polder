import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder_calendar/polder_calendar.dart";

import "../../support/provider_harness.dart";

void main() {
  Future<CalendarViewMode?> settled(ProviderHarness harness) async {
    harness.container.read(calendarViewModeProvider);
    await pumpEventQueue();
    return harness.container.read(calendarViewModeProvider);
  }

  test("has no view until one is chosen", () async {
    final harness = ProviderHarness();
    addTearDown(harness.dispose);

    expect(await settled(harness), isNull);
  });

  test("remembers the last chosen view across launches", () async {
    final preferences = InMemoryPreferencesStore();
    final first = ProviderHarness(preferences: preferences);
    await settled(first);
    await first.container.read(calendarViewModeProvider.notifier).select(CalendarViewMode.month);
    first.dispose();

    final second = ProviderHarness(preferences: preferences);
    addTearDown(second.dispose);

    expect(await settled(second), CalendarViewMode.month);
  });
}
