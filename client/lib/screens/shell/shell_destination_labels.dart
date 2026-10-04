import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/shell/shell_destinations_provider.dart";
import "package:nomad/util/localization_helper.dart";
import "package:nomad/widgets/navigation/navigation_shell.dart";

extension ShellDestinationPresentation on ShellDestination {
  String label(BuildContext context) => switch (this) {
    ShellDestination.files => context.localized.navFiles,
    ShellDestination.sync => context.localized.navSync,
    ShellDestination.autoUpload => context.localized.navAutoUpload,
    ShellDestination.trash => context.localized.navTrash,
    ShellDestination.settings => context.localized.navSettings,
  };

  IconData get icon => switch (this) {
    ShellDestination.files => IconsaxPlusLinear.folder_2,
    ShellDestination.sync => IconsaxPlusLinear.refresh_2,
    ShellDestination.autoUpload => IconsaxPlusLinear.gallery_import,
    ShellDestination.trash => IconsaxPlusLinear.trash,
    ShellDestination.settings => IconsaxPlusLinear.setting_2,
  };

  IconData get selectedIcon => switch (this) {
    ShellDestination.files => IconsaxPlusBold.folder_2,
    ShellDestination.sync => IconsaxPlusBold.refresh_2,
    ShellDestination.autoUpload => IconsaxPlusBold.gallery_import,
    ShellDestination.trash => IconsaxPlusBold.trash,
    ShellDestination.settings => IconsaxPlusBold.setting_2,
  };

  NavItem item(BuildContext context, {String? badge}) =>
      NavItem(icon: icon, selectedIcon: selectedIcon, label: label(context), badge: badge);
}

extension AdminDestinationPresentation on AdminDestination {
  String label(BuildContext context) => switch (this) {
    AdminDestination.overview => context.localized.adminOverview,
    AdminDestination.users => context.localized.users,
  };

  NavItem item(BuildContext context) => switch (this) {
    AdminDestination.overview => NavItem(
      icon: IconsaxPlusLinear.category,
      selectedIcon: IconsaxPlusBold.category,
      label: label(context),
    ),
    AdminDestination.users => NavItem(
      icon: IconsaxPlusLinear.profile_2user,
      selectedIcon: IconsaxPlusBold.profile_2user,
      label: label(context),
    ),
  };
}
