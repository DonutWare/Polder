import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "dart:ui";

import "package:polder/models/branding.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/models/user_tag.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_tags.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/services/offline/outbox_errors.dart";
import "package:polder/util/async_lock.dart";
import "package:polder/util/remote_path.dart";

enum TagChangeKind { create, edit, delete, deleteUnused, assign, unassign }

class TagChange {
  const TagChange(this.kind, {this.name = "", this.rename, this.color, this.paths = const [], this.names = const []});

  factory TagChange.fromJson(Map<String, dynamic> json) => TagChange(
    TagChangeKind.values.byName(json["kind"] as String),
    name: json["name"] as String? ?? "",
    rename: json["rename"] as String?,
    color: json["color"] == null ? null : Color(json["color"] as int),
    paths: [...?(json["paths"] as List<dynamic>?)?.cast<String>()],
    names: [...?(json["names"] as List<dynamic>?)?.cast<String>()],
  );

  final TagChangeKind kind;
  final String name;
  final String? rename;
  final Color? color;
  final List<String> paths;
  final List<String> names;

  Map<String, dynamic> toJson() => {
    "kind": kind.name,
    "name": name,
    "rename": ?rename,
    "color": ?color?.toARGB32(),
    if (paths.isNotEmpty) "paths": paths,
    if (names.isNotEmpty) "names": names,
  };
}

class OfflineTags {
  OfflineTags({
    required this._api,
    required this._store,
    required this._files,
    required this._nextColor,
    this._onQueued,
    this._clock = DateTime.now,
  }) {
    _adopting = _files.written.listen((written) => unawaited(_adoptNoteTags(written.path, written.bytes)));
  }

  static const _queueKey = "tags.queue";

  final PolderApi _api;
  final OfflineStore _store;
  final OfflineFiles _files;
  final Color Function(List<UserTag> known) _nextColor;
  final void Function()? _onQueued;
  final DateTime Function() _clock;
  final _lock = AsyncLock();
  final _changes = StreamController<void>.broadcast();
  var _failures = 0;
  Future<DateTime?>? _pushing;
  late final StreamSubscription<void> _adopting;

  Stream<void> get changes => _changes.stream;

  Future<void> dispose() async {
    await _adopting.cancel();
    await _changes.close();
  }

  Future<List<UserTag>> list() async {
    if ((await _queue()).isNotEmpty) return _cachedOrThrow();
    try {
      final tags = await _api.tags();
      return await _lock.run(() async {
        if ((await _queue()).isNotEmpty) return _cachedOrThrow();
        await _saveCache(tags);
        return tags;
      });
    } on NetworkException {
      return _cachedOrThrow();
    }
  }

  Future<UserTag> create(String name, Color? color) => _lock.run(() => _createLocally(name, color));

  Future<void> edit(UserTag tag, {String? name, Color? color}) => _lock.run(() => _editLocally(tag, name, color));

  Future<void> delete(UserTag tag) => _lock.run(() => _deleteLocally(tag));

  Future<int> deleteUnused() => _lock.run(_deleteUnusedLocally);

  Future<List<TagAssignmentResult>> retagRemote(List<String> paths, List<String> names, {required bool adding}) =>
      _lock.run(() => _retagLocally(paths, names, adding: adding));

  Future<DateTime?> push() => _pushing ??= _push().whenComplete(() => _pushing = null);

  Future<DateTime?> _push() async {
    var pushed = false;
    while (true) {
      final next = (await _queue()).firstOrNull;
      if (next == null) break;
      try {
        await _send(next);
      } on NetworkException {
        _failures++;
        return _clock().add(OutboxErrors.retryDelay(_failures));
      } on ApiException catch (_) {}
      pushed = true;
      await _lock.run(() async => _saveQueue((await _queue()).skip(1).toList()));
    }
    _failures = 0;
    if (pushed) {
      try {
        await list();
      } on NetworkException {
        return null;
      } finally {
        _changes.add(null);
      }
    }
    return null;
  }

  Future<void> _adoptNoteTags(String path, Uint8List bytes) async {
    if (RemotePath.extension(path).toLowerCase() != noteExtension) return;
    if ((await _files.pins()).governing(path)?.kind != OfflinePinKind.notes) return;
    final names = readNoteTags(utf8.decode(bytes, allowMalformed: true));
    if (names.isEmpty) return;
    final adopted = await _lock.run(() async {
      final known = await _cached();
      final keys = {for (final tag in known) tag.key};
      final added = [...known];
      for (final name in names) {
        if (!keys.add(tagKey(name))) continue;
        added.add(UserTag(id: _provisionalId(added), name: name, color: _nextColor(added), count: 1));
      }
      if (added.length == known.length) return false;
      await _saveCache(added);
      return true;
    });
    if (adopted && !_changes.isClosed) _changes.add(null);
  }

  static int _provisionalId(List<UserTag> known) =>
      known.fold(0, (lowest, tag) => tag.id < lowest ? tag.id : lowest) - 1;

  Future<UserTag> _createLocally(String name, Color? color) async {
    final known = await _cached();
    final existing = known.where((tag) => tag.key == tagKey(name)).firstOrNull;
    if (existing != null) return existing;
    final created = UserTag(id: _provisionalId(known), name: name, color: color ?? _nextColor(known));
    await _saveCache([...known, created]);
    await _enqueue(TagChange(TagChangeKind.create, name: name, color: created.color));
    return created;
  }

