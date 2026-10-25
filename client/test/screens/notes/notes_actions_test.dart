import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/screens/notes/notes_actions.dart";

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
}
