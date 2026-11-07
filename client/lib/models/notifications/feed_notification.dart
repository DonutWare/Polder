import "package:freezed_annotation/freezed_annotation.dart";

part "feed_notification.freezed.dart";

enum FeedNotificationKind { shareReceived, federatedShareReceived }

@freezed
abstract class ShareNotice with _$ShareNotice {
  const factory ShareNotice({
    required int shareId,
    required String ownerName,
    required String owner,
    required String name,
    @Default(false) bool isDir,
    @Default("") String note,
    String? group,
    String? server,
  }) = _ShareNotice;
}

@freezed
abstract class FeedNotification with _$FeedNotification {
  const FeedNotification._();

  const factory FeedNotification({
    required int id,
    required FeedNotificationKind kind,
    required DateTime createdAt,
    @Default(false) bool read,
    ShareNotice? share,
  }) = _FeedNotification;

  bool get federated => kind == FeedNotificationKind.federatedShareReceived;
}

@freezed
abstract class FeedPage with _$FeedPage {
  const factory FeedPage({
    @Default(<FeedNotification>[]) List<FeedNotification> notifications,
    required int cursor,
    @Default(false) bool hasMore,
  }) = _FeedPage;
}
