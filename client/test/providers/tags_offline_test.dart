import "dart:convert";

import "package:flutter_test/flutter_test.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/tags/tags_provider.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late FakePolderServer server;
  late ProviderHarness harness;

  setUp(() async {
    server = FakePolderServer()
      ..putFile("/Notes/Soup.md", utf8.encode("Tomato soup\n"))
      ..tags = [
        {"id": 1, "name": "home", "color": "#e5484d", "count": 1},
      ];
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  test("the tag list seen online is kept while the server is unreachable", () async {
    harness.container.listen(tagsProvider, (_, _) {});
    expect((await harness.container.read(tagsProvider.future)).single.name, "home");

    server.unreachable = true;
    harness.container.invalidate(tagsProvider);

    expect((await harness.container.read(tagsProvider.future)).single.name, "home");
  });

  test("tagging a note offline edits it on the device and queues the change", () async {
    final files = await harness.container.read(offlineFilesProvider.future);
    await files.pinNotes("/Notes");
    await files.pull();
    server.unreachable = true;
    harness.container.listen(tagsProvider, (_, _) {});
    final tags = harness.container.read(tagsProvider.notifier);

    final created = await tags.create("soup");
    await tags.assign(["/Notes/Soup.md"], ["home", created.name]);

    expect(utf8.decode((await files.read("/Notes/Soup.md"))!), "Tomato soup\n\n#home #soup\n");
    expect((await files.file("/Notes/Soup.md"))!.state, OfflineFileState.pending);
    expect(harness.container.read(tagsProvider).value!.map((tag) => tag.name), contains("soup"));
  });
}
