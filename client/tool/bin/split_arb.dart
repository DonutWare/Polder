import "dart:convert";
import "dart:io";

void main(List<String> arguments) {
  if (arguments.length < 5) {
    stderr.writeln("usage: dart tool/l10n/split_arb.dart <from-dir> <from-prefix> <to-dir> <to-prefix> <key>...");
    exitCode = 64;
    return;
  }
  final [fromDir, fromPrefix, toDir, toPrefix, ...keys] = arguments;
  final sources = Directory(fromDir)
      .listSync()
      .whereType<File>()
      .where((file) => _name(file).startsWith("${fromPrefix}_") && file.path.endsWith(".arb"));
  for (final source in sources) {
    final locale = _name(source).substring(fromPrefix.length + 1, _name(source).length - ".arb".length);
    final target = File("$toDir/${toPrefix}_$locale.arb");
    final moved = _moveKeys(source, target, locale, keys);
    stdout.writeln("$locale: moved $moved keys to ${target.path}");
  }
}

int _moveKeys(File source, File target, String locale, List<String> keys) {
  final from = _read(source);
  final to = target.existsSync() ? _read(target) : <String, Object?>{"@@locale": locale};
  var moved = 0;
  for (final key in keys) {
    for (final entry in [key, "@$key"]) {
      if (!from.containsKey(entry)) continue;
      to[entry] = from.remove(entry);
      if (entry == key) moved++;
    }
  }
  _write(source, from);
  target.parent.createSync(recursive: true);
  _write(target, to);
  return moved;
}

String _name(File file) => file.uri.pathSegments.last;

Map<String, Object?> _read(File file) => Map<String, Object?>.from(jsonDecode(file.readAsStringSync()) as Map);

void _write(File file, Map<String, Object?> content) =>
    file.writeAsStringSync("${const JsonEncoder.withIndent("\t").convert(content)}\n");
