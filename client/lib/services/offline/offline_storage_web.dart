import "package:drift_flutter/drift_flutter.dart";

import "package:polder/services/api/polder_api.dart";
import "package:polder/services/offline/content_downloader.dart";
import "package:polder/services/offline/db_content_store.dart";
import "package:polder/services/offline/offline_database.dart";
import "package:polder/services/offline/offline_storage.dart";
import "package:polder/services/offline/streaming_content_downloader.dart";

Future<OfflineStorage> openOfflineStorage(String accountId) async {
  final database = OfflineDatabase(
    driftDatabase(
      name: "polder_offline_${OfflineStorage.keyFor(accountId)}",
      web: DriftWebOptions(sqlite3Wasm: Uri.parse("sqlite3.wasm"), driftWorker: Uri.parse("drift_worker.js")),
    ),
  );
  return OfflineStorage(database: database, content: DbContentStore(database));
}

ContentDownloader createContentDownloader({
  required String accountId,
  required OfflineStorage storage,
  required PolderApi api,
  required Future<DownloadRequest> Function(String path) requestFor,
  required DownloadNotificationTexts texts,
}) => StreamingContentDownloader(api: api, content: storage.content);
