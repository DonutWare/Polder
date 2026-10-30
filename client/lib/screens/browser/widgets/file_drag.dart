import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/file_type_icon.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/localization_helper.dart";

class FileDrag {
  const FileDrag({required this.parentPath, required this.entries});

  final String parentPath;
  final List<FileEntry> entries;
}

class FileDragSource extends StatelessWidget {
  const FileDragSource({required this.drag, required this.longPress, required this.child, super.key});

  final FileDrag drag;
  final bool longPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final feedback = _DragFeedback(entries: drag.entries);
    final dragging = Opacity(opacity: 0.4, child: child);
    if (!longPress) {
      return Draggable<FileDrag>(
        data: drag,
        feedback: feedback,
        childWhenDragging: dragging,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        child: child,
      );
    }
    return LongPressDraggable<FileDrag>(
      data: drag,
      feedback: feedback,
      childWhenDragging: dragging,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: HapticFeedback.mediumImpact,
      child: child,
    );
  }
}

class FileMoveTarget extends ConsumerWidget {
  const FileMoveTarget({required this.destination, required this.builder, super.key});

  final String destination;
  final Widget Function(BuildContext context, bool active) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) => DragTarget<FileDrag>(
    onWillAcceptWithDetails: (details) => FileActions.canMoveInto(
      ref,
      parentPath: details.data.parentPath,
      entries: details.data.entries,
      destination: destination,
    ),
    onAcceptWithDetails: (details) {
      final directory = ref.read(directoryProvider(details.data.parentPath).notifier);
      unawaited(context.runWithFeedback(directory.moveAllTo(details.data.entries, destination)));
    },
    builder: (context, candidates, _) => builder(context, candidates.isNotEmpty),
  );
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.entries});

  final List<FileEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final single = entries.length == 1 ? entries.single : null;
    return Transform.translate(
      offset: const Offset(12, 12),
      child: Material(
        elevation: 6,
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              single == null
                  ? Icon(IconsaxPlusLinear.copy, size: 18, color: theme.colorScheme.onSecondaryContainer)
                  : FileTypeIcon(entry: single, size: 18),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  single?.name ?? context.localized.activityItemCount(entries.length),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
