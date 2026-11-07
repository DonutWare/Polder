import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/state/calendar_actions.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";

class EventDetails extends ConsumerWidget {
  const EventDetails({required this.event, this.onEdit, this.onDelete, this.onClose, super.key});

  final CalendarEvent event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final calendar = ref
        .watch(calendarListProvider)
        .value
        ?.where((calendar) => calendar.ref == event.calendar)
        .firstOrNull;
    final color = event.colorIn(context, ref.watch(calendarColorsProvider));
    final editable = ref.watch(calendarActionsProvider).canEdit(event, calendar);
    final location = event.location?.trim() ?? "";
    final description = event.description?.trim() ?? "";
    final url = event.url?.trim() ?? "";
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final accent = Color.lerp(color, theme.colorScheme.onSurfaceVariant, 0.35)!;
    final style = CalendarStyle.of(context);
    return IconTheme.merge(
      data: IconThemeData(color: accent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(CalendarStyle.tint(context, color), style.panel),
              border: Border(bottom: CalendarStyle.tintedSide(color)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (onClose != null)
                        IconButton(
                          tooltip: strings.close,
                          icon: const Icon(IconsaxPlusLinear.close_circle),
                          onPressed: onClose,
                        ),
                      const Spacer(),
                      if (editable && onEdit != null)
                        IconButton(
                          tooltip: strings.edit,
                          icon: const Icon(IconsaxPlusLinear.edit_2),
                          onPressed: onEdit,
                        ),
                      if (editable && onDelete != null)
                        IconButton(
                          tooltip: strings.delete,
                          icon: const Icon(IconsaxPlusLinear.trash),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Container(
                          width: 4,
                          height: 44,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(event.titleFor(strings), style: theme.textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text(describeWhen(context, event), style: theme.textTheme.bodyMedium),
                              if (event.recurring || event.rrule != null)
                                Row(
                                  spacing: 6,
                                  children: [
                                    const Icon(IconsaxPlusLinear.repeat, size: 16),
                                    Flexible(
                                      child: Text(describeRepeat(context, event.rrule, event.start), style: muted),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (location.isNotEmpty)
                    _DetailRow(icon: IconsaxPlusLinear.location, child: SelectableText(location)),
                  if (url.isNotEmpty) _DetailRow(icon: IconsaxPlusLinear.link_1, child: SelectableText(url)),
                  if (description.isNotEmpty)
                    _DetailRow(icon: IconsaxPlusLinear.note_text, child: SelectableText(description)),
                  if (event.attendees.isNotEmpty) ...[
                    _DetailRow(
                      icon: IconsaxPlusLinear.people,
                      child: Text(strings.guests(event.attendees.length), style: theme.textTheme.bodyMedium),
                    ),
                    for (final attendee in event.attendees)
                      _AttendeeRow(attendee: attendee, organizer: event.organizer),
                  ],
                  for (final (index, reminder) in event.reminders.indexed)
                    _DetailRow(
                      icon: index == 0 ? IconsaxPlusLinear.notification : null,
                      child: Text(describeReminder(context, reminder, allDay: event.allDay)),
                    ),
                  if (calendar != null) _DetailRow(icon: IconsaxPlusLinear.calendar_1, child: Text(calendar.name)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.child, this.icon});

  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 56, child: Center(child: icon == null ? null : Icon(icon, size: 20))),
        Expanded(child: child),
      ],
    ),
  );
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({required this.attendee, this.organizer});

  final EventAttendee attendee;
  final EventPerson? organizer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (attendee.status) {
      AttendeeStatus.accepted => (IconsaxPlusBold.tick_circle, theme.colorScheme.primary),
      AttendeeStatus.declined => (IconsaxPlusBold.close_circle, theme.colorScheme.error),
      AttendeeStatus.tentative => (IconsaxPlusBold.message_question, theme.colorScheme.onSurfaceVariant),
      _ => (IconsaxPlusLinear.clock, theme.colorScheme.outline),
    };
    final isOrganizer = organizer?.email == attendee.person.email;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 56, top: 2, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(attendee.person.label, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
          ),
          if (isOrganizer)
            Text(
              CalendarLocalizations.of(context).organizer,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
