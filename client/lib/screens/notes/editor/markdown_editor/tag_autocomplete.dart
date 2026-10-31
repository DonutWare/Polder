import "package:flutter/material.dart";

import "package:polder/models/user_tag.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_source.dart";
import "package:polder/util/tag_filter.dart";

final _partialTag = RegExp(r"[\p{L}\p{N}_\-/]*$", unicode: true);
final _tagCharacter = RegExp(r"[\p{L}\p{N}_\-/]", unicode: true);

@immutable
class TagQuery {
  const TagQuery({required this.start, required this.end, required this.partial});

  final int start;
  final int end;
  final String partial;
}

@immutable
class TagOption {
  const TagOption({required this.name, this.color, this.isNew = false});

  final String name;
  final Color? color;
  final bool isNew;
}

TagQuery? tagQueryAt(MarkdownSource source, TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isValid || !selection.isCollapsed) return null;
  if (value.composing.isValid && !value.composing.isCollapsed) return null;
  final caret = selection.baseOffset;
  final text = value.text;
  final line = source.lineAt(caret.clamp(0, text.length));
  if (line.block != null || caret <= line.contentStart) return null;
  final before = text.substring(line.contentStart, caret);
  final partial = _partialTag.firstMatch(before)!.group(0)!;
  final hash = caret - partial.length - 1;
  if (hash < line.contentStart || text[hash] != "#") return null;
  if (!startsTag(text, hash, line.contentStart)) return null;
  if (source.inlineAt(hash, (node) => node.kind == MarkdownInlineKind.code) != null) return null;
  var end = caret;
  while (end < text.length && _tagCharacter.hasMatch(text[end])) {
    end++;
  }
  return TagQuery(start: hash, end: end, partial: partial);
}

List<TagOption> tagOptions(List<UserTag> tags, String partial) => [
  for (final tag in partial.isEmpty ? _alphabetical(tags) : filterTags(tags, partial))
    TagOption(name: tag.name, color: tag.color),
  if (offersNewTag(tags, partial)) TagOption(name: partial, isNew: true),
];

List<UserTag> _alphabetical(List<UserTag> tags) => [...tags]..sort((a, b) => a.key.compareTo(b.key));

TextEditingValue acceptTag(TextEditingValue value, TagQuery query, String name) {
  final text = value.text;
  final spaced = query.end < text.length && text[query.end] == " ";
  final insert = spaced ? "#$name" : "#$name ";
  final caret = query.start + insert.length + (spaced ? 1 : 0);
  return TextEditingValue(
    text: text.replaceRange(query.start, query.end, insert),
    selection: TextSelection.collapsed(offset: caret),
  );
}

class TagSuggestions extends StatefulWidget {
  const TagSuggestions({
    required this.options,
    required this.highlighted,
    required this.onSelect,
    required this.newTagLabel,
    super.key,
  });

  static const width = 240.0;
  static const maxHeight = 280.0;

  final List<TagOption> options;
  final int highlighted;
  final ValueChanged<TagOption> onSelect;
  final String newTagLabel;

  @override
  State<TagSuggestions> createState() => _TagSuggestionsState();
}

class _TagSuggestionsState extends State<TagSuggestions> {
  final _highlightedKey = GlobalKey();

  @override
  void didUpdateWidget(TagSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlighted == widget.highlighted) return;
    final policy = widget.highlighted > oldWidget.highlighted
        ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
        : ScrollPositionAlignmentPolicy.keepVisibleAtStart;
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealHighlighted(policy));
  }

  void _revealHighlighted(ScrollPositionAlignmentPolicy policy) {
    final highlighted = _highlightedKey.currentContext;
    if (highlighted != null) Scrollable.ensureVisible(highlighted, alignmentPolicy: policy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFieldTapRegion(
      child: Material(
        elevation: 6,
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: TagSuggestions.width)
              .copyWith(maxHeight: TagSuggestions.maxHeight),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: [
              for (final (index, option) in widget.options.indexed)
                ListTile(
                  key: index == widget.highlighted ? _highlightedKey : null,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  selected: index == widget.highlighted,
                  selectedTileColor: theme.colorScheme.secondaryContainer,
                  leading: Icon(
                    option.isNew ? Icons.add : Icons.circle,
                    size: option.isNew ? 18 : 12,
                    color: option.color ?? theme.colorScheme.primary,
                  ),
                  title: Text("#${option.name}", maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: option.isNew ? Text(widget.newTagLabel) : null,
                  onTap: () => widget.onSelect(option),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
