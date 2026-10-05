import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/widgets/shared/icon_badge.dart";

class FileTypeIcon extends StatelessWidget {
  FileTypeIcon({required FileEntry entry, required this.size, super.key}) : isDir = entry.isDir, mime = entry.mime;

  const FileTypeIcon.of({required this.isDir, required this.mime, required this.size, super.key});

  final bool isDir;
  final String mime;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style(context);
    return IconBadge(icon: icon, color: color, size: size);
  }

  (IconData, Color) _style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    if (isDir) return (IconsaxPlusBold.folder_2, cs.primary);
    if (mime.startsWith("image/")) return (IconsaxPlusLinear.gallery, colors.rose);
    if (mime.startsWith("video/")) return (IconsaxPlusLinear.video_play, colors.sky);
    if (mime.startsWith("audio/")) return (IconsaxPlusLinear.music, colors.success);
    if (mime == "application/pdf") return (IconsaxPlusLinear.document_text, cs.error);
    if (mime.startsWith("text/")) return (IconsaxPlusLinear.document_text_1, cs.tertiary);
    if (mime.startsWith("application/zip") || mime.startsWith("application/x-")) {
      return (IconsaxPlusLinear.archive, cs.tertiary);
    }
    return (IconsaxPlusLinear.document, cs.outline);
  }
}
