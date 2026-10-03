import "package:freezed_annotation/freezed_annotation.dart";

part "upload_session.freezed.dart";
part "upload_session.g.dart";

@freezed
abstract class UploadSession with _$UploadSession {
  const factory UploadSession({required String uploadId, @Default(<String>[]) List<String> missing}) = _UploadSession;

  factory UploadSession.fromJson(Map<String, dynamic> json) => _$UploadSessionFromJson(json);
}

@freezed
abstract class UploadChunkSpec with _$UploadChunkSpec {
  const factory UploadChunkSpec({required String hash, required int size}) = _UploadChunkSpec;

  factory UploadChunkSpec.fromJson(Map<String, dynamic> json) => _$UploadChunkSpecFromJson(json);
}

@freezed
abstract class UploadRequest with _$UploadRequest {
  const factory UploadRequest({
    required String path,
    required int baseRev,
    required int size,
    required String hash,
    required DateTime mtime,
    required List<UploadChunkSpec> chunks,
  }) = _UploadRequest;

  factory UploadRequest.fromJson(Map<String, dynamic> json) => _$UploadRequestFromJson(json);
}
