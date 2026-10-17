import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/sharing.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/sharing/shares_provider.dart";

abstract final class ShareActions {
  static Future<void> update(
    WidgetRef ref,
    OutgoingShare share, {
    required SharePermissions permissions,
    required DateTime? expiresAt,
    required String note,
  }) async {
    await ref
        .read(polderApiProvider)
        .updateShare(
          share.id,
          permissions: permissions,
          expiresAt: expiresAt,
          removeExpiry: expiresAt == null && share.expiresAt != null,
          note: note,
        );
    invalidateShares(ref.invalidate);
  }

  static Future<void> remove(WidgetRef ref, OutgoingShare share) async {
    await ref.read(polderApiProvider).removeShare(share.id);
    invalidateShares(ref.invalidate);
  }
}
