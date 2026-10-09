import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:livemd_flutter/livemd_flutter.dart";

import "package:polder/services/notes/format_actions.dart";
import "package:polder/util/localization_helper.dart";

class NoteToolbar extends StatelessWidget implements PreferredSizeWidget {
  const NoteToolbar({
    required this.controller,
    required this.contentWidth,
    required this.onInsertLink,
    required this.onAttachFiles,
    super.key,
  });

  final LiveMarkdownController controller;
  final double contentWidth;

  @override
  Size get preferredSize => const Size.fromHeight(44);
  final VoidCallback onInsertLink;
  final VoidCallback onAttachFiles;

  void _apply(TextEditingValue Function(TextEditingValue value) change) =>
      controller.setValue(change(controller.value));

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) => IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: double.infinity,
        height: preferredSize.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ((constraints.maxWidth - contentWidth) / 2).clamp(8.0, double.infinity) - 8,
          ),
          child: Row(
            children: [
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Row(
                  children: [
                    button(IconsaxPlusLinear.undo, localized.noteUndo, controller.canUndo ? controller.undo : null),
                    button(IconsaxPlusLinear.redo, localized.noteRedo, controller.canRedo ? controller.redo : null),
                  ],
                ),
              ),
              const _Separator(),
              PopupMenuButton<int>(
                tooltip: localized.noteHeading,
                icon: const Icon(Icons.title, size: 20),
                onSelected: (level) =>
                    _apply((value) => FormatActions.linePrefix(value, level == 0 ? "" : "${"#" * level} ")),
                itemBuilder: (context) => [
                  for (final level in [1, 2, 3, 4])
                    PopupMenuItem(value: level, child: Text(localized.noteHeadingLevel(level))),
                  PopupMenuItem(value: 0, child: Text(localized.noteParagraph)),
                ],
              ),
              button(Icons.format_bold, localized.noteBold, () => _apply((value) => FormatActions.wrap(value, "**"))),
              button(
                Icons.format_italic,
                localized.noteItalic,
                () => _apply((value) => FormatActions.wrap(value, "*")),
              ),
              button(
                Icons.format_strikethrough,
                localized.noteStrikethrough,
                () => _apply((value) => FormatActions.wrap(value, "~~")),
              ),
              button(Icons.code, localized.noteInlineCode, () => _apply((value) => FormatActions.wrap(value, "`"))),
              const _Separator(),
              button(
                Icons.format_list_bulleted,
                localized.noteBulletList,
                () => _apply((value) => FormatActions.linePrefix(value, "- ")),
              ),
              button(
                Icons.format_list_numbered,
                localized.noteNumberedList,
                () => _apply((value) => FormatActions.linePrefix(value, "1. ")),
              ),
              button(
                Icons.checklist,
                localized.noteTaskList,
                () => _apply((value) => FormatActions.linePrefix(value, "- [ ] ")),
              ),
              button(
                Icons.format_quote,
                localized.noteQuote,
                () => _apply((value) => FormatActions.linePrefix(value, "> ")),
              ),
              button(
                Icons.info_outline,
                localized.noteCallout,
                () => _apply((value) => FormatActions.insertBlock(value, "> [!NOTE]\n> ", cursorAt: 12)),
              ),
              button(
                Icons.data_object,
                localized.noteCodeBlock,
                () => _apply((value) => FormatActions.insertBlock(value, "```\n\n```", cursorAt: 4)),
              ),
              button(
                Icons.table_chart_outlined,
                localized.noteTable,
                () => _apply((value) => FormatActions.insertBlock(value, "|  |  |\n|--|--|\n|  |  |", cursorAt: 2)),
              ),
              button(
                Icons.horizontal_rule,
                localized.noteDivider,
                () => _apply((value) => FormatActions.insertBlock(value, "---")),
              ),
              const _Separator(),
              button(IconsaxPlusLinear.link, localized.noteLinkFile, onInsertLink),
              button(IconsaxPlusLinear.paperclip_2, localized.noteAttachFiles, onAttachFiles),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 20,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    color: Theme.of(context).colorScheme.outlineVariant,
  );
}
