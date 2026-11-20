import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/note_selection_provider.dart";
import "package:polder/providers/notes/notes_search_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";
import "package:polder/screens/notes/widgets/notes_grid.dart";
import "package:polder/screens/notes/widgets/notes_tag_filter.dart";
import "package:polder/screens/notes/widgets/notes_tree.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
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
  const NotesSidebar({
    required this.root,
    required this.selectedPath,
    required this.onOpen,
    required this.searchFocus,
    super.key,
  });

  final String root;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;
  final FocusNode searchFocus;

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

  bool get _grid => ref.watch(notesViewModeProvider) == NotesViewMode.grid;

  @override
  Widget build(BuildContext context) {
    final searching = ref.watch(notesSearchQueryProvider).trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NotesSearchField(focusNode: widget.searchFocus),
              const NotesViewChips(),
            ],
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: switch ((searching, ref.watch(notesTagFilterProvider))) {
              (true, _) => _searchResults(),
              (false, AllNotes()) => _allNotes(),
              _ => _taggedNotes(),
            },
          ),
        ),
      ],
    );
  }

  Widget _flatNotes(List<FileEntry> notes) {
    final sorted = sortNoteEntries(notes, ref.watch(notesSortProvider));
    if (_grid) {
      return NotesGrid(
        folder: widget.root,
        nodes: [for (final note in sorted) NoteTreeNode(page: note)],
        selectedPath: widget.selectedPath,
        onOpen: widget.onOpen,
      );
    }
    return TaggedNotesList(root: widget.root, notes: sorted, selectedPath: widget.selectedPath, onOpen: widget.onOpen);
  }

  Widget _taggedNotes() => AsyncValueView<List<FileEntry>?>(
    value: ref.watch(notesInViewProvider),
    onRetry: () => ref.invalidate(notesIndexProvider),
    data: (notes) => _flatNotes(notes ?? const []),
  );

  Widget _searchResults() => AsyncValueView<NotesSearchResults?>(
    value: ref.watch(notesSearchResultsProvider),
    onRetry: () => ref.invalidate(notesIndexProvider),
    data: (results) => switch (results) {
      null => const SizedBox.shrink(),
      NotesSearchResults(:final notes) when notes.isEmpty => const _NoSearchMatches(),
      final results when _grid || ref.watch(notesTagFilterProvider) is! AllNotes => _flatNotes(results.notes),
      final results => _tree(filter: results.filter),
    },
  );

  Widget _allNotes() {
    if (_grid) {
      return NotesGrid(folder: notesLevel(ref, widget.root), selectedPath: widget.selectedPath, onOpen: widget.onOpen);
    }
    return _tree();
  }

  Widget _tree({NotesTreeFilter? filter}) => Focus(
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
                child: NotesTree(
                  root: widget.root,
                  selectedPath: widget.selectedPath,
                  onOpen: widget.onOpen,
                  filter: filter,
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

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape) return KeyEventResult.ignored;
    if (ref.read(noteSelectionProvider).isEmpty) return KeyEventResult.ignored;
    ref.read(noteSelectionProvider.notifier).clear();
    return KeyEventResult.handled;
  }
}

class _NoSearchMatches extends StatelessWidget {
  const _NoSearchMatches();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      context.localized.notesSearchNoResults,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class NotesSearchField extends ConsumerStatefulWidget {
  const NotesSearchField({required this.focusNode, super.key});

  final FocusNode focusNode;

  @override
  ConsumerState<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends ConsumerState<NotesSearchField> {
  late final _controller = TextEditingController(text: ref.read(notesSearchQueryProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(notesSearchQueryProvider.notifier).clear();
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notesSearchQueryProvider, (_, query) {
      if (query != _controller.text) _controller.text = query;
    });
    final colors = Theme.of(context).colorScheme;
    final pointer = AdaptiveLayout.usesPointer(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _clear},
        child: TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.search,
          onChanged: ref.read(notesSearchQueryProvider.notifier).set,
          style: pointer ? Theme.of(context).textTheme.bodyMedium : null,
          decoration: InputDecoration(
            isDense: true,
            hintText: context.localized.notesSearchHint,
            prefixIcon: Icon(IconsaxPlusLinear.search_normal_1, size: 18, color: colors.onSurfaceVariant),
            suffixIcon: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: context.localized.notesFilterClear,
                      icon: const Icon(IconsaxPlusLinear.close_circle, size: 18),
                      onPressed: _clear,
                    ),
            ),
            filled: true,
            fillColor: colors.onSurface.withValues(alpha: 0.05),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: pointer ? 8 : 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(pointer ? 8 : 12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
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
  const NotesHeaderActions({required this.root, this.selectedPath, this.onChangeFolder, super.key});

  final String root;
  final String? selectedPath;
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
        NotesOptionsMenu(root: root, selectedPath: selectedPath, density: density),
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

enum _TreeAction { expandAll, collapseAll, reveal }

class NotesOptionsMenu extends ConsumerWidget {
  const NotesOptionsMenu({required this.root, required this.selectedPath, required this.density, super.key});

  final String root;
  final String? selectedPath;
  final VisualDensity density;

  static Future<void> expandAll(WidgetRef ref, String root, {String? within}) async {
    final expanded = ref.read(expandedNotesProvider.notifier);
    final notes = await ref.read(notesIndexProvider.future);
    expanded.expandAll({
      for (final folder in allNoteFolders(root, notes))
        if (within == null || folder == within || RemotePath.isWithin(folder, within)) folder,
    });
  }

  static void reveal(WidgetRef ref, String root, String path) {
    ref.read(notesSearchQueryProvider.notifier).clear();
    ref.read(expandedNotesProvider.notifier).expandTo(root, path);
    ref.read(notesRevealProvider.notifier).reveal(path);
  }

  void _choose(WidgetRef ref, Object choice) {
    final sort = ref.read(notesSortProvider.notifier);
    switch (choice) {
      case final NotesSortField field:
        unawaited(sort.select(field));
      case final bool ascending:
        unawaited(sort.setAscending(ascending));
      case _TreeAction.expandAll:
        unawaited(expandAll(ref, root));
      case _TreeAction.collapseAll:
        ref.read(expandedNotesProvider.notifier).collapseAll();
      case _TreeAction.reveal:
        reveal(ref, root, selectedPath!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final sort = ref.watch(notesSortProvider);
    final tree = ref.watch(notesViewModeProvider) == NotesViewMode.tree;
    return PopupMenuButton<Object>(
      tooltip: localized.notesViewOptions,
      icon: const Icon(IconsaxPlusLinear.sort),
      style: IconButton.styleFrom(visualDensity: density),
      onSelected: (choice) => _choose(ref, choice),
      itemBuilder: (_) => [
        for (final field in NotesSortField.values)
          CheckedPopupMenuItem(
            value: field,
            checked: sort.field == field,
            child: Text(switch (field) {
              NotesSortField.name => localized.name,
              NotesSortField.modified => localized.modified,
            }),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(value: true, checked: sort.ascending, child: Text(localized.sortAscending)),
        CheckedPopupMenuItem(value: false, checked: !sort.ascending, child: Text(localized.sortDescending)),
        if (tree) ...[
          const PopupMenuDivider(),
          PopupMenuItem(value: _TreeAction.expandAll, child: Text(localized.notesExpandAll)),
          PopupMenuItem(value: _TreeAction.collapseAll, child: Text(localized.notesCollapseAll)),
          if (selectedPath != null) PopupMenuItem(value: _TreeAction.reveal, child: Text(localized.notesRevealCurrent)),
        ],
      ],
    );
  }
}
