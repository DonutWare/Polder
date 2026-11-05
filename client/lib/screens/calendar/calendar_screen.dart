import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/app_checkbox.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder_calendar/polder_calendar.dart";

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({this.mode, this.date, super.key});

  final CalendarViewMode? mode;
  final DateTime? date;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _sidebarWidth = 300.0;

  var _monthOpen = false;

  void _navigate(CalendarViewMode mode, DateTime anchor) {
    ref.read(calendarViewModeProvider.notifier).select(mode);
    context.go(AppRoutes.calendarAt(mode, anchor));
  }

  CalendarViewMode _mode(bool phone) =>
      widget.mode ?? ref.watch(calendarViewModeProvider) ?? (phone ? CalendarViewMode.schedule : CalendarViewMode.week);

  void _toggleMonth() => setState(() => _monthOpen = !_monthOpen);

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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MiniMonth(
                                selected: anchor,
                                showHeader: false,
                                showWeekNumbers: true,
                                onSelect: (day) => _navigate(mode, day),
                              ),
                              const _CalendarList(onlyWhenSeveral: true),
                            ],
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
                child: ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: MiniMonth(selected: anchor, onSelect: (day) => _navigate(mode, day)),
                      ),
                    ),
                    const _CalendarList(),
                  ],
                ),
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

class _CalendarList extends ConsumerWidget {
  const _CalendarList({this.onlyWhenSeveral = false});

  final bool onlyWhenSeveral;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendars = ref.watch(calendarListProvider).value ?? const <CalendarInfo>[];
    if (calendars.isEmpty || onlyWhenSeveral && calendars.length < 2) return const SizedBox.shrink();
    final hidden = ref.watch(hiddenCalendarsProvider);
    final primary = Theme.of(context).colorScheme.primary;
    void toggle(CalendarInfo calendar) => ref.read(hiddenCalendarsProvider.notifier).toggle(calendar.ref);
    return NavGroup(
      title: CalendarLocalizations.of(context).calendars,
      children: [
        for (final calendar in calendars)
          ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            leading: IconBadge(icon: IconsaxPlusLinear.calendar_1, color: calendar.color ?? primary, size: 32),
            title: Text(calendar.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: calendar.ownerName == null ? null : Text(calendar.ownerName!, maxLines: 1),
            trailing: AppCheckbox(value: !hidden.contains(calendar.ref), onChanged: (_) => toggle(calendar)),
            onTap: () => toggle(calendar),
          ),
      ],
    );
  }
}
