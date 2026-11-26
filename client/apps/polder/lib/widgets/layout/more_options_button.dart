import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:polder/providers/shell/shell_destinations_provider.dart";
import "package:polder_ui/widgets/navigation/sidebar_account.dart";

class MoreOptionsButton extends ConsumerWidget {
  const MoreOptionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      AccountMenuButton(busy: ref.watch(activityBadgeProvider) != null);
}
