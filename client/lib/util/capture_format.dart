import "package:intl/intl.dart";

import "package:polder/models/file_entry.dart";

abstract final class CaptureFormat {
  static const _bitrateUnits = ["bps", "kbps", "Mbps", "Gbps"];

  static String? camera(FileEntry entry) {
    final make = entry.cameraMake;
    final model = entry.cameraModel;
    if (make == null || model == null) return model ?? make;
    final brand = make.split(" ").first.toLowerCase();
    return model.toLowerCase().startsWith(brand) ? model : "$make $model";
  }

  static String aperture(double value, {String? locale}) => "ƒ/${NumberFormat("0.#", locale).format(value)}";

  static String exposureTime(double seconds, {String? locale}) {
    if (seconds >= 1) return "${NumberFormat("0.#", locale).format(seconds)} s";
    return "1/${(1 / seconds).round()} s";
  }

  static String focalLength(double millimeters, {String? locale}) =>
      "${NumberFormat("0.#", locale).format(millimeters)} mm";

  static String coordinates(double latitude, double longitude, {String? locale}) {
    final format = NumberFormat("0.00000", locale);
    return "${format.format(latitude)}, ${format.format(longitude)}";
  }

  static String mapUrl(double latitude, double longitude) =>
      "https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude";

  static String frameRate(double framesPerSecond, {String? locale}) =>
      "${NumberFormat("0.##", locale).format(framesPerSecond)} fps";

  static String bitrate(int bitsPerSecond, {String? locale}) {
    var value = bitsPerSecond.toDouble();
    var unit = 0;
    while (value >= 1000 && unit < _bitrateUnits.length - 1) {
      value /= 1000;
      unit++;
    }
    return "${NumberFormat(value >= 100 ? "0" : "0.#", locale).format(value)} ${_bitrateUnits[unit]}";
  }
}
