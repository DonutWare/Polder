import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/browser/browser_selection_provider.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/screens/browser/widgets/file_actions_menu.dart";
import "package:polder/screens/browser/widgets/file_open_action.dart";
import "package:polder/util/remote_path.dart";

bool get _apple => const {TargetPlatform.macOS, TargetPlatform.iOS}.contains(defaultTargetPlatform);

bool get _commandPressed =>
    _apple ? HardwareKeyboard.instance.isMetaPressed : HardwareKeyboard.instance.isControlPressed;

class EntryInteraction {
  const EntryInteraction({required this.selected, required this.onTap, this.onIconTap, this.onMenu});

  final bool selected;
  final VoidCallback onTap;

  final VoidCallback? onIconTap;

  final void Function(RelativeRect position)? onMenu;
}

class SelectableEntry extends ConsumerStatefulWidget {
  const SelectableEntry({required this.parentPath, required this.entry, required this.builder, super.key});

  final String parentPath;
  final FileEntry entry;
  final Widget Function(BuildContext context, EntryInteraction interaction) builder;

  @override
  ConsumerState<SelectableEntry> createState() => _SelectableEntryState();
}

class _SelectableEntryState extends ConsumerState<SelectableEntry> {
  Duration? _lastClick;
  Offset _lastClickPosition = Offset.zero;

  String get _name => widget.entry.name;
  BrowserSelection get _selection => ref.read(browserSelectionProvider(widget.parentPath));
  BrowserSelectionNotifier get _notifier => ref.read(browserSelectionProvider(widget.parentPath).notifier);

  List<FileEntry> _targets() => _selection.contains(_name) ? _notifier.selectedEntries : [widget.entry];

  void _showMenu(RelativeRect position) =>
      FileActions.showMenuFor(context, ref, parentPath: widget.parentPath, entries: _targets(), position: position);

  void _selectForMenu() {
    if (!_selection.contains(_name)) _notifier.only(_name);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kSecondaryMouseButton != 0) return _selectForMenu();
    if (event.buttons & kPrimaryButton == 0) return;
    final keyboard = HardwareKeyboard.instance;
    if (_apple && keyboard.isControlPressed) {
      _selectForMenu();
      return _showMenu(FileActions.menuPositionAt(context, event.position));
    }
    final doubleClick =
        _lastClick != null &&
        event.timeStamp - _lastClick! < kDoubleTapTimeout &&
        (event.position - _lastClickPosition).distance < kDoubleTapSlop;
    _lastClick = doubleClick ? null : event.timeStamp;
    _lastClickPosition = event.position;
    if (keyboard.isShiftPressed) return _notifier.extendTo(_name);
    if (_commandPressed) return _notifier.toggle(_name);
    if (doubleClick) {
      _notifier.only(_name);
      openEntry(context, widget.entry);
    } else if (!_selection.contains(_name)) {
      _notifier.only(_name);
    }
  }

  void _onPointerTap() {
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isShiftPressed && !keyboard.isMetaPressed && !keyboard.isControlPressed) _notifier.only(_name);
  }

  void _onTouchTap() {
    if (_selection.isNotEmpty) return _notifier.toggle(_name);
    openEntry(context, widget.entry);
  }

  void _onLongPress(LongPressStartDetails details) {
    Feedback.forLongPress(context);
    _showMenu(FileActions.menuPositionAt(context, details.globalPosition));
  }

  void _reveal() {
    final box = context.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (box == null || position == null) return;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return;
    final insets = MediaQuery.paddingOf(context);
    final top = viewport.getOffsetToReveal(box, 0).offset - insets.top;
    final bottom = viewport.getOffsetToReveal(box, 1).offset + insets.bottom;
    final target = position.pixels > top ? top : (position.pixels < bottom ? bottom : null);
    if (target == null) return;
    position.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = browserSelectionProvider(widget.parentPath);
    final selected = ref.watch(provider.select((selection) => selection.contains(_name)));
    if (!usesPointerSelection) {
      return GestureDetector(
        onLongPressStart: _onLongPress,
        onSecondaryTapUp: (details) => _showMenu(FileActions.menuPositionAt(context, details.globalPosition)),
        child: widget.builder(
          context,
          EntryInteraction(selected: selected, onTap: _onTouchTap, onIconTap: () => _notifier.toggle(_name)),
        ),
      );
    }
    ref.listen(provider.select((selection) => selection.lead == _name), (_, lead) {
      if (!lead) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reveal();
      });
    });
    return Listener(
      onPointerDown: _onPointerDown,
      child: GestureDetector(
        onSecondaryTapUp: (details) => _showMenu(FileActions.menuPositionAt(context, details.globalPosition)),
        child: widget.builder(context, EntryInteraction(selected: selected, onTap: _onPointerTap, onMenu: _showMenu)),
      ),
    );
  }
}

