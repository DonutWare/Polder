import "package:flutter/material.dart";

import "package:polder/util/localization_helper.dart";
import "package:polder/util/quota_unit.dart";

class QuotaInput extends StatelessWidget {
  const QuotaInput({
    required this.amount,
    required this.unit,
    required this.isValid,
    required this.onAmountChanged,
    required this.onUnitChanged,
    super.key,
  });

  final String amount;
  final QuotaUnit unit;
  final bool isValid;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<QuotaUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      Expanded(
        child: TextFormField(
          initialValue: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.localized.quota,
            helperText: context.localized.quotaUnlimitedHint,
            errorText: isValid ? null : context.localized.quotaInvalid,
          ),
          onChanged: onAmountChanged,
        ),
      ),
      DropdownMenu<QuotaUnit>(
        width: 110,
        initialSelection: unit,
        label: Text(context.localized.unit),
        dropdownMenuEntries: [
          for (final option in QuotaUnit.values) DropdownMenuEntry(value: option, label: option.label),
        ],
        onSelected: (selected) => selected == null ? null : onUnitChanged(selected),
      ),
    ],
  );
}
