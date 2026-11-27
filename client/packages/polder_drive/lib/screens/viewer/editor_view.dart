export "package:polder_drive/screens/viewer/editor_view_native.dart"
    if (dart.library.js_interop) "package:polder_drive/screens/viewer/editor_view_web.dart";

abstract interface class EditorChannel {
  void send(Map<String, Object?> message);
}

typedef EditorMessageHandler = void Function(Map<String, Object?> message);
