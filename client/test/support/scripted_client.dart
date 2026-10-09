import "dart:convert";
import "dart:typed_data";

import "package:http/http.dart" as http;

typedef ScriptedHandler = Future<http.StreamedResponse> Function(RecordedRequest request);

class RecordedRequest {
  RecordedRequest(this.method, this.url, this.headers, this.bytes, {this.contentLength});

  final String method;
  final Uri url;
  final Map<String, String> headers;
  final Uint8List bytes;

  final int? contentLength;

  String get path => url.path.replaceFirst("/api/v1", "");

  Map<String, String> get query => url.queryParameters;

  Object? get data =>
      bytes.isEmpty || !(headers["content-type"] ?? "").contains("json") ? null : jsonDecode(utf8.decode(bytes));
}

class ScriptedClient extends http.BaseClient {
  ScriptedClient(this.handler);

  final ScriptedHandler handler;
  final List<RecordedRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final recorded = RecordedRequest(
      request.method,
      request.url,
      request.headers,
      await request.finalize().toBytes(),
      contentLength: request.contentLength,
    );
    requests.add(recorded);
    return handler(recorded);
  }
}

http.StreamedResponse jsonResponse(int status, Object? body) =>
    textResponse(status, jsonEncode(body), contentType: "application/json");

http.StreamedResponse emptyResponse(int status) => http.StreamedResponse(const Stream.empty(), status);

http.StreamedResponse textResponse(int status, String body, {required String contentType}) =>
    bytesResponse(status, utf8.encode(body), contentType: contentType);

http.StreamedResponse bytesResponse(int status, List<int> bytes, {String contentType = "application/octet-stream"}) =>
    http.StreamedResponse(
      Stream.value(bytes),
      status,
      contentLength: bytes.length,
      headers: {"content-type": contentType, "content-length": "${bytes.length}"},
    );

Map<String, dynamic> userJson({String role = "user"}) => {
  "id": 1,
  "username": "alice",
  "role": role,
  "quotaBytes": 0,
  "usedBytes": 0,
  "historyBytes": 0,
  "disabled": false,
  "createdAt": "2026-09-30T12:00:00Z",
  "profile": {"firstName": "", "lastName": "", "displayName": "", "email": "", "address": ""},
  "appearance": <String, dynamic>{},
};

Map<String, dynamic> tokenJson(String access, String refresh) => {
  "accessToken": access,
  "refreshToken": refresh,
  "expiresIn": 900,
  "user": userJson(),
};
