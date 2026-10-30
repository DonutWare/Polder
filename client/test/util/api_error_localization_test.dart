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

  test("shows what went wrong on the server", () {
    const error = ServerException(
      error: ApiError(code: "internal", message: "move to trash: permission denied"),
      statusCode: 500,
    );

    expect(localized.describeError(error), "${localized.errorServer("500")}\nMove to trash: permission denied");
  });

  test("shows why the server could not be reached", () {
    const error = NetworkException(reason: "Connection refused");

    expect(localized.describeError(error), "${localized.errorNetwork}\nConnection refused");
  });

  test("shows the cause of an error inside the app", () {
    expect(
      localized.describeError(StateError("ref was disposed")),
      "${localized.errorUnknown}\nBad state: ref was disposed",
    );
  });

  test("keeps the summary alone without a server message", () {
    expect(localized.describeError(const NotFoundException()), localized.errorNotFound);
  });
}
