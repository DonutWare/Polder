import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/group.dart";
import "package:polder/models/sharing.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";

extension SharePermissionsLabel on SharePermissions {
  String summary(AppLocalizations localized) => isViewOnly
      ? localized.sharePermissionRead
      : isEditor
      ? localized.sharePermissionWrite
      : localized.sharePermissionCustom;

  IconData get icon => isViewOnly ? IconsaxPlusLinear.eye : IconsaxPlusLinear.edit_2;
}

extension GroupRoleLabel on GroupRole {
  String label(AppLocalizations localized) => switch (this) {
    GroupRole.admin => localized.groupRoleAdmin,
    GroupRole.member => localized.groupRoleMember,
    GroupRole.viewer => localized.groupRoleViewer,
  };

  String hint(AppLocalizations localized) => switch (this) {
    GroupRole.admin => localized.groupRoleAdminHint,
    GroupRole.member => localized.groupRoleMemberHint,
    GroupRole.viewer => localized.groupRoleViewerHint,
  };
}

extension SharedFileLabel on SharedFile {
  String displayName(AppLocalizations localized) => name.isEmpty ? localized.shareUnavailable : name;
}

extension LinkPermissionsLabel on LinkPermissions {
  List<(String, IconData)> labels(AppLocalizations localized) => [
    if (view) (localized.linkCanView, IconsaxPlusLinear.eye),
    if (download) (localized.linkCanDownload, IconsaxPlusLinear.document_download),
    if (upload) (localized.linkCanUpload, IconsaxPlusLinear.document_upload),
  ];
}

String shareDescription(BuildContext context, OutgoingShare share) {
  final localized = context.localized;
  return [
    share.permissions.summary(localized),
    if (share.expiresAt case final expiresAt?) localized.linkExpiresOn(expiresAt.formattedDate(context)),
  ].join(" · ");
}
