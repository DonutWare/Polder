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
  FakeUpload.fromJson(Map<String, dynamic> json)
    : path = json["path"] as String,
      baseRev = json["baseRev"] as int,
      hash = json["hash"] as String,
      mtime = DateTime.parse(json["mtime"] as String),
      chunks = [
        for (final chunk in (json["chunks"] as List<dynamic>).cast<Map<String, dynamic>>())
          (chunk["hash"] as String, chunk["size"] as int),
      ];

  final String path;
  final int baseRev;
  final String hash;
  final DateTime mtime;
  final List<(String, int)> chunks;
  Map<String, dynamic>? result;
}

class FakeBatch {
  FakeBatch(this.files);

  final List<FakeUpload> files;
  final Map<String, Uint8List> staged = {};
  final Set<String> corrupt = {};

  Iterable<FakeUpload> get unfinished => files.where((file) => file.result == null);

  List<Map<String, dynamic>> get results => [for (final file in files) ?file.result];
}

class FakePolderServer extends http.BaseClient {
  FakePolderServer() {
    nodes["/"] = FakeNode.dir(0, DateTime.utc(2026));
  }

  final Map<String, FakeNode> nodes = {};
  final List<Map<String, dynamic>> changes = [];
  final Map<String, FakeBatch> batches = {};
  final List<String> requests = [];
  bool indexing = false;
  int rangeBytesServed = 0;
  int chunkBytesReceived = 0;
  bool failNextPut = false;
  final _ids = <String, int>{};

