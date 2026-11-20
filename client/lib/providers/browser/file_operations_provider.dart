import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/util/remote_path.dart";

enum FileOperationKind { move, copy, delete, rename, restore, purge }

enum FileOperationItemState { waiting, active, done, failed }

class FileOperationItem {
  const FileOperationItem({
    required this.path,
    required this.isDir,
    this.targetName,
    this.label,
    this.state = FileOperationItemState.waiting,
  });

  factory FileOperationItem.of(FileEntry entry, {String? targetName}) =>
      FileOperationItem(path: entry.path, isDir: entry.isDir, targetName: targetName);

  final String path;
  final bool isDir;
  final String? targetName;
  final String? label;
  final FileOperationItemState state;

  String get name => RemotePath.name(path);

  String get displayName => label ?? name;

  String get arrivingName => targetName ?? name;

  String get parent => RemotePath.parent(path);

  bool get isBusy => state == FileOperationItemState.waiting || state == FileOperationItemState.active;

  FileOperationItem withState(FileOperationItemState state) =>
      FileOperationItem(path: path, isDir: isDir, targetName: targetName, label: label, state: state);
}

class FileOperation {
  const FileOperation({
    required this.id,
    required this.kind,
    required this.items,
    this.destination,
    this.ownFiles = true,
    this.finished = false,
  });

  final int id;
  final FileOperationKind kind;
  final List<FileOperationItem> items;
  final String? destination;
  final bool ownFiles;
  final bool finished;

  int get completed => items.where((item) => !item.isBusy).length;

  bool get failed => items.any((item) => item.state == FileOperationItemState.failed);

  double? get progress => finished ? 1 : (items.length < 2 ? null : completed / items.length);

  bool get removesSource => kind == FileOperationKind.move || kind == FileOperationKind.delete;

  FileOperation copyWith({List<FileOperationItem>? items, bool? finished}) => FileOperation(
    id: id,
    kind: kind,
    items: items ?? this.items,
    destination: destination,
    ownFiles: ownFiles,
    finished: finished ?? this.finished,
  );
}

final fileOperationsProvider = NotifierProvider<FileOperationsNotifier, List<FileOperation>>(
  FileOperationsNotifier.new,
);

class FileOperationsNotifier extends Notifier<List<FileOperation>> {
  static const revealAfter = Duration(milliseconds: 400);
  static const lingerFor = Duration(seconds: 2);

  var _nextId = 0;
  final Map<int, FileOperation> _running = {};
  final Set<int> _revealed = {};

  @override
  List<FileOperation> build() {
    ref.onDispose(() {
      _running.clear();
      _revealed.clear();
    });
    return const [];
  }

  Future<void> run({
    required FileOperationKind kind,
    required List<FileOperationItem> items,
    required Future<void> Function(FileOperationItem item) perform,
    String? destination,
    bool ownFiles = true,
    void Function(FileOperationItem item)? onItemDone,
  }) async {
    if (items.isEmpty) return;
    final id = _nextId++;
    _running[id] = FileOperation(id: id, kind: kind, items: items, destination: destination, ownFiles: ownFiles);
    final reveal = Timer(revealAfter, () => _reveal(id));
    (Object, StackTrace)? failure;
    try {
      for (var index = 0; index < items.length; index++) {
        _setItem(id, index, FileOperationItemState.active);
        try {
          await perform(items[index]);
          _setItem(id, index, FileOperationItemState.done);
          onItemDone?.call(items[index]);
        } catch (error, stack) {
          failure ??= (error, stack);
          _setItem(id, index, FileOperationItemState.failed);
        }
      }
    } finally {
      reveal.cancel();
      _finish(id);
    }
    if (failure case (final error, final stack)) Error.throwWithStackTrace(error, stack);
  }

  bool isBusy(String path) =>
      _running.values.any((operation) => operation.items.any((item) => item.isBusy && item.path == path));

  Future<T> runSingle<T>({
    required FileOperationKind kind,
    required FileOperationItem item,
    required Future<T> Function() perform,
    String? destination,
    bool ownFiles = true,
  }) async {
    late T result;
    await run(
      kind: kind,
      items: [item],
      destination: destination,
      ownFiles: ownFiles,
      perform: (_) async => result = await perform(),
    );
    return result;
  }

  void _setItem(int id, int index, FileOperationItemState itemState) {
    final operation = _running[id];
    if (operation == null) return;
    final items = [...operation.items];
    items[index] = items[index].withState(itemState);
    _update(operation.copyWith(items: items));
  }

  void _reveal(int id) {
    final operation = _running[id];
    if (operation == null || operation.finished) return;
    _revealed.add(id);
    state = [...state, operation];
  }

  void _finish(int id) {
    final operation = _running[id];
    if (operation == null) return;
    if (!_revealed.contains(id)) {
      _running.remove(id);
      return;
    }
    _update(operation.copyWith(finished: true));
    Timer(lingerFor, () => _remove(id));
  }

  void _remove(int id) {
    _running.remove(id);
    if (!_revealed.remove(id) || !ref.mounted) return;
    state = [
      for (final operation in state)
        if (operation.id != id) operation,
    ];
  }

  void _update(FileOperation operation) {
    _running[operation.id] = operation;
    if (!_revealed.contains(operation.id) || !ref.mounted) return;
    state = [for (final current in state) current.id == operation.id ? operation : current];
  }
}

class EntryOperation {
  const EntryOperation({required this.kind, required this.state});

  final FileOperationKind kind;
  final FileOperationItemState state;
}

final entryOperationsProvider = Provider.autoDispose.family<Map<String, EntryOperation>, String>((ref, directory) {
  final busy = <String, EntryOperation>{};
  for (final operation in ref.watch(fileOperationsProvider)) {
    if (!operation.ownFiles) continue;
    for (final item in operation.items) {
      if (item.parent == directory && item.state != FileOperationItemState.failed) {
        busy[item.name] = EntryOperation(kind: operation.kind, state: item.state);
      }
    }
  }
  return busy;
});

class ArrivingItem {
  const ArrivingItem({required this.name, required this.isDir, required this.kind, required this.state});

  final String name;
  final bool isDir;
  final FileOperationKind kind;
  final FileOperationItemState state;
}

final arrivingItemsProvider = Provider.autoDispose.family<List<ArrivingItem>, String>((ref, directory) {
  return [
    for (final operation in ref.watch(fileOperationsProvider))
      if (operation.ownFiles && operation.destination == directory)
        for (final item in operation.items)
          if (item.state != FileOperationItemState.failed && item.path != RemotePath.join(directory, item.arrivingName))
            ArrivingItem(name: item.arrivingName, isDir: item.isDir, kind: operation.kind, state: item.state),
  ];
});
