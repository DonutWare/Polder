import "dart:async";
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
import "package:path/path.dart" as p;

import "package:nomad/models/token_pair.dart";
import "package:nomad/services/api/api_client_factory.dart";
import "package:nomad/services/api/auth_session.dart";
import "package:nomad/services/api/nomad_api.dart";

/// Where the Go server sources live (`NOMAD_SERVER_DIR`). Point `NOMAD_SERVER_BIN` at a
/// prebuilt binary instead to skip `go build`. With neither set, the real-server tests skip.
String? get serverSourceDir => Platform.environment["NOMAD_SERVER_DIR"];

/// Why the real-server tests cannot run here, or `null` when they can.
String? realServerUnavailableReason() {
  if (Platform.environment["NOMAD_SERVER_BIN"] != null) return null;
  final sources = serverSourceDir;
  if (sources == null) return "set NOMAD_SERVER_DIR or NOMAD_SERVER_BIN to run against a real server";
  if (!File(p.join(sources, "go.mod")).existsSync()) return "nomad-server sources not found at $sources";
  try {
    if (Process.runSync("go", ["version"]).exitCode != 0) return "go toolchain not available";
  } on ProcessException {
    return "go toolchain not available";
  }
  return null;
}

class MemoryAuthSession implements AuthSession {
  TokenPair? tokens;

  @override
  String? get accessToken => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> storeTokens(TokenPair tokens) async => this.tokens = tokens;

  @override
  Future<void> expire() async => tokens = null;
}

/// Counts delta-transfer traffic so tests can assert that only changed chunks move.
class TransferCounter extends http.BaseClient {
  final _inner = http.Client();
  int chunkBytesSent = 0;
  int rangeBytesReceived = 0;

  void reset() => chunkBytesSent = rangeBytesReceived = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == "PUT" && request.url.path.contains("/chunks/")) chunkBytesSent += request.contentLength ?? 0;
    final response = await _inner.send(request);
    if (response.statusCode == 206) rangeBytesReceived += response.contentLength ?? 0;
    return response;
  }

  @override
  void close() => _inner.close();
}

/// A real `nomad` server process on a free localhost port with throwaway `/config` and `/data`.
class RealNomadServer {
  RealNomadServer._(this._process, this._workDir, this.url, this._log);

  final Process _process;
  final Directory _workDir;
  final String url;
  final StringBuffer _log;

  String get dataDir => p.join(_workDir.path, "data");

  String get log => _log.toString();

  static Future<RealNomadServer> start() async {
    final workDir = await Directory.systemTemp.createTemp("nomad_server");
    final binary = Platform.environment["NOMAD_SERVER_BIN"] ?? await _build(workDir);
    final port = await _freePort();
    for (final dir in ["config", "data"]) {
      await Directory(p.join(workDir.path, dir)).create();
    }
    final process = await Process.start(
      binary,
      const [],
      environment: {
        "NOMAD_LISTEN": "127.0.0.1:$port",
        "NOMAD_CONFIG_DIR": p.join(workDir.path, "config"),
        "NOMAD_DATA_DIR": p.join(workDir.path, "data"),
        "NOMAD_RESCAN_INTERVAL": "0",
        "NOMAD_WATCH_FILES": "false",
      },
    );
    final log = StringBuffer();
    process.stdout.transform(utf8.decoder).listen(log.write);
    process.stderr.transform(utf8.decoder).listen(log.write);
    final server = RealNomadServer._(process, workDir, "http://127.0.0.1:$port", log);
    await server._waitUntilHealthy();
    return server;
  }

  static Future<String> _build(Directory workDir) async {
    final output = p.join(workDir.path, "nomad");
    final result = await Process.run("go", ["build", "-o", output, "./cmd/nomad"], workingDirectory: serverSourceDir);
    if (result.exitCode != 0) throw StateError("go build failed:\n${result.stderr}");
    return output;
  }

  static Future<int> _freePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  Future<void> _waitUntilHealthy() async {
    final api = anonymousApi();
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      try {
        if (await api.healthz()) return;
      } on Exception {
        // Not listening yet.
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError("nomad did not become healthy:\n$log");
  }

  NomadApi anonymousApi() => NomadApi(ApiClientFactory.create(url));

  /// An API authenticated through the real [AuthInterceptor], so token refresh is exercised too.
  ({NomadApi api, MemoryAuthSession session, TransferCounter counter}) signedIn(TokenPair tokens) {
    final session = MemoryAuthSession()..tokens = tokens;
    final counter = TransferCounter();
    return (
      api: NomadApi(ApiClientFactory.create(url, session: session, httpClient: counter)),
      session: session,
      counter: counter,
    );
  }

  Future<void> stop() async {
    _process.kill();
    await _process.exitCode.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _process.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
    await _workDir.delete(recursive: true);
  }
}
