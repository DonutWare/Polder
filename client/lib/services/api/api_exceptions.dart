import "package:polder/models/api_error.dart";
import "package:polder/models/file_entry.dart";

sealed class ApiException implements Exception {
  const ApiException({this.error, this.statusCode});

  final ApiError? error;
  final int? statusCode;

  String get serverMessage => error?.message ?? "";

  @override
  String toString() => "$runtimeType($statusCode, ${error?.code}: $serverMessage)";
}

class InvalidRequestException extends ApiException {
  const InvalidRequestException({super.error, super.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.error, super.statusCode});
}

class ForbiddenException extends ApiException {
  const ForbiddenException({super.error, super.statusCode});
}

class NotFoundException extends ApiException {
  const NotFoundException({super.error, super.statusCode});
}

class ConflictException extends ApiException {
  const ConflictException({this.current, super.error, super.statusCode});

  final FileEntry? current;
}

class AlreadyExistsException extends ApiException {
  const AlreadyExistsException({super.error, super.statusCode});
}

class PreconditionFailedException extends ApiException {
  const PreconditionFailedException({super.error, super.statusCode});
}

class QuotaExceededException extends ApiException {
  const QuotaExceededException({super.error, super.statusCode});
}

class NetworkException extends ApiException {
  const NetworkException({super.error});
}

class ServerException extends ApiException {
  const ServerException({super.error, super.statusCode});
}
