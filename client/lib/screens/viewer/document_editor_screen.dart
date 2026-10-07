import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";

import "package:polder/models/document_editor.dart";
import "package:polder/models/file_entry.dart";
import "package:polder/providers/account_provider.dart";
import "package:polder/providers/browser/transfers_provider.dart";
import "package:polder/providers/polder_api_provider.dart";
import "package:polder/screens/browser/widgets/file_details_sheet.dart";
import "package:polder/screens/viewer/editor_theme.dart";
import "package:polder/screens/viewer/editor_view.dart";
import "package:polder/theme/app_theme.dart";
import "package:polder/util/localization_helper.dart";
import "package:polder/widgets/shared/async_value_view.dart";
import "package:polder/widgets/shared/centered_progress.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";

enum _SaveState { saved, unsaved, saving }

class DocumentEditorScreen extends ConsumerStatefulWidget {
  const DocumentEditorScreen({required this.entry, super.key});

  final FileEntry entry;

  @override
  ConsumerState<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  static const _saveTimeout = Duration(seconds: 30);

  AsyncValue<EditorSession> _session = const AsyncLoading();
  EditorTheme? _theme;
  int _generation = 0;
  EditorChannel? _channel;
  bool _loaded = false;
  bool _closing = false;
  _SaveState _state = _SaveState.saved;
  Completer<bool>? _saveResult;

  Uri get _server => Uri.parse(ref.read(currentAccountProvider)!.serverUrl);

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = EditorTheme.of(context);
    if (_theme == null) {
      _theme = theme;
    } else if (theme != _theme) {
      unawaited(_reloadWith(theme));
    }
  }

  Future<void> _start() async {
    setState(() => _session = const AsyncLoading());
    final result = await AsyncValue.guard(
      () => ref.read(polderApiProvider).startEditorSession(widget.entry.path, origin: _server.origin),
    );
    if (mounted) setState(() => _session = result);
  }

  // Collabora takes its theme only when it opens a document, so a new theme reopens it after saving.
  Future<void> _reloadWith(EditorTheme theme) async {
    await _save();
    if (!mounted) return;
    setState(() {
      _theme = theme;
      _generation++;
      _loaded = false;
    });
  }

  Uri _page(EditorSession session, String language) => _server.replace(
    path: session.hostPage,
    queryParameters: {"v": "$_generation"},
    fragment: Uri(
      queryParameters: {
        "src": "${session.editorUrl}&lang=${Uri.encodeQueryComponent(language)}",
        "access_token": session.accessToken,
        "access_token_ttl": "${session.accessTokenTtl}",
        "ui_defaults": _theme!.uiDefaults,
        "css_variables": _theme!.cssVariables,
        "background": _theme!.background,
        if (kIsWeb) "parent": Uri.base.origin,
      },
    ).query,
  );

  void _onMessage(Map<String, Object?> message) {
    final values = message["Values"];
    switch ((message["MessageId"], values)) {
      case ("App_LoadingStatus", {"Status": "Document_Loaded" || "Failed"}):
        setState(() => _loaded = true);
      case ("Doc_ModifiedStatus", {"Modified": final bool modified}):
        setState(() => _state = modified ? _SaveState.unsaved : _SaveState.saved);
      case ("Action_Save_Resp", {"success": final bool success}):
        _saveResult?.complete(success);
        _saveResult = null;
        setState(() => _state = success ? _SaveState.saved : _SaveState.unsaved);
      case ("UI_Close", _):
        unawaited(_close());
    }
  }

  Future<bool> _save() async {
    final channel = _channel;
    if (channel == null || _state == _SaveState.saved) return true;
    final result = _saveResult ??= Completer<bool>();
    setState(() => _state = _SaveState.saving);
    channel.send({
      "MessageId": "Action_Save",
      "Values": {"DontTerminateEdit": true, "DontSaveIfUnmodified": true, "Notify": true},
    });
    return result.future.timeout(_saveTimeout, onTimeout: () => false);
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    final saved = await _save();
    if (!mounted) return;
    if (!saved) {
      final leave = await showConfirmDialog(
        context,
        title: context.localized.editorSaveFailedTitle,
        message: context.localized.editorSaveFailedMessage,
        confirmLabel: context.localized.editorLeave,
        destructive: true,
      );
      if (!mounted) return;
      if (!leave) {
        _closing = false;
        return;
      }
    }
    setState(() => _state = _SaveState.saved);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).toLanguageTag();
    return PopScope(
      canPop: !_loaded || _state == _SaveState.saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).canvas,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.entry.name, overflow: TextOverflow.ellipsis),
              if (_status(context) case final status?) Text(status, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          actions: [
            IconButton(
              tooltip: context.localized.download,
              icon: const Icon(IconsaxPlusLinear.document_download),
              onPressed: () async {
                await _save();
                await ref.read(transfersProvider.notifier).download(widget.entry);
              },
            ),
            IconButton(
              tooltip: context.localized.details,
              icon: const Icon(IconsaxPlusLinear.info_circle),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => FileDetailsSheet(entry: widget.entry),
              ),
            ),
          ],
        ),
        body: AsyncValueView<EditorSession>(
          value: _session,
          onRetry: _start,
          data: (session) => Stack(
            children: [
              EditorView(
                page: _page(session, language),
                onMessage: _onMessage,
                onReady: (channel) => _channel = channel,
              ),
              if (!_loaded) const Positioned.fill(child: IgnorePointer(child: CenteredProgress())),
            ],
          ),
        ),
      ),
    );
  }

  String? _status(BuildContext context) {
    if (_session.value?.readOnly ?? false) return context.localized.editorReadOnly;
    if (!_loaded) return null;
    return switch (_state) {
      _SaveState.saved => context.localized.editorSaved,
      _SaveState.unsaved => context.localized.editorUnsaved,
      _SaveState.saving => context.localized.editorSaving,
    };
  }
}
