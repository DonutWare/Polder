import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/tag_filter.dart";
import "package:polder/widgets/tags/tag_chip.dart";

Future<void> showTagPicker(BuildContext context, List<FileEntry> entries) {
  if (AdaptiveLayout.isPhone(context)) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.6,
          child: TagPicker(entries: entries),
        ),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: 420, height: 480, child: TagPicker(entries: entries)),
    ),
  );
}

class TagPicker extends ConsumerStatefulWidget {
  const TagPicker({required this.entries, super.key});

  final List<FileEntry> entries;

  @override
  ConsumerState<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends ConsumerState<TagPicker> {
  final _query = TextEditingController();
  late final Map<int, Set<String>> _carriers = _initialCarriers();
  Color? _newColor;
  String? _failure;

  Map<int, Set<String>> _initialCarriers() {
    final carriers = <int, Set<String>>{};
    for (final entry in widget.entries) {
      for (final id in entry.tagIds) {
        carriers.putIfAbsent(id, () => {}).add(entry.path);
      }
    }
    return carriers;
  }

  List<String> get _paths => [for (final entry in widget.entries) entry.path];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool? _state(UserTag tag) => switch (_carriers[tag.id]?.length ?? 0) {
    0 => false,
    final count when count >= widget.entries.length => true,
    _ => null,
  };

  Future<void> _toggle(UserTag tag) => context.runWithFeedback(() async {
    final tags = ref.read(tagsProvider.notifier);
    final adding = _state(tag) != true;
    final results = adding ? await tags.assign(_paths, [tag.name]) : await tags.unassign(_paths, [tag.name]);
    _applyResults(tag.id, adding, results);
  }());

  Future<void> _create(String name, Color color) => context.runWithFeedback(() async {
    final tags = ref.read(tagsProvider.notifier);
    final created = await tags.create(name, color: color);
    final results = await tags.assign(_paths, [created.name]);
    _query.clear();
    _applyResults(created.id, true, results);
  }());

  void _applyResults(int tagId, bool added, List<TagAssignmentResult> results) {
    if (!mounted) return;
    final failed = results.where((result) => result.failed).toList();
    setState(() {
      final carriers = _carriers.putIfAbsent(tagId, () => {});
      for (final result in results.where((result) => !result.failed)) {
        added ? carriers.add(result.path) : carriers.remove(result.path);
      }
      _failure = failed.isEmpty ? null : failed.first.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    final theme = Theme.of(context);
    final tags = ref.watch(tagsProvider).value ?? const <UserTag>[];
    final query = _query.text.trim().replaceFirst("#", "");
    final shown = filterTags(tags, query);
    final creatable = offersNewTag(tags, query);
    final invalid = query.isNotEmpty && !isValidTagName(query);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _query,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(IconsaxPlusLinear.tag),
              hintText: l.tagPickerHint,
              errorText: invalid ? l.tagInvalidName : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (creatable) {
                _create(query, _newColor ?? nextTagColor(tags));
              } else if (shown.isNotEmpty) {
                _toggle(shown.first);
              }
            },
          ),
        ),
        if (_failure != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_failure!, style: TextStyle(color: theme.colorScheme.error)),
          ),
        Expanded(
          child: ListView(
            children: [
              if (creatable) _createTile(context, query, _newColor ?? nextTagColor(tags)),
              for (final tag in shown)
                CheckboxListTile(
                  tristate: true,
                  value: _state(tag),
                  onChanged: (_) => _toggle(tag),
                  secondary: TagDot(color: tag.color, size: 14),
                  title: Text("#${tag.name}"),
                  subtitle: Text(l.tagUsage(tag.count)),
                ),
              if (shown.isEmpty && !creatable)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.tagsEmpty, textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => Navigator.pop(context), child: Text(l.done)),
          ),
        ),
      ],
    );
  }

  Widget _createTile(BuildContext context, String name, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ListTile(
        leading: const Icon(IconsaxPlusLinear.add),
        title: Text(context.localized.tagCreate(name)),
        onTap: () => _create(name, color),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TagColorPicker(selected: color, onSelected: (picked) => setState(() => _newColor = picked)),
      ),
    ],
  );
}

class TagColorPicker extends StatelessWidget {
  const TagColorPicker({required this.selected, required this.onSelected, super.key});

  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final color in tagPalette)
        InkResponse(
          onTap: () => onSelected(color),
          radius: 18,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                width: 3,
                color: color.toARGB32() == selected.toARGB32()
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
              ),
            ),
          ),
        ),
    ],
  );
}
