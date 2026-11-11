import "package:polder/models/offline_models.dart";

sealed class ContentDownloadEvent {
  const ContentDownloadEvent(this.path);

  final String path;
}

final class ContentDownloadProgress extends ContentDownloadEvent {
  const ContentDownloadProgress(super.path, {required this.received, required this.total, this.fraction});

  final int received;
  final int total;
  final double? fraction;
}

final class ContentDownloadDone extends ContentDownloadEvent {
  const ContentDownloadDone(super.path, {required this.hash});

  final String hash;
}

final class ContentDownloadFailed extends ContentDownloadEvent {
  const ContentDownloadFailed(super.path, this.error);

  final Object error;
}

typedef DownloadRequest = ({Uri url, Map<String, String> headers});

typedef DownloadNotificationTexts = ({
  String runningTitle,
  String runningBody,
  String doneTitle,
  String doneBody,
  String failedTitle,
  String failedBody,
});

abstract interface class ContentDownloader {
  Stream<ContentDownloadEvent> get events;

  Future<Set<String>> queued();

  Future<void> enqueue(OfflineFile file);

  Future<void> cancel(String path);

  Future<void> clearLeftovers();

  Future<void> dispose();
}
