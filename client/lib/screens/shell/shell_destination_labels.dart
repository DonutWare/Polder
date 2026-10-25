import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/navigation/navigation_shell.dart";

extension ShellDestinationPresentation on ShellDestination {
  String label(BuildContext context) => switch (this) {
    ShellDestination.files => context.localized.navFiles,
    ShellDestination.shared => context.localized.navShared,
    ShellDestination.notes => context.localized.navNotes,
    ShellDestination.activity => context.localized.navActivity,
    ShellDestination.sync => context.localized.navSync,
    ShellDestination.autoUpload => context.localized.navAutoUpload,
    ShellDestination.groups => context.localized.groups,
    ShellDestination.trash => context.localized.navTrash,
    ShellDestination.settings => context.localized.navSettings,
  };

  IconData get icon => switch (this) {
    ShellDestination.files => IconsaxPlusLinear.folder_2,
    ShellDestination.shared => IconsaxPlusLinear.share,
    ShellDestination.notes => IconsaxPlusLinear.note_2,
    ShellDestination.activity => IconsaxPlusLinear.activity,
    ShellDestination.sync => IconsaxPlusLinear.refresh_2,
    ShellDestination.autoUpload => IconsaxPlusLinear.gallery_import,
    ShellDestination.groups => IconsaxPlusLinear.people,
    ShellDestination.trash => IconsaxPlusLinear.trash,
    ShellDestination.settings => IconsaxPlusLinear.setting_2,
  };

  IconData get selectedIcon => switch (this) {
    ShellDestination.files => IconsaxPlusBold.folder_2,
    ShellDestination.shared => IconsaxPlusBold.share,
    ShellDestination.notes => IconsaxPlusBold.note_2,
    ShellDestination.activity => IconsaxPlusBold.activity,
    ShellDestination.sync => IconsaxPlusBold.refresh_2,
    ShellDestination.autoUpload => IconsaxPlusBold.gallery_import,
    ShellDestination.groups => IconsaxPlusBold.people,
    ShellDestination.trash => IconsaxPlusBold.trash,
    ShellDestination.settings => IconsaxPlusBold.setting_2,
  };

  NavItem item(BuildContext context, {String? badge}) =>
      NavItem(icon: icon, selectedIcon: selectedIcon, label: label(context), badge: badge);
}
