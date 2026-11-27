import "package:material_ui/material_ui.dart";

class ScrollNudges extends ChangeNotifier {
  var _distance = 0.0;

  double get distance => _distance;

  void nudge(double distance) {
    _distance = distance;
    notifyListeners();
  }
}

extension NudgeScroll on ScrollController {
  void nudgeBy(double distance) {
    if (!hasClients) return;
    final target = (position.pixels + distance).clamp(position.minScrollExtent, position.maxScrollExtent);
    animateTo(target, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
  }
}
