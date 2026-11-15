import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/app/app_location_provider.dart";
import "package:polder/util/browser_favicon.dart";

final browserFaviconProvider = Provider<void>(
  (ref) => setBrowserFavicon(faviconFor(ref.watch(appLocationProvider.select((location) => location.section)))),
);

String faviconFor(AppSection section) => switch (section) {
  AppSection.notes => "favicon-notes.png",
  AppSection.calendar => "favicon-calendar.png",
  AppSection.other => "favicon.png",
};
