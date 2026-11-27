import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
import "package:go_router/go_router.dart";
import "package:polder_account_link/app_location_links.dart";
import "package:polder_account_link/companion_app.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/media_gallery.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes_app/routes/notes_app_router.dart";
import "package:polder_notes_app/routes/notes_app_routes.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_ui/util/external_link.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";

final List<Override> notesAppOverrides = [
  polderUiConfigProvider.overrideWithValue(
    const PolderUiConfig(
      afterSignIn: _afterSignIn,
      accountSettings: NotesAppRoutes.settings,
      upFrom: NotesAppRoutes.upFrom,
      isTopLevel: NotesAppRoutes.isTopLevel,
      pageActions: [SettingsButton(onlyOnPhone: true)],
      menuButton: AccountMenuButton(),
    ),
  ),
  notesLocationsProvider.overrideWithValue(NotesAppRoutes.notes),
  notesHostProvider.overrideWithValue(const NotesHost(openFile: _openFile, showInFiles: _showInPolder)),
  historyRouterProvider.overrideWith((ref) => ref.watch(notesRouterProvider)),
];

String _afterSignIn(Uri loginLocation) => NotesAppRoutes.signIn.afterSignIn(loginLocation);

Future<void> _openFile(BuildContext context, FileEntry entry, {List<FileEntry>? gallery}) async {
  if (entry.isText) return context.go(NotesAppRoutes.notes.noteAt(entry.path));
  if (entry.isDir) return _openInFiles(context, entry.path);
  if (entry.isViewableMedia) {
    await context.push(NotesAppRoutes.media, extra: gallery == null ? entry : MediaGallery(entry, gallery));
    return;
  }
  await _openInFiles(context, RemotePath.parent(entry.path), select: entry.name);
}

void _showInPolder(BuildContext context, FileEntry entry) =>
    unawaited(_openInFiles(context, RemotePath.parent(entry.path), select: entry.name));

Future<void> _openInFiles(BuildContext context, String folder, {String? select}) async {
  final location = _filesLocation(folder, select: select).toString();
  if (await AppLocationLinks.openInFirstOf([CompanionApp.drive, null], location, dev: isDevFlavor)) return;
  if (context.mounted) await _openInPolderWeb(context, folder, select: select);
}

Uri _filesLocation(String folder, {String? select}) =>
    Uri(path: "/files", queryParameters: {"path": folder, "select": ?select});

Future<void> _openInPolderWeb(BuildContext context, String folder, {String? select}) async {
  final account = ProviderScope.containerOf(context, listen: false).read(currentAccountProvider);
  if (account == null) return;
  final server = account.serverUrl.endsWith("/")
      ? account.serverUrl.substring(0, account.serverUrl.length - 1)
      : account.serverUrl;
  await openExternalLink("$server${_filesLocation(folder, select: select)}");
}
