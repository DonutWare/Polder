import "package:flutter/material.dart";

import "package:go_router/go_router.dart";

import "package:polder/widgets/layout/adaptive.dart";
import "package:polder/widgets/layout/app_page.dart";

class SplitView extends StatelessWidget {
  const SplitView({
    required this.pane,
    required this.placeholder,
    this.title,
    this.content,
    this.trailing,
    this.paneActions = const [],
    super.key,
  });

  static const paneWidth = 280.0;

  final Widget? title;
  final Widget pane;
  final List<Widget> paneActions;
  final Widget? content;
  final Widget placeholder;
  final Widget? trailing;

  static Widget? backTo(BuildContext context, String route) =>
      WindowSize.isCompact(context) ? BackButton(onPressed: () => context.go(route)) : null;

  @override
  Widget build(BuildContext context) {
    if (WindowSize.isCompact(context)) {
      return content ??
          AppPage(
            title: title ?? const SizedBox.shrink(),
            actions: paneActions,
            body: SafeArea(child: pane),
          );
    }
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: paneWidth,
            child: Material(
              color: colors.surfaceContainerLow,
              child: SafeArea(
                right: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title case final title?) _PaneHeader(title: title, actions: paneActions),
                    Expanded(child: pane),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(key: ValueKey(content?.key ?? content.runtimeType), child: content ?? placeholder),
            ),
          ),
          if (trailing case final trailing?) ...[const VerticalDivider(width: 1), trailing],
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.title, required this.actions});

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
    child: Row(
      children: [
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
