import "dart:async";

import "package:material_ui/material_ui.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_calendar/providers/calendar/calendar_reminder_providers.dart";
import "package:polder_calendar/providers/calendar/week_layout_provider.dart";
import "package:polder_calendar_app/routes/calendar_app_router.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/widgets/app/standalone_app.dart";

class CalendarApp extends ConsumerWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekLayout = ref.watch(weekLayoutProvider);
    ref
      ..watch(calendarReminderRefreshProvider)
      ..watch(liveCalendarReminderProvider)
      ..watch(_notificationTapsProvider);
    return StandaloneApp(
      title: (localized) => localized.navCalendar,
      router: ref.watch(calendarRouterProvider),
      localizationsDelegates: const [CalendarLocalizations.delegate],
      wrap: (child) => WeekLayoutScope(layout: weekLayout, child: child),
    );
  }
}

final _notificationTapsProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  void open(String? location) {
    if (location != null) ref.read(calendarRouterProvider).go(location);
  }

  final subscription = service.taps.listen((tap) => open(tap.location));
  unawaited(service.launchTap().then((tap) => open(tap?.location)).catchError((_) {}));
  ref.onDispose(subscription.cancel);
});
