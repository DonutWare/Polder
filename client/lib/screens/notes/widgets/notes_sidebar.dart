import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";
import "package:polder/screens/notes/widgets/notes_grid.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";

String notesLevel(WidgetRef ref, String root) {
  if (ref.watch(notesViewModeProvider) != NotesViewMode.grid) return root;
  final folder = ref.watch(notesGridFolderProvider);
  return folder != null && RemotePath.isWithin(folder, root) ? folder : root;
}

class NotesSidebar extends ConsumerStatefulWidget {
  const NotesSidebar({required this.root, required this.selectedPath, required this.onOpen, super.key});

  final String root;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<NotesSidebar> createState() => _NotesSidebarState();
}

class _NotesSidebarState extends ConsumerState<NotesSidebar> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(notesViewModeProvider) == NotesViewMode.grid) {
      return NotesGrid(folder: notesLevel(ref, widget.root), selectedPath: widget.selectedPath, onOpen: widget.onOpen);
    }
    return NoteDragAutoScroll(
      controller: _scroll,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: _TreeLevel(path: widget.root, depth: 0, selectedPath: widget.selectedPath, onOpen: widget.onOpen),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _TopLevelDropZone(root: widget.root, selectedPath: widget.selectedPath),
          ),
        ],
      ),
    );
  }
}

class _TopLevelDropZone extends ConsumerWidget {
  const _TopLevelDropZone({required this.root, required this.selectedPath});

  static const _minHeight = 96.0;

  final String root;
  final String? selectedPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return NoteDropTarget(
      destination: root,
      onDrop: (node) => NoteNodeActions.drop(context, ref, node: node, destination: root, selectedPath: selectedPath),
      builder: (context, active) => Container(
        constraints: const BoxConstraints(minHeight: _minHeight),
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? colors.primary : Colors.transparent, width: 2),
        ),
        child: active
            ? Text(
                context.localized.notesMoveToTop,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onPrimaryContainer),
              )
            : null,
      ),
    );
  }
}

class NotesTitle extends ConsumerWidget {
  const NotesTitle({required this.root, required this.selectedPath, super.key});

  final String? root;
  final String? selectedPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final root = this.root;
    final title = Text(context.localized.navNotes, overflow: TextOverflow.ellipsis);
    if (root == null) return title;
    final level = notesLevel(ref, root);
    final nested = level != root;
    final destination = nested ? RemotePath.parent(level) : root;
    final colors = Theme.of(context).colorScheme;
    return NoteDropTarget(
      destination: destination,
      onDrop: (node) =>
          NoteNodeActions.drop(context, ref, node: node, destination: destination, selectedPath: selectedPath),
      builder: (context, active) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: active ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? colors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nested)
              IconButton(
                tooltip: context.localized.notesUpOneLevel,
                icon: const Icon(IconsaxPlusLinear.arrow_left),
                onPressed: () {
                  final parent = RemotePath.parent(level);
                  ref.read(notesGridFolderProvider.notifier).open(parent == root ? null : parent);
                },
              ),
            Flexible(child: nested ? Text(RemotePath.name(level), overflow: TextOverflow.ellipsis) : title),
          ],
        ),
      ),
    );
  }
}

class NotesHeaderActions extends ConsumerWidget {
  const NotesHeaderActions({required this.root, required this.showNewPage, this.onChangeFolder, super.key});

  final String root;
  final bool showNewPage;
  final VoidCallback? onChangeFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final grid = ref.watch(notesViewModeProvider) == NotesViewMode.grid;
    final level = notesLevel(ref, root);
    final density = AdaptiveLayout.usesPointer(context) ? VisualDensity.compact : VisualDensity.standard;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: grid ? localized.listView : localized.gridView,
          visualDensity: density,
          icon: Icon(grid ? IconsaxPlusLinear.row_vertical : IconsaxPlusLinear.element_3),
          onPressed: ref.read(notesViewModeProvider.notifier).toggle,
        ),
        if (showNewPage) ...[
          IconButton(
            tooltip: localized.noteNewChecklist,
            visualDensity: density,
            icon: const Icon(IconsaxPlusLinear.task_square),
            onPressed: () => NotesActions.createPage(context, folder: level, checklist: true),
          ),
          IconButton(
            tooltip: localized.noteNewPage,
            visualDensity: density,
            icon: const Icon(IconsaxPlusLinear.note_add),
            onPressed: () => NotesActions.createPage(context, folder: level),
          ),
        ],
        if (onChangeFolder != null)
          IconButton(
            tooltip: localized.notesChangeFolder,
            visualDensity: density,
            icon: const Icon(IconsaxPlusLinear.setting_4),
            onPressed: onChangeFolder,
          ),
      ],
    );
  }
}

