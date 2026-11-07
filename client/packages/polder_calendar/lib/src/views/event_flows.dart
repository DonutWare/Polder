import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/model/calendar_info.dart";
import "package:polder_calendar/src/model/calendar_ref.dart";
import "package:polder_calendar/src/model/event_draft.dart";
import "package:polder_calendar/src/state/calendar_actions.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/time/calendar_view_mode.dart";
import "package:polder_calendar/src/time/date_math.dart";
import "package:polder_calendar/src/views/event_details.dart";
import "package:polder_calendar/src/views/event_editor.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/event_transform.dart";

bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

Future<void> openCalendarEvent(BuildContext context, CalendarEvent event) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final color = event.colorIn(context, container.read(calendarColorsProvider));
  final compact = _compact(context);
  final toDelete = await Navigator.of(context, rootNavigator: true).push(
    EventTransformRoute<CalendarEvent>(
      color: color,
      compact: compact,
      origin: EventOrigin.take(event),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (context) => _LiveEventDetails(initial: event),
    ),
  );
  if (toDelete == null || !context.mounted) return;
  await deleteCalendarEvent(context, toDelete);
}

class _LiveEventDetails extends StatefulWidget {
  const _LiveEventDetails({required this.initial});

  final CalendarEvent initial;

  @override
  State<_LiveEventDetails> createState() => _LiveEventDetailsState();
}

class _LiveEventDetailsState extends State<_LiveEventDetails> {
  late var _event = widget.initial;

  Future<void> _edit() async {
    final updated = await editCalendarEvent(context, _event);
    if (updated != null && mounted) setState(() => _event = updated);
  }

  @override
  Widget build(BuildContext context) => EventDetails(
    event: _event,
    onEdit: _edit,
    onDelete: () => Navigator.of(context).pop(_event),
    onClose: () => Navigator.of(context).pop(),
  );
}

Future<void> createCalendarEvent(BuildContext context, {DateTime? start, DateTime? day, bool allDay = false}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final strings = CalendarLocalizations.of(context);
  final actions = container.read(calendarActionsProvider);
  final calendars = actions.writableCalendars(await _calendars(container));
  if (!context.mounted) return;
  if (calendars.isEmpty) return _notify(context, strings.noWritableCalendar);
  final calendar = calendars.where((calendar) => calendar.isDefault).firstOrNull ?? calendars.first;
  final shownDay = (day ?? DateTime.now()).dateOnly;
  final dayEvents = container.read(rangeEventsProvider(VisibleRange(shownDay, shownDay.nextDay))).value ?? const [];
  final from = start ?? suggestedStart(shownDay, dayEvents);
  final edited = await _openEditor(
    context,
    isNew: true,
    calendar: calendar.ref,
    calendars: calendars,
    draft: EventDraft(
      summary: "",
      allDay: allDay,
      start: allDay ? from.dateOnly : from,
      end: allDay ? from.dateOnly.nextDay : from.add(const Duration(hours: 1)),
      reminders: allDay ? const [] : const [EventReminder(offsetMinutes: -10)],
    ),
  );
  if (edited == null || !context.mounted) return;
  await _run(context, strings.saveFailed, actions.create(edited.calendar, edited.draft));
}

Future<CalendarEvent?> editCalendarEvent(BuildContext context, CalendarEvent event) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final strings = CalendarLocalizations.of(context);
  final actions = container.read(calendarActionsProvider);
  final calendars = [
    for (final calendar in actions.writableCalendars(await _calendars(container)))
      if (calendar.ref.sourceId == event.calendar.sourceId) calendar,
  ];
  if (!context.mounted) return null;
  final edited = await _openEditor(
    context,
    draft: EventDraft.fromEvent(event),
    calendar: event.calendar,
    calendars: calendars,
    canChangeCalendar: !event.recurring && actions.capabilitiesOf(event.calendar).moveBetweenCalendars,
  );
  if (edited == null || !context.mounted) return null;
  final scope = await _scopeFor(
    context,
    event,
    actions,
    title: strings.editRecurringTitle,
    allowThisEvent: edited.draft.rrule == event.rrule,
  );
  if (scope == null || !context.mounted) return null;
  final updated = await _run(
    context,
    strings.saveFailed,
    actions.update(event, edited.draft, scope, moveTo: edited.calendar),
  );
  if (updated == null) return null;
  return _seriesWide(event, scope) ? _applied(event, edited.draft, updated.etag) : updated;
}

bool _seriesWide(CalendarEvent event, RecurrenceScope scope) =>
    scope == RecurrenceScope.all && event.ref.recurrenceId != null;

