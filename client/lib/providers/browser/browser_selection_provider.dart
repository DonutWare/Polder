import "package:flutter/foundation.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";

@immutable
class BrowserSelection {
  const BrowserSelection({this.names = const {}, this.anchor, this.lead});

  final Set<String> names;

  /// Where a shift-click range starts.
  final String? anchor;

  /// The item last clicked or reached with the arrow keys.
  final String? lead;

  bool get isEmpty => names.isEmpty;
  bool get isNotEmpty => names.isNotEmpty;
  int get length => names.length;
  bool contains(String name) => names.contains(name);
}

final browserSelectionProvider = NotifierProvider.autoDispose
    .family<BrowserSelectionNotifier, BrowserSelection, String>(BrowserSelectionNotifier.new);

class BrowserSelectionNotifier extends Notifier<BrowserSelection> {
  BrowserSelectionNotifier(this.path);

  final String path;

  @override
  BrowserSelection build() {
    ref.listen(directoryProvider(path), (_, next) {
      if (next.value case final listing?) _retain({for (final entry in listing.entries) entry.name});
    });
    return const BrowserSelection();
  }

  /// The selectable entries in the order they are shown.
  List<FileEntry> get entries =>
      ref.read(browserSortProvider).apply(ref.read(directoryProvider(path)).value?.entries ?? const []);

  List<FileEntry> get selectedEntries => [
    for (final entry in entries)
      if (state.contains(entry.name)) entry,
  ];

  void only(String name) => state = BrowserSelection(names: {name}, anchor: name, lead: name);

  void toggle(String name) {
    final names = {...state.names};
    if (!names.remove(name)) names.add(name);
    state = BrowserSelection(names: names, anchor: name, lead: name);
  }

  /// Selects everything from the anchor up to [name], replacing the previous range.
  void extendTo(String name) {
    final names = [for (final entry in entries) entry.name];
    final anchor = state.anchor ?? name;
    final from = names.indexOf(anchor);
    final to = names.indexOf(name);
    if (from < 0 || to < 0) return only(name);
    final range = from <= to ? names.sublist(from, to + 1) : names.sublist(to, from + 1);
    state = BrowserSelection(names: range.toSet(), anchor: anchor, lead: name);
  }

  void selectAll() => state = BrowserSelection(
    names: {for (final entry in entries) entry.name},
    anchor: state.anchor,
    lead: state.lead,
  );

  void clear() => state = const BrowserSelection();

  void _retain(Set<String> existing) {
    if (state.names.every(existing.contains)) return;
    state = BrowserSelection(
      names: state.names.where(existing.contains).toSet(),
      anchor: existing.contains(state.anchor) ? state.anchor : null,
      lead: existing.contains(state.lead) ? state.lead : null,
    );
  }
}
