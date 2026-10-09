import "dart:typed_data";

import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/file_entry.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/providers/service_providers.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/remote_image_picker_dialog.dart";

enum ImageSource { device, files }

typedef ImageLoader = Future<Uint8List> Function();

Future<List<ImageLoader>> pickImages(
  BuildContext context,
  WidgetRef ref,
  ImageSource source, {
  required bool multiple,
}) async {
  switch (source) {
    case ImageSource.device:
      final picked = await ref.read(filePickerServiceProvider).pickFiles();
      return [
        for (final file in picked)
          () => file
              .openRead()
              .fold(BytesBuilder(copy: false), (bytes, chunk) => bytes..add(chunk))
              .then((b) => b.takeBytes()),
      ];
    case ImageSource.files:
      final entries = await showRemoteImagePicker(context, multiple: multiple);
      final api = ref.read(polderApiProvider);
      return [for (final entry in entries ?? const <FileEntry>[]) () => api.downloadBytes(entry.path)];
  }
}

class ImageSourceMenu extends StatelessWidget {
  const ImageSourceMenu({required this.onSelected, required this.builder, super.key});

  final ValueChanged<ImageSource> onSelected;
  final Widget Function(VoidCallback open) builder;

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      MenuItemButton(
        leadingIcon: const Icon(IconsaxPlusLinear.monitor_mobbile),
        onPressed: () => onSelected(ImageSource.device),
        child: Text(context.localized.imageFromDevice),
      ),
      MenuItemButton(
        leadingIcon: const Icon(IconsaxPlusLinear.folder_2),
        onPressed: () => onSelected(ImageSource.files),
        child: Text(context.localized.imageFromFiles),
      ),
    ],
    builder: (context, controller, _) => builder(() => controller.isOpen ? controller.close() : controller.open()),
  );
}
