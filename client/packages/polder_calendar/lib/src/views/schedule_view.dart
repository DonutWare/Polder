import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_tiles.dart";
import "package:polder_calendar/src/views/month_art.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/load_state.dart";

class ScheduleView extends ConsumerStatefulWidget {
  const ScheduleView({required this.anchor, this.onEventTap, this.onDayTap, this.padding, super.key});

  static const _wideWidth = 600.0;
  static const _center = ValueKey("schedule-center");

  final DateTime anchor;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;
  final EdgeInsets? padding;

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  final _scroll = ScrollController();

  DateTime get anchor => widget.anchor;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _focus() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(0, duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
  }

  VisibleRange _after(int index) {
    final month = anchor.firstOfMonth.addMonths(index);
    return VisibleRange(index == 0 ? anchor.dateOnly : month, month.addMonths(1));
  }

  VisibleRange _before(int index) {
    final month = anchor.firstOfMonth.addMonths(-index);
    return VisibleRange(month, index == 0 ? anchor.dateOnly : month.addMonths(1));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(calendarFocusProvider, (_, _) => _focus());
    final padding = widget.padding;
    final onEventTap = widget.onEventTap;
    final onDayTap = widget.onDayTap;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= ScheduleView._wideWidth;
        final horizontal = EdgeInsets.only(left: padding?.left ?? 0, right: padding?.right ?? 0);
        Widget section(VisibleRange range, {bool leading = false}) =>
            _Section(range: range, wide: wide, leading: leading, onEventTap: onEventTap, onDayTap: onDayTap);
        return CustomScrollView(
          controller: _scroll,
          center: ScheduleView._center,
          slivers: [
            SliverPadding(
              padding: horizontal,
              sliver: SliverList.builder(itemBuilder: (context, index) => section(_before(index))),
            ),
            SliverPadding(
              key: ScheduleView._center,
              padding: horizontal + EdgeInsets.only(top: 8, bottom: (padding?.bottom ?? 0) + 96),
              sliver: SliverList.builder(itemBuilder: (context, index) => section(_after(index), leading: index == 0)),
            ),
          ],
        );
      },
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({required this.range, required this.wide, required this.leading, this.onEventTap, this.onDayTap});

  final VisibleRange range;
  final bool wide;
  final bool leading;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (range.dayCount <= 0) return const SizedBox.shrink();
    final value = ref.watch(rangeEventsProvider(range));
    final banner = range.start.day == 1 && !leading;
    if (!value.hasValue) {
      return Column(
        children: [
          if (banner) _MonthBanner(month: range.start),
          if (value.hasError) LoadState(value: value) else const SizedBox(height: 160),
        ],
      );
    }
    final events = value.value!;
    final colors = ref.watch(calendarColorsProvider);
    final weekStart = firstDayOfWeek(context);
    final today = DateTime.now().dateOnly;
    final rows = <Widget>[if (banner) _MonthBanner(month: range.start, empty: events.isEmpty)];
    DateTime? shownWeek;
    for (final day in range.days) {
      final dayEvents = [
        for (final event in events)
          if (event.occursOn(day)) event,
      ];
      final isToday = day == today;
      if (dayEvents.isEmpty && !isToday) continue;
      final week = day.startOfWeek(weekStart);
      if (shownWeek != week && !(leading && shownWeek == null && week == range.start.startOfWeek(weekStart))) {
        rows.add(_WeekHeader(weekStart: week, wide: wide));
      }
      shownWeek = week;
      rows.add(
        _DayGroup(
          day: day,
          events: dayEvents,
          wide: wide,
          colorOf: (event) => event.colorIn(context, colors),
          onEventTap: onEventTap,
          onDayTap: onDayTap,
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

double _dateColumnWidth(bool wide) => wide ? 176 : 68;

class _MonthBanner extends StatelessWidget {
  const _MonthBanner({required this.month, this.empty = false});

  final DateTime month;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const shadow = [Shadow(color: Colors.black38, blurRadius: 8)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 28, 12, 8),
      child: Material(
        shape: CalendarStyle.squircle(CalendarStyle.panelRadius),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: (constraints.maxWidth * 0.2).clamp(112.0, 200.0) + (empty ? 36 : 0),
            child: MonthArt(
              month: month,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black38],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMM(localeTag(context)).format(month),
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, shadows: shadow),
                      ),
                      if (empty)
                        Text(
                          CalendarLocalizations.of(context).nothingPlanned,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, shadows: shadow),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.weekStart, required this.wide});

  final DateTime weekStart;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final format = DateFormat.MMMd(localeTag(context));
    final range = "${format.format(weekStart)} – ${format.format(weekStart.addDays(6))}";
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(_dateColumnWidth(wide), 20, 16, 12),
      child: Text(
        CalendarLocalizations.of(context).weekHeader(weekNumber(weekStart, firstDayOfWeek(context)), range),
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.events,
    required this.wide,
    required this.colorOf,
    this.onEventTap,
    this.onDayTap,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final bool wide;
  final Color Function(CalendarEvent event) colorOf;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final today = day == DateTime.now().dateOnly;
    final tiles = <Widget>[
      for (final event in events)
        _ScheduleTile(event: event, day: day, color: colorOf(event), wide: wide, onTap: onEventTap),
    ];
    if (today) {
      final now = DateTime.now();
      final upcoming = events.indexWhere((event) => !event.allDay && event.start.isAfter(now));
      tiles.insert(upcoming == -1 ? tiles.length : upcoming, const _NowMarker());
      if (events.isEmpty) tiles.insert(0, const _NothingPlanned());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _dateColumnWidth(wide),
            child: _DateLabel(day: day, wide: wide, onTap: onDayTap),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: tiles),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.day, required this.wide, this.onTap});

