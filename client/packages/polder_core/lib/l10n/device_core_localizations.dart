import "dart:ui";

import "package:polder_core/l10n/generated/core_localizations.dart";

CoreLocalizations deviceCoreLocalizations() {
  final supported = CoreLocalizations.supportedLocales.map((locale) => locale.languageCode).toSet();
  final preferred = PlatformDispatcher.instance.locales.where((locale) => supported.contains(locale.languageCode));
  return lookupCoreLocalizations(Locale(preferred.firstOrNull?.languageCode ?? "en"));
}
