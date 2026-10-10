import "dart:async";

import "package:flutter/services.dart";

import "package:polder/models/account.dart";
import "package:polder/models/token_pair.dart";

typedef FinderSession = ({String serverUrl, String refreshToken});

abstract interface class FinderLocation {
  Stream<bool?> watchEnabled();

  Future<String?> connectedAccount();

  Future<FinderSession?> connect(Account account, TokenPair session, {required String deviceName});

  Future<FinderSession?> disconnect();

  Future<void> signal();
}

class ChannelFinderLocation implements FinderLocation {
  const ChannelFinderLocation();

  static const _channel = MethodChannel("polder/finder");
  static final StreamController<void> _changes = StreamController.broadcast(
    onListen: () => _channel.setMethodCallHandler((call) async {
      if (call.method == "changed") _changes.add(null);
    }),
  );

  @override
  Stream<bool?> watchEnabled() async* {
    final changes = StreamIterator(_changes.stream);
    try {
      do {
        yield await _enabled();
      } while (await changes.moveNext());
    } finally {
      await changes.cancel();
    }
  }

  Future<bool?> _enabled() async {
    try {
      return await _channel.invokeMethod<bool>("enabled");
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<String?> connectedAccount() => _channel.invokeMethod<String>("connectedAccount");

  @override
  Future<FinderSession?> connect(Account account, TokenPair session, {required String deviceName}) async => _session(
    await _channel.invokeMethod<Object?>("connect", {
      "accountId": account.id,
      "serverUrl": account.serverUrl,
      "displayName": account.handle,
      "deviceName": deviceName,
      "accessToken": session.accessToken,
      "refreshToken": session.refreshToken,
    }),
  );

  @override
  Future<FinderSession?> disconnect() async => _session(await _channel.invokeMethod<Object?>("disconnect"));

  @override
  Future<void> signal() => _channel.invokeMethod<void>("signal");

  static FinderSession? _session(Object? value) => switch (value) {
    {"serverUrl": final String serverUrl, "refreshToken": final String refreshToken} => (
      serverUrl: serverUrl,
      refreshToken: refreshToken,
    ),
    _ => null,
  };
}
