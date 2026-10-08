import "package:flutter/material.dart";

import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/text_input_dialog.dart";

Future<int?> showCountInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required int initialValue,
  int minimum = 0,
  int? maximum,
}) async {
  bool isValid(String value) {
    final count = int.tryParse(value.trim());
    return count != null && count >= minimum && (maximum == null || count <= maximum);
  }

  final value = await showTextInputDialog(
    context,
    title: title,
    label: label,
    confirmLabel: context.localized.save,
    initialValue: "$initialValue",
    isValid: isValid,
  );
  return value == null ? null : int.parse(value.trim());
}
