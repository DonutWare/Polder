import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/screens/notes/editor/markdown_editor/markdown_editing_controller.dart";
import "package:polder/services/notes/note_checklist.dart";
import "package:polder/util/localization_helper.dart";

class ChecklistEditor extends StatefulWidget {
  const ChecklistEditor({required this.controller, this.padding = EdgeInsets.zero, super.key});

  final MarkdownEditingController controller;
  final EdgeInsets padding;

  @override
  State<ChecklistEditor> createState() => _ChecklistEditorState();
}

class _ChecklistEditorState extends State<ChecklistEditor> {
  static const _typingWindow = Duration(milliseconds: 800);

  List<_Entry> _entries = [];
  final _typingOrigin = Object();
  _Entry? _lastTypedEntry;
  DateTime? _lastTyped;
  _Entry? _hovered;
  bool _showChecked = true;
  bool _writing = false;

  Iterable<_Entry> get _unchecked => _entries.where((entry) => !entry.item.checked);

  Iterable<_Entry> get _checked => _entries.where((entry) => entry.item.checked);

  @override
  void initState() {
    super.initState();
    _entries = _entriesFrom(widget.controller.text);
    widget.controller.addListener(_documentChanged);
    if (_entries.length == 1 && _entries.single.item.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entries.firstOrNull?.focus.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(ChecklistEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_documentChanged);
    widget.controller.addListener(_documentChanged);
    _replaceEntries(_entriesFrom(widget.controller.text));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_documentChanged);
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  List<_Entry> _entriesFrom(String text) => [
    for (final item in NoteChecklist.parse(text) ?? const <ChecklistItem>[]) _entry(item),
  ];

  _Entry _entry(ChecklistItem item) {
    final entry = _Entry(item, _handleKey);
    entry.focus.addListener(() {
      if (mounted) setState(() {});
    });
    return entry;
  }

  void _replaceEntries(List<_Entry> entries) {
    for (final entry in _entries) {
      entry.dispose();
    }
    _entries = entries;
  }

  void _documentChanged() {
    if (_writing) return;
    final items = NoteChecklist.parse(widget.controller.text);
    if (items == null || listEquals(items, [for (final entry in _entries) entry.item])) return;
    setState(() => _replaceEntries(_entriesFrom(widget.controller.text)));
  }

  void _write({_Entry? typedEntry}) {
    final now = DateTime.now();
    final merge =
        typedEntry != null &&
        identical(typedEntry, _lastTypedEntry) &&
        _lastTyped != null &&
        now.difference(_lastTyped!) < _typingWindow;
    _lastTypedEntry = typedEntry;
    _lastTyped = typedEntry == null ? null : now;
    final text = NoteChecklist.serialize([for (final entry in _entries) entry.item]);
    _writing = true;
    try {
      widget.controller.setValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
        origin: typedEntry == null ? Object() : _typingOrigin,
        mergeWithPrevious: merge,
      );
    } finally {
      _writing = false;
    }
  }

