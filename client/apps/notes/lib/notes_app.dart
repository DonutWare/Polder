import "dart:async";

import "package:flutter/material.dart";

import "package:calendar_views/calendar_views.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/browser/directory_provider.dart";
import "package:polder_core/providers/connection/server_connection_provider.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder_core/providers/offline/offline_availability_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes_app/routes/notes_app_router.dart";
import "package:polder_ui/widgets/app/standalone_app.dart";

class NotesApp extends ConsumerWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void recoverFromOffline() {
      for (final provider in [currentUserProvider, notesFolderProvider]) {
        if (ref.read(provider).hasError) ref.invalidate(provider);
      }
      ref
        ..invalidate(directoryProvider)
        ..invalidate(notesTreeProvider);
    }

    ref.listen(sessionEndedProvider, (wasEnded, ended) {
      if (!ended && wasEnded == true && ref.read(currentAccountProvider) != null) {
        recoverFromOffline();
        unawaited(ref.read(serverConnectionProvider.notifier).check());
        ref.read(offlineSyncProvider.notifier).kickAll();
      }
    });
    ref.listen(serverConnectionProvider.select((connection) => connection.isOnline), (wasOnline, isOnline) {
      if (isOnline && wasOnline == false) recoverFromOffline();
    });
    if (ref.watch(currentAccountProvider.select((account) => account != null))) {
      ref
        ..watch(notesOfflinePinProvider)
        ..watch(offlinePinsProvider);
    }
    return StandaloneApp(
      title: (localized) => localized.navNotes,
      router: ref.watch(notesRouterProvider),
      localizationsDelegates: const [CalendarLocalizations.delegate],
    );
  }
}
