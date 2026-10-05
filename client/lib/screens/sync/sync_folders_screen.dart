import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/screens/sync/widgets/add_sync_folder_dialog.dart";
import "package:polder/screens/sync/widgets/conflicts_banner.dart";
import "package:polder/screens/sync/widgets/pause_sync_button.dart";
import "package:polder/screens/sync/widgets/sync_now_button.dart";
import "package:polder/screens/sync/widgets/sync_roots_list.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/message_view.dart";

class SyncFoldersScreen extends ConsumerWidget {
  const SyncFoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(syncPlatformProvider).supportsFolderSync) {
      return AppPage(
        title: Text(context.localized.syncFolders),
        body: MessageView(icon: IconsaxPlusLinear.refresh_2, message: context.localized.syncUnsupported),
      );
    }
    return AppPage(
      title: Text(context.localized.syncFolders),
      actions: const [PauseSyncButton(), SyncNowButton()],
      body: ReadableWidth(
        maxWidth: 840,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 8, bottom: 96),
          children: const [
            ConflictsBanner(),
            SyncRootsList(mode: SyncMode.sync),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(IconsaxPlusLinear.folder_add),
        label: Text(context.localized.addSyncFolder),
        onPressed: () => showAddSyncFolderDialog(context, SyncMode.sync),
      ),
    );
  }
}
