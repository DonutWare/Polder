import "package:polder/models/offline_models.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/offline/content_store.dart";

class ServerDidNotStoreException implements Exception {
  const ServerDidNotStoreException(this.message);

  final String message;

  @override
  String toString() => "ServerDidNotStoreException: $message";
}

abstract final class OutboxErrors {
  static OutboxError classify(Object error) => OutboxError(kind: kindOf(error), message: messageOf(error));

  static OutboxErrorKind kindOf(Object error) => switch (error) {
    NetworkException(timedOut: true) => OutboxErrorKind.timedOut,
    NetworkException() || UnauthorizedException() => OutboxErrorKind.unreachable,
    StorageFullException() => OutboxErrorKind.storageFull,
    DeviceStorageFullException() => OutboxErrorKind.deviceFull,
    ServerDidNotStoreException() => OutboxErrorKind.serverDidNotStore,
    QuotaExceededException() => OutboxErrorKind.quota,
    ConflictException() || AlreadyExistsException() || PreconditionFailedException() => OutboxErrorKind.conflict,
    ForbiddenException() => OutboxErrorKind.forbidden,
    NotFoundException() => OutboxErrorKind.notFound,
    InvalidRequestException() || MissingContentException() => OutboxErrorKind.rejected,
    _ => OutboxErrorKind.serverError,
  };

  static String messageOf(Object error) => switch (error) {
    NetworkException(:final reason) => reason,
    ApiException(:final serverMessage) when serverMessage.isNotEmpty => serverMessage,
    ServerDidNotStoreException(:final message) => message,
    _ => error.toString(),
  };

  static const _delays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

  static Duration retryDelay(int attempts) => _delays[(attempts - 1).clamp(0, _delays.length - 1)];
}
