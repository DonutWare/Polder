import "package:flutter/foundation.dart";

@immutable
class ItemSelection {
  const ItemSelection({this.names = const {}, this.anchor, this.lead});

  final Set<String> names;

  /// Where a shift-click range starts.
  final String? anchor;

  /// The item last clicked or reached with the arrow keys.
  final String? lead;

  bool get isEmpty => names.isEmpty;
  bool get isNotEmpty => names.isNotEmpty;
  int get length => names.length;
  bool contains(String name) => names.contains(name);

  static ItemSelection only(String name) => ItemSelection(names: {name}, anchor: name, lead: name);

  ItemSelection toggled(String name) {
    final toggled = {...names};
    if (!toggled.remove(name)) toggled.add(name);
    return ItemSelection(names: toggled, anchor: name, lead: name);
  }

  /// Selects everything from the anchor up to [name] in [order], replacing the previous range.
  ItemSelection extendedTo(String name, List<String> order) {
    final from = order.indexOf(anchor ?? name);
    final to = order.indexOf(name);
    if (from < 0 || to < 0) return only(name);
    final range = from <= to ? order.sublist(from, to + 1) : order.sublist(to, from + 1);
    return ItemSelection(names: range.toSet(), anchor: anchor ?? name, lead: name);
  }

  ItemSelection withAll(Iterable<String> order) => ItemSelection(names: order.toSet(), anchor: anchor, lead: lead);

  ItemSelection retaining(Set<String> existing) {
    if (names.every(existing.contains)) return this;
    return ItemSelection(
      names: names.where(existing.contains).toSet(),
      anchor: existing.contains(anchor) ? anchor : null,
      lead: existing.contains(lead) ? lead : null,
    );
  }
}
