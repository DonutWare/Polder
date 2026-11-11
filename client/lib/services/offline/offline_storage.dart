import "package:crypto/crypto.dart";

import "dart:convert";

import "package:polder/services/offline/content_store.dart";
import "package:polder/services/offline/offline_database.dart";

export "package:polder/services/offline/offline_storage_web.dart"
    if (dart.library.io) "package:polder/services/offline/offline_storage_io.dart";

class OfflineStorage {
  const OfflineStorage({required this.database, required this.content});

  final OfflineDatabase database;
  final OfflineContentStore content;

  static String keyFor(String accountId) => sha1.convert(utf8.encode(accountId)).toString().substring(0, 16);
}