class BrowserSelectionArea extends ConsumerStatefulWidget {
  const BrowserSelectionArea({
    required this.parentPath,
    required this.slots,
    required this.child,
    this.columns = 1,
    super.key,
  });

  final String parentPath;

  final List<String?> slots;

  final int columns;
  final Widget child;

  @override
  ConsumerState<BrowserSelectionArea> createState() => _BrowserSelectionAreaState();
}

class _BrowserSelectionAreaState extends ConsumerState<BrowserSelectionArea> {
  final _focus = FocusNode(debugLabel: "BrowserSelectionArea");

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  BrowserSelectionNotifier get _notifier => ref.read(browserSelectionProvider(widget.parentPath).notifier);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    final selection = ref.read(browserSelectionProvider(widget.parentPath));
    final command = _commandPressed;
    final repeat = event is KeyRepeatEvent;
    final single = selection.length == 1 ? _notifier.selectedEntries.firstOrNull : null;

    bool pressed(LogicalKeyboardKey target, {bool withCommand = false, bool withAlt = false}) =>
        key == target && command == withCommand && keyboard.isAltPressed == withAlt;

    if (pressed(LogicalKeyboardKey.keyA, withCommand: true)) {
      _notifier.selectAll();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape && selection.isNotEmpty) {
      _notifier.clear();
      return KeyEventResult.handled;
    }
    final delete = _apple
        ? pressed(LogicalKeyboardKey.backspace, withCommand: true) || pressed(LogicalKeyboardKey.delete)
        : pressed(LogicalKeyboardKey.delete);
    if (delete && selection.isNotEmpty) {
      if (!repeat) {
        FileActions.delete(context, ref, parentPath: widget.parentPath, entries: _notifier.selectedEntries);
      }
      return KeyEventResult.handled;
    }
    final open = _apple
        ? pressed(LogicalKeyboardKey.keyO, withCommand: true) ||
              pressed(LogicalKeyboardKey.arrowDown, withCommand: true)
        : pressed(LogicalKeyboardKey.enter) || pressed(LogicalKeyboardKey.numpadEnter);
    if (open && single != null) {
      if (!repeat) openEntry(context, single);
      return KeyEventResult.handled;
    }
    final rename = _apple ? pressed(LogicalKeyboardKey.enter) : pressed(LogicalKeyboardKey.f2);
    if (rename && single != null) {
      if (!repeat) FileActions.rename(context, ref, parentPath: widget.parentPath, entry: single);
      return KeyEventResult.handled;
    }
    final up = _apple
        ? pressed(LogicalKeyboardKey.arrowUp, withCommand: true)
        : pressed(LogicalKeyboardKey.arrowUp, withAlt: true);
    if (up && widget.parentPath != RemotePath.root) {
      context.go(AppRoutes.filesAt(RemotePath.parent(widget.parentPath)));
      return KeyEventResult.handled;
    }
    if (command || keyboard.isAltPressed) return KeyEventResult.ignored;
    final step = switch (key) {
      LogicalKeyboardKey.arrowUp => -widget.columns,
      LogicalKeyboardKey.arrowDown => widget.columns,
      LogicalKeyboardKey.arrowLeft when widget.columns > 1 => -1,
      LogicalKeyboardKey.arrowRight when widget.columns > 1 => 1,
      _ => null,
    };
    if (step == null) return KeyEventResult.ignored;
    if (_step(selection.lead, step) case final target?) {
      keyboard.isShiftPressed ? _notifier.extendTo(target) : _notifier.only(target);
    }
    return KeyEventResult.handled;
  }

  String? _step(String? lead, int step) {
    final slots = widget.slots;
    final from = lead == null ? -1 : slots.indexOf(lead);
    if (from < 0) return step > 0 ? slots.nonNulls.firstOrNull : slots.nonNulls.lastOrNull;
    for (var index = from + step; index >= 0 && index < slots.length; index += step) {
      if (slots[index] case final name?) return name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focus,
    autofocus: usesPointerSelection,
    onKeyEvent: _onKey,
    child: Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _focus.requestFocus(),
      child: usesPointerSelection
          ? GestureDetector(behavior: HitTestBehavior.translucent, onTap: _notifier.clear, child: widget.child)
          : widget.child,
    ),
  );
}

class SelectionMark extends StatelessWidget {
  const SelectionMark({required this.selected, this.showUnselected = false, super.key});

  final bool selected;

  final bool showUnselected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: selected
          ? DecoratedBox(
              key: const ValueKey(true),
              decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
              child: Icon(IconsaxPlusBold.tick_circle, color: colors.primary, size: 24),
            )
          : showUnselected
          ? Container(
              key: const ValueKey(false),
              width: 22,
              height: 22,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(color: colors.onSurfaceVariant, width: 1.5),
              ),
            )
          : const SizedBox.shrink(key: ValueKey(null)),
    );
  }
}
