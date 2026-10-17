import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/file_space.dart";
import "package:polder/models/sharing.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/sharing/file_space_providers.dart";
import "package:polder/providers/sharing/shares_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/breadcrumbs.dart";
import "package:polder/screens/browser/widgets/transfers_button.dart";
import "package:polder/screens/shared/widgets/space_directory_view.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/app_page.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/file_dialogs.dart";

class SharedBrowserScreen extends ConsumerWidget {
  const SharedBrowserScreen({required this.shareId, required this.path, required this.parentRoute, super.key});

  final int shareId;
  final String path;
  final String parentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = FileSpace.share(shareId: shareId);
    final location = SpaceLocation(space: space, path: path);
    final share = ref.watch(incomingShareProvider(shareId));
    final capabilities = ref.watch(spaceCapabilitiesProvider(space));
    final localized = context.localized;
    final name = share?.entry.name ?? localized.navShared;
    final isDir = share?.entry.isDir ?? true;
    final folder = FileEntry.folder(path, rootName: name);
    return AppPage(
      leading: BackButton(onPressed: () => context.go(parentRoute)),
      title: Text(folder.name),
      actions: [
        const TransfersButton(),
        if (capabilities.canCreate && isDir)
          IconButton(
            tooltip: localized.newFolder,
            icon: const Icon(IconsaxPlusLinear.folder_add),
            onPressed: () => _createFolder(context, ref, location),
          ),
        if (isDir)
          IconButton(
            tooltip: localized.downloadAll,
            icon: const Icon(IconsaxPlusLinear.document_download),
            onPressed: () => ref.read(transfersProvider.notifier).downloadFromSpace(space, folder),
          ),
      ],
      bottom: isDir
          ? PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Breadcrumbs(
                path: path,
                rootLabel: name,
                onNavigate: (target) => context.go(AppRoutes.sharedAt(shareId, path: target)),
              ),
            )
          : null,
      floatingActionButton: capabilities.canUpload && isDir
          ? FloatingActionButton.extended(
              icon: const Icon(IconsaxPlusLinear.document_upload),
              label: Text(localized.uploadFiles),
              onPressed: () => ref.read(transfersProvider.notifier).pickAndUploadToSpace(location),
            )
          : null,
      body: AsyncValueView<List<IncomingShare>>(
        value: ref.watch(incomingSharesProvider),
        onRetry: () => ref.invalidate(incomingSharesProvider),
        data: (_) => SpaceDirectoryView(
          location: location,
          onOpenFolder: (folder) => context.go(AppRoutes.sharedAt(shareId, path: folder)),
        ),
      ),
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref, SpaceLocation location) async {
    final name = await promptFolderName(context);
    if (name == null || !context.mounted) return;
    await context.runWithFeedback(ref.read(spaceDirectoryProvider(location).notifier).createFolder(name));
  }
}
