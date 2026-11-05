import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_calendar/l10n/generated/calendar_localizations.dart";
import "package:polder_calendar/src/state/calendar_providers.dart";

class LoadState extends ConsumerWidget {
  const LoadState({required this.value, super.key});

  final AsyncValue<Object?> value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (value.hasError) {
      final strings = CalendarLocalizations.of(context);
      final colors = Theme.of(context).colorScheme;
      return Material(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(strings.loadFailed, style: TextStyle(color: colors.onErrorContainer)),
              ),
              TextButton(onPressed: () => ref.invalidate(monthEventsProvider), child: Text(strings.retry)),
            ],
          ),
        ),
      );
    }
    return SizedBox(height: 2, child: value.isLoading ? const LinearProgressIndicator(minHeight: 2) : null);
  }
}
