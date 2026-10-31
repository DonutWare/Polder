import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/models/user_tag.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor_style.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";
import "package:polder/screens/notes/editor/markdown_editor/tag_autocomplete.dart";

const _style = MarkdownEditorStyle(
  body: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
  code: TextStyle(fontFamily: "monospace"),
  link: TextStyle(color: Colors.blue),
  syntaxColor: Colors.grey,
  accentColor: Colors.blue,
  quoteColor: Colors.grey,
  highlightColor: Colors.yellow,
  codeBackground: Color(0xFFEEEEEE),
);

const _tags = [
  UserTag(id: 1, name: "work", color: Colors.red, count: 4),
  UserTag(id: 2, name: "workshop", color: Colors.green, count: 1),
  UserTag(id: 3, name: "home", color: Colors.blue, count: 2),
];

TagQuery? _queryAt(String text, [int? caret]) => tagQueryAt(
  MarkdownSource.parse(text),
  TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: caret ?? text.length),
  ),
);

Future<MarkdownEditingController> _pump(WidgetTester tester, String text) async {
  final controller = MarkdownEditingController(text: text);
  addTearDown(controller.dispose);
  controller.selection = TextSelection.collapsed(offset: text.length);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MarkdownEditor(
          controller: controller,
          style: _style,
          imageFor: (_) => const AssetImage("none"),
          tags: _tags,
          newTagLabel: "New tag",
        ),
      ),
    ),
  );
  await tester.showKeyboard(find.byType(TextField));
  await tester.pump();
  return controller;
}

Future<void> _type(WidgetTester tester, MarkdownEditingController controller, String text) async {
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group("tagQueryAt", () {
    test("finds the tag being typed", () {
      final query = _queryAt("Plan #wo");
      expect(query?.start, 5);
      expect(query?.partial, "wo");
    });

    test("a lone hash starts a query", () {
      final query = _queryAt("Plan #");
      expect(query?.start, 5);
      expect(query?.partial, "");
    });

    test("ignores headings, words and code", () {
      expect(_queryAt("# Title"), isNull);
      expect(_queryAt("##"), isNull);
      expect(_queryAt("mail a#b"), isNull);
      expect(_queryAt("see `#co`", 8), isNull);
      expect(_queryAt("- item", 1), isNull);
      expect(_queryAt("```\n#fenced"), isNull);
    });

    test("covers the rest of the word after the caret", () {
      expect(_queryAt("#workday", 3)?.end, 8);
    });
  });

  test("options rank matches and offer a new tag", () {
    final options = tagOptions(_tags, "wor");
    expect(options.map((option) => option.name), ["work", "workshop", "wor"]);
    expect(options.last.isNew, isTrue);
    expect(tagOptions(_tags, "work").where((option) => option.isNew), isEmpty);
  });

  test("an empty query lists every tag alphabetically", () {
    expect(tagOptions(_tags, "").map((option) => option.name), ["home", "work", "workshop"]);
  });

  test("accepting replaces the token and adds a space", () {
    const text = "Plan #wo today";
    final value = acceptTag(
      const TextEditingValue(text: text, selection: TextSelection.collapsed(offset: 8)),
      const TagQuery(start: 5, end: 8, partial: "wo"),
      "work",
    );
    expect(value.text, "Plan #work today");
    expect(value.selection.baseOffset, 11);
  });

  test("markdown source parses tags as inlines", () {
    const text = "Plan #work and `#code`, #1 a#b #project/x.";
    final source = MarkdownSource.parse(text);
    final tags = source.inlinesOf(source.lines.single).where((node) => node.kind == MarkdownInlineKind.tag);
    expect([for (final tag in tags) text.substring(tag.contentStart, tag.contentEnd)], ["work", "project/x"]);
  });

  testWidgets("typing a tag shows suggestions and enter accepts the highlighted one", (tester) async {
    final controller = await _pump(tester, "");
    await _type(tester, controller, "Plan #wo");
    expect(find.text("#work"), findsOneWidget);
    expect(find.text("#workshop"), findsOneWidget);
    expect(find.text("#home"), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controller.text, "Plan #workshop ");
    expect(find.text("#work"), findsNothing);
  });

  testWidgets("escape dismisses suggestions until another tag starts", (tester) async {
    final controller = await _pump(tester, "");
    await _type(tester, controller, "#ho");
    expect(find.text("#home"), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text("#home"), findsNothing);
    await _type(tester, controller, "#hom");
    expect(find.text("#home"), findsNothing);
  });

  testWidgets("a lone hash shows every tag", (tester) async {
    final controller = await _pump(tester, "");
    await _type(tester, controller, "Plan #");
    expect(find.text("#home"), findsOneWidget);
    expect(find.text("#work"), findsOneWidget);
    expect(find.text("#workshop"), findsOneWidget);
  });

  testWidgets("a hash at the start of a new line suggests tags instead of starting a heading", (tester) async {
    final controller = await _pump(tester, "");
    await _type(tester, controller, "Intro\n#");
    expect(find.text("#home"), findsOneWidget);
    expect(MarkdownSource.parse("Intro\n#").lines.last.kind, MarkdownLineKind.paragraph);
    expect(MarkdownSource.parse("Intro\n# Title").lines.last.kind, MarkdownLineKind.heading);
  });

  testWidgets("tapping a suggestion accepts it", (tester) async {
    final controller = await _pump(tester, "");
    await _type(tester, controller, "#h");
    await tester.tap(find.text("#home"));
    await tester.pump();
    expect(controller.text, "#home ");
  });
}
