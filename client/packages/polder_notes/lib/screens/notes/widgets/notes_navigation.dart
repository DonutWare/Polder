import "dart:async";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/models/user_tag.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/providers/tags/tags_provider.dart";
import "package:polder_notes/notes_locations.dart";
import "package:polder_notes/providers/notes/notes_folder_provider.dart";
import "package:polder_notes/providers/notes/notes_search_focus_provider.dart";
import "package:polder_notes/providers/notes/notes_tag_filter_provider.dart";
import "package:polder_notes/providers/notes/notes_view_provider.dart";
import "package:polder_notes/screens/notes/widgets/notes_add_button.dart";
import "package:polder_notes/screens/notes/widgets/notes_setup_dialog.dart";
import "package:polder_notes/screens/notes/widgets/notes_sidebar.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/dual_pane.dart";
import "package:polder_ui/widgets/navigation/navigation_shell.dart";
import "package:polder_ui/widgets/tags/tag_chip.dart";

String? _selectedNote(WidgetRef ref, Uri location) =>
    location.path == ref.read(notesLocationsProvider).root ? NotesLocations.pathOf(location) : null;

Future<void> _changeFolder(BuildContext context, WidgetRef ref) =>
    showNotesSetupDialog(context, suggestion: ref.read(notesFolderProvider).value);

Future<void> showNotesFlyout(BuildContext context, Uri location, {bool focusSearch = false}) {
  final anchor = context.findRenderObject()! as RenderBox;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final edge = anchor.localToGlobal(Offset(rtl ? 0 : anchor.size.width, 0)).dx;
  final inset = (rtl ? screenWidth - edge : edge) + 8;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black12,
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (flyoutContext, _, _) => _NotesFlyout(
      inset: inset,
      child: NotesNavigationSidebar(
        location: location,
        showActions: false,
        autofocusSearch: focusSearch,
        onOpened: () => Navigator.of(flyoutContext).pop(),
      ),
    ),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(
          begin: Offset(rtl ? 0.02 : -0.02, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

class _NotesFlyout extends StatelessWidget {
  const _NotesFlyout({required this.inset, required this.child});

  static const width = 320.0;

  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsetsDirectional.only(start: inset, top: 8, bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            elevation: 8,
            shape: squircle(AppRadius.panel, side: BorderSide(color: AppColors.of(context).border)),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    ),
  );
}

class NotesNavigationSidebar extends ConsumerStatefulWidget {
  const NotesNavigationSidebar({
    required this.location,
    this.showActions = true,
    this.autofocusSearch = false,
    this.onOpened,
    super.key,
  });

  final Uri location;
  final bool showActions;
  final bool autofocusSearch;
  final VoidCallback? onOpened;

  @override
  ConsumerState<NotesNavigationSidebar> createState() => _NotesNavigationSidebarState();
}

class _NotesNavigationSidebarState extends ConsumerState<NotesNavigationSidebar> {
  final _searchFocus = FocusNode(debugLabel: "NotesNavigationSearch");

  @override
  void initState() {
    super.initState();
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  bool _filterOnTag(String name) {
    final tag = ref.read(tagsByKeyProvider)[tagKey(name)];
    if (tag == null) return false;
    ref.read(notesTagFilterProvider.notifier).only(tag.id);
    return true;
  }

  void _open(FileEntry entry) {
    final router = GoRouter.of(context);
    final location = ref.read(notesLocationsProvider).noteAt(entry.path);
    widget.onOpened?.call();
    router.go(location);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notesSearchFocusRequestProvider, (_, _) => _searchFocus.requestFocus());
    final root = ref.watch(notesFolderProvider).value;
    final selectedPath = _selectedNote(ref, widget.location);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListPaneHeader(
          title: NotesTitle(root: root, selectedPath: selectedPath),
          actions: [
            if (root != null && widget.showActions)
              NotesHeaderActions(
                root: root,
                selectedPath: selectedPath,
                onChangeFolder: () => _changeFolder(context, ref),
              ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: root == null
                    ? const SizedBox.shrink()
                    : TagTapHandler(
                        onTag: _filterOnTag,
                        child: NotesSidebar(
                          root: root,
                          selectedPath: selectedPath,
                          searchFocus: _searchFocus,
                          allowGrid: false,
                          onOpen: _open,
                        ),
                      ),
              ),
              Positioned(right: 16, bottom: 16, child: NotesAddButton(root: root)),
            ],
          ),
        ),
      ],
    );
  }
}

class NotesNavigationRail extends ConsumerStatefulWidget {
  const NotesNavigationRail({required this.location, super.key});

  final Uri location;

  @override
  ConsumerState<NotesNavigationRail> createState() => _NotesNavigationRailState();
}

class _NotesNavigationRailState extends ConsumerState<NotesNavigationRail> {
  final _notesTile = GlobalKey();
  var _flyoutOpen = false;

  Future<void> _showNotes({bool focusSearch = false}) async {
    final anchor = _notesTile.currentContext;
    if (_flyoutOpen || anchor == null) return;
    _flyoutOpen = true;
    try {
      await showNotesFlyout(anchor, widget.location, focusSearch: focusSearch);
    } finally {
      _flyoutOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notesSearchFocusRequestProvider, (_, _) => unawaited(_showNotes(focusSearch: true)));
    final localized = context.localized;
    final root = ref.watch(notesFolderProvider).value;
    final grid = ref.watch(notesViewModeProvider) == NotesViewMode.grid;
    return Column(
      children: [
        if (!AdaptiveLayout.isSingle(context))
          RailTile(
            key: _notesTile,
            icon: IconsaxPlusLinear.note_2,
            label: localized.navNotes,
            onTap: () => unawaited(_showNotes()),
          ),
        if (root != null) ...[
          RailTile(
            icon: grid ? IconsaxPlusLinear.row_vertical : IconsaxPlusLinear.element_3,
            label: grid ? localized.listView : localized.gridView,
            onTap: ref.read(notesViewModeProvider.notifier).toggle,
          ),
          Builder(
            builder: (context) => RailTile(
              icon: IconsaxPlusLinear.sort,
              label: localized.notesViewOptions,
              onTap: () => unawaited(
                NotesOptionsMenu.showFrom(context, ref, root: root, selectedPath: _selectedNote(ref, widget.location)),
              ),
            ),
          ),
        ],
        RailTile(
          icon: IconsaxPlusLinear.setting_4,
          label: localized.notesChangeFolder,
          onTap: () => unawaited(_changeFolder(context, ref)),
        ),
      ],
    );
  }
}
