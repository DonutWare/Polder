import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/layout/day_span_layout.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/event_tiles.dart";
import "package:polder_calendar/src/views/load_state.dart";
import "package:polder_calendar/src/views/time_grid_view.dart";

class MonthView extends ConsumerWidget {
  const MonthView({
    required this.month,
    required this.range,
    this.onEventTap,
    this.onDayTap,
    this.onMoreTap,
    super.key,
  });

  final DateTime month;
  final VisibleRange range;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<DateTime>? onMoreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(rangeEventsProvider(range));
    final events = value.value ?? const <CalendarEvent>[];
    final colors = ref.watch(calendarColorsProvider);
    final weekday = DateFormat.E(localeTag(context));
    final theme = Theme.of(context);
    return CalendarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final day in range.days.take(7))
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      weekday.format(day).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          LoadState(value: value),
          for (var week = 0; week < range.dayCount ~/ 7; week++)
            Expanded(
              child: _WeekRow(
                start: range.start.addDays(week * 7),
                month: month,
                events: events,
                colors: colors,
                onEventTap: onEventTap,
                onDayTap: onDayTap,
                onMoreTap: onMoreTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.start,
    required this.month,
    required this.events,
    required this.colors,
    this.onEventTap,
    this.onDayTap,
    this.onMoreTap,
  });

  static const headerHeight = 32.0;
  static const laneHeight = 20.0;

  final DateTime start;
  final DateTime month;
  final List<CalendarEvent> events;
  final Map<CalendarRef, Color?> colors;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<DateTime>? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final end = start.addDays(7);
    final days = daysIn(start, end).toList();
    final row = layoutDaySpans(
      [
        for (final event in events)
          if (event.start.isBefore(end) && !event.lastDay.isBefore(start))
            DaySpan(event, daysBetween(start, event.firstDay), daysBetween(start, event.lastDay)),
      ],
      columns: 7,
      tieBreak: (a, b) => a.spansDays == b.spansDays ? a.start.compareTo(b.start) : (a.spansDays ? -1 : 1),
    );
    final strings = CalendarLocalizations.of(context);
    final lines = CalendarStyle.of(context).border;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / 7;
        final capacity = math.max(0, ((constraints.maxHeight - headerHeight - 2) / laneHeight).floor());
        final overflow = row.laneCount > capacity;
        final shownLanes = overflow ? math.max(0, capacity - 1) : capacity;
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final day in days)
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: lines),
                          left: day == days.first ? BorderSide.none : BorderSide(color: lines),
                        ),
                      ),
                      child: InkWell(
                        onTap: onDayTap == null ? null : () => onDayTap!(day),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: DayNumber(
                              day: day,
                              size: 26,
                              style: Theme.of(context).textTheme.labelMedium,
                              muted: !day.isSameMonth(month),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            for (final span in row.visible(shownLanes))
              Positioned(
                left: span.firstColumn * width + 2,
                width: span.length * width - 4,
                top: headerHeight + span.lane * laneHeight,
                height: laneHeight - 2,
                child: EventBar(
                  event: span.item,
                  color: span.item.colorIn(context, colors),
                  filled: span.item.spansDays,
                  onTap: onEventTap,
                ),
              ),
            if (overflow)
              for (var column = 0; column < 7; column++)
                if (row.hiddenAt(column, shownLanes) case final hidden when hidden > 0)
                  Positioned(
                    left: column * width + 2,
                    width: width - 4,
                    top: headerHeight + shownLanes * laneHeight,
                    height: laneHeight - 2,
                    child: InkWell(
                      customBorder: CalendarStyle.squircle(CalendarStyle.tagRadius / 2),
                      onTap: onMoreTap == null ? null : () => onMoreTap!(days[column]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          strings.moreEvents(hidden),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
