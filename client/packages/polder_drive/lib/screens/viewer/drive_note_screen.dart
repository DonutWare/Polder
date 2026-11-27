import "dart:async";

import "package:material_ui/material_ui.dart";

import "package:polder_notes/screens/notes/widgets/note_pane.dart";
import "package:polder_ui/routes/up_scope.dart";

class DriveNoteScreen extends StatefulWidget {
  const DriveNoteScreen({required this.path, super.key});

  final String path;

  @override
  State<DriveNoteScreen> createState() => _DriveNoteScreenState();
}

class _DriveNoteScreenState extends State<DriveNoteScreen> {
  var _sourceMode = false;

  @override
  Widget build(BuildContext context) => NotePane(
    key: ValueKey(widget.path),
    path: widget.path,
    sourceMode: _sourceMode,
    onToggleSourceMode: () => setState(() => _sourceMode = !_sourceMode),
    leading: BackButton(onPressed: () => unawaited(UpScope.navigateUp(context))),
  );
}
