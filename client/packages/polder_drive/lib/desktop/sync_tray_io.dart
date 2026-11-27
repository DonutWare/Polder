import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:ui" as ui;

import "package:material_ui/material_ui.dart";
import "package:flutter/services.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
import "package:go_router/go_router.dart";
import "package:iconsax_plus/iconsax_plus.dart";
import "package:polder_core/util/flavor.dart";
import "package:polder_ui/l10n/generated/app_localizations.dart";
import "package:polder_ui/util/byte_format.dart";
import "package:polder_ui/widgets/shared/confirm_dialog.dart";
import "package:tray_manager/tray_manager.dart" as tray;
import "package:window_manager/window_manager.dart";

import "package:polder_drive/desktop/tray_entry.dart";
import "package:polder_drive/providers/sync/sync_paused_provider.dart";
import "package:polder_drive/providers/sync/tray_status_provider.dart";

final _isDesktopPlatform = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
final _isDesktop = desktopIntegrationsEnabled && _isDesktopPlatform;

/// Prepares the native window, which the runners keep hidden until Flutter shows it.
///
/// With [startHidden] the window stays hidden so the app starts in the tray.
Future<void> initializeDesktopWindow({bool startHidden = false}) async {
  if (!_isDesktopPlatform) return;
  await windowManager.ensureInitialized();
  if (_isDesktop) await windowManager.setPreventClose(true);
  if (startHidden && _isDesktop) {
    if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
    return;
  }
  unawaited(WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) => windowManager.show()));
}

Future<void> setDesktopWindowTitle(String title) async {
  if (_isDesktop) await windowManager.setTitle(title);
}

Future<void> showDesktopWindow() async {
  if (!_isDesktop) return;
  if (Platform.isMacOS) await windowManager.setSkipTaskbar(false);
  await windowManager.show();
  await windowManager.focus();
}

/// Shows the sync status in the system tray, and keeps the app running there when its window closes.
///
/// While not [enabled] there is no tray icon: closing the window quits the app.
class SyncTray extends ConsumerStatefulWidget {
  const SyncTray({
    required this.child,
    required this.appName,
    required this.router,
    this.enabled = true,
    this.openEntries = const [],
    this.newEntries = const [],
    this.findEntries = const [],
    this.appEntries = const [],
    this.refreshOn = const [],
    this.beforeQuit,
    this.restartRequested,
    this.onRestartCancelled,
    super.key,
  });

  final Widget child;
  final String Function(AppLocalizations l10n) appName;
  final GoRouter router;
  final bool enabled;

  /// Shown below the "Open" item.
  final List<TrayEntry> openEntries;

  /// Shown in a "New" submenu, left out when empty.
  final List<TrayEntry> newEntries;

  /// Shown below the "New" submenu.
  final List<TrayEntry> findEntries;

  /// Shown above the "Quit" item.
  final List<TrayEntry> appEntries;

  /// Providers whose changes relabel the entries.
  final List<ProviderListenable<Object?>> refreshOn;

  /// Runs once the app is certain to quit.
  final Future<void> Function({required bool restart})? beforeQuit;

  /// Quits and restarts the app when this turns true, unless the user cancels.
  final ProviderListenable<bool>? restartRequested;
  final VoidCallback? onRestartCancelled;

  @override
  ConsumerState<SyncTray> createState() => _SyncTrayState();
}

typedef _TrayView = ({String status, String? speed, bool paused, bool signedIn, IconData glyph, Color color});

class _SyncTrayState extends ConsumerState<SyncTray> with WindowListener {
  static final _template = Platform.isMacOS;

  tray.TrayIcon? _icon;
  tray.Menu? _menu;
  tray.MenuItem? _statusItem;
  tray.MenuItem? _speedItem;
  tray.MenuItem? _openItem;
  tray.MenuItem? _newItem;
  final List<tray.MenuItem> _openItems = [];
  final List<tray.MenuItem> _newItems = [];
  final List<tray.MenuItem> _findItems = [];
  final List<tray.MenuItem> _appItems = [];
  tray.MenuItem? _pauseItem;
  tray.MenuItem? _quitItem;
  final Map<(IconData, Color), tray.Image> _images = {};
  final List<ProviderSubscription<Object?>> _subscriptions = [];

