import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notes/note_tags.dart";

void main() {
  test("tags are read from prose, once per name, but not from code", () {
    expect(readNoteTags("# Title\n\nShopping #home and #Home, not `#code`.\n\n#work"), ["home", "work"]);
  });

  test("a tag is appended to a trailing tag line or on a new line", () {
    expect(appendNoteTag("", "home"), "#home\n");
    expect(appendNoteTag("Text\n", "home"), "Text\n\n#home\n");
    expect(appendNoteTag("Text\n\n#work\n", "home"), "Text\n\n#work #home\n");
    expect(appendNoteTag("Text #home\n", "Home"), "Text #home\n");
  });

  test("removing a tag takes its spacing and an emptied line with it", () {
    expect(removeNoteTag("Text\n\n#work #home\n", "home"), "Text\n\n#work\n");
    expect(removeNoteTag("Buy #home milk\n", "HOME"), "Buy milk\n");
    expect(removeNoteTag("Text\n\n#home\n", "home"), "Text\n");
    expect(removeNoteTag("Text\n", "home"), "Text\n");
  });
}
