import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";

class ExpiryTile extends StatelessWidget {
  const ExpiryTile({required this.value, required this.onChanged, this.enabled = true, this.dense, super.key});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final expiresAt = value;
    return ListTile(
      dense: dense,
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      leading: const Icon(IconsaxPlusLinear.calendar_1),
      title: Text(localized.linkExpiry),
      subtitle: Text(expiresAt == null ? localized.linkNoExpiry : expiresAt.formattedDate(context)),
      trailing: expiresAt == null || !enabled
          ? null
          : IconButton(
              tooltip: localized.linkNoExpiry,
              icon: const Icon(IconsaxPlusLinear.close_circle),
              onPressed: () => onChanged(null),
            ),
      onTap: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: value?.toLocal() ?? tomorrow.add(const Duration(days: 6)),
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) onChanged(DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
  }
}
