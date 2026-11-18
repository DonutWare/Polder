import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/month_view.dart";
import "package:polder_calendar/src/views/schedule_view.dart";
import "package:polder_calendar/src/views/scroll_nudges.dart";
import "package:polder_calendar/src/views/time_grid_view.dart";

class CalendarView extends StatefulWidget {
  const CalendarView({
    required this.mode,
    required this.anchor,
    required this.onNavigate,
    this.onEventTap,
    this.onDayTap,
    this.onCreate,
    this.onVisibleMonthChanged,
    this.padding,
    this.autofocus = false,
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
  final bool autofocus;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const _keyScrollDistance = 48.0;

  final _focus = FocusNode(debugLabel: "CalendarView", skipTraversal: true);
  final _nudges = ScrollNudges();

  @override
  void dispose() {
    _focus.dispose();
    _nudges.dispose();
    super.dispose();
  }

  void _openDay(DateTime day) => widget.onNavigate(CalendarViewMode.day, day);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (_modifierPressed()) return KeyEventResult.ignored;
    final forward = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final handled = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => _page(-forward),
      LogicalKeyboardKey.arrowRight => _page(forward),
      LogicalKeyboardKey.arrowUp => _scroll(-_keyScrollDistance),
      LogicalKeyboardKey.arrowDown => _scroll(_keyScrollDistance),
      _ => false,
    };
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  bool _modifierPressed() {
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isMetaPressed || keyboard.isControlPressed || keyboard.isAltPressed || keyboard.isShiftPressed;
  }

  bool _page(int steps) {
    if (widget.mode == CalendarViewMode.schedule) return false;
    widget.onNavigate(widget.mode, shiftAnchor(widget.mode, widget.anchor, steps));
    return true;
  }

  bool _scroll(double distance) {
    if (widget.mode == CalendarViewMode.month) return false;
    _nudges.nudge(distance);
    return true;
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focus,
    autofocus: widget.autofocus,
    onKeyEvent: _onKey,
    child: Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _focus.requestFocus(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(animation), child: child),
        ),
        child: KeyedSubtree(
          key: ValueKey(widget.mode == CalendarViewMode.schedule ? widget.anchor : widget.mode),
          child: _view(),
        ),
      ),
    ),
  );

  Widget _view() {
    if (widget.mode == CalendarViewMode.schedule) {
      return ScheduleView(
        key: ValueKey(widget.anchor),
        anchor: widget.anchor,
        padding: widget.padding,
        nudges: _nudges,
        onEventTap: widget.onEventTap,
        onDayTap: widget.onDayTap ?? _openDay,
        onVisibleMonthChanged: widget.onVisibleMonthChanged,
      );
    }
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: _PagedView(
        key: ValueKey(widget.mode),
        mode: widget.mode,
        anchor: widget.anchor,
        nudges: _nudges,
        onNavigate: widget.onNavigate,
        onEventTap: widget.onEventTap,
        onCreate: widget.onCreate,
        onDayTap: widget.onDayTap ?? _openDay,
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
    required this.nudges,
    this.onEventTap,
    this.onCreate,
    super.key,
  });

  final CalendarViewMode mode;
  final DateTime anchor;
  final CalendarNavigate onNavigate;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<DateTime> onMoreTap;
  final ScrollNudges nudges;
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
    setState(() => _page = page);
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
                nudges: page == _page ? widget.nudges : null,
              );
      },
    );
  }
}
