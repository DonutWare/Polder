import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/util/remote_path.dart";

final folderPickerProvider = NotifierProvider.autoDispose.family<FolderPickerNotifier, String, String>(
  FolderPickerNotifier.new,
);

class FolderPickerNotifier extends Notifier<String> {
  FolderPickerNotifier(this.initialPath);

  final String initialPath;

  @override
  String build() => initialPath;

  void open(String path) => state = path;

  void up() => state = RemotePath.parent(state);
}
