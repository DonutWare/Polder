import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/util/adaptive_layout/adaptive_layout.dart";

Future<T?> showCalendarPanel<T>(
  BuildContext context, {
  required Widget Function(BuildContext context, ScrollController? controller) builder,
  double initialSize = 0.85,
}) {
  if (AdaptiveLayout.isPhone(context)) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: initialSize,
          maxChildSize: 0.95,
          builder: builder,
        ),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: builder(context, null),
      ),
    ),
  );
}

class CalendarPanelBody extends StatelessWidget {
  const CalendarPanelBody({required this.title, required this.children, this.controller, this.actions, super.key});

  final String title;
  final List<Widget> children;
  final ScrollController? controller;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(IconsaxPlusLinear.close_circle),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            controller: controller,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            children: children,
          ),
        ),
        if (actions != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, spacing: 8, children: actions!),
            ),
          ),
      ],
    );
  }
}

class CalendarFieldLabel extends StatelessWidget {
  const CalendarFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
