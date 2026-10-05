import "package:flutter/material.dart";

import "package:polder/models/sync/conflict.dart";
import "package:polder/util/localization_helper.dart";

class ConflictKindText extends StatelessWidget {
  const ConflictKindText({required this.kind, super.key});

  final ConflictKind kind;

  @override
  Widget build(BuildContext context) => Text(switch (kind) {
    ConflictKind.bothModified => context.localized.conflictBothModified,
    ConflictKind.bothCreated => context.localized.conflictBothCreated,
    ConflictKind.localModifiedRemoteDeleted => context.localized.conflictLocalModifiedRemoteDeleted,
    ConflictKind.localDeletedRemoteModified => context.localized.conflictLocalDeletedRemoteModified,
  });
}
