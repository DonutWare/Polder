import "package:flutter/foundation.dart";

import "package:polder/services/notifications/local_notification.dart";

enum NotificationPermission { granted, denied, notAsked }

class NotificationCapabilities {
  const NotificationCapabilities({
    required this.scheduling,
    required this.progress,
    required this.backgroundActions,
    required this.exactAlarms,
    required this.batteryOptimization,
  });

  factory NotificationCapabilities.current() {
    final platform = kIsWeb ? null : defaultTargetPlatform;
    final android = platform == TargetPlatform.android;
    final apple = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    return NotificationCapabilities(
      scheduling: android || apple,
      progress: android,
      backgroundActions: android || apple,
      exactAlarms: android,
      batteryOptimization: android,
    );
  }

  final bool scheduling;
  final bool progress;
  final bool backgroundActions;
  final bool exactAlarms;
  final bool batteryOptimization;
}

abstract interface class NotificationService {
  NotificationCapabilities get capabilities;

  Stream<NotificationTap> get taps;

  Future<NotificationTap?> launchTap();

  Future<NotificationPermission> permission();

  Future<bool> requestPermission();

  Future<bool> canScheduleExactly();

  Future<void> show(LocalNotification notification);

  Future<void> schedule(LocalNotification notification, DateTime at);

  Future<void> cancel(int id);

  Future<Set<int>> scheduledIds();
}
