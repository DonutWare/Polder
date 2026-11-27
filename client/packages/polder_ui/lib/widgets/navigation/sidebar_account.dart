import "package:material_ui/material_ui.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/layout/adaptive.dart";
import "package:polder_ui/widgets/shared/connection_status.dart";
import "package:polder_ui/widgets/shared/user_avatar.dart";

void _openAccountSheet(BuildContext context) => SideSheetDrawer.maybeOf(context)?.open();

class SidebarAccountCard extends StatelessWidget {
  const SidebarAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Tooltip(
        message: context.localized.moreOptions,
        child: Material(
          color: AppColors.of(context).inset,
          shape: squircle(AppRadius.inset),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openAccountSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AccountIdentity(
                badged: true,
                trailing: Icon(IconsaxPlusLinear.arrow_swap, size: 16, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarAccountButton extends StatelessWidget {
  const SidebarAccountButton({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.localized.moreOptions,
    child: Material(
      color: Colors.transparent,
      shape: squircle(AppRadius.inset),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openAccountSheet(context),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: ConnectionBadge(child: SignedInAvatar(size: 40)),
        ),
      ),
    ),
  );
}

class SidebarToggle extends ConsumerWidget {
  const SidebarToggle({required this.expanded, super.key});

  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final pointsLeft = expanded != rtl;
    return IconButton(
      tooltip: expanded ? context.localized.collapseSidebar : context.localized.expandSidebar,
      icon: Icon(pointsLeft ? IconsaxPlusLinear.sidebar_left : IconsaxPlusLinear.sidebar_right),
      onPressed: ref.read(sidebarExpandedProvider.notifier).toggle,
    );
  }
}

class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({this.busy = false, super.key});

  final bool busy;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.localized.moreOptions,
    icon: ConnectionBadge(fallback: busy, child: const SignedInAvatar(size: 32)),
    onPressed: () => _openAccountSheet(context),
  );
}
