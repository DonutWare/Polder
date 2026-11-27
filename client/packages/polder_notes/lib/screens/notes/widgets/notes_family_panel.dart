import "dart:async";

import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_notes/providers/notes/notes_tree_provider.dart";
import "package:polder_notes/screens/notes/widgets/note_node_interactions.dart";
import "package:polder_notes/screens/notes/widgets/notes_sidebar.dart";
import "package:polder_notes/screens/notes/widgets/notes_tree.dart";
import "package:polder_ui/util/adaptive_layout/adaptive_layout.dart";
import "package:polder_ui/util/localization_helper.dart";

class NotesFamilyPanel extends ConsumerStatefulWidget {
  const NotesFamilyPanel({
    required this.root,
    required this.family,
    required this.selectedPath,
    required this.onOpen,
    super.key,
  });

  final String root;
  final NoteTreeNode family;
  final String selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<NotesFamilyPanel> createState() => _NotesFamilyPanelState();
}

class _NotesFamilyPanelState extends ConsumerState<NotesFamilyPanel> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _expandFamily();
  }

  @override
  void didUpdateWidget(NotesFamilyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.family.path != widget.family.path) _expandFamily();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _expandFamily() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final expanded = ref.read(expandedNotesProvider.notifier);
    expanded.expand(widget.family.childrenPath);
    expanded.expandTo(widget.root, widget.selectedPath);
  });

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final theme = Theme.of(context);
    final density = AdaptiveLayout.usesPointer(context) ? VisualDensity.compact : VisualDensity.standard;
    final family = widget.family.childrenPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  localized.notesShowFamilyTree,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              IconButton(
                tooltip: localized.notesExpandAll,
                visualDensity: density,
                icon: const Icon(IconsaxPlusLinear.add_square, size: 20),
                onPressed: () => unawaited(NotesOptionsMenu.expandAll(ref, widget.root, within: family)),
              ),
              IconButton(
                tooltip: localized.notesCollapseAll,
                visualDensity: density,
                icon: const Icon(IconsaxPlusLinear.minus_square, size: 20),
                onPressed: () => ref.read(expandedNotesProvider.notifier).collapseWithin(family),
              ),
            ],
          ),
        ),
        Expanded(
          child: NoteDragAutoScroll(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: NotesTree(
                root: widget.root,
                selectedPath: widget.selectedPath,
                onOpen: widget.onOpen,
                family: widget.family.path,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
