import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:permission_handler/permission_handler.dart";
import "package:polder/models/notifications/notification_preferences.dart";
import "package:polder/providers/notifications/notification_providers.dart";
import "package:polder/services/notifications/notification_service.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/notice_tile.dart";

Future<void> allowNotifications(WidgetRef ref, NotificationPermission? permission) async {
  if (permission == NotificationPermission.denied && !kIsWeb) {
    await openAppSettings();
    return;
  }
  await ref.read(notificationPreferencesProvider.notifier).setEnabled(true);
}

class NotificationPermissionNotice extends ConsumerStatefulWidget {
  const NotificationPermissionNotice({this.padding = EdgeInsets.zero, super.key});

  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<NotificationPermissionNotice> createState() => _NotificationPermissionNoticeState();
}

class _NotificationPermissionNoticeState extends ConsumerState<NotificationPermissionNotice> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => ref.invalidate(notificationPermissionProvider));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localized = context.localized;
    final permission = ref.watch(notificationPermissionProvider).value;
    if (permission == null || permission == NotificationPermission.granted) return const SizedBox.shrink();
    final denied = permission == NotificationPermission.denied;
    return _Notice(
      padding: widget.padding,
      text: denied ? localized.notificationsBlocked : localized.notificationsNotAllowed,
      action: denied && kIsWeb
          ? null
          : FilledButton.tonal(
              onPressed: () => allowNotifications(ref, permission),
              child: Text(denied ? localized.notificationsOpenSettings : localized.notificationsAllow),
            ),
    );
  }
}

class CalendarReminderNotice extends ConsumerWidget {
  const CalendarReminderNotice({this.padding = EdgeInsets.zero, super.key});

  final EdgeInsetsGeometry padding;

  Future<void> _turnOn(WidgetRef ref, NotificationPreferences preferences) async {
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    if (!preferences.enabled && !await notifier.setEnabled(true)) return;
    if (!preferences.calendarReminders) await notifier.setCalendarReminders(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider).value;
    if (preferences == null) return const SizedBox.shrink();
    if (preferences.wantsCalendarReminders) return NotificationPermissionNotice(padding: padding);
    final localized = context.localized;
    return _Notice(
      padding: padding,
      text: localized.notificationsReminderOff,
      action: FilledButton.tonal(
        onPressed: () => _turnOn(ref, preferences),
        child: Text(localized.notificationsTurnOn),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.padding, required this.text, this.action});

  final EdgeInsetsGeometry padding;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: NoticeTile(
      icon: IconsaxPlusLinear.notification_bing,
      color: AppColors.of(context).warning,
      text: text,
      action: action,
    ),
  );
}
