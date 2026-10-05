import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/providers/account_provider.dart";
import "package:polder/providers/activity/activity_scope_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/services/api/api_exceptions.dart";
import "package:polder/services/realtime/events_client.dart";

final eventsClientProvider = Provider<EventsClient?>((ref) {
  final connect = ref.watch(webSocketConnectorProvider);
  final accountId = ref.watch(currentAccountProvider.select((account) => account?.id));
  final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl));
  if (connect == null || accountId == null || serverUrl == null) return null;

  final client = EventsClient(
    endpoint: EventsClient.endpointFor(serverUrl),
    connect: connect,
    token: ({required refresh}) async {
      if (refresh) {
        try {
          await ref.read(polderApiProvider).me();
        } on ApiException {
          return null;
        }
      }
      return ref.read(currentAccountProvider)?.accessToken;
    },
  );
  ref.listen(currentAccountProvider.select((account) => account?.accessToken), (previous, next) {
    if (next != null && next != previous) client.reauthenticate(next);
  });
  ref.listen(activityScopeProvider, (_, scope) => client.subscribe(scope), fireImmediately: true);
  client.start();
  ref.onDispose(() => unawaited(client.dispose()));
  return client;
});

final realtimeStatusProvider = StreamProvider<RealtimeStatus>((ref) async* {
  final client = ref.watch(eventsClientProvider);
  if (client == null) {
    yield RealtimeStatus.offline;
    return;
  }
  yield client.status;
  yield* client.statusChanges;
});
