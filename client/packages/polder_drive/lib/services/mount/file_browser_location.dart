import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "package:polder_core/models/account.dart";
import "package:polder_core/models/token_pair.dart";

bool get usesFilesApp => defaultTargetPlatform == TargetPlatform.android;

String get fileBrowserName => usesFilesApp ? "Files" : "Finder";

typedef FileBrowserSession = ({String serverUrl, String refreshToken});

abstract interface class FileBrowserLocation {
  Stream<bool?> watchEnabled();

  Stream<bool> watchHandedOff();

  Future<String?> connectedAccount();

  Future<FileBrowserSession?> connect(Account account, TokenPair session, {required String deviceName});

  Future<FileBrowserSession?> disconnect();

  Future<void> signal();
}

class ChannelFileBrowserLocation implements FileBrowserLocation {
  const ChannelFileBrowserLocation();

  static const _channel = MethodChannel("polder/file_browser");
  static final StreamController<void> _changes = StreamController.broadcast(
    onListen: () => _channel.setMethodCallHandler((call) async {
      if (call.method == "changed") _changes.add(null);
    }),
  );

  @override
  Stream<bool?> watchEnabled() => _watch(() => _ask("enabled"));

  @override
  Stream<bool> watchHandedOff() => _watch(() async => await _ask("handedOff") ?? false);

  static Stream<T> _watch<T>(Future<T> Function() read) async* {
    final changes = StreamIterator(_changes.stream);
    try {
      do {
        yield await read();
      } while (await changes.moveNext());
    } finally {
      await changes.cancel();
    }
  }

  static Future<bool?> _ask(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<String?> connectedAccount() => _channel.invokeMethod<String>("connectedAccount");

  @override
  Future<FileBrowserSession?> connect(Account account, TokenPair session, {required String deviceName}) async =>
      _session(
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
  Future<FileBrowserSession?> disconnect() async => _session(await _channel.invokeMethod<Object?>("disconnect"));

  @override
  Future<void> signal() => _channel.invokeMethod<void>("signal");

  static FileBrowserSession? _session(Object? value) => switch (value) {
    {"serverUrl": final String serverUrl, "refreshToken": final String refreshToken} => (
      serverUrl: serverUrl,
      refreshToken: refreshToken,
    ),
    _ => null,
  };
}