  int idOf(String path) => _ids.putIfAbsent(path, () => _ids.length + 1);
  int wholeBytesReceived = 0;
  var _rev = 0;
  var _seq = 0;
  var _batchIds = 0;

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
    final uri = request.url;
    final route = uri.path.replaceFirst("/api/v1", "");
    requests.add("${request.method} $route");
    try {
      final streamed = _streamedBatch(request.method, route);
      if (streamed != null) return await _receiveStream(streamed, request.finalize());
      final body = await request.finalize().toBytes();
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
      ("POST", "/files/copy") => _copy(_decode(body)),
      ("POST", "/files/resolve") => _resolve(_decode(body)),
      ("DELETE", "/files") => _delete(query),
      ("GET", "/link-previews") => _linkPreview(query["url"]!),
      ("GET", "/sync/changes") => _changes(int.parse(query["cursor"] ?? "0")),
      ("GET", "/sync/manifest") => _manifest(query["path"]!),
      ("POST", "/sync/batches") => _createBatch(_decode(body)),
      ("POST", "/sync/downloads") => _downloadBatch(_decode(body)),
      ("GET", _) when segments.length == 3 && segments[1] == "batches" => _batchStatus(segments[2]),
      ("DELETE", _) when segments.length == 3 && segments[1] == "batches" => _abortBatch(segments[2]),
      _ => throw const _HttpError(404, "not_found"),
    };
  }

  http.StreamedResponse _linkPreview(String url) {
    final host = Uri.parse(url).host;
    return _json(200, {"url": url, "siteName": host, "title": "Page on $host", "hasImage": false, "hasIcon": false});
  }

  http.StreamedResponse _resolve(Map<String, dynamic> body) {
    final wanted = (body["ids"] as List).cast<int>().toSet();
    final entries = [
      for (final MapEntry(key: path, value: id) in _ids.entries)
        if (wanted.contains(id) && nodes.containsKey(path)) _entry(path),
    ];
    return _json(200, {"entries": entries});
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
    if (failNextPut) {
      failNextPut = false;
      throw const _HttpError(500, "internal");
    }
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

  http.StreamedResponse _copy(Map<String, dynamic> body) {
    final from = body["from"] as String;
    final to = body["to"] as String;
    _require(from);
    if (nodes.containsKey(to)) throw const _HttpError(409, "conflict");
    _ensureParents(to);
    final copied = nodes.keys.where((key) => key == from || RemotePath.isWithin(key, from)).toList()
      ..sort((a, b) => a.length.compareTo(b.length));
    for (final oldPath in copied) {
      final source = nodes[oldPath]!;
      final newPath = to + oldPath.substring(from.length);
      nodes[newPath] = source.isDir
          ? FakeNode.dir(++_rev, source.mtime)
          : FakeNode.file(Uint8List.fromList(source.bytes), ++_rev, source.mtime);
      _emitUpsert(newPath);
    }
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
      if (_ids.remove(oldPath) case final id?) _ids[newPath] = id;
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

  http.StreamedResponse _downloadBatch(Map<String, dynamic> body) {
    final out = BytesBuilder();
    for (final file in (body["files"] as List<dynamic>).cast<Map<String, dynamic>>()) {
      final path = file["path"] as String;
      final node = nodes[path];
      final error = switch (node) {
        null || FakeNode(isDir: true) => "not_found",
        _ when (file["rev"] as int? ?? 0) > 0 && node.rev != file["rev"] => "precondition_failed",
        _ => null,
      };
      final header = error == null
          ? {"path": path, "rev": node!.rev, "size": node.bytes.length, "hash": node.hash}
          : {
              "path": path,
              "size": 0,
              "error": {"code": error, "message": error},
            };
      out.add(utf8.encode("${jsonEncode(header)}\n"));
      if (error == null) out.add(node!.bytes);
    }
    return bytesResponse(200, out.takeBytes());
  }

  String? _streamedBatch(String method, String route) {
    final segments = route.split("/").where((segment) => segment.isNotEmpty).toList();
    final isStream = method == "PUT" && segments.length == 4 && segments[1] == "batches" && segments[3] == "stream";
    return isStream ? segments[2] : null;
  }

  http.StreamedResponse _createBatch(Map<String, dynamic> body) {
    final files = [
      for (final file in (body["files"] as List<dynamic>).cast<Map<String, dynamic>>()) FakeUpload.fromJson(file),
    ];
    final batch = FakeBatch(files);
    for (final file in files) {
      try {
        _checkBaseRev(file.path, file.baseRev);
      } on _HttpError catch (error) {
        file.result = _failure(file.path, error);
      }
    }
    for (final other in batches.values) {
      batch.staged.addAll(other.staged);
    }
    final id = "b${_batchIds++}";
    batches[id] = batch;
    return _json(201, _status(id, batch));
  }

  http.StreamedResponse _batchStatus(String id) {
    final batch = batches[id] ?? (throw const _HttpError(404, "not_found"));
    return _json(200, _status(id, batch));
  }

  Future<http.StreamedResponse> _receiveStream(String id, Stream<List<int>> body) async {
    final batch = batches[id] ?? (throw const _HttpError(404, "not_found"));
    final missing = _missing(batch);
    final pending = BytesBuilder();
    var next = 0;
    try {
      await for (final piece in body) {
        pending.add(piece);
        while (next < missing.length && pending.length >= missing[next].$2) {
          final bytes = pending.takeBytes();
          final (hash, size) = missing[next++];
          _stage(batch, hash, Uint8List.sublistView(bytes, 0, size));
          pending.add(Uint8List.sublistView(bytes, size));
        }
      }
    } on Exception catch (error) {
      throw http.ClientException("$error");
    }
    if (next < missing.length) throw const _HttpError(400, "invalid_request");
    for (final file in batch.unfinished) {
      file.result = _commitFile(batch, file);
    }
    batches.remove(id);
    return _json(200, _status(id, batch));
  }

  void _stage(FakeBatch batch, String hash, Uint8List bytes) {
    chunkBytesReceived += bytes.length;
    if (sha256.convert(bytes).toString() == hash) {
      batch.staged[hash] = Uint8List.fromList(bytes);
    } else {
      batch.corrupt.add(hash);
    }
  }

  Map<String, dynamic> _commitFile(FakeBatch batch, FakeUpload file) {
    if (file.chunks.any((chunk) => batch.corrupt.contains(chunk.$1))) {
      return _failure(file.path, const _HttpError(412, "precondition_failed"));
    }
    try {
      _checkBaseRev(file.path, file.baseRev);
    } on _HttpError catch (error) {
      return _failure(file.path, error);
    }
    final known = _reusableChunks(file);
    final builder = BytesBuilder();
    for (final (hash, _) in file.chunks) {
      builder.add(batch.staged[hash] ?? known[hash]!);
    }
    final bytes = builder.takeBytes();
    if (sha256.convert(bytes).toString() != file.hash) {
      return _failure(file.path, const _HttpError(400, "invalid_request"));
    }
    putFile(file.path, bytes, mtime: file.mtime);
    return {"path": file.path, "entry": _entry(file.path)};
  }

  Map<String, dynamic> _failure(String path, _HttpError error) => {
    "path": path,
    "error": {"code": error.code, "message": error.code, "current": ?error.current},
  };

  http.StreamedResponse _abortBatch(String id) {
    batches.remove(id);
    return emptyResponse(204);
  }

  Map<String, dynamic> _status(String id, FakeBatch batch) => {
    "batchId": id,
    "missing": [
      for (final (hash, size) in _missing(batch)) {"hash": hash, "size": size},
    ],
    "results": batch.results,
  };

  List<(String, int)> _missing(FakeBatch batch) {
    final missing = <String, int>{};
    for (final file in batch.unfinished) {
      final known = _reusableChunks(file);
      for (final (hash, size) in file.chunks) {
        if (!known.containsKey(hash) && !batch.staged.containsKey(hash)) missing.putIfAbsent(hash, () => size);
      }
    }
    return [for (final MapEntry(:key, :value) in missing.entries) (key, value)];
  }

  Map<String, Uint8List> _reusableChunks(FakeUpload file) => file.chunks.length > 1 ? _knownChunks(file.path) : {};

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

  static const _mediaMimes = {"jpg": "image/jpeg", "png": "image/png", "mp4": "video/mp4"};

  Map<String, dynamic> _entry(String path) {
    final node = _require(path);
    return {
      "id": idOf(path),
      "path": path,
      "name": RemotePath.name(path),
      "isDir": node.isDir,
      "size": node.bytes.length,
      "mtime": node.mtime.toIso8601String(),
      "rev": node.rev,
      "hash": node.hash,
      "mime": node.isDir ? "" : _mediaMimes[RemotePath.extension(path).toLowerCase()] ?? "",
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

class SignedInServer extends http.BaseClient {
  SignedInServer(this.server);

  final FakePolderServer server;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path == "/api/v1/auth/me") return jsonResponse(200, userJson());
    return server.send(request);
  }
}
