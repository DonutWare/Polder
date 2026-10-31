import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:cross_file/cross_file.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor.dart";
import "package:polder/screens/notes/editor/markdown_editor/markdown_editor_style.dart";
import "package:polder/screens/notes/editor/markdown_view.dart";
import "package:polder/screens/notes/editor/note_embeds.dart";
import "package:polder/services/notes/note_markdown.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/tags/tag_chip.dart";

const noteFieldDecoration = InputDecoration(
  isCollapsed: true,
  filled: false,
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
);

class UndoNoteIntent extends Intent {
  const UndoNoteIntent();
}

class RedoNoteIntent extends Intent {
  const RedoNoteIntent();
}

const noteHistoryShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoNoteIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoNoteIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true): RedoNoteIntent(),
  SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): RedoNoteIntent(),
  SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoNoteIntent(),
};

class LiveNoteEditor extends ConsumerWidget {
  const LiveNoteEditor({
    required this.controller,
    required this.targets,
    required this.onLink,
    required this.imageFor,
    required this.onDropFiles,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final MarkdownEditingController controller;
  final NoteTargets targets;
  final void Function(String destination) onLink;
  final ImageProvider Function(String destination) imageFor;
  final void Function(List<XFile> files) onDropFiles;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final body = theme.textTheme.bodyLarge!.copyWith(color: colors.onSurface, height: 1.5);
    return MarkdownEditor(
      controller: controller,
      tags: ref.watch(tagsProvider).value ?? const [],
      newTagLabel: context.localized.tagSuggestionCreate,
      onTagTap: (name) => searchForTag(context, name),
      padding: padding,
      decoration: noteFieldDecoration,
      onLinkTap: onLink,
      onImageTap: onLink,
      onDropFiles: onDropFiles,
      imageFor: imageFor,
      blockBuilder: (context, block, source) {
        final markdown = NoteMarkdownContext.of(source);
        return MarkdownView(nodes: markdown.parse(source), context: markdown, targets: targets, onLink: onLink);
      },
      style: MarkdownEditorStyle(
        body: body,
        code: monospaced(TextStyle(color: colors.onSurface, fontSize: body.fontSize! * 0.92)),
        link: TextStyle(color: colors.primary, decoration: TextDecoration.none),
        syntaxColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
        accentColor: colors.primary,
        quoteColor: colors.outline,
        highlightColor: colors.tertiaryContainer,
        codeBackground: colors.surfaceContainerHighest,
      ),
    );
  }
}
