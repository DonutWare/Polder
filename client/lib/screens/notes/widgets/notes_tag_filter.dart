import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/notes/notes_tag_filter_provider.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/tags/tag_chip.dart";

class NotesViewPicker extends ConsumerStatefulWidget {
  const NotesViewPicker({required this.density, super.key});

  final VisualDensity density;

  @override
  ConsumerState<NotesViewPicker> createState() => _NotesViewPickerState();
}

class _NotesViewPickerState extends ConsumerState<NotesViewPicker> {
  final _menu = MenuController();

  static bool get _combining => HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;

  void _pick(VoidCallback choose) {
    choose();
    _menu.close();
  }

  void _pickTag(int tagId) {
    final filter = ref.read(notesTagFilterProvider.notifier);
    if (_combining) return filter.toggle(tagId);
    _pick(() => filter.only(tagId));
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final view = ref.watch(notesTagFilterProvider);
    final filtering = view is! AllNotes;
    return MenuAnchor(
      controller: _menu,
      menuChildren: [_menuContents(context, view)],
      builder: (context, controller, _) => IconButton(
        tooltip: localized.notesFilterByTag,
        visualDensity: widget.density,
        isSelected: filtering,
        icon: const Icon(IconsaxPlusLinear.filter),
        selectedIcon: Icon(IconsaxPlusBold.filter, color: Theme.of(context).colorScheme.primary),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _menuContents(BuildContext context, NotesView view) {
    final localized = context.localized;
    final filter = ref.read(notesTagFilterProvider.notifier);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final counts = ref.watch(notesTagCountsProvider).value;
    final selectedTags = view is TaggedNotes ? view.tagIds : const <int>{};
    final hintStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ViewItem(
            leading: const Icon(IconsaxPlusLinear.note_2, size: _ViewItem.iconSize),
            label: localized.notesViewAll,
            count: counts?.total,
            selected: view is AllNotes,
            onTap: () => _pick(filter.showAll),
            onCheck: () => _pick(filter.showAll),
          ),
          _ViewItem(
            leading: const Icon(IconsaxPlusLinear.tag_cross, size: _ViewItem.iconSize),
            label: localized.notesViewUntagged,
            count: counts?.untagged,
            selected: view is UntaggedNotes,
            onTap: () => _pick(filter.showUntagged),
            onCheck: () => _pick(filter.showUntagged),
          ),
          const Divider(height: 8),
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _ViewItem.horizontalPadding, vertical: 8),
              child: Text(localized.notesFilterNoTags, style: hintStyle),
            )
          else ...[
            for (final tag in tags)
              _ViewItem(
                leading: TagDot(color: tag.color, size: 12),
                label: "#${tag.name}",
                count: counts?.byTag[tag.id] ?? (counts == null ? null : 0),
                selected: selectedTags.contains(tag.id),
                onTap: () => _pickTag(tag.id),
                onCheck: () => filter.toggle(tag.id),
              ),
          ],
        ],
      ),
    );
  }
}

class _ViewItem extends StatelessWidget {
  const _ViewItem({
    required this.leading,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onCheck,
    this.count,
  });

  static const iconSize = 18.0;
  static const horizontalPadding = 12.0;
  static const _height = 40.0;
  static const _leadingWidth = 24.0;
  static const _countWidth = 36.0;
  static const _checkWidth = 32.0;

  final Widget leading;
  final String label;
  final bool selected;
  final int? count;
  final VoidCallback onTap;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: _height,
        color: selected ? colors.secondaryContainer : null,
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            SizedBox(
              width: _leadingWidth,
              child: Center(child: leading),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? colors.onSecondaryContainer : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
            SizedBox(
              width: _countWidth,
              child: Text(
                count == null ? "" : "$count",
                textAlign: TextAlign.end,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: _checkWidth,
              child: Checkbox(
                value: selected,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) => onCheck(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesViewChips extends ConsumerWidget {
  const NotesViewChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(notesTagFilterProvider);
    final filter = ref.read(notesTagFilterProvider.notifier);
    final tags = ref.watch(tagsByIdProvider);
    final chips = switch (view) {
      AllNotes() => const <Widget>[],
      UntaggedNotes() => [
        _ViewChip(
          label: context.localized.notesViewUntagged,
          avatar: const Icon(IconsaxPlusLinear.tag_cross, size: 16),
          onRemove: filter.showAll,
        ),
      ],
      TaggedNotes(:final tagIds) => [
        for (final id in tagIds)
          if (tags[id] case final tag?)
            _ViewChip(label: "#${tag.name}", color: tag.color, onRemove: () => filter.toggle(id)),
      ],
    };
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({required this.label, required this.onRemove, this.color, this.avatar});

  final String label;
  final Color? color;
  final Widget? avatar;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return InputChip(
      avatar: avatar,
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      labelStyle: color == null ? null : TextStyle(color: color, fontWeight: FontWeight.w600),
      backgroundColor: color?.withValues(alpha: 0.14),
      side: color == null ? null : BorderSide(color: color.withValues(alpha: 0.4)),
      deleteIconColor: color,
      deleteButtonTooltipMessage: context.localized.notesFilterClear,
      onDeleted: onRemove,
    );
  }
}

class TaggedNotesList extends ConsumerWidget {
  const TaggedNotesList({
    required this.root,
    required this.notes,
    required this.selectedPath,
    required this.onOpen,
    super.key,
  });

  final String root;
  final List<FileEntry> notes;
  final String? selectedPath;
  final ValueChanged<FileEntry> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) return const TaggedNotesEmpty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
      itemCount: notes.length,
      itemBuilder: (context, index) => _TaggedNoteTile(
        key: ValueKey(notes[index].path),
        root: root,
        entry: notes[index],
        selected: notes[index].path == selectedPath,
        onOpen: onOpen,
      ),
    );
  }
}

class TaggedNotesEmpty extends ConsumerWidget {
  const TaggedNotesEmpty({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      ref.watch(notesTagFilterProvider) is UntaggedNotes
          ? context.localized.notesViewUntaggedEmpty
          : context.localized.notesFilterNoMatches,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _TaggedNoteTile extends ConsumerWidget {
  const _TaggedNoteTile({
    required this.root,
    required this.entry,
    required this.selected,
    required this.onOpen,
    super.key,
  });

  final String root;
  final FileEntry entry;
  final bool selected;
  final ValueChanged<FileEntry> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pointer = AdaptiveLayout.usesPointer(context);
    final tint = noteTintOf(ref.watch(tagsByIdProvider), entry);
    final radius = BorderRadius.circular(pointer ? 8 : 12);
    final folder = RemotePath.relativeTo(RemotePath.parent(entry.path), root) ?? "";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? colors.secondaryContainer : tint?.withValues(alpha: 0.14) ?? Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onOpen(entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noteTitleOf(entry),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (pointer ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                          color: selected ? colors.onSecondaryContainer : null,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      ),
                      if (folder.isNotEmpty)
                        Text(
                          folder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                EntryTagDots(entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
