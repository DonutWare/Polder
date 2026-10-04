import "package:intl/intl.dart";

abstract final class ByteFormat {
  static const _units = ["B", "KB", "MB", "GB", "TB", "PB"];

  static String format(int bytes, {String? locale}) {
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < _units.length - 1) {
      value /= 1024;
      unit++;
    }
    final pattern = unit == 0 || value >= 100 ? "0" : "0.#";
    return "${NumberFormat(pattern, locale).format(value)} ${_units[unit]}";
  }

  static String rate(int bytesPerSecond, {String? locale}) => "${format(bytesPerSecond, locale: locale)}/s";
}
