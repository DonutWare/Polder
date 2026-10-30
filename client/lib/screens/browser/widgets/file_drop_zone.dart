import "dart:async";

import "package:desktop_drop/desktop_drop.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:polder/models/file_entry.dart";
import "package:polder/models/file_mount.dart";
import "package:polder/providers/browser/directory_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/screens/browser/widgets/file_drag.dart";
import "package:polder/services/transfer/file_picker_service.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/action_feedback.dart";
import "package:polder/util/remote_path.dart";
import "package:polder/widgets/navigation/intercept_back.dart";

bool _canCreateIn(FileMount? mount) => mount == null || mount.permissions.create;

class FileDropZone extends ConsumerStatefulWidget {
  const FileDropZone({required this.path, required this.child, super.key});

  final String path;
  final Widget child;

  static bool isDestination(BuildContext context, String folder) =>
      context.dependOnInheritedWidgetOfExactType<_DropScope>()?.destination == folder;

  @override
  ConsumerState<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends ConsumerState<FileDropZone> {
  String? _destination;

  String? _destinationAt(Offset globalPosition) {
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, globalPosition, View.of(context).viewId);
    for (final hit in result.path) {
      if (hit.target case RenderMetaData(metaData: _DroppableFolder(:final folder))) {
        return _canCreateIn(folder.mount) ? folder.path : null;
      }
    }
    return _canCreateIn(ref.read(directoryProvider(widget.path)).value?.mount) ? widget.path : null;
  }

  void _hover(Offset globalPosition) {
    final destination = _destinationAt(globalPosition);
    if (destination != _destination) setState(() => _destination = destination);
  }

  void _leave() {
    if (_destination != null) setState(() => _destination = null);
  }

  void _dropped(DropDoneDetails details) {
    final destination = _destinationAt(details.globalPosition);
    _leave();
    if (destination == null || details.files.isEmpty) return;
    unawaited(context.runWithFeedback(_upload(ref.read(transfersProvider.notifier), destination, details.files)));
  }

  static Future<void> _upload(TransfersNotifier transfers, String directory, List<DropItem> items) => Future.wait(
    items.map((item) async {
      if (item is! DropItemDirectory) return transfers.upload(directory, XFilePickedFile(item));
      final folder = RemotePath.join(directory, p.basename(item.path));
      await transfers.ensureFolder(folder);
      await _upload(transfers, folder, item.children);
    }),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DropTarget(
      enable: isFrontmost(context) && TickerMode.valuesOf(context).enabled,
      onDragEntered: (details) => _hover(details.globalPosition),
      onDragUpdated: (details) => _hover(details.globalPosition),
      onDragExited: (_) => _leave(),
      onDragDone: _dropped,
      child: _DropScope(
        destination: _destination,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_destination == widget.path)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    border: Border.all(color: colors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DropScope extends InheritedWidget {
  const _DropScope({required this.destination, required super.child});

  final String? destination;

  @override
  bool updateShouldNotify(_DropScope oldWidget) => destination != oldWidget.destination;
}

class _DroppableFolder {
  const _DroppableFolder(this.folder);

  final FileEntry folder;
}

class FolderDropTarget extends StatelessWidget {
  const FolderDropTarget({required this.folder, required this.child, this.shape, super.key});

  final FileEntry folder;
  final Widget child;
  final ShapeBorder Function(BorderSide side)? shape;

  @override
  Widget build(BuildContext context) {
    final external = FileDropZone.isDestination(context, folder.path);
    return MetaData(
      metaData: _DroppableFolder(folder),
      child: FileMoveTarget(
        destination: folder.path,
        builder: (context, moving) => _highlighted(context, active: external || moving),
      ),
    );
  }

  Widget _highlighted(BuildContext context, {required bool active}) {
    final color = Theme.of(context).colorScheme.primary;
    final side = BorderSide(color: color.withValues(alpha: active ? 0.8 : 0), width: 2);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      foregroundDecoration: ShapeDecoration(
        shape: shape?.call(side) ?? squircle(AppRadius.inset + 4, side: side),
        color: color.withValues(alpha: active ? 0.12 : 0),
      ),
      child: child,
    );
  }
}
