import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/screens/notes/widgets/link_preview_card.dart";
import "package:polder/screens/notes/widgets/note_pane.dart";
import "package:polder/widgets/shared/file_link_picker_dialog.dart";

import "../../support/fake_server.dart";
import "../../support/localized_app.dart";
import "../../support/provider_harness.dart";

const notePath = "/Notes/plan.md";
const liveField = ValueKey("livemd-document-field");

void main() {
  late ProviderHarness harness;

  Future<void> openNote(WidgetTester tester) async {
    final server = FakePolderServer()..putFile(notePath, utf8.encode("# Plan\n"));
    harness = ProviderHarness(httpClient: SignedInServer(server), account: testAccount());
    await harness.container.read(accountProvider.future);
    var sourceMode = false;
    await tester.pumpWidget(
      localizedApp(
        harness.container,
        StatefulBuilder(
          builder: (context, setState) => NotePane(
            path: notePath,
            sourceMode: sourceMode,
            onToggleSourceMode: () => setState(() => sourceMode = !sourceMode),
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

  testWidgets("one undo history covers live and source editing", (tester) async {
    await openNote(tester);

    await tester.enterText(find.byKey(liveField), "# Plan\n\nLive\n");
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

    await tester.enterText(find.byKey(liveField), "# Plan\n[");
    await tester.enterText(find.byKey(liveField), "# Plan\n[[");
    await tester.pumpAndSettle();

    expect(find.byType(FileLinkPickerDialog), findsOneWidget);
    expect(noteText(), "# Plan\n");

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await closeNote(tester);
  });

  testWidgets("web links in the note show as preview cards once typing settles", (tester) async {
    await openNote(tester);
    expect(find.byType(LinkPreviewCard), findsNothing);

    await tester.enterText(find.byKey(liveField), "# Plan\n\nRead https://example.com/guide first.\n");
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinkPreviewCard), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(LinkPreviewCard), findsOneWidget);
    expect(find.text("Page on example.com"), findsOneWidget);

    unawaited(harness.container.read(noteDocumentProvider(notePath).notifier).save());
    await tester.pumpAndSettle();
    await closeNote(tester);
  });
}
