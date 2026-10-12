import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/services/api/api_exceptions.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late FakePolderServer server;
  late ProviderHarness harness;
  final account = testAccount();

  setUp(() {
    server = FakePolderServer()
      ..putFile("/b.txt", "b".codeUnits)
      ..putFile("/Photos/p.jpg", "p".codeUnits);
    harness = ProviderHarness(httpClient: SignedInServer(server), account: account);
    harness.container.listen(directoryProvider("/"), (_, _) {});
  });

  tearDown(() => harness.dispose());

  DirectoryNotifier root() => harness.container.read(directoryProvider("/").notifier);

  Future<List<String>> names() async =>
      (await harness.container.read(directoryProvider("/").future)).sortedEntries.map((entry) => entry.name).toList();

  test("lists directories first, then files by name", () async {
    expect(await names(), ["Photos", "b.txt"]);
  });

  test("creating, renaming and deleting refresh the listing", () async {
    await harness.container.read(directoryProvider("/").future);

    await root().createFolder("Music");
    expect(await names(), ["Music", "Photos", "b.txt"]);

    final file = (await harness.container.read(directoryProvider("/").future)).entries
        .firstWhere((e) => e.name == "b.txt");
    await root().rename(file, "c.txt");
    expect(await names(), ["Music", "Photos", "c.txt"]);

    final renamed = (await harness.container.read(directoryProvider("/").future)).entries
        .firstWhere((e) => e.name == "c.txt");
    await root().delete(renamed);
    expect(await names(), ["Music", "Photos"]);
  });

  test("moving into a folder removes it here", () async {
    final listing = await harness.container.read(directoryProvider("/").future);
    final file = listing.entries.firstWhere((entry) => entry.name == "b.txt");

    await root().moveTo(file, "/Photos");

    expect(await names(), ["Photos"]);
    expect(server.contentOf("/Photos/b.txt"), isNotNull);
  });

  test("keeps refreshing while the server is indexing, then stops", () {
    fakeAsync((async) {
      server.indexing = true;
      final indexing = ProviderHarness(httpClient: SignedInServer(server), account: account);
      indexing.container.read(accountProvider.future);
      async.flushMicrotasks();
      indexing.container.listen(directoryProvider("/"), (_, _) {});
      async.flushMicrotasks();
      expect(indexing.container.read(directoryProvider("/")).requireValue.indexing, isTrue);

      server
        ..putFile("/found.txt", "f".codeUnits)
        ..indexing = false;
      async.elapse(DirectoryNotifier.indexingRefresh);
      final listing = indexing.container.read(directoryProvider("/")).requireValue;
      expect(listing.indexing, isFalse);
      expect(listing.entries.map((entry) => entry.name), contains("found.txt"));

      final requests = server.requests.length;
      async.elapse(DirectoryNotifier.indexingRefresh * 3);
      expect(server.requests.length, requests);
      indexing.dispose();
    });
  });

  test("a stale rev surfaces a conflict", () async {
    final listing = await harness.container.read(directoryProvider("/").future);
    final file = listing.entries.firstWhere((entry) => entry.name == "b.txt");
    server.putFile("/b.txt", "changed".codeUnits);

    await expectLater(root().delete(file), throwsA(isA<ConflictException>()));
  });

  test("deleting several entries tries each and refreshes once, even when one fails", () async {
    server.putFile("/c.txt", "c".codeUnits);
    await root().refresh();
    final listing = await harness.container.read(directoryProvider("/").future);
    final b = listing.entries.firstWhere((entry) => entry.name == "b.txt");
    final c = listing.entries.firstWhere((entry) => entry.name == "c.txt");
    server.putFile("/b.txt", "changed".codeUnits);

    await expectLater(root().deleteAll([b, c]), throwsA(isA<ConflictException>()));

    expect(await names(), ["Photos", "b.txt"]);
  });

  test("copying keeps the original and names a copy into the same folder after it", () async {
    final listing = await harness.container.read(directoryProvider("/").future);
    final file = listing.entries.firstWhere((entry) => entry.name == "b.txt");
    final folder = listing.entries.firstWhere((entry) => entry.name == "Photos");

    await root().copyAllTo([file], "/", copySuffix: "copy");
    await root().copyAllTo([file, folder], "/", copySuffix: "copy");
    await root().copyAllTo([file], "/Photos", copySuffix: "copy");

    expect(await names(), ["Photos", "Photos (copy)", "b (copy 2).txt", "b (copy).txt", "b.txt"]);
    expect(server.contentOf("/Photos (copy)/p.jpg"), isNotNull);
    expect(server.contentOf("/Photos/b.txt"), "b".codeUnits);
  });
}