CalendarEvent _applied(CalendarEvent occurrence, EventDraft draft, String etag) => occurrence.copyWith(
  etag: etag,
  summary: draft.summary,
  start: draft.start,
  end: draft.end,
  allDay: draft.allDay,
  description: draft.description,
  location: draft.location,
  rrule: draft.rrule,
  reminders: draft.reminders,
);

Future<void> deleteCalendarEvent(BuildContext context, CalendarEvent event) async {
  final strings = CalendarLocalizations.of(context);
  final actions = ProviderScope.containerOf(context, listen: false).read(calendarActionsProvider);
  final scope = _hasScopes(event, actions)
      ? await _scopeFor(context, event, actions, title: strings.deleteRecurringTitle)
      : await showDialog<RecurrenceScope>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(IconsaxPlusLinear.trash, color: Theme.of(context).colorScheme.error),
            title: Text(strings.deleteEventTitle),
            content: Text(strings.deleteEventMessage(event.titleFor(strings))),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancel)),
              TextButton(onPressed: () => Navigator.of(context).pop(RecurrenceScope.all), child: Text(strings.delete)),
            ],
          ),
        );
  if (scope == null || !context.mounted) return;
  await _run(context, strings.deleteFailed, actions.delete(event, scope));
}

Future<List<CalendarInfo>> _calendars(ProviderContainer container) async {
  final subscription = container.listen(calendarListProvider.future, (_, _) {});
  try {
    return await subscription.read();
  } finally {
    subscription.close();
  }
}

bool _hasScopes(CalendarEvent event, CalendarActions actions) =>
    event.recurring && event.ref.recurrenceId != null && actions.capabilitiesOf(event.calendar).recurrenceScopes;

Future<RecurrenceScope?> _scopeFor(
  BuildContext context,
  CalendarEvent event,
  CalendarActions actions, {
  required String title,
  bool allowThisEvent = true,
}) async {
  if (!_hasScopes(event, actions)) return RecurrenceScope.all;
  return showDialog<RecurrenceScope>(
    context: context,
    builder: (context) => _ScopeDialog(
      title: title,
      scopes: [if (allowThisEvent) RecurrenceScope.thisEvent, RecurrenceScope.following, RecurrenceScope.all],
    ),
  );
}

Future<EditedEvent?> _openEditor(
  BuildContext context, {
  required EventDraft draft,
  required CalendarRef calendar,
  required List<CalendarInfo> calendars,
  bool isNew = false,
  bool canChangeCalendar = true,
}) {
  final editor = EventEditor(
    draft: draft,
    calendar: calendar,
    calendars: calendars,
    isNew: isNew,
    canChangeCalendar: canChangeCalendar,
  );
  if (_compact(context)) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push<EditedEvent>(MaterialPageRoute(fullscreenDialog: true, builder: (context) => editor));
  }
  final height = MediaQuery.sizeOf(context).height;
  return showDialog<EditedEvent>(
    context: context,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: 560, height: math.min(760, height - 64), child: editor),
    ),
  );
}

Future<T?> _run<T>(BuildContext context, String failure, Future<T> action) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    return await action;
  } on Object {
    messenger?.showSnackBar(SnackBar(content: Text(failure)));
    return null;
  }
}

void _notify(BuildContext context, String message) =>
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));

class _ScopeDialog extends StatefulWidget {
  const _ScopeDialog({required this.title, required this.scopes});

  final String title;
  final List<RecurrenceScope> scopes;

  @override
  State<_ScopeDialog> createState() => _ScopeDialogState();
}

class _ScopeDialogState extends State<_ScopeDialog> {
  late var _scope = widget.scopes.first;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final deleting = widget.title == strings.deleteRecurringTitle;
    return AlertDialog(
      icon: Icon(deleting ? IconsaxPlusLinear.trash : IconsaxPlusLinear.repeat, color: deleting ? scheme.error : null),
      title: Text(widget.title),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: RadioGroup<RecurrenceScope>(
        groupValue: _scope,
        onChanged: (scope) => setState(() => _scope = scope ?? _scope),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final scope in widget.scopes)
              RadioListTile<RecurrenceScope>(
                value: scope,
                title: Text(switch (scope) {
                  RecurrenceScope.thisEvent => strings.scopeThisEvent,
                  RecurrenceScope.following => strings.scopeFollowing,
                  RecurrenceScope.all => strings.scopeAll,
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancel)),
        FilledButton(
          style: deleting
              ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
              : null,
          onPressed: () => Navigator.of(context).pop(_scope),
          child: Text(deleting ? strings.delete : strings.ok),
        ),
      ],
    );
  }
}
