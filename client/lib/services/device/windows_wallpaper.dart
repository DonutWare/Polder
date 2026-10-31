import "dart:ffi";

import "package:ffi/ffi.dart";

const _setDesktopWallpaper = 0x0014;
const _updateIniFile = 0x01;
const _sendChange = 0x02;

typedef _SystemParametersInfoNative = Int32 Function(Uint32 action, Uint32 param, Pointer<Utf16> value, Uint32 flags);
typedef _SystemParametersInfo = int Function(int action, int param, Pointer<Utf16> value, int flags);

void setWindowsWallpaper(String path) {
  final systemParametersInfo = DynamicLibrary.open("user32.dll")
      .lookupFunction<_SystemParametersInfoNative, _SystemParametersInfo>("SystemParametersInfoW");
  final nativePath = path.toNativeUtf16();
  try {
    final succeeded = systemParametersInfo(_setDesktopWallpaper, 0, nativePath, _updateIniFile | _sendChange);
    if (succeeded == 0) throw StateError("Windows did not accept the wallpaper");
  } finally {
    calloc.free(nativePath);
  }
}
