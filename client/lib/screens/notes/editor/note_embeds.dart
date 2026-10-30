import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/screens/notes/editor/note_image_provider.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_link.dart";
import "package:polder/services/notes/note_markdown.dart";

class NoteTargets {
  const NoteTargets({required this.notePath, required this.byId});

  final String notePath;
  final Map<int, FileEntry> byId;

  NoteLink? parse(String destination) => NoteLink.parse(destination, notePath: notePath);

  FileEntry? knownTarget(NoteLink link) => link.fileId == null ? null : byId[link.fileId];
}

const notePreviewSize = 512;

const notePreviewRadius = BorderRadius.all(Radius.circular(6));

ImageProvider noteImage(PolderApi api, NoteTargets targets, String destination) {
  final uri = Uri.tryParse(destination);
  if (uri != null && (uri.scheme == "http" || uri.scheme == "https")) return NetworkImage(destination);
  final link = targets.parse(destination);
  final known = link == null ? null : targets.knownTarget(link);
  return NoteImageProvider(
    identity: "${targets.notePath}|$destination|${known?.rev}",
    load: () => _imageBytes(api, link, known),
  );
}

Future<Uint8List> _imageBytes(PolderApi api, NoteLink? link, FileEntry? known) async {
  final entry = known ?? (link?.path == null ? null : await api.stat(link!.path!));
  if (entry == null) throw StateError("the linked image does not exist");
  if (entry.hasPreview) {
    final preview = await api.preview(entry.path, size: notePreviewSize);
    if (preview != null) return preview;
  }
  if (!entry.isImage) throw StateError("the linked file has no preview");
  return api.downloadBytes(entry.path);
}

class NoteLinkIcon extends ConsumerWidget {
  const NoteLinkIcon({required this.destination, required this.targets, super.key});

  final String destination;
  final NoteTargets targets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = targets.parse(destination);
    if (link == null) return const SizedBox.shrink();
    final entry =
        targets.knownTarget(link) ?? (link.path == null ? null : ref.watch(fileAtPathProvider(link.path!)).value);
    if (entry == null) {
      return Icon(Icons.link_off, size: 16, color: Theme.of(context).colorScheme.error);
    }
    if (entry.isMarkdown) return const SizedBox.shrink();
    return FileTypeIcon(entry: entry, size: 16);
  }
}

class NoteImage extends ConsumerWidget {
  const NoteImage({
    required this.destination,
    required this.alt,
    required this.targets,
    required this.onOpen,
    super.key,
  });

  static const maxHeight = 420.0;

  final String destination;
  final String alt;
  final NoteTargets targets;
  final void Function(String destination) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: alt.isEmpty ? destination : alt,
      child: InkWell(
        onTap: () => onOpen(destination),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: maxHeight),
          child: ClipRRect(
            borderRadius: notePreviewRadius,
            child: NotePlayOverlay(
              visible: isVideoDestination(destination),
              child: Image(
                image: noteImage(ref.watch(polderApiProvider), targets, destination),
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, loadedSynchronously) => frame == null && !loadedSynchronously
                    ? Container(height: 160, width: 240, color: colors.surfaceContainerHighest)
                    : child,
                errorBuilder: (context, _, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(alt.isEmpty ? destination : alt, style: TextStyle(color: colors.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotePlayOverlay extends StatelessWidget {
  const NotePlayOverlay({required this.visible, required this.child, super.key});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
