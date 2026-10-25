import "package:flutter/widgets.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/util/localization_helper.dart";

extension ErrorLocalization on AppLocalizations {
  String describeError(Object? error) => switch (_detailOf(error)) {
    final detail? => "${_summaryOf(error)}\n$detail",
    null => _summaryOf(error),
  };

  String _summaryOf(Object? error) => switch (error) {
    NetworkException() => errorNetwork,
    UnauthorizedException() => errorUnauthorized,
    ForbiddenException() => errorForbidden,
    NotFoundException() => errorNotFound,
    ConflictException() => errorConflict,
    AlreadyExistsException() => errorAlreadyExists,
    QuotaExceededException() => errorQuotaExceeded,
    InvalidRequestException() => errorInvalidRequest,
    RateLimitedException() => errorRateLimited,
    UnavailableException() => errorUnavailable,
    LocalRootMissingException(:final path) => errorLocalFolderMissing(path),
    _ => errorUnknown,
  };

  static String? _detailOf(Object? error) {
    if (error is! ApiException || error.error?.code == "internal") return null;
    final message = error.serverMessage.trim();
    if (message.isEmpty) return null;
    return "${message[0].toUpperCase()}${message.substring(1)}";
  }
}

extension ContextErrorLocalization on BuildContext {
  String describeError(Object? error) => localized.describeError(error);
}
