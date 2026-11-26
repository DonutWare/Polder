import "dart:async";
import "dart:convert";

import "package:stream_channel/stream_channel.dart";
import "package:web_socket_channel/web_socket_channel.dart";

class FakeWebSocket with StreamChannelMixin<dynamic> implements WebSocketChannel {
  final _incoming = StreamController<dynamic>();
  final List<Map<String, dynamic>> sent = [];
  late final _FakeSink _sink = _FakeSink(sent);
  int? _closeCode;

  @override
  Future<void> get ready => Future.value();

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  void serverSends(Map<String, Object?> message) => _incoming.add(jsonEncode(message));

  Future<void> serverCloses(int code) async {
    _closeCode = code;
    await _incoming.close();
  }
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.sent);

  final List<Map<String, dynamic>> sent;
  final _done = Completer<void>();

  @override
  void add(dynamic data) => sent.add(jsonDecode(data as String) as Map<String, dynamic>);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<dynamic> stream) => stream.forEach(add);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;
}

Map<String, Object?> transferJson({
  String id = "t1",
  int userId = 1,
  String path = "/Photos/cat.jpg",
  String direction = "upload",
  int bytes = 0,
  int? total = 100,
  String? clientId,
  String device = "macOS",
}) => {
  "id": id,
  "userId": userId,
  "username": "alice",
  "direction": direction,
  "path": path,
  "device": device,
  "clientId": ?clientId,
  "bytes": bytes,
  "total": ?total,
  "rate": 1024,
  "startedAt": "2026-10-04T12:00:00Z",
};
