import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/search.dart";
import "package:polder/providers/search/app_destinations_provider.dart";
import "package:polder/screens/browser/widgets/file_metadata_text.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/icon_badge.dart";

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
    return ListTile(
      selected: selected,
      selectedTileColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
      selectedColor: theme.colorScheme.onSurface,
      shape: const StadiumBorder(),
      leading: FileThumbnail(entry: entry, dimension: 40),
      title: HighlightedText(text: entry.name, ranges: hit.nameMatches),
      subtitle: Row(
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
  const HighlightedText({required this.text, required this.ranges, super.key});

  final String text;
  final List<TextRange> ranges;

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
    return Text.rich(TextSpan(children: spans), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
