import "dart:math" as math;

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/note_preview_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/notes_view_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/screens/notes/widgets/link_preview_card.dart";
import "package:polder/screens/notes/widgets/note_node_interactions.dart";
import "package:polder/services/notes/note_checklist.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";

class NotesGrid extends ConsumerStatefulWidget {
  const NotesGrid({required this.folder, required this.selectedPath, required this.onOpen, super.key});

  final String folder;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  ConsumerState<NotesGrid> createState() => _NotesGridState();
}

class _NotesGridState extends ConsumerState<NotesGrid> {
  static const _minTileWidth = 150.0;
  static const _minWideTileWidth = 220.0;
  static const _wideFrom = 600.0;
  static const _spacing = 8.0;
  static const _padding = EdgeInsets.fromLTRB(12, 4, 12, 96);

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static int _columnsFor(double width) =>
      math.max(1, ((width - _padding.horizontal + _spacing) / (_tileWidthFor(width) + _spacing)).floor());

  static double _tileWidthFor(double width) => width < _wideFrom ? _minTileWidth : _minWideTileWidth;

  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(notesTreeProvider(widget.folder));
    return AsyncValueView<NotesFolderContents>(
      value: contents,
      onRetry: () => ref.invalidate(notesTreeProvider(widget.folder)),
      data: (contents) {
        if (contents.nodes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.localized.notesEmptyFolder,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          );
        }
        return LayoutBuilder(builder: (context, constraints) => _masonry(contents.nodes, constraints.maxWidth));
      },
    );
  }

  Widget _masonry(List<NoteTreeNode> nodes, double width) {
    final columns = _columnsFor(width);
    return NoteDragAutoScroll(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        padding: _padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _spacing,
          children: [
            for (var column = 0; column < columns; column++)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _spacing,
                  children: [
                    for (var index = column; index < nodes.length; index += columns)
                      _NoteCard(
                        key: ValueKey(nodes[index].path),
                        node: nodes[index],
                        selectedPath: widget.selectedPath,
                        onOpen: widget.onOpen,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.node, required this.selectedPath, required this.onOpen, super.key});

  static const _maxImageHeight = 220.0;
  static const _maxLinkRows = 2;

  final NoteTreeNode node;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  void _openSubpages(WidgetRef ref) => ref.read(notesGridFolderProvider.notifier).open(node.childrenPath);

  void _activate(WidgetRef ref) {
    final page = node.page;
    if (page == null) {
      _openSubpages(ref);
    } else {
      onOpen(page);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => NoteDropTarget(
    destination: node.childrenPath,
    onDrop: (dropped) =>
        NoteNodeActions.drop(context, ref, node: dropped, destination: node.childrenPath, selectedPath: selectedPath),
    builder: (context, active) => NoteDragSource(node: node, child: _card(context, ref, active)),
  );

  Widget _card(BuildContext context, WidgetRef ref, bool dropActive) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final page = node.page;
    final selected = page != null && page.path == selectedPath;
    final preview = page == null ? null : ref.watch(notePreviewProvider(page)).value;
    final image = preview?.image;
    final checklist = preview?.checklist;
    final excerpt = checklist == null ? preview?.excerpt : null;
    final links = preview?.links.take(_maxLinkRows) ?? const <String>[];
    final foreground = selected ? colors.onSecondaryContainer : colors.onSurface;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: dropActive
          ? colors.primaryContainer
          : selected
          ? colors.secondaryContainer
          : colors.surfaceContainer,
      shape: squircle(
        AppRadius.inset,
        side: dropActive ? BorderSide(color: colors.primary, width: 2) : BorderSide(color: colors.outlineVariant),
      ),
      child: GestureDetector(
        onSecondaryTapUp: (details) => _showMenu(context, ref, details.globalPosition & Size.zero),
        child: InkWell(
          onTap: () => _activate(ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (page != null && image != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: _maxImageHeight),
                  child: _CardImage(notePath: page.path, destination: image),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (page == null) ...[
                      Icon(IconsaxPlusLinear.folder, size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        node.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
              if (excerpt != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                  child: Text(
                    excerpt,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              if (checklist != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 14, 0),
                  child: _ChecklistPreview(items: checklist, selected: selected),
                ),
              for (final link in links)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: LinkPreviewRow(key: ValueKey(link), url: link),
                ),
              _footer(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final size = NoteTargetSize.button(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: node.hasChildren
                ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: Size(size, size),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: const Icon(IconsaxPlusLinear.folder_open, size: 16),
                      label: Text(localized.noteSubpages, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onPressed: () => _openSubpages(ref),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: localized.moreOptions,
              icon: const Icon(Icons.more_horiz, size: 18),
              constraints: BoxConstraints.tightFor(width: size, height: size),
              padding: EdgeInsets.zero,
              onPressed: () => _showMenu(context, ref, NoteNodeActions.anchorOf(buttonContext)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref, Rect anchor) =>
      NoteNodeActions.showMenuFor(context, ref, node: node, anchor: anchor, selectedPath: selectedPath);
}

class _ChecklistPreview extends StatelessWidget {
  const _ChecklistPreview({required this.items, required this.selected});

  static const _maxRows = 8;

  final List<ChecklistItem> items;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = selected ? colors.onSecondaryContainer : colors.onSurfaceVariant;
    final style = theme.textTheme.bodySmall?.copyWith(color: color);
    final open = items.where((item) => !item.checked && item.text.trim().isNotEmpty).toList();
    final checked = items.where((item) => item.checked).length;
    final hidden = open.length - _maxRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in open.take(_maxRows))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_box_outline_blank_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(item.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
                ),
              ],
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text("+$hidden", style: style),
          ),
        if (checked > 0)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 4),
            child: Text("+ ${context.localized.noteCheckedItems(checked)}", style: style),
          ),
      ],
    );
  }
}

class _CardImage extends ConsumerWidget {
  const _CardImage({required this.notePath, required this.destination});

  static const _placeholderHeight = 120.0;

  final String notePath;
  final String destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = NoteTargets(notePath: notePath, byId: const {});
    return Image(
      image: noteImage(ref.watch(polderApiProvider), targets, destination),
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, loadedSynchronously) => frame == null && !loadedSynchronously
          ? Container(height: _placeholderHeight, color: Theme.of(context).colorScheme.surfaceContainerHighest)
          : child,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
