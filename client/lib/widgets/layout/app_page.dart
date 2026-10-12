import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/screens/search/open_search.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/shared/app_bar_fade.dart";

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    super.key,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final isRoot = !(ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    final showMenu =
        leading == null &&
        isRoot &&
        WindowSize.of(context) == WindowSize.compact &&
        SideSheetDrawer.maybeOf(context) != null;
    final navigationBarOverlap = MediaQuery.paddingOf(context).bottom - MediaQuery.viewPaddingOf(context).bottom;
    final fab = floatingActionButton;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: fab != null
          ? Padding(
              padding: EdgeInsets.only(bottom: navigationBarOverlap.clamp(0, double.infinity)),
              child: fab,
            )
          : null,
      appBar: AppBar(
        flexibleSpace: const AppBarFade(),
        toolbarHeight: isRoot ? 64 : null,
        leading: leading ?? (showMenu ? const MoreOptionsButton() : null),
        titleSpacing: showMenu || leading != null ? 4 : null,
        title: title,
        actions: [if (isRoot) const SearchButton(), ...?actions, const SizedBox(width: 8)],
        bottom: bottom,
      ),
      body: body,
    );
  }
}

class MoreOptionsButton extends StatelessWidget {
  const MoreOptionsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.localized.moreOptions,
    icon: const Icon(IconsaxPlusLinear.menu),
    onPressed: () => SideSheetDrawer.of(context).open(),
  );
}
