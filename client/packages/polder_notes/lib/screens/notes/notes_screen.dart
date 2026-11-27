import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_notes/providers/notes/last_note_provider.dart";
import "package:polder_notes/providers/notes/note_document_provider.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_search_focus_provider.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes/providers/notes/notes_view_provider.dart";
import "package:polder_notes/providers/notes/renamed_note_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_notes/screens/notes/notes_actions.dart";
import "package:polder_notes/screens/notes/widgets/links_panel.dart";
import "package:polder_notes/screens/notes/widgets/note_node_interactions.dart";
import "package:polder_notes/screens/notes/widgets/note_pane.dart";
import "package:polder_notes/screens/notes/widgets/notes_family_panel.dart";
import "package:polder_notes/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder_notes/screens/notes/widgets/notes_add_button.dart";
import "package:polder_notes/screens/notes/widgets/notes_sidebar.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/dual_pane.dart";
import "package:polder_ui/widgets/shared/async_value_view.dart";
import "package:polder_ui/widgets/shared/message_view.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_core/models/user_tag.dart";
import "package:polder_notes/providers/notes/notes_tag_filter_provider.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_ui/widgets/tags/tag_chip.dart";
import "package:polder_ui/routes/up_scope.dart";

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({this.notePath, this.showSidebar = true, super.key});

  final String? notePath;
  final bool showSidebar;

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  static const _linksWidth = 300.0;
  static const _listWidth = 320.0;

  var _linksShown = true;
  var _sourceMode = false;
  FileEntry? _lastLinksEntry;
  var _askedForFolder = false;
  String? _panePath;
  Key? _paneKey;
  final _searchFocus = FocusNode(debugLabel: "NotesSearch");

  Key _paneKeyFor(String notePath) {
    final renamed = ref.watch(renamedNoteProvider);
    final kept = _paneKey;
    final continues = notePath == _panePath || (renamed != null && renamed == (from: _panePath, to: notePath));
    _panePath = notePath;
    if (kept != null && continues) return kept;
    return _paneKey = ValueKey(notePath);
  }

  @override
  void initState() {
    super.initState();
    _rememberOpenNote();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notePath != widget.notePath) _rememberOpenNote();
  }

  void _rememberOpenNote() {
    final path = widget.notePath;
    if (path == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lastNoteProvider.notifier).set(path);
      final root = ref.read(notesFolderProvider).value;
      if (root != null) ref.read(expandedNotesProvider.notifier).expandTo(root, path);
    });
  }

  void _toggleSourceMode() => setState(() => _sourceMode = !_sourceMode);

  void _open(FileEntry entry) => context.go(notesLocationsOf(context).noteAt(entry.path));

  void _openInFamily(String root, FileEntry entry) {
    final holder = notesGridFolderFor(root, entry.path);
    ref.read(notesGridFolderProvider.notifier).open(holder == root ? null : holder);
    _open(entry);
  }

  void _focusSearch() {
    final noteCovers =
        widget.notePath != null &&
        (ref.read(notesViewModeProvider) == NotesViewMode.grid || AdaptiveLayout.isSingle(context));
    if (noteCovers) return;
    if (_searchFocus.context == null) {
      ref.read(notesSearchFocusRequestProvider.notifier).request();
    } else {
      _searchFocus.requestFocus();
    }
  }

  Future<void> _changeFolder() async {
    final current = ref.read(notesFolderProvider).value;
    await showNotesSetupDialog(context, suggestion: current);
  }

  void _askForFolderOnce() {
    if (_askedForFolder) return;
    _askedForFolder = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showNotesSetupDialog(context);
    });
  }

  void _openStartPage(String root) {
    final last = ref.read(lastNoteProvider);
    final readme = ref.watch(notesTreeProvider(root)).value?.readme;
    final start = last ?? readme?.path;
    if (start == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.notePath != null) return;
      ref.read(navigationHistoryProvider.notifier).replace(ref.read(notesLocationsProvider).noteAt(start));
    });
  }

  @override
  Widget build(BuildContext context) {
    final folder = ref.watch(notesFolderProvider);
    return AsyncValueView<String?>(
      value: folder,
      onRetry: () => ref.invalidate(notesFolderProvider),
      data: (root) {
        if (root == null && widget.notePath == null) _askForFolderOnce();
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _focusSearch,
            const SingleActivator(LogicalKeyboardKey.keyF, control: true): _focusSearch,
          },
          child: TagTapHandler(onTag: _filterOnTag, child: _notes(context, root)),
        );
      },
    );
  }

  bool _filterOnTag(String name) {
    final tag = ref.read(tagsByKeyProvider)[tagKey(name)];
    if (tag == null) return false;
    ref.read(notesTagFilterProvider.notifier).only(tag.id);
    if (widget.notePath != null && AdaptiveLayout.isSingle(context)) _closeNote(notesLocationsOf(context).root);
    return true;
  }

  bool get _listInShell => !widget.showSidebar && !AdaptiveLayout.isSingle(context);

  Widget? _sidebar(String? root) => root == null
      ? null
      : NotesSidebar(
          root: root,
          selectedPath: widget.notePath,
          onOpen: _open,
          searchFocus: _searchFocus,
          showSearch: !_listInShell,
        );

  void _closeNote(String location) {
    ref.read(lastNoteProvider.notifier).set(null);
    goWithin(context, location, replacing: true);
  }

  Widget _notes(BuildContext context, String? root) {
    final notePath = widget.notePath;
    final grid = ref.watch(notesViewModeProvider) == NotesViewMode.grid;
    final single = grid || AdaptiveLayout.isSingle(context);
    if (!single && notePath == null && root != null) _openStartPage(root);
    final entry = single || notePath == null
        ? null
        : ref.watch(noteDocumentProvider(notePath)).value?.entry ?? _lastLinksEntry;
    _lastLinksEntry = entry;
    return DualPane(
      title: NotesTitle(root: root, selectedPath: notePath),
      listActions: [
        if (root != null && (widget.showSidebar || AdaptiveLayout.isPhone(context)))
          NotesHeaderActions(root: root, selectedPath: notePath, onChangeFolder: _changeFolder),
      ],
      listLocation: notesLocationsOf(context).root,
      maxListWidth: _listWidth,
      forceSingle: grid,
      showList: widget.showSidebar,
      listScrollsUnderBars: true,
      list: _sidebar(root) ?? _NoFolder(onSetUp: _changeFolder),
      listFloatingActionButton: _listInShell ? null : NotesAddButton(root: root),
      onPop: _closeNote,
      placeholder: SafeArea(
        left: false,
        child: _NothingOpen(onCreate: _listInShell ? null : () => NotesActions.createInNotesFolder(context)),
      ),
      detail: switch (notePath) {
        null => null,
        final notePath when single => _singleNote(root, notePath, grid: grid),
        final notePath => SafeArea(
          key: _paneKeyFor(notePath),
          left: false,
          top: false,
          child: NotePane(
            path: notePath,
            sourceMode: _sourceMode,
            onToggleSourceMode: _toggleSourceMode,
            linksShown: _linksShown,
            onToggleLinks: () => setState(() => _linksShown = !_linksShown),
          ),
        ),
      },
      trailing: !single && _linksShown && entry != null
          ? SizedBox(
              width: _linksWidth,
              child: SafeArea(
                left: false,
                child: LinksPanel(
                  entry: entry,
                  onOpen: (target) => notesHostOf(context).openFile(context, target, gallery: [target]),
                ),
              ),
            )
          : null,
    );
  }

  Widget _singleNote(String? root, String notePath, {required bool grid}) {
    final family = grid && root != null ? notesFamilyOf(ref.watch(notesTreeProvider(root)).value, notePath) : null;
    final beside = family != null && !AdaptiveLayout.isSingle(context);
    final pane = NotePane(
      key: beside ? null : _paneKeyFor(notePath),
      path: notePath,
      sourceMode: _sourceMode,
      onToggleSourceMode: _toggleSourceMode,
      leading: IconButton(
        tooltip: context.localized.navNotes,
        icon: const Icon(IconsaxPlusLinear.arrow_left),
        onPressed: () => unawaited(UpScope.navigateUp(context)),
      ),
      onToggleLinks: () => _showLinksSheet(notePath),
      onShowFamily: family == null || beside ? null : () => _showFamilySheet(root!, family, notePath),
    );
    if (!beside) return pane;
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: ValueKey("family:${family.path}"),
      color: colors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _listWidth,
            child: Material(
              color: colors.surfaceContainerLow,
              child: SafeArea(
                right: false,
                child: NotesFamilyPanel(
                  root: root!,
                  family: family,
                  selectedPath: notePath,
                  onOpen: (entry) => _openInFamily(root, entry),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: KeyedSubtree(key: _paneKeyFor(notePath), child: pane),
          ),
        ],
      ),
    );
  }

  Future<void> _showFamilySheet(String root, NoteTreeNode family, String notePath) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.6,
        child: NotesFamilyPanel(
          root: root,
          family: family,
          selectedPath: notePath,
          onOpen: (entry) {
            Navigator.pop(sheetContext);
            _openInFamily(root, entry);
          },
        ),
      ),
    );
  }

  Future<void> _showLinksSheet(String notePath) async {
    final entry = ref.read(noteDocumentProvider(notePath)).value?.entry;
    if (entry == null) return;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.6,
        child: LinksPanel(
          entry: entry,
          onOpen: (target) {
            Navigator.pop(sheetContext);
            notesHostOf(context).openFile(context, target, gallery: [target]);
          },
        ),
      ),
    );
  }
}

class _NoFolder extends StatelessWidget {
  const _NoFolder({required this.onSetUp});

  final VoidCallback onSetUp;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: IconsaxPlusLinear.note_2,
    message: context.localized.notesSetupMessage,
    action: FilledButton(onPressed: onSetUp, child: Text(context.localized.notesSetUp)),
  );
}

class _NothingOpen extends StatelessWidget {
  const _NothingOpen({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: IconsaxPlusLinear.note_2,
    message: context.localized.notesNothingOpenMessage,
    action: switch (onCreate) {
      null => null,
      final onCreate => FilledButton.tonal(onPressed: onCreate, child: Text(context.localized.noteNewPage)),
    },
  );
}
