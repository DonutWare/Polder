import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/directory_listing.dart";
import "package:nomad/providers/browser/directory_provider.dart";
import "package:nomad/providers/browser/folder_picker_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/util/remote_path.dart";
import "package:nomad/widgets/shared/async_value_view.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

Future<String?> showRemoteFolderPicker(BuildContext context, {String initialPath = RemotePath.root}) =>
    showDialog<String>(
      context: context,
      builder: (_) => RemoteFolderPickerDialog(initialPath: initialPath),
    );

class RemoteFolderPickerDialog extends ConsumerWidget {
  const RemoteFolderPickerDialog({required this.initialPath, super.key});

  final String initialPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = folderPickerProvider(initialPath);
    final path = ref.watch(picker);
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.folder_open),
      title: Text(context.localized.chooseServerFolder),
      content: SizedBox(
        width: 400,
        height: 360,
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(IconsaxPlusLinear.arrow_up_3),
                onPressed: path == RemotePath.root ? null : ref.read(picker.notifier).up,
              ),
              title: Text(path),
            ),
            const Divider(height: 1),
            Expanded(
              child: AsyncValueView<DirectoryListing>(
                value: ref.watch(directoryProvider(path)),
                data: (listing) => ListView(
                  children: [
                    for (final directory in listing.directories)
                      ListTile(
                        leading: const IconBadge(icon: IconsaxPlusBold.folder_2, size: 32),
                        title: Text(directory.name),
                        onTap: () => ref.read(picker.notifier).open(directory.path),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.localized.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, path), child: Text(context.localized.chooseThisFolder)),
      ],
    );
  }
}
