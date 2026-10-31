import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/item_selection.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";

final browserSelectionProvider = NotifierProvider.autoDispose.family<BrowserSelectionNotifier, ItemSelection, String>(
  BrowserSelectionNotifier.new,
);

class BrowserSelectionNotifier extends Notifier<ItemSelection> {
  BrowserSelectionNotifier(this.path);

  final String path;

  @override
  ItemSelection build() {
    ref.listen(directoryProvider(path), (_, next) {
      if (next.value case final listing?) state = state.retaining({for (final entry in listing.entries) entry.name});
    });
    return const ItemSelection();
  }

  /// The selectable entries in the order they are shown.
  List<FileEntry> get entries =>
      ref.read(browserSortProvider).apply(ref.read(directoryProvider(path)).value?.entries ?? const []);

  List<FileEntry> get selectedEntries => [
    for (final entry in entries)
      if (state.contains(entry.name)) entry,
  ];

  List<String> get _order => [for (final entry in entries) entry.name];

  void only(String name) => state = ItemSelection.only(name);

  void toggle(String name) => state = state.toggled(name);

  void extendTo(String name) => state = state.extendedTo(name, _order);

  void selectAll() => state = state.withAll(_order);

  void clear() => state = const ItemSelection();
}
