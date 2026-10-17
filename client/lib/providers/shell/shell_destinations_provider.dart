import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";

enum ShellDestination {
  files(AppRoutes.files),
  shared(AppRoutes.shared),
  notes(AppRoutes.notes),
  activity(AppRoutes.activity),
  sync(AppRoutes.sync),
  autoUpload(AppRoutes.autoUpload),
  groups(AppRoutes.groups),
  trash(AppRoutes.trash),
  settings(AppRoutes.settings);

  const ShellDestination(this.route);

  final String route;
}

enum AdminDestination {
  overview(AppRoutes.admin),
  users(AppRoutes.adminUsers),
  logs(AppRoutes.adminLogs),
  branding(AppRoutes.adminBranding);

  const AdminDestination(this.route);

  final String route;
}

final shellDestinationsProvider = Provider<List<ShellDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    ShellDestination.files,
    ShellDestination.shared,
    ShellDestination.notes,
    ShellDestination.activity,
    if (platform.supportsFolderSync) ShellDestination.sync,
    if (platform.supportsAutoUpload) ShellDestination.autoUpload,
  ];
});

final secondaryShellDestinationsProvider = Provider<List<ShellDestination>>(
  (ref) => const [ShellDestination.groups, ShellDestination.trash, ShellDestination.settings],
);
