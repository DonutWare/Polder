import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/item_selection.dart";
import "package:polder/providers/notes/note_selection_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";
import "package:polder/screens/notes/widgets/notes_grid.dart";
import "package:polder/screens/notes/widgets/notes_tag_filter.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/modifier_keys.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/tags/tag_chip.dart";

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
  final _focus = FocusNode(debugLabel: "NotesSidebar");

  @override
  void dispose() {
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ref.watch(notesTagFilterProvider) is AllNotes ? _allNotes() : _taggedNotes();

  Widget _taggedNotes() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const NotesViewChips(),
      Expanded(
        child: AsyncValueView<List<FileEntry>?>(
          value: ref.watch(notesInViewProvider),
          onRetry: () => ref.invalidate(notesIndexProvider),
          data: (notes) => ref.watch(notesViewModeProvider) == NotesViewMode.grid
              ? NotesGrid(
                  folder: widget.root,
                  nodes: [for (final note in notes ?? const <FileEntry>[]) NoteTreeNode(page: note)],
                  selectedPath: widget.selectedPath,
                  onOpen: widget.onOpen,
                )
              : TaggedNotesList(
                  root: widget.root,
                  notes: notes ?? const [],
                  selectedPath: widget.selectedPath,
                  onOpen: widget.onOpen,
                ),
        ),
      ),
    ],
  );

  Widget _allNotes() {
    if (ref.watch(notesViewModeProvider) == NotesViewMode.grid) {
      return NotesGrid(folder: notesLevel(ref, widget.root), selectedPath: widget.selectedPath, onOpen: widget.onOpen);
    }
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _focus.requestFocus(),
        child: NoteDragAutoScroll(
          controller: _scroll,
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverToBoxAdapter(
                  child: _TreeLevel(
                    path: widget.root,
                    root: widget.root,
                    depth: 0,
                    selectedPath: widget.selectedPath,
                    onOpen: widget.onOpen,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _TopLevelDropZone(root: widget.root, selectedPath: widget.selectedPath),
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape) return KeyEventResult.ignored;
    if (ref.read(noteSelectionProvider).isEmpty) return KeyEventResult.ignored;
    ref.read(noteSelectionProvider.notifier).clear();
    return KeyEventResult.handled;
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
      onDrop: (drag) => NoteNodeActions.drop(context, ref, drag: drag, destination: root, selectedPath: selectedPath),
      builder: (context, active) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: ref.read(noteSelectionProvider.notifier).clear,
        child: Container(
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
    final filtering = ref.watch(notesTagFilterProvider) is! AllNotes;
    final level = filtering ? root : notesLevel(ref, root);
    final nested = level != root;
    final destination = nested ? RemotePath.parent(level) : root;
    final colors = Theme.of(context).colorScheme;
    return NoteDropTarget(
      destination: destination,
      onDrop: (drag) =>
          NoteNodeActions.drop(context, ref, drag: drag, destination: destination, selectedPath: selectedPath),
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
  const NotesHeaderActions({this.onChangeFolder, super.key});

  final VoidCallback? onChangeFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final grid = ref.watch(notesViewModeProvider) == NotesViewMode.grid;
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
        NotesViewPicker(density: density),
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
  const _TreeLevel({
    required this.path,
    required this.root,
    required this.depth,
    required this.selectedPath,
    required this.onOpen,
    this.parentTint,
  });

  final String path;
  final String root;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final Color? parentTint;

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
              _TreeNode(
                key: ValueKey(node.path),
                node: node,
                root: root,
                depth: depth,
                selectedPath: selectedPath,
                onOpen: onOpen,
                parentTint: parentTint,
              ),
          ],
        );
      },
    );
  }
}

class _TreeNode extends ConsumerStatefulWidget {
  const _TreeNode({
    required this.node,
    required this.root,
    required this.depth,
    required this.selectedPath,
    required this.onOpen,
    this.parentTint,
    super.key,
  });

  final NoteTreeNode node;
  final String root;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final Color? parentTint;

