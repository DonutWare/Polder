import "package:flutter/widgets.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";

class DriveHost {
  const DriveHost({this.openNote});

  final void Function(BuildContext context, String path)? openNote;
}

final driveHostProvider = Provider<DriveHost>((_) => const DriveHost());

DriveHost driveHostOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(driveHostProvider);
