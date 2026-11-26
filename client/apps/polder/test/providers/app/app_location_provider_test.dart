import "package:flutter_test/flutter_test.dart";

import "package:polder_ui/l10n/generated/app_localizations_en.dart";
import "package:polder/providers/app/app_location_provider.dart";
import "package:polder/providers/app/browser_favicon_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/app_title.dart";

import "../../support/fixtures.dart";

void main() {
  final localized = AppLocalizationsEn();
  String titleOf(String location, [Object? extra]) =>
      appTitle(AppLocation.of(Uri.parse(location), extra), "Polder", localized);

  test("notes and calendar get their own favicon, everything else the default", () {
    expect(faviconFor(AppSection.notes), "favicon-notes.png");
    expect(faviconFor(AppSection.calendar), "favicon-calendar.png");
    expect(faviconFor(AppSection.other), "favicon.png");
  });

  test("sections and the open folder, note or file lead the title", () {
    expect(titleOf(AppRoutes.files), "Polder");
    expect(titleOf(AppRoutes.filesAt("/Photos/Holiday")), "Holiday · Polder");
    expect(titleOf(AppRoutes.notes), "Notes · Polder");
    expect(titleOf(AppRoutes.noteAt("/Notes/Groceries.md")), "Groceries · Notes · Polder");
    expect(titleOf(AppRoutes.cookAt("/Notes/Pancakes.md")), "Pancakes · Notes · Polder");
    expect(titleOf(AppRoutes.calendar), "Calendar · Polder");
    expect(titleOf(AppRoutes.pdf, remoteFile("/Documents/Taxes.pdf")), "Taxes.pdf · Polder");
    expect(titleOf(AppRoutes.settings), "Polder");
  });
}
