import "package:freezed_annotation/freezed_annotation.dart";
import "package:polder/models/file_entry.dart";

part "note_item.freezed.dart";

@freezed
abstract class NoteItem with _$NoteItem {
  const factory NoteItem({required FileEntry entry, @Default(false) bool hasNotes, @Default(false) bool hasReadme}) =
      _NoteItem;
}
