import "package:flutter_test/flutter_test.dart";

import "package:polder/services/shortcuts/app_shortcut.dart";

void main() {
  test("every shortcut round-trips through its link", () {
    for (final shortcut in AppShortcut.values) {
      expect(AppShortcut.fromUri(shortcut.uri), shortcut);
    }
  });

  test("launcher links from the desktop file resolve", () {
    expect(AppShortcut.fromUri(Uri.parse("polder://shortcut/new-note")), AppShortcut.newNote);
    expect(AppShortcut.fromUri(Uri.parse("polder-dev://shortcut/search")), AppShortcut.search);
  });

  test("unknown or foreign links are not shortcuts", () {
    for (final link in [
      "polder://shortcut",
      "polder://shortcut/delete-everything",
      "polder://open/new-note",
      "https://files.example.com/shortcut/new-note",
    ]) {
      expect(AppShortcut.fromUri(Uri.parse(link)), isNull, reason: link);
    }
  });

  test("the launcher keeps the four most useful shortcuts", () {
    expect(AppShortcut.forLauncher(canScan: true), [
      AppShortcut.newEvent,
      AppShortcut.newNote,
      AppShortcut.scanDocument,
      AppShortcut.newChecklist,
    ]);
    expect(AppShortcut.forLauncher(canScan: false), [
      AppShortcut.newEvent,
      AppShortcut.newNote,
      AppShortcut.newChecklist,
      AppShortcut.search,
    ]);
  });

  test("groups leave out scanning where it is unsupported", () {
    expect(AppShortcut.inGroup(AppShortcutGroup.create, canScan: false), [
      AppShortcut.newEvent,
      AppShortcut.newNote,
      AppShortcut.newChecklist,
    ]);
    expect(AppShortcut.inGroup(AppShortcutGroup.find, canScan: true), [AppShortcut.search]);
  });

  test("every shortcut names a bundled icon", () {
    for (final shortcut in AppShortcut.values) {
      expect(shortcut.iconName, matches(RegExp(r"^shortcut_[a-z_]+$")));
    }
  });
}
