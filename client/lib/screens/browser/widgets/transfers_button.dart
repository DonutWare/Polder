import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/screens/browser/widgets/transfers_sheet.dart";
import "package:polder/util/localization_helper.dart";

class TransfersButton extends ConsumerWidget {
  const TransfersButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transfersProvider);
    if (transfers.isEmpty) return const SizedBox.shrink();
    final running = transfers.where((transfer) => transfer.isRunning).length;
    return IconButton(
      tooltip: context.localized.transfers,
      icon: Badge(
        isLabelVisible: running > 0,
        label: Text("$running"),
        child: const Icon(IconsaxPlusLinear.arrow_swap),
      ),
      onPressed: () =>
          showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => const TransfersSheet()),
    );
  }
}
