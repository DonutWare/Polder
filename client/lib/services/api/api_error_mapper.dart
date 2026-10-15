import "dart:async";
import "dart:convert";

import "package:chopper/chopper.dart";
import "package:http/http.dart" as http;

import "package:polder/models/api_error.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/services/api/api_exceptions.dart";

class ApiErrorInterceptor implements Interceptor {
  const ApiErrorInterceptor();

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final Response<BodyType> response;
    try {
      response = await chain.proceed(chain.request);
    } on http.ClientException {
      throw const NetworkException();
    }
    if (response.isSuccessful) return response;
    throw ApiErrorMapper.fromResponse(response.statusCode, await ApiErrorMapper._decodeBody(response));
  }
}

abstract final class ApiErrorMapper {
  static ApiException fromResponse(int statusCode, Map<String, dynamic>? body) =>
      _fromParts(statusCode, _parseError(body), _parseCurrent(body));

  static ApiException fromError(ApiError error, {FileEntry? current}) => _fromParts(null, error, current);

  static ApiException _fromParts(int? statusCode, ApiError? error, FileEntry? current) {
    return switch ((statusCode, error?.code)) {
      (_, "conflict") => ConflictException(current: current, error: error, statusCode: statusCode),
      (_, "already_exists") => AlreadyExistsException(error: error, statusCode: statusCode),
      (_, "quota_exceeded") || (507, _) => QuotaExceededException(error: error, statusCode: statusCode),
      (_, "invalid_request") || (400, _) => InvalidRequestException(error: error, statusCode: statusCode),
      (_, "unauthorized") || (401, _) => UnauthorizedException(error: error, statusCode: statusCode),
      (_, "forbidden") || (403, _) => ForbiddenException(error: error, statusCode: statusCode),
      (_, "not_found") || (404, _) => NotFoundException(error: error, statusCode: statusCode),
      (_, "precondition_failed") || (412, _) => PreconditionFailedException(error: error, statusCode: statusCode),
      (409, _) => ConflictException(current: current, error: error, statusCode: statusCode),
      _ => ServerException(error: error, statusCode: statusCode),
    };
  }

  static ApiError? _parseError(Map<String, dynamic>? body) => switch (body?["error"]) {
    final Map<String, dynamic> error => ApiError.fromJson(error),
    _ => null,
  };

  static FileEntry? _parseCurrent(Map<String, dynamic>? body) {
    final nestedError = body?["error"];
    final current = body?["current"] ?? (nestedError is Map<String, dynamic> ? nestedError["current"] : null);
    return current is Map<String, dynamic> ? FileEntry.fromJson(current) : null;
  }

  static Future<Map<String, dynamic>?> _decodeBody(Response<dynamic> response) async {
    try {
      final text = switch ((response.base, response.error)) {
        (final http.Response base, _) => utf8.decode(base.bodyBytes),
        (_, final Stream<List<int>> stream) => await utf8.decodeStream(stream),
        _ => "",
      };
      return text.isEmpty ? null : _asMap(jsonDecode(text));
    } on FormatException {
      return null;
    }
  }

  static Map<String, dynamic>? _asMap(Object? value) => value is Map<String, dynamic> ? value : null;
}
