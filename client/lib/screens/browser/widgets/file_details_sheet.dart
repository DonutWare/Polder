import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/providers/versions/file_versions_provider.dart";
import "package:polder/screens/browser/widgets/file_history_sheet.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/detail_row.dart";

class FileDetailsSheet extends ConsumerWidget {
  const FileDetailsSheet({required this.entry, this.onShowHistory, super.key});

  final FileEntry entry;
  final VoidCallback? onShowHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: FileThumbnail(entry: entry, dimension: 160, fill: true)),
            const SizedBox(height: 16),
            Text(entry.name, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            DetailRow(
              label: localized.size,
              value: ByteFormat.format(entry.size, locale: context.localeName),
            ),
            DetailRow(label: localized.modified, value: entry.mtime.formatted(context)),
            if (entry.mime.isNotEmpty) DetailRow(label: localized.type, value: entry.mime),
            if (entry.width != null && entry.height != null)
              DetailRow(label: localized.dimensionsLabel, value: localized.dimensions(entry.width!, entry.height!)),
            if (entry.pageCount != null) DetailRow(label: localized.pages, value: "${entry.pageCount}"),
            if (entry.takenAt != null) DetailRow(label: localized.takenAt, value: entry.takenAt!.formatted(context)),
            if (!entry.isDir)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  if (onShowHistory case final show?) {
                    show();
                  } else {
                    showFileHistory(navigator.context, entry);
                  }
                },
                child: DetailRow(
                  label: localized.versions,
                  value: switch (ref.watch(fileVersionsProvider(entry.path))) {
                    AsyncValue(:final value?) => localized.versionCount(value.versions.length),
                    _ => "…",
                  },
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (!entry.isDir && entry.id > 0) _LinkedFrom(entry: entry),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(IconsaxPlusLinear.document_download),
              label: Text(localized.download),
              onPressed: () {
                ref.read(transfersProvider.notifier).download(entry);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedFrom extends ConsumerWidget {
  const _LinkedFrom({required this.entry});

  final FileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incoming = ref.watch(fileLinksProvider(entry.id)).value?.incoming ?? const [];
    final sources = {for (final link in incoming) link.source.id: link.source}.values;
    if (sources.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(context.localized.noteLinkedFrom, style: Theme.of(context).textTheme.titleSmall),
        for (final source in sources)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: FileTypeIcon(entry: source, size: 22),
            title: Text(source.name),
            subtitle: Text(source.path),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              openEntry(navigator.context, source);
            },
          ),
      ],
    );
  }
}
