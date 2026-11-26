import "dart:async";

import "package:flutter/material.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_calendar/providers/calendar/calendar_providers.dart";
import "package:polder_calendar/screens/calendar/widgets/calendar_settings.dart";
import "package:polder_calendar/screens/calendar/widgets/calendar_sidebar.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";

DateTime _anchorOf(Uri location) =>
    (DateTime.tryParse(location.queryParameters[CalendarLocations.dateParameter] ?? "") ?? DateTime.now()).dateOnly;

void _goToDay(BuildContext context, WidgetRef ref, Uri location, DateTime day) {
  final mode = switch (location.queryParameters[CalendarLocations.viewParameter]) {
    final slug? => CalendarViewMode.fromSlug(slug),
    null => ref.read(calendarViewModeProvider) ?? CalendarViewMode.week,
  };
  goWithin(context, ref.read(calendarLocationsProvider).dayAt(mode, day), replacing: true);
}

class CalendarNavigationSidebar extends ConsumerWidget {
  const CalendarNavigationSidebar({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CalendarSidebar(
    anchor: _anchorOf(location),
    padding: const EdgeInsets.only(top: 4, bottom: 12),
    onSelectDay: (day) => _goToDay(context, ref, location, day),
  );
}

class CalendarNavigationRail extends ConsumerWidget {
  const CalendarNavigationRail({required this.location, super.key});

  final Uri location;

  Future<void> _pickDay(BuildContext context, WidgetRef ref) async {
    final day = await showCalendarMonthPicker(context, selected: _anchorOf(location));
    if (day != null && context.mounted) _goToDay(context, ref, location, day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      RailTile(
        icon: IconsaxPlusLinear.calendar_1,
        label: CalendarLocalizations.of(context).showMonth,
        onTap: () => unawaited(_pickDay(context, ref)),
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
