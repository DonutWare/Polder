import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/gestures.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/providers/app/navigation_history_provider.dart";
import "package:polder/providers/notes/note_selection_provider.dart";
import "package:polder/providers/notes/notes_tree_provider.dart";
import "package:polder/providers/notes/renamed_note_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/notes/notes_actions.dart";
import "package:polder/util/adaptive_layout/adaptive_layout.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/drag_chip.dart";
import "package:polder/widgets/shared/escape_cancels_drag.dart";
import "package:polder/widgets/tags/tag_picker.dart";

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

enum _NodeAction { newSubpage, rename, tags, select, move, delete }

class NoteDrag {
  const NoteDrag(this.nodes);

  final List<NoteTreeNode> nodes;
}

abstract final class NoteNodeActions {
  static Rect anchorOf(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> showMenuFor(
    BuildContext context,
    WidgetRef ref, {
    required List<NoteTreeNode> nodes,
    required Rect anchor,
    required String? selectedPath,
    VoidCallback? onSelect,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final local = Rect.fromPoints(overlay.globalToLocal(anchor.topLeft), overlay.globalToLocal(anchor.bottomRight));
    final localized = context.localized;
    final single = nodes.length == 1 ? nodes.single : null;
    final action = await showMenu<_NodeAction>(
      context: context,
      position: RelativeRect.fromRect(local, Offset.zero & overlay.size),
      items: [
        if (single != null) ...[
          PopupMenuItem(value: _NodeAction.newSubpage, child: Text(localized.noteNewSubpage)),
          PopupMenuItem(value: _NodeAction.rename, child: Text(localized.rename)),
        ],
        PopupMenuItem(value: _NodeAction.tags, child: Text(localized.tagsAction)),
        if (single != null && onSelect != null)
          PopupMenuItem(value: _NodeAction.select, child: Text(localized.noteSelect)),
        PopupMenuItem(value: _NodeAction.move, child: Text(localized.noteMove)),
        PopupMenuItem(value: _NodeAction.delete, child: Text(localized.delete)),
      ],
    );
    if (action == null || !context.mounted) return;
    final navigation = ref.read(navigationHistoryProvider.notifier);
    final renames = ref.read(renamedNoteProvider.notifier);
    final selection = ref.read(noteSelectionProvider.notifier);
    switch (action) {
      case _NodeAction.newSubpage:
        await createSubpage(context, ref, single!);
      case _NodeAction.rename:
        final renamed = await NotesActions.rename(context, single!);
        if (renamed != null) _follow(navigation, renames, selectedPath, {single: renamed});
      case _NodeAction.tags:
        await showTagPicker(context, [for (final node in nodes) node.page ?? node.folder!]);
      case _NodeAction.select:
        onSelect?.call();
      case _NodeAction.move:
        final moved = await NotesActions.moveAll(context, nodes);
        if (moved.isNotEmpty) selection.clear();
        _follow(navigation, renames, selectedPath, moved);
      case _NodeAction.delete:
        final deleted = await NotesActions.deleteAll(context, nodes);
        if (!deleted) return;
        selection.clear();
        if (selectedPath != null && nodes.any((node) => node.holds(selectedPath))) {
          navigation.replace(AppRoutes.notes);
        }
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
    required NoteDrag drag,
    required String destination,
    required String? selectedPath,
  }) async {
    final expanded = ref.read(expandedNotesProvider.notifier);
    final navigation = ref.read(navigationHistoryProvider.notifier);
    final renames = ref.read(renamedNoteProvider.notifier);
    final selection = ref.read(noteSelectionProvider.notifier);
    final moved = await NotesActions.moveAllInto(context, drag.nodes, destination);
    if (moved.isEmpty) return;
    selection.clear();
    expanded.expand(destination);
    _follow(navigation, renames, selectedPath, moved);
  }

  static void _follow(
    NavigationHistoryNotifier navigation,
    RenamedNote renames,
    String? selectedPath,
    Map<NoteTreeNode, String> moved,
  ) {
    if (selectedPath == null) return;
    for (final MapEntry(key: node, value: movedTo) in moved.entries) {
      final selected = NotesActions.pathAfterMove(selectedPath, node, movedTo);
      if (selected == null) continue;
      renames.record(selectedPath, selected);
      navigation.replace(AppRoutes.noteAt(selected));
      return;
    }
  }
}

class NoteDragSource extends StatefulWidget {
  const NoteDragSource({required this.nodes, required this.child, this.onHold, super.key});

  final List<NoteTreeNode> nodes;
  final Widget child;
  final ValueChanged<Rect>? onHold;

  @override
  State<NoteDragSource> createState() => _NoteDragSourceState();
}

class _NoteDragSourceState extends State<NoteDragSource> {
  var _travelled = 0.0;
  var _cancelled = false;

  void _startHold() {
    _travelled = 0;
    _cancelled = false;
    unawaited(HapticFeedback.mediumImpact());
  }

  void _endHold(DraggableDetails details) {
    final onHold = widget.onHold;
    if (onHold == null || _cancelled || details.wasAccepted || _travelled > kTouchSlop || !mounted) return;
    onHold(NoteNodeActions.anchorOf(context));
  }

  @override
  Widget build(BuildContext context) {
    final scroller = NoteDragAutoScroll.maybeOf(context);
    final drag = NoteDrag(widget.nodes);
    final feedback = _DragFeedback(nodes: widget.nodes);
    final dragging = Opacity(opacity: 0.4, child: widget.child);
    return EscapeCancelsDrag(
      onCancel: () => _cancelled = true,
      child: AdaptiveLayout.usesPointer(context)
          ? Draggable<NoteDrag>(
              data: drag,
              feedback: feedback,
              childWhenDragging: dragging,
              onDragUpdate: (details) => scroller?.follow(details.globalPosition),
              onDragEnd: (_) => scroller?.stop(),
              child: widget.child,
            )
          : _holdDraggable(drag, feedback, dragging, scroller),
    );
  }

  Widget _holdDraggable(NoteDrag drag, Widget feedback, Widget dragging, NoteDragAutoScrollState? scroller) =>
      LongPressDraggable<NoteDrag>(
        data: drag,
        feedback: feedback,
        childWhenDragging: dragging,
        onDragStarted: _startHold,
        onDragUpdate: (details) {
          _travelled += details.delta.distance;
          scroller?.follow(details.globalPosition);
        },
        onDragEnd: (details) {
          scroller?.stop();
          _endHold(details);
        },
        child: widget.child,
      );
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.nodes});

  final List<NoteTreeNode> nodes;

  @override
  Widget build(BuildContext context) {
    final single = nodes.length == 1 ? nodes.single : null;
    return DragChip(
      icon: Icon(switch (single) {
        null => IconsaxPlusLinear.copy,
        NoteTreeNode(page: null) => IconsaxPlusLinear.folder,
        _ => IconsaxPlusLinear.note_2,
      }),
      label: single?.name ?? context.localized.activityItemCount(nodes.length),
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
  final ValueChanged<NoteDrag> onDrop;
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

  bool _accepts(DragTargetDetails<NoteDrag> details) {
    final accepts = NotesActions.canMoveAllInto(details.data.nodes, widget.destination);
    if (accepts && widget.onLinger != null) _linger = Timer(NoteDropTarget.lingerDelay, widget.onLinger!);
    return accepts;
  }

  void _leave() {
    _linger?.cancel();
    _linger = null;
  }

  @override
  Widget build(BuildContext context) => DragTarget<NoteDrag>(
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
