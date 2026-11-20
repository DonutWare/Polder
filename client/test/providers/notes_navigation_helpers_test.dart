import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/note_item.dart";
import "package:polder/providers/notes/notes_search_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";

FileEntry _page(String path, {DateTime? mtime}) => FileEntry(
  path: path,
  name: path.substring(path.lastIndexOf("/") + 1),
  mtime: mtime ?? DateTime.utc(2026),
  mime: markdownMime,
);

FileEntry _dir(String path, {DateTime? mtime}) => FileEntry(
  path: path,
  name: path.substring(path.lastIndexOf("/") + 1),
  isDir: true,
  mtime: mtime ?? DateTime.utc(2026),
);

void main() {
  final top = NotesTreeNotifier.arrange([
    NoteItem(entry: _page("/Notes/Wiki.md")),
    NoteItem(entry: _dir("/Notes/Wiki"), hasNotes: true),
    NoteItem(entry: _page("/Notes/Loose.md")),
    NoteItem(entry: _dir("/Notes/Guide"), hasNotes: true, hasReadme: true),
  ]);

  group("notesFamilyOf", () {
    test("finds the top-level parent of a nested note", () {
      expect(notesFamilyOf(top, "/Notes/Wiki/Cooking/Bread.md")?.path, "/Notes/Wiki.md");
      expect(notesFamilyOf(top, "/Notes/Wiki.md")?.path, "/Notes/Wiki.md");
      expect(notesFamilyOf(top, "/Notes/Guide/README.md")?.path, "/Notes/Guide");
    });

    test("has no family for a top-level page without children", () {
      expect(notesFamilyOf(top, "/Notes/Loose.md"), isNull);
      expect(notesFamilyOf(null, "/Notes/Wiki.md"), isNull);
    });
  });

  test("a note's grid folder is the folder that shows its card", () {
    expect(notesGridFolderFor("/Notes", "/Notes/Wiki/Bread.md"), "/Notes/Wiki");
    expect(notesGridFolderFor("/Notes", "/Notes/Wiki/Cooking/README.md"), "/Notes/Wiki");
    expect(notesGridFolderFor("/Notes", "/Notes/README.md"), "/Notes");
  });

  group("sortNoteNodes", () {
    final nodes = [
      NoteTreeNode(page: _page("/Notes/b.md", mtime: DateTime.utc(2026, 3))),
      NoteTreeNode(page: _page("/Notes/A.md", mtime: DateTime.utc(2026, 1))),
      NoteTreeNode(
        page: _page("/Notes/c.md", mtime: DateTime.utc(2026, 2)),
        folder: _dir("/Notes/c", mtime: DateTime.utc(2026, 4)),
      ),
    ];

    List<String> names(NotesSort sort) => [for (final node in sortNoteNodes(nodes, sort)) node.name];

    test("keeps the alphabetical order by default", () {
      expect(names(const NotesSort()), ["b", "A", "c"]);
    });

    test("sorts by name descending, ignoring case", () {
      expect(names(const NotesSort(ascending: false)), ["c", "b", "A"]);
    });

    test("sorts by the latest change of a page or its subpages", () {
      expect(names(const NotesSort(field: NotesSortField.modified, ascending: false)), ["c", "b", "A"]);
      expect(names(const NotesSort(field: NotesSortField.modified)), ["A", "b", "c"]);
    });
  });

  group("search", () {
    final notes = [_page("/Notes/Wiki/Cooking/Bread.md"), _page("/Notes/Bread rolls.md"), _page("/Notes/Soup.md")];

    test("matches titles regardless of case", () {
      expect(
        [for (final note in titleMatches(notes, "bread")) note.path],
        ["/Notes/Wiki/Cooking/Bread.md", "/Notes/Bread rolls.md"],
      );
    });

    test("adds content matches after title matches without duplicates", () {
      final merged = mergeNoteMatches([notes[0]], [notes[2], notes[0]]);
      expect([for (final note in merged) note.path], ["/Notes/Wiki/Cooking/Bread.md", "/Notes/Soup.md"]);
    });

    test("the tree filter shows matches and opens their ancestors", () {
      final filter = NotesTreeFilter.of("bread", "/Notes", [notes[0]]);
      final wiki = NoteTreeNode(page: _page("/Notes/Wiki.md"), folder: _dir("/Notes/Wiki"), hasChildren: true);
      final cooking = NoteTreeNode(folder: _dir("/Notes/Wiki/Cooking"), hasChildren: true);
      final soup = NoteTreeNode(page: notes[2]);
      expect(filter.shows(wiki) && filter.opens(wiki), isTrue);
      expect(filter.shows(cooking) && filter.opens(cooking), isTrue);
      expect(filter.shows(NoteTreeNode(page: notes[0])), isTrue);
      expect(filter.shows(soup), isFalse);
      expect(filter.folders.contains("/Notes"), isFalse);
    });
  });
}
