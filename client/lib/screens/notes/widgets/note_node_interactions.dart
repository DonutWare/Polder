import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";

final expandedNotesProvider = NotifierProvider<ExpandedNotes, Set<String>>(ExpandedNotes.new);

class ExpandedNotes extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String path) => state = state.contains(path) ? ({...state}..remove(path)) : {...state, path};

  void expand(String path) {
    if (!state.contains(path)) state = {...state, path};
  }

  void expandTo(String root, String path) {
    final ancestors = [
      for (final ancestor in RemotePath.ancestry(RemotePath.parent(path)))
        if (RemotePath.isWithin(ancestor, root)) ancestor,
    ];
    if (ancestors.every(state.contains)) return;
    state = {...state, ...ancestors};
  }
}

abstract final class NoteTargetSize {
  static double row(BuildContext context) => AdaptiveLayout.usesPointer(context) ? 36 : 48;

  static double button(BuildContext context) => AdaptiveLayout.usesPointer(context) ? 32 : 48;
}

enum _NodeAction { newSubpage, rename, move, delete }

abstract final class NoteNodeActions {
  static Rect anchorOf(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> showMenuFor(
    BuildContext context,
    WidgetRef ref, {
    required NoteTreeNode node,
    required Rect anchor,
    required String? selectedPath,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final local = Rect.fromPoints(overlay.globalToLocal(anchor.topLeft), overlay.globalToLocal(anchor.bottomRight));
    final localized = context.localized;
    final action = await showMenu<_NodeAction>(
      context: context,
      position: RelativeRect.fromRect(local, Offset.zero & overlay.size),
      items: [
        PopupMenuItem(value: _NodeAction.newSubpage, child: Text(localized.noteNewSubpage)),
        PopupMenuItem(value: _NodeAction.rename, child: Text(localized.rename)),
        PopupMenuItem(value: _NodeAction.move, child: Text(localized.noteMove)),
        PopupMenuItem(value: _NodeAction.delete, child: Text(localized.delete)),
      ],
    );
    if (action == null || !context.mounted) return;
    final navigation = ref.read(navigationHistoryProvider.notifier);
    switch (action) {
      case _NodeAction.newSubpage:
        await createSubpage(context, ref, node);
      case _NodeAction.rename:
        _follow(navigation, selectedPath, node, await NotesActions.rename(context, node));
      case _NodeAction.move:
        _follow(navigation, selectedPath, node, await NotesActions.move(context, node));
      case _NodeAction.delete:
        final deleted = await NotesActions.delete(context, node);
        if (deleted && selectedPath != null && node.holds(selectedPath)) navigation.replace(AppRoutes.notes);
    }
  }

  static Future<void> createSubpage(BuildContext context, WidgetRef ref, NoteTreeNode node) async {
    final expanded = ref.read(expandedNotesProvider.notifier);
    await NotesActions.createSubpage(context, node);
    expanded.expand(node.childrenPath);
  }

  static Future<void> drop(
    BuildContext context,
    WidgetRef ref, {
    required NoteTreeNode node,
    required String destination,
    required String? selectedPath,
  }) async {
    final expanded = ref.read(expandedNotesProvider.notifier);
    final navigation = ref.read(navigationHistoryProvider.notifier);
    final movedTo = await NotesActions.moveInto(context, node, destination);
    if (movedTo == null) return;
    expanded.expand(destination);
    _follow(navigation, selectedPath, node, movedTo);
  }

  static void _follow(NavigationHistoryNotifier navigation, String? selectedPath, NoteTreeNode node, String? movedTo) {
    final selected = movedTo == null ? null : NotesActions.pathAfterMove(selectedPath, node, movedTo);
    if (selected != null) navigation.replace(AppRoutes.noteAt(selected));
  }
}

class NoteDragSource extends StatelessWidget {
  const NoteDragSource({required this.node, required this.child, super.key});

  final NoteTreeNode node;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scroller = NoteDragAutoScroll.maybeOf(context);
    final feedback = _DragFeedback(node: node);
    final dragging = Opacity(opacity: 0.4, child: child);
    if (AdaptiveLayout.usesPointer(context)) {
      return Draggable<NoteTreeNode>(
        data: node,
        feedback: feedback,
        childWhenDragging: dragging,
        onDragUpdate: (details) => scroller?.follow(details.globalPosition),
        onDragEnd: (_) => scroller?.stop(),
        child: child,
      );
    }
    return LongPressDraggable<NoteTreeNode>(
      data: node,
      feedback: feedback,
      childWhenDragging: dragging,
      onDragStarted: HapticFeedback.mediumImpact,
      onDragUpdate: (details) => scroller?.follow(details.globalPosition),
      onDragEnd: (_) => scroller?.stop(),
      child: child,
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.node});

  final NoteTreeNode node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 6,
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              node.page == null ? IconsaxPlusLinear.folder : IconsaxPlusLinear.note_2,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                node.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDropTarget extends StatefulWidget {
  const NoteDropTarget({
    required this.destination,
    required this.onDrop,
    required this.builder,
    this.onLinger,
    super.key,
  });

  static const lingerDelay = Duration(milliseconds: 700);

  final String destination;
  final ValueChanged<NoteTreeNode> onDrop;
  final Widget Function(BuildContext context, bool active) builder;
  final VoidCallback? onLinger;

  @override
  State<NoteDropTarget> createState() => _NoteDropTargetState();
}

class _NoteDropTargetState extends State<NoteDropTarget> {
  Timer? _linger;

  @override
  void dispose() {
    _linger?.cancel();
    super.dispose();
  }

  bool _accepts(DragTargetDetails<NoteTreeNode> details) {
    final accepts = NotesActions.canMoveInto(details.data, widget.destination);
    if (accepts && widget.onLinger != null) _linger = Timer(NoteDropTarget.lingerDelay, widget.onLinger!);
    return accepts;
  }

  void _leave() {
    _linger?.cancel();
    _linger = null;
  }

  @override
  Widget build(BuildContext context) => DragTarget<NoteTreeNode>(
    onWillAcceptWithDetails: _accepts,
    onLeave: (_) => _leave(),
    onAcceptWithDetails: (details) {
      _leave();
      widget.onDrop(details.data);
    },
    builder: (context, candidates, _) => widget.builder(context, candidates.isNotEmpty),
  );
}

class NoteDragAutoScroll extends StatefulWidget {
  const NoteDragAutoScroll({required this.controller, required this.child, super.key});

  final ScrollController controller;
  final Widget child;

  static NoteDragAutoScrollState? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AutoScrollScope>()?.state;

  @override
  State<NoteDragAutoScroll> createState() => NoteDragAutoScrollState();
}

class NoteDragAutoScrollState extends State<NoteDragAutoScroll> {
  static const _edge = 56.0;
  static const _maxStep = 14.0;

  Timer? _ticker;
  var _step = 0.0;

  void follow(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final y = box.globalToLocal(globalPosition).dy;
    final height = box.size.height;
    _step = switch (y) {
      _ when y < _edge => -_maxStep * (1 - y.clamp(0, _edge) / _edge),
      _ when y > height - _edge => _maxStep * (1 - (height - y).clamp(0, _edge) / _edge),
      _ => 0,
    };
    if (_step == 0) {
      stop();
    } else {
      _ticker ??= Timer.periodic(const Duration(milliseconds: 16), (_) => _scroll());
    }
  }

  void _scroll() {
    final controller = widget.controller;
    if (!controller.hasClients) return;
    final position = controller.position;
    final target = (position.pixels + _step).clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) controller.jumpTo(target);
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AutoScrollScope(state: this, child: widget.child);
}

class _AutoScrollScope extends InheritedWidget {
  const _AutoScrollScope({required this.state, required super.child});

  final NoteDragAutoScrollState state;

  @override
  bool updateShouldNotify(_AutoScrollScope oldWidget) => false;
}
