import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/layout/day_span_layout.dart";
import "package:polder_calendar/src/layout/time_grid_layout.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/event_tiles.dart";
import "package:polder_calendar/src/views/load_state.dart";

class TimeGridView extends ConsumerStatefulWidget {
  const TimeGridView({
    required this.range,
    this.hourHeight = 48,
    this.onEventTap,
    this.onDayTap,
    this.onMoreTap,
    this.onSlotTap,
    super.key,
  });

  static const gutterWidth = 56.0;

  final VisibleRange range;
  final double hourHeight;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<DateTime>? onMoreTap;
  final ValueChanged<DateTime>? onSlotTap;

  @override
  ConsumerState<TimeGridView> createState() => _TimeGridViewState();
}

class _TimeGridViewState extends ConsumerState<TimeGridView> {
  late final ScrollController _scroll;
  late final Timer _clock;
  var _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    final startHour = widget.range.contains(_now) ? math.max(0, _now.hour - 1) : 8;
    _scroll = ScrollController(initialScrollOffset: startHour * widget.hourHeight);
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _clock.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _focus() {
    if (!_scroll.hasClients || !widget.range.contains(DateTime.now())) return;
    final target = math.max(0, DateTime.now().hour - 1) * widget.hourHeight;
    _scroll.animateTo(
      math.min(target, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(calendarFocusProvider, (_, _) => _focus());
    final value = ref.watch(rangeEventsProvider(widget.range));
    final events = value.value ?? const <CalendarEvent>[];
    final colors = ref.watch(calendarColorsProvider);
    final days = widget.range.days.toList();
    final divider = CalendarStyle.of(context).border;
    return CalendarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DayHeaders(days: days, onDayTap: widget.onDayTap),
          _AllDayLane(
            days: days,
            events: [
              for (final event in events)
                if (event.spansDays) event,
            ],
            colors: colors,
            onEventTap: widget.onEventTap,
            onMoreTap: widget.onMoreTap,
          ),
          LoadState(value: value),
          Divider(height: 1, color: divider),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: SizedBox(
                height: 24 * widget.hourHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HourGutter(hourHeight: widget.hourHeight),
                    for (final day in days)
                      Expanded(
                        child: _DayColumn(
                          day: day,
                          now: _now,
                          hourHeight: widget.hourHeight,
                          events: [
                            for (final event in events)
                              if (!event.spansDays && event.occursOn(day)) event,
                          ],
                          colors: colors,
                          onEventTap: widget.onEventTap,
                          onSlotTap: widget.onSlotTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeaders extends StatelessWidget {
  const _DayHeaders({required this.days, this.onDayTap});

  final List<DateTime> days;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekday = DateFormat.E(localeTag(context));
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: TimeGridView.gutterWidth),
          for (final day in days)
            Expanded(
              child: InkWell(
                customBorder: CalendarStyle.squircle(CalendarStyle.controlRadius),
                onTap: onDayTap == null ? null : () => onDayTap!(day),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Text(
                        weekday.format(day).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isToday(day) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      DayNumber(day: day, size: 36, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DayNumber extends StatelessWidget {
  const DayNumber({required this.day, required this.size, this.style, this.muted = false, super.key});

  final DateTime day;
  final double size;
  final TextStyle? style;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = style ?? const TextStyle();
    if (isToday(day)) {
      return TodayBadge(
        size: size,
        child: Text(
          "${day.day}",
          style: base.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
        ),
      );
    }
    final color = muted ? colors.onSurfaceVariant.withValues(alpha: 0.55) : colors.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text("${day.day}", style: base.copyWith(color: color)),
      ),
    );
  }
}

class _AllDayLane extends StatelessWidget {
  const _AllDayLane({required this.days, required this.events, required this.colors, this.onEventTap, this.onMoreTap});

  static const laneHeight = 24.0;
  static const maxLanes = 3;

  final List<DateTime> days;
  final List<CalendarEvent> events;
  final Map<CalendarRef, Color?> colors;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final first = days.first;
    final row = layoutDaySpans([
      for (final event in events) DaySpan(event, daysBetween(first, event.firstDay), daysBetween(first, event.lastDay)),
    ], columns: days.length);
    final overflow = row.laneCount > maxLanes;
    final shownLanes = overflow ? maxLanes - 1 : row.laneCount;
    final lanes = overflow ? maxLanes : row.laneCount;
    if (lanes == 0) return const SizedBox(height: 4);
    return SizedBox(
      height: lanes * laneHeight + 4,
      child: Row(
        children: [
          SizedBox(
            width: TimeGridView.gutterWidth,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8, top: 4),
                child: Text(strings.allDay, style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth / days.length;
                return Stack(
                  children: [
                    for (final span in row.visible(shownLanes))
                      Positioned(
                        left: span.firstColumn * width + 1,
                        width: span.length * width - 2,
                        top: span.lane * laneHeight + 2,
                        height: laneHeight - 2,
                        child: EventBar(event: span.item, color: span.item.colorIn(context, colors), onTap: onEventTap),
                      ),
                    if (overflow)
                      for (var column = 0; column < days.length; column++)
                        if (row.hiddenAt(column, shownLanes) case final hidden when hidden > 0)
                          Positioned(
                            left: column * width,
                            width: width,
                            top: shownLanes * laneHeight + 2,
                            height: laneHeight - 2,
                            child: TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                              onPressed: onMoreTap == null ? null : () => onMoreTap!(days[column]),
                              child: Text(strings.moreEvents(hidden), style: Theme.of(context).textTheme.labelSmall),
                            ),
                          ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourGutter extends StatelessWidget {
  const _HourGutter({required this.hourHeight});

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final reference = DateTime(2000);
    final hourLabel = MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm() : DateFormat.j(localeTag(context));
    return SizedBox(
      width: TimeGridView.gutterWidth,
      child: Stack(
        children: [
          for (var hour = 1; hour < 24; hour++)
            Positioned(
              top: hour * hourHeight - 7,
              right: 8,
              child: Text(hourLabel.format(reference.add(Duration(hours: hour))), style: style),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.now,
    required this.hourHeight,
    required this.events,
    required this.colors,
    this.onEventTap,
    this.onSlotTap,
  });

  final DateTime day;
  final DateTime now;
  final double hourHeight;
  final List<CalendarEvent> events;
  final Map<CalendarRef, Color?> colors;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onSlotTap;

  double _offset(int minutes) => minutes / 60 * hourHeight;

  DateTime _slotAt(double y) {
    final minutes = (y / hourHeight * 60).clamp(0, 23 * 60 + 30) ~/ 30 * 30;
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = CalendarStyle.of(context).border;
    final placed = layoutTimedSlots([
      for (final event in events) TimedSlot(event, event.startMinuteOn(day), event.endMinuteOn(day)),
    ]);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: lines)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - 4;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: onSlotTap == null ? null : (details) => onSlotTap!(_slotAt(details.localPosition.dy)),
                  child: CustomPaint(painter: _HourLines(hourHeight, lines)),
                ),
              ),
              for (final slot in placed)
                Positioned(
                  top: _offset(slot.startMinute),
                  height: math.max(_offset(slot.endMinute - slot.startMinute), 18) - 2,
                  left: slot.left * width + 2,
                  width: slot.width * width - 1,
                  child: EventBlock(event: slot.item, color: slot.item.colorIn(context, colors), onTap: onEventTap),
                ),
              if (day.isSameDay(now))
                Positioned(
                  top: _offset(now.minuteOfDay) - 4,
                  left: -4,
                  right: 0,
                  child: _NowLine(color: scheme.primary),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NowLine extends StatelessWidget {
  const _NowLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 8,
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
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
  );
}

class _HourLines extends CustomPainter {
  _HourLines(this.hourHeight, this.color);

  final double hourHeight;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var hour = 1; hour < 24; hour++) {
      final y = hour * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_HourLines oldDelegate) => oldDelegate.hourHeight != hourHeight || oldDelegate.color != color;
}
