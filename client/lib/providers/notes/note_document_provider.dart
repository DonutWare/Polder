import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/offline/offline_sync_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_drafts.dart";
import "package:polder/services/notes/note_link.dart";
import "package:polder/services/offline/offline_files.dart";
import "package:polder/util/remote_path.dart";

enum NoteSaveState { saved, unsaved, saving, pending, conflict, failed }

class NoteDocument {
  const NoteDocument({
    required this.entry,
    required this.text,
    required this.savedText,
    this.editable = true,
    this.state = NoteSaveState.saved,
    this.conflict,
    this.draft,
    this.saveError,
  });

  final FileEntry entry;
  final String text;
  final String savedText;

  final bool editable;
  final NoteSaveState state;

  final FileEntry? conflict;

  final NoteDraft? draft;

  final Object? saveError;

  bool get dirty => text != savedText;

  NoteDocument copyWith({
    FileEntry? entry,
    String? text,
    String? savedText,
    NoteSaveState? state,
    FileEntry? Function()? conflict,
    NoteDraft? Function()? draft,
    Object? saveError,
  }) => NoteDocument(
    entry: entry ?? this.entry,
    text: text ?? this.text,
    savedText: savedText ?? this.savedText,
    editable: editable,
    state: state ?? this.state,
    conflict: conflict != null ? conflict() : this.conflict,
    draft: draft != null ? draft() : this.draft,
    saveError: (state ?? this.state) == NoteSaveState.failed ? saveError ?? this.saveError : null,
  );
}

final noteDocumentProvider = AsyncNotifierProvider.autoDispose.family<NoteDocumentNotifier, NoteDocument, String>(
  NoteDocumentNotifier.new,
);

class NoteDocumentNotifier extends AsyncNotifier<NoteDocument> {
  NoteDocumentNotifier(this.path);

  static const saveDelay = Duration(milliseconds: 800);

  final String path;
  late PolderApi _api;
  late OfflineFiles _files;
  late NoteDrafts _drafts;
  Timer? _saveTimer;
  Future<void>? _saving;
  NoteDocument? _latest;
  String? _shownHash;

  NoteDocument get _document => state.requireValue;

  @override
  Future<NoteDocument> build() async {
    _api = ref.watch(polderApiProvider);
    _files = await ref.watch(offlineFilesProvider.future);
    _drafts = NoteDrafts(ref.read(preferencesStoreProvider));
    ref.onDispose(_close);
    listenSelf((_, next) => _latest = next.value ?? _latest);
    final subscription = _files.changes.listen((_) => unawaited(_followStore()));
    ref.onDispose(subscription.cancel);

    final row = await _load();
    final bytes = await _files.read(row.path) ?? Uint8List(0);
    final (text, editable) = _decode(bytes);
    _shownHash = row.localHash;
    final draft = await _drafts.read(row.entry);
    unawaited(Future(_followLinkedFiles));
    return _withSyncState(
      NoteDocument(
        entry: row.entry,
        text: text,
        savedText: text,
        editable: editable,
        draft: draft != null && draft.text != text ? draft : null,
      ),
      row,
    );
  }

  Future<OfflineFile> _load() async {
    final cached = await _files.file(path);
    final trusted = cached != null && (cached.unsynced || await _files.availableOffline(path));
    if (trusted && cached.hasCurrentContent) return cached;
    try {
      return await _files.fetch(path);
    } on ApiException {
      if (cached != null && cached.localHash != null) return cached;
      rethrow;
    }
  }

  NoteDocument _withSyncState(NoteDocument document, OfflineFile row) {
    final syncState = switch (row.state) {
      OfflineFileState.synced => NoteSaveState.saved,
      OfflineFileState.pending => NoteSaveState.pending,
      OfflineFileState.failed => NoteSaveState.failed,
      OfflineFileState.conflict => NoteSaveState.conflict,
    };
    final keepsLocalState = document.state == NoteSaveState.unsaved || document.state == NoteSaveState.saving;
    return document.copyWith(
      entry: document.entry.path == row.path ? row.entry : document.entry,
      state: keepsLocalState && syncState != NoteSaveState.conflict ? document.state : syncState,
      conflict: () => row.conflict?.server,
      saveError: row.error,
    );
  }

  Future<void> _followStore() async {
    final document = state.value;
    if (document == null || !ref.mounted) return;
    final row = await _files.file(document.entry.path);
    if (row == null || !ref.mounted) return;
    final latest = state.requireValue;
    if (row.hasCurrentContent && row.localHash != _shownHash && !latest.dirty && _saving == null) {
      final (text, _) = _decode(await _files.read(row.path) ?? Uint8List(0));
      if (!ref.mounted) return;
      final current = state.requireValue;
      if (current.dirty || _saving != null) {
        state = AsyncData(_withSyncState(current, row));
        return;
      }
      _shownHash = row.localHash;
      state = AsyncData(_withSyncState(current.copyWith(text: text, savedText: text), row));
      return;
    }
    state = AsyncData(_withSyncState(latest, row));
  }

