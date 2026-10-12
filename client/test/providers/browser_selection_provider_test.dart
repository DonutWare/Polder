import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/browser_selection_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";

import "../support/fake_server.dart";
import "../support/provider_harness.dart";

void main() {
  late FakePolderServer server;
  late ProviderHarness harness;

  setUp(() async {
    server = FakePolderServer()
      ..putFile("/a.txt", "a".codeUnits)
      ..putFile("/b.txt", "b".codeUnits)
      ..putFile("/c.txt", "c".codeUnits)
      ..putFile("/d.txt", "d".codeUnits);
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
    harness.container.listen(browserSelectionProvider("/"), (_, _) {});
    await harness.container.read(directoryProvider("/").future);
  });

  tearDown(() => harness.dispose());

  BrowserSelectionNotifier selection() => harness.container.read(browserSelectionProvider("/").notifier);
  Set<String> selected() => harness.container.read(browserSelectionProvider("/")).names;

  test("a click selects only that entry, a toggle adds and removes", () {
    selection()
      ..only("a.txt")
      ..only("b.txt");
    expect(selected(), {"b.txt"});

    selection().toggle("d.txt");
    expect(selected(), {"b.txt", "d.txt"});

    selection().toggle("b.txt");
    expect(selected(), {"d.txt"});
  });

  test("a range runs from the anchor in either direction and replaces the previous range", () {
    selection()
      ..only("b.txt")
      ..extendTo("d.txt");
    expect(selected(), {"b.txt", "c.txt", "d.txt"});

    selection().extendTo("a.txt");
    expect(selected(), {"a.txt", "b.txt"});
  });

  test("select all follows the listing, and selected entries keep its order", () {
    selection().selectAll();
    expect(selection().selectedEntries.map((entry) => entry.name), ["a.txt", "b.txt", "c.txt", "d.txt"]);

    selection().clear();
    expect(selected(), isEmpty);
  });

  test("entries that leave the folder drop out of the selection", () async {
    selection()
      ..only("a.txt")
      ..toggle("c.txt");
    final c = selection().selectedEntries.last;

    await harness.container.read(directoryProvider("/").notifier).delete(c);

    expect(selected(), {"a.txt"});
    expect(harness.container.read(browserSelectionProvider("/")).lead, isNull);
  });
}
