import "package:nomad/models/change.dart";
import "package:nomad/models/file_entry.dart";
import "package:nomad/models/sync/remote_state.dart";
import "package:nomad/models/sync/sync_entry.dart";
import "package:nomad/util/relative_path.dart";
import "package:nomad/util/remote_path.dart";

/// A file that now lives at [to] but had the content found at [from] before this change set, so a local
/// copy of [from] can be moved there instead of downloading [entry] again. Paths are absolute remote paths.
typedef RemoteMove = ({String from, String to, FileEntry entry});

class RemoteChangeSet {
  RemoteChangeSet({required this.remoteRoot, required this._synced});

  final String remoteRoot;
  final Map<String, SyncEntry> _synced;
  final Map<String, RemoteState> _states = {};

  // Absolute path -> the path its content had before this change set, or null when it has none (new or gone).
  final Map<String, String?> _origins = {};
  final Map<String, FileEntry> _entries = {};

  Map<String, RemoteState> get states => Map.unmodifiable(_states);

  /// Moves across the whole account, not just under [remoteRoot], so moves between sync roots are seen too.
  List<RemoteMove> get moves => [
    for (final MapEntry(key: to, value: from) in _origins.entries)
      if ((from, _entries[to]) case (final from?, final entry?) when from != to && !entry.isDir)
        (from: from, to: to, entry: entry),
  ];

  void applyAll(Iterable<Change> changes) => changes.forEach(apply);

  void apply(Change change) {
    switch (change) {
      case Change(type: ChangeType.move, :final fromPath?):
        _applyMove(fromPath, change.path, change.entry);
      case Change(type: ChangeType.upsert, :final entry?):
        _entries[change.path] = entry;
        _setState(change.path, RemoteState.upserted(entry));
      case _:
        _applyDelete(change.path);
    }
  }

  void _applyMove(String from, String to, FileEntry? entry) {
    final origin = _origins.containsKey(from) ? _origins[from] : from;
    _origins[from] = null;
    _entries.remove(from);
    _setState(from, const RemoteState.deleted());
    _origins[to] = origin;
    // Without an entry the move was superseded; a later change in the feed describes the target.
    if (entry != null) {
      _entries[to] = entry;
      _setState(to, RemoteState.upserted(entry));
    }
  }

  void _applyDelete(String path) {
    bool affected(String known) => known == path || RemotePath.isWithin(known, path);
    _entries.removeWhere((known, _) => affected(known));
    for (final known in _origins.keys.where(affected).toList()) {
      _origins[known] = null;
    }
    _origins[path] = null;
    final relative = _relative(path);
    if (relative != null) _markDeleted(relative);
  }

  void _setState(String path, RemoteState state) {
    final relative = _relative(path);
    if (relative != null) _states[relative] = state;
  }

  String? _relative(String path) => RemotePath.relativeTo(path, remoteRoot);

  void _markDeleted(String path) {
    _states.removeWhere((known, _) => RelativePath.isWithin(known, path));
    _states[path] = const RemoteState.deleted();
    for (final syncedPath in _synced.keys.where((known) => RelativePath.isWithin(known, path))) {
      _states[syncedPath] = const RemoteState.deleted();
    }
  }
}
