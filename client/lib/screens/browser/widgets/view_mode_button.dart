import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:nomad/providers/browser/browser_view_provider.dart";
import "package:nomad/util/localization_helper.dart";

class ViewModeButton extends ConsumerWidget {
  const ViewModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isList = ref.watch(browserViewModeProvider) == BrowserViewMode.list;
    return IconButton(
      tooltip: isList ? context.localized.gridView : context.localized.listView,
      icon: Icon(isList ? IconsaxPlusLinear.element_3 : IconsaxPlusLinear.row_vertical),
      onPressed: ref.read(browserViewModeProvider.notifier).toggle,
    );
  }
}
