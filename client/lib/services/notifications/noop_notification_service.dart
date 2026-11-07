import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_service.dart";

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  NotificationCapabilities get capabilities => const NotificationCapabilities(
    scheduling: false,
    progress: false,
    backgroundActions: false,
    exactAlarms: false,
    batteryOptimization: false,
  );

  @override
  Stream<NotificationTap> get taps => const Stream.empty();

  @override
  Future<NotificationTap?> launchTap() async => null;

  @override
  Future<NotificationPermission> permission() async => NotificationPermission.denied;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> canScheduleExactly() async => false;

  @override
  Future<void> show(LocalNotification notification) async {}

  @override
  Future<void> schedule(LocalNotification notification, DateTime at) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<Set<int>> scheduledIds() async => const {};
}
