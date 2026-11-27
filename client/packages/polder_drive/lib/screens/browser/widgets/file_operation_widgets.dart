import "package:material_ui/material_ui.dart";

import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder_core/providers/browser/file_operations_provider.dart";
import "package:polder_ui/widgets/files/file_type_icon.dart";
import "package:polder_drive/screens/browser/widgets/pending_upload_widgets.dart";
import "package:polder_ui/theme/app_theme.dart";
import "package:polder_ui/util/localization_helper.dart";
import "package:polder_ui/widgets/shared/level_bar.dart";
import "package:polder_ui/widgets/shared/tag.dart";

extension FileOperationKindPresentation on FileOperationKind {
  IconData get icon => switch (this) {
    FileOperationKind.move => IconsaxPlusLinear.folder_open,
    FileOperationKind.copy => IconsaxPlusLinear.copy,
    FileOperationKind.delete || FileOperationKind.purge => IconsaxPlusLinear.trash,
    FileOperationKind.rename => IconsaxPlusLinear.edit_2,
    FileOperationKind.restore => IconsaxPlusLinear.rotate_left,
  };

  Color color(BuildContext context) => switch (this) {
    FileOperationKind.delete || FileOperationKind.purge => Theme.of(context).colorScheme.error,
    _ => Theme.of(context).colorScheme.primary,
  };

  String tag(BuildContext context) => switch (this) {
    FileOperationKind.move => context.localized.fileOperationTagMoving,
    FileOperationKind.copy => context.localized.fileOperationTagCopying,
    FileOperationKind.delete || FileOperationKind.purge => context.localized.fileOperationTagDeleting,
    FileOperationKind.rename => context.localized.fileOperationTagRenaming,
    FileOperationKind.restore => context.localized.fileOperationTagRestoring,
  };

  String arrivingTag(BuildContext context) => switch (this) {
    FileOperationKind.copy => context.localized.fileOperationTagCopyingHere,
    _ => context.localized.fileOperationTagMovingHere,
  };

  String title(BuildContext context, String subject, {required bool finished}) => switch (this) {
    FileOperationKind.move when finished => context.localized.fileOperationMoved(subject),
    FileOperationKind.move => context.localized.fileOperationMoving(subject),
    FileOperationKind.copy when finished => context.localized.fileOperationCopied(subject),
    FileOperationKind.copy => context.localized.fileOperationCopying(subject),
    FileOperationKind.delete when finished => context.localized.fileOperationDeleted(subject),
    FileOperationKind.delete => context.localized.fileOperationDeleting(subject),
    FileOperationKind.rename when finished => context.localized.fileOperationRenamed(subject),
    FileOperationKind.rename => context.localized.fileOperationRenaming(subject),
    FileOperationKind.restore when finished => context.localized.fileOperationRestored(subject),
    FileOperationKind.restore => context.localized.fileOperationRestoring(subject),
    FileOperationKind.purge when finished => context.localized.fileOperationPurged(subject),
    FileOperationKind.purge => context.localized.fileOperationPurging(subject),
  };
}

double? _itemFraction(FileOperationItemState state) => switch (state) {
  FileOperationItemState.waiting => 0,
  FileOperationItemState.active => null,
  FileOperationItemState.done || FileOperationItemState.failed => 1,
};

class FileOperationStatus extends StatelessWidget {
  const FileOperationStatus({required this.label, required this.kind, required this.state, super.key});

  final String label;
  final FileOperationKind kind;
  final FileOperationItemState state;

  @override
  Widget build(BuildContext context) {
    final waiting = state == FileOperationItemState.waiting;
    final color = waiting ? Theme.of(context).colorScheme.outline : kind.color(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Tag(
          icon: waiting ? IconsaxPlusLinear.clock : kind.icon,
          text: waiting ? context.localized.fileOperationTagWaiting : label,
          color: color,
        ),
        LevelBar(fraction: _itemFraction(state), height: 4, color: color),
      ],
    );
  }
}

class BusyEntry extends StatelessWidget {
  const BusyEntry({required this.operation, required this.child, super.key});

  final EntryOperation operation;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedOpacity(
      opacity: operation.state == FileOperationItemState.active ? 1 : 0.6,
      duration: const Duration(milliseconds: 200),
      child: child,
    ),
  );
}

class EntryOperationStatus extends StatelessWidget {
  const EntryOperationStatus({required this.operation, super.key});

  final EntryOperation operation;

  @override
  Widget build(BuildContext context) =>
      FileOperationStatus(label: operation.kind.tag(context), kind: operation.kind, state: operation.state);
}

class ArrivingListTile extends StatelessWidget {
  const ArrivingListTile({required this.item, super.key});

  final ArrivingItem item;

  @override
  Widget build(BuildContext context) => PendingHighlight(
    child: ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 16, top: 4, bottom: 4),
      leading: FileTypeIcon.of(isDir: item.isDir, mime: "", size: 40),
      title: Text(item.name, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: FileOperationStatus(label: item.kind.arrivingTag(context), kind: item.kind, state: item.state),
      ),
    ),
  );
}

class ArrivingGridTile extends StatelessWidget {
  const ArrivingGridTile({required this.item, super.key});

  final ArrivingItem item;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      color: Color.alphaBlend(primary.withValues(alpha: 0.07), Theme.of(context).cardTheme.color ?? Colors.transparent),
      shape: squircle(AppRadius.inset + 4, side: BorderSide(color: primary, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Expanded(
              child: Center(
                child: FileTypeIcon.of(isDir: item.isDir, mime: "", size: 56),
              ),
            ),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            FileOperationStatus(label: item.kind.arrivingTag(context), kind: item.kind, state: item.state),
          ],
        ),
      ),
    );
  }
}
