import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_calendar/screens/calendar/calendar_screen.dart";
import "package:polder_calendar/screens/calendar/widgets/calendar_navigation.dart";
import "package:polder_calendar/screens/settings/widgets/calendars_group.dart";
import "package:polder_calendar/screens/settings/widgets/reminder_settings_group.dart";
import "package:polder_calendar_app/routes/calendar_app_routes.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/routes/standalone_router.dart";

final calendarRouterProvider = Provider<GoRouter>(
  (ref) => createStandaloneRouter(
    ref,
    signIn: CalendarAppRoutes.signIn,
    settings: CalendarAppRoutes.settings,
    title: (context) => AppLocalizations.of(context).navCalendar,
    home: (location) => CalendarScreen.at(location, showSidebar: false),
    sidebar: (location) => CalendarNavigationSidebar(location: location),
    rail: (location) => CalendarNavigationRail(location: location),
    settingsGroups: const [ReminderSettingsGroup(), CalendarsGroup()],
  ),
);
