import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/models/user.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/util/byte_format.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/shared/stat_tile.dart";

class AdminStatsGrid extends StatelessWidget {
  const AdminStatsGrid({required this.users, super.key});

  static const nearQuotaFraction = 0.9;

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final colors = AppColors.of(context);
    final used = users.fold(0, (sum, user) => sum + user.usedBytes);
    final admins = users.where((user) => user.isAdmin).length;
    final nearQuota = users.where((user) => user.hasQuota && user.usedFraction >= nearQuotaFraction).length;
    final disabled = users.where((user) => user.disabled).length;
    final (value, unit) = _split(ByteFormat.format(used, locale: context.localeName));
    final tiles = [
      StatTile(
        icon: IconsaxPlusLinear.profile_2user,
        label: localized.users,
        value: "${users.length}",
        caption: localized.adminAccountsCaption(admins),
      ),
      StatTile(
        icon: IconsaxPlusLinear.cloud,
        label: localized.adminStorageUsed,
        value: value,
        unit: unit,
        caption: localized.adminStorageCaption,
        color: colors.sky,
      ),
      StatTile(
        icon: IconsaxPlusLinear.warning_2,
        label: localized.adminNearQuota,
        value: "$nearQuota",
        caption: localized.adminNearQuotaCaption,
        color: nearQuota > 0 ? colors.warning : colors.success,
      ),
      StatTile(
        icon: IconsaxPlusLinear.user_remove,
        label: localized.disabled,
        value: "$disabled",
        caption: localized.adminDisabledCaption,
        color: disabled > 0 ? colors.rose : colors.success,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth >= 720 ? 4 : 2;
        const gap = 12.0;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }

  static (String, String?) _split(String formatted) {
    final space = formatted.lastIndexOf(" ");
    return space < 0 ? (formatted, null) : (formatted.substring(0, space), formatted.substring(space + 1));
  }
}
