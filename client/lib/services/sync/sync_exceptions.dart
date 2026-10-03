class LocalRootMissingException implements Exception {
  const LocalRootMissingException(this.path);

  final String path;

  @override
  String toString() => "LocalRootMissingException($path)";
}

class HashMismatchException implements Exception {
  const HashMismatchException({required this.expected, required this.actual});

  final String expected;
  final String actual;

  @override
  String toString() => "HashMismatchException(expected $expected, got $actual)";
}
