import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/providers/account_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_notes/screens/notes/notes_actions.dart";
import "package:polder_drive/screens/scan/scan_review_screen.dart";
import "package:polder_drive/screens/search/open_search.dart";
import "package:polder/services/shortcuts/app_shortcut.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder/widgets/desktop/desktop_tray.dart";
import "package:calendar_views/calendar_views.dart";

final appShortcutRunnerProvider = Provider<AppShortcutRunner>(AppShortcutRunner.new);

class AppShortcutRunner {
  AppShortcutRunner(this._ref);

  final Ref _ref;
  var _running = false;

  Future<void> run(AppShortcut shortcut) => perform(_locationFor(shortcut), (context) => _perform(context, shortcut));

  Future<void> perform(String? location, Future<void> Function(BuildContext context) action) async {
    if (_running) return;
    _running = true;
    try {
      await showDesktopWindow();
      if (await _ref.read(accountProvider.future) == null) return;
      final router = _ref.read(routerProvider);
      if (location != null) router.go(location);
      await WidgetsBinding.instance.endOfFrame;
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      await action(context);
    } finally {
      _running = false;
    }
  }

  static String? _locationFor(AppShortcut shortcut) => switch (shortcut) {
    AppShortcut.newEvent => AppRoutes.calendar,
    AppShortcut.newNote || AppShortcut.newChecklist => AppRoutes.notes,
    AppShortcut.scanDocument => AppRoutes.files,
    AppShortcut.search => null,
  };

  static Future<void> _perform(BuildContext context, AppShortcut shortcut) => switch (shortcut) {
    AppShortcut.newEvent => createCalendarEvent(context),
    AppShortcut.newNote => NotesActions.createInNotesFolder(context),
    AppShortcut.newChecklist => NotesActions.createInNotesFolder(context, kind: NewNoteKind.checklist),
    AppShortcut.scanDocument => scanInto(context, RemotePath.root),
    AppShortcut.search => openSearch(context),
  };
}
