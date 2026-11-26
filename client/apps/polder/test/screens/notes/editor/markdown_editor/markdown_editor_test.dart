import "dart:convert";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor_style.dart";

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

const _document = """# Title
Some **bold**, *em*, `code`, ~~gone~~ and [a link](notes/other.md).
- item one
  - nested
1. first
- [ ] open task
- [x] done task
> quoted
![pic](pic.png)
Inline ![icon](icon.png) image and https://example.com url.

```dart
final a = 1;
```

| a | b |
|---|---|
| 1 | 2 |

> [!NOTE] Callout
> body

---
Tail""";

final _png = base64Decode(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
);

Future<MarkdownEditingController> _pump(
  WidgetTester tester,
  String text, {
  int? caret,
  void Function(String destination)? onLinkTap,
  void Function(String destination)? onImageTap,
  bool blocks = true,
}) async {
  final controller = MarkdownEditingController(text: text);
  addTearDown(controller.dispose);
  if (caret != null) controller.selection = TextSelection.collapsed(offset: caret);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MarkdownEditor(
          controller: controller,
          style: _style,
          imageFor: (_) => MemoryImage(_png),
          onLinkTap: onLinkTap,
          onImageTap: onImageTap,
          blockBuilder: blocks ? (context, block, source) => Text("rendered ${block.kind.name}") : null,
        ),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

TextSpan _projection(WidgetTester tester, MarkdownEditingController controller) => controller.buildTextSpan(
  context: tester.element(find.byType(TextField)),
  style: const TextStyle(),
  withComposing: true,
);

Iterable<TextSpan> _textSpans(InlineSpan span) sync* {
  if (span is TextSpan) {
    if (span.text != null) yield span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _textSpans(child);
    }
  }
}

bool _hidden(TextSpan span) => (span.style?.fontSize ?? 1) < 0.1;

String _visible(TextSpan root) => _textSpans(root).where((span) => !_hidden(span)).map((span) => span.text).join();

Future<void> _focus(WidgetTester tester) async {
  await tester.showKeyboard(find.byType(TextField));
  await tester.pump();
}

