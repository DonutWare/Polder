import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

import "package:polder_core/models/notifications/notification_preferences.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder/services/features/feature_modes.dart";

void main() {
  const automatic = FeatureModes({
    PolderFeature.drive: FeatureMode.automatic,
    PolderFeature.notes: FeatureMode.automatic,
    PolderFeature.calendar: FeatureMode.automatic,
  });

  test("automatic opens an installed companion app and builds in the rest", () {
    final resolved = automatic.resolve({PolderFeature.calendar});

    expect(resolved[PolderFeature.calendar], FeatureMode.openApp);
    expect(resolved[PolderFeature.drive], FeatureMode.builtIn);
    expect(resolved[PolderFeature.notes], FeatureMode.builtIn);
  });

  test("explicit choices win over what is installed", () {
    final modes = automatic
        .withMode(PolderFeature.calendar, FeatureMode.builtIn)
        .withMode(PolderFeature.notes, FeatureMode.hidden)
        .resolve({PolderFeature.calendar, PolderFeature.notes});

    expect(modes[PolderFeature.calendar], FeatureMode.builtIn);
    expect(modes[PolderFeature.notes], FeatureMode.hidden);
  });

  test("phones offer every mode and default to automatic", () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(FeatureModes.choices, FeatureMode.values);
    expect(const FeatureModes({})[PolderFeature.drive], FeatureMode.automatic);
  });

  test("desktop only offers built in and hidden, defaulting to built in", () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(FeatureModes.choices, [FeatureMode.builtIn, FeatureMode.hidden]);
    expect(const FeatureModes({})[PolderFeature.drive], FeatureMode.builtIn);
    expect(FeatureModes.fromJson({"drive": "openApp", "notes": "hidden"})[PolderFeature.drive], FeatureMode.builtIn);
    expect(FeatureModes.fromJson({"drive": "openApp", "notes": "hidden"})[PolderFeature.notes], FeatureMode.hidden);
  });

  test("notifications only come from built-in features", () {
    const preferences = NotificationPreferences(enabled: true, autoUploadCheck: true);
    final restricted = const FeatureModes({
      PolderFeature.drive: FeatureMode.hidden,
      PolderFeature.calendar: FeatureMode.openApp,
    }).restrict(preferences);

    expect(restricted.wantsShares, isFalse);
    expect(restricted.wantsUploadProgress, isFalse);
    expect(restricted.wantsUploadCheck, isFalse);
    expect(restricted.wantsCalendarReminders, isFalse);
    expect(FeatureModes.everythingBuiltIn.restrict(preferences), preferences);
  });

  test("modes survive a round trip through preferences", () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final store = InMemoryPreferencesStore();
    final modes = const FeatureModes({}).withMode(PolderFeature.notes, FeatureMode.hidden);

    await FeatureModes.write(store, modes);

    expect((await FeatureModes.read(store))[PolderFeature.notes], FeatureMode.hidden);
    expect((await FeatureModes.readResolved(store))[PolderFeature.drive], FeatureMode.builtIn);
  });
}
