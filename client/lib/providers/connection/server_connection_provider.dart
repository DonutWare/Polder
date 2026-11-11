import "dart:async";
import "dart:math";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/server_connection.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/realtime/events_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/realtime/events_client.dart";

final serverConnectionProvider = NotifierProvider<ServerConnectionNotifier, ServerConnection>(
  ServerConnectionNotifier.new,
);

class ServerConnectionNotifier extends Notifier<ServerConnection> {
  static const onlineCheckInterval = Duration(minutes: 1);
  static const firstRetryDelay = Duration(seconds: 2);
  static const maxRetryDelay = Duration(seconds: 30);

  Timer? _timer;
  Future<void>? _probing;
  var _failedProbes = 0;
  var _hasNetwork = true;

  @override
  ServerConnection build() {
    final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
    ref.onDispose(_stopTimer);
    if (accountId == null) return const ServerConnection();
    _listenToNetwork();
    ref.listen(realtimeStatusProvider, (_, next) => _onRealtime(next.value));
    unawaited(Future.microtask(check));
    return const ServerConnection();
  }

  Future<void> check() => _probing ??= _probe().whenComplete(() => _probing = null);

  void report({required bool reachable}) {
    if (!ref.mounted) return;
    if (reachable && !state.isOnline) unawaited(check());
    if (!reachable && !state.isOffline) unawaited(check());
  }

  void _listenToNetwork() {
    final conditions = ref.read(deviceConditionsProvider);
    final subscription = conditions.networkChanges().listen(_onNetwork);
    ref.onDispose(subscription.cancel);
    unawaited(conditions.hasNetwork().then(_onNetwork));
  }

  void _onNetwork(bool available) {
    if (!ref.mounted || available == _hasNetwork) return;
    _hasNetwork = available;
    if (available) {
      _failedProbes = 0;
      unawaited(check());
    } else {
      _stopTimer();
      state = state.offline(OfflineCause.noNetwork);
    }
  }

  void _onRealtime(RealtimeStatus? status) {
    if (status == RealtimeStatus.connected && !state.isOnline) unawaited(check());
    if (status == RealtimeStatus.offline && state.isOnline) unawaited(check());
  }

  Future<void> _probe() async {
    _stopTimer();
    if (!_hasNetwork) return;
    try {
      final health = await ref.read(polderApiProvider).health();
      if (!ref.mounted) return;
      _failedProbes = 0;
      state = ServerConnection(reachability: ServerReachability.online, storage: health.storage);
      _schedule(onlineCheckInterval);
    } on Object {
      if (!ref.mounted) return;
      _failedProbes++;
      state = state.offline(_hasNetwork ? OfflineCause.serverUnreachable : OfflineCause.noNetwork);
      _schedule(_retryDelay());
    }
  }

  Duration _retryDelay() {
    final seconds = firstRetryDelay.inSeconds * pow(2, min(_failedProbes - 1, 5));
    return Duration(seconds: min(seconds.toInt(), maxRetryDelay.inSeconds));
  }

  void _schedule(Duration delay) {
    _stopTimer();
    _timer = Timer(delay, () => unawaited(check()));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
