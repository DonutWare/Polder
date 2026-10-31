import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/user_tag.dart";
import "package:polder/providers/tags/tags_provider.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:polder/widgets/shared/message_view.dart";
import "package:polder/widgets/shared/nav_group.dart";
import "package:polder/widgets/tags/tag_chip.dart";
import "package:polder/widgets/tags/tag_picker.dart";

enum _TagAction { edit, delete }

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    final notifier = ref.read(tagsProvider.notifier);
    final unused = tags.value?.where((tag) => tag.count == 0).length ?? 0;
    return AppPage(
      title: Text(context.localized.tagsTitle),
      actions: [
        if (unused > 0)
          IconButton(
            tooltip: context.localized.tagsDeleteUnused,
            icon: const Icon(IconsaxPlusLinear.broom),
            onPressed: () => _deleteUnused(context, ref, unused),
          ),
      ],
      body: AsyncValueView<List<UserTag>>(
        value: tags,
        onRetry: notifier.refresh,
        data: (list) => ReadableWidth(
          maxWidth: 900,
          builder: (context, inset) => RefreshIndicator(
            edgeOffset: inset.top,
            onRefresh: notifier.refresh,
            child: list.isEmpty
                ? ListView(
                    children: [MessageView(icon: IconsaxPlusLinear.tag, message: context.localized.tagsEmpty)],
                  )
                : ListView.builder(
                    padding: inset + const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: list.length,
                    itemBuilder: (context, index) => GroupedTile(
                      index: index,
                      count: list.length,
                      child: _TagTile(tag: list[index]),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> _deleteUnused(BuildContext context, WidgetRef ref, int unused) async {
  final l = context.localized;
  final notifier = ref.read(tagsProvider.notifier);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l.tagsDeleteUnusedTitle,
    message: l.tagsDeleteUnusedMessage(unused),
    confirmLabel: l.delete,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  var removed = 0;
  final succeeded = await context.runWithFeedback(() async {
    removed = await notifier.deleteUnused();
  }());
  if (succeeded) messenger?.showSnackBar(SnackBar(content: Text(l.tagsUnusedDeleted(removed))));
}

class _TagTile extends ConsumerWidget {
  const _TagTile({required this.tag});

  final UserTag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.localized;
    return ListTile(
      leading: TagDot(color: tag.color, size: 16),
      title: Text("#${tag.name}"),
      subtitle: Text(l.tagUsage(tag.count)),
      onTap: () => searchForTag(context, tag.name),
      trailing: PopupMenuButton<_TagAction>(
        icon: const Icon(IconsaxPlusLinear.more),
        onSelected: (action) => switch (action) {
          _TagAction.edit => _edit(context, ref),
          _TagAction.delete => _delete(context, ref),
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: _TagAction.edit, child: Text(l.edit)),
          PopupMenuItem(value: _TagAction.delete, child: Text(l.delete)),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(tagsProvider.notifier);
    final edited = await showDialog<(String, Color)>(
      context: context,
      builder: (_) => _EditTagDialog(tag: tag),
    );
    if (edited == null || !context.mounted) return;
    final (name, color) = edited;
    await context.runWithFeedback(
      notifier.edit(tag, name: name == tag.name ? null : name, color: color == tag.color ? null : color),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(tagsProvider.notifier);
    final confirmed = await showConfirmDialog(
      context,
      title: context.localized.tagDeleteTitle(tag.name),
      message: context.localized.tagDeleteMessage(tag.count),
      confirmLabel: context.localized.delete,
      destructive: true,
    );
    if (confirmed && context.mounted) await context.runWithFeedback(notifier.delete(tag));
  }
}

class _EditTagDialog extends StatefulWidget {
  const _EditTagDialog({required this.tag});

  final UserTag tag;

  @override
  State<_EditTagDialog> createState() => _EditTagDialogState();
}

class _EditTagDialogState extends State<_EditTagDialog> {
  late final _name = TextEditingController(text: widget.tag.name);
  late Color _color = widget.tag.color;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => isValidTagName(_name.text.trim());

  void _save() {
    if (_valid) Navigator.pop(context, (_name.text.trim(), _color));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    return AlertDialog(
      title: Text(l.tagEditTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.tagName,
                prefixText: "#",
                errorText: _valid ? null : l.tagInvalidName,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
            Text(l.tagColor, style: Theme.of(context).textTheme.labelLarge),
            TagColorPicker(selected: _color, onSelected: (color) => setState(() => _color = color)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: _valid ? _save : null, child: Text(l.save)),
      ],
    );
  }
}
