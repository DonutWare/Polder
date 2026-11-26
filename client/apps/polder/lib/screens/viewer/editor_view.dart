export "package:polder/screens/viewer/editor_view_native.dart"
    if (dart.library.js_interop) "package:polder/screens/viewer/editor_view_web.dart";

abstract interface class EditorChannel {
  void send(Map<String, Object?> message);
}

typedef EditorMessageHandler = void Function(Map<String, Object?> message);
