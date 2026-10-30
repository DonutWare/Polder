import "package:flutter/widgets.dart";

import "package:flutter_riverpod/misc.dart";

import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/sync/sync_exceptions.dart";
import "package:polder/util/localization_helper.dart";

extension ErrorLocalization on AppLocalizations {
  String describeError(Object? error) => _describe(_unwrapped(error));

  String _describe(Object? error) => switch (_detailOf(error)) {
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
    PreconditionFailedException() => errorPreconditionFailed,
    RateLimitedException() => errorRateLimited,
    UnavailableException() => errorUnavailable,
    ServerException(:final statusCode) => errorServer("${statusCode ?? "?"}"),
    LocalRootMissingException(:final path) => errorLocalFolderMissing(path),
    _ => errorUnknown,
  };

  String? errorDetail(Object? error) => _detailOf(_unwrapped(error));

  static Object? _unwrapped(Object? error) => switch (error) {
    ProviderException(:final exception) => _unwrapped(exception),
    _ => error,
  };

  static String? _detailOf(Object? error) => switch (error) {
    null || LocalRootMissingException() => null,
    NetworkException(:final reason) => _sentence(reason),
    ApiException(:final serverMessage) => _sentence(serverMessage),
    _ => _sentence(error.toString()),
  };

  static String? _sentence(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;
    return "${trimmed[0].toUpperCase()}${trimmed.substring(1)}";
  }
}

extension ContextErrorLocalization on BuildContext {
  String describeError(Object? error) => localized.describeError(error);
}
