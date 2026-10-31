import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/providers/current_user_provider.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/fuzzy_match.dart";

@immutable
class AppDestination {
  const AppDestination({required this.route, required this.icon, required this.label, required this.keywords});

  final String route;
  final IconData icon;
  final String Function(AppLocalizations) label;

  final String Function(AppLocalizations) keywords;
}

@immutable
class DestinationMatch {
  const DestinationMatch({required this.destination, required this.label, required this.match});

  final AppDestination destination;
  final String label;

  final FuzzyMatch match;
}

final appDestinationsProvider = Provider<List<AppDestination>>((ref) {
  final shell = ref.watch(shellDestinationsProvider);
  final platform = ref.watch(syncPlatformProvider);
  final isAdmin = ref.watch(isAdminProvider);
  return [
    AppDestination(
      route: AppRoutes.files,
      icon: IconsaxPlusLinear.folder_2,
      label: (l) => l.navFiles,
      keywords: (l) => l.searchKeywordsFiles,
    ),
    AppDestination(
      route: AppRoutes.shared,
      icon: IconsaxPlusLinear.share,
      label: (l) => l.navShared,
      keywords: (l) => l.searchKeywordsShared,
    ),
    AppDestination(
      route: AppRoutes.groups,
      icon: IconsaxPlusLinear.people,
      label: (l) => l.groups,
      keywords: (l) => l.searchKeywordsGroups,
    ),
    AppDestination(
      route: AppRoutes.notes,
      icon: IconsaxPlusLinear.note_2,
      label: (l) => l.navNotes,
      keywords: (l) => l.searchKeywordsNotes,
    ),
    AppDestination(
      route: AppRoutes.activity,
      icon: IconsaxPlusLinear.activity,
      label: (l) => l.navActivity,
      keywords: (l) => l.searchKeywordsActivity,
    ),
    if (shell.contains(ShellDestination.sync)) ...[
      AppDestination(
        route: AppRoutes.sync,
        icon: IconsaxPlusLinear.refresh_2,
        label: (l) => l.navSync,
        keywords: (l) => l.searchKeywordsSync,
      ),
      AppDestination(
        route: AppRoutes.conflicts,
        icon: IconsaxPlusLinear.warning_2,
        label: (l) => l.searchSyncConflicts,
        keywords: (l) => l.searchKeywordsConflicts,
      ),
    ],
    if (platform.supportsAutoUpload)
      AppDestination(
        route: AppRoutes.autoUpload,
        icon: IconsaxPlusLinear.gallery_import,
        label: (l) => l.navAutoUpload,
        keywords: (l) => l.searchKeywordsAutoUpload,
      ),
    AppDestination(
      route: AppRoutes.tags,
      icon: IconsaxPlusLinear.tag,
      label: (l) => l.tagsTitle,
      keywords: (l) => l.searchKeywordsTags,
    ),
    AppDestination(
      route: AppRoutes.trash,
      icon: IconsaxPlusLinear.trash,
      label: (l) => l.navTrash,
      keywords: (l) => l.searchKeywordsTrash,
    ),
    AppDestination(
      route: AppRoutes.settings,
      icon: IconsaxPlusLinear.setting_2,
      label: (l) => l.navSettings,
      keywords: (l) => l.searchKeywordsSettings,
    ),
    AppDestination(
      route: AppRoutes.about,
      icon: IconsaxPlusLinear.info_circle,
      label: (l) => l.about,
      keywords: (l) => l.searchKeywordsAbout,
    ),
    if (isAdmin) ...[
      AppDestination(
        route: AppRoutes.admin,
        icon: IconsaxPlusLinear.shield_tick,
        label: (l) => l.administration,
        keywords: (l) => l.searchKeywordsAdmin,
      ),
      AppDestination(
        route: AppRoutes.adminUsers,
        icon: IconsaxPlusLinear.profile_2user,
        label: (l) => l.users,
        keywords: (l) => l.searchKeywordsAdminUsers,
      ),
    ],
  ];
});

List<DestinationMatch> matchDestinations(List<AppDestination> destinations, AppLocalizations l, String query) {
  final matches = <DestinationMatch>[];
  for (final destination in destinations) {
    final label = destination.label(l);
    final byLabel = fuzzyMatch(query, label);
    final byKeyword = destination
        .keywords(l)
        .split(",")
        .map((keyword) => fuzzyMatch(query, keyword.trim()))
        .whereType<FuzzyMatch>()
        .fold<FuzzyMatch?>(null, (best, match) => best == null || match.score > best.score ? match : best);
    final match = switch ((byLabel, byKeyword)) {
      (final label?, final keyword?) when keyword.score > label.score + 20 => FuzzyMatch(keyword.score - 10, const []),
      (final label?, _) => label,
      (null, final keyword?) => FuzzyMatch(keyword.score - 10, const []),
      _ => null,
    };
    if (match != null) matches.add(DestinationMatch(destination: destination, label: label, match: match));
  }
  return matches..sort((a, b) => b.match.score.compareTo(a.match.score));
}
