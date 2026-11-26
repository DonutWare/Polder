import "package:intl/intl.dart";

abstract final class ConflictFileName {
  static final _stamp = DateFormat("yyyy-MM-dd HHmm");

  static String build(String name, {required String device, required DateTime at}) {
    final suffix = " (conflict $device ${_stamp.format(at)})";
    final extensionStart = name.lastIndexOf(".");
    if (extensionStart <= 0) return "$name$suffix";
    return "${name.substring(0, extensionStart)}$suffix${name.substring(extensionStart)}";
  }
}
