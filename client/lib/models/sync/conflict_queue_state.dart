import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/sync/conflict.dart";

part "conflict_queue_state.freezed.dart";

@freezed
abstract class ConflictQueueState with _$ConflictQueueState {
  const ConflictQueueState._();

  const factory ConflictQueueState({
    @Default(<Conflict>[]) List<Conflict> conflicts,
    @Default(<String>{}) Set<String> resolving,
    @Default(false) bool applyToAll,
    Object? lastError,
  }) = _ConflictQueueState;

  bool get isEmpty => conflicts.isEmpty;

  bool isResolving(Conflict conflict) => resolving.contains(conflict.id);

  Set<String> pausedPaths(String rootId) => {
    for (final conflict in conflicts)
      if (conflict.syncRootId == rootId) conflict.relativePath,
  };
}
