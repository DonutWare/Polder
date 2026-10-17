import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/sharing.dart";
import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/widgets/shared/icon_badge.dart";
import "package:polder/widgets/shared/user_avatar.dart";

class ShareTargetAvatar extends ConsumerWidget {
  const ShareTargetAvatar({required this.target, this.size = 36, super.key});

  final ShareTarget target;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (target.isGroup) return IconBadge(icon: IconsaxPlusLinear.people, size: size);
    final serverUrl = ref.watch(currentAccountProvider.select((account) => account?.serverUrl)) ?? "";
    return UserAvatar(
      user: User(
        id: target.id,
        username: target.username ?? target.name,
        avatar: target.avatar,
        profile: UserProfile(displayName: target.name),
      ),
      serverUrl: serverUrl,
      size: size,
    );
  }
}
