import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder/l10n/generated/app_localizations.dart";
import "package:polder/providers/desktop/tray_status_provider.dart";
import "package:polder/providers/sync/sync_paused_provider.dart";
import "package:polder/routes/app_router.dart";
import "package:polder/routes/app_routes.dart";
import "package:polder/util/byte_format.dart";
import "package:polder/util/flavor.dart";
import "package:polder/widgets/shared/confirm_dialog.dart";
import "package:tray_manager/tray_manager.dart" as tray;
import "package:window_manager/window_manager.dart";

final _isDesktop = desktopIntegrationsEnabled && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

Future<void> initializeDesktopWindow() async {
  if (!_isDesktop) return;
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
}

class DesktopTray extends ConsumerStatefulWidget {
  const DesktopTray({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DesktopTray> createState() => _DesktopTrayState();
}

typedef _TrayView = ({String status, String? speed, bool paused, bool signedIn, IconData glyph, Color color});

class _DesktopTrayState extends ConsumerState<DesktopTray> with WindowListener {
  static const _appChannel = MethodChannel("polder/app");
  static final _template = Platform.isMacOS;

  tray.TrayIcon? _icon;
  tray.Menu? _menu;
  tray.MenuItem? _statusItem;
  tray.MenuItem? _speedItem;
  tray.MenuItem? _openItem;
  tray.MenuItem? _syncedItem;
  tray.MenuItem? _pauseItem;
  tray.MenuItem? _quitItem;
  final Map<(IconData, Color), tray.Image> _images = {};

  AppLocalizations? _l10n;
  Color _color = Colors.black;
  _TrayView? _shown;
  bool _speedShown = false;
  bool? _reportedSyncing;
  bool _quitting = false;

  @override
  void initState() {
    super.initState();
    if (!_isDesktop) return;
    windowManager.addListener(this);
    if (Platform.isMacOS) {
      _appChannel.setMethodCallHandler((call) async {
        if (call.method == "quitRequested") await _requestQuit();
      });
    }
    ref.listenManual(trayStatusProvider, (_, _) => _apply());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDesktop) return;
    _l10n = AppLocalizations.of(context);
    _color = _template ? Colors.black : Theme.of(context).colorScheme.primary;
    _apply();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!_isDesktop) return;
    _images.clear();
    _shown = null;
    _apply();
  }

