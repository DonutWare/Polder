import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/theme/app_theme.dart";

class TagDot extends StatelessWidget {
  const TagDot({required this.color, this.size = 10, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class TagChip extends StatelessWidget {
  const TagChip({required this.name, required this.color, this.onTap, super.key});

  final String name;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.14),
    shape: squircle(AppRadius.tag),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          "#$name",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    ),
  );
}

void searchForTag(BuildContext context, String name) => openSearch(context, initialQuery: "#$name ");

class EntryTagChips extends ConsumerWidget {
  const EntryTagChips({required this.entry, this.maxVisible = 2, super.key});

  static const maxChipWidth = 120.0;

  final FileEntry entry;
  final int maxVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = entryTags(ref.watch(tagsByIdProvider), entry);
    if (tags.isEmpty && entry.otherTags.isEmpty) return const SizedBox.shrink();
    final neutral = Theme.of(context).colorScheme.outline;
    final chips = [
      for (final tag in tags) TagChip(name: tag.name, color: tag.color, onTap: () => searchForTag(context, tag.name)),
      for (final name in entry.otherTags)
        TagChip(name: name, color: neutral, onTap: () => ref.read(tagsProvider.notifier).create(name)),
    ];
    final hidden = chips.length - maxVisible;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (final chip in chips.take(maxVisible))
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxChipWidth),
            child: chip,
          ),
        if (hidden > 0) Text("+$hidden", style: TextStyle(fontSize: 12, color: neutral)),
      ],
    );
  }
}

List<UserTag> entryTags(Map<int, UserTag> byId, FileEntry entry) => [for (final id in entry.tagIds) ?byId[id]];

class EntryTagDots extends ConsumerWidget {
  const EntryTagDots({required this.entry, this.maxVisible = 4, super.key});

  final FileEntry entry;
  final int maxVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = entryTags(ref.watch(tagsByIdProvider), entry);
    if (tags.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: tags.map((tag) => "#${tag.name}").join(" "),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [for (final tag in tags.take(maxVisible)) TagDot(color: tag.color, size: 8)],
      ),
    );
  }
}
