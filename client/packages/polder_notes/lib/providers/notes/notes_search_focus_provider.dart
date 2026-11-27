import "package:flutter_riverpod/flutter_riverpod.dart";

final notesSearchFocusRequestProvider = NotifierProvider<NotesSearchFocusRequest, int>(NotesSearchFocusRequest.new);

class NotesSearchFocusRequest extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}
