import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/services/deep_link/share_link_target.dart";

final incomingLinksProvider = Provider<Stream<Uri>>((ref) => kIsWeb ? const Stream.empty() : AppLinks().uriLinkStream);

final deepLinkHandlerProvider = Provider<void>((ref) {
  final subscription = ref.watch(incomingLinksProvider).listen((uri) {
    final target = ShareLinkTarget.parse(uri);
    if (target != null) unawaited(_open(ref, target));
  });
  ref.onDispose(subscription.cancel);
});

Future<void> _open(Ref ref, ShareLinkTarget target) async {
  final account = await ref.read(accountProvider.future);
  final api = target.isOn(account?.serverUrl) ? ref.read(polderApiProvider) : null;
  final location = await target.locationFor(api);
  ref.read(routerProvider).go(location);
}