  final DateTime day;
  final bool wide;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = localeTag(context);
    final today = isToday(day);
    final accent = today ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final numberStyle = theme.textTheme.titleLarge?.copyWith(height: 1);
    final number = today
        ? TodayBadge(
            size: 44,
            child: Text("${day.day}", style: numberStyle?.copyWith(color: theme.colorScheme.primary)),
          )
        : SizedBox(
            width: 44,
            height: 44,
            child: Center(child: Text("${day.day}", style: numberStyle)),
          );
    final weekday = Text(
      (wide ? DateFormat.EEEE(locale) : DateFormat.E(locale)).format(day),
      style: theme.textTheme.labelMedium?.copyWith(color: accent, fontWeight: FontWeight.w600),
    );
    return InkWell(
      customBorder: CalendarStyle.squircle(CalendarStyle.controlRadius),
      onTap: onTap == null ? null : () => onTap!(day),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8, bottom: 4),
        child: wide
            ? Row(
                spacing: 10,
                children: [
                  number,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        weekday,
                        Text(
                          DateFormat.yMMM(locale).format(day),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(children: [number, weekday]),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.event, required this.day, required this.color, required this.wide, this.onTap});

  final CalendarEvent event;
  final DateTime day;
  final Color color;
  final bool wide;
  final EventTap? onTap;

  String? _time(BuildContext context) {
    if (event.allDay) return null;
    final from = event.start.isBefore(day) ? null : formatTime(context, event.start);
    final until = event.end.isAfter(day.nextDay) ? null : formatTime(context, event.end);
    if (from == null && until == null) return null;
    return "${from ?? ""} – ${until ?? ""}".trim();
  }

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final location = event.location?.trim() ?? "";
    final time = _time(context) ?? strings.allDay;
    final title = Text(
      event.titleFor(strings),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(decoration: isDeclined(event) ? TextDecoration.lineThrough : null),
    );
    final details = [
      _Detail(icon: event.allDay ? IconsaxPlusLinear.sun_1 : IconsaxPlusLinear.clock, text: time),
      if (location.isNotEmpty) _Detail(icon: IconsaxPlusLinear.location, text: location),
      if (event.recurring) const Icon(IconsaxPlusLinear.repeat, size: 14),
    ];
    return EventTransition(
      event: event,
      color: color,
      collapse: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: EventSurface(
          color: color,
          event: event,
          radius: CalendarStyle.controlRadius,
          accent: 4,
          declined: isDeclined(event),
          onTap: onTap == null ? null : () => onTap!(event),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
              child: wide
                  ? Row(
                      spacing: 16,
                      children: [
                        SizedBox(width: 140, child: details.first),
                        Expanded(flex: 3, child: title),
                        if (location.isNotEmpty) Flexible(flex: 2, child: details[1]),
                        if (event.recurring) details.last,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        title,
                        Wrap(spacing: 12, runSpacing: 2, children: details),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 14),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _NowMarker extends StatelessWidget {
  const _NowMarker();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NothingPlanned extends StatelessWidget {
  const _NothingPlanned();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = CalendarStyle.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: ShapeDecoration(
        color: style.inset,
        shape: CalendarStyle.squircle(CalendarStyle.controlRadius, side: BorderSide(color: style.border)),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(IconsaxPlusLinear.calendar_tick, size: 18, color: theme.colorScheme.onSurfaceVariant),
          Text(
            CalendarLocalizations.of(context).nothingPlanned,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
