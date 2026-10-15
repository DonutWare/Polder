import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/services/api/api_exceptions.dart";

part "upload_batch.freezed.dart";
part "upload_batch.g.dart";

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

class UploadFileResult {
  const UploadFileResult({required this.path, this.entry, this.error});

  final String path;
  final FileEntry? entry;
  final ApiException? error;
}

class UploadBatchStatus {
  const UploadBatchStatus({required this.batchId, this.missing = const [], this.results = const []});

  final String batchId;
  final List<UploadChunkSpec> missing;
  final List<UploadFileResult> results;

  int get missingBytes => missing.fold(0, (sum, chunk) => sum + chunk.size);
}