  void _focus(_Entry entry, int offset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_entries.contains(entry)) return;
      entry.focus.requestFocus();
      entry.text.selection = TextSelection.collapsed(offset: offset.clamp(0, entry.text.text.length));
    });
  }

  void _edited(_Entry entry, String value) {
    final lines = value.split("\n");
    if (lines.length == 1) {
      entry.item = entry.item.copyWith(text: value);
      _write(typedEntry: entry);
      return;
    }
    final index = _entries.indexOf(entry);
    entry.item = entry.item.copyWith(text: lines.first);
    entry.text.value = TextEditingValue(
      text: lines.first,
      selection: TextSelection.collapsed(offset: lines.first.length),
    );
    final added = [for (final line in lines.skip(1)) _entry(ChecklistItem(line))];
    setState(() => _entries.insertAll(index + 1, added));
    _write();
    _focus(added.last, 0);
  }

  KeyEventResult _handleKey(_Entry entry, KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.backspace) return KeyEventResult.ignored;
    final selection = entry.text.selection;
    if (!selection.isCollapsed || selection.baseOffset != 0) return KeyEventResult.ignored;
    final visible = entry.item.checked ? _checked.toList() : _unchecked.toList();
    final position = visible.indexOf(entry);
    final previous = position > 0 ? visible[position - 1] : null;
    if (previous == null && entry.item.text.isNotEmpty) return KeyEventResult.ignored;
    final joinAt = previous?.item.text.length ?? 0;
    setState(() {
      _entries.remove(entry);
      if (previous != null) {
        previous.item = previous.item.copyWith(text: previous.item.text + entry.item.text);
        previous.text.text = previous.item.text;
      }
    });
    _write();
    if (previous != null) _focus(previous, joinAt);
    entry.dispose();
    return KeyEventResult.handled;
  }

  void _toggle(_Entry entry, bool checked) {
    setState(() => entry.item = entry.item.copyWith(checked: checked));
    _write();
  }

  void _remove(_Entry entry) {
    setState(() => _entries.remove(entry));
    _write();
    entry.dispose();
  }

  void _add() {
    final entry = _entry(const ChecklistItem(""));
    final lastUnchecked = _unchecked.lastOrNull;
    setState(() => _entries.insert(lastUnchecked == null ? 0 : _entries.indexOf(lastUnchecked) + 1, entry));
    _write();
    _focus(entry, 0);
  }

  void _reorder(int oldIndex, int newIndex) {
    final unchecked = _unchecked.toList();
    final moved = unchecked[oldIndex];
    setState(() {
      _entries.remove(moved);
      final remaining = _unchecked.toList();
      if (newIndex < remaining.length) {
        _entries.insert(_entries.indexOf(remaining[newIndex]), moved);
      } else {
        _entries.insert(remaining.isEmpty ? 0 : _entries.indexOf(remaining.last) + 1, moved);
      }
    });
    _write();
  }

  @override
  Widget build(BuildContext context) {
    final unchecked = _unchecked.toList();
    final checked = _checked.toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(left: widget.padding.left, right: widget.padding.right, top: widget.padding.top),
          sliver: SliverReorderableList(
            itemCount: unchecked.length,
            onReorderItem: _reorder,
            itemBuilder: (context, index) => _row(context, unchecked[index], index: index),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(left: widget.padding.left, right: widget.padding.right),
          sliver: SliverList.list(
            children: [
              _AddItemRow(onTap: _add),
              if (checked.isNotEmpty) ...[
                const Divider(height: 24),
                _CheckedHeader(
                  count: checked.length,
                  expanded: _showChecked,
                  onToggle: () => setState(() => _showChecked = !_showChecked),
                ),
                if (_showChecked)
                  for (final entry in checked) _row(context, entry),
              ],
            ],
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: widget.padding.bottom)),
      ],
    );
  }

  Widget _row(BuildContext context, _Entry entry, {int? index}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final checked = entry.item.checked;
    final style = theme.textTheme.bodyLarge!.copyWith(
      color: checked ? colors.onSurfaceVariant : colors.onSurface,
      decoration: checked ? TextDecoration.lineThrough : null,
      decorationColor: colors.onSurfaceVariant,
    );
    final active = entry.focus.hasFocus || identical(_hovered, entry);
    return MouseRegion(
      key: entry.key,
      onEnter: (_) => setState(() => _hovered = entry),
      onExit: (_) => setState(() => _hovered = identical(_hovered, entry) ? null : _hovered),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: index == null
                  ? null
                  : ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Icon(
                          Icons.drag_indicator,
                          size: 20,
                          color: active ? colors.onSurfaceVariant : colors.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
            ),
            Checkbox(value: checked, onChanged: (value) => _toggle(entry, value ?? false)),
            Expanded(
              child: TextField(
                controller: entry.text,
                focusNode: entry.focus,
                style: style,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration.collapsed(hintText: context.localized.noteListItem),
                onChanged: (value) => _edited(entry, value),
              ),
            ),
            SizedBox(
              width: 40,
              child: active
                  ? IconButton(
                      tooltip: context.localized.noteRemoveItem,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _remove(entry),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  _Entry(this.item, KeyEventResult Function(_Entry entry, KeyEvent event) onKey)
    : text = TextEditingController(text: item.text) {
    focus = FocusNode(onKeyEvent: (_, event) => onKey(this, event));
  }

  final key = UniqueKey();
  ChecklistItem item;
  final TextEditingController text;
  late final FocusNode focus;

  void dispose() {
    text.dispose();
    focus.dispose();
  }
}

class _AddItemRow extends StatelessWidget {
  const _AddItemRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 24),
            SizedBox(width: 48, child: Icon(IconsaxPlusLinear.add, size: 20, color: colors.onSurfaceVariant)),
            Text(
              context.localized.noteListItem,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckedHeader extends StatelessWidget {
  const _CheckedHeader({required this.count, required this.expanded, required this.onToggle});

  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 24),
            SizedBox(
              width: 48,
              child: Icon(expanded ? Icons.expand_more : Icons.chevron_right, color: colors.onSurfaceVariant),
            ),
            Text(
              context.localized.noteCheckedItems(count),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
