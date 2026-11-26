import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_commands.dart";

TextEditingValue _at(String text, [int? offset]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: offset ?? text.length),
);

void main() {
  group("continueMarkdownLine", () {
    test("continues bullets, numbers, tasks and quotes", () {
      expect(continueMarkdownLine(_at("- one"))?.text, "- one\n- ");
      expect(continueMarkdownLine(_at("  * one"))?.text, "  * one\n  * ");
      expect(continueMarkdownLine(_at("9) nine"))?.text, "9) nine\n10) ");
      expect(continueMarkdownLine(_at("- [x] done"))?.text, "- [x] done\n- [ ] ");
      expect(continueMarkdownLine(_at("> quote"))?.text, "> quote\n> ");
      expect(continueMarkdownLine(_at("> - item"))?.text, "> - item\n> - ");
    });

    test("places the caret after the new marker", () {
      final next = continueMarkdownLine(_at("1. a"))!;
      expect(next.selection, const TextSelection.collapsed(offset: 8));
    });

    test("splits the line at the caret", () {
      expect(continueMarkdownLine(_at("- abcd", 4))?.text, "- ab\n- cd");
    });

    test("replaces a selection before continuing", () {
      const value = TextEditingValue(text: "- abcd", selection: TextSelection(baseOffset: 3, extentOffset: 5));
      expect(continueMarkdownLine(value)?.text, "- a\n- d");
    });

    test("an empty item ends the list", () {
      final next = continueMarkdownLine(_at("- one\n- "))!;
      expect(next.text, "- one\n");
      expect(next.selection.baseOffset, 6);
    });

    test("an empty nested item outdents", () {
      expect(continueMarkdownLine(_at("- one\n  - "))?.text, "- one\n- ");
    });

    test("leaves plain text, headings and code alone", () {
      expect(continueMarkdownLine(_at("plain")), isNull);
      expect(continueMarkdownLine(_at("# Title")), isNull);
      expect(continueMarkdownLine(_at("```\n- not a list")), isNull);
      expect(continueMarkdownLine(_at("- item", 1)), isNull);
    });
  });

  group("removeMarkdownMarker", () {
    test("removes list, task and heading markers at content start", () {
      expect(removeMarkdownMarker(_at("- item", 2))?.text, "item");
      expect(removeMarkdownMarker(_at("  - [ ] task", 8))?.text, "  task");
      expect(removeMarkdownMarker(_at("## Head", 3))?.text, "Head");
      expect(removeMarkdownMarker(_at("> quote", 2))?.text, "quote");
    });

    test("only applies exactly at content start", () {
      expect(removeMarkdownMarker(_at("- item", 3)), isNull);
      expect(removeMarkdownMarker(_at("plain", 0)), isNull);
      expect(removeMarkdownMarker(_at("plain", 3)), isNull);
    });
  });

  group("indentMarkdownLines", () {
    test("indents and outdents list items", () {
      final indented = indentMarkdownLines(_at("- a\n- b"), outdent: false)!;
      expect(indented.text, "- a\n  - b");
      expect(indented.selection.baseOffset, 9);
      expect(indentMarkdownLines(_at("- a\n  - b"), outdent: true)?.text, "- a\n- b");
      expect(indentMarkdownLines(_at("- a\n\t- b"), outdent: true)?.text, "- a\n- b");
    });

    test("indents every list line in a selection", () {
      const value = TextEditingValue(text: "- a\n- b\ntext", selection: TextSelection(baseOffset: 1, extentOffset: 6));
      expect(indentMarkdownLines(value, outdent: false)?.text, "  - a\n  - b\ntext");
    });

    test("ignores non-list lines", () {
      expect(indentMarkdownLines(_at("plain"), outdent: false), isNull);
    });
  });
}
