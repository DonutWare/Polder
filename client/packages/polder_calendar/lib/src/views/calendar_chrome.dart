import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:intl/intl.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";

class CalendarTitle extends StatelessWidget {
  const CalendarTitle({required this.mode, required this.anchor, super.key});

  final CalendarViewMode mode;
  final DateTime anchor;

  String _text(BuildContext context) {
    final locale = localeTag(context);
    if (mode == CalendarViewMode.day) return DateFormat.yMMMMd(locale).format(anchor);
    if (!mode.isTimeGrid) return _month(anchor, locale);
    final range = visibleRange(mode, anchor, firstDayOfWeek: firstDayOfWeek(context));
    final last = range.end.addDays(-1);
    if (range.start.isSameMonth(last)) return _month(range.start, locale);
    final sameYear = range.start.year == last.year;
    final from = (sameYear ? DateFormat.MMM(locale) : DateFormat.yMMM(locale)).format(range.start);
    return "$from – ${DateFormat.yMMM(locale).format(last)}";
  }

  String _month(DateTime month, String locale) =>
      (month.year == DateTime.now().year ? DateFormat.MMMM(locale) : DateFormat.yMMMM(locale)).format(month);

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 220),
    layoutBuilder: (current, previous) =>
        Stack(alignment: AlignmentDirectional.centerStart, children: [...previous, ?current]),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
        child: child,
      ),
    ),
    child: Text(_text(context), key: ValueKey(_text(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

IconData viewModeIcon(CalendarViewMode mode) => switch (mode) {
  CalendarViewMode.schedule => IconsaxPlusLinear.task_square,
  CalendarViewMode.day => IconsaxPlusLinear.calendar_1,
  CalendarViewMode.threeDays => IconsaxPlusLinear.row_horizontal,
  CalendarViewMode.week => IconsaxPlusLinear.calendar_2,
  CalendarViewMode.month => IconsaxPlusLinear.element_3,
};

class CalendarViewMenu extends StatelessWidget {
  const CalendarViewMenu({required this.mode, required this.onSelected, this.compact = false, super.key});

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    return PopupMenuButton<CalendarViewMode>(
      initialValue: mode,
      onSelected: onSelected,
      tooltip: mode.label(strings),
      itemBuilder: (context) => [
        for (final option in CalendarViewMode.values)
          PopupMenuItem(
            value: option,
            child: Row(spacing: 12, children: [Icon(viewModeIcon(option), size: 20), Text(option.label(strings))]),
          ),
      ],
      child: compact
          ? Padding(padding: const EdgeInsets.all(8), child: Icon(viewModeIcon(mode)))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: ShapeDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: CalendarStyle.squircle(
                  CalendarStyle.controlRadius,
                  side: CalendarStyle.tintedSide(theme.colorScheme.secondary),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(viewModeIcon(mode), size: 18, color: theme.colorScheme.onSecondaryContainer),
                  Text(
                    mode.label(strings),
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                  Icon(IconsaxPlusLinear.arrow_down, size: 16, color: theme.colorScheme.onSecondaryContainer),
                ],
              ),
            ),
    );
  }
}

class CalendarPeriodButtons extends ConsumerWidget {
  const CalendarPeriodButtons({
    required this.mode,
    required this.anchor,
    required this.onNavigate,
    this.showArrows = true,
    super.key,
  });

  final CalendarViewMode mode;
  final DateTime anchor;
  final CalendarNavigate onNavigate;
  final bool showArrows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = CalendarLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: strings.today,
          icon: const Icon(IconsaxPlusLinear.calendar_tick),
          onPressed: () {
            ref.read(calendarFocusProvider.notifier).request();
            onNavigate(mode, DateTime.now().dateOnly);
          },
        ),
        if (showArrows) ...[
          IconButton(
            tooltip: strings.previousPeriod,
            icon: const Icon(IconsaxPlusLinear.arrow_left_1),
            onPressed: () => onNavigate(mode, shiftAnchor(mode, anchor, -1)),
          ),
          IconButton(
            tooltip: strings.nextPeriod,
            icon: const Icon(IconsaxPlusLinear.arrow_right_3),
            onPressed: () => onNavigate(mode, shiftAnchor(mode, anchor, 1)),
          ),
        ],
      ],
    );
  }
}

