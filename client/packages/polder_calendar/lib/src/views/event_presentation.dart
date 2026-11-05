import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_info.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/rrule/recurrence_rule.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";

typedef CalendarNavigate = void Function(CalendarViewMode mode, DateTime anchor);

typedef EventTap = void Function(CalendarEvent event);

final calendarColorsProvider = Provider.autoDispose<Map<CalendarRef, Color?>>(
  (ref) => {
    for (final calendar in ref.watch(calendarListProvider).value ?? const <CalendarInfo>[])
      calendar.ref: calendar.color,
  },
);

extension EventPresentation on CalendarEvent {
  bool get spansDays => allDay || duration >= const Duration(hours: 24);

  DateTime get firstDay => start.dateOnly;

  DateTime get lastDay {
    final endDay = end.dateOnly;
    return end == endDay && end.isAfter(start) ? endDay.addDays(-1) : endDay;
  }

  bool occursOn(DateTime day) => start.isBefore(day.nextDay) && (end.isAfter(day) || start == end && start == day);

  int startMinuteOn(DateTime day) => start.isBefore(day) ? 0 : start.minuteOfDay;

  int endMinuteOn(DateTime day) => end.isBefore(day.nextDay) ? end.minuteOfDay : 24 * 60;

  String titleFor(CalendarLocalizations strings) => busyOnly
      ? strings.busy
      : summary.trim().isEmpty
      ? strings.untitledEvent
      : summary;

  Color colorIn(BuildContext context, Map<CalendarRef, Color?> calendarColors) =>
      calendarColors[calendar] ?? Theme.of(context).colorScheme.primary;
}

extension CalendarViewModeLabel on CalendarViewMode {
  String label(CalendarLocalizations strings) => switch (this) {
    CalendarViewMode.schedule => strings.viewSchedule,
    CalendarViewMode.day => strings.viewDay,
    CalendarViewMode.threeDays => strings.viewThreeDays,
    CalendarViewMode.week => strings.viewWeek,
    CalendarViewMode.month => strings.viewMonth,
  };
}

Color foregroundOn(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : Colors.black87;

String formatTime(BuildContext context, DateTime time) => MaterialLocalizations.of(context)
    .formatTimeOfDay(TimeOfDay.fromDateTime(time), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

String localeTag(BuildContext context) => Localizations.localeOf(context).toLanguageTag();

int firstDayOfWeek(BuildContext context) => MaterialLocalizations.of(context).firstDayOfWeekIndex;

bool isToday(DateTime day) => day.isSameDay(DateTime.now());

String describeWhen(BuildContext context, CalendarEvent event) {
  final locale = localeTag(context);
  final day = DateFormat.MMMMEEEEd(locale);
  if (event.allDay) {
    return event.firstDay == event.lastDay
        ? day.format(event.firstDay)
        : "${DateFormat.MMMd(locale).format(event.firstDay)} – ${DateFormat.MMMd(locale).format(event.lastDay)}";
  }
  final start = formatTime(context, event.start);
  final end = formatTime(context, event.end);
  if (event.start.isSameDay(event.end) || event.end == event.start.dateOnly.nextDay) {
    return "${day.format(event.start)} · $start – $end";
  }
  final short = DateFormat.MMMd(locale);
  return "${short.format(event.start)}, $start – ${short.format(event.end)}, $end";
}

String describeRepeat(BuildContext context, String? rrule, DateTime start) {
  final strings = CalendarLocalizations.of(context);
  final rule = RecurrenceRule.tryParse(rrule);
  if (rule == null) return rrule == null || rrule.trim().isEmpty ? strings.repeatNone : strings.repeatCustom;
  if (RepeatOption.matching(rule, start) == RepeatOption.weekdays) return strings.repeatWeekdays;
  final locale = localeTag(context);
  var text = switch (rule.frequency) {
    RecurrenceFrequency.daily => strings.ruleDaily(rule.interval),
    RecurrenceFrequency.weekly => strings.ruleWeekly(rule.interval),
    RecurrenceFrequency.monthly => strings.ruleMonthly(rule.interval),
    RecurrenceFrequency.yearly => strings.ruleYearly(rule.interval),
  };
  final weekday = DateFormat.EEEE(locale);
  final when = switch (rule.frequency) {
    RecurrenceFrequency.weekly =>
      (rule.weekdays.isEmpty ? [start.weekday] : (rule.weekdays.toList()..sort()))
          .map((day) => weekday.format(start.addDays(day - start.weekday)))
          .join(", "),
    RecurrenceFrequency.monthly when rule.weekdays.isEmpty => strings.monthDay(rule.monthDay ?? start.day),
    RecurrenceFrequency.yearly => DateFormat.MMMMd(locale).format(start),
    _ => null,
  };
  if (when != null) text = strings.ruleOn(text, when);
  if (rule.count case final count?) text = strings.ruleCount(text, count);
  if (rule.until case final until?) text = strings.ruleUntil(text, DateFormat.yMMMd(locale).format(until));
  return text;
}

String describeReminder(BuildContext context, EventReminder reminder, {required bool allDay}) {
  final strings = CalendarLocalizations.of(context);
  if (reminder.at case final at?) {
    return strings.reminderAt("${DateFormat.MMMd(localeTag(context)).format(at)}, ${formatTime(context, at)}");
  }
  final offset = reminder.offsetMinutes ?? 0;
  if (reminder.relativeToEnd) return strings.reminderAt(_offsetLabel(offset));
  if (allDay) {
    final daysBefore = offset >= 0 ? 0 : (-offset + 24 * 60 - 1) ~/ (24 * 60);
    final minuteOfDay = offset + daysBefore * 24 * 60;
    if (minuteOfDay >= 24 * 60) return strings.reminderAt(_offsetLabel(offset));
    final time = formatTime(context, DateTime(2000).add(Duration(minutes: minuteOfDay)));
    return daysBefore == 0 ? strings.reminderOnDay(time) : strings.reminderDaysBefore(daysBefore, time);
  }
  if (offset == 0) return strings.reminderAtStart;
  if (offset > 0) return strings.reminderAt(_offsetLabel(offset));
  final minutes = -offset;
  if (minutes % (7 * 24 * 60) == 0) return strings.reminderWeeks(minutes ~/ (7 * 24 * 60));
  if (minutes % (24 * 60) == 0) return strings.reminderDays(minutes ~/ (24 * 60));
  if (minutes % 60 == 0) return strings.reminderHours(minutes ~/ 60);
  return strings.reminderMinutes(minutes);
}

String _offsetLabel(int minutes) =>
    "${minutes < 0 ? "-" : "+"}${minutes.abs() ~/ 60}:${(minutes.abs() % 60).toString().padLeft(2, "0")}";
