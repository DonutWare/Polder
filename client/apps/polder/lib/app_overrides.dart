import "package:flutter/material.dart";

import "package:flutter_riverpod/misc.dart";
import "package:go_router/go_router.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/file_version.dart";
import "package:polder_core/providers/sync/sync_request_provider.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder_drive/drive_host.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/providers/sync/sync_scheduler_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/polder_ui_config_override.dart";
import "package:polder_drive/screens/browser/widgets/file_history_sheet.dart";
import "package:polder_drive/screens/browser/widgets/file_open_action.dart";
import "package:polder_drive/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/search/search_view.dart";

final List<Override> polderPackageOverrides = [
  polderUiConfigOverride,
  calendarLocationsProvider.overrideWithValue(AppRoutes.calendarLocations),
  notesLocationsProvider.overrideWithValue(AppRoutes.notesLocations),
  notesHostProvider.overrideWithValue(_notesHost),
  historyRouterProvider.overrideWith((ref) => ref.watch(routerProvider)),
  syncRequestProvider.overrideWith(
    (ref) =>
        () => ref.read(syncSchedulerProvider)?.requestRun(),
  ),
  notificationChecksSchedulerProvider.overrideWith((ref) => ref.watch(syncPlatformProvider).scheduleNotificationChecks),
  driveHostProvider.overrideWith(
    (ref) => ref.watch(resolvedFeatureModesProvider).isBuiltIn(PolderFeature.notes)
        ? const DriveHost(openNote: _openNote)
        : const DriveHost(),
  ),
  deliveredNotificationPreferencesProvider.overrideWith(
    (ref) async =>
        ref.watch(resolvedFeatureModesProvider).restrict(await ref.watch(notificationPreferencesProvider.future)),
  ),
];

void _openNote(BuildContext context, String path) => context.go(AppRoutes.noteAt(path));

const _notesHost = NotesHost(
  openFile: openEntry,
  showInFiles: _showInFiles,
  showFileHistory: _showFileHistory,
  fileSearch: _fileSearch,
  fileThumbnail: _fileThumbnail,
);

void _showInFiles(BuildContext context, FileEntry entry) =>
    context.go(AppRoutes.filesAt(RemotePath.parent(entry.path), select: entry.name));

Future<void> _showFileHistory(
  BuildContext context,
  FileEntry entry, {
  required void Function(FileVersion version) onView,
  required Future<void> Function(FileVersion version) onRestore,
}) => showFileHistory(context, entry, onView: onView, onRestore: onRestore);

Widget _fileSearch(BuildContext context, ValueChanged<FileEntry> onPick) =>
    SearchView(onOpenEntry: onPick, onShowInFolder: onPick, onGo: (_) {}, onClose: () => Navigator.pop(context));

Widget _fileThumbnail(FileEntry entry, double dimension) => FileThumbnail(entry: entry, dimension: dimension);
