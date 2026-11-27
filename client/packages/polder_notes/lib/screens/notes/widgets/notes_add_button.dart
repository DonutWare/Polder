import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_notes/screens/notes/notes_actions.dart";
import "package:polder_notes/screens/notes/widgets/notes_sidebar.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/fab_menu.dart";

class NotesAddButton extends ConsumerWidget {
  const NotesAddButton({required this.root, super.key});

  final String? root;

  static void createPage(BuildContext context, WidgetRef ref, String? root, {NewNoteKind kind = NewNoteKind.page}) {
    if (root == null) {
      NotesActions.createInNotesFolder(context, kind: kind);
    } else {
      NotesActions.createPage(context, folder: notesLevel(ref, root), kind: kind);
    }
  }

  static void addRecipe(BuildContext context, WidgetRef ref, String? root) {
    if (root == null) {
      NotesActions.addRecipeInNotesFolder(context);
    } else {
      NotesActions.addRecipe(context, folder: notesLevel(ref, root));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return FabMenu(
      icon: IconsaxPlusLinear.add,
      tooltip: localized.add,
      groups: [
        [
          FabMenuItem(
            icon: IconsaxPlusLinear.note_add,
            label: localized.noteNewPage,
            onPressed: () => createPage(context, ref, root),
          ),
          FabMenuItem(
            icon: IconsaxPlusLinear.task_square,
            label: localized.noteNewChecklist,
            onPressed: () => createPage(context, ref, root, kind: NewNoteKind.checklist),
          ),
        ],
        [
          FabMenuItem(
            icon: IconsaxPlusLinear.cake,
            label: localized.recipeAdd,
            onPressed: () => addRecipe(context, ref, root),
          ),
        ],
      ],
    );
  }
}
