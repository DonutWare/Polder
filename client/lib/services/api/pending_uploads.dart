import "package:chopper/chopper.dart";
import "package:http/http.dart" as http;

class PendingUpload {
  const PendingUpload(this.bytes, this.length);

  final Stream<List<int>> bytes;
  final int length;
}

class PendingUploads {
  static const header = "x-nomad-upload";

  final _uploads = <String, PendingUpload>{};
  var _nextId = 0;

  String add(PendingUpload upload) {
    final id = "${_nextId++}";
    _uploads[id] = upload;
    return id;
  }

  PendingUpload? take(String id) => _uploads.remove(id);

  static bool isUpload(Request request) => request.headers.containsKey(header);
}

class UploadingClient extends http.BaseClient {
  UploadingClient(this._inner, this._uploads);

  final http.Client _inner;
  final PendingUploads _uploads;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final id = request.headers.remove(PendingUploads.header);
    final upload = id == null ? null : _uploads.take(id);
    return _inner.send(upload == null ? request : _UploadRequest(request, upload));
  }

  @override
  void close() => _inner.close();
}

class _UploadRequest extends http.BaseRequest {
  _UploadRequest(http.BaseRequest original, this._upload) : super(original.method, original.url) {
    headers.addAll(original.headers);
    contentLength = _upload.length;
  }

  final PendingUpload _upload;

  @override
  http.ByteStream finalize() {
    super.finalize();
    return http.ByteStream(_upload.bytes);
  }
}
