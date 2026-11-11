import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:flutter/painting.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/branding.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/search/search_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_tags.dart";
import "package:polder/services/offline/offline_files.dart";
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

  PolderApi get _api => ref.read(polderApiProvider);

  @override
  Future<List<UserTag>> build() async {
    Timer? pending;
    ref.onDispose(() => pending?.cancel());
    ref.listen(filesChangedProvider, (_, _) {
      pending?.cancel();
      pending = Timer(notesSettleDelay, refresh);
    });
    return _fetch(ref.watch(polderApiProvider));
  }

  Future<List<UserTag>> _fetch(PolderApi api) async {
    final store = await ref.read(offlineStoreProvider.future);
    try {
      final tags = await api.tags();
      await store.saveMeta(_cacheKey, jsonEncode([for (final tag in tags) _encode(tag)]));
      return tags;
    } on NetworkException {
      final cached = await store.meta(_cacheKey);
      if (cached == null) rethrow;
      return [for (final tag in jsonDecode(cached) as List<dynamic>) _decode(tag as Map<String, dynamic>)];
    }
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(() => _fetch(_api));
    if (ref.mounted && next.hasValue) state = next;
  }

  Future<UserTag> create(String name, {Color? color}) async {
    try {
      final created = await _api.createTag(name, color: color == null ? null : hexColor(color));
      await refresh();
      return created;
    } on NetworkException {
      final known = state.value ?? const <UserTag>[];
      final provisional = UserTag(id: -1 - known.length, name: name, color: color ?? nextTagColor(known));
      state = AsyncData([...known, provisional]);
      return provisional;
    }
  }

  Future<void> edit(UserTag tag, {String? name, Color? color}) async {
    if (tag.id < 0) return _replaceProvisional(tag, tag.copyWith(name: name ?? tag.name, color: color ?? tag.color));
    await _api.updateTag(tag.id, name: name, color: color == null ? null : hexColor(color));
    await _afterItemsChanged();
  }

  Future<void> delete(UserTag tag) async {
    if (tag.id < 0) return _replaceProvisional(tag, null);
    await _api.deleteTag(tag.id);
    await _afterItemsChanged();
  }

  void _replaceProvisional(UserTag tag, UserTag? replacement) => state = AsyncData([
    for (final known in state.value ?? const <UserTag>[])
      if (known.id != tag.id) known else ?replacement,
  ]);

  Future<int> deleteUnused() async {
    final removed = await _api.deleteUnusedTags();
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
      if (remote.isNotEmpty) ...await (adding ? _api.assignTags(remote, names) : _api.unassignTags(remote, names)),
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

const _cacheKey = "tags.cache";

Map<String, dynamic> _encode(UserTag tag) => {
  "id": tag.id,
  "name": tag.name,
  "color": tag.color.toARGB32(),
  "count": tag.count,
};

UserTag _decode(Map<String, dynamic> json) => UserTag(
  id: json["id"] as int,
  name: json["name"] as String,
  color: Color(json["color"] as int),
  count: json["count"] as int? ?? 0,
);

Color nextTagColor(List<UserTag> tags) => tagPalette[tags.length % tagPalette.length];
