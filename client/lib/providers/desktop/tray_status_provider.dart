import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:nomad/models/sync/sync_status.dart";
import "package:nomad/providers/account_provider.dart";
import "package:nomad/providers/sync/sync_activity_provider.dart";
import "package:nomad/providers/sync/sync_paused_provider.dart";
import "package:nomad/providers/sync/sync_status_provider.dart";
import "package:nomad/services/sync/sync_activity.dart";

enum TrayPhase { signedOut, idle, syncing, paused, error }

class TrayStatus {
  const TrayStatus(this.phase, {this.files = 0, this.uploadRate = 0, this.downloadRate = 0});

  final TrayPhase phase;
  final int files;
  final int uploadRate;
  final int downloadRate;

  bool get isSyncing => phase == TrayPhase.syncing;

  @override
  bool operator ==(Object other) =>
      other is TrayStatus &&
      other.phase == phase &&
      other.files == files &&
      other.uploadRate == uploadRate &&
      other.downloadRate == downloadRate;

  @override
  int get hashCode => Object.hash(phase, files, uploadRate, downloadRate);
}

final trayStatusProvider = Provider<TrayStatus>((ref) {
  if (ref.watch(currentAccountProvider.select((account) => account == null))) {
    return const TrayStatus(TrayPhase.signedOut);
  }
  if (ref.watch(syncPausedProvider).value ?? false) return const TrayStatus(TrayPhase.paused);
  final phase = ref.watch(syncStatusProvider.select((status) => status.phase));
  final items = ref.watch(localSyncItemsProvider).values;
  if (phase == SyncPhase.syncing || items.any((item) => item.phase != LocalSyncPhase.waiting)) {
    final activity = ref.read(syncActivityProvider);
    return TrayStatus(
      TrayPhase.syncing,
      files: items.length,
      uploadRate: activity.uploadRate,
      downloadRate: activity.downloadRate,
    );
  }
  return TrayStatus(phase == SyncPhase.error ? TrayPhase.error : TrayPhase.idle);
});
