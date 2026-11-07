import "package:polder/models/notifications/feed_notification.dart";
import "package:polder/services/api/generated/polder.swagger.dart" as wire;

extension FeedNotificationToModel on wire.Notification {
  FeedNotification? toModel() {
    final kind = switch (this.kind) {
      wire.NotificationKind.shareReceived => FeedNotificationKind.shareReceived,
      wire.NotificationKind.federatedShareReceived => FeedNotificationKind.federatedShareReceived,
      wire.NotificationKind.swaggerGeneratedUnknown => null,
    };
    if (kind == null) return null;
    return FeedNotification(id: id, kind: kind, createdAt: createdAt.toLocal(), read: read, share: share?.toModel());
  }
}

extension ShareNoticeToModel on wire.ShareNotice {
  ShareNotice toModel() => ShareNotice(
    shareId: shareId,
    ownerName: ownerName,
    owner: owner,
    name: name,
    isDir: isDir,
    note: note ?? "",
    group: group,
    server: server,
  );
}

extension FeedPageToModel on wire.NotificationPage {
  FeedPage toModel() => FeedPage(
    notifications: [...?notifications?.map((notification) => notification.toModel()).nonNulls],
    cursor: cursor,
    hasMore: hasMore,
  );
}
