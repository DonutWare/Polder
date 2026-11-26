import "dart:async";

import "package:flutter/material.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_calendar/providers/calendar/calendar_reminder_providers.dart";
import "package:polder_calendar/providers/calendar/week_layout_provider.dart";
import "package:polder_calendar_app/routes/calendar_app_router.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/providers/appearance/appearance_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_window/window_titlebar.dart";

class CalendarApp extends ConsumerStatefulWidget {
  const CalendarApp({super.key});

  @override
  ConsumerState<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends ConsumerState<CalendarApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    ref.read(appearanceProvider.notifier).refreshSystemAccent();
    if (ref.read(currentAccountProvider) == null || ref.read(sessionEndedProvider)) return;
    unawaited(ref.read(serverConnectionProvider.notifier).check());
    ref.read(offlineSyncProvider.notifier).kickAll();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearance = ref.watch(appearanceProvider);
    final seed = appearance.seedWith(ref.watch(brandingProvider).accent);
    final weekLayout = ref.watch(weekLayoutProvider);
    ref
      ..watch(offlineSyncProvider)
      ..watch(calendarReminderRefreshProvider)
      ..watch(liveCalendarReminderProvider)
      ..watch(_notificationTapsProvider);
    final restoringAccount = ref.watch(accountProvider.select((account) => account.isLoading && !account.hasValue));
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).navCalendar,
      theme: AppTheme.build(seed, Brightness.light),
      darkTheme: AppTheme.build(seed, Brightness.dark),
      themeMode: appearance.mode,
      localizationsDelegates: [...AppLocalizations.localizationsDelegates, CalendarLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => restoringAccount
          ? ColoredBox(color: Theme.of(context).colorScheme.surface)
          : AdaptiveLayoutBuilder(
              child: (_) => WindowTitlebar(
                child: WeekLayoutScope(layout: weekLayout, child: child!),
              ),
            ),
      routerConfig: ref.watch(calendarRouterProvider),
    );
  }
}

final _notificationTapsProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  void open(String? location) {
    if (location != null) ref.read(calendarRouterProvider).go(location);
  }

  final subscription = service.taps.listen((tap) => open(tap.location));
  unawaited(service.launchTap().then((tap) => open(tap?.location)).catchError((_) {}));
  ref.onDispose(subscription.cancel);
});
