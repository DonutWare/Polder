import "package:flutter/material.dart";

import "package:polder/providers/browser/pending_uploads_provider.dart";
import "package:polder/screens/browser/widgets/browser_selection.dart";
import "package:polder/screens/browser/widgets/file_grid_tile.dart";
import "package:polder/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder/screens/browser/widgets/selection_highlight.dart";

class FileGridView extends StatefulWidget {
  const FileGridView({required this.parentPath, required this.items, required this.padding, this.select, super.key});

  final String parentPath;
  final List<BrowserItem> items;
  final EdgeInsets padding;
  final String? select;

  @override
  State<FileGridView> createState() => _FileGridViewState();
}

class _FileGridViewState extends State<FileGridView> {
  static const _maxTileExtent = 180.0;
  static const _spacing = 12.0;
  static const _aspectRatio = 0.85;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpNearSelected());
  }

  @override
  void didUpdateWidget(FileGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.select != oldWidget.select) WidgetsBinding.instance.addPostFrameCallback((_) => _jumpNearSelected());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Matches how SliverGridDelegateWithMaxCrossAxisExtent counts columns.
  static int _columnsFor(double width) => (width / (_maxTileExtent + _spacing)).ceil().clamp(1, 1000);

  void _jumpNearSelected() {
    final index = widget.items.indexWhere((item) => item.name == widget.select);
    final size = context.size;
    if (index < 0 || size == null || !_scroll.hasClients) return;
    final width = size.width - widget.padding.horizontal;
    final columns = _columnsFor(width);
    final rowHeight = (width - _spacing * (columns - 1)) / columns / _aspectRatio + _spacing;
    final offset = (index ~/ columns - 1) * rowHeight;
    _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => BrowserSelectionArea(
      parentPath: widget.parentPath,
      slots: [for (final item in widget.items) item.entry?.name],
      columns: _columnsFor(constraints.maxWidth - widget.padding.horizontal),
      child: GridView.builder(
        controller: _scroll,
        padding: widget.padding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _maxTileExtent,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          childAspectRatio: _aspectRatio,
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final entry = item.entry;
          if (item.pendingFolder case final folder?) return PendingFolderGridTile(key: ValueKey(folder), name: folder);
          if (entry == null) return PendingFileGridTile(key: ValueKey(item.name), upload: item.pending!);
          final tile = SelectableEntry(
            key: ValueKey(item.name),
            parentPath: widget.parentPath,
            entry: entry,
            builder: (context, interaction) =>
                FileGridTile(entry: entry, interaction: interaction, pending: item.pending, busy: item.busy),
          );
          return item.name == widget.select
              ? SelectionHighlight(key: ValueKey("selected-${item.name}"), child: tile)
              : tile;
        },
      ),
    ),
  );
}
