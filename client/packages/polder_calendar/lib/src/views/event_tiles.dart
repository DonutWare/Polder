import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/model/calendar_event.dart";
import "package:polder_calendar/src/state/calendar_actions.dart";
import "package:polder_calendar/src/views/calendar_style.dart";
import "package:polder_calendar/src/views/event_presentation.dart";
import "package:polder_calendar/src/views/event_transform.dart";

const _spatial = Cubic(0.38, 1.21, 0.22, 1.0);

bool isDeclined(CalendarEvent event) => event.selfAttendee?.status == AttendeeStatus.declined;

class EventTransition extends ConsumerWidget {
  const EventTransition({required this.event, required this.child, this.color, this.collapse = false, super.key});

  final CalendarEvent event;
  final Color? color;
  final bool collapse;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removing = ref.watch(calendarMotionProvider.select((motion) => motion.isRemoving(event)));
    final appearing = ref.watch(calendarMotionProvider.select((motion) => motion.isAppearing(event)));
    const duration = CalendarMotion.removeDuration;
    Widget result = TweenAnimationBuilder<double>(
      tween: Tween(begin: appearing ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, progress, child) {
        final grow = _spatial.transform((progress * 2).clamp(0, 1));
        return Opacity(
          opacity: (progress * 4).clamp(0, 1),
          child: Transform.scale(
            scale: 0.7 + 0.3 * grow,
            child: progress >= 1
                ? child
                : DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: ShapeDecoration(
                      shape: CalendarStyle.squircle(
                        CalendarStyle.tagRadius,
                        side: BorderSide(
                          color: color ?? event.color ?? Theme.of(context).colorScheme.primary,
                          width: 2 * (1 - progress),
                        ),
                      ),
                    ),
                    child: child,
                  ),
          ),
        );
      },
      child: child,
    );
    result = AnimatedScale(
      scale: removing ? 0.8 : 1,
      duration: duration,
      curve: Curves.easeInCubic,
      child: AnimatedOpacity(opacity: removing ? 0 : 1, duration: duration, child: result),
    );
    if (!collapse) return IgnorePointer(ignoring: removing, child: result);
    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: removing ? const SizedBox(width: double.infinity) : result,
    );
  }
}

class EventSurface extends StatelessWidget {
  const EventSurface({
    required this.color,
    required this.child,
    this.event,
    this.onTap,
    this.radius = CalendarStyle.tagRadius,
    this.accent = 3,
    this.declined = false,
    super.key,
  });

  final Color color;
  final CalendarEvent? event;
  final double radius;
  final double accent;
  final bool declined;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = CalendarStyle.of(context);
    final fill = Color.alphaBlend(CalendarStyle.tint(context, color), style.panel);
    return Material(
      color: declined ? style.panel : fill,
      shape: CalendarStyle.squircle(radius, side: CalendarStyle.tintedSide(color)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                if (event case final event?) EventOrigin.remember(context, event, radius: radius);
                onTap!();
              },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: accent),
              child: child,
            ),
            if (accent > 0)
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: accent,
                child: ColoredBox(color: declined ? color.withValues(alpha: 0.4) : color),
              ),
          ],
        ),
      ),
    );
  }
}

TextStyle? _titleStyle(BuildContext context, TextStyle? base, CalendarEvent event) => base?.copyWith(
  color: Theme.of(context).colorScheme.onSurface,
  fontWeight: FontWeight.w600,
  decoration: isDeclined(event) ? TextDecoration.lineThrough : null,
);

class EventBlock extends StatelessWidget {
  const EventBlock({required this.event, required this.color, this.onTap, super.key});

  final CalendarEvent event;
  final Color color;
  final EventTap? onTap;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final small = theme.textTheme.labelSmall!;
    final muted = small.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.25);
    final title = _titleStyle(context, small.copyWith(height: 1.25), event);
    return EventTransition(
      event: event,
      color: color,
      child: EventSurface(
        color: color,
        event: event,
        declined: isDeclined(event),
        onTap: onTap == null ? null : () => onTap!(event),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final roomy = constraints.maxHeight >= 34;
            final narrow = constraints.maxWidth < 64;
            final time = "${formatTime(context, event.start)} – ${formatTime(context, event.end)}";
            return Padding(
              padding: EdgeInsets.fromLTRB(narrow ? 3 : 6, 3, narrow ? 2 : 4, 2),
              child: narrow
                  ? Text(
                      event.titleFor(strings),
                      maxLines: (constraints.maxHeight / 15).floor().clamp(1, 6),
                      overflow: TextOverflow.ellipsis,
                      style: title,
                    )
                  : roomy
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.titleFor(strings),
                          maxLines: ((constraints.maxHeight - 20) / 15).floor().clamp(1, 4),
                          overflow: TextOverflow.ellipsis,
                          style: title,
                        ),
                        Text(time, maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                      ],
                    )
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: event.titleFor(strings), style: title),
                          TextSpan(text: "  ${formatTime(context, event.start)}", style: muted),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            );
          },
        ),
      ),
    );
  }
}

class EventBar extends StatelessWidget {
  const EventBar({required this.event, required this.color, this.filled = true, this.onTap, super.key});

  final CalendarEvent event;
  final Color color;
  final bool filled;
  final EventTap? onTap;

  @override
  Widget build(BuildContext context) {
    final strings = CalendarLocalizations.of(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall!;
    final tap = onTap == null ? null : () => onTap!(event);
    if (filled) {
      return EventTransition(
        event: event,
        color: color,
        child: EventSurface(
          color: color,
          event: event,
          declined: isDeclined(event),
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                event.titleFor(strings),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _titleStyle(context, style, event),
              ),
            ),
          ),
        ),
      );
    }
    return EventTransition(
      event: event,
      color: color,
      child: InkWell(
        onTap: tap == null
            ? null
            : () {
                EventOrigin.remember(context, event);
                tap();
              },
        customBorder: CalendarStyle.squircle(CalendarStyle.tagRadius / 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Text.rich(
                    TextSpan(
                      children: [
                        if (constraints.maxWidth >= 96)
                          TextSpan(
                            text: "${formatTime(context, event.start)} ",
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        TextSpan(text: event.titleFor(strings), style: _titleStyle(context, const TextStyle(), event)),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
