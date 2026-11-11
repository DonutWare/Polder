import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/offline_models.dart";
import "package:polder/models/sync/conflict.dart";
import "package:polder/models/sync/local_file_state.dart";
import "package:polder/models/sync/conflict_queue_state.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/providers/sync/sync_roots_provider.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/calendar/offline_calendar_source.dart";
import "package:polder/services/offline/offline_store.dart";

final conflictQueueProvider = NotifierProvider<ConflictQueueNotifier, ConflictQueueState>(ConflictQueueNotifier.new);

class ConflictQueueNotifier extends Notifier<ConflictQueueState> {
  @override
  ConflictQueueState build() {
    final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
    if (accountId != null) followOfflineStore(ref, _replaceOffline);
    return const ConflictQueueState();
  }

  Future<void> _replaceOffline(OfflineStore store) async {
    final offline = [
      for (final file in await store.unsyncedFiles())
        if (file.state == OfflineFileState.conflict) offlineConflictOf(file),
      for (final entry in await store.outbox(OutboxDomain.calendar))
        if (entry.error?.kind == OutboxErrorKind.conflict)
          Conflict(
            syncRootId: Conflict.calendarRoot,
            relativePath: "${entry.id}/${OfflineCalendarSource.summaryOf(entry)}",
            kind: ConflictKind.bothModified,
          ),
    ];
    if (!ref.mounted) return;
    state = state.copyWith(
      conflicts: [...state.conflicts.where((conflict) => !conflict.fromOffline && !conflict.fromCalendar), ...offline],
    );
  }

  static Conflict offlineConflictOf(OfflineFile file) {
    final conflict = file.conflict;
    final server = conflict?.server;
    return Conflict(
      syncRootId: Conflict.offlineRoot,
      relativePath: file.path,
      kind: switch ((conflict?.deletedHere ?? false, server)) {
        (true, _) => ConflictKind.localDeletedRemoteModified,
        (false, null) => ConflictKind.localModifiedRemoteDeleted,
        _ when file.baseRev == 0 => ConflictKind.bothCreated,
        _ => ConflictKind.bothModified,
      },
      local: (conflict?.deletedHere ?? false)
          ? null
          : LocalFileState(
              relativePath: file.path,
              isDir: file.isDir,
              size: file.entry.size,
              mtime: file.entry.mtime,
              hash: file.localHash ?? "",
            ),
      remote: server,
    );
  }

  void enqueue(Iterable<Conflict> conflicts) {
    final incoming = {for (final conflict in conflicts) conflict.id: conflict};
    final kept = state.conflicts.where((existing) => !incoming.containsKey(existing.id));
    state = state.copyWith(conflicts: [...kept, ...incoming.values]);
  }

  void setApplyToAll(bool applyToAll) => state = state.copyWith(applyToAll: applyToAll);

  Future<void> choose(Conflict conflict, ConflictResolution resolution) =>
      state.applyToAll ? resolveAll(resolution) : resolve(conflict, resolution);

  Future<void> resolveAll(ConflictResolution resolution) async {
    for (final conflict in [...state.conflicts]) {
      await resolve(conflict, resolution);
    }
  }

  Future<void> resolve(Conflict conflict, ConflictResolution resolution) async {
    if (conflict.fromOffline || conflict.fromCalendar) return _resolveOffline(conflict, resolution);
    final root = await _rootOf(conflict);
    if (root == null) return _drop(conflict);
    _markResolving(conflict, true);
    try {
      final service = await ref.read(syncServiceProvider.future);
      await service.resolve(root, conflict, resolution);
      _drop(conflict);
    } on ConflictException catch (error) {
      enqueue([conflict.copyWith(remote: error.current)]);
      state = state.copyWith(lastError: error);
    } on Exception catch (error) {
      state = state.copyWith(lastError: error);
    } finally {
      _markResolving(conflict, false);
    }
  }

  Future<void> _resolveOffline(Conflict conflict, ConflictResolution resolution) async {
    _markResolving(conflict, true);
    try {
      if (conflict.calendarEntryId case final id?) {
        await ref.read(offlineCalendarSourceProvider)?.resolve(id, resolution);
      } else {
        final files = await ref.read(offlineFilesProvider.future);
        await files.resolve(conflict.relativePath, resolution);
      }
      _drop(conflict);
    } on Exception catch (error) {
      state = state.copyWith(lastError: error);
    } finally {
      _markResolving(conflict, false);
    }
  }

  Future<SyncRoot?> _rootOf(Conflict conflict) async =>
      (await ref.read(syncRootsProvider.future)).where((root) => root.id == conflict.syncRootId).firstOrNull;

  void _drop(Conflict conflict) =>
      state = state.copyWith(conflicts: state.conflicts.where((existing) => existing.id != conflict.id).toList());

  void _markResolving(Conflict conflict, bool resolving) => state = state.copyWith(
    resolving: resolving ? {...state.resolving, conflict.id} : ({...state.resolving}..remove(conflict.id)),
  );
}
