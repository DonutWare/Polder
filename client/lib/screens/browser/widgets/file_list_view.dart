import "package:flutter/material.dart";

import "package:polder/models/activity.dart";
import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/browser_selection.dart";
import "package:polder/screens/browser/widgets/file_drop_zone.dart";
import "package:polder/screens/browser/widgets/file_list_tile.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder/screens/browser/widgets/selection_highlight.dart";
import "package:polder/widgets/shared/nav_group.dart";

class FileListView extends StatefulWidget {
  const FileListView({required this.parentPath, required this.items, required this.padding, this.select, super.key});

  final String parentPath;
  final List<BrowserItem> items;
  final EdgeInsets padding;
  final String? select;

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  static const _estimatedTileHeight = 74.0;

  late final _scroll = ScrollController(initialScrollOffset: _estimatedOffset());

  double _estimatedOffset() {
    final index = widget.items.indexWhere((item) => item.name == widget.select);
    return index < 3 ? 0 : _estimatedTileHeight * (index - 2);
  }

  @override
  void didUpdateWidget(FileListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.select != null && widget.select != oldWidget.select && _scroll.hasClients) {
      _scroll.jumpTo(_estimatedOffset().clamp(0, _scroll.position.maxScrollExtent));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BrowserSelectionArea(
    parentPath: widget.parentPath,
    slots: [for (final item in widget.items) item.entry?.name],
    child: ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final entry = item.entry;
        final content = switch (item) {
          BrowserItem(:final pendingFolder?, :final syncing) => PendingFolderListTile(
            name: pendingFolder,
            direction: syncing ?? TransferDirectionKind.upload,
          ),
          _ when entry == null => PendingFileListTile(upload: item.pending!),
          _ => SelectableEntry(
            parentPath: widget.parentPath,
            entry: entry,
            builder: (context, interaction) =>
                FileListTile(entry: entry, interaction: interaction, pending: item.pending, syncing: item.syncing),
          ),
        };
        final droppable = entry != null && entry.isDir
            ? FolderDropTarget(
                folder: entry,
                shape: (side) => GroupedTile.shapeFor(index, widget.items.length, side: side),
                child: content,
              )
            : content;
        return GroupedTile(
          key: ValueKey(item.name),
          index: index,
          count: widget.items.length,
          child: item.name == widget.select
              ? SelectionHighlight(
                  key: ValueKey("selected-${item.name}"),
                  shape: (side) => GroupedTile.shapeFor(index, widget.items.length, side: side),
                  child: droppable,
                )
              : droppable,
        );
      },
    ),
  );
}
