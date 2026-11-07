import "package:flutter_test/flutter_test.dart";

import "package:polder/services/notifications/local_notification.dart";

void main() {
  test("a tap carries the location, the action and the data back", () {
    const notification = LocalNotification(
      id: 1,
      channel: NotificationChannel.sharing,
      title: "bob shared Photos with you",
      location: "/shared/with-me/4",
      data: {"shareId": 4, "federated": false},
    );

    final tap = NotificationTap.decode(notification.payload, "accept");

    expect(tap.location, "/shared/with-me/4");
    expect(tap.action, NotificationActionId.accept);
    expect(tap.data, {"shareId": 4, "federated": false});
  });

  test("a broken or empty payload still reports the action", () {
    expect(NotificationTap.decode("not json", "decline").action, NotificationActionId.decline);
    expect(NotificationTap.decode("", null).location, isNull);
    expect(NotificationTap.decode(null, "unknown").action, isNull);
  });

  test("ids for feed items and calendar reminders never collide", () {
    final calendar = NotificationIds.calendar("3|9||1762419000000");
    expect(NotificationIds.isCalendar(calendar), isTrue);
    expect(NotificationIds.isCalendar(NotificationIds.feed(1 << 30)), isFalse);
    expect(NotificationIds.isCalendar(NotificationIds.upload), isFalse);
    expect(NotificationIds.calendar("3|9||1762419000000"), calendar);
    expect(calendar, lessThan(1 << 31));
  });
}