class _TreeLevel extends ConsumerWidget {
  const _TreeLevel({required this.path, required this.depth, required this.selectedPath, required this.onOpen});

  final String path;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contents = ref.watch(notesTreeProvider(path));
    if (depth > 0 && !contents.hasValue && !contents.hasError) return const SizedBox(width: double.infinity);
    return AsyncValueView<NotesFolderContents>(
      value: contents,
      onRetry: () => ref.invalidate(notesTreeProvider(path)),
      data: (contents) {
        if (contents.nodes.isEmpty && depth == 0) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.localized.notesEmptyFolder,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final node in contents.nodes)
              _TreeNode(key: ValueKey(node.path), node: node, depth: depth, selectedPath: selectedPath, onOpen: onOpen),
          ],
        );
      },
    );
  }
}

class _TreeNode extends ConsumerStatefulWidget {
  const _TreeNode({
    required this.node,
    required this.depth,
    required this.selectedPath,
    required this.onOpen,
    super.key,
  });

  final NoteTreeNode node;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<_TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends ConsumerState<_TreeNode> {
  static const _indent = 16.0;
  static const _leading = 12.0;

  NoteTreeNode get node => widget.node;

  bool _isSelected(FileEntry? readme) {
    final selected = widget.selectedPath;
    return selected != null && (selected == node.page?.path || selected == readme?.path);
  }

  Future<void> _open() async {
    final page = node.page;
    if (page != null) {
      widget.onOpen(page);
      return;
    }
    final folder = node.folder!;
    ref.read(expandedNotesProvider.notifier).expand(folder.path);
    final readme = (await ref.read(notesTreeProvider(folder.path).future)).readme;
    if (readme != null && mounted) widget.onOpen(readme);
  }

  void _showMenu(Rect anchor) =>
      NoteNodeActions.showMenuFor(context, ref, node: node, anchor: anchor, selectedPath: widget.selectedPath);

  void _drop(NoteTreeNode dropped) => NoteNodeActions.drop(
    context,
    ref,
    node: dropped,
    destination: node.childrenPath,
    selectedPath: widget.selectedPath,
  );

  @override
  Widget build(BuildContext context) {
    final folder = node.folder;
    final expanded = folder != null && node.hasChildren && ref.watch(expandedNotesProvider).contains(folder.path);
    if (folder != null && node.hasChildren) {
      ref.watch(notesTreeProvider(folder.path).select((children) => children.hasValue));
    }
    final readme = folder == null || node.page != null ? null : ref.watch(notesTreeProvider(folder.path)).value?.readme;

    final row = NoteDropTarget(
      destination: node.childrenPath,
      onDrop: _drop,
      onLinger: () => ref.read(expandedNotesProvider.notifier).expand(node.childrenPath),
      builder: (context, active) => NoteDragSource(
        node: node,
        onHold: _showMenu,
        child: _row(
          context,
          selected: _isSelected(readme),
          expanded: expanded,
          dropActive: active,
          isSection: node.page == null && readme == null,
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? _TreeLevel(
                    path: folder.path,
                    depth: widget.depth + 1,
                    selectedPath: widget.selectedPath,
                    onOpen: widget.onOpen,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context, {
    required bool selected,
    required bool expanded,
    required bool dropActive,
    required bool isSection,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pointer = AdaptiveLayout.usesPointer(context);
    final height = NoteTargetSize.row(context);
    final radius = BorderRadius.circular(pointer ? 8 : 12);
    return GestureDetector(
      onSecondaryTapUp: (details) => _showMenu(details.globalPosition & Size.zero),
      child: Material(
        color: dropActive
            ? colors.primaryContainer
            : selected
            ? colors.secondaryContainer
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: dropActive ? BorderSide(color: colors.primary, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: _open,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                SizedBox(width: _leading + widget.depth * _indent),
                Expanded(
                  child: Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (pointer ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                      color: selected ? colors.onSecondaryContainer : (isSection ? colors.onSurfaceVariant : null),
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                _disclosure(context, expanded: expanded, height: height),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on _TreeNodeState {
  Widget _disclosure(BuildContext context, {required bool expanded, required double height}) {
    final width = NoteTargetSize.button(context);
    final folder = node.folder;
    if (folder == null || !node.hasChildren) return const SizedBox(width: 12);
    return Tooltip(
      message: expanded ? context.localized.noteCollapse : context.localized.noteExpand,
      child: InkResponse(
        onTap: () => ref.read(expandedNotesProvider.notifier).toggle(folder.path),
        radius: width / 2,
        child: SizedBox(
          width: width,
          height: height,
          child: AnimatedRotation(
            turns: expanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
