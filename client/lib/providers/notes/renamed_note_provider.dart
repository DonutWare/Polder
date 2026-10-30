import "package:flutter_riverpod/flutter_riverpod.dart";

typedef NoteRename = ({String from, String to});

final renamedNoteProvider = NotifierProvider<RenamedNote, NoteRename?>(RenamedNote.new);

class RenamedNote extends Notifier<NoteRename?> {
  @override
  NoteRename? build() => null;

  void record(String from, String to) => state = (from: from, to: to);
}
