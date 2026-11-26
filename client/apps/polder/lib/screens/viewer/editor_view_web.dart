import "dart:convert";
import "dart:js_interop";

import "package:flutter/material.dart";

import "package:web/web.dart" as web;

import "package:polder/screens/viewer/editor_view.dart";

class EditorView extends StatefulWidget {
  const EditorView({
    required this.page,
    required this.onMessage,
    required this.onReady,
    this.interactive = true,
    super.key,
  });

  final Uri page;
  final bool interactive;
  final EditorMessageHandler onMessage;
  final ValueChanged<EditorChannel> onReady;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> implements EditorChannel {
  web.HTMLIFrameElement? _frame;
  late final JSFunction _listener = _receive.toJS;

  @override
  void initState() {
    super.initState();
    web.window.addEventListener("message", _listener);
  }

  @override
  void dispose() {
    web.window.removeEventListener("message", _listener);
    super.dispose();
  }

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) _frame?.src = widget.page.toString();
    if (oldWidget.interactive != widget.interactive) _applyInteractive();
  }

  void _applyInteractive() => _frame?.style.pointerEvents = widget.interactive ? "auto" : "none";

  void _receive(web.MessageEvent event) {
    if (event.origin != widget.page.origin) return;
    if (event.data.dartify() case {"polderOffice": final String raw}) {
      if (jsonDecode(raw) case final Map<String, Object?> message) widget.onMessage(message);
    }
  }

  @override
  void send(Map<String, Object?> message) {
    _frame?.contentWindow?.postMessage({"polderOffice": jsonEncode(message)}.jsify(), widget.page.origin.toJS);
  }

  @override
  Widget build(BuildContext context) => HtmlElementView.fromTagName(
    tagName: "iframe",
    onElementCreated: (element) {
      final frame = element as web.HTMLIFrameElement
        ..allow = "clipboard-read; clipboard-write; fullscreen"
        ..src = widget.page.toString();
      frame.style
        ..border = "none"
        ..width = "100%"
        ..height = "100%";
      _frame = frame;
      _applyInteractive();
      widget.onReady(this);
    },
  );
}
