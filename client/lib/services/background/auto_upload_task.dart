import "package:flutter/widgets.dart";

import "package:workmanager/workmanager.dart";

import "package:polder/models/account.dart";
import "package:polder/models/sync/sync_root.dart";
import "package:polder/services/api/api_client_factory.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/api/stored_auth_session.dart";
import "package:polder/services/storage/credentials_store.dart";
import "package:polder/services/storage/preferences_store.dart";
import "package:polder/services/sync/drift/drift_sync_state_store.dart";
import "package:polder/services/sync/native_sync_platform.dart";
import "package:polder/services/sync/sync_engine.dart";
import "package:polder/services/sync/sync_pause.dart";
import "package:polder/services/sync/sync_state_store.dart";
import "package:polder/util/device_name.dart";

@pragma("vm:entry-point")
void autoUploadCallbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((_, _) async {
    await AutoUploadTask(credentials: platformCredentialsStore()).run();
    return true;
  });
}

class AutoUploadTask {
  const AutoUploadTask({required this.credentials});

  final CredentialsStore credentials;

  Future<void> run() async {
    final store = DriftSyncStateStore(NativeSyncPlatform.openDatabase());
    try {
      final account = await credentials.load();
      if (account == null || await SyncPause.read(SharedPreferencesStore())) return;
      final engine = _engineFor(account, store, await DeviceName.resolve());
      for (final root in await _autoUploadRoots(store)) {
        if (root.accountId == account.id) await engine.run(root);
      }
    } finally {
      await store.close();
    }
  }

  Future<List<SyncRoot>> _autoUploadRoots(SyncStateStore store) async =>
      (await store.roots()).where((root) => root.enabled && root.mode == SyncMode.autoUpload).toList();

  SyncEngine _engineFor(Account account, SyncStateStore store, String deviceName) {
    final session = StoredAuthSession(store: credentials, accountId: account.id, accessToken: account.accessToken);
    final api = PolderApi(ApiClientFactory.create(account.serverUrl, session: session, deviceName: deviceName));
    return SyncEngine(api: api, store: store, deviceName: deviceName);
  }
}
