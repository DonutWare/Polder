import "package:freezed_annotation/freezed_annotation.dart";

part "server_log.freezed.dart";

enum LogLevel {
  debug,
  info,
  warn,
  error;

  static LogLevel? parseLogLevels(String raw) {
    final name = raw.split(RegExp("[+-]")).first.toLowerCase();
    return LogLevel.values.where((level) => level.name == name).firstOrNull;
  }
}

@freezed
abstract class ServerLogEntry with _$ServerLogEntry {
  const factory ServerLogEntry({
    required String id,
    DateTime? time,
    LogLevel? level,
    @Default("") String component,
    required String message,
    @Default(<String, String>{}) Map<String, String> attrs,
  }) = _ServerLogEntry;
}

@freezed
abstract class ServerLogPage with _$ServerLogPage {
  const ServerLogPage._();

  const factory ServerLogPage({
    @Default(<ServerLogEntry>[]) List<ServerLogEntry> entries,
    @Default("") String nextCursor,
  }) = _ServerLogPage;

  bool get hasMore => nextCursor.isNotEmpty;
}

@freezed
abstract class ServerLogFile with _$ServerLogFile {
  const factory ServerLogFile({required String name, required DateTime day, required int size}) = _ServerLogFile;
}

@freezed
abstract class ServerLogFilter with _$ServerLogFilter {
  const factory ServerLogFilter({
    @Default(LogLevel.debug) LogLevel minLevel,
    String? component,
    @Default("") String query,
  }) = _ServerLogFilter;
}
