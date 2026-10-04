extension NumExtensions on num {
  String shortenToNearestNumber() {
    final value = this;
    if (value > 1000) {
      return "${(value / 1000).floor()}k+";
    } else if (value > 100) {
      return "${(value / 100).floor() * 100}+";
    } else {
      return "$value";
    }
  }
}
