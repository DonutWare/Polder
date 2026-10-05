import "package:flutter_test/flutter_test.dart";

import "package:polder/models/manifest.dart";
import "package:polder/services/sync/download_plan.dart";

void main() {
  const remote = Manifest(
    size: 40,
    hash: "file",
    chunks: [
      ChunkRef(hash: "a", offset: 0, size: 10),
      ChunkRef(hash: "b", offset: 10, size: 10),
      ChunkRef(hash: "c", offset: 20, size: 10),
      ChunkRef(hash: "d", offset: 30, size: 10),
    ],
  );

  test("reuses local chunks at their local offsets and merges adjacent remote ranges", () {
    final plan = DownloadPlan.build(remote, {"a": const ChunkRef(hash: "a", offset: 50, size: 10)});

    expect(plan, hasLength(2));
    expect(plan.first, isA<LocalSegment>().having((segment) => segment.offset, "offset", 50));
    expect(plan.last, isA<RemoteSegment>().having((segment) => (segment.offset, segment.size), "range", (10, 30)));
    expect(DownloadPlan.remoteBytes(plan), 30);
  });

  test("without local chunks the whole file is one range", () {
    final plan = DownloadPlan.build(remote, const {});

    expect(plan.single, isA<RemoteSegment>().having((segment) => segment.size, "size", 40));
  });
}
