import "package:polder_core/models/file_entry.dart";

class MediaGallery {
  const MediaGallery(this.entry, this.items);

  final FileEntry entry;
  final List<FileEntry> items;
}
