import "dart:convert";
import "dart:ffi";
import "dart:io";
import "dart:typed_data";

import "package:ffi/ffi.dart";
import "package:path/path.dart" as p;
import "package:win32/win32.dart";

import "package:polder_account_link/shared_account_platform.dart";

class WindowsSharedAccountPlatform extends SharedAccountPlatform {
  static void registerWith() => SharedAccountPlatform.instance = WindowsSharedAccountPlatform();

  @override
  Future<String?> read(String namespace) async {
    final file = _accountFile(namespace);
    if (!file.existsSync()) return null;
    try {
      final record = jsonDecode(utf8.decode(_unprotect(await file.readAsBytes()))) as Map<String, dynamic>;
      return record["json"] as String?;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String namespace, {required String name, required String json}) async {
    final file = _accountFile(namespace);
    await file.parent.create(recursive: true);
    final staged = File("${file.path}.$pid.tmp");
    await staged.writeAsBytes(_protect(utf8.encode(jsonEncode({"name": name, "json": json}))), flush: true);
    await staged.rename(file.path);
  }

  @override
  Future<void> remove(String namespace) async {
    final file = _accountFile(namespace);
    if (file.existsSync()) await file.delete();
  }

  @override
  Stream<void> changes(String namespace) => const Stream.empty();

  static File _accountFile(String namespace) {
    final appData = Platform.environment["APPDATA"] ?? Platform.environment["LOCALAPPDATA"] ?? ".";
    return File(p.join(appData, namespace, "account.dat"));
  }

  static Uint8List _protect(List<int> plain) => _transform(plain, protect: true);

  static Uint8List _unprotect(List<int> sealed) => _transform(sealed, protect: false);

  static Uint8List _transform(List<int> input, {required bool protect}) => using((arena) {
    final data = arena<Uint8>(input.length);
    data.asTypedList(input.length).setAll(0, input);
    final source = arena.allocate<CRYPT_INTEGER_BLOB>(sizeOf<CRYPT_INTEGER_BLOB>());
    source.ref
      ..cbData = input.length
      ..pbData = data;
    final target = arena.allocate<CRYPT_INTEGER_BLOB>(sizeOf<CRYPT_INTEGER_BLOB>());
    final Win32Result(value: succeeded, error: error) = protect
        ? CryptProtectData(source, null, null, null, 0, target)
        : CryptUnprotectData(source, null, null, null, 0, target);
    if (!succeeded || target.ref.pbData.address == NULL) {
      throw WindowsException(
        error.toHRESULT(),
        message: protect ? "CryptProtectData failed" : "CryptUnprotectData failed",
      );
    }
    try {
      return Uint8List.fromList(target.ref.pbData.asTypedList(target.ref.cbData));
    } finally {
      LocalFree(HLOCAL(target.ref.pbData.cast()));
    }
  });
}
