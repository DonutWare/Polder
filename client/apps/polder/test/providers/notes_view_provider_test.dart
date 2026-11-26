import "package:flutter_test/flutter_test.dart";

import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder_core/services/storage/preferences_store.dart";

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

  test("remembers the chosen sort across launches", () async {
    final preferences = InMemoryPreferencesStore();
    final first = ProviderHarness(preferences: preferences);
    first.container.read(notesSortProvider);
    await pumpEventQueue();
    await first.container.read(notesSortProvider.notifier).select(NotesSortField.modified);
    first.dispose();

    final second = ProviderHarness(preferences: preferences);
    addTearDown(second.dispose);
    second.container.read(notesSortProvider);
    await pumpEventQueue();

    expect(second.container.read(notesSortProvider), const NotesSort(field: NotesSortField.modified, ascending: false));
  });
}
