import "dart:math" as math;

import "package:flutter/material.dart";

import "package:go_router/go_router.dart";

import "package:polder/routes/app_routes.dart";
import "package:polder/routes/up_scope.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/widgets/layout/app_page.dart";

class DualPane extends StatelessWidget {
  const DualPane({
    required this.list,
    required this.listLocation,
    required this.placeholder,
    this.title,
    this.listActions = const [],
    this.listFloatingActionButton,
    this.detail,
    this.defaultDetail,
    this.trailing,
    this.onPop,
    this.maxListWidth = defaultMaxListWidth,
    this.forceSingle = false,
    super.key,
  });

  static const defaultMaxListWidth = 480.0;

  final Widget list;
  final String listLocation;
  final Widget? title;
  final List<Widget> listActions;
  final Widget? listFloatingActionButton;
  final Widget? detail;
  final Widget? defaultDetail;
  final Widget placeholder;
  final Widget? trailing;
  final ValueChanged<String>? onPop;
  final double maxListWidth;
  final bool forceSingle;

  static bool isDetail(BuildContext context) => context.getInheritedWidgetOfExactType<_DualDetail>() != null;

  static bool highlights(BuildContext context) => !AdaptiveLayout.isSingle(context);

  @override
  Widget build(BuildContext context) =>
      forceSingle || AdaptiveLayout.isSingle(context) ? _single(context) : _dual(context);

  Widget _single(BuildContext context) {
    final shown = detail;
    return PageStack(
      onPop: onPop,
      pages: [
        StackPage(
          location: listLocation,
          key: const ValueKey("list"),
          child: AppPage(
            title: title ?? const SizedBox.shrink(),
            actions: listActions,
            floatingActionButton: listFloatingActionButton,
            body: SafeArea(child: list),
          ),
        ),
        if (shown != null)
          StackPage(
            location: GoRouterState.of(context).uri.toString(),
            key: switch (shown.key) {
              final LocalKey key => key,
              _ => const ValueKey("detail"),
            },
            child: shown,
          ),
      ],
    );
  }

  Widget _withFloatingButton(Widget list) => switch (listFloatingActionButton) {
    null => list,
    final button => Stack(
      children: [
        Positioned.fill(child: list),
        Positioned(right: 16, bottom: 16, child: button),
      ],
    ),
  };

  Widget _dual(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shown = detail ?? defaultDetail;
    final location = UpScope.locationOf(context);
    return Material(
      color: colors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: math.min(maxListWidth, constraints.maxWidth * 2 / 5),
              child: Material(
                color: colors.surfaceContainerLow,
                child: SafeArea(
                  right: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title case final title?)
                        _ListHeader(
                          title: title,
                          actions: listActions,
                          showUp: location != null && !AppRoutes.isTab(location),
                        ),
                      Expanded(child: _withFloatingButton(list)),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(shown?.key ?? shown.runtimeType),
                  child: _DualDetail(child: shown ?? placeholder),
                ),
              ),
            ),
            if (trailing case final trailing?) ...[const VerticalDivider(width: 1), trailing],
          ],
        ),
      ),
    );
  }
}

class _DualDetail extends InheritedWidget {
  const _DualDetail({required super.child});

  @override
  bool updateShouldNotify(_DualDetail oldWidget) => false;
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title, required this.actions, required this.showUp});

  final Widget title;
  final List<Widget> actions;
  final bool showUp;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(showUp ? 8 : 20, 12, 8, 8),
    child: Row(
      children: [
        if (showUp) const UpButton(),
        Expanded(
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
            child: title,
          ),
        ),
        ...actions,
      ],
    ),
  );
}
