import "dart:async";

import "package:chopper/chopper.dart";

import "package:polder/services/api/generated/polder.swagger.dart";
import "package:polder/services/api/pending_uploads.dart";

class PolderConverter extends $JsonSerializableConverter {
  PolderConverter(this._uploads);

  static const octetStream = "application/octet-stream";

  final PendingUploads _uploads;

  @override
  Request convertRequest(Request request) => switch (request.body) {
    final PendingUpload upload => applyHeaders(request.copyWith(body: const <int>[]), {
      contentTypeKey: octetStream,
      PendingUploads.header: _uploads.add(upload),
    }),
    List<int>() => applyHeader(request, contentTypeKey, octetStream),
    _ => super.convertRequest(request),
  };

  @override
  FutureOr<Response<ResultType>> convertResponse<ResultType, Item>(Response<dynamic> response) {
    if (response.body is Stream<List<int>>) return response.copyWith<ResultType>();
    return super.convertResponse<ResultType, Item>(response);
  }
}