  @override
  void dispose() {
    if (_isDesktop) {
      windowManager.removeListener(this);
      if (Platform.isMacOS) _appChannel.setMethodCallHandler(null);
      _icon?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void onWindowClose() => _hideWindow();

  @override
  void onWindowMinimize() => _hideWindow();

  void _apply() {
    final l10n = _l10n;
    if (l10n == null) return;
    final status = ref.read(trayStatusProvider);
    final view = (
      status: switch (status.phase) {
        TrayPhase.signedOut => l10n.traySignedOut,
        TrayPhase.idle => l10n.trayUpToDate,
        TrayPhase.syncing => status.files > 0 ? l10n.traySyncingFiles(status.files) : l10n.traySyncing,
        TrayPhase.paused => l10n.traySyncPaused,
        TrayPhase.error => l10n.traySyncFailed,
      },
      speed: status.isSyncing ? _speed(status, l10n.localeName) : null,
      paused: status.phase == TrayPhase.paused,
      signedIn: status.phase != TrayPhase.signedOut,
      glyph: switch (status.phase) {
        TrayPhase.signedOut => IconsaxPlusBold.cloud_remove,
        TrayPhase.idle => IconsaxPlusBold.cloud,
        TrayPhase.syncing => IconsaxPlusBold.cloud_change,
        TrayPhase.paused => IconsaxPlusBold.cloud_minus,
        TrayPhase.error => IconsaxPlusBold.cloud_cross,
      },
      color: _color,
    );
    _reportSyncing(status.isSyncing);
    if (view == _shown) return;
    final previous = _shown;
    _shown = view;

    final icon = _icon ??= _createIcon();
    if (icon == null) return;
    _statusItem!.label = view.status;
    _speedItem!.label = view.speed;
    _showSpeed(view.speed != null);
    _openItem!.label = l10n.trayOpenApp;
    _syncedItem!
      ..label = l10n.trayOpenSyncedFolders
      ..isEnabled = view.signedIn;
    _pauseItem!
      ..label = view.paused ? l10n.resumeSync : l10n.pauseSync
      ..isEnabled = view.signedIn;
    _quitItem!.label = l10n.trayQuit;
    icon.setTooltip([l10n.appTitle, view.status, ?view.speed].join("\n"));
    if (previous?.glyph != view.glyph || previous?.color != view.color) unawaited(_showGlyph(icon, view));
  }

  static String? _speed(TrayStatus status, String locale) {
    final parts = [
      if (status.uploadRate > 0) "↑ ${ByteFormat.rate(status.uploadRate, locale: locale)}",
      if (status.downloadRate > 0) "↓ ${ByteFormat.rate(status.downloadRate, locale: locale)}",
    ];
    return parts.isEmpty ? null : parts.join("   ");
  }

  tray.TrayIcon? _createIcon() {
    if (!tray.TrayManager.instance.isSupported()) return null;
    final icon = tray.TrayIcon.create();
    if (icon == null) return null;
    icon
      ..setContextMenuTrigger(
        Platform.isWindows ? tray.ContextMenuTrigger.rightClicked : tray.ContextMenuTrigger.clicked,
      )
      ..addListener((event) {
        if (!Platform.isWindows) return;
        if (event is tray.TrayIconClickedEvent || event is tray.TrayIconDoubleClickedEvent) Timer.run(_showWindow);
      })
      ..setVisible(true);
    _buildMenu(icon);
    return icon;
  }

  void _buildMenu(tray.TrayIcon icon) {
    tray.MenuItem item(void Function()? onClick) {
      final item = tray.MenuItem.createWithLabelAndType("", tray.MenuItemType.normal)!;
      if (onClick == null) {
        item.isEnabled = false;
      } else {
        item.addListener((event) {
          if (event is tray.MenuItemClickedEvent) Timer.run(onClick);
        });
      }
      return item;
    }

    _speedItem = item(null);
    final menu = _menu = tray.Menu.create()!
      ..addItem(_statusItem = item(null))
      ..addSeparator()
      ..addItem(_openItem = item(_showWindow))
      ..addItem(_syncedItem = item(_openSyncedFolders))
      ..addSeparator()
      ..addItem(_pauseItem = item(_togglePause))
      ..addSeparator()
      ..addItem(_quitItem = item(_requestQuit));
    icon.setContextMenu(menu);
  }

  void _showSpeed(bool show) {
    if (show == _speedShown) return;
    _speedShown = show;
    if (show) {
      _menu!.insertItem(1, _speedItem);
    } else {
      _menu!.removeItem(_speedItem);
    }
  }

  Future<void> _showGlyph(tray.TrayIcon icon, _TrayView view) async {
    final key = (view.glyph, view.color);
    final image = _images[key] ?? await _render(view.glyph, view.color);
    if (image == null || !mounted || _icon != icon) return;
    _images[key] = image;
    if (_shown?.glyph != view.glyph || _shown?.color != view.color) return;
    icon
      ..icon = image
      ..isIconTemplate = _template;
    if (_template) icon.iconSize = const Size.square(18);
  }

  static Future<tray.Image?> _render(IconData glyph, Color color) async {
    final size = _template ? 36.0 : 64.0;
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(glyph.codePoint),
        style: TextStyle(
          fontFamily: glyph.fontFamily,
          package: glyph.fontPackage,
          fontSize: size,
          height: 1,
          color: color,
        ),
      ),
    )..layout();
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), Offset((size - painter.width) / 2, (size - painter.height) / 2));
    painter.dispose();
    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (png == null) return null;
    return tray.Image.fromBase64("data:image/png;base64,${base64Encode(png.buffer.asUint8List())}");
  }

  void _reportSyncing(bool syncing) {
    if (!Platform.isMacOS || syncing == _reportedSyncing) return;
    _reportedSyncing = syncing;
    unawaited(_appChannel.invokeMethod("setSyncing", syncing));
  }

  Future<void> _showWindow() async {
    if (Platform.isMacOS) await windowManager.setSkipTaskbar(false);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
    if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
  }

  Future<void> _openSyncedFolders() async {
    ref.read(routerProvider).go(AppRoutes.sync);
    await _showWindow();
  }

  Future<void> _togglePause() async {
    final notifier = ref.read(syncPausedProvider.notifier);
    await ((await ref.read(syncPausedProvider.future)) ? notifier.resume() : notifier.pause());
  }

  Future<void> _requestQuit() async {
    if (_quitting) return;
    _quitting = true;
    try {
      if (ref.read(trayStatusProvider).isSyncing && !await _confirmQuit()) return;
      _icon?.dispose();
      _icon = null;
      if (Platform.isMacOS) {
        await _appChannel.invokeMethod("quit");
      } else {
        await windowManager.destroy();
      }
    } finally {
      _quitting = false;
    }
  }

  Future<bool> _confirmQuit() async {
    await _showWindow();
    final context = ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return true;
    final l10n = AppLocalizations.of(context);
    return showConfirmDialog(
      context,
      title: l10n.quitWhileSyncingTitle,
      message: l10n.quitWhileSyncingMessage,
      confirmLabel: l10n.quit,
    );
  }
}
