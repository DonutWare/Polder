import "dart:async";

import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/l10n/device_core_localizations.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/offline/offline_sync_provider.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_core/services/api/polder_api.dart";
import "package:polder_core/services/offline/content_downloader.dart";
import "package:polder_core/services/offline/offline_files.dart";
import "package:polder_core/services/offline/offline_storage.dart";
import "package:polder_core/services/offline/offline_store.dart";
import "package:polder_core/services/offline/offline_tags.dart";

final offlineStorageOpenerProvider = Provider<Future<OfflineStorage> Function(String accountId)>(
  (ref) => openOfflineStorage,
);

final offlineStorageProvider = FutureProvider<OfflineStorage>((ref) async {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) throw StateError("No account is signed in");
  final storage = await ref.watch(offlineStorageOpenerProvider)(accountId);
  ref.onDispose(() => unawaited(storage.database.close()));
  return storage;
});

final offlineStoreProvider = FutureProvider<OfflineStore>((ref) async {
  final store = OfflineStore((await ref.watch(offlineStorageProvider.future)).database);
  ref.onDispose(() => unawaited(store.dispose()));
  return store;
});

void followOfflineStore(Ref ref, Future<void> Function(OfflineStore store) refresh) {
  OfflineStore? followed;
  StreamSubscription<void>? subscription;
  Timer? pending;
  Future<void> guarded(OfflineStore store) async {
    try {
      await refresh(store);
    } on StateError {
      return;
    }
  }

  void stop() {
    pending?.cancel();
    unawaited(subscription?.cancel());
  }

  ref.onDispose(stop);
  ref.listen(offlineStoreProvider, (_, next) {
    final store = next.value;
    if (store == null || identical(store, followed)) return;
    stop();
    followed = store;
    subscription = store.changes.listen((_) {
      pending?.cancel();
      pending = Timer(const Duration(milliseconds: 150), () => unawaited(guarded(store)));
    });
    unawaited(guarded(store));
  }, fireImmediately: true);
}

typedef ContentDownloaderFactory = ContentDownloader Function({
  required String accountId,
  required OfflineStorage storage,
  required PolderApi api,
  required Future<DownloadRequest> Function(String path) requestFor,
  required DownloadNotificationTexts texts,
});

final contentDownloaderFactoryProvider = Provider<ContentDownloaderFactory>((ref) => createContentDownloader);

final offlineFilesProvider = FutureProvider<OfflineFiles>((ref) async {
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  if (accountId == null) throw StateError("No account is signed in");
  final storage = await ref.watch(offlineStorageProvider.future);
  final api = ref.watch(polderApiProvider);
  final downloader = ref.watch(contentDownloaderFactoryProvider)(
    accountId: accountId,
    storage: storage,
    api: api,
    requestFor: _DownloadRequests(ref, api).forPath,
    texts: _notificationTexts(),
  );
  final files = OfflineFiles(
    api: api,
    store: await ref.watch(offlineStoreProvider.future),
    content: storage.content,
    downloader: downloader,
    onWork: (work) => ref.read(offlineSyncProvider.notifier).request(work),
    notesOnDemand: kIsWeb,
  );
  ref.onDispose(() async {
    await files.dispose();
    await downloader.dispose();
  });
  return files;
});

final offlineTagsProvider = FutureProvider<OfflineTags>((ref) async {
  final tags = OfflineTags(
    api: ref.watch(polderApiProvider),
    store: await ref.watch(offlineStoreProvider.future),
    files: await ref.watch(offlineFilesProvider.future),
    nextColor: nextTagColor,
    onQueued: () => ref.read(offlineSyncProvider.notifier).request(OfflineWork.push),
  );
  ref.onDispose(() => unawaited(tags.dispose()));
  return tags;
});

class _DownloadRequests {
  _DownloadRequests(this._ref, this._api);

  static const tokenCheckInterval = Duration(minutes: 5);

  final Ref _ref;
  final PolderApi _api;
  DateTime? _checkedAt;

  Future<DownloadRequest> forPath(String path) async {
    await _keepTokenFresh();
    final account = _ref.read(currentAccountProvider);
    if (account == null) throw StateError("No account is signed in");
    return (
      url: DownloadPurpose.cache.contentUrl(account.serverUrl, path),
      headers: {"Authorization": "Bearer ${account.accessToken}"},
    );
  }

  Future<void> _keepTokenFresh() async {
    final checked = _checkedAt;
    if (checked != null && DateTime.now().difference(checked) < tokenCheckInterval) return;
    await _api.me();
    _checkedAt = DateTime.now();
  }
}

DownloadNotificationTexts _notificationTexts() {
  final localized = deviceCoreLocalizations();
  return (
    runningTitle: localized.offlineDownloadsTitle,
    runningBody: localized.offlineDownloadsProgress("{numFinished}", "{numTotal}"),
    doneTitle: localized.offlineDownloadsDoneTitle,
    doneBody: localized.offlineDownloadsDone("{numTotal}"),
    failedTitle: localized.offlineDownloadsFailedTitle,
    failedBody: localized.offlineDownloadsFailed("{numFailed}", "{numTotal}"),
  );
}