  Future<void> _editLocally(UserTag tag, String? name, Color? color) async {
    final known = await _cached();
    final renamed = name != null && name != tag.name;
    if (renamed && known.any((other) => other.id != tag.id && other.key == tagKey(name))) {
      await _saveCache([
        for (final other in known)
          if (other.key == tagKey(name))
            other.copyWith(name: name, color: color ?? tag.color)
          else if (other.id != tag.id)
            other,
      ]);
    } else {
      await _saveCache([
        for (final other in known)
          if (other.id == tag.id) other.copyWith(name: name ?? other.name, color: color ?? other.color) else other,
      ]);
    }
    await _enqueue(TagChange(TagChangeKind.edit, name: tag.name, rename: renamed ? name : null, color: color));
    if (renamed) await _rewriteNotes((text) => renameNoteTag(text, tag.name, name));
  }

  Future<void> _deleteLocally(UserTag tag) async {
    await _saveCache([...(await _cached()).where((other) => other.id != tag.id)]);
    await _enqueue(TagChange(TagChangeKind.delete, name: tag.name));
    await _rewriteNotes((text) => removeNoteTag(text, tag.name));
  }

  Future<int> _deleteUnusedLocally() async {
    final known = await _cached();
    final used = await _keysInUse();
    final kept = [
      for (final tag in known)
        if (tag.count > 0 || used.contains(tag.key)) tag,
    ];
    await _saveCache(kept);
    await _enqueue(const TagChange(TagChangeKind.deleteUnused));
    return known.length - kept.length;
  }

  Future<Set<String>> _keysInUse() async => {
    for (final change in await _queue())
      if (change.kind == TagChangeKind.assign) ...change.names.map(tagKey),
    for (final note in await _localNotes()) ...readNoteTags(note.text).map(tagKey),
  };

  Future<List<TagAssignmentResult>> _retagLocally(
    List<String> paths,
    List<String> names, {
    required bool adding,
  }) async {
    if (adding) {
      for (final name in names) {
        await _createLocally(name, null);
      }
    }
    await _enqueue(TagChange(adding ? TagChangeKind.assign : TagChangeKind.unassign, paths: paths, names: names));
    return [for (final path in paths) TagAssignmentResult(path: path)];
  }

  Future<void> _rewriteNotes(String Function(String text) rewrite) async {
    for (final note in await _localNotes()) {
      final updated = rewrite(note.text);
      if (updated != note.text) await _files.write(note.path, Uint8List.fromList(utf8.encode(updated)));
    }
  }

  Future<List<({String path, String text})>> _localNotes() async {
    final notes = <({String path, String text})>[];
    final roots = (await _files.pins()).ofKind(OfflinePinKind.notes).map((pin) => pin.path);
    for (final root in roots) {
      for (final row in await _files.tree(root)) {
        if (row.isDir || RemotePath.extension(row.path).toLowerCase() != noteExtension) continue;
        final bytes = await _files.read(row.path);
        if (bytes != null) notes.add((path: row.path, text: utf8.decode(bytes, allowMalformed: true)));
      }
    }
    return notes;
  }

  Future<void> _send(TagChange change) async {
    final color = change.color == null ? null : hexColor(change.color!);
    switch (change.kind) {
      case TagChangeKind.create:
        try {
          await _api.createTag(change.name, color: color);
        } on AlreadyExistsException {
          final existing = await _serverTag(change.name);
          if (existing != null && color != null) await _api.updateTag(existing.id, color: color);
        }
      case TagChangeKind.edit:
        final existing = await _serverTag(change.name);
        if (existing != null) {
          await _api.updateTag(existing.id, name: change.rename, color: color);
        } else if (change.rename != null || change.color != null) {
          await _send(TagChange(TagChangeKind.create, name: change.rename ?? change.name, color: change.color));
        }
      case TagChangeKind.delete:
        final existing = await _serverTag(change.name);
        if (existing != null) await _api.deleteTag(existing.id);
      case TagChangeKind.deleteUnused:
        await _api.deleteUnusedTags();
      case TagChangeKind.assign:
        await _api.assignTags(change.paths, change.names);
      case TagChangeKind.unassign:
        await _api.unassignTags(change.paths, change.names);
    }
  }

  Future<UserTag?> _serverTag(String name) async =>
      (await _api.tags()).where((tag) => tag.key == tagKey(name)).firstOrNull;

  Future<void> _enqueue(TagChange change) async {
    await _saveQueue([...await _queue(), change]);
    _onQueued?.call();
  }

  Future<List<TagChange>> _queue() async {
    final raw = await _store.meta(_queueKey);
    if (raw == null) return const [];
    return [for (final change in jsonDecode(raw) as List<dynamic>) TagChange.fromJson(change as Map<String, dynamic>)];
  }

  Future<void> _saveQueue(List<TagChange> queue) =>
      _store.saveMeta(_queueKey, queue.isEmpty ? null : jsonEncode([for (final change in queue) change.toJson()]));

  Future<List<UserTag>> _cachedOrThrow() async =>
      await _store.cachedTags() ?? (throw const NetworkException(reason: "tags are not on this device"));

  Future<List<UserTag>> _cached() async => await _store.cachedTags() ?? const [];

  Future<void> _saveCache(List<UserTag> tags) => _store.saveCachedTags(tags);
}