  @override
  ConsumerState<_TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends ConsumerState<_TreeNode> {
  static const _indent = 16.0;
  static const _leading = 12.0;
  static const _groupInset = 8.0;
  static const _maxTintedDepth = 3;

  Color? get _tint => noteTintOf(ref.watch(tagsByIdProvider), node.page ?? node.folder!);

  bool get _showsMarker => widget.depth > 0 && _tint != null && _tint != widget.parentTint;

  Color? _groupColor(ColorScheme colors) {
    if (widget.depth >= _maxTintedDepth) return null;
    return _tint?.withValues(alpha: 0.12) ?? colors.onSurface.withValues(alpha: 0.04);
  }

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

  NoteSelectionNotifier get _selection => ref.read(noteSelectionProvider.notifier);

  NotesFolderContents? _contentsOf(String folder) =>
      ref.exists(notesTreeProvider(folder)) ? ref.read(notesTreeProvider(folder)).value : null;

  List<String> _visibleOrder() {
    final expanded = ref.read(expandedNotesProvider);
    return [
      for (final visible in walkNoteTree(
        widget.root,
        contentsOf: _contentsOf,
        descend: (candidate) => expanded.contains(candidate.childrenPath),
      ))
        visible.path,
    ];
  }

  List<NoteTreeNode> _targets(ItemSelection? selection) {
    if (selection == null || selection.length < 2) return [node];
    final known = walkNoteTree(widget.root, contentsOf: _contentsOf, descend: (_) => true);
    return outermostNotes([
      for (final candidate in known)
        if (selection.contains(candidate.path)) candidate,
    ]);
  }

  void _includeOpenNote(List<String> order) {
    final open = widget.selectedPath;
    if (ref.read(noteSelectionProvider).isEmpty && open != null && open != node.path && order.contains(open)) {
      _selection.only(open);
    }
  }

  void _onTap() {
    final selecting = ref.read(noteSelectionProvider).isNotEmpty;
    if (AdaptiveLayout.usesPointer(context) && (shiftPressed || commandPressed)) {
      final order = _visibleOrder();
      _includeOpenNote(order);
      shiftPressed ? _selection.extendTo(node.path, order) : _selection.toggle(node.path);
      return;
    }
    if (!AdaptiveLayout.usesPointer(context) && selecting) return _selection.toggle(node.path);
    _selection.clear();
    unawaited(_open());
  }

  void _showMenu(Rect anchor) {
    final selection = ref.read(noteSelectionProvider);
    final inSelection = selection.contains(node.path);
    if (!inSelection) _selection.clear();
    NoteNodeActions.showMenuFor(
      context,
      ref,
      nodes: _targets(inSelection ? selection : null),
      anchor: anchor,
      selectedPath: widget.selectedPath,
      onSelect: AdaptiveLayout.usesPointer(context) ? null : () => _selection.toggle(node.path),
    );
  }

  void _drop(NoteDrag drag) =>
      NoteNodeActions.drop(context, ref, drag: drag, destination: node.childrenPath, selectedPath: widget.selectedPath);

  @override
  Widget build(BuildContext context) {
    final folder = node.folder;
    final expanded = folder != null && node.hasChildren && ref.watch(expandedNotesProvider).contains(folder.path);
    if (folder != null && node.hasChildren) {
      ref.watch(notesTreeProvider(folder.path).select((children) => children.hasValue));
    }
    final readme = folder == null || node.page != null ? null : ref.watch(notesTreeProvider(folder.path)).value?.readme;
    final selection = ref.watch(
      noteSelectionProvider.select((selection) => selection.contains(node.path) ? selection : null),
    );

    final row = NoteDropTarget(
      destination: node.childrenPath,
      onDrop: _drop,
      onLinger: () => ref.read(expandedNotesProvider.notifier).expand(node.childrenPath),
      builder: (context, active) => NoteDragSource(
        nodes: _targets(selection),
        onHold: _showMenu,
        child: _row(
          context,
          selected: _isSelected(readme),
          marked: selection != null,
          expanded: expanded,
          dropActive: active,
          isSection: node.page == null && readme == null,
        ),
      ),
    );
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: expanded ? _groupColor(colors) : null,
        borderRadius: BorderRadius.circular(AdaptiveLayout.usesPointer(context) ? 8 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(_groupInset, 0, _groupInset / 2, _groupInset / 2),
                      child: _TreeLevel(
                        path: folder.path,
                        root: widget.root,
                        depth: widget.depth + 1,
                        selectedPath: widget.selectedPath,
                        onOpen: widget.onOpen,
                        parentTint: _tint ?? widget.parentTint,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required bool selected,
    required bool marked,
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
        color: switch ((dropActive, marked, selected)) {
          (true, _, _) => colors.primaryContainer,
          (_, true, _) => colors.primary.withValues(alpha: 0.16),
          (_, _, true) => colors.secondaryContainer,
          _ when widget.depth == 0 && !expanded => _tint?.withValues(alpha: 0.14) ?? Colors.transparent,
          _ => Colors.transparent,
        },
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: dropActive ? BorderSide(color: colors.primary, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: _onTap,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                SizedBox(width: _leading + widget.depth * (_indent - _groupInset)),
                if (_showsMarker) _TagMarker(color: _tint!),
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
                EntryTagDots(entry: node.page ?? node.folder!),
                _disclosure(context, expanded: expanded, height: height),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagMarker extends StatelessWidget {
  const _TagMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    ),
  );
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
