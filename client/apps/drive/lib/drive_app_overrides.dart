import "dart:async";

import "package:flutter/widgets.dart";

import "package:flutter_riverpod/misc.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_version.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_drive/drive_host.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/screens/browser/widgets/file_history_sheet.dart";
import "package:polder_drive/screens/browser/widgets/file_open_action.dart";
import "package:polder_drive/screens/browser/widgets/file_thumbnail.dart";
import "package:polder_drive/screens/search/search_view.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_core/providers/sync/sync_request_provider.dart";
import "package:polder_drive/providers/search/search_destinations_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/providers/sync/sync_scheduler_provider.dart";
import "package:polder_drive/screens/search/open_search.dart";
import "package:polder_ui/polder_ui_config.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";

import "package:polder_drive_app/providers/drive_search_destinations.dart";
import "package:polder_drive_app/routes/drive_app_router.dart";
import "package:polder_drive_app/routes/drive_app_routes.dart";

final List<Override> driveAppOverrides = [
  polderUiConfigProvider.overrideWithValue(
    const PolderUiConfig(
      afterSignIn: _afterSignIn,
      accountSettings: DriveAppRoutes.settings,
      upFrom: DriveAppRoutes.upFrom,
      isTopLevel: DriveAppRoutes.isTopLevel,
      pageActions: [SearchButton(), SettingsButton(onlyOnPhone: true)],
      menuButton: AccountMenuButton(),
      openSearch: _openSearch,
    ),
  ),
  historyRouterProvider.overrideWith((ref) => ref.watch(driveRouterProvider)),
  syncRequestProvider.overrideWith(
    (ref) =>
        () => ref.read(syncSchedulerProvider)?.requestRun(),
  ),
  notificationChecksSchedulerProvider.overrideWith((ref) => ref.watch(syncPlatformProvider).scheduleNotificationChecks),
  searchDestinationsProvider.overrideWith(driveSearchDestinations),
  driveHostProvider.overrideWithValue(const DriveHost(openNote: _openNote)),
  notesLocationsProvider.overrideWithValue(DriveRoutes.notes),
  notesHostProvider.overrideWithValue(
    const NotesHost(
      openFile: openEntry,
      showInFiles: _showInFiles,
      showFileHistory: _showFileHistory,
      fileSearch: _fileSearch,
      fileThumbnail: _fileThumbnail,
    ),
  ),
];

String _afterSignIn(Uri loginLocation) => DriveAppRoutes.signIn.afterSignIn(loginLocation);

void _openNote(BuildContext context, String path) => unawaited(context.push(DriveRoutes.noteAt(path)));

void _showInFiles(BuildContext context, FileEntry entry) =>
    context.go(DriveRoutes.filesAt(RemotePath.parent(entry.path), select: entry.name));

Future<void> _showFileHistory(
  BuildContext context,
  FileEntry entry, {
  required void Function(FileVersion version) onView,
  required Future<void> Function(FileVersion version) onRestore,
}) => showFileHistory(context, entry, onView: onView, onRestore: onRestore);

Widget _fileSearch(BuildContext context, ValueChanged<FileEntry> onPick) =>
    SearchView(onOpenEntry: onPick, onShowInFolder: onPick, onGo: (_) {}, onClose: () => Navigator.pop(context));

Widget _fileThumbnail(FileEntry entry, double dimension) => FileThumbnail(entry: entry, dimension: dimension);

void _openSearch(BuildContext context, String query) => openSearch(context, initialQuery: query);
