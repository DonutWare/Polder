import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/calendar/widgets/calendar_sidebar.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder_calendar/polder_calendar.dart";

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({this.mode, this.date, this.event, this.occurrence, super.key});

  final CalendarViewMode? mode;
  final DateTime? date;
  final String? event;
  final String? occurrence;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _sidebarWidth = 300.0;

  var _monthOpen = false;
  String? _openedEvent;

  @override
  void initState() {
    super.initState();
    _openRequestedEvent();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _openRequestedEvent();
  }

  void _openRequestedEvent() {
    final requested = widget.event;
    if (requested == null || requested == _openedEvent) return;
    _openedEvent = requested;
    WidgetsBinding.instance.addPostFrameCallback((_) => _openEvent(requested, widget.occurrence));
  }

  Future<void> _openEvent(String requested, String? occurrence) async {
    final source = ref.read(polderCalendarSourceProvider);
    final parts = requested.split("/");
    if (source == null || parts.length != 2) return;
    final [calendarId, eventId] = parts;
    final calendar = CalendarRef(sourceId: source.id, calendarId: calendarId);
    final day = (widget.date ?? DateTime.now()).dateOnly;
    final CalendarEvent? event;
    try {
      final events = await source.events(
        DateTimeRange(start: day.subtract(const Duration(days: 1)), end: day.add(const Duration(days: 2))),
        calendars: {calendar},
      );
      event =
          events.where((event) => event.ref.eventId == eventId && event.ref.recurrenceId == occurrence).firstOrNull ??
          (await source.event(EventRef(calendar: calendar, eventId: eventId))).series;
    } on Exception {
      return;
    }
    if (!mounted) return;
    context.go(AppRoutes.calendarAt(widget.mode ?? CalendarViewMode.day, day));
    await openCalendarEvent(context, event);
  }

  void _navigate(CalendarViewMode mode, DateTime anchor) {
    ref.read(calendarViewModeProvider.notifier).select(mode);
    context.go(AppRoutes.calendarAt(mode, anchor));
  }

  CalendarViewMode _mode(bool phone) =>
      widget.mode ?? ref.watch(calendarViewModeProvider) ?? (phone ? CalendarViewMode.schedule : CalendarViewMode.week);

  void _toggleMonth() => setState(() => _monthOpen = !_monthOpen);

  Future<void> _openAgendas(CalendarViewMode mode, DateTime anchor) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheet) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (sheet, controller) => CalendarSidebar(
        anchor: anchor,
        controller: controller,
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 24),
        onSelectDay: (day) {
          Navigator.pop(sheet);
          _navigate(mode, day);
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final phone = AdaptiveLayout.isPhone(context);
    final single = AdaptiveLayout.isSingle(context);
    final mode = _mode(phone);
    final anchor = (widget.date ?? DateTime.now()).dateOnly;
    final title = CalendarTitle(mode: mode, anchor: anchor);
    final strings = CalendarLocalizations.of(context);

    final page = AppPage(
      title: single ? _MonthToggle(open: _monthOpen, onToggle: _toggleMonth, child: title) : title,
      floatingActionButton: FloatingActionButton(
        tooltip: strings.newEvent,
        onPressed: () => createCalendarEvent(context, day: anchor),
        child: const Icon(IconsaxPlusLinear.add),
      ),
      actions: [
        CalendarPeriodButtons(mode: mode, anchor: anchor, onNavigate: _navigate, showArrows: !phone),
        CalendarViewMenu(mode: mode, compact: phone, onSelected: (mode) => _navigate(mode, anchor)),
        if (single)
          IconButton(
            tooltip: context.localized.calendarManage,
            icon: const Icon(IconsaxPlusLinear.calendar_2),
            onPressed: () => _openAgendas(mode, anchor),
          ),
      ],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (single)
              AnimatedSize(
                duration: AppMotion.spatialDuration,
                curve: AppMotion.spatial,
                alignment: Alignment.topCenter,
                child: _monthOpen
                    ? Card(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          child: MiniMonth(
                            selected: anchor,
                            showHeader: false,
                            showWeekNumbers: true,
                            onSelect: (day) => _navigate(mode, day),
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            Expanded(
              child: CalendarView(
                mode: mode,
                anchor: anchor,
                onNavigate: _navigate,
                onEventTap: (event) => openCalendarEvent(context, event),
                onDayTap: (day) => createCalendarEvent(context, day: day),
                onCreate: (start) => createCalendarEvent(context, start: start),
              ),
            ),
          ],
        ),
      ),
    );
    if (single) return page;

    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _sidebarWidth,
            child: Material(
              color: colors.surfaceContainerLow,
              child: SafeArea(
                right: false,
                child: CalendarSidebar(anchor: anchor, onSelectDay: (day) => _navigate(mode, day)),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: page),
        ],
      ),
    );
  }
}

class _MonthToggle extends StatelessWidget {
  const _MonthToggle({required this.open, required this.onToggle, required this.child});

  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: CalendarLocalizations.of(context).showMonth,
    child: InkWell(
      customBorder: squircle(AppRadius.control),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Flexible(child: child),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: AppMotion.spatialDuration,
              curve: AppMotion.spatial,
              child: const Icon(IconsaxPlusLinear.arrow_down, size: 18),
            ),
          ],
        ),
      ),
    ),
  );
}
