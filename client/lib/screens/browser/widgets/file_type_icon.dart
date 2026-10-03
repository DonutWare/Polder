import "package:flutter/material.dart";

import "package:iconsax_plus/iconsax_plus.dart";
import "package:nomad/models/file_entry.dart";
import "package:nomad/theme/app_theme.dart";
import "package:nomad/widgets/shared/icon_badge.dart";

class FileTypeIcon extends StatelessWidget {
  const FileTypeIcon({required this.entry, required this.size, super.key});

  final FileEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style(context);
    return IconBadge(icon: icon, color: color, size: size);
  }

  (IconData, Color) _style(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    if (entry.isDir) return (IconsaxPlusBold.folder_2, cs.primary);
    if (entry.isImage) return (IconsaxPlusLinear.gallery, colors.rose);
    if (entry.isVideo) return (IconsaxPlusLinear.video_play, colors.sky);
    if (entry.isAudio) return (IconsaxPlusLinear.music, colors.success);
    if (entry.mime == "application/pdf") return (IconsaxPlusLinear.document_text, cs.error);
    if (entry.mime.startsWith("text/")) return (IconsaxPlusLinear.document_text_1, cs.tertiary);
    if (entry.mime.startsWith("application/zip") || entry.mime.startsWith("application/x-")) {
      return (IconsaxPlusLinear.archive, cs.tertiary);
    }
    return (IconsaxPlusLinear.document, cs.outline);
  }
}
