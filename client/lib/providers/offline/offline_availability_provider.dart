import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/util/remote_path.dart";

enum OfflineOrigin { none, notes, user, excluded }

enum OfflineAvailability { none, waiting, downloading, available, failed }

class OfflineStatus {
  const OfflineStatus(this.origin, this.availability, {this.progress, this.done = 0, this.total = 0, this.error});

  static const none = OfflineStatus(OfflineOrigin.none, OfflineAvailability.none);

  final OfflineOrigin origin;
  final OfflineAvailability availability;
  final double? progress;
  final int done;
  final int total;
  final Object? error;
}

typedef OfflineDownloads = ({Map<String, OfflineDownload> active, Map<String, DownloadFailure> failed});

final offlineDownloadsProvider = StreamProvider<OfflineDownloads>((ref) async* {
  final files = await ref.watch(offlineFilesProvider.future);
  OfflineDownloads snapshot() => (active: files.activeDownloads, failed: files.failedDownloads);
  yield snapshot();
  await for (final _ in files.downloadsChanged) {
    yield snapshot();
  }
});

final offlineCountsProvider = StreamProvider.autoDispose.family<OfflineCounts, String>((ref, path) {
  final skip = ref.watch(
    offlinePinsProvider.select(
      (pins) => {
        for (final nested in pins.nestedIn(path))
          if (nested.kind != OfflinePinKind.user) nested.path,
      }.join("\n"),
    ),
  );
  final controller = StreamController<OfflineCounts>();
  Timer? pending;
  StreamSubscription<void>? subscription;
  ref.onDispose(() {
    pending?.cancel();
    unawaited(subscription?.cancel());
    unawaited(controller.close());
  });
  unawaited(
    ref.watch(offlineFilesProvider.future).then((files) {
      Future<void> publish() async {
        try {
          final counts = await files.counts(path, skip: skip.isEmpty ? const [] : skip.split("\n"));
          if (!controller.isClosed) controller.add(counts);
        } on StateError {
          return;
        }
      }

      subscription = files.changes.listen((_) {
        pending?.cancel();
        pending = Timer(const Duration(milliseconds: 250), () => unawaited(publish()));
      });
      return publish();
    }, onError: (Object _) {}),
  );
  return controller.stream;
});

final offlineStatusProvider = Provider.autoDispose.family<OfflineStatus, String>((ref, path) {
  final governing = ref.watch(offlinePinsProvider.select((pins) => pins.governing(path)));
  final origin = switch (governing?.kind) {
    null => OfflineOrigin.none,
    OfflinePinKind.notes => OfflineOrigin.notes,
    OfflinePinKind.user => OfflineOrigin.user,
    OfflinePinKind.excluded => OfflineOrigin.excluded,
  };
  if (governing == null || origin != OfflineOrigin.user) return OfflineStatus(origin, OfflineAvailability.none);
  final counts = ref.watch(offlineCountsProvider(path)).value;
  const waiting = OfflineStatus(OfflineOrigin.user, OfflineAvailability.waiting);
  if (!governing.populated || counts == null) return waiting;
  if (counts.ready >= counts.files) return const OfflineStatus(OfflineOrigin.user, OfflineAvailability.available);
  final downloads = ref.watch(offlineDownloadsProvider).value;
  bool under(String candidate) => candidate == path || RemotePath.isWithin(candidate, path);
  final inFlight = [
    for (final MapEntry(key: downloading, value: download) in (downloads?.active ?? const {}).entries)
      if (under(downloading)) download,
  ];
  final failure = [
    for (final MapEntry(key: failed, value: failure) in (downloads?.failed ?? const {}).entries)
      if (under(failed)) failure,
  ].firstOrNull;
  final receivedBytes = inFlight.fold<int>(0, (sum, download) => sum + download.countedBytes);
  final availability = switch ((inFlight.any((download) => download.received > 0), failure)) {
    (true, _) => OfflineAvailability.downloading,
    (false, _?) when inFlight.isEmpty => OfflineAvailability.failed,
    _ => OfflineAvailability.waiting,
  };
  return OfflineStatus(
    OfflineOrigin.user,
    availability,
    progress: counts.bytes <= 0 ? null : ((counts.readyBytes + receivedBytes) / counts.bytes).clamp(0.0, 1.0),
    done: counts.ready,
    total: counts.files,
    error: failure?.error,
  );
});

final offlinePinsProvider = NotifierProvider<OfflinePinsNotifier, List<OfflinePin>>(OfflinePinsNotifier.new);

class OfflinePinsNotifier extends Notifier<List<OfflinePin>> {
  @override
  List<OfflinePin> build() {
    final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
    if (accountId == null) return const [];
    followOfflineStore(ref, _refresh);
    return const [];
  }

  Future<void> makeAvailableOffline(String path) async =>
      (await ref.read(offlineFilesProvider.future)).makeAvailableOffline(path);

  Future<void> removeFromDevice(String path) async =>
      (await ref.read(offlineFilesProvider.future)).removeFromDevice(path);

  Future<void> _refresh(OfflineStore store) async {
    final pins = await store.pins();
    if (ref.mounted && !listEquals(state, pins)) state = pins;
  }
}
