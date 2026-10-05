import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/activity.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";

extension ActivityKindPresentation on ActivityKind {
  String label(BuildContext context) {
    final localized = context.localized;
    return switch (this) {
      ActivityKind.upload => localized.activityKindUpload,
      ActivityKind.download => localized.activityKindDownload,
      ActivityKind.mkdir => localized.activityKindMkdir,
      ActivityKind.move => localized.activityKindMove,
      ActivityKind.delete => localized.activityKindDelete,
      ActivityKind.restore => localized.activityKindRestore,
      ActivityKind.trashDelete => localized.activityKindTrashDelete,
      ActivityKind.trashEmpty => localized.activityKindTrashEmpty,
      ActivityKind.trashExpire => localized.activityKindTrashExpire,
      ActivityKind.rescan => localized.activityRescanChanged,
      ActivityKind.login => localized.activityKindLogin,
      ActivityKind.logout => localized.activityKindLogout,
      ActivityKind.unknown => localized.activityKindUnknown,
    };
  }

  (IconData, Color) style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    return switch (this) {
      ActivityKind.upload => (IconsaxPlusLinear.document_upload, cs.primary),
      ActivityKind.download => (IconsaxPlusLinear.document_download, colors.sky),
      ActivityKind.mkdir => (IconsaxPlusLinear.folder_add, cs.primary),
      ActivityKind.move => (IconsaxPlusLinear.arrow_swap_horizontal, cs.tertiary),
      ActivityKind.delete => (IconsaxPlusLinear.trash, colors.warning),
      ActivityKind.restore => (IconsaxPlusLinear.rotate_left, colors.success),
      ActivityKind.trashDelete || ActivityKind.trashEmpty => (IconsaxPlusLinear.trash, cs.error),
      ActivityKind.trashExpire => (IconsaxPlusLinear.timer_1, cs.outline),
      ActivityKind.rescan => (IconsaxPlusLinear.refresh_2, colors.sky),
      ActivityKind.login => (IconsaxPlusLinear.login, colors.success),
      ActivityKind.logout => (IconsaxPlusLinear.logout, cs.outline),
      ActivityKind.unknown => (IconsaxPlusLinear.info_circle, cs.outline),
    };
  }
}

extension ActivityScopePresentation on ActivityScope {
  String label(BuildContext context) => switch (this) {
    ActivityScopeMe() => context.localized.activityScopeMe,
    ActivityScopeAll() => context.localized.activityScopeAll,
    ActivityScopeUser(:final username) => username,
  };
}

String formatDuration(BuildContext context, int milliseconds) {
  final seconds = (milliseconds / 1000).round();
  return seconds < 60
      ? context.localized.durationSeconds(seconds < 1 ? 1 : seconds)
      : context.localized.durationMinutes((seconds / 60).round());
}
