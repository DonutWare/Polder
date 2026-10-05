import "package:flutter/widgets.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/util/localization_helper.dart";

extension ErrorLocalization on AppLocalizations {
  String describeError(Object? error) => switch (error) {
    NetworkException() => errorNetwork,
    UnauthorizedException() => errorUnauthorized,
    ForbiddenException() => errorForbidden,
    NotFoundException() => errorNotFound,
    ConflictException() => errorConflict,
    AlreadyExistsException() => errorAlreadyExists,
    QuotaExceededException() => errorQuotaExceeded,
    InvalidRequestException() => errorInvalidRequest,
    LocalRootMissingException(:final path) => errorLocalFolderMissing(path),
    _ => errorUnknown,
  };
}

extension ContextErrorLocalization on BuildContext {
  String describeError(Object? error) => localized.describeError(error);
}
