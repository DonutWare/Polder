import "dart:async";

import "package:http/http.dart" as http;

class ServerStalledException extends http.ClientException {
  ServerStalledException(Uri url, Duration after)
    : super("The server stopped responding for ${after.inSeconds} seconds", url);
}

class StallGuardClient extends http.BaseClient {
  StallGuardClient(this._inner, {this.stallTimeout = defaultStallTimeout});

  static const defaultStallTimeout = Duration(seconds: 60);
  static const finishingBytesPerSecond = 10 * 1024 * 1024;

  final http.Client _inner;
  final Duration stallTimeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final watchdog = _Watchdog(stallTimeout);
    try {
      final response = await _inner.send(_GuardedRequest(request, watchdog));
      return _guardedResponse(request.url, response, watchdog);
    } on http.RequestAbortedException {
      watchdog.stop();
      if (watchdog.fired) throw ServerStalledException(request.url, stallTimeout);
      rethrow;
    } catch (_) {
      watchdog.stop();
      rethrow;
    }
  }

  http.StreamedResponse _guardedResponse(Uri url, http.StreamedResponse response, _Watchdog watchdog) {
    watchdog.touch();
    StreamSubscription<List<int>>? source;
    var finished = false;
    final body = StreamController<List<int>>(sync: true);
    body
      ..onListen = () {
        source = response.stream.listen(
          (chunk) {
            watchdog.touch();
            body.add(chunk);
          },
          onError: (Object error, StackTrace stack) => body.addError(
            error is http.RequestAbortedException && watchdog.fired ? ServerStalledException(url, stallTimeout) : error,
            stack,
          ),
          onDone: () {
            finished = true;
            watchdog.stop();
            unawaited(body.close());
          },
        );
      }
      ..onPause = () {
        watchdog.pause();
        source?.pause();
      }
      ..onResume = () {
        source?.resume();
        watchdog.touch();
      }
      ..onCancel = () {
        watchdog.stop();
        return finished ? null : source?.cancel();
      };
    return http.StreamedResponse(
      body.stream,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}

class _Watchdog {
  _Watchdog(this._timeout) {
    touch();
  }

  Duration _timeout;
  final _tripped = Completer<void>();
  Timer? _timer;
  var _stopped = false;

  bool get fired => _tripped.isCompleted;

  Future<void> get tripped => _tripped.future;

  void touch() {
    if (_stopped || fired) return;
    _timer?.cancel();
    _timer = Timer(_timeout, _trip);
  }

  void pause() => _timer?.cancel();

  void allowExtra(Duration extra) {
    _timeout += extra;
    touch();
  }

  void stop() {
    _stopped = true;
    _timer?.cancel();
  }

  void _trip() {
    if (!_stopped) _tripped.complete();
  }
}

class _GuardedRequest extends http.BaseRequest with http.Abortable {
  _GuardedRequest(this._original, this._watchdog) : super(_original.method, _original.url) {
    headers.addAll(_original.headers);
    contentLength = _original.contentLength;
    followRedirects = _original.followRedirects;
    maxRedirects = _original.maxRedirects;
    persistentConnection = _original.persistentConnection;
  }

  final http.BaseRequest _original;
  final _Watchdog _watchdog;

  @override
  Future<void>? get abortTrigger => switch (_original) {
    http.Abortable(:final abortTrigger?) => Future.any([_watchdog.tripped, abortTrigger]),
    _ => _watchdog.tripped,
  };

  @override
  http.ByteStream finalize() {
    super.finalize();
    var sent = 0;
    return http.ByteStream(
      _original.finalize().transform(
        StreamTransformer.fromHandlers(
          handleData: (chunk, sink) {
            sent += chunk.length;
            _watchdog.touch();
            sink.add(chunk);
          },
          handleDone: (sink) {
            _watchdog.allowExtra(Duration(seconds: sent ~/ StallGuardClient.finishingBytesPerSecond));
            sink.close();
          },
        ),
      ),
    );
  }
}
