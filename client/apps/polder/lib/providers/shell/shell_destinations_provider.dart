import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_drive/providers/activity/live_transfers_provider.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder/util/extensions/num_extensions.dart";

enum ShellDestination {
  files(AppRoutes.files, PolderFeature.drive),
  shared(AppRoutes.shared, PolderFeature.drive),
  notes(AppRoutes.notes, PolderFeature.notes),
  calendar(AppRoutes.calendar, PolderFeature.calendar),
  activity(AppRoutes.activity, PolderFeature.drive),
  sync(AppRoutes.sync, PolderFeature.drive),
  autoUpload(AppRoutes.autoUpload, PolderFeature.drive),
  groups(AppRoutes.groups),
  tags(AppRoutes.tags, PolderFeature.drive),
  trash(AppRoutes.trash, PolderFeature.drive),
  settings(AppRoutes.settings);

  const ShellDestination(this.route, [this.feature]);

  final String route;
  final PolderFeature? feature;
}

final shellDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final modes = ref.watch(resolvedFeatureModesProvider);
  return [
    if (modes.isVisible(PolderFeature.drive)) ShellDestination.files,
    if (modes.isBuiltIn(PolderFeature.drive)) ShellDestination.shared,
    if (modes.isVisible(PolderFeature.notes)) ShellDestination.notes,
    if (modes.isVisible(PolderFeature.calendar)) ShellDestination.calendar,
  ];
});

final stackedDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  final drive = ref.watch(resolvedFeatureModesProvider).isBuiltIn(PolderFeature.drive);
  return [
    if (drive) ShellDestination.activity,
    if (drive && platform.supportsAutoUpload) ShellDestination.autoUpload,
    ShellDestination.groups,
    if (drive) ShellDestination.tags,
    if (drive) ShellDestination.trash,
    if (drive && platform.supportsFolderSync) ShellDestination.sync,
    ShellDestination.settings,
  ];
});

final opensCompanionProvider = Provider.family<bool, ShellDestination>((ref, destination) {
  final feature = destination.feature;
  return feature != null && ref.watch(resolvedFeatureModesProvider)[feature] == FeatureMode.openApp;
});

final activityBadgeProvider = Provider<String?>((ref) {
  final uploading = ref.watch(incomingPathsProvider.select((paths) => paths.length));
  return uploading > 0 ? uploading.shortenToNearestNumber() : null;
});
