import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/providers/browser/transfers_provider.dart";
import "package:nomad/util/action_feedback.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/util/remote_path.dart";
import "package:nomad/widgets/shared/text_input_dialog.dart";

enum _AddAction { upload, folder }

class BrowserAddButton extends ConsumerWidget {
  const BrowserAddButton({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<_AddAction>(
    tooltip: context.localized.add,
    onSelected: (action) => _handle(context, ref, action),
    itemBuilder: (context) => [
      PopupMenuItem(
        value: _AddAction.upload,
        child: ListTile(
          leading: const Icon(IconsaxPlusLinear.document_upload),
          title: Text(context.localized.uploadFiles),
        ),
      ),
      PopupMenuItem(
        value: _AddAction.folder,
        child: ListTile(leading: const Icon(IconsaxPlusLinear.folder_add), title: Text(context.localized.newFolder)),
      ),
    ],
    child: const IgnorePointer(child: FloatingActionButton(onPressed: null, child: Icon(IconsaxPlusLinear.add))),
  );

  Future<void> _handle(BuildContext context, WidgetRef ref, _AddAction action) async {
    switch (action) {
      case _AddAction.upload:
        await ref.read(transfersProvider.notifier).pickAndUpload(path);
      case _AddAction.folder:
        final name = await showTextInputDialog(
          context,
          title: context.localized.newFolder,
          label: context.localized.name,
          confirmLabel: context.localized.create,
          isValid: (value) => RemotePath.isValidName(value.trim()),
        );
        if (name != null && context.mounted) {
          await context.runWithFeedback(ref.read(directoryProvider(path).notifier).createFolder(name));
        }
    }
  }
}
