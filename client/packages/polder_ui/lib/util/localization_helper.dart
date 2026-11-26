import "package:flutter/widgets.dart";

import "package:polder_ui/l10n/generated/app_localizations.dart";

extension BuildContextLocalization on BuildContext {
  AppLocalizations get localized => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).toLanguageTag();
}
