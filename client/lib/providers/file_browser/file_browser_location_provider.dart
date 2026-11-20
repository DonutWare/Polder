import "dart:async";

import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/files_changed_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/mount/file_browser_location.dart";

final fileBrowserLocationEnabledProvider = StreamProvider<bool?>(
  (ref) => ref.watch(fileBrowserLocationProvider)?.watchEnabled() ?? Stream.value(null),
);

final showInFileBrowserProvider = AsyncNotifierProvider<ShowInFileBrowserNotifier, bool>(ShowInFileBrowserNotifier.new);

class ShowInFileBrowserNotifier extends AsyncNotifier<bool> {
  static const _key = "polder.showInFinder";
  static const signalDelay = Duration(milliseconds: 500);

  Future<void> _pending = Future.value();

  @override
  Future<bool> build() async {
    final location = ref.watch(fileBrowserLocationProvider);
    if (location == null) return false;

    ref.listen(accountProvider.select((state) => state.hasValue ? (accountId: state.value?.id) : null), (_, next) {
      if (next != null) _follow(location);
    }, fireImmediately: true);

    Timer? signal;
    ref.listen(filesChangedProvider, (_, _) {
      signal?.cancel();
      signal = Timer(signalDelay, () => unawaited(location.signal()));
    });
    ref.onDispose(() => signal?.cancel());

    final stored = await ref.read(preferencesStoreProvider).readJson(_key);
    return stored?["shown"] as bool? ?? true;
  }

  Future<void> setShown(bool shown) async {
    final location = ref.read(fileBrowserLocationProvider);
    if (location == null) return;
    state = AsyncData(shown);
    await ref.read(preferencesStoreProvider).writeJson(_key, {"shown": shown});
    await _follow(location);
  }

  Future<void> _follow(FileBrowserLocation location) => _pending = _pending.then((_) => _apply(location));

  Future<void> _apply(FileBrowserLocation location) async {
    try {
      final shown = await future;
      final account = ref.read(accountProvider).value;
      if (account == null || !shown) return await _revoke(await location.disconnect());
      if (await location.connectedAccount() == account.id) return await location.signal();
      final deviceName = "${ref.read(deviceNameProvider)} ($fileBrowserName)";
      final session = await ref.read(polderApiProvider).startSession(deviceName: deviceName);
      await _revoke(await location.connect(account, session, deviceName: deviceName));
    } on PlatformException {
      return;
    } on ApiException {
      return;
    }
  }

  Future<void> _revoke(FileBrowserSession? session) async {
    if (session == null) return;
    await ref.read(serverPolderApiProvider(session.serverUrl)).logout(session.refreshToken);
  }
}
