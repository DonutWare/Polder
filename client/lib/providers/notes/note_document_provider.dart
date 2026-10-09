import "dart:async";
import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/notes/file_links_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notes/note_drafts.dart";
import "package:polder/services/notes/note_link.dart";
import "package:polder/util/remote_path.dart";

enum NoteSaveState { saved, unsaved, saving, conflict, failed }

class NoteDocument {
  const NoteDocument({
    required this.entry,
    required this.text,
    required this.savedText,
    this.editable = true,
    this.state = NoteSaveState.saved,
    this.conflict,
    this.draft,
  });

  final FileEntry entry;
  final String text;
  final String savedText;

  final bool editable;
  final NoteSaveState state;

  final FileEntry? conflict;

  final NoteDraft? draft;

  bool get dirty => text != savedText;

  NoteDocument copyWith({
    FileEntry? entry,
    String? text,
    String? savedText,
    NoteSaveState? state,
    FileEntry? Function()? conflict,
    NoteDraft? Function()? draft,
  }) => NoteDocument(
    entry: entry ?? this.entry,
    text: text ?? this.text,
    savedText: savedText ?? this.savedText,
    editable: editable,
    state: state ?? this.state,
    conflict: conflict != null ? conflict() : this.conflict,
    draft: draft != null ? draft() : this.draft,
  );
}

final noteDocumentProvider = AsyncNotifierProvider.autoDispose.family<NoteDocumentNotifier, NoteDocument, String>(
  NoteDocumentNotifier.new,
);

class NoteDocumentNotifier extends AsyncNotifier<NoteDocument> {
  NoteDocumentNotifier(this.path);

  static const checkpointInterval = Duration(minutes: 5);
  static const draftDelay = Duration(seconds: 2);

  final String path;
  late PolderApi _api;
  late NoteDrafts _drafts;
  Timer? _checkpoint;
  Timer? _draftTimer;
  Future<void>? _saving;
  NoteDocument? _latest;

  NoteDocument get _document => state.requireValue;

  @override
  Future<NoteDocument> build() async {
    _api = ref.watch(polderApiProvider);
    _drafts = NoteDrafts(ref.read(preferencesStoreProvider));
    ref.onDispose(_close);
    listenSelf((_, next) => _latest = next.value ?? _latest);
    ref.listen(filesChangedProvider, (_, next) {
      final dirs = next.value;
      if (dirs != null && state.hasValue && dirs.contains(RemotePath.parent(_document.entry.path))) {
        unawaited(checkRemote());
      }
    });

    final entry = await _api.stat(path);
    final (text, editable) = _decode(await _api.downloadBytes(entry.path));
    final draft = await _drafts.read(entry);
    unawaited(Future(_followLinkedFiles));
    return NoteDocument(
      entry: entry,
      text: text,
      savedText: text,
      editable: editable,
      draft: draft != null && draft.text != text ? draft : null,
    );
  }

  Future<void> _followLinkedFiles() async {
    final document = state.value;
    if (document == null || !document.editable || document.dirty || document.draft != null) return;
    if (document.state == NoteSaveState.conflict || _saving != null) return;
    final updated = await _updateLinks(document.text, document.entry.path);
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
    state = AsyncData(
      next.copyWith(
        state: next.state == NoteSaveState.conflict
            ? NoteSaveState.conflict
            : (dirty ? NoteSaveState.unsaved : NoteSaveState.saved),
      ),
    );
    if (dirty) {
      _checkpoint ??= Timer(checkpointInterval, () => unawaited(save()));
      _draftTimer?.cancel();
      _draftTimer = Timer(draftDelay, () => unawaited(_writeDraft()));
    } else {
      _checkpoint?.cancel();
      _checkpoint = null;
      _draftTimer?.cancel();
      unawaited(_drafts.remove(next.entry));
    }
  }

  Future<void> _writeDraft() async {
    final document = state.value;
    if (document == null || !document.dirty) return;
    await _drafts.write(document.entry, document.text);
  }

  Future<void> save() => _saving ??= _save().whenComplete(() => _saving = null);

