import "package:flutter_riverpod/misc.dart";

import "package:polder_calendar/calendar_locations.dart";
import "package:polder_calendar/providers/calendar/calendar_providers.dart";
import "package:polder_calendar_app/routes/calendar_app_routes.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_core/providers/calendar/calendar_source_providers.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";

final List<Override> calendarAppOverrides = [
  polderUiConfigProvider.overrideWithValue(
    const PolderUiConfig(
      afterSignIn: _afterSignIn,
      accountSettings: CalendarAppRoutes.settings,
      upFrom: CalendarAppRoutes.upFrom,
      isTopLevel: CalendarAppRoutes.isTopLevel,
      pageActions: [SettingsButton()],
      menuButton: AccountMenuButton(),
    ),
  ),
  calendarLocationsProvider.overrideWithValue(CalendarAppRoutes.calendar),
  polderCalendarSourcesOverride,
  calendarReminderNoticeOverride,
];

String _afterSignIn(Uri loginLocation) => CalendarAppRoutes.signIn.afterSignIn(loginLocation);
