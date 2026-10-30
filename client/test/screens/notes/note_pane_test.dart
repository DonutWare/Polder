import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/screens/notes/editor/checklist_editor.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor.dart";
import "package:polder/screens/notes/widgets/link_preview_card.dart";
import "package:polder/screens/notes/widgets/note_pane.dart";
import "package:polder/widgets/shared/file_link_picker_dialog.dart";

import "../../support/fake_server.dart";
import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";

const notePath = "/Notes/plan.md";
final liveField = find.descendant(of: find.byType(MarkdownEditor), matching: find.byType(TextField));

void main() {
  late ProviderHarness harness;

  Future<void> openNote(WidgetTester tester, {double bottomInset = 0}) async {
    final server = FakePolderServer()..putFile(notePath, utf8.encode("# Plan\n"));
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
    var sourceMode = false;
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(padding: EdgeInsets.only(bottom: bottomInset)),
            child: StatefulBuilder(
              builder: (context, setState) => NotePane(
                path: notePath,
                sourceMode: sourceMode,
                onToggleSourceMode: () => setState(() => sourceMode = !sourceMode),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeNote(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    harness.dispose();
    await tester.pump(const Duration(minutes: 10));
  }

  String noteText() => harness.container.read(noteDocumentProvider(notePath)).requireValue.text;

  testWidgets("show and hide checkboxes switch between text and checklist", (tester) async {
    await openNote(tester);
    await tester.enterText(liveField, "Milk\nEggs");
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Show checkboxes"));
    await tester.pumpAndSettle();
    expect(noteText(), "- [ ] Milk\n- [ ] Eggs");
    expect(find.byType(ChecklistEditor), findsOneWidget);
    expect(find.byType(MarkdownEditor), findsNothing);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump(const Duration(seconds: 1));
    expect(noteText(), "- [x] Milk\n- [ ] Eggs");

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Hide checkboxes"));
    await tester.pumpAndSettle();
    expect(noteText(), "Milk\nEggs");
    expect(find.byType(MarkdownEditor), findsOneWidget);

    unawaited(harness.container.read(noteDocumentProvider(notePath).notifier).save());
    await tester.pumpAndSettle();
    await closeNote(tester);
  });

  testWidgets("one undo history covers live and source editing", (tester) async {
    await openNote(tester);

    await tester.enterText(liveField, "# Plan\n\nLive\n");
    await tester.pump(const Duration(seconds: 1));
    expect(noteText(), "# Plan\n\nLive\n");

    await tester.tap(find.byTooltip("Source mode"));
    await tester.pumpAndSettle();
    expect(find.text("# Plan\n\nLive\n"), findsOneWidget);
    await tester.enterText(find.byType(TextField), "# Plan\n\nLive\n\nSource\n");
    await tester.pump(const Duration(seconds: 1));
    expect(noteText(), "# Plan\n\nLive\n\nSource\n");

    await tester.tap(find.byTooltip("Undo"));
    await tester.pump();
    expect(noteText(), "# Plan\n\nLive\n");
    await tester.tap(find.byTooltip("Live preview"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Undo"));
    await tester.pump();
    expect(noteText(), "# Plan\n");

    await closeNote(tester);
  });

  testWidgets("typing [[ opens the link picker without leaving the brackets", (tester) async {
    await openNote(tester);

    await tester.enterText(liveField, "# Plan\n[");
    await tester.enterText(liveField, "# Plan\n[[");
    await tester.pumpAndSettle();

    expect(find.byType(FileLinkPickerDialog), findsOneWidget);
    expect(noteText(), "# Plan\n");

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await closeNote(tester);
  });

  testWidgets("web links in the note show as preview cards once typing settles", (tester) async {
    await openNote(tester, bottomInset: 80);
    expect(find.byType(LinkPreviewCard), findsNothing);

    await tester.enterText(liveField, "# Plan\n\nRead https://example.com/guide first.\n");
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinkPreviewCard), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(LinkPreviewCard), findsOneWidget);
    expect(find.text("Page on example.com"), findsOneWidget);
    final screenBottom = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(find.byType(LinkPreviewCard)).dy, lessThanOrEqualTo(screenBottom - 80));

    unawaited(harness.container.read(noteDocumentProvider(notePath).notifier).save());
    await tester.pumpAndSettle();
    await closeNote(tester);
  });
}