class MiniMonth extends ConsumerStatefulWidget {
  const MiniMonth({
    required this.selected,
    required this.onSelect,
    this.initialMonth,
    this.onMonthChanged,
    this.showHeader = true,
    this.showWeekNumbers = false,
    super.key,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final DateTime? initialMonth;
  final ValueChanged<DateTime>? onMonthChanged;
  final bool showHeader;
  final bool showWeekNumbers;

  @override
  ConsumerState<MiniMonth> createState() => _MiniMonthState();
}

class _MiniMonthState extends ConsumerState<MiniMonth> {
  late DateTime _month = (widget.initialMonth ?? widget.selected).firstOfMonth;
  var _direction = 1;

  @override
  void didUpdateWidget(MiniMonth oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected.isSameMonth(widget.selected)) {
      final month = widget.selected.firstOfMonth;
      _direction = month.isBefore(_month) ? -1 : 1;
      _month = month;
    }
  }

  void _shift(int months) {
    setState(() {
      _direction = months.sign;
      _month = _month.addMonths(months);
    });
    widget.onMonthChanged?.call(_month);
  }

  void _swiped(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 200) _shift(velocity < 0 ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = localeTag(context);
    final weekStart = firstDayOfWeek(context);
    final range = visibleRange(CalendarViewMode.month, _month, firstDayOfWeek: weekStart);
    final days = range.days.toList();
    final colors = ref.watch(calendarColorsProvider);
    final events = ref.watch(rangeEventsProvider(range)).value ?? const [];
    final dots = <DateTime, Color>{};
    for (final event in events) {
      for (final day in daysIn(event.firstDay, event.lastDay.nextDay)) {
        dots.putIfAbsent(day, () => event.colorIn(context, colors));
      }
    }
    final columns = widget.showWeekNumbers ? 8 : 7;
    final muted = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader)
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(DateFormat.yMMMM(locale).format(_month), style: theme.textTheme.titleMedium),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: strings.previousPeriod,
                icon: const Icon(IconsaxPlusLinear.arrow_left_1),
                onPressed: () => _shift(-1),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: strings.nextPeriod,
                icon: const Icon(IconsaxPlusLinear.arrow_right_3),
                onPressed: () => _shift(1),
              ),
            ],
          ),
        GestureDetector(
          onHorizontalDragEnd: _swiped,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey(_month);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: Offset(0.25 * (incoming ? _direction : -_direction), 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: LayoutBuilder(
              key: ValueKey(_month),
              builder: (context, constraints) => GridView.count(
                crossAxisCount: columns,
                childAspectRatio: math.max(1, constraints.maxWidth / columns / 44),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  if (widget.showWeekNumbers) const SizedBox.shrink(),
                  for (final day in days.take(7))
                    Center(child: Text(DateFormat.E(locale).format(day).characters.first.toUpperCase(), style: muted)),
                  for (var index = 0; index < days.length; index++) ...[
                    if (widget.showWeekNumbers && index % 7 == 0)
                      Center(child: Text("${weekNumber(days[index], weekStart)}", style: muted)),
                    _MiniDay(
                      day: days[index],
                      month: _month,
                      selected: widget.selected,
                      dot: dots[days[index]],
                      onTap: widget.onSelect,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniDay extends StatelessWidget {
  const _MiniDay({required this.day, required this.month, required this.selected, required this.onTap, this.dot});

  final DateTime day;
  final DateTime month;
  final DateTime selected;
  final Color? dot;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final picked = day.isSameDay(selected);
    final today = isToday(day);
    final foreground = today
        ? scheme.primary
        : picked
        ? scheme.onSecondaryContainer
        : day.isSameMonth(month)
        ? scheme.onSurface
        : scheme.onSurfaceVariant.withValues(alpha: 0.6);
    return InkResponse(
      onTap: () => onTap(day),
      radius: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: picked || today
                ? ShapeDecoration(
                    color: picked ? scheme.secondaryContainer : CalendarStyle.tint(context, scheme.primary),
                    shape: const CircleBorder(),
                  )
                : null,
            child: Text(
              "${day.day}",
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: today || picked ? FontWeight.w700 : null),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
