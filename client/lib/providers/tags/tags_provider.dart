import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:flutter/painting.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/search/search_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/services/notes/note_tags.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/services/offline/offline_tags.dart";
import "package:polder/util/remote_path.dart";

const tagPalette = [
  Color(0xFFE5484D),
  Color(0xFFF76B15),
  Color(0xFFFFC53D),
  Color(0xFF46A758),
  Color(0xFF12A594),
  Color(0xFF0090FF),
  Color(0xFF3E63DD),
  Color(0xFF8E4EC6),
  Color(0xFFD6409F),
  Color(0xFF8D8D8D),
];

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<UserTag>>(TagsNotifier.new);

final tagsByIdProvider = Provider<Map<int, UserTag>>(
  (ref) => {for (final tag in ref.watch(tagsProvider).value ?? const <UserTag>[]) tag.id: tag},
);

final tagsByKeyProvider = Provider<Map<String, UserTag>>(
  (ref) => {for (final tag in ref.watch(tagsProvider).value ?? const <UserTag>[]) tag.key: tag},
);

class TagsNotifier extends AsyncNotifier<List<UserTag>> {
  static const notesSettleDelay = Duration(seconds: 1);

  Future<OfflineTags> get _tags => ref.read(offlineTagsProvider.future);

  @override
  Future<List<UserTag>> build() async {
    Timer? pending;
    void refreshSoon() {
      pending?.cancel();
      pending = Timer(notesSettleDelay, refresh);
    }

    final tags = await ref.watch(offlineTagsProvider.future);
    final subscription = tags.changes.listen((_) => refresh());
    ref.onDispose(() {
      pending?.cancel();
      unawaited(subscription.cancel());
    });
    ref.listen(filesChangedProvider, (_, _) => refreshSoon());
    return tags.list();
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(() async => (await _tags).list());
    if (ref.mounted && next.hasValue) state = next;
  }

  Future<UserTag> create(String name, {Color? color}) async {
    final created = await (await _tags).create(name, color);
    await refresh();
    return created;
  }

  Future<void> edit(UserTag tag, {String? name, Color? color}) async {
    await (await _tags).edit(tag, name: name, color: color);
    await _afterItemsChanged();
  }

  Future<void> delete(UserTag tag) async {
    await (await _tags).delete(tag);
    await _afterItemsChanged();
  }

  Future<int> deleteUnused() async {
    final removed = await (await _tags).deleteUnused();
    await refresh();
    return removed;
  }

  Future<List<TagAssignmentResult>> assign(List<String> paths, List<String> names) =>
      _retag(paths, names, adding: true);

  Future<List<TagAssignmentResult>> unassign(List<String> paths, List<String> names) =>
      _retag(paths, names, adding: false);

  Future<List<TagAssignmentResult>> _retag(List<String> paths, List<String> names, {required bool adding}) async {
    final files = await ref.read(offlineFilesProvider.future);
    final local = <String>[];
    final remote = <String>[];
    for (final path in paths) {
      final note = RemotePath.extension(path).toLowerCase() == noteExtension && await files.availableOffline(path);
      (note ? local : remote).add(path);
    }
    final results = [
      for (final path in local) await _retagNote(files, path, names, adding: adding),
      if (remote.isNotEmpty) ...await (await _tags).retagRemote(remote, names, adding: adding),
    ];
    await _afterItemsChanged();
    return results;
  }

  Future<TagAssignmentResult> _retagNote(
    OfflineFiles files,
    String path,
    List<String> names, {
    required bool adding,
  }) async {
    final bytes = await files.read(path);
    if (bytes == null) return TagAssignmentResult(path: path, error: "not available offline");
    final text = utf8.decode(bytes, allowMalformed: true);
    final updated = names.fold(
      text,
      (current, name) => adding ? appendNoteTag(current, name) : removeNoteTag(current, name),
    );
    if (updated != text) await files.write(path, Uint8List.fromList(utf8.encode(updated)));
    return TagAssignmentResult(path: path);
  }

  Future<void> _afterItemsChanged() async {
    await refresh();
    ref
      ..invalidate(directoryProvider)
      ..invalidate(notesTreeProvider)
      ..invalidate(searchResultsProvider);
  }
}

Color nextTagColor(List<UserTag> tags) => tagPalette[tags.length % tagPalette.length];
