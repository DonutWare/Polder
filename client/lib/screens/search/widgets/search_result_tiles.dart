import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/search.dart";
import "package:polder/providers/search/app_destinations_provider.dart";
import "package:polder/screens/browser/widgets/file_metadata_text.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/tags/tag_chip.dart";

class SearchHitTile extends StatelessWidget {
  const SearchHitTile({
    required this.hit,
    required this.selected,
    required this.onOpen,
    required this.onShowInFolder,
    super.key,
  });

  final SearchHit hit;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onShowInFolder;

  @override
  Widget build(BuildContext context) {
    final entry = hit.entry;
    final theme = Theme.of(context);
    final parent = RemotePath.parent(entry.path);
    final snippet = hit.snippet;
    final location = Row(
      children: [
        Flexible(
          child: Text(
            parent == RemotePath.root ? context.localized.navFiles : parent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!entry.isDir) ...[const Text(" · "), Flexible(child: FileMetadataText(entry: entry))],
      ],
    );
    return ListTile(
      selected: selected,
      selectedTileColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
      selectedColor: theme.colorScheme.onSurface,
      shape: snippet == null ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      leading: FileThumbnail(entry: entry, dimension: 40),
      title: Row(
        spacing: 8,
        children: [
          Flexible(
            child: HighlightedText(text: entry.name, ranges: hit.nameMatches),
          ),
          EntryTagChips(entry: entry),
        ],
      ),
      isThreeLine: snippet != null,
      subtitle: snippet == null
          ? location
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                location,
                HighlightedText(
                  text: snippet,
                  ranges: hit.snippetMatches,
                  maxLines: 2,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
      trailing: IconButton(
        tooltip: context.localized.searchShowInFolder,
        icon: const Icon(IconsaxPlusLinear.folder_open),
        onPressed: onShowInFolder,
      ),
      onTap: onOpen,
    );
  }
}

class DestinationTile extends StatelessWidget {
  const DestinationTile({required this.match, required this.selected, required this.onOpen, super.key});

  final DestinationMatch match;
  final bool selected;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      selected: selected,
      selectedTileColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
      selectedColor: theme.colorScheme.onSurface,
      shape: const StadiumBorder(),
      leading: IconBadge(icon: match.destination.icon),
      title: HighlightedText(text: match.label, ranges: match.match.ranges),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? IconsaxPlusLinear.arrow_left_2
            : IconsaxPlusLinear.arrow_right_3,
        size: 18,
      ),
      onTap: onOpen,
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({required this.text, required this.ranges, this.maxLines = 1, this.style, super.key});

  final String text;
  final List<TextRange> ranges;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final highlight = TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary);
    final spans = <TextSpan>[];
    var position = 0;
    for (final range in ranges) {
      if (range.start < position || range.end > text.length) continue;
      spans
        ..add(TextSpan(text: text.substring(position, range.start)))
        ..add(TextSpan(text: text.substring(range.start, range.end), style: highlight));
      position = range.end;
    }
    spans.add(TextSpan(text: text.substring(position)));
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
