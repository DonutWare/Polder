import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/models/search.dart";
import "package:polder_core/providers/current_user_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder_drive/providers/search/search_destinations_provider.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder_drive/search_host.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_tag_filter_provider.dart";
import "package:polder_ui/util/search_syntax.dart";

const polderSearchHost = SearchHost(scopeFor: _scopeFor, eventAt: AppRoutes.calendarEventAt);

String _scopeFor(BuildContext context, Uri location) => searchScopeFor(
  location,
  notesRoot: ProviderScope.containerOf(context, listen: false).read(notesFolderProvider).value,
);

String searchScopeFor(Uri uri, {String? notesRoot}) {
  if (uri.path == AppRoutes.notes) {
    return notesRoot == null ? "" : appendSearchFilter("", notesFolderQuery(notesRoot));
  }
  if (uri.path == AppRoutes.calendar) {
    return appendSearchFilter(
      "",
      formatSearchFilter(const SearchFilter(key: SearchKey.type, op: SearchOp.equals, values: [searchEventType])),
    );
  }
  return folderSearchScope(uri);
}

List<SearchDestination> polderSearchDestinations(Ref ref) {
  final stacked = ref.watch(stackedDestinationsProvider);
  final platform = ref.watch(syncPlatformProvider);
  final isAdmin = ref.watch(isAdminProvider);
  return [
    SearchDestination(
      route: AppRoutes.files,
      icon: IconsaxPlusLinear.folder_2,
      label: (l) => l.navFiles,
      keywords: (l) => l.searchKeywordsFiles,
    ),
    SearchDestination(
      route: AppRoutes.shared,
      icon: IconsaxPlusLinear.share,
      label: (l) => l.navShared,
      keywords: (l) => l.searchKeywordsShared,
    ),
    SearchDestination(
      route: AppRoutes.groups,
      icon: IconsaxPlusLinear.people,
      label: (l) => l.groups,
      keywords: (l) => l.searchKeywordsGroups,
    ),
    SearchDestination(
      route: AppRoutes.notes,
      icon: IconsaxPlusLinear.note_2,
      label: (l) => l.navNotes,
      keywords: (l) => l.searchKeywordsNotes,
    ),
    SearchDestination(
      route: AppRoutes.calendar,
      icon: IconsaxPlusLinear.calendar_1,
      label: (l) => l.navCalendar,
      keywords: (l) => l.searchKeywordsCalendar,
    ),
    SearchDestination(
      route: AppRoutes.activity,
      icon: IconsaxPlusLinear.activity,
      label: (l) => l.navActivity,
      keywords: (l) => l.searchKeywordsActivity,
    ),
    if (stacked.contains(ShellDestination.sync)) ...[
      SearchDestination(
        route: AppRoutes.sync,
        icon: IconsaxPlusLinear.refresh_2,
        label: (l) => l.navSync,
        keywords: (l) => l.searchKeywordsSync,
      ),
      SearchDestination(
        route: AppRoutes.conflicts,
        icon: IconsaxPlusLinear.warning_2,
        label: (l) => l.searchSyncConflicts,
        keywords: (l) => l.searchKeywordsConflicts,
      ),
    ],
    if (platform.supportsAutoUpload)
      SearchDestination(
        route: AppRoutes.autoUpload,
        icon: IconsaxPlusLinear.gallery_import,
        label: (l) => l.navAutoUpload,
        keywords: (l) => l.searchKeywordsAutoUpload,
      ),
    SearchDestination(
      route: AppRoutes.tags,
      icon: IconsaxPlusLinear.tag,
      label: (l) => l.tagsTitle,
      keywords: (l) => l.searchKeywordsTags,
    ),
    SearchDestination(
      route: AppRoutes.trash,
      icon: IconsaxPlusLinear.trash,
      label: (l) => l.navTrash,
      keywords: (l) => l.searchKeywordsTrash,
    ),
    SearchDestination(
      route: AppRoutes.settings,
      icon: IconsaxPlusLinear.setting_2,
      label: (l) => l.navSettings,
      keywords: (l) => l.searchKeywordsSettings,
    ),
    SearchDestination(
      route: AppRoutes.about,
      icon: IconsaxPlusLinear.info_circle,
      label: (l) => l.about,
      keywords: (l) => l.searchKeywordsAbout,
    ),
    if (isAdmin) ...[
      SearchDestination(
        route: AppRoutes.admin,
        icon: IconsaxPlusLinear.shield_tick,
        label: (l) => l.administration,
        keywords: (l) => l.searchKeywordsAdmin,
      ),
      SearchDestination(
        route: AppRoutes.adminUsers,
        icon: IconsaxPlusLinear.profile_2user,
        label: (l) => l.users,
        keywords: (l) => l.searchKeywordsAdminUsers,
      ),
    ],
  ];
}
