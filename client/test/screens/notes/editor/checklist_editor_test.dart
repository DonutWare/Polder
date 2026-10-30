import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/screens/notes/editor/checklist_editor.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";

Future<MarkdownEditingController> _pump(WidgetTester tester, String text) async {
  final controller = MarkdownEditingController(text: text);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ChecklistEditor(controller: controller)),
    ),
  );
  await tester.pump();
  return controller;
}

Finder _field(String text) => find.widgetWithText(TextField, text);

void main() {
  testWidgets("checking an item moves it to the checked section", (tester) async {
    final controller = await _pump(tester, "- [ ] milk\n- [ ] eggs");
    expect(find.text("1 checked item"), findsNothing);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(controller.text, "- [x] milk\n- [ ] eggs");
    expect(find.text("1 checked item"), findsOneWidget);
    final eggs = tester.getTopLeft(_field("eggs")).dy;
    final milk = tester.getTopLeft(_field("milk")).dy;
    expect(milk, greaterThan(eggs));

    await tester.tap(find.text("1 checked item"));
    await tester.pump();
    expect(_field("milk"), findsNothing);
  });

  testWidgets("typing updates the note", (tester) async {
    final controller = await _pump(tester, "- [ ] milk");
    await tester.enterText(_field("milk"), "oat milk");
    expect(controller.text, "- [ ] oat milk");
  });

  testWidgets("enter splits an item into a new one below", (tester) async {
    final controller = await _pump(tester, "- [ ] milkeggs");
    await tester.enterText(_field("milkeggs"), "milk\neggs");
    await tester.pump();
    expect(controller.text, "- [ ] milk\n- [ ] eggs");
    expect(tester.widget<TextField>(_field("eggs")).focusNode!.hasFocus, isTrue);
  });

  testWidgets("the add row appends an item after the open items", (tester) async {
    final controller = await _pump(tester, "- [ ] milk\n- [x] eggs");
    await tester.tap(find.byIcon(IconsaxPlusLinear.add));
    await tester.pump();
    await tester.pump();
    expect(controller.text, "- [ ] milk\n- [ ]\n- [x] eggs");
  });

  testWidgets("backspace on an empty item removes it", (tester) async {
    final controller = await _pump(tester, "- [ ] milk\n- [ ]");
    await tester.tap(find.byType(TextField).last);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(controller.text, "- [ ] milk");
  });

  testWidgets("the remove button deletes the focused item", (tester) async {
    final controller = await _pump(tester, "- [ ] milk\n- [ ] eggs");
    await tester.tap(_field("eggs"));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(controller.text, "- [ ] milk");
  });

  testWidgets("undo restores the list from the note history", (tester) async {
    final controller = await _pump(tester, "- [ ] milk");
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    controller.undo();
    await tester.pump();
    expect(controller.text, "- [ ] milk");
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });
}