  Future<void> _followLinkedFiles() async {
    final document = state.value;
    if (document == null || !document.editable || document.dirty || document.draft != null) return;
    if (document.state == NoteSaveState.conflict || _saving != null) return;
    final String updated;
    try {
      updated = await _updateLinks(document.text, document.entry.path);
    } on ApiException {
      return;
    }
    if (!ref.mounted || updated == document.text) return;
    final current = state.value;
    if (current == null || current.text != document.text || current.dirty) return;
    _apply(current.copyWith(text: updated));
    await save();
  }

  static (String, bool) _decode(List<int> bytes) {
    try {
      return (utf8.decode(bytes), true);
    } on FormatException {
      return (utf8.decode(bytes, allowMalformed: true), false);
    }
  }

  void edit(String text) {
    final document = state.value;
    if (document == null || !document.editable || text == document.text) return;
    _apply(document.copyWith(text: text));
  }

  void _apply(NoteDocument next) {
    final dirty = next.text != next.savedText;
    final conflicted = next.state == NoteSaveState.conflict;
    state = AsyncData(
      next.copyWith(state: conflicted ? NoteSaveState.conflict : (dirty ? NoteSaveState.unsaved : next.state)),
    );
    _saveTimer?.cancel();
    if (dirty) _saveTimer = Timer(saveDelay, () => unawaited(save()));
  }

  Future<void> save() => _saving ??= _save().whenComplete(() => _saving = null);

  Future<void> _save() async {
    _saveTimer?.cancel();
    final document = state.value;
    if (document == null || !document.dirty) return;
    if (document.state != NoteSaveState.conflict) state = AsyncData(document.copyWith(state: NoteSaveState.saving));
    try {
      final row = await _files.write(document.entry.path, Uint8List.fromList(utf8.encode(document.text)));
      _shownHash = row.localHash;
      unawaited(_drafts.remove(document.entry));
      if (!ref.mounted) return;
      final current = state.requireValue;
      final next = current.copyWith(savedText: document.text, state: NoteSaveState.pending);
      state = AsyncData(
        current.text == document.text ? _withSyncState(next, row) : next.copyWith(state: NoteSaveState.unsaved),
      );
      if (current.text != document.text) _saveTimer = Timer(saveDelay, () => unawaited(save()));
      _refreshAround(row.entry);
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(state.requireValue.copyWith(state: NoteSaveState.failed, saveError: error));
    }
  }

  Future<void> retrySync() async {
    await save();
    await ref.read(offlineSyncProvider.notifier).retryNow();
  }

  Future<String> _updateLinks(String text, String notePath) async {
    final ids = {
      for (final link in findSourceLinks(text)) ?NoteLink.parse(link.destination, notePath: notePath)?.fileId,
    };
    if (ids.isEmpty) return text;
    final current = {for (final entry in await _api.filesById(ids)) entry.id: entry};
    return updateLinks(text, notePath: notePath, current: current);
  }

  void _refreshAround(FileEntry saved) {
    ref.invalidate(fileLinksProvider);
    final parent = RemotePath.parent(saved.path);
    if (ref.exists(directoryProvider(parent))) unawaited(ref.read(directoryProvider(parent).notifier).refresh());
  }

  Future<void> checkRemote() async {
    final document = state.value;
    if (document == null || _saving != null || document.dirty) return;
    if (await _tryFetch(document.entry.path) == null) return;
    await _followStore();
  }

  Future<OfflineFile?> _tryFetch(String path) async {
    try {
      return await _files.fetch(path);
    } on ApiException {
      return null;
    }
  }

  Future<void> takeTheirs() async {
    final path = _document.entry.path;
    await _files.resolve(path, ConflictResolution.keepServer);
    await _reloadFromServer(path);
  }

  Future<void> keepMine() async {
    final path = _document.entry.path;
    await save();
    await _files.resolve(path, ConflictResolution.keepMine);
    await _followStore();
  }

  Future<void> saveMineAsCopy(String name) async {
    final path = _document.entry.path;
    await save();
    await _files.resolve(path, ConflictResolution.keepBoth, copyPath: RemotePath.join(RemotePath.parent(path), name));
    await _reloadFromServer(path);
  }

  Future<void> _reloadFromServer(String path) async {
    await _tryFetch(path);
    if (!ref.mounted) return;
    _shownHash = null;
    state = AsyncData(_document.copyWith(savedText: _document.text));
    await _followStore();
  }

  void recoverDraft() {
    final document = state.requireValue;
    final draft = document.draft;
    if (draft == null) return;
    _apply(document.copyWith(text: draft.text, draft: () => null));
  }

  void discardDraft() {
    final document = state.requireValue;
    unawaited(_drafts.remove(document.entry));
    state = AsyncData(document.copyWith(draft: () => null));
  }

  void _close() {
    _saveTimer?.cancel();
    final document = _latest;
    if (document == null || !document.dirty) return;
    unawaited(
      _files
          .write(document.entry.path, Uint8List.fromList(utf8.encode(document.text)))
          .then((_) {}, onError: (Object _) {}),
    );
  }
}
