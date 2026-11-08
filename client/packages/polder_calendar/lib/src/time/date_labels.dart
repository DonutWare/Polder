import "package:intl/intl.dart";

extension StandaloneDateFormat on DateFormat {
  String formatStandalone(DateTime date) => capitalizeFirst(format(date));
}

String capitalizeFirst(String text) => text.isEmpty ? text : "${text[0].toUpperCase()}${text.substring(1)}";
