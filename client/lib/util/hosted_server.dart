import "package:flutter/foundation.dart";

/// Where the server is when this is the web client bundled with (and served by) a Nomad server:
/// the page's own origin. Native apps have none and ask for a server.
abstract final class HostedServer {
  static String? get url => kIsWeb ? Uri.base.origin : null;
}
