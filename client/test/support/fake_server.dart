import "dart:async";
import "dart:convert";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:http/http.dart" as http;

import "package:polder/services/sync/chunker.dart";
import "package:polder/util/remote_path.dart";

import "scripted_client.dart";

class FakeNode {
  FakeNode.file(this.bytes, this.rev, this.mtime) : isDir = false;

  FakeNode.dir(this.rev, this.mtime) : isDir = true, bytes = Uint8List(0);

  final bool isDir;
  Uint8List bytes;
  int rev;
  DateTime mtime;

  String get hash => isDir ? "" : sha256.convert(bytes).toString();
}

class FakeUpload {
  FakeUpload({
    required this.path,
    required this.baseRev,
    required this.hash,
    required this.mtime,
    required this.chunks,
  });

  final String path;
  final int baseRev;
  final String hash;
  final DateTime mtime;
  final List<(String, int)> chunks;
  final Map<String, Uint8List> received = {};
}

class FakePolderServer extends http.BaseClient {
  FakePolderServer() {
    nodes["/"] = FakeNode.dir(0, DateTime.utc(2026));
  }

  final Map<String, FakeNode> nodes = {};
  final List<Map<String, dynamic>> changes = [];
  final Map<String, FakeUpload> uploads = {};
  final List<String> requests = [];
  bool indexing = false;
  int rangeBytesServed = 0;
  int chunkBytesReceived = 0;
  int wholeBytesReceived = 0;
  var _rev = 0;
  var _seq = 0;
  var _uploadIds = 0;

  void putFile(String path, List<int> bytes, {DateTime? mtime}) {
    _ensureParents(path);
    final existing = nodes[path];
    if (existing != null) {
      existing
        ..bytes = Uint8List.fromList(bytes)
        ..rev = ++_rev
        ..mtime = mtime ?? DateTime.now().toUtc();
    } else {
      nodes[path] = FakeNode.file(Uint8List.fromList(bytes), ++_rev, mtime ?? DateTime.now().toUtc());
    }
    _emitUpsert(path);
  }

  void deletePath(String path) {
    nodes.removeWhere((key, _) => key == path || RemotePath.isWithin(key, path));
    changes.add({"seq": ++_seq, "type": "delete", "path": path, "entry": null});
  }

