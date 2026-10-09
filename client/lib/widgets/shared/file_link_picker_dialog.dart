import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/directory_listing.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/folder_picker_provider.dart";
import "package:polder/screens/browser/widgets/file_thumbnail.dart";
import "package:polder/screens/search/search_view.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/async_value_view.dart";

Future<FileEntry?> showFileLinkPicker(BuildContext context, {required String startFolder}) => showDialog<FileEntry>(
  context: context,
  builder: (_) => FileLinkPickerDialog(startFolder: startFolder),
);

class FileLinkPickerDialog extends StatelessWidget {
  const FileLinkPickerDialog({required this.startFolder, super.key});

  final String startFolder;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 640,
        height: size.height * 0.75,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: localized.noteLinkSearch),
                  Tab(text: localized.noteLinkBrowse),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SearchView(
                      onOpenEntry: (entry) => Navigator.pop(context, entry),
                      onShowInFolder: (entry) => Navigator.pop(context, entry),
                      onGo: (_) {},
                      onClose: () => Navigator.pop(context),
                    ),
                    _FolderBrowser(startFolder: startFolder),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderBrowser extends ConsumerWidget {
  const _FolderBrowser({required this.startFolder});

  final String startFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = folderPickerProvider(startFolder);
    final path = ref.watch(picker);
    return Column(
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
                for (final entry in listing.sortedEntries)
                  ListTile(
                    leading: FileThumbnail(entry: entry, dimension: 36),
                    title: Text(entry.name),
                    trailing: entry.isDir
                        ? IconButton(
                            icon: const Icon(IconsaxPlusLinear.link),
                            tooltip: context.localized.noteLinkThisFolder,
                            onPressed: () => Navigator.pop(context, entry),
                          )
                        : null,
                    onTap: () =>
                        entry.isDir ? ref.read(picker.notifier).open(entry.path) : Navigator.pop(context, entry),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
