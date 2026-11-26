import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/providers/calendar/week_layout_provider.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/util/localization_helper.dart";

Future<void> showCalendarSettings(BuildContext context) {
  if (AdaptiveLayout.isPhone(context)) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => const SafeArea(child: CalendarSettings(showTitle: true)),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.localized.calendarSettings),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: const SizedBox(width: 440, child: CalendarSettings()),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.localized.done))],
    ),
  );
}

class CalendarSettings extends StatelessWidget {
  const CalendarSettings({this.showTitle = false, super.key});

  final bool showTitle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (showTitle)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Text(context.localized.calendarSettings, style: Theme.of(context).textTheme.titleLarge),
        ),
      const _WeekStartTile(),
    ],
  );
}

class _WeekStartTile extends ConsumerWidget {
  const _WeekStartTile();

  static const _choices = [DateTime.monday, 0, DateTime.saturday];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final chosen = ref.watch(weekStartProvider);
    final regional = ref.watch(deviceWeekLayoutProvider).firstDay;
    final format = DateFormat.EEEE(context.localeName);
    String dayName(int day) => format.format(DateTime(2024, 1, 7 + day));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: const Icon(IconsaxPlusLinear.calendar_1),
      title: Text(localized.firstDayOfWeek),
      trailing: DropdownButton<int?>(
        value: chosen,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        onChanged: (day) => ref.read(weekStartProvider.notifier).choose(day),
        items: [
          DropdownMenuItem(value: null, child: Text(localized.firstDayOfWeekRegional(dayName(regional)))),
          for (final day in _choices) DropdownMenuItem(value: day, child: Text(dayName(day))),
        ],
      ),
    );
  }
}
