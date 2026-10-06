import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/search.dart";
import "package:polder/providers/search/search_provider.dart";
import "package:polder/screens/search/widgets/search_filter_label.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/shared/remote_folder_picker_dialog.dart";

Future<SearchFilter?> showSearchFilterBuilder(BuildContext context) =>
    showDialog<SearchFilter>(context: context, builder: (_) => const SearchFilterBuilder());

const _typeKeys = [SearchKey.type, SearchKey.modified, SearchKey.size, SearchKey.folder];
const _relativePresets = ["today", "yesterday", "7d", "30d", "1y"];
const _sizePresets = ["1mb", "10mb", "100mb", "1gb"];

class SearchFilterBuilder extends ConsumerStatefulWidget {
  const SearchFilterBuilder({super.key});

  @override
  ConsumerState<SearchFilterBuilder> createState() => _SearchFilterBuilderState();
}

class _SearchFilterBuilderState extends ConsumerState<SearchFilterBuilder> {
  SearchKey _key = SearchKey.type;
  SearchOp _op = SearchOp.equals;
  List<String> _values = [];
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  List<SearchOp> get _ops => switch (_key) {
    SearchKey.type || SearchKey.ext || SearchKey.folder => const [SearchOp.equals, SearchOp.notEquals],
    SearchKey.modified => const [SearchOp.greater, SearchOp.less, SearchOp.equals, SearchOp.between],
    SearchKey.size => const [SearchOp.greater, SearchOp.less, SearchOp.between],
  };

  bool get _valid => _op == SearchOp.between ? _values.length == 2 : _values.isNotEmpty;

  void _selectKey(SearchKey key) => setState(() {
    _key = key;
    _values = [];
    _op = _ops.first;
  });

  void _selectOp(SearchOp op) => setState(() {
    if ((op == SearchOp.between) != (_op == SearchOp.between) && _key != SearchKey.type) _values = [];
    _op = op;
  });

  void _toggle(String value) => setState(() {
    if (!_values.remove(value)) _values = [..._values, value];
  });

  void _single(String value) => setState(() => _values = [value]);

  void _addCustom() {
    final value = _custom.text.trim().toLowerCase().replaceFirst(RegExp(r"^\."), "");
    if (value.isEmpty) return;
    _custom.clear();
    if (_key == SearchKey.size) return _single(value);
    if (!_values.contains(value)) setState(() => _values = [..._values, value]);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    if (_op == SearchOp.between) {
      final range = await showDateRangePicker(context: context, firstDate: DateTime(1970), lastDate: now);
      if (range != null) setState(() => _values = [_day(range.start), _day(range.end)]);
      return;
    }
    final picked = await showDatePicker(context: context, firstDate: DateTime(1970), lastDate: now, initialDate: now);
    if (picked != null) _single(_day(picked));
  }

  Future<void> _pickFolder() async {
    final folder = await showRemoteFolderPicker(context, initialPath: _values.lastOrNull ?? RemotePath.root);
    if (folder != null && !_values.contains(folder)) setState(() => _values = [..._values, folder]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.localized;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.searchFilterAdd),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              SegmentedButton<SearchKey>(
                showSelectedIcon: false,
                segments: [for (final key in _typeKeys) ButtonSegment(value: key, label: Text(key.label(l)))],
                selected: {_key},
                onSelectionChanged: (selection) => _selectKey(selection.single),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final op in _ops)
                    ChoiceChip(
                      label: Text(searchOpLabel(l, _key, op)),
                      selected: op == _op,
                      onSelected: (_) => _selectOp(op),
                    ),
                ],
              ),
              Text(l.searchFilterValues, style: theme.textTheme.labelLarge),
              ..._valueEditor(context),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _valid ? () => Navigator.pop(context, SearchFilter(key: _key, op: _op, values: _values)) : null,
          child: Text(l.add),
        ),
      ],
    );
  }

  List<Widget> _valueEditor(BuildContext context) {
    final l = context.localized;
    switch (_key) {
      case SearchKey.type || SearchKey.ext:
        final suggestions = ref.watch(searchSuggestionsProvider((query: "type=", cursor: 5))).value?.suggestions ?? [];
        final offered = {for (final suggestion in suggestions) suggestion.value: suggestion.count};
        for (final value in _values) {
          offered.putIfAbsent(value, () => 0);
        }
        return [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final MapEntry(key: value, value: count) in offered.entries)
                FilterChip(
                  label: Text(count > 0 ? "$value ($count)" : value),
                  selected: _values.contains(value),
                  onSelected: (_) => _toggle(value),
                ),
            ],
          ),
          _customField(l.searchCustomType),
        ];
      case SearchKey.modified:
        return [
          if (_op != SearchOp.between)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in _relativePresets)
                  ChoiceChip(
                    label: Text(searchValueLabel(l, SearchKey.modified, preset)),
                    selected: _values.contains(preset),
                    onSelected: (_) => _single(preset),
                  ),
              ],
            ),
          OutlinedButton.icon(
            icon: const Icon(IconsaxPlusLinear.calendar_1),
            label: Text(switch (_values) {
              [final from, final to] when _op == SearchOp.between => l.searchRange(from, to),
              [final day] when !_relativePresets.contains(day) => day,
              _ => _op == SearchOp.between ? l.searchPickRange : l.searchPickDate,
            }),
            onPressed: _pickDate,
          ),
        ];
      case SearchKey.size:
        if (_op == SearchOp.between) {
          return [
            Row(
              spacing: 12,
              children: [
                for (final index in [0, 1])
                  Expanded(
                    child: TextFormField(
                      initialValue: _values.elementAtOrNull(index),
                      decoration: InputDecoration(
                        labelText: index == 0 ? l.searchSizeFrom : l.searchSizeTo,
                        hintText: "10mb",
                      ),
                      onChanged: (value) => setState(() {
                        final next = [_values.elementAtOrNull(0) ?? "", _values.elementAtOrNull(1) ?? ""];
                        next[index] = value.trim().toLowerCase();
                        _values = next.every((part) => part.isNotEmpty)
                            ? next
                            : next.where((part) => part.isNotEmpty).toList();
                      }),
                    ),
                  ),
              ],
            ),
          ];
        }
        return [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in {..._sizePresets, ..._values})
                ChoiceChip(label: Text(preset), selected: _values.contains(preset), onSelected: (_) => _single(preset)),
            ],
          ),
          _customField(l.searchCustomSize),
        ];
      case SearchKey.folder:
        return [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final folder in _values)
                InputChip(
                  avatar: const Icon(IconsaxPlusLinear.folder_2, size: 16),
                  label: Text(folder),
                  onDeleted: () => _toggle(folder),
                ),
            ],
          ),
          OutlinedButton.icon(
            icon: const Icon(IconsaxPlusLinear.folder_add),
            label: Text(l.searchChooseFolder),
            onPressed: _pickFolder,
          ),
        ];
    }
  }

  Widget _customField(String hint) => TextField(
    controller: _custom,
    decoration: InputDecoration(
      hintText: hint,
      suffixIcon: IconButton(icon: const Icon(IconsaxPlusLinear.add), onPressed: _addCustom),
    ),
    onSubmitted: (_) => _addCustom(),
  );
}

String _day(DateTime date) =>
    "${date.year.toString().padLeft(4, "0")}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
