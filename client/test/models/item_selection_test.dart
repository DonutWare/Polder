import "package:flutter_test/flutter_test.dart";

import "package:polder/models/item_selection.dart";

void main() {
  const order = ["a", "b", "c", "d"];

  test("toggling adds and removes an item", () {
    final selection = ItemSelection.only("a").toggled("c");

    expect(selection.names, {"a", "c"});
    expect(selection.toggled("a").names, {"c"});
  });

  test("a range runs from the anchor to the item in either direction", () {
    expect(ItemSelection.only("b").extendedTo("d", order).names, {"b", "c", "d"});
    expect(ItemSelection.only("c").extendedTo("a", order).names, {"a", "b", "c"});
  });

  test("a new range replaces the previous one from the same anchor", () {
    final selection = ItemSelection.only("b").extendedTo("d", order).extendedTo("a", order);

    expect(selection.names, {"a", "b"});
    expect(selection.anchor, "b");
  });

  test("items that disappear leave the selection", () {
    final selection = ItemSelection.only("a").toggled("b").retaining({"b", "c"});

    expect(selection.names, {"b"});
    expect(selection.anchor, "b");
  });
}
