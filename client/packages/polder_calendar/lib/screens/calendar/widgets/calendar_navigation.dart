import "dart:async";

import "package:material_ui/material_ui.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_calendar/providers/calendar/calendar_providers.dart";
import "package:polder_calendar/screens/calendar/widgets/calendar_settings.dart";
import "package:polder_calendar/screens/calendar/widgets/calendar_sidebar.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";

DateTime _anchorOf(Uri location) =>
    (DateTime.tryParse(location.queryParameters[CalendarLocations.dateParameter] ?? "") ?? DateTime.now()).dateOnly;

Future<void> _pickDay(BuildContext context, Uri location) async {
  final day = await showCalendarMonthPicker(context, selected: _anchorOf(location));
  if (day != null && context.mounted) _goToDay(context, location, day);
}

void _goToDay(BuildContext context, Uri location, DateTime day) {
  final ref = ProviderScope.containerOf(context, listen: false);
  final mode = switch (location.queryParameters[CalendarLocations.viewParameter]) {
    final slug? => CalendarViewMode.fromSlug(slug),
    null => ref.read(calendarViewModeProvider) ?? CalendarViewMode.week,
  };
  goWithin(context, ref.read(calendarLocationsProvider).dayAt(mode, day), replacing: true);
}

class CalendarNavigationSidebar extends StatelessWidget {
  const CalendarNavigationSidebar({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context) => CalendarSidebar(
    anchor: _anchorOf(location),
    padding: const EdgeInsets.only(top: 4, bottom: 12),
    onSelectDay: (day) => _goToDay(context, location, day),
  );
}

class CalendarNavigationRail extends StatelessWidget {
  const CalendarNavigationRail({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RailTile(
        icon: IconsaxPlusLinear.calendar_1,
        label: CalendarLocalizations.of(context).showMonth,
        onTap: () => unawaited(_pickDay(context, location)),
      ),
      RailTile(
        icon: IconsaxPlusLinear.calendar_2,
        label: context.localized.calendars,
        onTap: () => unawaited(showCalendarAgendas(context)),
      ),
      RailTile(
        icon: IconsaxPlusLinear.setting_2,
        label: context.localized.calendarSettings,
        onTap: () => unawaited(showCalendarSettings(context)),
      ),
    ],
  );
}

class CalendarNavigationSheetItems extends StatelessWidget {
  const CalendarNavigationSheetItems({required this.location, super.key});

  final Uri location;

  void _run(BuildContext context, Future<void> Function(BuildContext context) action) =>
      SideSheetDrawer.of(context).dismissThen((context) => unawaited(action(context)));

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: const Icon(IconsaxPlusLinear.calendar_1),
        title: Text(CalendarLocalizations.of(context).showMonth),
        onTap: () => _run(context, (context) => _pickDay(context, location)),
      ),
      ListTile(
        leading: const Icon(IconsaxPlusLinear.calendar_2),
        title: Text(context.localized.calendars),
        onTap: () => _run(context, showCalendarAgendas),
      ),
      ListTile(
        leading: const Icon(IconsaxPlusLinear.setting_4),
        title: Text(context.localized.calendarSettings),
        onTap: () => _run(context, showCalendarSettings),
      ),
    ],
  );
}
