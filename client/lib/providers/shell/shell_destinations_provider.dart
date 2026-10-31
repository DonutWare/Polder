import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/extensions/num_extensions.dart";

enum ShellDestination {
  files(AppRoutes.files),
  shared(AppRoutes.shared),
  notes(AppRoutes.notes),
  activity(AppRoutes.activity),
  sync(AppRoutes.sync),
  autoUpload(AppRoutes.autoUpload),
  groups(AppRoutes.groups),
  tags(AppRoutes.tags),
  trash(AppRoutes.trash),
  settings(AppRoutes.settings);

  const ShellDestination(this.route);

  final String route;
}

final shellDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    ShellDestination.files,
    ShellDestination.shared,
    ShellDestination.notes,
    if (platform.supportsFolderSync) ShellDestination.sync,
  ];
});

final stackedDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    ShellDestination.activity,
    if (platform.supportsAutoUpload) ShellDestination.autoUpload,
    ShellDestination.groups,
    ShellDestination.tags,
    ShellDestination.trash,
    ShellDestination.settings,
  ];
});

final activityBadgeProvider = Provider<String?>((ref) {
  final uploading = ref.watch(incomingPathsProvider.select((paths) => paths.length));
  return uploading > 0 ? uploading.shortenToNearestNumber() : null;
});
