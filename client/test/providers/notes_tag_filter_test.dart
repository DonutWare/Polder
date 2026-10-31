import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";

FileEntry _note(String path, {List<int> tagIds = const []}) =>
    FileEntry(path: path, name: path.split("/").last, mtime: DateTime(2026), tagIds: tagIds);

void main() {
  test("the index searches only the notes folder", () {
    expect(notesFolderQuery("/Notes"), "type=md in=/Notes");
    expect(notesFolderQuery("/My Notes"), 'type=md in="/My Notes"');
  });

  test("views pick untagged notes or notes with any chosen tag", () {
    final notes = [
      _note("/Notes/plain.md"),
      _note("/Notes/soup.md", tagIds: [1]),
      _note("/Notes/plan.md", tagIds: [2]),
      FileEntry(path: "/Notes/idea.md", name: "idea.md", mtime: DateTime(2026), otherTags: const ["draft"]),
    ];
    List<String> paths(NotesView view) => notesMatching(view, notes).map((note) => note.path).toList();

    expect(paths(const UntaggedNotes()), ["/Notes/plain.md"]);
    expect(paths(const TaggedNotes({1})), ["/Notes/soup.md"]);
    expect(paths(const TaggedNotes({1, 2})), ["/Notes/soup.md", "/Notes/plan.md"]);
  });

  test("a folder page is titled by its folder", () {
    expect(noteTitleOf(_note("/Notes/Trips/README.md")), "Trips");
    expect(noteTitleOf(_note("/Notes/Trips/Rome.md")), "Rome");
  });

  test("a note takes the color of its first known tag", () {
    const red = Color(0xFFE5484D);
    final tags = {2: const UserTag(id: 2, name: "urgent", color: red)};
    expect(noteTintOf(tags, _note("/Notes/a.md", tagIds: [9, 2])), red);
    expect(noteTintOf(tags, _note("/Notes/b.md")), isNull);
  });
}
