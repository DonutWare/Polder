import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:pdfrx/pdfrx.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/file_content_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/screens/browser/widgets/file_details_sheet.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({required this.entry, super.key});

  final FileEntry entry;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final _controller = PdfViewerController();
  int? _page;
  int? _pageCount;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(fileContentProvider(widget.entry));
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.entry.name, overflow: TextOverflow.ellipsis),
            if (_page != null && _pageCount != null)
              Text("$_page / $_pageCount", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.localized.download,
            icon: const Icon(IconsaxPlusLinear.document_download),
            onPressed: () => ref.read(transfersProvider.notifier).download(widget.entry),
          ),
          IconButton(
            tooltip: context.localized.details,
            icon: const Icon(IconsaxPlusLinear.info_circle),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => FileDetailsSheet(entry: widget.entry),
            ),
          ),
        ],
      ),
      backgroundColor: colors.surfaceContainer,
      body: AsyncValueView<Uint8List>(
        value: content,
        onRetry: () => ref.invalidate(fileContentProvider(widget.entry)),
        data: (bytes) => PdfViewer.data(
          bytes,
          sourceName: "${widget.entry.path}@${widget.entry.rev}",
          controller: _controller,
          params: PdfViewerParams(
            backgroundColor: colors.surfaceContainer,
            pageDropShadow: BoxShadow(color: colors.shadow.withValues(alpha: 0.2), blurRadius: 8),
            onViewerReady: (document, _) => setState(() => _pageCount = document.pages.length),
            onPageChanged: (page) => setState(() => _page = page),
            viewerOverlayBuilder: (context, size, handleLinkTap) => [
              PdfViewerScrollThumb(
                controller: _controller,
                orientation: ScrollbarOrientation.right,
                thumbSize: const Size(40, 24),
                thumbBuilder: (context, thumbSize, pageNumber, controller) => DecoratedBox(
                  decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text("$pageNumber", style: TextStyle(color: colors.onSecondaryContainer)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
