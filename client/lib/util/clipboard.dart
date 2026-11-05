import "package:flutter/material.dart";
import "package:flutter/services.dart";

void copyWithNotice(BuildContext context, String value, String notice) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(notice)));
}
