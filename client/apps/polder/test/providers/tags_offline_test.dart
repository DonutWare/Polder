import "dart:convert";
import "dart:typed_data";

import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/offline_models.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/providers/offline/offline_storage_provider.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_core/services/offline/offline_files.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late FakePolderServer server;
  late ProviderHarness harness;
  late OfflineFiles files;

  setUp(() async {
    server = FakePolderServer()
      ..putFile("/Notes/Soup.md", utf8.encode("Tomato soup #home\n"))
      ..putFile("/Notes/Bread.md", utf8.encode("Sourdough #home #bake\n"))
      ..putFile("/Photos/cat.jpg", [1, 2, 3])
      ..tags = [
        {"id": 1, "name": "home", "color": "#e5484d", "count": 2},
        {"id": 2, "name": "bake", "color": "#46a758", "count": 1},
      ];
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
    files = await harness.container.read(offlineFilesProvider.future);
    await files.pinNotes("/Notes");
    await files.pull();
    harness.container.listen(tagsProvider, (_, _) {});
    await harness.container.read(tagsProvider.future);
  });

  tearDown(() => harness.dispose());

  TagsNotifier tags() => harness.container.read(tagsProvider.notifier);

  List<String> names() => [for (final tag in harness.container.read(tagsProvider).value!) tag.name];

  Future<String> note(String path) async => utf8.decode((await files.read(path))!);

  Future<void> sync() async {
    server.unreachable = false;
    await files.push();
    await (await harness.container.read(offlineTagsProvider.future)).push();
    await tags().refresh();
  }

  test("the tag list seen online is kept while the server is unreachable", () async {
    server.unreachable = true;
    harness.container.invalidate(tagsProvider);

    expect(await harness.container.read(tagsProvider.future), hasLength(2));
  });

  test("tagging a note offline edits it on the device and queues the change", () async {
    server.unreachable = true;

    final created = await tags().create("soup");
    await tags().assign(["/Notes/Soup.md"], [created.name]);

    expect(await note("/Notes/Soup.md"), "Tomato soup #home\n\n#soup\n");
    expect((await files.file("/Notes/Soup.md"))!.state, OfflineFileState.pending);
    expect(names(), contains("soup"));
  });

  test("a tag renamed offline renames it in every note and on the server once back online", () async {
    server.unreachable = true;
    final home = harness.container.read(tagsByKeyProvider)["home"]!;

    await tags().edit(home, name: "house");

    expect(await note("/Notes/Soup.md"), "Tomato soup #house\n");
    expect(await note("/Notes/Bread.md"), "Sourdough #house #bake\n");
    expect(names(), ["house", "bake"]);

    await sync();

    expect(utf8.decode(server.nodes["/Notes/Bread.md"]!.bytes), "Sourdough #house #bake\n");
    expect(server.tagChanges, ["update home -> house #e5484d"]);
    expect(names(), ["house", "bake"]);
    expect(harness.container.read(tagsByKeyProvider)["house"]!.id, home.id);
  });

  test("a rename merges with the tag the server made from the synced notes", () async {
    server.unreachable = true;
    await tags().edit(harness.container.read(tagsByKeyProvider)["home"]!, name: "house");
    server.tags = [
      ...server.tags,
      {"id": 3, "name": "house", "color": "#8d8d8d", "count": 2},
    ];

    await sync();

    expect(names(), unorderedEquals(["house", "bake"]));
    expect(harness.container.read(tagsByKeyProvider)["house"]!.color, const Color(0xFFE5484D));
  });

  test("a tag deleted offline leaves every note and the server", () async {
    server.unreachable = true;

    await tags().delete(harness.container.read(tagsByKeyProvider)["bake"]!);

    expect(await note("/Notes/Bread.md"), "Sourdough #home\n");
    expect(names(), ["home"]);

    await sync();

    expect(server.tagChanges, ["delete bake"]);
    expect(names(), ["home"]);
  });

  test("changes to a tag created offline are sent in order", () async {
    server.unreachable = true;

    final created = await tags().create("soup", color: const Color(0xFF0090FF));
    await tags().edit(created, name: "stew", color: const Color(0xFF8E4EC6));
    await tags().create("later");
    await tags().delete(harness.container.read(tagsByKeyProvider)["later"]!);

    expect(names(), ["home", "bake", "stew"]);

    await sync();

    expect(server.tagChanges, ["create soup", "update soup -> stew #8e4ec6", "create later", "delete later"]);
    expect(names(), unorderedEquals(["home", "bake", "stew"]));
  });

  test("a tag created offline keeps its color when the server already made it from a note", () async {
    server.unreachable = true;
    await tags().create("soup", color: const Color(0xFF0090FF));
    server.tags = [
      ...server.tags,
      {"id": 3, "name": "soup", "color": "#8d8d8d", "count": 1},
    ];

    await sync();

    expect(harness.container.read(tagsByKeyProvider)["soup"]!.color, const Color(0xFF0090FF));
  });

  test("unused tags are removed offline, keeping ones a note or queued change still uses", () async {
    server.unreachable = true;
    await tags().create("idle");
    await tags().create("dinner");
    await tags().create("pets");
    await tags().assign(["/Notes/Soup.md"], ["dinner"]);
    await tags().assign(["/Photos/cat.jpg"], ["pets"]);

    expect(await tags().deleteUnused(), 1);
    expect(names(), unorderedEquals(["home", "bake", "dinner", "pets"]));

    await sync();

    expect(server.tagChanges.last, startsWith("delete unused"));
  });

  test("tagging a file that is not on the device is sent once back online", () async {
    server.unreachable = true;

    final results = await tags().assign(["/Photos/cat.jpg"], ["pets"]);

    expect(results.single.failed, isFalse);
    expect(names(), contains("pets"));

    await sync();

    expect(server.tagChanges, ["create pets", "assign /Photos/cat.jpg pets"]);
  });

  test("queued changes stay visible when the list is refreshed before they are sent", () async {
    server.unreachable = true;
    await tags().create("soup");
    server.unreachable = false;

    await tags().refresh();

    expect(names(), contains("soup"));
  });

  test("notes on the device take their tags from their text, not the last server listing", () async {
    await tags().assign(["/Notes/Soup.md"], ["bake"]);
    await sync();

    final soup = (await files.children("/Notes")).singleWhere((row) => row.path == "/Notes/Soup.md").entry;
    expect(soup.tagIds, [1, 2]);

    await tags().unassign(["/Notes/Soup.md"], ["bake"]);

    expect((await files.file("/Notes/Soup.md"))!.entry.tagIds, [1]);
  });

  test("tag changes made online are applied at once and sent in the background", () async {
    await tags().create("soup");

    expect(names(), contains("soup"));
    expect(server.tagChanges, isEmpty);

    await sync();

    expect(server.tagChanges, ["create soup"]);
    expect(harness.container.read(tagsByKeyProvider)["soup"]!.id, greaterThan(0));
  });

  test("a new tag typed in a note offline is added with the next color and kept once synced", () async {
    server.unreachable = true;

    await files.write("/Notes/Soup.md", Uint8List.fromList(utf8.encode("Tomato soup #home #dinner\n")));
    await pumpEventQueue();
    await tags().refresh();

    final dinner = harness.container.read(tagsByKeyProvider)["dinner"]!;
    expect(dinner.color, tagPalette[2]);
    expect((await files.file("/Notes/Soup.md"))!.entry.tagIds, [1, dinner.id]);

    await tags().edit(dinner, color: tagPalette[5]);
    await sync();

    expect(server.tagChanges, ["create dinner"]);
    expect(harness.container.read(tagsByKeyProvider)["dinner"]!.color, tagPalette[5]);
  });
}
