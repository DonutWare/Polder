import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notes/note_checklist.dart";

void main() {
  test("parses notes made only of top-level tasks", () {
    expect(NoteChecklist.parse("- [ ] milk\n- [x] eggs\n"), const [
      ChecklistItem("milk"),
      ChecklistItem("eggs", checked: true),
    ]);
    expect(NoteChecklist.parse(NoteChecklist.empty), const [ChecklistItem("")]);
    expect(NoteChecklist.parse("- [ ]"), const [ChecklistItem("")]);
  });

  test("anything else is not a checklist", () {
    expect(NoteChecklist.parse(""), isNull);
    expect(NoteChecklist.parse("- [ ] milk\nplain"), isNull);
    expect(NoteChecklist.parse("- [ ] milk\n\n- [ ] eggs"), isNull);
    expect(NoteChecklist.parse("  - [ ] nested"), isNull);
    expect(NoteChecklist.parse("* [ ] star"), isNull);
  });

  test("serializes back to the same markdown", () {
    const text = "- [ ] milk\n- [x] eggs\n- [ ]\n- [ ] trailing ";
    expect(NoteChecklist.serialize(NoteChecklist.parse(text)!), text);
    expect(NoteChecklist.serialize(const []), NoteChecklist.empty);
  });

  test("converts text to a checklist and back", () {
    final checklist = NoteChecklist.fromText("Shopping\n\n- milk\n1. eggs\n* [x] bread");
    expect(checklist, "- [ ] Shopping\n- [ ] milk\n- [ ] eggs\n- [x] bread");
    expect(NoteChecklist.toText(NoteChecklist.parse(checklist)!), "Shopping\nmilk\neggs\nbread");
  });
}
