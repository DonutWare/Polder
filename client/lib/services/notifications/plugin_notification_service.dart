import "dart:async";

import "package:flutter/foundation.dart";

import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/services/notifications/device_localizations.dart";
import "package:polder/services/notifications/local_notification.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:timezone/timezone.dart" as tz;

class PluginNotificationService implements NotificationService {
  PluginNotificationService._(this._plugin, this._strings);

  static const _shareCategory = "share";
  static const _androidIcon = "ic_notification";
  static const _androidCalendarIcon = "ic_notification_calendar";

  static Future<PluginNotificationService> initialize({
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    final strings = deviceLocalizations();
    final service = PluginNotificationService._(FlutterLocalNotificationsPlugin(), strings);
    await service._plugin.initialize(
      settings: _settings(strings),
      onDidReceiveNotificationResponse: service._receive,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    return service;
  }

  static InitializationSettings _settings(AppLocalizations strings) {
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _shareCategory,
          actions: [
            DarwinNotificationAction.plain(NotificationActionId.accept.name, strings.accept),
            DarwinNotificationAction.plain(
              NotificationActionId.decline.name,
              strings.decline,
              options: {DarwinNotificationActionOption.destructive},
            ),
          ],
        ),
      ],
    );
    return InitializationSettings(
      android: const AndroidInitializationSettings(_androidIcon),
      iOS: darwin,
      macOS: darwin,
      linux: LinuxInitializationSettings(defaultActionName: strings.open),
      windows: const WindowsInitializationSettings(
        appName: "Polder",
        appUserModelId: "Knaapen.Polder.Desktop",
        guid: "948b0967-808d-46b1-86b7-3faf78a37231",
      ),
      web: const WebInitializationSettings(),
    );
  }

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _strings;
  final _taps = StreamController<NotificationTap>.broadcast();
  var _refused = false;

  @override
  final capabilities = NotificationCapabilities.current();

  @override
  Stream<NotificationTap> get taps => _taps.stream;

  void _receive(NotificationResponse response) =>
      _taps.add(NotificationTap.decode(response.payload, response.actionId));

  @override
  Future<NotificationTap?> launchTap() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details == null || !details.didNotificationLaunchApp || response == null) return null;
    return NotificationTap.decode(response.payload, response.actionId);
  }

  T? _platform<T extends FlutterLocalNotificationsPlatform>() => _plugin.resolvePlatformSpecificImplementation<T>();

  @override
  Future<NotificationPermission> permission() async {
    if (kIsWeb) {
      return switch (_platform<WebFlutterLocalNotificationsPlugin>()?.permissionStatus) {
        WebNotificationPermission.granted => NotificationPermission.granted,
        WebNotificationPermission.denied => NotificationPermission.denied,
        _ => NotificationPermission.notAsked,
      };
    }
    final enabled = switch (defaultTargetPlatform) {
      TargetPlatform.android => await _platform<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled(),
      TargetPlatform.iOS => (await _platform<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions())?.isEnabled,
      TargetPlatform.macOS => (await _platform<MacOSFlutterLocalNotificationsPlugin>()?.checkPermissions())?.isEnabled,
      _ => true,
    };
    if (enabled ?? false) return NotificationPermission.granted;
    return _refused ? NotificationPermission.denied : NotificationPermission.notAsked;
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return await _platform<WebFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    final granted = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        await _platform<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission(),
      TargetPlatform.iOS => await _platform<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ),
      TargetPlatform.macOS => await _platform<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ),
      _ => true,
    };
    _refused = !(granted ?? false);
    return !_refused;
  }

  @override
  Future<bool> canScheduleExactly() async {
    if (!capabilities.exactAlarms) return true;
    return await _platform<AndroidFlutterLocalNotificationsPlugin>()?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> show(LocalNotification notification) => _plugin.show(
    id: notification.id,
    title: notification.title,
    body: notification.body,
    notificationDetails: _details(notification),
    payload: notification.payload,
  );

  @override
  Future<void> schedule(LocalNotification notification, DateTime at) async {
    if (!capabilities.scheduling) return;
    await _plugin.zonedSchedule(
      id: notification.id,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      notificationDetails: _details(notification),
      androidScheduleMode: await canScheduleExactly()
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<Set<int>> scheduledIds() async {
    if (!capabilities.scheduling) return const {};
    return {for (final request in await _plugin.pendingNotificationRequests()) request.id};
  }

  NotificationDetails _details(LocalNotification notification) => NotificationDetails(
    android: _android(notification),
    iOS: _darwin(notification),
    macOS: _darwin(notification),
    linux: LinuxNotificationDetails(
      actions: [
        for (final action in notification.actions) LinuxNotificationAction(key: action.id.name, label: action.label),
      ],
      suppressSound: notification.silent,
      urgency: notification.channel == NotificationChannel.calendar
          ? LinuxNotificationUrgency.critical
          : LinuxNotificationUrgency.normal,
    ),
    windows: WindowsNotificationDetails(
      actions: [
        for (final action in notification.actions) WindowsAction(content: action.label, arguments: action.id.name),
      ],
    ),
    web: WebNotificationDetails(
      actions: [
        for (final action in notification.actions) WebNotificationAction(action: action.id.name, title: action.label),
      ],
      isSilent: notification.silent,
      requireInteraction: notification.channel == NotificationChannel.calendar,
    ),
  );

  AndroidNotificationDetails _android(LocalNotification notification) {
    final progress = notification.progress;
    final (name, importance) = switch (notification.channel) {
      NotificationChannel.uploads => (_strings.notificationChannelUploads, Importance.low),
      NotificationChannel.calendar => (_strings.notificationChannelCalendar, Importance.high),
      NotificationChannel.sharing => (_strings.notificationChannelSharing, Importance.defaultImportance),
    };
    return AndroidNotificationDetails(
      notification.channel.name,
      name,
      icon: notification.channel == NotificationChannel.calendar ? _androidCalendarIcon : _androidIcon,
      importance: importance,
      priority: importance == Importance.high ? Priority.high : Priority.defaultPriority,
      category: notification.channel == NotificationChannel.calendar
          ? AndroidNotificationCategory.reminder
          : notification.channel == NotificationChannel.uploads
          ? AndroidNotificationCategory.progress
          : AndroidNotificationCategory.social,
      ongoing: notification.ongoing,
      autoCancel: !notification.ongoing,
      onlyAlertOnce: true,
      silent: notification.silent,
      showProgress: progress != null,
      maxProgress: 100,
      progress: ((progress ?? 0).clamp(0, 1) * 100).round(),
      indeterminate: progress != null && progress < 0,
      actions: [
        for (final action in notification.actions)
          AndroidNotificationAction(action.id.name, action.label, cancelNotification: true),
      ],
    );
  }

  DarwinNotificationDetails _darwin(LocalNotification notification) => DarwinNotificationDetails(
    categoryIdentifier: notification.actions.isEmpty ? null : _shareCategory,
    threadIdentifier: notification.channel.name,
    presentSound: !notification.silent,
    interruptionLevel: switch (notification.channel) {
      NotificationChannel.calendar => InterruptionLevel.timeSensitive,
      NotificationChannel.uploads => InterruptionLevel.passive,
      NotificationChannel.sharing => InterruptionLevel.active,
    },
  );
}
