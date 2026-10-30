import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/item_selection.dart";

final noteSelectionProvider = NotifierProvider<NoteSelectionNotifier, ItemSelection>(NoteSelectionNotifier.new);

class NoteSelectionNotifier extends Notifier<ItemSelection> {
  @override
  ItemSelection build() => const ItemSelection();

  void only(String path) => state = ItemSelection.only(path);

  void toggle(String path) => state = state.toggled(path);

  void extendTo(String path, List<String> order) => state = state.extendedTo(path, order);

  void clear() {
    if (state.isNotEmpty) state = const ItemSelection();
  }
}
