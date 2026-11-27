import "package:polder_account_link/companion_app.dart";
import "package:polder_core/models/notifications/notification_preferences.dart";
import "package:polder_core/services/storage/preferences_store.dart";
import "package:polder_core/util/flavor.dart";

enum PolderFeature {
  drive(CompanionApp.drive),
  notes(CompanionApp.notes),
  calendar(CompanionApp.calendar);

  const PolderFeature(this.companion);

  final CompanionApp companion;
}

enum FeatureMode { automatic, builtIn, openApp, hidden }

class FeatureModes {
  const FeatureModes(this._modes);

  static const key = "polder.features";

  static const everythingBuiltIn = FeatureModes({
    PolderFeature.drive: FeatureMode.builtIn,
    PolderFeature.notes: FeatureMode.builtIn,
    PolderFeature.calendar: FeatureMode.builtIn,
  });

  final Map<PolderFeature, FeatureMode> _modes;

  static bool get canOpenApps => CompanionApps.canDetect;

  static List<FeatureMode> get choices =>
      canOpenApps ? FeatureMode.values : const [FeatureMode.builtIn, FeatureMode.hidden];

  static FeatureMode get defaultMode => canOpenApps ? FeatureMode.automatic : FeatureMode.builtIn;

  FeatureMode operator [](PolderFeature feature) => _modes[feature] ?? defaultMode;

  FeatureModes withMode(PolderFeature feature, FeatureMode mode) => FeatureModes({..._modes, feature: mode});

  FeatureModes resolve(Set<PolderFeature> installed) => FeatureModes({
    for (final feature in PolderFeature.values)
      feature: switch (this[feature]) {
        FeatureMode.automatic => installed.contains(feature) ? FeatureMode.openApp : FeatureMode.builtIn,
        final mode => mode,
      },
  });

  bool isBuiltIn(PolderFeature feature) => this[feature] == FeatureMode.builtIn;

  bool isVisible(PolderFeature feature) => this[feature] != FeatureMode.hidden;

  bool get needsDetection => PolderFeature.values.any((feature) => this[feature] == FeatureMode.automatic);

  NotificationPreferences restrict(NotificationPreferences preferences) => preferences.copyWith(
    shares: preferences.shares && isBuiltIn(PolderFeature.drive),
    autoUploadProgress: preferences.autoUploadProgress && isBuiltIn(PolderFeature.drive),
    autoUploadSummary: preferences.autoUploadSummary && isBuiltIn(PolderFeature.drive),
    autoUploadCheck: preferences.autoUploadCheck && isBuiltIn(PolderFeature.drive),
    calendarReminders: preferences.calendarReminders && isBuiltIn(PolderFeature.calendar),
  );

  Map<String, String> toJson() => {for (final entry in _modes.entries) entry.key.name: entry.value.name};

  static FeatureModes fromJson(Map<String, dynamic> json) => FeatureModes({
    for (final feature in PolderFeature.values)
      if (FeatureMode.values.asNameMap()[json[feature.name]] case final mode? when choices.contains(mode))
        feature: mode,
  });

  static Future<FeatureModes> read(PreferencesStore store) async =>
      fromJson(await store.readJson(key) ?? const <String, dynamic>{});

  static Future<void> write(PreferencesStore store, FeatureModes modes) => store.writeJson(key, modes.toJson());

  static Future<Set<PolderFeature>> detectInstalled() async => {
    for (final feature in PolderFeature.values)
      if (await CompanionApps.isInstalled(feature.companion, dev: isDevFlavor)) feature,
  };

  static Future<FeatureModes> readResolved(PreferencesStore store) async {
    final modes = await read(store);
    return modes.resolve(modes.needsDetection ? await detectInstalled() : const {});
  }
}
