import "package:polder/models/manifest.dart";

sealed class DownloadSegment {
  const DownloadSegment({required this.offset, required this.size});

  final int offset;
  final int size;
}

class LocalSegment extends DownloadSegment {
  const LocalSegment({required super.offset, required super.size});
}

class RemoteSegment extends DownloadSegment {
  const RemoteSegment({required super.offset, required super.size});
}

abstract final class DownloadPlan {
  static List<DownloadSegment> build(Manifest remote, Map<String, ChunkRef> localChunks) {
    final segments = <DownloadSegment>[];
    for (final chunk in remote.chunks) {
      final local = localChunks[chunk.hash];
      final previous = segments.lastOrNull;
      if (local != null) {
        segments.add(LocalSegment(offset: local.offset, size: local.size));
      } else if (previous is RemoteSegment && previous.offset + previous.size == chunk.offset) {
        segments[segments.length - 1] = RemoteSegment(offset: previous.offset, size: previous.size + chunk.size);
      } else {
        segments.add(RemoteSegment(offset: chunk.offset, size: chunk.size));
      }
    }
    return segments;
  }

  static int remoteBytes(List<DownloadSegment> segments) =>
      segments.whereType<RemoteSegment>().fold(0, (sum, segment) => sum + segment.size);
}
