import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/user.dart";
import "package:nomad/util/localization_helper.dart";

class RoleSelector extends StatelessWidget {
  const RoleSelector({required this.role, required this.onChanged, super.key});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<UserRole>(
    segments: [
      ButtonSegment(
        value: UserRole.user,
        icon: const Icon(IconsaxPlusLinear.user),
        label: Text(context.localized.roleUser),
      ),
      ButtonSegment(
        value: UserRole.admin,
        icon: const Icon(IconsaxPlusLinear.shield_tick),
        label: Text(context.localized.roleAdmin),
      ),
    ],
    selected: {role},
    onSelectionChanged: (selection) => onChanged(selection.single),
  );
}
