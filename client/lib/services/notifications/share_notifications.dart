import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/models/notifications/feed_notification.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/services/api/polder_api.dart";
import "package:polder/services/notifications/local_notification.dart";

abstract final class ShareNotifications {
  static const _shareId = "shareId";
  static const _federated = "federated";

  static LocalNotification? build(FeedNotification notification, AppLocalizations strings) {
    final share = notification.share;
    if (share == null) return null;
    final group = share.group;
    return LocalNotification(
      id: NotificationIds.feed(notification.id),
      channel: NotificationChannel.sharing,
      title: group == null
          ? strings.notificationShareTitle(share.ownerName, share.name)
          : strings.notificationShareGroupTitle(share.ownerName, share.name, group),
      body: [
        if (share.server case final server?) strings.notificationFederatedShareBody(server),
        if (share.note.isNotEmpty) share.note,
      ].join("\n"),
      location: notification.federated
          ? AppRoutes.sharedSection(SharedSection.federated.segment)
          : AppRoutes.sharedAt(share.shareId),
      actions: [
        NotificationAction(NotificationActionId.accept, strings.accept),
        NotificationAction(NotificationActionId.decline, strings.decline, destructive: true),
      ],
      data: {_shareId: share.shareId, _federated: notification.federated},
    );
  }

  static bool handles(NotificationTap tap) => tap.action != null && tap.data[_shareId] is int;

  static Future<void> respond(PolderApi api, NotificationTap tap) async {
    final shareId = tap.data[_shareId] as int;
    final federated = tap.data[_federated] == true;
    switch ((tap.action!, federated)) {
      case (NotificationActionId.accept, false):
        await api.acceptShare(shareId);
      case (NotificationActionId.decline, false):
        await api.declineShare(shareId);
      case (NotificationActionId.accept, true):
        await api.acceptFederatedShare(shareId);
      case (NotificationActionId.decline, true):
        await api.removeIncomingFederatedShare(shareId);
    }
  }
}
