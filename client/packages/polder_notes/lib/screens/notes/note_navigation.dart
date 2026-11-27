import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_notes/providers/notes/last_note_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes/providers/notes/notes_view_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_notes/screens/notes/widgets/note_node_interactions.dart";
import "package:polder_core/util/remote_path.dart";

abstract final class NoteNavigation {
  static Future<void> openFolder(BuildContext context, WidgetRef ref, String root, String folder) async {
    final page = await pageFor(ref, root, folder);
    if (!context.mounted) return;
    if (page != null) {
      context.go(notesLocationsOf(context).noteAt(page.path));
    } else {
      showFolder(context, ref, root, folder);
    }
  }

  static void showFolder(BuildContext context, WidgetRef ref, String root, String folder) {
    if (ref.read(notesViewModeProvider) == NotesViewMode.grid) {
      ref.read(notesGridFolderProvider.notifier).open(folder == root ? null : folder);
      ref.read(lastNoteProvider.notifier).set(null);
      goWithin(context, notesLocationsOf(context).root, replacing: true);
      return;
    }
    if (folder == root) return;
    ref.read(expandedNotesProvider.notifier)
      ..expandTo(root, folder)
      ..expand(folder);
  }

  static Future<FileEntry?> pageFor(WidgetRef ref, String root, String folder) async {
    try {
      if (folder == root) return (await ref.read(notesTreeProvider(root).future)).readme;
      final siblings = await ref.read(notesTreeProvider(RemotePath.parent(folder)).future);
      final page = siblings.nodes.where((node) => node.childrenPath == folder).firstOrNull?.page;
      return page ?? (await ref.read(notesTreeProvider(folder).future)).readme;
    } on Exception {
      return null;
    }
  }
}
