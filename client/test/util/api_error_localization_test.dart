import "package:flutter_test/flutter_test.dart";

import "package:polder/l10n/generated/app_localizations_en.dart";
import "package:polder/models/api_error.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/util/api_error_localization.dart";

void main() {
  final localized = AppLocalizationsEn();

  test("adds the server message below the summary", () {
    const error = InvalidRequestException(
      error: ApiError(code: "invalid_request", message: "only http and https links can be previewed"),
    );

    expect(
      localized.describeError(error),
      "${localized.errorInvalidRequest}\nOnly http and https links can be previewed",
    );
  });

  test("leaves out the message of an internal error", () {
    const error = ServerException(
      error: ApiError(code: "internal", message: "internal server error"),
    );

    expect(localized.describeError(error), localized.errorUnknown);
  });

  test("keeps the summary alone without a server message", () {
    expect(localized.describeError(const NotFoundException()), localized.errorNotFound);
  });
}
