import "package:freezed_annotation/freezed_annotation.dart";

import "package:polder/models/file_entry.dart";

part "file_links.freezed.dart";

@freezed
abstract class FileLinks with _$FileLinks {
  const factory FileLinks({
    @Default(<OutgoingLink>[]) List<OutgoingLink> outgoing,
    @Default(<IncomingLink>[]) List<IncomingLink> incoming,
  }) = _FileLinks;
}

@freezed
abstract class OutgoingLink with _$OutgoingLink {
  const factory OutgoingLink({required String title, required String targetPath, FileEntry? target}) = _OutgoingLink;
}

@freezed
abstract class IncomingLink with _$IncomingLink {
  const factory IncomingLink({required String title, required FileEntry source}) = _IncomingLink;
}
