import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/app_checkbox.dart";
import "package:polder/widgets/shared/async_value_view.dart";

Future<List<FileEntry>?> showRemoteImagePicker(BuildContext context, {bool multiple = false}) =>
    showDialog<List<FileEntry>>(
      context: context,
      builder: (_) => RemoteImagePickerDialog(multiple: multiple),
    );

class RemoteImagePickerDialog extends ConsumerStatefulWidget {
  const RemoteImagePickerDialog({this.multiple = false, super.key});

  final bool multiple;

  @override
  ConsumerState<RemoteImagePickerDialog> createState() => _RemoteImagePickerDialogState();
}

class _RemoteImagePickerDialogState extends ConsumerState<RemoteImagePickerDialog> {
  String _path = RemotePath.root;
  final _selected = <String, FileEntry>{};

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return AlertDialog(
      icon: const Icon(IconsaxPlusLinear.gallery),
      title: Text(widget.multiple ? localized.chooseImages : localized.chooseImage),
      content: SizedBox(
        width: 440,
        height: 400,
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(IconsaxPlusLinear.arrow_up_3),
                onPressed: _path == RemotePath.root ? null : () => setState(() => _path = RemotePath.parent(_path)),
              ),
              title: Text(_path),
            ),
            const Divider(height: 1),
            Expanded(
              child: AsyncValueView<DirectoryListing>(
                value: ref.watch(directoryProvider(_path)),
                data: (listing) {
                  final entries = [
                    for (final entry in listing.sortedEntries)
                      if (entry.isDir || entry.isImage) entry,
                  ];
                  if (entries.isEmpty) return Center(child: Text(localized.noImagesInFolder));
                  return ListView(children: [for (final entry in entries) _tile(entry)]);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(localized.cancel)),
        if (widget.multiple)
          FilledButton(
            onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.values.toList()),
            child: Text(localized.addSelected(_selected.length)),
          ),
      ],
    );
  }

  Widget _tile(FileEntry entry) {
    final selected = _selected.containsKey(entry.path);
    return ListTile(
      leading: FileThumbnail(entry: entry, dimension: 40),
      title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: selected,
      trailing: widget.multiple && !entry.isDir ? AppCheckbox(value: selected, onChanged: (_) => _toggle(entry)) : null,
      onTap: () {
        if (entry.isDir) {
          setState(() => _path = entry.path);
        } else if (widget.multiple) {
          _toggle(entry);
        } else {
          Navigator.pop(context, [entry]);
        }
      },
    );
  }

  void _toggle(FileEntry entry) => setState(() {
    if (_selected.remove(entry.path) == null) _selected[entry.path] = entry;
  });
}
