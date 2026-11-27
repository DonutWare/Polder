import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/providers/browser/file_operations_provider.dart";
import "package:polder/screens/browser/widgets/file_operation_widgets.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_core/util/remote_path.dart";
import "package:polder_ui/widgets/shared/level_bar.dart";

class FileOperationsOverlay extends StatelessWidget {
  const FileOperationsOverlay({required this.child, super.key});

  static const fabClearance = 88.0;

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      const PositionedDirectional(
        start: 0,
        end: fabClearance,
        bottom: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 16, bottom: 16),
            child: Align(alignment: AlignmentDirectional.bottomStart, child: FileOperationsBar()),
          ),
        ),
      ),
    ],
  );
}

class FileOperationsBar extends ConsumerWidget {
  const FileOperationsBar({super.key});

  static const maxShown = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(fileOperationsProvider);
    final shown = operations.take(maxShown).toList();
    final hidden = operations.length - shown.length;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: AlignmentDirectional.bottomStart,
      child: shown.isEmpty
          ? const SizedBox.shrink()
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                elevation: 6,
                shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.4),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: squircle(AppRadius.inset + 4, side: tintedSide(Theme.of(context).colorScheme.outline)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      for (final operation in shown)
                        FileOperationRow(key: ValueKey(operation.id), operation: operation),
                      if (hidden > 0)
                        Text(
                          context.localized.fileOperationsMore(hidden),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class FileOperationRow extends StatelessWidget {
  const FileOperationRow({required this.operation, super.key});

  final FileOperation operation;

  String _subject(BuildContext context) => operation.items.length == 1
      ? operation.items.single.displayName
      : context.localized.fileOperationItems(operation.items.length);

  String? _detail(BuildContext context) {
    if (operation.finished && operation.failed) return context.localized.fileOperationIncomplete;
    final destination = operation.destination;
    if (destination == null) return null;
    final folder = destination == RemotePath.root ? context.localized.rootFolder : RemotePath.name(destination);
    return context.localized.fileOperationInto(folder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = operation.finished && operation.failed;
    final color = failed ? theme.colorScheme.error : operation.kind.color(context);
    final detail = _detail(context);
    final counter = operation.items.length > 1 && !operation.finished
        ? context.localized.transferProgress("${operation.completed}", "${operation.items.length}")
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 12,
          children: [
            Icon(
              failed
                  ? IconsaxPlusLinear.danger
                  : (operation.finished ? IconsaxPlusLinear.tick_circle : operation.kind.icon),
              size: 20,
              color: color,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    operation.kind.title(context, _subject(context), finished: operation.finished),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (detail != null)
                    Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (counter != null) Text(counter, style: theme.textTheme.bodySmall),
          ],
        ),
        LevelBar(fraction: operation.progress, height: 4, color: color),
      ],
    );
  }
}
