import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder/providers/app/app_location_provider.dart";

String appTitle(AppLocation location, String appName, AppLocalizations localized) =>
    [?location.detail, ?_sectionName(location.section, localized), appName].join(" · ");

String? _sectionName(AppSection section, AppLocalizations localized) => switch (section) {
  AppSection.notes => localized.navNotes,
  AppSection.calendar => localized.navCalendar,
  AppSection.other => null,
};
