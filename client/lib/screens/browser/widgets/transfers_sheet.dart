import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/transfer.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/api_error_localization.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/level_bar.dart";
import "package:polder/widgets/shared/section_header.dart";

class TransfersSheet extends ConsumerWidget {
  const TransfersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transfersProvider);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionHeader(
            context.localized.transfers,
            trailing: TextButton(
              onPressed: ref.read(transfersProvider.notifier).clearFinished,
              child: Text(context.localized.clearFinished),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              children: [for (final transfer in transfers.reversed) _TransferTile(transfer: transfer)],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({required this.transfer});

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final upload = transfer.direction == TransferDirection.upload;
    final color = switch (transfer.status) {
      TransferStatus.running => cs.primary,
      TransferStatus.done => colors.success,
      TransferStatus.failed => cs.error,
    };
    return ListTile(
      leading: IconBadge(
        icon: upload ? IconsaxPlusLinear.document_upload : IconsaxPlusLinear.document_download,
        color: color,
      ),
      title: Text(transfer.name, overflow: TextOverflow.ellipsis),
      subtitle: switch (transfer.status) {
        TransferStatus.running => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: LevelBar(fraction: transfer.progress, color: cs.primary, height: 4),
        ),
        TransferStatus.done => Text(context.localized.transferDone),
        TransferStatus.failed => Text(context.describeError(transfer.error), style: TextStyle(color: cs.error)),
      },
    );
  }
}
