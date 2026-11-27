import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:polder_notes/providers/notes/note_preview_provider.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes/providers/notes/notes_view_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/screens/notes/note_navigation.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/widgets/layout/window_centered.dart";

class NoteSubpages extends ConsumerWidget {
  const NoteSubpages({required this.path, required this.contentWidth, super.key});

  static const _height = 64.0;
  static const _tileWidth = 200.0;

  final String path;
  final double contentWidth;

  NoteTreeNode? _nodeOf(WidgetRef ref, String root) {
    final holder = notesGridFolderFor(root, path);
    if (holder == RemotePath.parent(path) &&
        RemotePath.withoutExtension(RemotePath.name(path)).toLowerCase() == "readme") {
      return null;
    }
    final siblings = ref.watch(notesTreeProvider(holder)).value?.nodes ?? const <NoteTreeNode>[];
    return siblings.where((node) => node.path == path || node.childrenPath == RemotePath.parent(path)).firstOrNull;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final root = ref.watch(notesFolderProvider).value;
    if (root == null || !RemotePath.isWithin(path, root) || MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    final node = _nodeOf(ref, root);
    if (node == null || !node.hasChildren) return const SizedBox.shrink();
    final children = ref.watch(notesTreeProvider(node.childrenPath)).value?.nodes;
    if (children == null || children.isEmpty) return const SizedBox.shrink();
    final sorted = sortNoteNodes(children, ref.watch(notesSortProvider));
    final shown = ref.watch(notesSubpagesShownProvider);
    final theme = Theme.of(context);
    return WindowCentered(
      contentWidth: contentWidth,
      builder: (context, gutters) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(gutters.left - 8, 4, gutters.right, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
                onPressed: ref.read(notesSubpagesShownProvider.notifier).toggle,
                icon: AnimatedRotation(
                  turns: shown ? 0.25 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: const Icon(Icons.chevron_right, size: 18),
                ),
                label: Text("${context.localized.noteSubpages} · ${sorted.length}"),
              ),
            ),
          ),
          if (shown)
            SizedBox(
              height: _height + 8,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(gutters.left, 0, gutters.right, 8),
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) =>
                    _SubpageTile(key: ValueKey(sorted[index].path), root: root, node: sorted[index], width: _tileWidth),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubpageTile extends ConsumerWidget {
  const _SubpageTile({required this.root, required this.node, required this.width, super.key});

  final String root;
  final NoteTreeNode node;
  final double width;

  void _open(BuildContext context, WidgetRef ref) => switch (node.page) {
    final page? => context.go(notesLocationsOf(context).noteAt(page.path)),
    null => NoteNavigation.openFolder(context, ref, root, node.childrenPath),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final page = node.page;
    final excerpt = page == null ? null : ref.watch(notePreviewProvider(notePreviewKey(page))).value?.excerpt;
    return SizedBox(
      width: width,
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _open(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (excerpt != null && excerpt.isNotEmpty)
                  Text(
                    excerpt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
