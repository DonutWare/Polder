import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notes/format_actions.dart";

TextEditingValue _value(String text, int start, [int? end]) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: start, extentOffset: end ?? start),
);

void main() {
  test("wraps and unwraps the selection", () {
    final bold = FormatActions.wrap(_value("make this bold", 10, 14), "**");
    expect(bold.text, "make this **bold**");
    expect(bold.selection, const TextSelection(baseOffset: 12, extentOffset: 16));
    expect(FormatActions.wrap(bold, "**").text, "make this bold");
  });

  test("an empty selection gets the marks with the cursor between them", () {
    final value = FormatActions.wrap(_value("ab", 1), "`");
    expect(value.text, "a``b");
    expect(value.selection.baseOffset, 2);
  });

  test("line prefixes replace existing marks and toggle off", () {
    const text = "first\nsecond\nthird";
    final listed = FormatActions.linePrefix(_value(text, 0, 12), "- ");
    expect(listed.text, "- first\n- second\nthird");
    expect(
      FormatActions.linePrefix(
        listed.copyWith(selection: const TextSelection(baseOffset: 0, extentOffset: 16)),
        "- ",
      ).text,
      text,
    );
    expect(FormatActions.linePrefix(_value("# Title", 3), "## ").text, "## Title");
    expect(FormatActions.linePrefix(_value("- a\n- b", 0, 7), "1. ").text, "1. a\n2. b");
    expect(FormatActions.linePrefix(_value("- a", 0), "- [ ] ").text, "- [ ] a");
  });

  test("blocks are separated from the text around them", () {
    final value = FormatActions.insertBlock(_value("before\nafter", 6), "---");
    expect(value.text, "before\n\n---\n\nafter");
  });
}
