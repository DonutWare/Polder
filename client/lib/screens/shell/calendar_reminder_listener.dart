import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:polder/models/calendar_reminder.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder_calendar/polder_calendar.dart";

class CalendarReminderListener extends ConsumerWidget {
  const CalendarReminderListener({required this.child, super.key});

  final Widget child;

  void _show(BuildContext context, CalendarReminder reminder) {
    final localizations = context.localized;
    final start = reminder.allDay
        ? DateTime(reminder.start.year, reminder.start.month, reminder.start.day)
        : reminder.start.toLocal();
    final summary = reminder.summary.trim().isEmpty
        ? CalendarLocalizations.of(context).untitledEvent
        : reminder.summary;
    final message = reminder.allDay
        ? localizations.calendarReminderAllDay(summary, DateFormat.MMMMEEEEd(localeTag(context)).format(start))
        : localizations.calendarReminder(summary, formatTime(context, start));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: localizations.open,
          onPressed: () => context.go(AppRoutes.calendarAt(CalendarViewMode.day, start)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(calendarRemindersProvider, (_, next) {
      if (next case AsyncData(:final value)) _show(context, value);
    });
    return child;
  }
}
