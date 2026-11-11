import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/appearance/appearance_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/connection/server_connection_provider.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/offline/offline_availability_provider.dart";
import "package:polder/providers/offline/offline_sync_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/providers/deep_link/deep_link_provider.dart";
import "package:polder/providers/notifications/notification_coordinator.dart";
import "package:polder/providers/desktop/finder_location_provider.dart";
import "package:polder/widgets/shared/connection_banner.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:polder/widgets/layout/mouse_navigation.dart";
import "package:polder/widgets/layout/window_titlebar.dart";
import "package:polder/widgets/shortcuts/launcher_shortcuts.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_calendar/polder_calendar.dart";

class PolderApp extends ConsumerStatefulWidget {
  const PolderApp({super.key});

  @override
  ConsumerState<PolderApp> createState() => _PolderAppState();
}

class _PolderAppState extends ConsumerState<PolderApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    ref.read(appearanceProvider.notifier).refreshSystemAccent();
    if (ref.read(currentAccountProvider) == null) return;
    unawaited(ref.read(serverConnectionProvider.notifier).check());
    ref.read(offlineSyncProvider.notifier).kickAll();
  }

  void _recoverFromOffline() {
    for (final provider in [currentUserProvider, notesFolderProvider]) {
      if (ref.read(provider).hasError) ref.invalidate(provider);
    }
    ref
      ..invalidate(monthEventsProvider)
      ..invalidate(calendarListProvider)
      ..invalidate(directoryProvider)
      ..invalidate(notesTreeProvider);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(showInFinderProvider);
    final appearance = ref.watch(appearanceProvider);
    final branding = ref.watch(brandingProvider);
    final seed = appearance.seedWith(branding.accent);
    ref.watch(deepLinkHandlerProvider);
    ref.watch(notificationCoordinatorProvider);
    ref.watch(offlineSyncProvider);
    ref.listen(serverConnectionProvider.select((connection) => connection.isOnline), (wasOnline, isOnline) {
      if (isOnline && wasOnline == false) _recoverFromOffline();
    });
    if (ref.watch(currentAccountProvider.select((account) => account != null))) {
      ref
        ..watch(notesOfflinePinProvider)
        ..watch(offlinePinsProvider);
    }
    final restoringAccount = ref.watch(accountProvider.select((account) => account.isLoading && !account.hasValue));
    return MaterialApp.router(
      onGenerateTitle: (context) => branding.nameOr(AppLocalizations.of(context).appTitle),
      theme: AppTheme.build(seed, Brightness.light),
      darkTheme: AppTheme.build(seed, Brightness.dark),
      themeMode: appearance.mode,
      localizationsDelegates: [...AppLocalizations.localizationsDelegates, CalendarLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => restoringAccount
          ? ColoredBox(color: Theme.of(context).colorScheme.surface)
          : AdaptiveLayoutBuilder(
              child: (_) => LauncherShortcuts(
                child: DesktopTray(
                  child: WindowTitlebar(
                    child: ConnectionBanner(child: MouseNavigation(child: child!)),
                  ),
                ),
              ),
            ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
