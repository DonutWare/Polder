import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";

final expandedNotesProvider = NotifierProvider<ExpandedNotes, Set<String>>(ExpandedNotes.new);

class ExpandedNotes extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String path) => state = state.contains(path) ? ({...state}..remove(path)) : {...state, path};

  void expand(String path) {
    if (!state.contains(path)) state = {...state, path};
  }

  void expandTo(String root, String path) {
    final ancestors = [
      for (final ancestor in RemotePath.ancestry(RemotePath.parent(path)))
        if (RemotePath.isWithin(ancestor, root)) ancestor,
    ];
    if (ancestors.every(state.contains)) return;
    state = {...state, ...ancestors};
  }
}

class NotesSidebar extends ConsumerWidget {
  const NotesSidebar({
    required this.root,
    required this.selectedPath,
    required this.onOpen,
    this.onChangeFolder,
    super.key,
  });

  final String root;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final VoidCallback? onChangeFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  RemotePath.name(root),
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: localized.noteNewPage,
                icon: const Icon(IconsaxPlusLinear.note_add, size: 20),
                onPressed: () => NotesActions.createPage(context, ref, folder: root),
              ),
              if (onChangeFolder != null)
                IconButton(
                  tooltip: localized.notesChangeFolder,
                  icon: const Icon(IconsaxPlusLinear.setting_4, size: 20),
                  onPressed: onChangeFolder,
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: _TreeLevel(path: root, depth: 0, selectedPath: selectedPath, onOpen: onOpen),
          ),
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
              _TreeNode(node: node, depth: depth, selectedPath: selectedPath, onOpen: onOpen),
          ],
        );
      },
    );
  }
}

class _TreeNode extends ConsumerStatefulWidget {
  const _TreeNode({required this.node, required this.depth, required this.selectedPath, required this.onOpen});

  final NoteTreeNode node;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<_TreeNode> createState() => _TreeNodeState();
}

enum _NodeAction { newSubpage, rename, move, delete }

class _TreeNodeState extends ConsumerState<_TreeNode> {
  var _hovered = false;

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

  Future<void> _createSubpage() async {
    await NotesActions.createSubpage(context, ref, node);
    if (mounted) ref.read(expandedNotesProvider.notifier).expand(node.childrenPath);
  }

  void _followMove(String? movedTo) {
    final selected = movedTo == null ? null : NotesActions.pathAfterMove(widget.selectedPath, node, movedTo);
    if (selected != null && mounted) ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.noteAt(selected));
  }

  Future<void> _showMenu(Rect anchor) async {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final local = Rect.fromPoints(overlay.globalToLocal(anchor.topLeft), overlay.globalToLocal(anchor.bottomRight));
    final localized = context.localized;
    final action = await showMenu<_NodeAction>(
      context: context,
      position: RelativeRect.fromRect(local, Offset.zero & overlay.size),
      items: [
        PopupMenuItem(value: _NodeAction.newSubpage, child: Text(localized.noteNewSubpage)),
        PopupMenuItem(value: _NodeAction.rename, child: Text(localized.rename)),
        PopupMenuItem(value: _NodeAction.move, child: Text(localized.noteMove)),
        PopupMenuItem(value: _NodeAction.delete, child: Text(localized.delete)),
      ],
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _NodeAction.newSubpage:
        await _createSubpage();
      case _NodeAction.rename:
        _followMove(await NotesActions.rename(context, ref, node));
      case _NodeAction.move:
        _followMove(await NotesActions.move(context, ref, node));
      case _NodeAction.delete:
        final selected = widget.selectedPath;
        final deleted = await NotesActions.delete(context, ref, node);
        if (deleted && mounted && selected != null && node.holds(selected)) {
          ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.notes);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final folder = node.folder;
    final expanded = folder != null && node.hasChildren && ref.watch(expandedNotesProvider).contains(folder.path);
    if (folder != null && node.hasChildren) {
      ref.watch(notesTreeProvider(folder.path).select((children) => children.hasValue));
    }
    final readme = folder == null || node.page != null ? null : ref.watch(notesTreeProvider(folder.path)).value?.readme;
    final selected = _isSelected(readme);
    final isSection = node.page == null && readme == null;

    final row = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onSecondaryTapUp: (details) => _showMenu(details.globalPosition & Size.zero),
        onLongPressStart: (details) => _showMenu(details.globalPosition & Size.zero),
        child: Material(
          color: selected ? colors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _open,
            child: SizedBox(
              height: 34,
              child: Row(
                children: [
                  SizedBox(width: widget.depth * 14.0),
                  SizedBox(
                    width: 24,
                    child: folder == null || !node.hasChildren
                        ? null
                        : InkResponse(
                            radius: 14,
                            onTap: () => ref.read(expandedNotesProvider.notifier).toggle(folder.path),
                            child: Icon(
                              expanded ? Icons.expand_more : Icons.chevron_right,
                              size: 18,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected ? colors.onSecondaryContainer : (isSection ? colors.onSurfaceVariant : null),
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  if (_hovered) ...[
                    _HoverButton(icon: Icons.add, tooltip: context.localized.noteNewSubpage, onPressed: _createSubpage),
                    Builder(
                      builder: (buttonContext) => _HoverButton(
                        icon: Icons.more_horiz,
                        tooltip: context.localized.moreOptions,
                        onPressed: () {
                          final box = buttonContext.findRenderObject()! as RenderBox;
                          _showMenu(box.localToGlobal(Offset.zero) & box.size);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
}

class _HoverButton extends StatelessWidget {
  const _HoverButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 16),
    tooltip: tooltip,
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints.tightFor(width: 28, height: 28),
  );
}
