import "package:flutter/foundation.dart";

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

enum RepeatOption {
  daily,
  weekly,
  weekdays,
  monthly,
  yearly;

  RecurrenceRule ruleFor(DateTime start) => switch (this) {
    RepeatOption.daily => const RecurrenceRule(RecurrenceFrequency.daily),
    RepeatOption.weekly => RecurrenceRule(RecurrenceFrequency.weekly, weekdays: {start.weekday}),
    RepeatOption.weekdays => const RecurrenceRule(RecurrenceFrequency.weekly, weekdays: RecurrenceRule.workWeek),
    RepeatOption.monthly => RecurrenceRule(RecurrenceFrequency.monthly, monthDay: start.day),
    RepeatOption.yearly => const RecurrenceRule(RecurrenceFrequency.yearly),
  };

  static RepeatOption? matching(RecurrenceRule rule, DateTime start) {
    if (rule.interval != 1 || rule.count != null || rule.until != null) return null;
    for (final option in values) {
      if (option.ruleFor(start).matches(rule, start)) return option;
    }
    return null;
  }
}

@immutable
class RecurrenceRule {
  const RecurrenceRule(
    this.frequency, {
    this.interval = 1,
    this.weekdays = const {},
    this.monthDay,
    this.count,
    this.until,
  });

  static const workWeek = {DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday};

  static const _dayCodes = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"];

  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weekdays;
  final int? monthDay;
  final int? count;
  final DateTime? until;

  static RecurrenceRule? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = <String, String>{};
    for (final part in value.trim().replaceFirst(RegExp("^RRULE:", caseSensitive: false), "").split(";")) {
      final separator = part.indexOf("=");
      if (separator <= 0) return null;
      parts[part.substring(0, separator).toUpperCase()] = part.substring(separator + 1).toUpperCase();
    }
    final frequency = switch (parts.remove("FREQ")) {
      "DAILY" => RecurrenceFrequency.daily,
      "WEEKLY" => RecurrenceFrequency.weekly,
      "MONTHLY" => RecurrenceFrequency.monthly,
      "YEARLY" => RecurrenceFrequency.yearly,
      _ => null,
    };
    if (frequency == null) return null;
    final interval = int.tryParse(parts.remove("INTERVAL") ?? "1");
    final days = parts.remove("BYDAY")?.split(",").map(_dayCodes.indexOf).toList() ?? const [];
    final monthDay = parts.remove("BYMONTHDAY");
    final count = parts.remove("COUNT");
    final until = parts.remove("UNTIL");
    parts.remove("WKST");
    if (parts.isNotEmpty || interval == null || interval < 1 || days.contains(-1)) return null;
    if (monthDay != null && (int.tryParse(monthDay) ?? 0) <= 0) return null;
    if (count != null && int.tryParse(count) == null) return null;
    final untilDate = until == null ? null : _parseUntil(until);
    if (until != null && untilDate == null) return null;
    return RecurrenceRule(
      frequency,
      interval: interval,
      weekdays: {for (final day in days) day + 1},
      monthDay: monthDay == null ? null : int.parse(monthDay),
      count: count == null ? null : int.parse(count),
      until: untilDate,
    );
  }

  static DateTime? _parseUntil(String value) {
    final match = RegExp(r"^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2})(Z?))?$").firstMatch(value);
    if (match == null) return null;
    final fields = [for (var group = 1; group <= 6; group++) int.parse(match.group(group) ?? "0")];
    if (match.group(4) == null) return DateTime(fields[0], fields[1], fields[2]);
    return match.group(7) == "Z"
        ? DateTime.utc(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5]).toLocal()
        : DateTime(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5]);
  }

  String encode() {
    final days = weekdays.toList()..sort();
    return [
      "FREQ=${frequency.name.toUpperCase()}",
      if (interval != 1) "INTERVAL=$interval",
      if (days.isNotEmpty) "BYDAY=${days.map((day) => _dayCodes[day - 1]).join(",")}",
      if (monthDay != null) "BYMONTHDAY=$monthDay",
      if (count != null) "COUNT=$count",
      if (until case final until?) "UNTIL=${_encodeUntil(until.toUtc())}",
    ].join(";");
  }

  static String _encodeUntil(DateTime until) {
    String two(int value) => value.toString().padLeft(2, "0");
    return "${until.year.toString().padLeft(4, "0")}${two(until.month)}${two(until.day)}"
        "T${two(until.hour)}${two(until.minute)}${two(until.second)}Z";
  }

  bool matches(RecurrenceRule other, DateTime start) =>
      frequency == other.frequency &&
      interval == other.interval &&
      setEquals(_effectiveDays(start), other._effectiveDays(start)) &&
      _effectiveMonthDay(start) == other._effectiveMonthDay(start) &&
      count == other.count &&
      until == other.until;

  Set<int> _effectiveDays(DateTime start) =>
      frequency == RecurrenceFrequency.weekly && weekdays.isEmpty ? {start.weekday} : weekdays;

  int? _effectiveMonthDay(DateTime start) =>
      frequency == RecurrenceFrequency.monthly && monthDay == null && weekdays.isEmpty ? start.day : monthDay;

  @override
  bool operator ==(Object other) => other is RecurrenceRule && encode() == other.encode();

  @override
  int get hashCode => encode().hashCode;
}
