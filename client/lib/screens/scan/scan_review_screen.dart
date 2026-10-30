import "dart:io";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/scan_session.dart";
import "package:polder/providers/appearance/appearance_provider.dart";
import "package:polder/providers/branding/branding_provider.dart";
import "package:polder/providers/browser/document_scan_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/transfer/document_scanner_service.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/escape_cancels_drag.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";

Future<List<String>?> scanDocument(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final localizations = context.localized;
  try {
    final seed = ref.read(appearanceProvider).seedWith(ref.read(brandingProvider).accent);
    return await ref
        .read(documentScannerServiceProvider)
        .scan(
          accent: (
            light: buildColorScheme(seed, Brightness.light).primary,
            dark: buildColorScheme(seed, Brightness.dark).primary,
          ),
        );
  } on DocumentScanException catch (error) {
    final message = switch (error.failure) {
      DocumentScanFailure.cameraDenied => localizations.scanCameraDenied,
      DocumentScanFailure.other when error.reason.isNotEmpty => "${localizations.scanFailed}\n${error.reason}",
      DocumentScanFailure.other => localizations.scanFailed,
    };
    messenger?.showSnackBar(SnackBar(content: Text(message)));
    return null;
  }
}

class ScanReviewScreen extends ConsumerStatefulWidget {
  const ScanReviewScreen({required this.request, super.key});

  final ScanRequest request;

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  late final _name = TextEditingController(text: ref.read(scanSessionProvider(widget.request)).name);
  var _saving = false;

  ScanSessionNotifier get _session => ref.read(scanSessionProvider(widget.request).notifier);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider(widget.request));
    return PopScope(
      canPop: session.pages.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showConfirmDialog(
          context,
          title: context.localized.discardScanTitle,
          message: context.localized.discardScanMessage,
          confirmLabel: context.localized.discard,
          destructive: true,
        );
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.localized.reviewScan),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: session.canSave && !_saving ? _save : null,
                child: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.localized.save),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  itemCount: session.pages.length,
                  onReorderItem: _session.reorderPage,
                  itemBuilder: (context, index) => EscapeCancelsDrag(
                    key: ValueKey(session.pages[index]),
                    child: _PageCard(
                      path: session.pages[index],
                      number: index + 1,
                      onRemove: () => _session.removePage(index),
                    ),
                  ),
                  footer: _AddPagesCard(onTap: _addPages),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: context.localized.name,
                        suffixText: session.format == ScanFormat.pdf ? ".pdf" : null,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: _session.setName,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ScanFormat>(
                      segments: [
                        ButtonSegment(
                          value: ScanFormat.pdf,
                          icon: const Icon(IconsaxPlusLinear.document_text),
                          label: Text(context.localized.scanFormatPdf),
                        ),
                        ButtonSegment(
                          value: ScanFormat.images,
                          icon: const Icon(IconsaxPlusLinear.gallery),
                          label: Text(context.localized.scanFormatImages),
                        ),
                      ],
                      selected: {session.format},
                      onSelectionChanged: (selection) => _session.setFormat(selection.single),
                    ),
                    const SizedBox(height: 4),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(IconsaxPlusLinear.folder_2),
                      title: Text(context.localized.scanSaveTo),
                      subtitle: Text(session.directory),
                      trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                      onTap: () => _pickDirectory(session.directory),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPages() async {
    final pages = await scanDocument(context, ref);
    if (pages != null && mounted) _session.addPages(pages);
  }

  Future<void> _pickDirectory(String current) async {
    final directory = await showRemoteFolderPicker(context, initialPath: current);
    if (directory != null && mounted) _session.setDirectory(directory);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await context.runWithFeedback(_session.save());
      if (saved && mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({required this.path, required this.number, required this.onRemove});

  final String path;
  final int number;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AspectRatio(
        aspectRatio: 1 / 1.414,
        child: Card.filled(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(child: Image.file(File(path), fit: BoxFit.contain, cacheWidth: 1024)),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: context.localized.removePage,
                  icon: const Icon(IconsaxPlusLinear.trash),
                  onPressed: onRemove,
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      context.localized.pageNumber(number),
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
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

class _AddPagesCard extends StatelessWidget {
  const _AddPagesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1 / 1.414,
    child: Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(IconsaxPlusLinear.add, size: 32),
            const SizedBox(height: 8),
            Text(context.localized.addPages),
          ],
        ),
      ),
    ),
  );
}
