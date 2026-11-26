import "dart:math" as math;

class TimedSlot<T> {
  const TimedSlot(this.item, this.startMinute, this.endMinute);

  final T item;
  final int startMinute;
  final int endMinute;
}

class PlacedSlot<T> {
  const PlacedSlot({
    required this.item,
    required this.startMinute,
    required this.endMinute,
    required this.column,
    required this.span,
    required this.columns,
  });

  final T item;
  final int startMinute;
  final int endMinute;
  final int column;
  final int span;
  final int columns;

  double get left => column / columns;

  double get width => span / columns;
}

List<PlacedSlot<T>> layoutTimedSlots<T>(Iterable<TimedSlot<T>> slots, {int minimumMinutes = 20}) {
  final sorted = slots.toList()
    ..sort((a, b) {
      final byStart = a.startMinute.compareTo(b.startMinute);
      return byStart != 0 ? byStart : b.endMinute.compareTo(a.endMinute);
    });
  final placed = <PlacedSlot<T>>[];
  var cluster = <_Placement<T>>[];
  var clusterEnd = -1;

  for (final slot in sorted) {
    final visualEnd = math.max(slot.endMinute, slot.startMinute + minimumMinutes);
    if (cluster.isNotEmpty && slot.startMinute >= clusterEnd) {
      placed.addAll(_finishCluster(cluster));
      cluster = [];
      clusterEnd = -1;
    }
    final column = _firstFreeColumn(cluster, slot.startMinute);
    cluster.add(_Placement(slot, visualEnd, column));
    clusterEnd = math.max(clusterEnd, visualEnd);
  }
  placed.addAll(_finishCluster(cluster));
  return placed;
}

int _firstFreeColumn<T>(List<_Placement<T>> cluster, int start) {
  for (var column = 0; ; column++) {
    final busy = cluster.any((placement) => placement.column == column && placement.visualEnd > start);
    if (!busy) return column;
  }
}

Iterable<PlacedSlot<T>> _finishCluster<T>(List<_Placement<T>> cluster) {
  if (cluster.isEmpty) return const [];
  final columns = cluster.map((placement) => placement.column).reduce(math.max) + 1;
  return [
    for (final placement in cluster)
      PlacedSlot(
        item: placement.slot.item,
        startMinute: placement.slot.startMinute,
        endMinute: placement.slot.endMinute,
        column: placement.column,
        span: _expandableSpan(placement, cluster, columns),
        columns: columns,
      ),
  ];
}

int _expandableSpan<T>(_Placement<T> placement, List<_Placement<T>> cluster, int columns) {
  var span = 1;
  for (var column = placement.column + 1; column < columns; column++) {
    final blocked = cluster.any((other) => other.column == column && other.overlaps(placement));
    if (blocked) break;
    span++;
  }
  return span;
}

class _Placement<T> {
  _Placement(this.slot, this.visualEnd, this.column);

  final TimedSlot<T> slot;
  final int visualEnd;
  final int column;

  bool overlaps(_Placement<T> other) => slot.startMinute < other.visualEnd && other.slot.startMinute < visualEnd;
}
