import "package:flutter_test/flutter_test.dart";

import "package:polder/services/api/api_error_mapper.dart";
import "package:polder/services/api/api_exceptions.dart";

void main() {
  Map<String, dynamic> error(String code) => {
    "error": {"code": code, "message": code},
  };

  test("maps conflict with the current entry", () {
    final exception = ApiErrorMapper.fromResponse(409, {
      ...error("conflict"),
      "current": {"path": "/a.txt", "name": "a.txt", "mtime": "2026-09-30T12:00:00Z", "rev": 9, "hash": "abc"},
    });

    expect(exception, isA<ConflictException>().having((e) => e.current?.rev, "current rev", 9));
  });

  test("maps conflict for a deleted file to a null current entry", () {
    final exception = ApiErrorMapper.fromResponse(409, {...error("conflict"), "current": null});

    expect(exception, isA<ConflictException>().having((e) => e.current, "current", isNull));
  });

  test("distinguishes already_exists from conflict on the same status", () {
    expect(ApiErrorMapper.fromResponse(409, error("already_exists")), isA<AlreadyExistsException>());
  });

  test("maps the remaining protocol codes", () {
    expect(ApiErrorMapper.fromResponse(507, error("quota_exceeded")), isA<QuotaExceededException>());
    expect(ApiErrorMapper.fromResponse(400, error("invalid_request")), isA<InvalidRequestException>());
    expect(ApiErrorMapper.fromResponse(401, error("unauthorized")), isA<UnauthorizedException>());
    expect(ApiErrorMapper.fromResponse(403, error("forbidden")), isA<ForbiddenException>());
    expect(ApiErrorMapper.fromResponse(404, error("not_found")), isA<NotFoundException>());
    expect(ApiErrorMapper.fromResponse(412, null), isA<PreconditionFailedException>());
    expect(ApiErrorMapper.fromResponse(500, null), isA<ServerException>());
  });

  test("keeps the server message", () {
    expect(ApiErrorMapper.fromResponse(403, error("forbidden")).serverMessage, "forbidden");
  });
}
