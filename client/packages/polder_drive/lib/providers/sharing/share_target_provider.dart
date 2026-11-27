import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/providers/account_provider.dart";
import "package:polder_core/services/transfer/file_picker_service.dart";
import "package:polder_drive/providers/browser/transfers_provider.dart";
import "package:polder_drive/routes/drive_routes.dart";
import "package:polder_drive/services/sharing/shared_content.dart";
import "package:polder_ui/providers/app/navigation_history_provider.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/files/remote_folder_picker_dialog.dart";

const _channel = MethodChannel("polder/share");

final shareTargetHandlerProvider = Provider<void>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  var choosing = false;
  Future<void> receive(Object? arguments) async {
    final content = SharedContent.fromMap(arguments);
    if (content == null || choosing) return;
    choosing = true;
    try {
      final context = await _signedInContext(ref);
      if (context != null && context.mounted) await _chooseFolder(ref, context, content);
    } finally {
      choosing = false;
    }
  }

  _channel.setMethodCallHandler((call) async {
    if (call.method == "share") unawaited(receive(call.arguments));
  });
  unawaited(_channel.invokeMethod<Object?>("takePending").then(receive));
  ref.onDispose(() => _channel.setMethodCallHandler(null));
});

Future<BuildContext?> _signedInContext(Ref ref) async {
  if (await ref.read(accountProvider.future) == null) return null;
  await WidgetsBinding.instance.endOfFrame;
  return ref.read(historyRouterProvider).routerDelegate.navigatorKey.currentContext;
}

Future<void> _chooseFolder(Ref ref, BuildContext context, SharedContent content) async {
  final folder = await showRemoteFolderPicker(
    context,
    title: context.localized.uploadSharedFiles(content.count),
    confirmLabel: context.localized.uploadHere,
  );
  if (folder == null) return;
  final transfers = ref.read(transfersProvider.notifier);
  await transfers.ensureFolder(folder);
  ref.read(historyRouterProvider).go(DriveRoutes.filesAt(folder));
  unawaited(_upload(transfers, folder, content));
}

Future<void> _upload(TransfersNotifier transfers, String folder, SharedContent content) async {
  if (content case SharedContent(isText: true, :final text?)) {
    return transfers.upload(folder, BytesPickedFile(content.textFileName, utf8.encode(text)));
  }
  for (final file in content.files) {
    final copy = await _copyToCache(file);
    if (copy == null) continue;
    try {
      await transfers.upload(folder, LocalPickedFile(copy, name: file.name));
    } finally {
      await _delete(copy);
    }
  }
}

Future<String?> _copyToCache(SharedFile file) async {
  try {
    return await _channel.invokeMethod<String>("copy", {"uri": file.uri});
  } on PlatformException catch (error) {
    debugPrint("Could not read shared file ${file.name}: ${error.message}");
    return null;
  }
}

Future<void> _delete(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    return;
  }
}
