import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_sort.dart";

enum BrowserViewMode { list, grid }

final browserViewModeProvider = NotifierProvider<BrowserViewModeNotifier, BrowserViewMode>(BrowserViewModeNotifier.new);

class BrowserViewModeNotifier extends Notifier<BrowserViewMode> {
  @override
  BrowserViewMode build() => BrowserViewMode.list;

  void toggle() => state = state == BrowserViewMode.list ? BrowserViewMode.grid : BrowserViewMode.list;
}

final browserSortProvider = NotifierProvider<BrowserSortNotifier, FileSort>(BrowserSortNotifier.new);

class BrowserSortNotifier extends Notifier<FileSort> {
  @override
  FileSort build() => const FileSort();

  void select(FileSortField field) => state = state.copyWith(field: field);

  void setAscending(bool ascending) => state = state.copyWith(ascending: ascending);

  void toggleFoldersFirst() => state = state.copyWith(foldersFirst: !state.foldersFirst);
}
