import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/screens/notes/note_navigation.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";

class NoteBreadcrumbs extends ConsumerWidget {
  const NoteBreadcrumbs({required this.notePath, super.key});

  final String notePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final root = ref.watch(notesFolderProvider).value;
    if (root == null || !RemotePath.isWithin(notePath, root)) {
      return Text(RemotePath.parent(notePath), maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    final crumbs = [
      for (final folder in RemotePath.ancestry(notesGridFolderFor(root, notePath)))
        if (folder == root || RemotePath.isWithin(folder, root)) folder,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: [
          for (final (index, folder) in crumbs.indexed) ...[
            if (index > 0) Icon(IconsaxPlusLinear.arrow_right_3, size: 12, color: theme.colorScheme.outline),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => NoteNavigation.openFolder(context, ref, root, folder),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                child: Text(folder == root ? context.localized.navNotes : RemotePath.name(folder), style: style),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
