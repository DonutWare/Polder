import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_sort.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/util/localization_helper.dart";

const _foldersFirst = #foldersFirst;

class SortButton extends ConsumerWidget {
  const SortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(browserSortProvider);
    final localized = context.localized;
    return PopupMenuButton<Object>(
      tooltip: localized.sortBy,
      icon: const Icon(IconsaxPlusLinear.sort),
      onSelected: (choice) {
        final notifier = ref.read(browserSortProvider.notifier);
        switch (choice) {
          case final FileSortField field:
            notifier.select(field);
          case final bool ascending:
            notifier.setAscending(ascending);
          case _foldersFirst:
            notifier.toggleFoldersFirst();
        }
      },
      itemBuilder: (_) => [
        for (final field in FileSortField.values)
          CheckedPopupMenuItem(
            value: field,
            checked: sort.field == field,
            child: Text(switch (field) {
              FileSortField.name => localized.name,
              FileSortField.modified => localized.modified,
              FileSortField.size => localized.size,
              FileSortField.type => localized.type,
            }),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(value: true, checked: sort.ascending, child: Text(localized.sortAscending)),
        CheckedPopupMenuItem(value: false, checked: !sort.ascending, child: Text(localized.sortDescending)),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(value: _foldersFirst, checked: sort.foldersFirst, child: Text(localized.sortFoldersFirst)),
      ],
    );
  }
}
