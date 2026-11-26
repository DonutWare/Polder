import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

bool get isApplePlatform => const {TargetPlatform.macOS, TargetPlatform.iOS}.contains(defaultTargetPlatform);

bool get commandPressed =>
    isApplePlatform ? HardwareKeyboard.instance.isMetaPressed : HardwareKeyboard.instance.isControlPressed;

bool get shiftPressed => HardwareKeyboard.instance.isShiftPressed;
