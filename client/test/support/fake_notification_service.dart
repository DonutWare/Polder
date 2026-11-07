import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_service.dart";

class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.scheduling = true});

  final bool scheduling;
  final shown = <LocalNotification>[];
  final scheduled = <int, (LocalNotification, DateTime)>{};
  final cancelled = <int>[];

  @override
  NotificationCapabilities get capabilities => NotificationCapabilities(
    scheduling: scheduling,
    progress: true,
    backgroundActions: true,
    exactAlarms: false,
    batteryOptimization: false,
  );

  @override
  Stream<NotificationTap> get taps => const Stream.empty();

  @override
  Future<NotificationTap?> launchTap() async => null;

  @override
  Future<NotificationPermission> permission() async => NotificationPermission.granted;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> canScheduleExactly() async => true;

  @override
  Future<void> show(LocalNotification notification) async => shown.add(notification);

  @override
  Future<void> schedule(LocalNotification notification, DateTime at) async =>
      scheduled[notification.id] = (notification, at);

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<Set<int>> scheduledIds() async => scheduled.keys.toSet();
}
