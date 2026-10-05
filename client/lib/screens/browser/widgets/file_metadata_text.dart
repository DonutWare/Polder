import "package:flutter/material.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/date_format_extension.dart";
import "package:polder/util/localization_helper.dart";

class FileMetadataText extends StatelessWidget {
  const FileMetadataText({required this.entry, super.key});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) => Text(
    [
      if (!entry.isDir) ByteFormat.format(entry.size, locale: context.localeName),
      entry.mtime.formatted(context),
      if (entry.width != null && entry.height != null) context.localized.dimensions(entry.width!, entry.height!),
    ].join(" · "),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
