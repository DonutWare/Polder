import "dart:async";

import "package:flutter/material.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/branding/branding_provider.dart";
import "package:polder_core/providers/browser/directory_provider.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder_core/providers/offline/offline_availability_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes_app/routes/notes_app_router.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/providers/appearance/appearance_provider.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_window/window_titlebar.dart";

class NotesApp extends ConsumerStatefulWidget {
  const NotesApp({super.key});

  @override
  ConsumerState<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends ConsumerState<NotesApp> {
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

  void _recoverFromOffline() {
    for (final provider in [currentUserProvider, notesFolderProvider]) {
      if (ref.read(provider).hasError) ref.invalidate(provider);
    }
    ref
      ..invalidate(directoryProvider)
      ..invalidate(notesTreeProvider);
  }

  void _onSessionEnded(bool? wasEnded, bool ended) {
    if (!ended && wasEnded == true && ref.read(currentAccountProvider) != null) {
      _recoverFromOffline();
      unawaited(ref.read(serverConnectionProvider.notifier).check());
      ref.read(offlineSyncProvider.notifier).kickAll();
    }
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
    ref.watch(offlineSyncProvider);
    ref.listen(sessionEndedProvider, _onSessionEnded);
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
      onGenerateTitle: (context) => AppLocalizations.of(context).navNotes,
      theme: AppTheme.build(seed, Brightness.light),
      darkTheme: AppTheme.build(seed, Brightness.dark),
      themeMode: appearance.mode,
      localizationsDelegates: [...AppLocalizations.localizationsDelegates, CalendarLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => restoringAccount
          ? ColoredBox(color: Theme.of(context).colorScheme.surface)
          : AdaptiveLayoutBuilder(child: (_) => WindowTitlebar(child: child!)),
      routerConfig: ref.watch(notesRouterProvider),
    );
  }
}
