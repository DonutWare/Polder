// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class CoreLocalizationsNl extends CoreLocalizations {
  CoreLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String browserSignInFinishedTitle(String app) {
    return 'Terug naar $app';
  }

  @override
  String browserSignInFinished(String app) {
    return 'Je kunt dit tabblad sluiten en teruggaan naar $app.';
  }

  @override
  String get offlineDownloadsTitle => 'Bestanden synchroniseren voor offline gebruik';

  @override
  String offlineDownloadsProgress(String finished, String total) {
    return '$finished van $total bestanden';
  }

  @override
  String get offlineDownloadsDoneTitle => 'Bestanden offline beschikbaar';

  @override
  String offlineDownloadsDone(String total) {
    return '$total bestanden zijn klaar voor offline gebruik';
  }

  @override
  String get offlineDownloadsFailedTitle => 'Sommige bestanden konden niet worden gedownload';

  @override
  String offlineDownloadsFailed(String failed, String total) {
    return '$failed van $total mislukt; ze worden opnieuw geprobeerd';
  }
}
