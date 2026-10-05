import "package:flutter_test/flutter_test.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/sync/conflict_queue_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";

import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;
  final account = testAccount();

  Conflict conflict(String path) => Conflict(syncRootId: "root", relativePath: path, kind: ConflictKind.bothModified);

  setUp(() async {
    harness = ProviderHarness(account: account);
    await harness.syncPlatform.store.saveRoot(
      SyncRoot(id: "root", accountId: account.id, localPath: "/tmp/x", remotePath: "/"),
    );
    harness.container.listen(syncRootsProvider, (_, _) {});
    await harness.container.read(syncRootsProvider.future);
  });

  tearDown(() => harness.dispose());

  ConflictQueueNotifier queue() => harness.container.read(conflictQueueProvider.notifier);

  test("enqueue replaces conflicts for the same path", () {
    queue()
      ..enqueue([conflict("a.txt"), conflict("b.txt")])
      ..enqueue([conflict("a.txt").copyWith(kind: ConflictKind.localModifiedRemoteDeleted)]);

    final state = harness.container.read(conflictQueueProvider);
    expect(state.conflicts, hasLength(2));
    expect(state.conflicts.last.kind, ConflictKind.localModifiedRemoteDeleted);
    expect(state.pausedPaths("root"), {"a.txt", "b.txt"});
  });

  test("resolving one conflict removes it from the queue", () async {
    queue().enqueue([conflict("a.txt"), conflict("b.txt")]);

    await queue().choose(conflict("a.txt"), ConflictResolution.keepMine);

    expect(harness.container.read(conflictQueueProvider).lastError, isNull);
    expect(harness.syncPlatform.service.resolved, [("a.txt", ConflictResolution.keepMine)]);
    expect(harness.container.read(conflictQueueProvider).conflicts.map((c) => c.relativePath), ["b.txt"]);
  });

  test("apply to all resolves every queued conflict the same way", () async {
    queue()
      ..enqueue([conflict("a.txt"), conflict("b.txt"), conflict("c.txt")])
      ..setApplyToAll(true);

    await queue().choose(conflict("b.txt"), ConflictResolution.keepBoth);

    expect(harness.syncPlatform.service.resolved.map((entry) => entry.$2).toSet(), {ConflictResolution.keepBoth});
    expect(harness.syncPlatform.service.resolved, hasLength(3));
    expect(harness.container.read(conflictQueueProvider).isEmpty, isTrue);
  });
}
