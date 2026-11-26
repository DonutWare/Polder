import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:polder/screens/viewer/editor_view.dart";
import "package:url_launcher/url_launcher.dart";

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
  InAppWebViewController? _controller;

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) _controller?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(widget.page)));
  }

  @override
  void send(Map<String, Object?> message) {
    _controller?.evaluateJavascript(source: "window.polderOffice && window.polderOffice.send(${jsonEncode(message)})");
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(ignoring: !widget.interactive, child: _webView());

  Widget _webView() => InAppWebView(
    initialUrlRequest: URLRequest(url: WebUri.uri(widget.page)),
    initialSettings: InAppWebViewSettings(
      isInspectable: kDebugMode,
      transparentBackground: true,
      supportZoom: false,
      supportMultipleWindows: true,
      useShouldOverrideUrlLoading: true,
    ),
    onWebViewCreated: (controller) {
      _controller = controller;
      controller.addJavaScriptHandler(
        handlerName: "office",
        callback: (List<dynamic> arguments) {
          if (arguments.firstOrNull case final String raw) {
            if (jsonDecode(raw) case final Map<String, Object?> message) widget.onMessage(message);
          }
          return null;
        },
      );
      widget.onReady(this);
    },
    shouldOverrideUrlLoading: (_, action) async {
      final url = action.request.url;
      if (url == null || !action.isForMainFrame || url.origin == widget.page.origin) {
        return NavigationActionPolicy.ALLOW;
      }
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return NavigationActionPolicy.CANCEL;
    },
    onCreateWindow: (_, action) async {
      final url = action.request.url;
      if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
      return false;
    },
  );
}
