import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/layout/app_page.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";

import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/services/features/feature_modes.dart";

class AppsSettingsScreen extends StatelessWidget {
  const AppsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(context.localized.settingsApps),
    body: ReadableWidth(
      maxWidth: 720,
      builder: (context, inset) => ListView(
        padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              context.localized.settingsAppsIntro,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          for (final feature in PolderFeature.values) _FeatureModeGroup(feature: feature),
        ],
      ),
    ),
  );
}

class _FeatureModeGroup extends ConsumerWidget {
  const _FeatureModeGroup({required this.feature});

  final PolderFeature feature;

  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(featureModesProvider)[feature];
    final installed = ref.watch(installedCompanionsProvider).contains(feature);
    return NavGroup(
      title: feature.title(context),
      children: [
        RadioGroup<FeatureMode>(
          groupValue: mode,
          onChanged: (next) {
            if (next != null) ref.read(featureModesProvider.notifier).setMode(feature, next);
          },
          child: Column(
            children: [
              for (final choice in FeatureModes.choices)
                RadioListTile<FeatureMode>(
                  contentPadding: _padding,
                  value: choice,
                  title: Text(choice.label(context)),
                  subtitle: Text(choice.hint(context, feature, installed: installed)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on PolderFeature {
  String title(BuildContext context) => switch (this) {
    PolderFeature.drive => context.localized.navFiles,
    PolderFeature.notes => context.localized.navNotes,
    PolderFeature.calendar => context.localized.navCalendar,
  };

  String get appName => switch (this) {
    PolderFeature.drive => "Polder Drive",
    PolderFeature.notes => "Polder Notes",
    PolderFeature.calendar => "Polder Calendar",
  };
}

extension on FeatureMode {
  String label(BuildContext context) => switch (this) {
    FeatureMode.automatic => context.localized.featureModeAutomatic,
    FeatureMode.builtIn => context.localized.featureModeBuiltIn,
    FeatureMode.openApp => context.localized.featureModeOpenApp,
    FeatureMode.hidden => context.localized.featureModeHidden,
  };

  String hint(BuildContext context, PolderFeature feature, {required bool installed}) => switch (this) {
    FeatureMode.automatic when installed => context.localized.featureModeAutomaticOpens(feature.appName),
    FeatureMode.automatic => context.localized.featureModeAutomaticBuiltIn(feature.appName),
    FeatureMode.builtIn => context.localized.featureModeBuiltInHint,
    FeatureMode.openApp => context.localized.featureModeOpenAppHint(feature.appName),
    FeatureMode.hidden => context.localized.featureModeHiddenHint,
  };
}
