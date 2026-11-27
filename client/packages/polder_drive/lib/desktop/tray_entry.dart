import "dart:async";

import "package:flutter/widgets.dart";

/// An app-specific item in the [SyncTray] menu.
class TrayEntry {
  const TrayEntry({required this.label, required this.onSelected, this.needsAccount = true, this.isEnabled});

  /// Read again whenever the tray refreshes, so it may depend on app state.
  final String Function(BuildContext context) label;
  final FutureOr<void> Function() onSelected;

  /// Greyed out while nobody is signed in.
  final bool needsAccount;

  /// Extra condition on top of [needsAccount], read on every refresh.
  final bool Function()? isEnabled;
}
