import "package:flutter/material.dart";

import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/month_view.dart";
import "package:polder_calendar/src/views/schedule_view.dart";
import "package:polder_calendar/src/views/time_grid_view.dart";

class CalendarView extends StatelessWidget {
  const CalendarView({
    required this.mode,
    required this.anchor,
    required this.onNavigate,
    this.onEventTap,
    this.onDayTap,
    this.onCreate,
    this.onVisibleMonthChanged,
    this.padding,
    super.key,
  });

  final CalendarViewMode mode;
  final DateTime anchor;
  final CalendarNavigate onNavigate;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<DateTime>? onCreate;
  final ValueChanged<DateTime>? onVisibleMonthChanged;
  final EdgeInsets? padding;

  void _openDay(DateTime day) => onNavigate(CalendarViewMode.day, day);

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 280),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(animation), child: child),
    ),
    child: KeyedSubtree(key: ValueKey(mode == CalendarViewMode.schedule ? anchor : mode), child: _view()),
  );

  Widget _view() {
    if (mode == CalendarViewMode.schedule) {
      return ScheduleView(
        key: ValueKey(anchor),
        anchor: anchor,
        padding: padding,
        onEventTap: onEventTap,
        onDayTap: onDayTap ?? _openDay,
        onVisibleMonthChanged: onVisibleMonthChanged,
      );
    }
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: _PagedView(
        key: ValueKey(mode),
        mode: mode,
        anchor: anchor,
        onNavigate: onNavigate,
        onEventTap: onEventTap,
        onCreate: onCreate,
        onDayTap: onDayTap ?? _openDay,
        onMoreTap: _openDay,
      ),
    );
  }
}

class _PagedView extends StatefulWidget {
  const _PagedView({
    required this.mode,
    required this.anchor,
    required this.onNavigate,
    required this.onDayTap,
    required this.onMoreTap,
    this.onEventTap,
    this.onCreate,
    super.key,
  });

  final CalendarViewMode mode;
  final DateTime anchor;
  final CalendarNavigate onNavigate;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<DateTime> onMoreTap;
  final EventTap? onEventTap;
  final ValueChanged<DateTime>? onCreate;

  @override
  State<_PagedView> createState() => _PagedViewState();
}

class _PagedViewState extends State<_PagedView> {
  static const _origin = 100000;

  late DateTime _base = widget.anchor;
  late final PageController _pages = PageController(initialPage: _origin);
  var _page = _origin;
  var _moving = 0;

  DateTime _anchorAt(int page) => shiftAnchor(widget.mode, _base, page - _origin);

  @override
  void didUpdateWidget(_PagedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final weekStart = firstDayOfWeek(context);
    final target = visibleRange(widget.mode, widget.anchor, firstDayOfWeek: weekStart);
    if (visibleRange(widget.mode, _anchorAt(_page), firstDayOfWeek: weekStart) == target) return;
    final page = _pageShowing(target, weekStart);
    if (page != null && (page - _page).abs() <= 6 && _pages.hasClients) {
      _page = page;
      _quietly(
        () => _pages.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic),
      );
      return;
    }
    _base = widget.anchor;
    _page = _origin;
    if (_pages.hasClients) _quietly(() async => _pages.jumpToPage(_origin));
  }

  int? _pageShowing(VisibleRange target, int weekStart) {
    final current = visibleRange(widget.mode, _anchorAt(_page), firstDayOfWeek: weekStart);
    final steps = widget.mode == CalendarViewMode.month
        ? (widget.anchor.year - _anchorAt(_page).year) * 12 + widget.anchor.month - _anchorAt(_page).month
        : (daysBetween(current.start, target.start) / widget.mode.dayCount).round();
    final page = _page + steps;
    return visibleRange(widget.mode, _anchorAt(page), firstDayOfWeek: weekStart) == target ? page : null;
  }

  void _quietly(Future<void> Function() move) {
    _moving++;
    move().whenComplete(() => _moving--);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _changed(int page) {
    if (_moving > 0) return;
    _page = page;
    widget.onNavigate(widget.mode, _anchorAt(page));
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = firstDayOfWeek(context);
    return PageView.builder(
      controller: _pages,
      allowImplicitScrolling: true,
      onPageChanged: _changed,
      itemBuilder: (context, page) {
        final anchor = _anchorAt(page);
        final range = visibleRange(widget.mode, anchor, firstDayOfWeek: weekStart);
        return widget.mode == CalendarViewMode.month
            ? MonthView(
                month: anchor,
                range: range,
                onEventTap: widget.onEventTap,
                onDayTap: widget.onDayTap,
                onMoreTap: widget.onMoreTap,
              )
            : TimeGridView(
                range: range,
                onEventTap: widget.onEventTap,
                onDayTap: widget.onDayTap,
                onMoreTap: widget.onMoreTap,
                onSlotTap: widget.onCreate,
              );
      },
    );
  }
}