  Uint8List? contentOf(String path) => nodes[path]?.bytes;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = await request.finalize().toBytes();
    final uri = request.url;
    final route = uri.path.replaceFirst("/api/v1", "");
    requests.add("${request.method} $route");
    try {
      return _route(request.method, route, uri.queryParameters, request.headers, body);
    } on _HttpError catch (error) {
      return _json(error.status, {
        "error": {"code": error.code, "message": error.code},
        if (error.current != null || error.code == "conflict") "current": error.current,
      });
    }
  }

  http.StreamedResponse _route(
    String method,
    String route,
    Map<String, String> query,
    Map<String, String> headers,
    Uint8List body,
  ) {
    final segments = route.split("/").where((segment) => segment.isNotEmpty).toList();
    return switch ((method, route)) {
      ("GET", "/files/list") => _list(query["path"]!),
      ("GET", "/files/stat") => _json(200, _entry(query["path"]!)),
      ("GET", "/files/content") => _content(query["path"]!, headers),
      ("PUT", "/files/content") => _put(query, body),
      ("POST", "/files/mkdir") => _mkdir(_decode(body)["path"] as String),
      ("POST", "/files/move") => _move(_decode(body)),
      ("DELETE", "/files") => _delete(query),
      ("GET", "/sync/changes") => _changes(int.parse(query["cursor"] ?? "0")),
      ("GET", "/sync/manifest") => _manifest(query["path"]!),
      ("POST", "/sync/uploads") => _createUpload(_decode(body)),
      ("PUT", _) when segments.length == 5 && segments[3] == "chunks" => _putChunk(segments[2], segments[4], body),
      ("POST", _) when segments.length == 4 && segments[3] == "commit" => _commit(segments[2]),
      ("GET", _) when segments.length == 3 && segments[1] == "uploads" => _uploadStatus(segments[2]),
      ("DELETE", _) when segments.length == 3 && segments[1] == "uploads" => _abort(segments[2]),
      _ => throw const _HttpError(404, "not_found"),
    };
  }

  http.StreamedResponse _list(String path) {
    final entries = nodes.keys.where((key) => key != "/" && RemotePath.parent(key) == path).map(_entry).toList();
    return _json(200, {"path": path, "entries": entries, "indexing": indexing});
  }

  http.StreamedResponse _content(String path, Map<String, String> headers) {
    final node = _require(path);
    final ifMatch = headers["If-Match"];
    if (ifMatch != null && ifMatch != "\"${node.rev}\"") throw const _HttpError(412, "precondition_failed");
    final range = headers["Range"];
    if (range == null) return bytesResponse(200, node.bytes);
    final match = RegExp(r"bytes=(\d+)-(\d+)").firstMatch(range)!;
    final start = int.parse(match.group(1)!);
    final end = int.parse(match.group(2)!);
    rangeBytesServed += end - start + 1;
    return bytesResponse(206, node.bytes.sublist(start, end + 1));
  }

  http.StreamedResponse _put(Map<String, String> query, Uint8List body) {
    final path = query["path"]!;
    _checkBaseRev(path, int.parse(query["baseRev"] ?? "0"));
    wholeBytesReceived += body.length;
    putFile(path, body, mtime: DateTime.tryParse(query["mtime"] ?? ""));
    return _json(200, _entry(path));
  }

  http.StreamedResponse _mkdir(String path) {
    if (nodes.containsKey(path)) throw const _HttpError(409, "already_exists");
    _ensureParents(path);
    nodes[path] = FakeNode.dir(++_rev, DateTime.now().toUtc());
    _emitUpsert(path);
    return _json(200, _entry(path));
  }

  http.StreamedResponse _move(Map<String, dynamic> body) {
    final from = body["from"] as String;
    final to = body["to"] as String;
    _checkBaseRev(from, body["baseRev"] as int? ?? -1);
    movePath(from, to);
    return _json(200, _entry(to));
  }

  /// Moves [from] and everything below it in place, emitting a move change per entry like the real server.
  void movePath(String from, String to) {
    _require(from);
    _ensureParents(to);
    final moved = nodes.keys.where((key) => key == from || RemotePath.isWithin(key, from)).toList()
      ..sort((a, b) => a.length.compareTo(b.length));
    for (final oldPath in moved) {
      final newPath = to + oldPath.substring(from.length);
      nodes[newPath] = nodes.remove(oldPath)!..rev = ++_rev;
      changes.add({"seq": ++_seq, "type": "move", "path": newPath, "fromPath": oldPath, "entry": _entry(newPath)});
    }
  }

  http.StreamedResponse _delete(Map<String, String> query) {
    final path = query["path"]!;
    _require(path);
    _checkBaseRev(path, int.parse(query["baseRev"] ?? "-1"));
    deletePath(path);
    return emptyResponse(204);
  }

  http.StreamedResponse _changes(int cursor) {
    final pending = changes.where((change) => (change["seq"] as int) > cursor).toList();
    return _json(200, {"changes": pending, "cursor": _seq, "hasMore": false});
  }

  http.StreamedResponse _manifest(String path) {
    final node = _require(path);
    final manifest = FastCdc.manifestOfBytes(node.bytes);
    return _json(200, {...manifest.copyWith(path: path, rev: node.rev).toJson()});
  }

  http.StreamedResponse _createUpload(Map<String, dynamic> body) {
    final path = body["path"] as String;
    _checkBaseRev(path, body["baseRev"] as int);
    final chunks = [
      for (final chunk in (body["chunks"] as List<dynamic>).cast<Map<String, dynamic>>())
        (chunk["hash"] as String, chunk["size"] as int),
    ];
    final upload = FakeUpload(
      path: path,
      baseRev: body["baseRev"] as int,
      hash: body["hash"] as String,
      mtime: DateTime.parse(body["mtime"] as String),
      chunks: chunks,
    );
    final id = "u${_uploadIds++}";
    uploads[id] = upload;
    return _json(200, {"uploadId": id, "missing": _missing(upload)});
  }

  http.StreamedResponse _putChunk(String id, String hash, Uint8List body) {
    final upload = uploads[id] ?? (throw const _HttpError(404, "not_found"));
    if (sha256.convert(body).toString() != hash) throw const _HttpError(400, "invalid_request");
    chunkBytesReceived += body.length;
    upload.received[hash] = body;
    return emptyResponse(204);
  }

  http.StreamedResponse _uploadStatus(String id) {
    final upload = uploads[id] ?? (throw const _HttpError(404, "not_found"));
    return _json(200, {"uploadId": id, "missing": _missing(upload)});
  }

  http.StreamedResponse _commit(String id) {
    final upload = uploads.remove(id) ?? (throw const _HttpError(404, "not_found"));
    _checkBaseRev(upload.path, upload.baseRev);
    final known = _knownChunks(upload.path);
    final builder = BytesBuilder();
    for (final (hash, _) in upload.chunks) {
      builder.add(upload.received[hash] ?? known[hash]!);
    }
    final bytes = builder.takeBytes();
    if (sha256.convert(bytes).toString() != upload.hash) throw const _HttpError(400, "invalid_request");
    putFile(upload.path, bytes, mtime: upload.mtime);
    return _json(200, _entry(upload.path));
  }

  http.StreamedResponse _abort(String id) {
    uploads.remove(id);
    return emptyResponse(204);
  }

  List<String> _missing(FakeUpload upload) {
    final known = _knownChunks(upload.path);
    return {
      for (final (hash, _) in upload.chunks)
        if (!known.containsKey(hash) && !upload.received.containsKey(hash)) hash,
    }.toList();
  }

  Map<String, Uint8List> _knownChunks(String path) {
    final node = nodes[path];
    if (node == null || node.isDir) return {};
    return {
      for (final chunk in FastCdc.manifestOfBytes(node.bytes).chunks)
        chunk.hash: node.bytes.sublist(chunk.offset, chunk.end),
    };
  }

  void _checkBaseRev(String path, int baseRev) {
    final node = nodes[path];
    if (baseRev == -1) return;
    if (baseRev == 0 && node != null) throw _HttpError(409, "conflict", current: _entry(path));
    if (baseRev > 0 && node?.rev != baseRev) {
      throw _HttpError(409, "conflict", current: node == null ? null : _entry(path));
    }
  }

  void _ensureParents(String path) {
    for (final ancestor in RemotePath.ancestry(RemotePath.parent(path))) {
      if (nodes.containsKey(ancestor)) continue;
      nodes[ancestor] = FakeNode.dir(++_rev, DateTime.now().toUtc());
      _emitUpsert(ancestor);
    }
  }

  void _emitUpsert(String path) => changes.add({"seq": ++_seq, "type": "upsert", "path": path, "entry": _entry(path)});

  FakeNode _require(String path) => nodes[path] ?? (throw const _HttpError(404, "not_found"));

  Map<String, dynamic> _entry(String path) {
    final node = _require(path);
    return {
      "path": path,
      "name": RemotePath.name(path),
      "isDir": node.isDir,
      "size": node.bytes.length,
      "mtime": node.mtime.toIso8601String(),
      "rev": node.rev,
      "hash": node.hash,
      "mime": "",
      "meta": <String, dynamic>{},
      "previewState": "none",
    };
  }

  http.StreamedResponse _json(int status, Object body) => jsonResponse(status, body);

  Map<String, dynamic> _decode(Uint8List body) => jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
}

class _HttpError implements Exception {
  const _HttpError(this.status, this.code, {this.current});

  final int status;
  final String code;
  final Map<String, dynamic>? current;
}