  AppLocalizations? _l10n;
  Color _color = Colors.black;
  _TrayView? _shown;
  bool _speedShown = false;
  bool _quitting = false;
  AppLifecycleListener? _lifecycle;

  bool get _active => _isDesktop && widget.enabled;

  @override
  void initState() {
    super.initState();
    if (!_isDesktop) return;
    windowManager.addListener(this);
    _lifecycle = AppLifecycleListener(onExitRequested: _onExitRequested);
    if (widget.restartRequested case final restartRequested?) {
      ref.listenManual(restartRequested, (previous, next) {
        if (next && !(previous ?? false)) unawaited(_restart());
      });
    }
    if (widget.enabled) _activate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDesktop) return;
    _l10n = AppLocalizations.of(context);
    _color = _template ? Colors.black : Theme.of(context).colorScheme.primary;
    _apply(relabel: true);
  }

  @override
  void didUpdateWidget(SyncTray oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDesktop) return;
    if (oldWidget.enabled != widget.enabled) {
      widget.enabled ? _activate() : _deactivate();
      return;
    }
    if (oldWidget.openEntries.length != widget.openEntries.length ||
        oldWidget.newEntries.length != widget.newEntries.length ||
        oldWidget.findEntries.length != widget.findEntries.length ||
        oldWidget.appEntries.length != widget.appEntries.length) {
      _removeIcon();
    }
    _apply(relabel: true);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!_isDesktop) return;
    _images.clear();
    _shown = null;
    _apply(relabel: true);
  }

  @override
  void dispose() {
    if (_isDesktop) {
      windowManager.removeListener(this);
      _lifecycle?.dispose();
      _closeSubscriptions();
      _icon?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void onWindowClose() => _active ? unawaited(_hideWindow()) : unawaited(_requestQuit());

  @override
  void onWindowMinimize() {
    if (_active) unawaited(_hideWindow());
  }

  void _activate() {
    _subscriptions.add(ref.listenManual(trayStatusProvider, (_, _) => _apply()));
    for (final provider in widget.refreshOn) {
      _subscriptions.add(ref.listenManual(provider, (_, _) => _apply(relabel: true)));
    }
    _apply(relabel: true);
  }

  void _deactivate() {
    _closeSubscriptions();
    _removeIcon();
    unawaited(_revealIfHidden());
  }

  void _closeSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions.clear();
  }

  void _removeIcon() {
    _icon?.dispose();
    _icon = null;
    _menu = null;
    _shown = null;
    _speedShown = false;
    _openItems.clear();
    _newItems.clear();
    _findItems.clear();
    _appItems.clear();
  }

  /// Without a tray icon a hidden window could not be brought back.
  Future<void> _revealIfHidden() async {
    if (!await windowManager.isVisible()) await showDesktopWindow();
  }

  void _apply({bool relabel = false}) {
    final l10n = _l10n;
    if (l10n == null || !_active) return;
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
    if (view == _shown && !relabel) return;
    final previous = _shown;
    _shown = view;

    final icon = _icon ??= _createIcon();
    if (icon == null) return;
    final appName = widget.appName(l10n);
    _statusItem!.label = view.status;
    _speedItem!.label = view.speed;
    _showSpeed(view.speed != null);
    _openItem!.label = l10n.trayOpenApp(appName);
    _labelEntries(widget.openEntries, _openItems, view);
    _newItem
      ?..label = l10n.trayNew
      ..isEnabled = view.signedIn;
    _labelEntries(widget.newEntries, _newItems, view);
    _labelEntries(widget.findEntries, _findItems, view);
    _pauseItem!
      ..label = view.paused ? l10n.resumeSync : l10n.pauseSync
      ..isEnabled = view.signedIn;
    _labelEntries(widget.appEntries, _appItems, view);
    _quitItem!.label = l10n.trayQuit(appName);
    icon.setTooltip([appName, view.status, ?view.speed].join("\n"));
    if (previous?.glyph != view.glyph || previous?.color != view.color) unawaited(_showGlyph(icon, view));
  }

  void _labelEntries(List<TrayEntry> entries, List<tray.MenuItem> items, _TrayView view) {
    for (var index = 0; index < entries.length && index < items.length; index++) {
      final entry = entries[index];
      items[index]
        ..label = entry.label(context)
        ..isEnabled = (view.signedIn || !entry.needsAccount) && (entry.isEnabled?.call() ?? true);
    }
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
        if (event is tray.TrayIconClickedEvent || event is tray.TrayIconDoubleClickedEvent) {
          Timer.run(showDesktopWindow);
        }
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

    void addEntries(tray.Menu menu, List<TrayEntry> Function() entries, List<tray.MenuItem> items) {
      for (var index = 0; index < entries().length; index++) {
        final entryItem = item(() => unawaited(Future.sync(entries()[index].onSelected)));
        items.add(entryItem);
        menu.addItem(entryItem);
      }
    }

    _speedItem = item(null);
    final menu = _menu = tray.Menu.create()!
      ..addItem(_statusItem = item(null))
      ..addSeparator()
      ..addItem(_openItem = item(showDesktopWindow));
    addEntries(menu, () => widget.openEntries, _openItems);

    if (widget.newEntries.isNotEmpty || widget.findEntries.isNotEmpty) menu.addSeparator();
    if (widget.newEntries.isNotEmpty) {
      final newMenu = tray.Menu.create()!;
      addEntries(newMenu, () => widget.newEntries, _newItems);
      menu.addItem(_newItem = tray.MenuItem.createWithLabelAndType("", tray.MenuItemType.submenu)!..submenu = newMenu);
    } else {
      _newItem = null;
    }
    addEntries(menu, () => widget.findEntries, _findItems);

    menu
      ..addSeparator()
      ..addItem(_pauseItem = item(_togglePause))
      ..addSeparator();
    if (widget.appEntries.isNotEmpty) {
      addEntries(menu, () => widget.appEntries, _appItems);
      menu.addSeparator();
    }
    menu.addItem(_quitItem = item(() => unawaited(_requestQuit())));
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

  Future<ui.AppExitResponse> _onExitRequested() async {
    if (_quitting) return ui.AppExitResponse.exit;
    if (_active) {
      await _hideWindow();
    } else {
      unawaited(_requestQuit());
    }
    return ui.AppExitResponse.cancel;
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
    if (Platform.isMacOS) await windowManager.setSkipTaskbar(true);
  }

  Future<void> _togglePause() async {
    final notifier = ref.read(syncPausedProvider.notifier);
    await ((await ref.read(syncPausedProvider.future)) ? notifier.resume() : notifier.pause());
  }

  Future<void> _restart() async {
    if (!await _requestQuit(restart: true)) widget.onRestartCancelled?.call();
  }

  Future<bool> _requestQuit({bool restart = false}) async {
    if (_quitting) return false;
    _quitting = true;
    try {
      if (ref.read(trayStatusProvider).isSyncing && !await _confirmQuit()) return false;
      await widget.beforeQuit?.call(restart: restart);
      _icon?.dispose();
      _icon = null;
      await ServicesBinding.instance.exitApplication(ui.AppExitType.required);
      return true;
    } finally {
      _quitting = false;
    }
  }

  Future<bool> _confirmQuit() async {
    await showDesktopWindow();
    final context = widget.router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return true;
    final l10n = AppLocalizations.of(context);
    final appName = widget.appName(l10n);
    return showConfirmDialog(
      context,
      title: l10n.quitWhileSyncingTitle,
      message: l10n.quitWhileSyncingMessage(appName),
      confirmLabel: l10n.quit,
    );
  }
}