  Future<void> _save() async {
    _checkpoint?.cancel();
    _checkpoint = null;
    var document = state.value;
    if (document == null || !document.dirty || document.state == NoteSaveState.conflict) return;
    state = AsyncData(document.copyWith(state: NoteSaveState.saving));
    try {
      final relinked = await _updateLinks(document.text, document.entry.path);
      if (!ref.mounted) return;
      if (relinked != document.text) {
        _apply(state.requireValue.copyWith(text: relinked));
        document = state.requireValue;
      }
      final saved = await _write(document.entry, document.text, savedText: document.savedText);
      if (!ref.mounted) return;
      final current = state.requireValue;
      state = AsyncData(
        current.copyWith(
          entry: saved,
          savedText: document.text,
          state: current.text == document.text ? NoteSaveState.saved : NoteSaveState.unsaved,
        ),
      );
      if (current.text == document.text) await _drafts.remove(saved);
      _refreshAround(saved);
    } on ConflictException catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(state.requireValue.copyWith(state: NoteSaveState.conflict, conflict: () => error.current));
    } on ApiException {
      if (!ref.mounted) return;
      state = AsyncData(state.requireValue.copyWith(state: NoteSaveState.failed));
      _checkpoint ??= Timer(checkpointInterval, () => unawaited(save()));
    }
  }

  Future<FileEntry> _write(FileEntry entry, String text, {required String savedText}) async {
    try {
      return await _put(entry.path, text, entry.rev);
    } on ConflictException catch (error) {
      final current = error.current ?? (await _api.filesById([entry.id])).firstOrNull;
      if (current == null) rethrow;
      if (current.hash != entry.hash && !await _onlyLinksChanged(current, savedText)) rethrow;
      return _put(current.path, text, current.rev);
    }
  }

  Future<bool> _onlyLinksChanged(FileEntry current, String savedText) async {
    final theirs = utf8.decode(await _api.downloadBytes(current.path), allowMalformed: true);
    return theirs == await _updateLinks(savedText, current.path);
  }

  Future<FileEntry> _put(String path, String text, int baseRev) {
    final bytes = utf8.encode(text);
    return _api.putContent(path, Stream.value(bytes), length: bytes.length, baseRev: baseRev);
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
    if (document == null || _saving != null) return;
    final FileEntry current;
    try {
      current = (await _api.filesById([document.entry.id])).firstOrNull ?? await _api.stat(document.entry.path);
    } on ApiException {
      return;
    }
    if (!ref.mounted) return;
    final latest = state.requireValue;
    if (current.hash != latest.entry.hash) {
      if (!latest.dirty) await _reloadFrom(current);
    } else if (current.path != latest.entry.path) {
      state = AsyncData(latest.copyWith(entry: current));
    }
  }

  Future<void> _reloadFrom(FileEntry current) async {
    final (text, _) = _decode(await _api.downloadBytes(current.path));
    if (!ref.mounted) return;
    _apply(
      state.requireValue.copyWith(
        entry: current,
        text: text,
        savedText: text,
        state: NoteSaveState.saved,
        conflict: () => null,
      ),
    );
  }

  Future<void> takeTheirs() async {
    final document = state.requireValue;
    final current = document.conflict ?? await _api.stat(document.entry.path);
    if (ref.mounted) await _reloadFrom(current);
  }

  Future<void> keepMine() async {
    final document = state.requireValue;
    final target = document.conflict ?? document.entry;
    state = AsyncData(document.copyWith(state: NoteSaveState.unsaved, entry: target, conflict: () => null));
    await save();
  }

  Future<FileEntry> saveMineAsCopy(String name) async {
    final document = state.requireValue;
    final copy = await _put(RemotePath.join(RemotePath.parent(document.entry.path), name), document.text, 0);
    if (ref.mounted) await takeTheirs();
    return copy;
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
    _checkpoint?.cancel();
    _draftTimer?.cancel();
    final document = _latest;
    if (document == null || !document.dirty || document.state == NoteSaveState.conflict) return;
    final drafts = _drafts;
    final entry = document.entry;
    final text = document.text;
    final savedText = document.savedText;
    unawaited(() async {
      await drafts.write(entry, text);
      if (await _reachesServer(entry, text, savedText)) await drafts.remove(entry);
    }());
  }

  Future<bool> _reachesServer(FileEntry entry, String text, String savedText) async {
    try {
      await _write(entry, text, savedText: savedText);
      return true;
    } on ApiException {
      return false;
    }
  }
}
