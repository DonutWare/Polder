import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/conflict.dart";
import "package:nomad/models/sync/conflict_queue_state.dart";
import "package:nomad/models/sync/sync_root.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/sync/sync_platform_provider.dart";
import "package:nomad/providers/sync/sync_roots_provider.dart";
import "package:nomad/services/api/api_exceptions.dart";

final conflictQueueProvider = NotifierProvider<ConflictQueueNotifier, ConflictQueueState>(ConflictQueueNotifier.new);

class ConflictQueueNotifier extends Notifier<ConflictQueueState> {
  @override
  ConflictQueueState build() {
    ref.watch(currentAccountProvider.select((account) => account?.id));
    return const ConflictQueueState();
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

  Future<SyncRoot?> _rootOf(Conflict conflict) async =>
      (await ref.read(syncRootsProvider.future)).where((root) => root.id == conflict.syncRootId).firstOrNull;

  void _drop(Conflict conflict) =>
      state = state.copyWith(conflicts: state.conflicts.where((existing) => existing.id != conflict.id).toList());

  void _markResolving(Conflict conflict, bool resolving) => state = state.copyWith(
    resolving: resolving ? {...state.resolving, conflict.id} : ({...state.resolving}..remove(conflict.id)),
  );
}
