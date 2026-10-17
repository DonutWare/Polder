import "package:flutter/widgets.dart";

import "package:intl/intl.dart";

import "package:polder/util/localization_helper.dart";

extension DateTimeFormatting on DateTime {
  String formatted(BuildContext context) => DateFormat.yMMMd(context.localeName).add_Hm().format(toLocal());

  String formattedDate(BuildContext context) => DateFormat.yMMMd(context.localeName).format(toLocal());
}
