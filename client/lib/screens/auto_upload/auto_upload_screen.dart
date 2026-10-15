import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/screens/activity/widgets/live_transfers_card.dart";
import "package:polder/screens/auto_upload/widgets/auto_upload_settings_section.dart";
import "package:polder/screens/sync/widgets/add_sync_folder_dialog.dart";
import "package:polder/screens/sync/widgets/conflicts_banner.dart";
import "package:polder/screens/sync/widgets/sync_now_button.dart";
import "package:polder/screens/sync/widgets/sync_roots_list.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";

class AutoUploadScreen extends StatelessWidget {
  const AutoUploadScreen({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: Text(context.localized.navAutoUpload),
    actions: const [SyncNowButton()],
    body: ReadableWidth(
      maxWidth: 840,
      builder: (context, inset) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: inset + const EdgeInsets.only(top: 8, bottom: 96),
            sliver: const SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(child: AutoUploadSettingsSection()),
                LiveTransfersSliver(),
                SliverToBoxAdapter(child: ConflictsBanner()),
                SliverToBoxAdapter(child: SyncRootsList(mode: SyncMode.autoUpload)),
              ],
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      icon: const Icon(IconsaxPlusLinear.gallery_add),
      label: Text(context.localized.addAutoUploadFolder),
      onPressed: () => showAddSyncFolderDialog(context, SyncMode.autoUpload),
    ),
  );
}
