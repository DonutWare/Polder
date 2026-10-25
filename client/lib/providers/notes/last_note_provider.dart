import "package:flutter_riverpod/flutter_riverpod.dart";

final lastNoteProvider = NotifierProvider<LastNote, String?>(LastNote.new);

class LastNote extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? path) => state = path;
}
