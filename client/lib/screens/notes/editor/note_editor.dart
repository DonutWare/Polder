import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:livemd_flutter/livemd_flutter.dart";

import "package:polder/services/notes/note_markdown.dart";

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

class LiveNoteEditor extends StatelessWidget {
  const LiveNoteEditor({
    required this.controller,
    required this.onLink,
    required this.imageFor,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final LiveMarkdownController controller;
  final void Function(String destination) onLink;
  final ImageProvider Function(String destination) imageFor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final body = theme.textTheme.bodyLarge!.copyWith(color: colors.onSurface, height: 1.5);
    return LiveMarkdownEditor(
      controller: controller,
      padding: padding,
      editorDecoration: noteFieldDecoration,
      onLinkTap: (destination, _) => onLink(destination),
      onImageTap: (destination, _) => onLink(destination),
      imageResolver: imageFor,
      theme: LiveMarkdownThemeData(
        bodyStyle: body,
        linkStyle: TextStyle(color: colors.primary, decoration: TextDecoration.none),
        codeStyle: monospaced(TextStyle(color: colors.onSurface, fontSize: body.fontSize! * 0.92)),
        codeBlockDecoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        appearance: LiveMarkdownAppearance(
          syntaxColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
          quoteColor: colors.outline,
          taskColor: colors.primary,
          highlightColor: colors.tertiaryContainer,
          calloutAccentColor: colors.primary,
          calloutBackgroundColor: colors.primaryContainer.withValues(alpha: 0.35),
          tableActiveCellColor: colors.secondaryContainer,
        ),
      ),
    );
  }
}
