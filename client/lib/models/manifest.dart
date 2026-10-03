import "package:freezed_annotation/freezed_annotation.dart";

part "manifest.freezed.dart";
part "manifest.g.dart";

@freezed
abstract class ChunkRef with _$ChunkRef {
  const ChunkRef._();

  const factory ChunkRef({required String hash, @Default(0) int offset, required int size}) = _ChunkRef;

  factory ChunkRef.fromJson(Map<String, dynamic> json) => _$ChunkRefFromJson(json);

  int get end => offset + size;
}

@freezed
abstract class Manifest with _$Manifest {
  const Manifest._();

  const factory Manifest({
    @Default("") String path,
    @Default(0) int rev,
    required int size,
    required String hash,
    @Default(<ChunkRef>[]) List<ChunkRef> chunks,
  }) = _Manifest;

  factory Manifest.fromJson(Map<String, dynamic> json) => _$ManifestFromJson(json);

  Map<String, ChunkRef> get chunksByHash => {for (final chunk in chunks) chunk.hash: chunk};
}
