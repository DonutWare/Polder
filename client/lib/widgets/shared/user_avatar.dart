import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/user.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/server_icon.dart";

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, required this.serverUrl, this.size = 36, super.key});

  final User user;
  final String serverUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatar = user.avatar;
    final url = user.avatarUrl(serverUrl);
    final initials = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
      ),
      child: Center(
        child: Text(
          user.initials,
          maxLines: 1,
          style: TextStyle(color: cs.onPrimary, fontSize: size * 0.4, fontWeight: FontWeight.w600, height: 1),
        ),
      ),
    );
    return Semantics(
      label: user.displayName,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(size * AppRadius.inset / 48),
          child: avatar == null || url == null
              ? initials
              : ServerImageView(url: url, image: avatar, fit: BoxFit.cover, fallback: initials),
        ),
      ),
    );
  }
}

class SignedInAvatar extends ConsumerWidget {
  const SignedInAvatar({this.size = 36, super.key});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    if (account == null) return SizedBox.square(dimension: size);
    return UserAvatar(user: account.user, serverUrl: account.serverUrl, size: size);
  }
}

class AccountIdentity extends ConsumerWidget {
  const AccountIdentity({this.avatarSize = 36, this.trailing, super.key});

  final double avatarSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(currentAccountProvider);
    if (account == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Row(
      spacing: 12,
      children: [
        UserAvatar(user: account.user, serverUrl: account.serverUrl, size: avatarSize),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.user.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                account.handle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
