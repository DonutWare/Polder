import "dart:ui";

import "package:polder/l10n/generated/app_localizations.dart";

AppLocalizations deviceLocalizations() {
  final supported = AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toSet();
  final preferred = PlatformDispatcher.instance.locales.where((locale) => supported.contains(locale.languageCode));
  return lookupAppLocalizations(Locale(preferred.firstOrNull?.languageCode ?? "en"));
}
