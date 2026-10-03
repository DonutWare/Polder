enum QuotaUnit {
  mb(1024 * 1024),
  gb(1024 * 1024 * 1024),
  tb(1024 * 1024 * 1024 * 1024);

  const QuotaUnit(this.bytes);

  final int bytes;

  String get label => name.toUpperCase();

  int toBytes(double amount) => (amount * bytes).round();

  static QuotaUnit bestFor(int bytes) =>
      QuotaUnit.values.reversed.firstWhere((unit) => bytes >= unit.bytes && bytes % unit.bytes == 0, orElse: () => gb);
}
