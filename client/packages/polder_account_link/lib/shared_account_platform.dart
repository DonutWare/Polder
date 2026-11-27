import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

abstract class SharedAccountPlatform {
  static SharedAccountPlatform instance = MethodChannelSharedAccountPlatform();

  Future<String?> read(String namespace);

  Future<void> write(String namespace, {required String name, required String json});

  Future<void> remove(String namespace);

  Stream<void> changes(String namespace);
}

class MethodChannelSharedAccountPlatform extends SharedAccountPlatform {
  static const _methods = MethodChannel("polder/account_link");
  static const _events = EventChannel("polder/account_link/changes");

  static bool get _hasChangeEvents =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
        _ => false,
      };

  @override
  Future<String?> read(String namespace) => _methods.invokeMethod<String>("read", {"namespace": namespace});

  @override
  Future<void> write(String namespace, {required String name, required String json}) =>
      _methods.invokeMethod<void>("write", {"namespace": namespace, "name": name, "json": json});

  @override
  Future<void> remove(String namespace) => _methods.invokeMethod<void>("remove", {"namespace": namespace});

  @override
  Stream<void> changes(String namespace) =>
      _hasChangeEvents ? _events.receiveBroadcastStream(namespace).map((_) {}) : const Stream.empty();
}
