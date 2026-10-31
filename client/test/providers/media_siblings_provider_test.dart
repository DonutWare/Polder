import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_sort.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/media_siblings_provider.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late ProviderHarness harness;

  setUp(() async {
    final server = FakePolderServer()
      ..putFile("/photos/b.jpg", "b".codeUnits, mtime: DateTime.utc(2026, 1, 3))
      ..putFile("/photos/a.png", "a".codeUnits, mtime: DateTime.utc(2026, 1, 1))
      ..putFile("/photos/c.mp4", "c".codeUnits, mtime: DateTime.utc(2026, 1, 2))
      ..putFile("/photos/notes.txt", "n".codeUnits)
      ..putFile("/photos/nested/d.jpg", "d".codeUnits);
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
  });

  tearDown(() => harness.dispose());

  List<String>? siblings() => harness.container.read(mediaSiblingsProvider("/photos"))?.map((e) => e.name).toList();

  test("is unknown until the folder is listed", () {
    harness.container.listen(mediaSiblingsProvider("/photos"), (_, _) {});
    expect(siblings(), isNull);
  });

  test("keeps only the photos and videos of the folder, in the browser's sort order", () async {
    harness.container.listen(mediaSiblingsProvider("/photos"), (_, _) {});
    await harness.container.read(directoryProvider("/photos").future);
    expect(siblings(), ["a.png", "b.jpg", "c.mp4"]);

    harness.container.read(browserSortProvider.notifier).select(FileSortField.modified);
    expect(siblings(), ["a.png", "c.mp4", "b.jpg"]);
  });
}
