import "package:flutter_test/flutter_test.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";

void main() {
  group("lines", () {
    test("classifies headings, lists, tasks and quotes", () {
      const text = "# Title\n- item\n  * nested\n3. third\n- [x] done\n> quote\n> - quoted item\nplain";
      final kinds = MarkdownSource.parse(text).lines.map((line) => line.kind).toList();
      expect(kinds, [
        MarkdownLineKind.heading,
        MarkdownLineKind.bullet,
        MarkdownLineKind.bullet,
        MarkdownLineKind.ordered,
        MarkdownLineKind.task,
        MarkdownLineKind.quote,
        MarkdownLineKind.bullet,
        MarkdownLineKind.paragraph,
      ]);
    });

    test("records marker, content and checkbox offsets", () {
      const text = "  - [ ] task";
      final line = MarkdownSource.parse(text).lines.single;
      expect(line.markerStart, 2);
      expect(line.checkbox, 4);
      expect(line.contentStart, 8);
      expect(line.level, 2);
    });

    test("heading level and quoted list prefix", () {
      final source = MarkdownSource.parse("### Three\n> 1. one");
      expect(source.lines.first.level, 3);
      expect(source.lines.first.contentStart, 4);
      final quoted = source.lines.last;
      expect(quoted.quoteEnd, quoted.start + 2);
      expect(quoted.kind, MarkdownLineKind.ordered);
    });

    test("bold at line start is not a bullet", () {
      expect(MarkdownSource.parse("**bold**").lines.single.kind, MarkdownLineKind.paragraph);
    });

    test("lineAt finds the containing line", () {
      final source = MarkdownSource.parse("one\ntwo\n\nfour");
      expect(source.lineAt(0).index, 0);
      expect(source.lineAt(3).index, 0);
      expect(source.lineAt(4).index, 1);
      expect(source.lineAt(8).index, 2);
      expect(source.lineAt(13).index, 3);
    });
  });

  group("blocks", () {
    test("fenced code spans to its closing fence", () {
      const text = "before\n```dart\nfinal a = 1;\n```\nafter";
      final source = MarkdownSource.parse(text);
      final block = source.blocks.single;
      expect(block.kind, MarkdownBlockKind.code);
      expect(text.substring(block.start, block.end), "```dart\nfinal a = 1;\n```");
      expect(source.lines.last.block, isNull);
    });

    test("an unclosed fence runs to the end", () {
      final block = MarkdownSource.parse("```\ncode\nmore").blocks.single;
      expect(block.end, "```\ncode\nmore".length);
    });

    test("tables need a delimiter row", () {
      const table = "| a | b |\n|---|---|\n| 1 | 2 |";
      expect(MarkdownSource.parse("$table\n\nafter").blocks.single.kind, MarkdownBlockKind.table);
      expect(MarkdownSource.parse("a | b\nplain").blocks, isEmpty);
    });

    test("callouts include their quoted body", () {
      const text = "> [!NOTE] Title\n> body\n> more\nafter";
      final block = MarkdownSource.parse(text).blocks.single;
      expect(block.kind, MarkdownBlockKind.callout);
      expect(text.substring(block.start, block.end), "> [!NOTE] Title\n> body\n> more");
    });

    test("rules need a blank line before them", () {
      expect(MarkdownSource.parse("text\n\n---").blocks.single.kind, MarkdownBlockKind.rule);
      expect(MarkdownSource.parse("text\n---").blocks, isEmpty);
    });

    test("markdown inside code blocks is not parsed", () {
      final source = MarkdownSource.parse("```\n# not a heading\n- nor a list\n```");
      expect(source.lines.every((line) => line.block != null), isTrue);
      expect(source.inlinesOf(source.lines[1]), isEmpty);
    });
  });

  group("inlines", () {
    List<MarkdownInline> parse(String text) => parseInlines(text, 0, text.length);

    test("emphasis kinds and nesting", () {
      final nodes = parse("**bold *both*** _em_ ~~gone~~ ==mark==");
      expect(nodes.map((node) => node.kind), [
        MarkdownInlineKind.strong,
        MarkdownInlineKind.emphasis,
        MarkdownInlineKind.strikethrough,
        MarkdownInlineKind.highlight,
      ]);
      expect(nodes.first.children.single.kind, MarkdownInlineKind.emphasis);
    });

    test("delimiters need content next to them", () {
      expect(parse("a * b * c"), isEmpty);
      expect(parse("snake_case_name"), isEmpty);
      expect(parse("**"), isEmpty);
    });

    test("code spans hide markdown inside them", () {
      final node = parse("`**not bold**`").single;
      expect(node.kind, MarkdownInlineKind.code);
      expect(node.children, isEmpty);
      expect(parse("``a ` b``").single.contentEnd, 7);
    });

    test("links, images and their destinations", () {
      const text = "[label **x**](a/b.md) ![alt](<my pic.png> \"title\")";
      final nodes = parse(text);
      final link = nodes.first;
      expect(link.kind, MarkdownInlineKind.link);
      expect(text.substring(link.destinationStart!, link.destinationEnd!), "a/b.md");
      expect(link.children.single.kind, MarkdownInlineKind.strong);
      final image = nodes.last;
      expect(image.kind, MarkdownInlineKind.image);
      expect(text.substring(image.destinationStart!, image.destinationEnd!), "my pic.png");
      expect(image.end, text.length);
    });

    test("bare urls stop before trailing punctuation", () {
      const text = "see https://example.com/a_(b). next";
      final node = parse(text).single;
      expect(node.kind, MarkdownInlineKind.url);
      expect(text.substring(node.start, node.end), "https://example.com/a_(b");
    });

    test("escapes keep delimiters literal", () {
      final nodes = parse(r"\*not em\*");
      expect(nodes.map((node) => node.kind), [MarkdownInlineKind.escape, MarkdownInlineKind.escape]);
    });

    test("inlineAt finds the innermost matching node", () {
      final source = MarkdownSource.parse("x [a **b**](t) y");
      final link = source.inlineAt(7, (node) => node.kind == MarkdownInlineKind.link);
      expect(link?.kind, MarkdownInlineKind.link);
      expect(source.inlineAt(0, (_) => true), isNull);
    });
  });
}
