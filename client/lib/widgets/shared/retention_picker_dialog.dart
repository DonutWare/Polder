import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/util/localization_helper.dart";

typedef RetentionChoice = ({int? days});

abstract final class RetentionOptions {
  static const _common = [7, 14, 30, 60, 90, 180, 365];
  static const forever = 0;

  static List<int> including(int? current) => [
    ...{..._common, if (current != null && current != forever) current}.toList()..sort(),
    forever,
  ];
}

extension RetentionDuration on BuildContext {
  String retentionDuration(int days) =>
      days == RetentionOptions.forever ? localized.trashRetentionForever : localized.trashRetentionDays(days);
}

Future<RetentionChoice?> showRetentionPicker(
  BuildContext context, {
  required String title,
  required int? selected,
  String? followDefaultLabel,
}) => showDialog<RetentionChoice>(
  context: context,
  builder: (context) {
    Widget option(int? days, String label) => ListTile(
      title: Text(label),
      trailing: days == selected ? const Icon(IconsaxPlusLinear.tick_circle) : null,
      onTap: () => Navigator.pop(context, (days: days)),
    );
    return SimpleDialog(
      title: Text(title),
      children: [
        if (followDefaultLabel != null) option(null, followDefaultLabel),
        for (final days in RetentionOptions.including(selected)) option(days, context.retentionDuration(days)),
      ],
    );
  },
);
