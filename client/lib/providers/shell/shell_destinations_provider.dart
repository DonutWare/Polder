import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/routes/app_routes.dart";

enum ShellDestination {
  files(AppRoutes.files),
  sync(AppRoutes.sync),
  autoUpload(AppRoutes.autoUpload),
  trash(AppRoutes.trash),
  settings(AppRoutes.settings);

  const ShellDestination(this.route);

  final String route;
}

enum AdminDestination {
  overview(AppRoutes.admin),
  users(AppRoutes.adminUsers);

  const AdminDestination(this.route);

  final String route;
}

final shellDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    ShellDestination.files,
    if (platform.supportsFolderSync) ShellDestination.sync,
    if (platform.supportsAutoUpload) ShellDestination.autoUpload,
  ];
});

final secondaryShellDestinationsProvider = Provider<List<ShellDestination>>(
  (ref) => const [ShellDestination.trash, ShellDestination.settings],
);
