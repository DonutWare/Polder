import "package:flutter_riverpod/flutter_riverpod.dart";

enum BrowserViewMode { list, grid }

final browserViewModeProvider = NotifierProvider<BrowserViewModeNotifier, BrowserViewMode>(BrowserViewModeNotifier.new);

class BrowserViewModeNotifier extends Notifier<BrowserViewMode> {
  @override
  BrowserViewMode build() => BrowserViewMode.list;

  void toggle() => state = state == BrowserViewMode.list ? BrowserViewMode.grid : BrowserViewMode.list;
}
