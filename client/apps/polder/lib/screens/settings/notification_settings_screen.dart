import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:permission_handler/permission_handler.dart";
import "package:polder_core/models/notifications/notification_preferences.dart";
import "package:polder/providers/features/feature_modes_provider.dart";
import "package:polder/services/features/feature_modes.dart";
import "package:polder/providers/notifications/email_preferences_provider.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_drive/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder_ui/routes/up_scope.dart";
import "package:polder_core/services/notifications/notification_service.dart";
import "package:polder_ui/util/action_feedback.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/layout/app_page.dart";
import "package:polder_ui/widgets/notifications/notification_notices.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refreshPermissions);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _refreshPermissions() {
    ref.invalidate(unrestrictedBackgroundProvider);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(notificationPreferencesProvider).value;
    return AppPage(
      title: Text(context.localized.notifications),
      body: ReadableWidth(
        maxWidth: 720,
        builder: (context, inset) => ListView(
          padding: inset + const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            if (preferences != null) ...[
              if (preferences.enabled)
                const NotificationPermissionNotice(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              _EnableGroup(preferences: preferences),
              _TopicsGroup(preferences: preferences),
              if (preferences.enabled) const _ReliabilityGroup(),
            ],
            const _EmailGroup(),
          ],
        ),
      ),
    );
  }
}

const _tilePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

class _EnableGroup extends ConsumerWidget {
  const _EnableGroup({required this.preferences});

  final NotificationPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final permission = ref.watch(notificationPermissionProvider).value;
    final allowed = permission == null || permission == NotificationPermission.granted;
    return NavGroup(
      title: localized.notifications,
      children: [
        SwitchListTile(
          contentPadding: _tilePadding,
          secondary: const Icon(IconsaxPlusLinear.notification),
          title: Text(localized.notificationsEnable),
          subtitle: Text(kIsWeb ? localized.notificationsWebHint : localized.notificationsEnableHint),
          value: preferences.enabled && allowed,
          onChanged: (enabled) => enabled
              ? allowNotifications(ref, permission)
              : ref.read(notificationPreferencesProvider.notifier).setEnabled(false),
        ),
      ],
    );
  }
}

class _TopicsGroup extends ConsumerWidget {
  const _TopicsGroup({required this.preferences});

  final NotificationPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final features = ref.watch(resolvedFeatureModesProvider);
    final drive = features.isBuiltIn(PolderFeature.drive);
    final calendar = features.isBuiltIn(PolderFeature.calendar);
    final autoUpload = drive && ref.watch(syncPlatformProvider).supportsAutoUpload;
    final enabled = preferences.enabled;
    SwitchListTile toggle(String title, String hint, bool value, Future<void> Function(bool) change) => SwitchListTile(
      contentPadding: _tilePadding,
      title: Text(title),
      subtitle: Text(hint),
      value: enabled && value,
      onChanged: enabled ? change : null,
    );
    return NavGroup(
      title: localized.notificationsAbout,
      children: [
        if (drive)
          toggle(
            localized.notificationsShares,
            localized.notificationsSharesHint,
            preferences.shares,
            notifier.setShares,
          ),
        if (calendar)
          toggle(
            localized.notificationsCalendar,
            localized.notificationsCalendarHint,
            preferences.calendarReminders,
            notifier.setCalendarReminders,
          ),
        if (autoUpload) ...[
          toggle(
            localized.notificationsUploadProgress,
            localized.notificationsUploadProgressHint,
            preferences.autoUploadProgress,
            notifier.setUploadProgress,
          ),
          toggle(
            localized.notificationsUploadSummary,
            localized.notificationsUploadSummaryHint,
            preferences.autoUploadSummary,
            notifier.setUploadSummary,
          ),
          toggle(
            localized.notificationsUploadCheck,
            localized.notificationsUploadCheckHint,
            preferences.autoUploadCheck,
            notifier.setUploadCheck,
          ),
        ],
      ],
    );
  }
}

class _EmailGroup extends ConsumerWidget {
  const _EmailGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(emailPreferencesProvider).value;
    if (preferences == null || !preferences.enabled) return const SizedBox.shrink();
    final localized = context.localized;
    final notifier = ref.read(emailPreferencesProvider.notifier);
    final canSend = preferences.hasEmail;
    SwitchListTile toggle(String title, String hint, bool value, Future<void> Function(bool) change) => SwitchListTile(
      contentPadding: _tilePadding,
      title: Text(title),
      subtitle: Text(hint),
      value: canSend && value,
      onChanged: canSend ? (enabled) => context.runWithFeedback(change(enabled)) : null,
    );
    return NavGroup(
      title: localized.emailNotifications,
      children: [
        if (!canSend)
          NavEntry(
            icon: IconsaxPlusLinear.sms,
            title: localized.emailNotificationsNoAddress,
            subtitle: localized.emailNotificationsNoAddressHint,
            onTap: () => goWithin(context, AppRoutes.account),
          ),
        toggle(localized.emailSecurity, localized.emailSecurityHint, preferences.security, notifier.setSecurity),
        toggle(localized.emailQuota, localized.emailQuotaHint, preferences.quota, notifier.setQuota),
        toggle(localized.emailShares, localized.emailSharesHint, preferences.shares, notifier.setShares),
        ListTile(
          contentPadding: _tilePadding,
          leading: const Icon(IconsaxPlusLinear.info_circle),
          subtitle: Text(localized.emailAlwaysSent),
        ),
      ],
    );
  }
}

class _ReliabilityGroup extends ConsumerWidget {
  const _ReliabilityGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    if (!ref.watch(notificationServiceProvider).capabilities.batteryOptimization) return const SizedBox.shrink();
    final unrestricted = ref.watch(unrestrictedBackgroundProvider).value ?? true;
    return NavGroup(
      title: localized.notificationsReliability,
      children: [
        NavEntry(
          icon: IconsaxPlusLinear.battery_charging,
          title: localized.notificationsBattery,
          subtitle: unrestricted ? localized.notificationsAllowed : localized.notificationsBatteryHint,
          onTap: unrestricted
              ? null
              : () async {
                  await Permission.ignoreBatteryOptimizations.request();
                  ref.invalidate(unrestrictedBackgroundProvider);
                },
        ),
      ],
    );
  }
}
