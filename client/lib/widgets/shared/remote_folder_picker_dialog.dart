import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/directory_listing.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/folder_picker_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/icon_badge.dart";

Future<String?> showRemoteFolderPicker(
  BuildContext context, {
  String initialPath = RemotePath.root,
  String? title,
  String? confirmLabel,
  Set<String> excluded = const {},
  bool Function(String path)? canChoose,
}) => showDialog<String>(
  context: context,
  builder: (_) => RemoteFolderPickerDialog(
    initialPath: initialPath,
    title: title,
    confirmLabel: confirmLabel,
    excluded: excluded,
    canChoose: canChoose,
  ),
);

class RemoteFolderPickerDialog extends ConsumerWidget {
  const RemoteFolderPickerDialog({
    required this.initialPath,
    this.title,
    this.confirmLabel,
    this.excluded = const {},
    this.canChoose,
    super.key,
  });

  final String initialPath;
  final String? title;
  final String? confirmLabel;
  final Set<String> excluded;
  final bool Function(String path)? canChoose;

  bool _isExcluded(String path) => excluded.any((folder) => path == folder || RemotePath.isWithin(path, folder));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = folderPickerProvider(initialPath);
    final path = ref.watch(picker);
    final listing = ref.watch(directoryProvider(path));
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.folder_open),
      title: Text(title ?? context.localized.chooseServerFolder),
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
              child: switch (listing) {
                AsyncError(error: NotFoundException()) => Center(
                  child: Text(context.localized.folderWillBeCreated, textAlign: TextAlign.center),
                ),
                _ => AsyncValueView<DirectoryListing>(
                  value: listing,
                  data: (listing) => ListView(
                    children: [
                      for (final directory in listing.directories)
                        ListTile(
                          enabled: !_isExcluded(directory.path),
                          leading: Opacity(
                            opacity: _isExcluded(directory.path) ? 0.38 : 1,
                            child: const IconBadge(icon: IconsaxPlusBold.folder_2, size: 32),
                          ),
                          title: Text(directory.name),
                          onTap: () => ref.read(picker.notifier).open(directory.path),
                        ),
                    ],
                  ),
                ),
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.localized.cancel)),
        FilledButton(
          onPressed: _isExcluded(path) || !(canChoose?.call(path) ?? true) ? null : () => Navigator.pop(context, path),
          child: Text(confirmLabel ?? context.localized.chooseThisFolder),
        ),
      ],
    );
  }
}
