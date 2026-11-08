import "package:flutter_test/flutter_test.dart";

import "package:polder/screens/search/open_search.dart";

void main() {
  test("search from the calendar starts with events", () {
    expect(searchScopeFor(Uri.parse("/calendar?view=week")), "type=event ");
  });

  test("search from a folder starts in that folder", () {
    expect(searchScopeFor(Uri.parse("/files?path=/Photos")), "in=/Photos ");
    expect(searchScopeFor(Uri.parse("/files?path=/")), "");
  });

  test("search from elsewhere starts empty", () {
    expect(searchScopeFor(Uri.parse("/notes")), "");
  });
}
