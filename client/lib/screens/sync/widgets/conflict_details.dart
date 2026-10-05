import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/screens/sync/widgets/conflict_side_card.dart";
import "package:polder/util/localization_helper.dart";

class ConflictDetails extends StatelessWidget {
  const ConflictDetails({required this.conflict, super.key});

  final Conflict conflict;

  @override
  Widget build(BuildContext context) {
    final local = conflict.local;
    final remote = conflict.remote;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Expanded(
          child: ConflictSideCard(
            title: context.localized.thisDevice,
            icon: IconsaxPlusLinear.monitor,
            size: local?.size,
            modified: local?.mtime,
          ),
        ),
        Expanded(
          child: ConflictSideCard(
            title: context.localized.server,
            icon: IconsaxPlusLinear.cloud,
            size: remote?.size,
            modified: remote?.mtime,
            detail: remote == null ? null : context.localized.revisionShort(remote.rev),
          ),
        ),
      ],
    );
  }
}
