import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/providers/service_providers.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:calendar_views/calendar_views.dart";

final weekStartProvider = NotifierProvider<WeekStartNotifier, int?>(WeekStartNotifier.new);

final deviceWeekLayoutProvider = Provider<WeekLayout>((ref) => deviceWeekLayout());

final weekLayoutProvider = Provider<WeekLayout>(
  (ref) => ref.watch(deviceWeekLayoutProvider).startingOn(ref.watch(weekStartProvider)),
);

class WeekStartNotifier extends Notifier<int?> {
  static const _key = "polder.calendar.weekStart";

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final saved = await _preferences.readJson(_key);
    final day = saved?["firstDay"];
    if (ref.mounted && day is int) state = day;
  }

  Future<void> choose(int? firstDay) async {
    state = firstDay;
    if (firstDay == null) return _preferences.remove(_key);
    await _preferences.writeJson(_key, {"firstDay": firstDay});
  }
}
