import "package:flutter_riverpod/misc.dart";
import "package:polder_calendar/calendar_locations.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder/providers/sync/sync_platform_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/routes/polder_ui_config_override.dart";

final List<Override> polderPackageOverrides = [
  polderUiConfigOverride,
  calendarLocationsProvider.overrideWithValue(AppRoutes.calendarLocations),
  notificationChecksSchedulerProvider.overrideWith((ref) => ref.watch(syncPlatformProvider).scheduleNotificationChecks),
];
