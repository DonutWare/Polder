import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/services/storage/preferences_store.dart";

import "../support/provider_harness.dart";

void main() {
  Future<NotesViewMode> settled(ProviderHarness harness) async {
    harness.container.read(notesViewModeProvider);
    await pumpEventQueue();
    return harness.container.read(notesViewModeProvider);
  }

  test("starts as a tree", () async {
    final harness = ProviderHarness();
    addTearDown(harness.dispose);

    expect(await settled(harness), NotesViewMode.tree);
  });

  test("remembers the chosen view across launches", () async {
    final preferences = InMemoryPreferencesStore();
    final first = ProviderHarness(preferences: preferences);
    await settled(first);
    await first.container.read(notesViewModeProvider.notifier).toggle();
    first.dispose();

    final second = ProviderHarness(preferences: preferences);
    addTearDown(second.dispose);

    expect(await settled(second), NotesViewMode.grid);
  });
}
