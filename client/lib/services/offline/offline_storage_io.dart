import "dart:io";

import "package:drift_flutter/drift_flutter.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/background_content_downloader.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/file_content_store.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/services/offline/offline_storage.dart";
import "package:polder/services/offline/streaming_content_downloader.dart";

Future<OfflineStorage> openOfflineStorage(String accountId) async {
  final key = OfflineStorage.keyFor(accountId);
  final support = await getApplicationSupportDirectory();
  final database = OfflineDatabase(
    driftDatabase(
      name: "polder_offline_$key",
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    ),
  );
  return OfflineStorage(database: database, content: FileContentStore(Directory(p.join(support.path, "offline", key))));
}

ContentDownloader createContentDownloader({
  required String accountId,
  required OfflineStorage storage,
  required PolderApi api,
  required Future<DownloadRequest> Function(String path) requestFor,
  required DownloadNotificationTexts texts,
}) => switch (storage.content) {
  final FileContentStore content => BackgroundContentDownloader(
    accountKey: OfflineStorage.keyFor(accountId),
    content: content,
    requestFor: requestFor,
    texts: texts,
  ),
  final content => StreamingContentDownloader(api: api, content: content),
};
