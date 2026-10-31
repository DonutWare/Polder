import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/browser_view_provider.dart";
import "package:polder/providers/browser/directory_provider.dart";

final mediaSiblingsProvider = Provider.autoDispose.family<List<FileEntry>?, String>((ref, folder) {
  final listing = ref.watch(directoryProvider(folder)).value;
  if (listing == null) return null;
  return ref.watch(browserSortProvider).apply(listing.entries).where((entry) => entry.isViewableMedia).toList();
});
