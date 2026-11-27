import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_drive/providers/search/search_destinations_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/routes/drive_routes.dart";

import "package:polder_drive_app/routes/drive_app_routes.dart";

List<SearchDestination> driveSearchDestinations(Ref ref) {
  final platform = ref.watch(syncPlatformProvider);
  return [
    SearchDestination(
      route: DriveRoutes.files,
      icon: IconsaxPlusLinear.folder_2,
      label: (l) => l.navFiles,
      keywords: (l) => l.searchKeywordsFiles,
    ),
    SearchDestination(
      route: DriveRoutes.shared,
      icon: IconsaxPlusLinear.share,
      label: (l) => l.navShared,
      keywords: (l) => l.searchKeywordsShared,
    ),
    SearchDestination(
      route: DriveRoutes.activity,
      icon: IconsaxPlusLinear.activity,
      label: (l) => l.navActivity,
      keywords: (l) => l.searchKeywordsActivity,
    ),
    if (platform.supportsFolderSync) ...[
      SearchDestination(
        route: DriveRoutes.sync,
        icon: IconsaxPlusLinear.refresh_2,
        label: (l) => l.navSync,
        keywords: (l) => l.searchKeywordsSync,
      ),
      SearchDestination(
        route: DriveRoutes.conflicts,
        icon: IconsaxPlusLinear.warning_2,
        label: (l) => l.searchSyncConflicts,
        keywords: (l) => l.searchKeywordsConflicts,
      ),
    ],
    if (platform.supportsAutoUpload)
      SearchDestination(
        route: DriveRoutes.autoUpload,
        icon: IconsaxPlusLinear.gallery_import,
        label: (l) => l.navAutoUpload,
        keywords: (l) => l.searchKeywordsAutoUpload,
      ),
    SearchDestination(
      route: DriveRoutes.tags,
      icon: IconsaxPlusLinear.tag,
      label: (l) => l.tagsTitle,
      keywords: (l) => l.searchKeywordsTags,
    ),
    SearchDestination(
      route: DriveRoutes.trash,
      icon: IconsaxPlusLinear.trash,
      label: (l) => l.navTrash,
      keywords: (l) => l.searchKeywordsTrash,
    ),
    SearchDestination(
      route: DriveAppRoutes.settings,
      icon: IconsaxPlusLinear.setting_2,
      label: (l) => l.navSettings,
      keywords: (l) => l.searchKeywordsSettings,
    ),
  ];
}