void main() {
  testWidgets("projection keeps source length for every caret position", (tester) async {
    final controller = await _pump(tester, _document);
    await _focus(tester);
    for (var offset = 0; offset <= _document.length; offset++) {
      controller.selection = TextSelection.collapsed(offset: offset);
      final span = _projection(tester, controller);
      expect(span.toPlainText().length, _document.length, reason: "caret at $offset");
    }
  });

  testWidgets("hides syntax away from the caret and reveals it on the caret", (tester) async {
    const text = "**bold** and [link](x.md)\n# Head";
    final controller = await _pump(tester, text, caret: text.length);
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: 0);
    var visible = _visible(_projection(tester, controller));
    expect(visible, contains("**bold**"));
    expect(visible, contains("link"));
    expect(visible, isNot(contains("](x.md)")));
    expect(visible, isNot(contains("# ")));

    controller.selection = const TextSelection.collapsed(offset: text.length);
    visible = _visible(_projection(tester, controller));
    expect(visible, startsWith("bold and link"));
    expect(visible, contains("# Head"));
  });

  testWidgets("without focus everything renders", (tester) async {
    const text = "**bold**";
    final controller = await _pump(tester, text, caret: 2);
    expect(_visible(_projection(tester, controller)), "bold");
  });

  testWidgets("bullets render as dots until the marker is reached", (tester) async {
    const text = "- item";
    final controller = await _pump(tester, text, caret: text.length);
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: 6);
    expect(_visible(_projection(tester, controller)), "• item");
    controller.selection = const TextSelection.collapsed(offset: 1);
    expect(_visible(_projection(tester, controller)), "- item");
  });

  testWidgets("checkbox tap toggles the task without moving the caret", (tester) async {
    const text = "- [ ] task\nnext";
    final controller = await _pump(tester, text, caret: text.length);
    await _focus(tester);
    await tester.tap(find.byIcon(Icons.check_box_outline_blank_rounded));
    await tester.pump();
    expect(controller.text, "- [x] task\nnext");
    expect(controller.selection, const TextSelection.collapsed(offset: text.length));
    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
    controller.undo();
    expect(controller.text, text);
  });

  testWidgets("blocks render with the block builder until the caret enters", (tester) async {
    const text = "intro\n\n```\ncode\n```\n\nafter";
    final controller = await _pump(tester, text, caret: 0);
    await _focus(tester);
    expect(find.text("rendered code"), findsOneWidget);
    await tester.tap(find.text("rendered code"));
    await tester.pump();
    expect(controller.selection.baseOffset, text.indexOf("code\n"));
    expect(find.text("rendered code"), findsNothing);
    expect(_visible(_projection(tester, controller)), contains("```\ncode\n```"));
  });

  testWidgets("rules render without a block builder", (tester) async {
    await _pump(tester, "a\n\n---\nb", blocks: false);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets("images render inline and report taps", (tester) async {
    String? tapped;
    await _pump(tester, "![pic](a/pic.png)\ntext", onImageTap: (destination) => tapped = destination);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.byType(Image));
    expect(tapped, "a/pic.png");
  });

  testWidgets("a video link on its own line renders as a preview that opens once", (tester) async {
    const text = "intro\n[clip](media/clip.mp4)\nsee [other](media/other.mp4) too";
    final opened = <String>[];
    await _pump(tester, text, caret: 0, onLinkTap: opened.add, onImageTap: opened.add);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.tap(find.byType(Image));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, ["media/clip.mp4"]);
  });

  testWidgets("the empty line after a trailing image keeps the caret right under it", (tester) async {
    final bytes = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 800, 400), Paint()..color = Colors.red);
      final image = await recorder.endRecording().toImage(800, 400);
      return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    });
    const text = "![pic](a.png)\n";
    final controller = MarkdownEditingController(text: text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: MarkdownEditor(controller: controller, style: _style, imageFor: (_) => MemoryImage(bytes!)),
          ),
        ),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: text.length);
    await tester.pump();

    final editable = tester.allRenderObjects.whereType<RenderEditable>().single;
    final imageBottom = tester.getRect(find.byType(Image)).bottom;
    final caret = editable.getLocalRectForCaret(const TextPosition(offset: text.length));
    expect(editable.localToGlobal(caret.topLeft).dy, closeTo(imageBottom, 1));

    await tester.tapAt(editable.localToGlobal(Offset(200, caret.center.dy)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection.baseOffset, text.length);

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: "${text}x",
        selection: TextSelection.collapsed(offset: text.length + 1),
      ),
    );
    await tester.pump();
    expect(controller.text, "${text}x");
  });

  testWidgets("tapping a rendered link opens it and keeps the caret", (tester) async {
    const text = "start\nsee [the link](notes/other.md) here";
    String? opened;
    final controller = await _pump(tester, text, caret: 0, onLinkTap: (destination) => opened = destination);
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();
    final editable = tester.allRenderObjects.whereType<RenderEditable>().single;
    final linkStart = text.indexOf("the link");
    final box = editable.getBoxesForSelection(TextSelection(baseOffset: linkStart, extentOffset: linkStart + 3)).first;
    await tester.tapAt(editable.localToGlobal(box.toRect().center));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, "notes/other.md");
    expect(controller.selection, const TextSelection.collapsed(offset: 2));
  });

  testWidgets("enter continues a list through the text input", (tester) async {
    const text = "- one";
    final controller = await _pump(tester, text, caret: text.length);
    await _focus(tester);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: "- one\n", selection: TextSelection.collapsed(offset: 6)),
    );
    await tester.pump();
    expect(controller.text, "- one\n- ");
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  testWidgets("backspace at item start removes the marker", (tester) async {
    const text = "- one";
    final controller = await _pump(tester, text, caret: 2);
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: 2);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: "-one", selection: TextSelection.collapsed(offset: 1)),
    );
    await tester.pump();
    expect(controller.text, "one");
  });

  testWidgets("tab indents list items from the keyboard", (tester) async {
    const text = "- a\n- b";
    final controller = await _pump(tester, text, caret: text.length);
    await _focus(tester);
    controller.selection = const TextSelection.collapsed(offset: text.length);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(controller.text, "- a\n  - b");
  });

  group("history", () {
    test("typing merges into one undo step until a pause", () {
      final controller = MarkdownEditingController(text: "");
      addTearDown(controller.dispose);
      controller.value = const TextEditingValue(text: "a", selection: TextSelection.collapsed(offset: 1));
      controller.value = const TextEditingValue(text: "ab", selection: TextSelection.collapsed(offset: 2));
      expect(controller.canUndo, isTrue);
      controller.undo();
      expect(controller.text, "");
      expect(controller.canRedo, isTrue);
      controller.redo();
      expect(controller.text, "ab");
    });

    test("separate origins are separate steps and history can be skipped", () {
      final controller = MarkdownEditingController(text: "a");
      addTearDown(controller.dispose);
      final origin = Object();
      controller.setValue(const TextEditingValue(text: "ab"), origin: origin);
      controller.setValue(const TextEditingValue(text: "abc"), origin: origin, mergeWithPrevious: true);
      controller.setValue(const TextEditingValue(text: "abcd"), origin: Object());
      controller.setValue(const TextEditingValue(text: "abcde"), addToHistory: false);
      controller.undo();
      expect(controller.text, "abc");
      controller.undo();
      expect(controller.text, "a");
      expect(controller.canUndo, isFalse);
    });

    test("selection changes are not history", () {
      final controller = MarkdownEditingController(text: "abc");
      addTearDown(controller.dispose);
      controller.selection = const TextSelection.collapsed(offset: 2);
      expect(controller.canUndo, isFalse);
    });

    test("out of range selections are clamped", () {
      final controller = MarkdownEditingController(text: "abc");
      addTearDown(controller.dispose);
      controller.setText("a", selection: const TextSelection.collapsed(offset: 3));
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
    });
  });
}
