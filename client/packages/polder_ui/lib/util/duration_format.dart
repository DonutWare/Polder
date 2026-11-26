extension ClockDuration on Duration {
  String get clock {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60).toString().padLeft(2, "0");
    return hours > 0 ? "$hours:${minutes.toString().padLeft(2, "0")}:$seconds" : "$minutes:$seconds";
  }
}
