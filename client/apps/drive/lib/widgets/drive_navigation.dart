import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_ui/screens/settings/standalone_settings_screen.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";
import "package:polder_ui/widgets/shared/quota_bar.dart";

class DriveDestination {
  const DriveDestination(this.route, this.icon, this.selectedIcon, this.label);

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(BuildContext context) label;

  bool isAt(Uri location) => location.path == route || location.path.startsWith("$route/");
}

final driveDestinationsProvider = Provider<List<DriveDestination>>((ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    const DriveDestination(DriveRoutes.files, IconsaxPlusLinear.folder_2, IconsaxPlusBold.folder_2, _files),
    const DriveDestination(DriveRoutes.shared, IconsaxPlusLinear.share, IconsaxPlusBold.share, _shared),
    const DriveDestination(DriveRoutes.activity, IconsaxPlusLinear.activity, IconsaxPlusBold.activity, _activity),
    if (platform.supportsAutoUpload)
      const DriveDestination(
        DriveRoutes.autoUpload,
        IconsaxPlusLinear.gallery_import,
        IconsaxPlusBold.gallery_import,
        _autoUpload,
      ),
    if (platform.supportsFolderSync)
      const DriveDestination(DriveRoutes.sync, IconsaxPlusLinear.refresh_2, IconsaxPlusBold.refresh_2, _sync),
    const DriveDestination(DriveRoutes.tags, IconsaxPlusLinear.tag, IconsaxPlusBold.tag, _tags),
    const DriveDestination(DriveRoutes.trash, IconsaxPlusLinear.trash, IconsaxPlusBold.trash, _trash),
  ];
});

String _files(BuildContext context) => context.localized.navFiles;
String _shared(BuildContext context) => context.localized.navShared;
String _activity(BuildContext context) => context.localized.navActivity;
String _autoUpload(BuildContext context) => context.localized.navAutoUpload;
String _sync(BuildContext context) => context.localized.navSync;
String _tags(BuildContext context) => context.localized.tagsTitle;
String _trash(BuildContext context) => context.localized.navTrash;

class DriveSidebar extends ConsumerWidget {
  const DriveSidebar({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final destination in ref.watch(driveDestinationsProvider))
              SidebarItem(
                icon: destination.isAt(location) ? destination.selectedIcon : destination.icon,
                label: destination.label(context),
                selected: destination.isAt(location),
                onTap: () => context.go(destination.route),
              ),
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: QuotaBar()),
      SettingsSidebarItem(location: location),
    ],
  );
}

class DriveRail extends ConsumerWidget {
  const DriveRail({required this.location, super.key});

  final Uri location;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      for (final destination in ref.watch(driveDestinationsProvider))
        RailTile(
          icon: destination.icon,
          selectedIcon: destination.selectedIcon,
          label: destination.label(context),
          selected: destination.isAt(location),
          onTap: () => context.go(destination.route),
        ),
    ],
  );
}
