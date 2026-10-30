import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/screens/notes/notes_actions.dart";

import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";
import "../../support/scripted_client.dart";

FileEntry _page(String path) => FileEntry(path: path, name: path.split("/").last, mtime: DateTime.utc(2026));

FileEntry _folder(String path) =>
    FileEntry(path: path, name: path.split("/").last, isDir: true, mtime: DateTime.utc(2026));

void main() {
  final trip = NoteTreeNode(page: _page("/Notes/Trip.md"), folder: _folder("/Notes/Trip"), hasChildren: true);
  final archive = NoteTreeNode(folder: _folder("/Notes/Archive"), hasChildren: true);

  test("a page can move into another page or a parent level", () {
    expect(NotesActions.canMoveInto(trip, "/Notes/Ideas"), isTrue);
    expect(NotesActions.canMoveInto(trip, "/"), isTrue);
    expect(NotesActions.canMoveInto(archive, "/Notes/Trip"), isTrue);
  });

  test("a page cannot move to where it already is", () {
    expect(NotesActions.canMoveInto(trip, "/Notes"), isFalse);
  });

  test("a page cannot move into itself or its subpages", () {
    expect(NotesActions.canMoveInto(trip, "/Notes/Trip"), isFalse);
    expect(NotesActions.canMoveInto(trip, "/Notes/Trip/Day 1"), isFalse);
    expect(NotesActions.canMoveInto(archive, "/Notes/Archive"), isFalse);
    expect(NotesActions.canMoveInto(archive, "/Notes/Archive/2026"), isFalse);
  });

  testWidgets("deleting a page with subpages finishes after its tree row is gone", (tester) async {
    final rowShown = ValueNotifier(true);
    final client = ScriptedClient((request) async {
      if (request.method != "DELETE") return jsonResponse(200, userJson());
      rowShown.value = false;
      return emptyResponse(204);
    });
    final harness = ProviderHarness(httpClient: client, account: testAccount());
    addTearDown(harness.dispose);
    await harness.container.read(accountProvider.future);
    bool? deleted;
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Scaffold(
          body: ValueListenableBuilder(
            valueListenable: rowShown,
            builder: (_, shown, _) => shown
                ? Builder(
                    builder: (row) => TextButton(
                      onPressed: () async => deleted = await NotesActions.delete(row, trip),
                      child: const Text("row"),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.text("row"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(find.byType(SnackBar), findsNothing);
    expect(
      [for (final request in client.requests.where((request) => request.method == "DELETE")) request.query["path"]],
      ["/Notes/Trip", "/Notes/Trip.md"],
    );
  });
}
