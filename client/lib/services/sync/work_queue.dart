import "dart:async";
import "dart:collection";

Future<void> runPool<T>(Iterable<T> items, int workers, Future<void> Function(T item) work) {
  final pending = items.iterator;
  Future<void> worker() async {
    while (pending.moveNext()) {
      await work(pending.current);
    }
  }

  return Future.wait([for (var i = 0; i < workers; i++) worker()]);
}

class AsyncQueue<T> {
  AsyncQueue({required this.capacity});

  final int capacity;
  final _items = Queue<T>();
  final _takers = Queue<Completer<T?>>();
  final _putters = Queue<Completer<void>>();
  var _closed = false;

  Future<void> add(T item) async {
    while (_items.length >= capacity && _takers.isEmpty) {
      final space = Completer<void>();
      _putters.add(space);
      await space.future;
    }
    if (_takers.isNotEmpty) {
      _takers.removeFirst().complete(item);
    } else {
      _items.add(item);
    }
  }

  Future<T?> take() {
    if (_items.isNotEmpty) {
      final item = _items.removeFirst();
      if (_putters.isNotEmpty) _putters.removeFirst().complete();
      return Future.value(item);
    }
    if (_closed) return Future.value();
    final taker = Completer<T?>();
    _takers.add(taker);
    return taker.future;
  }

  void close() {
    _closed = true;
    while (_takers.isNotEmpty) {
      _takers.removeFirst().complete(null);
    }
  }

  Future<void> drain(int workers, Future<void> Function(T item) work) {
    Future<void> worker() async {
      for (var item = await take(); item != null; item = await take()) {
        await work(item);
      }
    }

    return Future.wait([for (var i = 0; i < workers; i++) worker()]);
  }
}
