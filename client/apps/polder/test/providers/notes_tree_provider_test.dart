import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/note_item.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";

NoteItem _note(String name) => NoteItem(
  entry: FileEntry(path: "/Notes/$name", name: name, mtime: DateTime.utc(2026), mime: markdownMime),
);

NoteItem _folder(String name, {bool hasNotes = false, bool hasReadme = false}) => NoteItem(
  entry: FileEntry(path: "/Notes/$name", name: name, isDir: true, mtime: DateTime.utc(2026)),
  hasNotes: hasNotes,
  hasReadme: hasReadme,
);

void main() {
  test("a page's folder holds its children, and only folders with notes are shown", () {
    final contents = NotesTreeNotifier.arrange([
      _note("Plan.md"),
      _folder("Plan"),
      _note("Journal.md"),
      _folder("Journal", hasNotes: true),
      _folder("Wiki", hasNotes: true),
      _folder("Guide", hasReadme: true),
      _folder("attachments"),
      _note("README.md"),
    ]);
    final summary = [
      for (final node in contents.nodes) "${node.name}:${node.page != null ? "page" : "folder"}:${node.hasChildren}",
    ];
    expect(summary, ["Guide:folder:false", "Journal:page:true", "Plan:page:false", "Wiki:folder:true"]);
    expect(contents.readme?.name, "README.md");
    expect(contents.nodes[2].folder?.name, "Plan");
    expect(contents.nodes[2].childrenPath, "/Notes/Plan");
  });

  test("text files are pages named with their extension and do not take a folder's children", () {
    final contents = NotesTreeNotifier.arrange([
      NoteItem(
        entry: FileEntry(path: "/Notes/todo.txt", name: "todo.txt", mtime: DateTime.utc(2026), mime: "text/plain"),
      ),
      NoteItem(
        entry: FileEntry(path: "/Notes/todo.md", name: "todo.md", mtime: DateTime.utc(2026), mime: markdownMime),
      ),
      _folder("todo", hasNotes: true),
    ]);
    final summary = [for (final node in contents.nodes) "${node.name}:${node.folder?.name}:${node.childrenPath}"];
    expect(summary, ["todo:todo:/Notes/todo", "todo.txt:null:/Notes/todo.txt"]);
  });
}
