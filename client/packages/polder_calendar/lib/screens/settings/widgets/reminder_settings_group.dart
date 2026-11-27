import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_ui/providers/notifications/notification_providers.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/nav_group.dart";

class ReminderSettingsGroup extends ConsumerWidget {
  const ReminderSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localized = context.localized;
    final preferences = ref.watch(notificationPreferencesProvider).value;
    final notifier = ref.read(notificationPreferencesProvider.notifier);
    final reminding = preferences != null && preferences.wantsCalendarReminders;
    return NavGroup(
      title: localized.notifications,
      children: [
        SwitchListTile(
          secondary: const Icon(IconsaxPlusLinear.notification),
          title: Text(localized.notificationsCalendar),
          subtitle: Text(localized.notificationsCalendarHint),
          value: reminding,
          onChanged: preferences == null
              ? null
              : (enabled) async {
                  if (enabled && !await notifier.setEnabled(true)) return;
                  await notifier.setCalendarReminders(enabled);
                },
        ),
      ],
    );
  }
}
