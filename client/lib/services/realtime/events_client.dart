import "dart:async";
import "dart:convert";
import "dart:math";

import "package:web_socket_channel/web_socket_channel.dart";

import "package:nomad/models/activity.dart";
import "package:nomad/models/server_event.dart";
import "package:nomad/services/api/generated/nomad.swagger.dart" as wire;
import "package:nomad/services/api/wire_mappers.dart";

typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

typedef TokenSource = Future<String?> Function({required bool refresh});

enum RealtimeStatus { connecting, connected, offline }

class EventsClient {
  EventsClient({required this.endpoint, required this._token, required this._connect});

  static const unauthorizedCloseCode = 4401;
  static const _maxBackoff = Duration(seconds: 30);

  final Uri endpoint;
  final TokenSource _token;
  final WebSocketConnector _connect;
  final _events = StreamController<ServerEvent>.broadcast();
  final _status = StreamController<RealtimeStatus>.broadcast();
  final _random = Random();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _messages;
  Timer? _retry;
  var _attempt = 0;
  var _refreshToken = false;
  var _disposed = false;
  var _scope = const ActivityScope.me();
  var _currentStatus = RealtimeStatus.offline;

  static Uri endpointFor(String serverUrl) {
    final server = Uri.parse(serverUrl);
    final path = "${server.path.replaceAll(RegExp(r"/+$"), "")}/api/v1/events";
    return server.replace(scheme: server.scheme == "https" ? "wss" : "ws", path: path);
  }

  Stream<ServerEvent> get events => _events.stream;

  Stream<RealtimeStatus> get statusChanges => _status.stream;

  RealtimeStatus get status => _currentStatus;

  void start() => unawaited(_open());

  void subscribe(ActivityScope scope) {
    _scope = scope;
    _sendScope();
  }

  void reauthenticate(String token) => _send(wire.ClientMessage(type: wire.ClientMessageType.auth, token: token));

  Future<void> dispose() async {
    _disposed = true;
    _retry?.cancel();
    await _messages?.cancel();
    await _channel?.sink.close();
    await _events.close();
    await _status.close();
  }

  Future<void> _open() async {
    if (_disposed) return;
    _setStatus(RealtimeStatus.connecting);
    final String? token;
    try {
      token = await _token(refresh: _refreshToken);
    } on Object {
      return _scheduleRetry();
    }
    if (token == null || _disposed) return _scheduleRetry();
    _refreshToken = false;

    final channel = _connect(endpoint);
    try {
      await channel.ready;
    } on Object {
      return _scheduleRetry();
    }
    if (_disposed) {
      await channel.sink.close();
      return;
    }
    _channel = channel;
    _messages = channel.stream.listen(_onMessage, onDone: () => _onClosed(channel), onError: (_) {});
    _send(wire.ClientMessage(type: wire.ClientMessageType.auth, token: token));
    _sendScope();
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    final event = wire.EventMessage.fromJson(decoded).toModel();
    if (event == null) return;
    if (event is ReadyEvent) {
      _attempt = 0;
      _setStatus(RealtimeStatus.connected);
    }
    _events.add(event);
  }

  void _onClosed(WebSocketChannel channel) {
    if (_channel != channel) return;
    _channel = null;
    _messages = null;
    if (_disposed) return;
    _refreshToken = channel.closeCode == unauthorizedCloseCode;
    _events.add(const DisconnectedEvent());
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (_disposed) return;
    _setStatus(RealtimeStatus.offline);
    final seconds = min(_maxBackoff.inSeconds, 1 << min(_attempt, 5));
    _attempt++;
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: seconds * 1000 + _random.nextInt(500)), _open);
  }

  void _sendScope() => _send(_scope.toSubscribeMessage());

  void _send(wire.ClientMessage message) => _channel?.sink.add(jsonEncode(message));

  void _setStatus(RealtimeStatus status) {
    if (_currentStatus == status || _disposed) return;
    _currentStatus = status;
    _status.add(status);
  }
}
