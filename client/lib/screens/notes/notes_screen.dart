import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/providers/notes/last_note_provider.dart";
import "package:polder/providers/notes/note_document_provider.dart";
import "package:polder/providers/notes/notes_folder_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/providers/notes/renamed_note_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/screens/notes/widgets/links_panel.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";
import "package:polder/screens/notes/widgets/note_pane.dart";
import "package:polder/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder/screens/notes/widgets/notes_sidebar.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/dual_pane.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/fab_menu.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/widgets/tags/tag_chip.dart";

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({this.notePath, super.key});

  final String? notePath;

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

  void _open(FileEntry entry) => context.go(AppRoutes.noteAt(entry.path));

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
      ref.read(navigationHistoryProvider.notifier).replace(AppRoutes.noteAt(start));
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
        return TagTapHandler(onTag: _filterOnTag, child: _notes(context, root));
      },
    );
  }

  bool _filterOnTag(String name) {
    final tag = ref.read(tagsByKeyProvider)[tagKey(name)];
    if (tag == null) return false;
    ref.read(notesTagFilterProvider.notifier).only(tag.id);
    if (widget.notePath != null && AdaptiveLayout.isSingle(context)) _closeNote(AppRoutes.notes);
    return true;
  }

  Widget? _sidebar(String? root) =>
      root == null ? null : NotesSidebar(root: root, selectedPath: widget.notePath, onOpen: _open);

  void _createPage(String? root, {NewNoteKind kind = NewNoteKind.page}) {
    if (root == null) {
      NotesActions.createInNotesFolder(context, kind: kind);
    } else {
      NotesActions.createPage(context, folder: notesLevel(ref, root), kind: kind);
    }
  }

  void _addRecipe(String? root) {
    if (root == null) {
      NotesActions.addRecipeInNotesFolder(context);
    } else {
      NotesActions.addRecipe(context, folder: notesLevel(ref, root));
    }
  }

  void _closeNote(String location) {
    ref.read(lastNoteProvider.notifier).set(null);
    context.go(location);
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
      listActions: [if (root != null) NotesHeaderActions(onChangeFolder: _changeFolder)],
      listLocation: AppRoutes.notes,
      maxListWidth: _listWidth,
      forceSingle: grid,
      list: _sidebar(root) ?? _NoFolder(onSetUp: _changeFolder),
      listFloatingActionButton: FabMenu(
        icon: IconsaxPlusLinear.add,
        tooltip: context.localized.add,
        groups: [
          [
            FabMenuItem(
              icon: IconsaxPlusLinear.note_add,
              label: context.localized.noteNewPage,
              onPressed: () => _createPage(root),
            ),
            FabMenuItem(
              icon: IconsaxPlusLinear.task_square,
              label: context.localized.noteNewChecklist,
              onPressed: () => _createPage(root, kind: NewNoteKind.checklist),
            ),
          ],
          [
            FabMenuItem(
              icon: IconsaxPlusLinear.cake,
              label: context.localized.recipeAdd,
              onPressed: () => _addRecipe(root),
            ),
          ],
        ],
      ),
      onPop: _closeNote,
      placeholder: SafeArea(
        left: false,
        child: _NothingOpen(onCreate: () => NotesActions.createInNotesFolder(context)),
      ),
      detail: switch (notePath) {
        null => null,
        final notePath when single => NotePane(
          key: _paneKeyFor(notePath),
          path: notePath,
          sourceMode: _sourceMode,
          onToggleSourceMode: _toggleSourceMode,
          leading: IconButton(
            tooltip: context.localized.navNotes,
            icon: const Icon(IconsaxPlusLinear.arrow_left),
            onPressed: () => _closeNote(AppRoutes.notes),
          ),
          onToggleLinks: () => _showLinksSheet(notePath),
        ),
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
                  onOpen: (target) => openEntry(context, target, gallery: [target]),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _showLinksSheet(String notePath) async {
    final entry = ref.read(noteDocumentProvider(notePath)).value?.entry;
    if (entry == null) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.6,
        child: LinksPanel(
          entry: entry,
          onOpen: (target) {
            Navigator.pop(sheetContext);
            openEntry(context, target, gallery: [target]);
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

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: IconsaxPlusLinear.note_2,
    message: context.localized.notesNothingOpenMessage,
    action: FilledButton.tonal(onPressed: onCreate, child: Text(context.localized.noteNewPage)),
  );
}
