import "package:flutter/widgets.dart";

@immutable
class WeekLayout {
  const WeekLayout({required this.firstDay, required this.weekend});

  factory WeekLayout.forRegion(String? countryCode) {
    final region = countryCode?.toUpperCase();
    return WeekLayout(firstDay: _firstDayIn(region), weekend: _weekendIn(region));
  }

  final int firstDay;
  final Set<int> weekend;

  bool isWeekend(DateTime day) => weekend.contains(day.weekday);

  WeekLayout startingOn(int? firstDay) =>
      firstDay == null ? this : WeekLayout(firstDay: firstDay % 7, weekend: weekend);

  static const _sundayStart = {
    "AG", "AS", "BD", "BR", "BS", "BT", "BW", "BZ", "CA", "CN", "CO", "DM", "DO", "ET", "GT", "GU", "HK", "HN", //
    "ID", "IL", "IN", "JM", "JP", "KE", "KH", "KR", "LA", "MH", "MM", "MO", "MT", "MX", "MZ", "NI", "NP", "PA", //
    "PE", "PH", "PK", "PR", "PT", "PY", "SA", "SG", "SV", "TH", "TT", "TW", "UM", "US", "VE", "VI", "WS", "YE", //
    "ZA", "ZW",
  };

  static const _saturdayStart = {
    "AE", "AF", "BH", "DJ", "DZ", "EG", "IQ", "IR", "JO", "KW", "LY", "OM", "QA", "SD", "SY", //
  };

  static const _fridayStart = {"MV"};

  static const _fridaySaturdayWeekend = {
    "AE", "BH", "DZ", "EG", "IL", "IQ", "JO", "KW", "LY", "OM", "QA", "SA", "SD", "SY", "YE", //
  };

  static const _sundayOnlyWeekend = {"IN", "UG"};

  static int _firstDayIn(String? region) => switch (region) {
    final region? when _sundayStart.contains(region) => 0,
    final region? when _saturdayStart.contains(region) => 6,
    final region? when _fridayStart.contains(region) => 5,
    _ => 1,
  };

  static Set<int> _weekendIn(String? region) => switch (region) {
    final region? when _fridaySaturdayWeekend.contains(region) => const {DateTime.friday, DateTime.saturday},
    final region? when _sundayOnlyWeekend.contains(region) => const {DateTime.sunday},
    "IR" => const {DateTime.friday},
    "AF" => const {DateTime.thursday, DateTime.friday},
    _ => const {DateTime.saturday, DateTime.sunday},
  };

  @override
  bool operator ==(Object other) =>
      other is WeekLayout &&
      other.firstDay == firstDay &&
      other.weekend.length == weekend.length &&
      other.weekend.containsAll(weekend);

  @override
  int get hashCode => Object.hash(firstDay, Object.hashAllUnordered(weekend));
}

class WeekLayoutScope extends InheritedWidget {
  const WeekLayoutScope({required this.layout, required super.child, super.key});

  final WeekLayout layout;

  static WeekLayout of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WeekLayoutScope>()?.layout ?? deviceWeekLayout();

  @override
  bool updateShouldNotify(WeekLayoutScope oldWidget) => layout != oldWidget.layout;
}

WeekLayout deviceWeekLayout() => WeekLayout.forRegion(WidgetsBinding.instance.platformDispatcher.locale.countryCode);
