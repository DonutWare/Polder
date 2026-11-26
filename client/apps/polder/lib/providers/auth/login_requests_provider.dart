import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder_core/models/security.dart";
import "package:polder_core/models/server_event.dart";
import "package:polder_core/providers/account_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_core/providers/polder_api_provider.dart";
import "package:polder_core/providers/realtime/events_provider.dart";
import "package:polder_core/services/notifications/local_notification.dart";
import "package:polder_core/services/realtime/events_client.dart";

final loginRequestsProvider = NotifierProvider<LoginRequestsNotifier, List<LoginRequest>>(LoginRequestsNotifier.new);

class LoginRequestsNotifier extends Notifier<List<LoginRequest>> {
  @override
  List<LoginRequest> build() {
    final client = ref.watch(eventsClientProvider);
    final userId = ref.watch(currentAccountProvider.select((account) => account?.user.id));
    if (client == null || userId == null) return const [];
    final events = client.events.listen((event) {
      switch (event) {
        case LoginRequestedEvent(userId: final owner, :final request) when owner == userId:
          state = [...state.where((pending) => pending.id != request.id), request];
          unawaited(_notify(request));
        case LoginResolvedEvent(userId: final owner, :final requestId) when owner == userId:
          state = state.where((pending) => pending.id != requestId).toList();
        default:
      }
    });
    final statuses = client.statusChanges.listen((status) {
      if (status == RealtimeStatus.connected) unawaited(refresh());
    });
    ref.onDispose(() {
      unawaited(events.cancel());
      unawaited(statuses.cancel());
    });
    Future.microtask(refresh);
    return const [];
  }

  Future<void> _notify(LoginRequest request) async {
    final strings = ref.read(notificationStringsProvider);
    try {
      await ref
          .read(notificationServiceProvider)
          .show(
            LocalNotification(
              id: NotificationIds.loginRequest,
              channel: NotificationChannel.security,
              title: strings.loginApprovalNotificationTitle(request.device),
              body: strings.loginApprovalNotificationBody(request.address),
            ),
          );
    } on Object {
      return;
    }
  }

  Future<void> refresh() async {
    try {
      final pending = await ref.read(polderApiProvider).loginRequests();
      if (ref.mounted) state = pending;
    } on Object {
      return;
    }
  }

  Future<void> approve(LoginRequest request, int number) async {
    _forget(request);
    await ref.read(polderApiProvider).approveLoginRequest(request.id, number);
  }

  Future<void> deny(LoginRequest request) async {
    _forget(request);
    await ref.read(polderApiProvider).denyLoginRequest(request.id);
  }

  void _forget(LoginRequest request) {
    state = state.where((pending) => pending.id != request.id).toList();
    unawaited(ref.read(notificationServiceProvider).cancel(NotificationIds.loginRequest).catchError((Object _) {}));
  }
}
