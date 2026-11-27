import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/models/directory_listing.dart";
import "package:polder_core/models/file_entry.dart";
import "package:polder_core/providers/browser/directory_provider.dart";
import "package:polder_core/providers/browser/folder_picker_provider.dart";
import "package:polder_notes/notes_host.dart";
import "package:polder_ui/widgets/files/file_type_icon.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/widgets/shared/async_value_view.dart";

Future<FileEntry?> showFileLinkPicker(BuildContext context, {required String startFolder}) => showDialog<FileEntry>(
  context: context,
  builder: (_) => FileLinkPickerDialog(startFolder: startFolder),
);

class FileLinkPickerDialog extends ConsumerWidget {
  const FileLinkPickerDialog({required this.startFolder, super.key});

  final String startFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final host = ref.watch(notesHostProvider);
    final browser = _FolderBrowser(startFolder: startFolder, thumbnail: host.fileThumbnail ?? _typeIcon);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 640,
        height: size.height * 0.75,
        child: switch (host.fileSearch) {
          null => browser,
          final search => _SearchOrBrowse(
            search: search(context, (entry) => Navigator.pop(context, entry)),
            browser: browser,
          ),
        },
      ),
    );
  }

  static Widget _typeIcon(FileEntry entry, double dimension) => FileTypeIcon(entry: entry, size: dimension);
}

class _SearchOrBrowse extends StatelessWidget {
  const _SearchOrBrowse({required this.search, required this.browser});

  final Widget search;
  final Widget browser;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: localized.noteLinkSearch),
              Tab(text: localized.noteLinkBrowse),
            ],
          ),
          Expanded(child: TabBarView(children: [search, browser])),
        ],
      ),
    );
  }
}

class _FolderBrowser extends ConsumerWidget {
  const _FolderBrowser({required this.startFolder, required this.thumbnail});

  final String startFolder;
  final FileThumbnailBuilder thumbnail;

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
                    leading: thumbnail(entry, 36),
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
