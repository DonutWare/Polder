import "package:flutter/widgets.dart";

import "package:polder/services/deep_link/share_link_target.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder_calendar/polder_calendar.dart";

enum AppShortcutGroup { create, find }

enum AppShortcut {
  newEvent("new-event", AppShortcutGroup.create),
  newNote("new-note", AppShortcutGroup.create),
  newChecklist("new-checklist", AppShortcutGroup.create),
  scanDocument("scan-document", AppShortcutGroup.create),
  search("search", AppShortcutGroup.find);

  const AppShortcut(this.slug, this.group);

  static const host = "shortcut";
  static const launcherLimit = 4;
  static const launcherPriority = [newEvent, newNote, scanDocument, newChecklist, search];

  final String slug;
  final AppShortcutGroup group;

  String get iconName => "shortcut_${slug.replaceAll("-", "_")}";

  Uri get uri => Uri(scheme: "polder", host: host, path: "/$slug");

  static AppShortcut? fromUri(Uri uri) {
    if (!ShareLinkTarget.isAppUri(uri, host: host)) return null;
    return fromSlug(uri.pathSegments.firstOrNull);
  }

  static AppShortcut? fromSlug(String? slug) => values.where((shortcut) => shortcut.slug == slug).firstOrNull;

  bool isAvailable({required bool canScan}) => canScan || this != scanDocument;

  static List<AppShortcut> inGroup(AppShortcutGroup group, {required bool canScan}) => [
    for (final shortcut in values)
      if (shortcut.group == group && shortcut.isAvailable(canScan: canScan)) shortcut,
  ];

  static List<AppShortcut> forLauncher({required bool canScan}) =>
      launcherPriority.where((shortcut) => shortcut.isAvailable(canScan: canScan)).take(launcherLimit).toList();

  String label(BuildContext context) => switch (this) {
    newEvent => CalendarLocalizations.of(context).newEvent,
    newNote => context.localized.shortcutNewNote,
    newChecklist => context.localized.noteNewChecklist,
    scanDocument => context.localized.scanDocument,
    search => context.localized.shortcutSearch,
  };

  String groupedLabel(BuildContext context) => switch (this) {
    newEvent => context.localized.shortcutEvent,
    newNote => context.localized.noteNewNote,
    newChecklist => context.localized.shortcutChecklist,
    scanDocument || search => label(context),
  };
}
