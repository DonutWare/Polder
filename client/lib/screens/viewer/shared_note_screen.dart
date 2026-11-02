import "dart:convert";
import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/providers/browser/file_content_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/screens/notes/editor/markdown_view.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/screens/shared/widgets/space_file_opener.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/notes/note_link.dart";
import "package:polder/util/external_link.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/async_value_view.dart";

class SharedNoteScreen extends ConsumerWidget {
  const SharedNoteScreen({required this.space, required this.entry, super.key});

  final FileSpace space;
  final FileEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = fileContentProvider((entry, space));
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.displayName, overflow: TextOverflow.ellipsis),
        actions: [
          if (ref.watch(spaceCapabilitiesProvider(space)).canDownload)
            IconButton(
              tooltip: context.localized.download,
              icon: const Icon(IconsaxPlusLinear.document_download),
              onPressed: () => ref.read(transfersProvider.notifier).downloadFromSpace(space, entry),
            ),
        ],
      ),
      body: AsyncValueView<Uint8List>(
        value: ref.watch(content),
        onRetry: () => ref.invalidate(content),
        data: (bytes) => ReadableWidth(
          builder: (context, inset) => ReadOnlyNote(
            text: utf8.decode(bytes, allowMalformed: true),
            targets: NoteTargets(notePath: entry.path, byId: const {}, space: space),
            padding: inset + const EdgeInsets.fromLTRB(24, 16, 24, 32),
            onLink: (destination) => _openLink(context, ref, destination),
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, WidgetRef ref, String destination) async {
    final uri = Uri.tryParse(destination);
    if (uri != null && uri.hasScheme) return openExternalLink(destination);
    final path = NoteLink.parse(destination, notePath: entry.path)?.path;
    if (path == null) return;
    final DirectoryListing listing;
    try {
      listing = await ref.read(
        spaceDirectoryProvider(SpaceLocation(space: space, path: RemotePath.parent(path))).future,
      );
    } on ApiException {
      return;
    }
    final target = listing.entries.where((candidate) => candidate.path == path).firstOrNull;
    if (target == null || target.isDir || !context.mounted) return;
    await openSpaceEntry(context, space, target, siblings: listing.entries);
  }
}
