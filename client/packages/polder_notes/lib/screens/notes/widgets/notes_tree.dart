import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/models/item_selection.dart";
import "package:polder_notes/providers/notes/note_selection_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes/providers/notes/notes_search_provider.dart";
import "package:polder_notes/providers/notes/notes_view_provider.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_notes/providers/notes/notes_tag_filter_provider.dart";
import "package:polder_notes/screens/notes/widgets/note_node_interactions.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/util/modifier_keys.dart";
import "package:polder_ui/widgets/shared/async_value_view.dart";
import "package:polder_ui/widgets/tags/tag_chip.dart";

class NotesTree extends StatelessWidget {
  const NotesTree({
    required this.root,
    required this.selectedPath,
    required this.onOpen,
    this.filter,
    this.family,
    super.key,
  });

  final String root;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final NotesTreeFilter? filter;
  final String? family;

  @override
  Widget build(BuildContext context) => _TreeLevel(
    path: root,
    root: root,
    depth: 0,
    selectedPath: selectedPath,
    onOpen: onOpen,
    filter: filter,
    family: family,
  );
}

class _TreeLevel extends ConsumerWidget {
  const _TreeLevel({
    required this.path,
    required this.root,
    required this.depth,
    required this.selectedPath,
    required this.onOpen,
    this.filter,
    this.family,
    this.parentTint,
  });

  final String path;
  final String root;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final NotesTreeFilter? filter;
  final String? family;
  final Color? parentTint;

  bool _shows(NoteTreeNode node) => (family == null || node.path == family) && (filter?.shows(node) ?? true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contents = ref.watch(notesTreeProvider(path));
    final sort = ref.watch(notesSortProvider);
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
            for (final node in sortNoteNodes(contents.nodes, sort))
              if (_shows(node))
                _TreeNode(
                  key: ValueKey(node.path),
                  node: node,
                  root: root,
                  depth: depth,
                  selectedPath: selectedPath,
                  onOpen: onOpen,
                  filter: filter,
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
    this.filter,
    this.parentTint,
    super.key,
  });

  final NoteTreeNode node;
  final String root;
  final int depth;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final NotesTreeFilter? filter;
  final Color? parentTint;

  @override
  ConsumerState<_TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends ConsumerState<_TreeNode> {
  static const _indent = 16.0;
  static const _leading = 12.0;
  static const _groupInset = 8.0;
  static const _maxTintedDepth = 3;

  final _rowKey = GlobalKey();

  Color? get _tint => noteTintOf(ref.watch(tagsByIdProvider), node.page ?? node.folder!);

  bool get _showsMarker => widget.depth > 0 && _tint != null && _tint != widget.parentTint;

  Color? _groupColor(ColorScheme colors) {
    if (widget.depth >= _maxTintedDepth) return null;
    return _tint?.withValues(alpha: 0.12) ?? colors.onSurface.withValues(alpha: 0.04);
  }

  NoteTreeNode get node => widget.node;

  void _revealAfterLayout() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final row = _rowKey.currentContext;
    if (!mounted || row == null) return;
    ref.read(notesRevealProvider.notifier).done();
    unawaited(Scrollable.ensureVisible(row, alignment: 0.3, duration: const Duration(milliseconds: 200)));
  });

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
    final expanded =
        folder != null &&
        node.hasChildren &&
        ((widget.filter?.opens(node) ?? false) || ref.watch(expandedNotesProvider).contains(folder.path));
    if (folder != null && node.hasChildren) {
      ref.watch(notesTreeProvider(folder.path).select((children) => children.hasValue));
    }
    final readme = folder == null || node.page != null ? null : ref.watch(notesTreeProvider(folder.path)).value?.readme;
    final selection = ref.watch(
      noteSelectionProvider.select((selection) => selection.contains(node.path) ? selection : null),
    );

    final selected = _isSelected(readme);
    if (selected && ref.watch(notesRevealProvider) == widget.selectedPath) _revealAfterLayout();

    final row = NoteDropTarget(
      destination: node.childrenPath,
      onDrop: _drop,
      onLinger: () => ref.read(expandedNotesProvider.notifier).expand(node.childrenPath),
      builder: (context, active) => NoteDragSource(
        nodes: _targets(selection),
        onHold: _showMenu,
        child: _row(
          context,
          selected: selected,
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
                        filter: widget.filter,
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
                  child: Text.rich(
                    highlightedNoteTitle(node.name, widget.filter?.query, colors),
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

TextSpan highlightedNoteTitle(String title, String? query, ColorScheme colors) {
  final needle = query?.trim().toLowerCase() ?? "";
  final start = needle.isEmpty ? -1 : title.toLowerCase().indexOf(needle);
  if (start < 0) return TextSpan(text: title);
  final end = start + needle.length;
  return TextSpan(
    children: [
      TextSpan(text: title.substring(0, start)),
      TextSpan(
        text: title.substring(start, end),
        style: TextStyle(backgroundColor: colors.primary.withValues(alpha: 0.2), fontWeight: FontWeight.w700),
      ),
      TextSpan(text: title.substring(end)),
    ],
  );
}
