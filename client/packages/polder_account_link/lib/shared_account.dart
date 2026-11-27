import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "package:polder_account_link/shared_account_platform.dart";

class SharedAccount {
  const SharedAccount(this.namespace);

  final String namespace;

  static bool get isSupported =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.linux ||
        TargetPlatform.windows => true,
        TargetPlatform.fuchsia => false,
      };

  SharedAccountPlatform get _platform => SharedAccountPlatform.instance;

  Future<String?> read() => _platform.read(namespace);

  Future<void> write({required String name, required String json}) =>
      _platform.write(namespace, name: name, json: json);

  Future<void> remove() => _platform.remove(namespace);

  Stream<void> get changes {
    AppLifecycleListener? lifecycle;
    StreamSubscription<void>? native;
    late final StreamController<void> controller;
    controller = StreamController<void>.broadcast(
      onListen: () {
        lifecycle = AppLifecycleListener(onResume: () => controller.add(null));
        native = _platform.changes(namespace).listen(controller.add, onError: (Object _) {});
      },
      onCancel: () async {
        lifecycle?.dispose();
        await native?.cancel();
      },
    );
    return controller.stream;
  }
}
