import "package:flutter/material.dart";

import "package:polder/screens/admin/widgets/federation_settings_group.dart";
import "package:polder/screens/admin/widgets/preview_settings_group.dart";
import "package:polder/screens/admin/widgets/search_settings_group.dart";
import "package:polder/screens/admin/widgets/trash_settings_group.dart";
import "package:polder/screens/admin/widgets/version_settings_group.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";

class AdminServerScreen extends StatelessWidget {
  const AdminServerScreen({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(context.localized.serverSettings),
    body: ReadableWidth(
      maxWidth: 1080,
      builder: (context, inset) => ListView(
        padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
        children: const [
          ServerTrashSettingsGroup(),
          ServerVersionSettingsGroup(),
          SearchSettingsGroup(),
          PreviewSettingsGroup(),
          ServerFederationSettingsGroup(),
        ],
      ),
    ),
  );
}
