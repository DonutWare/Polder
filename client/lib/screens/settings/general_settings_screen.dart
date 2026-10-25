import "package:flutter/material.dart";

import "package:polder/screens/settings/widgets/finder_settings_group.dart";
import "package:polder/screens/settings/widgets/trash_settings_group.dart";
import "package:polder/screens/settings/widgets/version_settings_group.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(context.localized.generalSettings),
    body: ReadableWidth(
      maxWidth: 720,
      builder: (context, inset) => ListView(
        padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
        children: const [FinderSettingsGroup(), TrashSettingsGroup(), VersionSettingsGroup()],
      ),
    ),
  );
}
