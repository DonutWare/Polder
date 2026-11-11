import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/models/offline_models.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/calendar/calendar_providers.dart";
import "package:polder/providers/offline/offline_storage_provider.dart";
import "package:polder/providers/offline/offline_sync_provider.dart";
import "package:polder/services/calendar/offline_calendar_source.dart";
import "package:polder/services/offline/offline_store.dart";
import "package:polder/util/remote_path.dart";

enum OfflineChangeGroup { notes, files, calendar }

enum OfflineChangeKind { edited, deleted }

class OfflineChange {
  const OfflineChange({
    required this.group,
    required this.key,
    required this.title,
    required this.state,
    this.kind = OfflineChangeKind.edited,
    this.error,
  });

  final OfflineChangeGroup group;
  final String key;
  final String title;
  final OfflineFileState state;
  final OfflineChangeKind kind;
  final OutboxError? error;

  bool get failing => state == OfflineFileState.failed;

  bool get conflicted => state == OfflineFileState.conflict;
}

final offlineChangesProvider = NotifierProvider<OfflineChangesNotifier, List<OfflineChange>>(
  OfflineChangesNotifier.new,
);

class OfflineChangesNotifier extends Notifier<List<OfflineChange>> {
  @override
  List<OfflineChange> build() {
    final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
    if (accountId == null) return const [];
    followOfflineStore(ref, _refresh);
    return const [];
  }

  Future<void> _refresh(OfflineStore store) async {
    final changes = [...await fileChanges(store), ...await calendarChanges(store)];
    if (ref.mounted) state = changes;
  }
}

Future<List<OfflineChange>> fileChanges(OfflineStore store) async {
  final pins = await store.pins();
  final notesRoots = [
    for (final pin in pins)
      if (pin.kind == OfflinePinKind.notes) pin,
  ];
  OfflineChangeGroup groupOf(String path) =>
      notesRoots.any((pin) => pin.covers(path)) ? OfflineChangeGroup.notes : OfflineChangeGroup.files;
  final files = await store.unsyncedFiles();
  final known = {for (final file in files) file.path};
  return [
    for (final file in files)
      OfflineChange(
        group: groupOf(file.path),
        key: file.path,
        title: file.entry.isMarkdown ? file.entry.displayName : file.entry.name,
        state: file.state,
        error: file.error,
      ),
    for (final entry in await store.outbox(OutboxDomain.files))
      if (entry.op is DeleteOp && !known.contains(entry.path))
        OfflineChange(
          group: groupOf(entry.path),
          key: entry.path,
          title: RemotePath.name(entry.path),
          kind: OfflineChangeKind.deleted,
          state: entry.failing ? OfflineFileState.failed : OfflineFileState.pending,
          error: entry.error,
        ),
  ];
}

const calendarChangePrefix = "calendar:";

Future<List<OfflineChange>> calendarChanges(OfflineStore store) async => [
  for (final entry in await store.outbox(OutboxDomain.calendar))
    OfflineChange(
      group: OfflineChangeGroup.calendar,
      key: "$calendarChangePrefix${entry.id}",
      title: OfflineCalendarSource.summaryOf(entry),
      kind: (entry.op as CalendarOp).change["type"] == CalendarChangeType.delete.name
          ? OfflineChangeKind.deleted
          : OfflineChangeKind.edited,
      state: switch (entry.error?.kind) {
        null => OfflineFileState.pending,
        OutboxErrorKind.conflict => OfflineFileState.conflict,
        _ => OfflineFileState.failed,
      },
      error: entry.error,
    ),
];

Future<void> discardOfflineChange(WidgetRef ref, OfflineChange change) async {
  if (change.group != OfflineChangeGroup.calendar) {
    return (await ref.read(offlineFilesProvider.future)).discard(change.key);
  }
  final id = int.tryParse(change.key.substring(calendarChangePrefix.length));
  if (id != null) await ref.read(offlineCalendarSourceProvider)?.discard(id);
}

Future<void> retryOfflineChanges(WidgetRef ref) => ref.read(offlineSyncProvider.notifier).retryNow();
