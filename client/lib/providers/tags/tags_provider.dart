import "dart:async";

import "package:flutter/painting.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/branding.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/search/search_provider.dart";
import "package:polder/services/api/polder_api.dart";

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
    return ref.watch(polderApiProvider).tags();
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_api.tags);
    if (ref.mounted && next.hasValue) state = next;
  }

  Future<UserTag> create(String name, {Color? color}) async {
    final created = await _api.createTag(name, color: color == null ? null : hexColor(color));
    await refresh();
    return created;
  }

  Future<void> edit(UserTag tag, {String? name, Color? color}) async {
    await _api.updateTag(tag.id, name: name, color: color == null ? null : hexColor(color));
    await _afterItemsChanged();
  }

  Future<void> delete(UserTag tag) async {
    await _api.deleteTag(tag.id);
    await _afterItemsChanged();
  }

  Future<int> deleteUnused() async {
    final removed = await _api.deleteUnusedTags();
    await refresh();
    return removed;
  }

  Future<List<TagAssignmentResult>> assign(List<String> paths, List<String> names) async {
    final results = await _api.assignTags(paths, names);
    await _afterItemsChanged();
    return results;
  }

  Future<List<TagAssignmentResult>> unassign(List<String> paths, List<String> names) async {
    final results = await _api.unassignTags(paths, names);
    await _afterItemsChanged();
    return results;
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
