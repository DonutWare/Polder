// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'core_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoreLocalizationsEn extends CoreLocalizations {
  CoreLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String browserSignInFinishedTitle(String app) {
    return 'Back to $app';
  }

  @override
  String browserSignInFinished(String app) {
    return 'You can close this tab and go back to $app.';
  }

  @override
  String get offlineDownloadsTitle => 'Syncing files for offline use';

  @override
  String offlineDownloadsProgress(String finished, String total) {
    return '$finished of $total files';
  }

  @override
  String get offlineDownloadsDoneTitle => 'Files available offline';

  @override
  String offlineDownloadsDone(String total) {
    return '$total files are ready to use offline';
  }

  @override
  String get offlineDownloadsFailedTitle => 'Some files couldn\'t be downloaded';

  @override
  String offlineDownloadsFailed(String failed, String total) {
    return '$failed of $total failed; they will be tried again';
  }
}
